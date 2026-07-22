#!/usr/bin/env python3
"""
Convert BL Living with Machines / British Library Widnes Examiner plaintext + metadata
ZIP files into a PressMint-style TEI sample tree.

Typical full-archive use:
    python convert_widnes_to_pressmint_v3.py \
        --input BLNewspapers_WidnesExaminer_0002601_1908.zip \
        --output Samples/PressMint-GB \
        --encoder "Dr Ignatius M. Ezeani"

Batch use with several ZIPs/URLs:
    python convert_widnes_to_pressmint_v3.py \
        --inputs BLNewspapers_WidnesExaminer_0002601_1908.zip BLNewspapers_WidnesExaminer_0002601_1909.zip \
        --output Samples/PressMint-GB \
        --encoder "Dr Ignatius M. Ezeani"

Batch use with a text file of ZIPs/URLs, limiting to the first 15 source years
(one line is treated as one source year):
    python convert_widnes_to_pressmint.py \
        --inputs-file widnes_pressmint_links.txt \
        --num-years 15 \
        --workers 8 \
        --output Samples/PressMint-GB \
        --encoder "Dr Ignatius M. Ezeani"

Sample-folder use with the two small ZIPs:
    python convert_widnes_to_pressmint.py \
        --plaintext-zip 0104_plaintext.zip \
        --metadata-zip 0104_metadata.zip \
        --output Samples/PressMint-GB \
        --encoder "Dr Ignatius M. Ezeani"

Notes:
- Each issue/date folder is converted to one PressMint component TEI file.
- Repeated runs and batch runs are cumulative: PressMint-GB.xml is rebuilt from all existing YYYY/*.xml components.
- Batch mode accepts many local ZIPs/directories/URLs or a text file containing one source per line.
- Use --num-years N to process only the first N source-year entries from --inputs-file/--inputs.
- Use --workers N to process issue/date folders concurrently within each source year.
- Each article/advert/section text file becomes a <div> inside that component.
- Very short OCR fragments are represented as <gap> by default and reported in the manifest.
- The generated TEI is designed to be a strong PressMint starter. Always run the official
  PressMint validation target afterwards, e.g. `make validate-TEI-GB` from the repo root.
"""

from __future__ import annotations

import argparse
import copy
import csv
import html
import os
import re
import shutil
import sys
import tempfile
import urllib.parse
import urllib.request
import zipfile
from collections import Counter
from concurrent.futures import ProcessPoolExecutor, as_completed
from dataclasses import dataclass, field
from datetime import date
from pathlib import Path
from typing import Dict, Iterable, Iterator, List, Optional, Sequence, Tuple
import xml.etree.ElementTree as ET

TEI_NS = "http://www.tei-c.org/ns/1.0"
XI_NS = "http://www.w3.org/2001/XInclude"
XML_NS = "http://www.w3.org/XML/1998/namespace"

ET.register_namespace("", TEI_NS)
ET.register_namespace("xi", XI_NS)

try:
    from tqdm import tqdm  # type: ignore
except Exception:  # pragma: no cover - tqdm is optional
    tqdm = None


def qn(tag: str) -> str:
    return f"{{{TEI_NS}}}{tag}"


def xml_attr(name: str) -> str:
    return f"{{{XML_NS}}}{name}"


def xi_qn(tag: str) -> str:
    return f"{{{XI_NS}}}{tag}"


def sub(parent: ET.Element, tag: str, attrs: Optional[dict] = None, text: Optional[str] = None) -> ET.Element:
    child = ET.SubElement(parent, qn(tag), attrs or {})
    if text is not None:
        child.text = text
    return child


def sanitize_xml_id(value: str) -> str:
    value = re.sub(r"[^A-Za-z0-9_.-]+", "-", value.strip())
    value = re.sub(r"-+", "-", value).strip("-._")
    if not value or not re.match(r"^[A-Za-z_]", value):
        value = f"id-{value}"
    return value


def normalize_space_for_filename(value: str) -> str:
    value = re.sub(r"[^A-Za-z0-9]+", "", value.strip())
    return value or "Newspaper"


def safe_extract_zip(zip_path: Path, dest_dir: Path) -> None:
    dest_dir.mkdir(parents=True, exist_ok=True)
    dest_resolved = dest_dir.resolve()
    with zipfile.ZipFile(zip_path) as zf:
        for member in zf.infolist():
            target = (dest_dir / member.filename).resolve()
            if not str(target).startswith(str(dest_resolved)):
                raise RuntimeError(f"Unsafe ZIP member path: {member.filename}")
        zf.extractall(dest_dir)


def download_url(url: str, dest_dir: Path, match: Optional[str] = None) -> Path:
    """Download a direct ZIP URL, or parse an HTML page for a .zip link."""
    dest_dir.mkdir(parents=True, exist_ok=True)
    headers = {"User-Agent": "Mozilla/5.0 PressMint conversion script"}
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req) as resp:
        content_type = resp.headers.get("Content-Type", "").lower()
        data = resp.read()

    url_name = Path(urllib.parse.urlparse(url).path).name
    is_zip = url.lower().endswith(".zip") or "zip" in content_type or data.startswith(b"PK\x03\x04")
    if is_zip:
        out = dest_dir / (url_name if url_name.endswith(".zip") else "download.zip")
        out.write_bytes(data)
        return out

    # Treat response as HTML and look for ZIP links.
    text = data.decode("utf-8", errors="replace")
    hrefs = re.findall(r"href=[\"']([^\"']+\.zip(?:\?[^\"']*)?)[\"']", text, flags=re.I)
    if not hrefs:
        raise RuntimeError("The URL did not return a ZIP and no .zip links were found in the page HTML.")
    links = [urllib.parse.urljoin(url, html.unescape(h)) for h in hrefs]
    if match:
        matched = [u for u in links if match in urllib.parse.unquote(u)]
        if matched:
            links = matched
    chosen = links[0]
    return download_url(chosen, dest_dir, match=None)


def is_url(value: str) -> bool:
    return value.startswith("http://") or value.startswith("https://")


@dataclass
class SourceSpec:
    """A local ZIP/directory/URL to process in batch mode.

    Optional download_match is useful when the value is an HTML page containing
    multiple ZIP links and a particular ZIP filename fragment must be selected.
    """
    value: str
    download_match: str = ""


@dataclass
class ItemMeta:
    metadata_file: str = ""
    source_file: str = ""
    publication_id: str = ""
    publication_source: str = ""
    newspaper_title: str = ""
    publication_location: str = ""
    issue_id: str = ""
    issue_date: str = ""
    item_id: str = ""
    plain_text_file: str = ""
    item_title: str = ""
    item_type: str = ""
    word_count: Optional[int] = None
    ocr_quality_mean: Optional[float] = None
    ocr_quality_sd: Optional[float] = None
    input_sub_path: str = ""
    input_filename: str = ""
    source_type: str = ""
    xml_flavour: str = ""
    software: str = ""


MANIFEST_FIELDNAMES = [
    "component_id", "issue_folder", "issue_date", "source_item_id", "div_type", "included", "reason",
    "plaintext_file", "metadata_file", "chars", "words", "source_word_count", "ocr_quality_mean",
    "ocr_quality_sd", "item_title", "item_type", "publication_id", "publication_title", "publication_location",
    "input_sub_path", "input_filename",
]


@dataclass
class IssueResult:
    issue_name: str
    issue_date: str
    component_rel_path: Path
    component_summary: dict
    manifest_rows: List[dict]
    n_items: int


def text_or_empty(elem: Optional[ET.Element]) -> str:
    if elem is None or elem.text is None:
        return ""
    return elem.text.strip()


def parse_int(value: str) -> Optional[int]:
    try:
        return int(value)
    except Exception:
        return None


def parse_float(value: str) -> Optional[float]:
    try:
        return float(value)
    except Exception:
        return None


def parse_lwm_metadata(xml_path: Path) -> ItemMeta:
    try:
        root = ET.parse(xml_path).getroot()
    except ET.ParseError as exc:
        raise RuntimeError(f"Could not parse metadata XML {xml_path}: {exc}") from exc

    pub = root.find("publication")
    issue = pub.find("issue") if pub is not None else None
    item = issue.find("item") if issue is not None else None
    process = root.find("process")

    meta = ItemMeta(metadata_file=xml_path.name)
    if process is not None:
        meta.source_type = text_or_empty(process.find("source_type"))
        meta.xml_flavour = text_or_empty(process.find("xml_flavour"))
        meta.software = text_or_empty(process.find("software"))
        meta.input_sub_path = text_or_empty(process.find("input_sub_path"))
        meta.input_filename = text_or_empty(process.find("input_filename"))
    if pub is not None:
        meta.publication_id = pub.attrib.get("id", "")
        meta.publication_source = text_or_empty(pub.find("source"))
        meta.newspaper_title = text_or_empty(pub.find("title"))
        meta.publication_location = text_or_empty(pub.find("location"))
    if issue is not None:
        meta.issue_id = issue.attrib.get("id", "")
        meta.issue_date = text_or_empty(issue.find("date")) or meta.issue_id
    if item is not None:
        meta.item_id = item.attrib.get("id", "")
        meta.plain_text_file = text_or_empty(item.find("plain_text_file"))
        meta.item_title = text_or_empty(item.find("title"))
        meta.item_type = text_or_empty(item.find("item_type"))
        meta.word_count = parse_int(text_or_empty(item.find("word_count")))
        meta.ocr_quality_mean = parse_float(text_or_empty(item.find("ocr_quality_mean")))
        meta.ocr_quality_sd = parse_float(text_or_empty(item.find("ocr_quality_sd")))
    return meta


def read_text_file(path: Path) -> str:
    for enc in ("utf-8-sig", "utf-8", "latin-1"):
        try:
            return path.read_text(encoding=enc)
        except UnicodeDecodeError:
            continue
    return path.read_text(errors="replace")


def clean_ocr_text(text: str, join_lines: bool = True) -> str:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    # Remove non-XML control characters, retaining tab and newline.
    text = re.sub(r"[\x00-\x08\x0B\x0C\x0E-\x1F]", "", text)
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    if join_lines:
        blocks = re.split(r"\n\s*\n", text.strip())
        joined = []
        for block in blocks:
            lines = [ln.strip() for ln in block.splitlines() if ln.strip()]
            if lines:
                joined.append(" ".join(lines))
        text = "\n\n".join(joined)
    return text.strip()


def split_paragraphs(text: str) -> List[str]:
    paras = [p.strip() for p in re.split(r"\n\s*\n", text) if p.strip()]
    if not paras and text.strip():
        paras = [text.strip()]
    return paras


def count_words(text: str) -> int:
    return len(re.findall(r"\b\w+\b", text, flags=re.UNICODE))


def natural_key(path_or_name) -> List[object]:
    name = Path(path_or_name).name
    return [int(x) if x.isdigit() else x.lower() for x in re.split(r"(\d+)", name)]


def detect_dirs(extracted_root: Path) -> Tuple[Path, Path]:
    dirs = [p for p in extracted_root.rglob("*") if p.is_dir()]
    plaintext_candidates = [p for p in dirs if re.search(r"plain[_-]?text|plaintext", p.name, re.I)]
    metadata_candidates = [p for p in dirs if re.search(r"metadata", p.name, re.I)]

    if not plaintext_candidates or not metadata_candidates:
        raise RuntimeError(
            "Could not locate plaintext and metadata directories. Use --plaintext-dir and --metadata-dir "
            "or pass --plaintext-zip and --metadata-zip."
        )

    # Prefer directories that contain child issue dirs or .txt/.xml files.
    plaintext_candidates.sort(key=lambda p: (len(list(p.rglob("*.txt"))), -len(p.parts)), reverse=True)
    metadata_candidates.sort(key=lambda p: (len(list(p.rglob("*.xml"))), -len(p.parts)), reverse=True)
    return plaintext_candidates[0], metadata_candidates[0]


def child_issue_dirs(base: Path, suffix: str) -> Dict[str, Path]:
    children = {p.name: p for p in base.iterdir() if p.is_dir()}
    if children:
        return children
    # Fallback: files directly inside the base directory; treat as one pseudo-issue.
    files = list(base.glob(f"*.{suffix}"))
    if files:
        return {base.name: base}
    return {}


def display_source(value: str, max_len: int = 110) -> str:
    value = value.strip()
    if len(value) <= max_len:
        return value
    return value[: max_len - 3] + "..."


def source_label(value: str) -> str:
    """Build a filesystem-safe label for per-input temporary work directories."""
    parsed = urllib.parse.urlparse(value)
    if parsed.scheme and parsed.netloc:
        name = Path(parsed.path).name or parsed.netloc
        if not Path(name).suffix:
            name = f"{parsed.netloc}_{name}"
    else:
        name = Path(value).stem or Path(value).name or "source"
    return sanitize_xml_id(name)[:80] or "source"


def progress_iter(items: Sequence[str], description: str, args, unit: str = "issue") -> Iterator[str]:
    """Yield items with tqdm if available, otherwise a simple plain-text progress log."""
    progress_mode = getattr(args, "progress", "auto")
    if progress_mode == "none":
        yield from items
        return

    use_tqdm = tqdm is not None and (progress_mode == "tqdm" or (progress_mode == "auto" and sys.stderr.isatty()))
    if use_tqdm:
        yield from tqdm(items, desc=description, unit=unit)
        return

    total = len(items)
    for idx, item in enumerate(items, 1):
        print(f"{description}: {idx}/{total} {unit}s - {item}")
        yield item


def parse_source_line(line: str) -> Optional[SourceSpec]:
    """Parse one line from --inputs-file.

    Accepted forms:
      /path/to/archive.zip
      https://example.org/page-with-zip-links
      https://example.org/page-with-zip-links<TAB>BLNewspapers_WidnesExaminer_0002601_1908
      https://example.org/page-with-zip-links match=BLNewspapers_WidnesExaminer_0002601_1908

    Blank lines and lines starting with # are ignored.
    """
    stripped = line.strip()
    if not stripped or stripped.startswith("#"):
        return None

    match = ""
    value = stripped
    if "\t" in stripped:
        value, match = stripped.split("\t", 1)
    elif " match=" in stripped:
        value, match = stripped.rsplit(" match=", 1)
    return SourceSpec(value=value.strip(), download_match=match.strip())


def collect_source_specs(args) -> List[SourceSpec]:
    specs: List[SourceSpec] = []
    if getattr(args, "input", None):
        specs.append(SourceSpec(value=args.input, download_match=args.download_match or ""))
    for value in getattr(args, "inputs", None) or []:
        specs.append(SourceSpec(value=value, download_match=args.download_match or ""))
    if getattr(args, "inputs_file", None):
        list_path = Path(args.inputs_file)
        if not list_path.exists():
            raise RuntimeError(f"Inputs file not found: {list_path}")
        for line_number, line in enumerate(list_path.read_text(encoding="utf-8").splitlines(), 1):
            spec = parse_source_line(line)
            if spec is None:
                continue
            if not spec.download_match:
                spec.download_match = args.download_match or ""
            specs.append(spec)

    args.total_source_specs = len(specs)
    if getattr(args, "num_years", None) is not None:
        # The Widnes links file has one source archive per year. Preserve file order
        # and process only the first N entries when requested.
        specs = specs[: args.num_years]
    args.selected_source_specs = len(specs)
    return specs


def is_batch_request(args) -> bool:
    return bool(getattr(args, "inputs", None) or getattr(args, "inputs_file", None))


def is_meaningful_title(value: str) -> bool:
    """Avoid promoting OCR punctuation/noise such as '_' or '.' to <head>."""
    value = (value or "").strip()
    if len(value) < 3:
        return False
    if not re.search(r"[A-Za-z0-9]", value):
        return False
    # Require at least two alphanumeric characters so OCR noise like "x" does not become a heading.
    if len(re.findall(r"[A-Za-z0-9]", value)) < 2:
        return False
    return True

def map_item_type_to_div_type(item_type: str, file_name: str) -> str:
    value = (item_type or "").strip().upper()
    if value in {"ADVERT", "ADVERTISEMENT", "AD"}:
        return "advertisement"
    if value in {"ARTICLE", "NEWS"}:
        return "article"
    if value in {"SUPPLEMENT"}:
        return "supplement"
    if "sect" in file_name.lower():
        # In the sample, sect0001 has item_type ADVERT. This fallback is for missing metadata.
        return "article"
    return "article"


def make_publication_stmt(parent: ET.Element, args) -> ET.Element:
    publication_stmt = sub(parent, "publicationStmt")
    publisher = sub(publication_stmt, "publisher")
    sub(publisher, "orgName", {xml_attr("lang"): "en"}, args.publisher)
    sub(publisher, "ref", {"target": "https://www.clarin.eu/"}, "www.clarin.eu")
    if args.handle:
        sub(publication_stmt, "idno", {"type": "URI", "subtype": "handle"}, args.handle)
    availability = sub(publication_stmt, "availability", {"status": args.availability_status})
    if args.licence_url:
        sub(availability, "licence", {"target": args.licence_url}, args.licence_url)
    sub(availability, "p", {xml_attr("lang"): "en"}, args.availability_note)
    sub(publication_stmt, "date", {"when": date.today().isoformat()}, date.today().isoformat())
    return publication_stmt


def add_title_stmt(parent: ET.Element, title: str, args, component: bool = False) -> None:
    title_stmt = sub(parent, "titleStmt")
    sub(title_stmt, "title", {"type": "main", xml_attr("lang"): "en"}, title)
    resp_stmt = sub(title_stmt, "respStmt")
    sub(resp_stmt, "persName", None, args.encoder)
    sub(resp_stmt, "resp", {xml_attr("lang"): "en"}, "PressMint TEI XML corpus encoding")
    if args.funder:
        funder = sub(title_stmt, "funder")
        sub(funder, "orgName", {xml_attr("lang"): "en"}, args.funder)


def add_extent(parent: ET.Element, texts: int, words: int) -> None:
    extent = sub(parent, "extent")
    sub(extent, "measure", {"unit": "texts", "quantity": str(texts), xml_attr("lang"): "en"}, f"{texts:,} texts")
    sub(extent, "measure", {"unit": "words", "quantity": str(words), xml_attr("lang"): "en"}, f"{words:,} words")


def add_project_desc(parent: ET.Element) -> None:
    project_desc = sub(parent, "projectDesc")
    p = sub(project_desc, "p", {xml_attr("lang"): "en"})
    ref1 = sub(p, "ref", {"target": "https://www.clarin.eu/pressmint"}, "PressMint")
    ref1.tail = " is a CLARIN project that creates interoperable corpora of historical newspapers encoded according to the "
    ref2 = sub(p, "ref", {"target": "https://clarin-eric.github.io/PressMint/"}, "PressMint encoding guidelines")
    ref2.tail = "."


def add_tags_decl(parent: ET.Element, counts: Counter) -> None:
    tags_decl = sub(parent, "tagsDecl", {"partial": "false"})
    ns = sub(tags_decl, "namespace", {"name": TEI_NS})
    for gi in sorted(counts):
        sub(ns, "tagUsage", {"gi": gi, "occurs": str(counts[gi])})


def add_profile_desc(parent: ET.Element, lang: str, start_date: Optional[str] = None, end_date: Optional[str] = None) -> None:
    profile = sub(parent, "profileDesc")
    if start_date or end_date:
        setting_desc = sub(profile, "settingDesc")
        setting = sub(setting_desc, "setting")
        attrs = {}
        text = ""
        if start_date:
            attrs["from"] = start_date[:4] if re.fullmatch(r"\d{4}-\d{2}-\d{2}", start_date) else start_date
            text = attrs["from"]
        if end_date:
            attrs["to"] = end_date[:4] if re.fullmatch(r"\d{4}-\d{2}-\d{2}", end_date) else end_date
            text = f"{attrs.get('from', '')}-{attrs['to']}" if attrs.get("from") != attrs["to"] else attrs["to"]
        sub(setting, "date", attrs, text)
    lang_usage = sub(profile, "langUsage")
    sub(lang_usage, "language", {"ident": lang, xml_attr("lang"): "en", "default": "true"}, "English" if lang == "en" else lang)


def build_component_xml(
    component_id: str,
    issue_date: str,
    issue_records: List[Tuple[ItemMeta, Path, str, bool, str]],
    component_words: int,
    component_texts: int,
    args,
) -> ET.Element:
    TEI = ET.Element(qn("TEI"), {xml_attr("id"): component_id, xml_attr("lang"): args.language})
    header = sub(TEI, "teiHeader")
    file_desc = sub(header, "fileDesc")

    first_meta = issue_records[0][0] if issue_records else ItemMeta()
    newspaper_title = (first_meta.newspaper_title or args.newspaper_title).strip().rstrip(".")
    comp_title = f"British historical newspaper corpus PressMint-GB, \"{newspaper_title}\", {issue_date} [PressMint SAMPLE]"
    add_title_stmt(file_desc, comp_title, args, component=True)
    edition_stmt = sub(file_desc, "editionStmt")
    sub(edition_stmt, "edition", None, args.edition)
    add_extent(file_desc, component_texts, component_words)
    make_publication_stmt(file_desc, args)

    source_desc = sub(file_desc, "sourceDesc")
    bibl = sub(source_desc, "bibl")
    sub(bibl, "title", {"level": "j"}, first_meta.newspaper_title or args.newspaper_title)
    if first_meta.publication_location:
        sub(bibl, "pubPlace", None, first_meta.publication_location)
    if issue_date:
        sub(bibl, "date", {"when": issue_date}, issue_date)
    if first_meta.publication_source:
        sub(bibl, "publisher", None, first_meta.publication_source)
    if first_meta.publication_id:
        sub(bibl, "idno", {"type": "local", "subtype": "publication-id"}, first_meta.publication_id)
    if first_meta.input_sub_path:
        sub(bibl, "idno", {"type": "local", "subtype": "input-sub-path"}, first_meta.input_sub_path)
    if first_meta.input_filename:
        sub(bibl, "idno", {"type": "local", "subtype": "source-mets"}, first_meta.input_filename)
    if args.source_url:
        sub(bibl, "idno", {"type": "URI", "subtype": "source"}, args.source_url)

    encoding = sub(header, "encodingDesc")
    add_project_desc(encoding)
    # Counts are filled after the body is created.
    profile = sub(header, "profileDesc")
    lang_usage = sub(profile, "langUsage")
    sub(lang_usage, "language", {"ident": args.language, xml_attr("lang"): "en"}, "English")
    rev = sub(header, "revisionDesc")
    ch = sub(rev, "change", {"when": date.today().isoformat()})
    name = sub(ch, "name", None, args.encoder)
    name.tail = ": Converted BL/Living with Machines plaintext and metadata to PressMint TEI sample format."

    text_el = sub(TEI, "text")
    body = sub(text_el, "body")

    for meta, txt_path, cleaned, include, reason in issue_records:
        item_id = meta.item_id or Path(meta.plain_text_file or txt_path.name).stem.split("_")[-1]
        div_type = map_item_type_to_div_type(meta.item_type, txt_path.name)
        div = sub(body, "div", {
            "type": div_type,
            xml_attr("id"): sanitize_xml_id(f"{component_id}_{item_id}"),
            "n": item_id,
        })
        if is_meaningful_title(meta.item_title):
            sub(div, "head", None, meta.item_title.strip())
        note_bits = []
        if meta.item_type:
            note_bits.append(f"source item type: {meta.item_type}")
        if meta.ocr_quality_mean is not None:
            note_bits.append(f"OCR quality mean: {meta.ocr_quality_mean:.4f}")
        if meta.word_count is not None:
            note_bits.append(f"source word count: {meta.word_count}")
        if note_bits and args.include_item_notes:
            sub(div, "note", {"type": "source-metadata"}, "; ".join(note_bits))
        if include:
            for para in split_paragraphs(cleaned):
                sub(div, "p", None, para)
        else:
            gap = sub(div, "gap", {"reason": "ocrQuality", "quantity": str(count_words(cleaned) or meta.word_count or 0), "unit": "words"})
            sub(gap, "desc", None, reason)

    # Add tag usage counts for the data part of this component.
    counts = Counter()
    for elem in text_el.iter():
        if elem.tag.startswith("{"):
            counts[elem.tag.split("}", 1)[1]] += 1
    add_tags_decl(encoding, counts)
    return TEI


def build_root_xml(component_paths: List[Path], component_summaries: List[dict], out_dir: Path, args) -> ET.Element:
    corpus_id = args.corpus_id
    root = ET.Element(qn("teiCorpus"), {xml_attr("id"): corpus_id, xml_attr("lang"): args.language})
    header = sub(root, "teiHeader")
    file_desc = sub(header, "fileDesc")
    title = f"British historical newspaper corpus {corpus_id} [PressMint SAMPLE]"
    add_title_stmt(file_desc, title, args)
    edition_stmt = sub(file_desc, "editionStmt")
    sub(edition_stmt, "edition", None, args.edition)
    total_texts = len(component_paths)
    total_words = sum(s.get("words", 0) for s in component_summaries)
    add_extent(file_desc, total_texts, total_words)
    make_publication_stmt(file_desc, args)
    source_desc = sub(file_desc, "sourceDesc")
    bibl = sub(source_desc, "bibl")
    sub(bibl, "title", {"level": "j"}, args.newspaper_title)
    sub(bibl, "pubPlace", None, args.publication_place)
    dates = sorted([s["date"] for s in component_summaries if s.get("date")])
    if dates:
        attrs = {"from": dates[0], "to": dates[-1]} if dates[0] != dates[-1] else {"when": dates[0]}
        sub(bibl, "date", attrs, f"{dates[0]} to {dates[-1]}" if dates[0] != dates[-1] else dates[0])
    if args.source_url:
        sub(bibl, "idno", {"type": "URI", "subtype": "source"}, args.source_url)

    encoding = sub(header, "encodingDesc")
    add_project_desc(encoding)
    editorial = sub(encoding, "editorialDecl")
    sub(sub(editorial, "correction"), "p", {xml_attr("lang"): "en"}, "OCR-derived text from the British Library / Living with Machines source was not manually corrected by this conversion script.")
    sub(sub(editorial, "normalization"), "p", {xml_attr("lang"): "en"}, "Line endings and XML control characters were normalised; no spelling or substantive textual normalisation was performed.")
    sub(sub(editorial, "segmentation"), "p", {xml_attr("lang"): "en"}, "Each issue/date folder is encoded as one TEI component. Each plaintext item file is encoded as an article, advertisement or related division inside the component.")
    root_counts = Counter({"text": len(component_paths), "body": len(component_paths)})
    root_counts["div"] = sum(s.get("divs", 0) for s in component_summaries)
    root_counts["p"] = sum(s.get("paragraphs", 0) for s in component_summaries)
    root_counts["gap"] = sum(s.get("gaps", 0) for s in component_summaries)
    root_counts = Counter({k: v for k, v in root_counts.items() if v})
    add_tags_decl(encoding, root_counts)

    start_date = dates[0] if dates else None
    end_date = dates[-1] if dates else None
    add_profile_desc(header, args.language, start_date=start_date, end_date=end_date)
    rev = sub(header, "revisionDesc")
    ch = sub(rev, "change", {"when": date.today().isoformat()})
    name = sub(ch, "name", None, args.encoder)
    name.tail = ": Built PressMint-GB corpus root with XIncludes for component files."

    for rel in component_paths:
        ET.SubElement(root, xi_qn("include"), {"href": rel.as_posix()})
    return root


def write_xml(root: ET.Element, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        ET.indent(root, space="  ")  # Python 3.9+
    except Exception:
        pass
    tree = ET.ElementTree(root)
    tree.write(path, encoding="utf-8", xml_declaration=True)



def int_or_zero(value: object) -> int:
    try:
        return int(str(value).replace(',', '').strip())
    except Exception:
        return 0


def infer_issue_date_from_component(component_path: Path, root: ET.Element) -> str:
    """Infer issue date from TEI sourceDesc/header or from the PressMint component filename."""
    for elem in root.iter(qn("date")):
        when = elem.attrib.get("when")
        if when and re.fullmatch(r"\d{4}-\d{2}-\d{2}", when):
            return when
    m = re.search(r"_(\d{4}-\d{2}-\d{2})_", component_path.stem)
    if m:
        return m.group(1)
    m = re.search(r"(\d{4})", component_path.stem)
    return m.group(1) if m else ""


def component_summary_from_xml(component_path: Path, out_dir: Path) -> Optional[Tuple[Path, dict]]:
    """Read an existing component TEI file and summarise it for the corpus root."""
    try:
        root = ET.parse(component_path).getroot()
    except Exception:
        return None
    if root.tag != qn("TEI"):
        return None

    words = 0
    texts = 0
    for elem in root.iter(qn("measure")):
        if elem.attrib.get("unit") == "words" and not words:
            words = int_or_zero(elem.attrib.get("quantity", 0))
        if elem.attrib.get("unit") == "texts" and not texts:
            texts = int_or_zero(elem.attrib.get("quantity", 0))

    text_el = root.find(qn("text"))
    divs = paragraphs = gaps = 0
    if text_el is not None:
        divs = sum(1 for _ in text_el.iter(qn("div")))
        paragraphs = sum(1 for _ in text_el.iter(qn("p")))
        gaps = sum(1 for _ in text_el.iter(qn("gap")))

    rel = component_path.relative_to(out_dir)
    issue_date = infer_issue_date_from_component(component_path, root)
    return rel, {
        "date": issue_date,
        "words": words,
        "texts": texts,
        "divs": divs,
        "paragraphs": paragraphs,
        "gaps": gaps,
    }


def collect_existing_component_summaries(out_dir: Path, args) -> Tuple[List[Path], List[dict]]:
    """Collect all existing issue-level PressMint component files in the output tree.

    This makes repeated conversion runs cumulative: each run may add/replace issue files,
    then the corpus root is rebuilt from every component currently present under YYYY/.
    """
    if not out_dir.exists():
        return [], []

    root_name = f"{args.corpus_id}.xml"
    collected: List[Tuple[Path, dict]] = []
    seen = set()
    for component_path in sorted(out_dir.rglob("*.xml"), key=natural_key):
        if component_path.name == root_name:
            continue
        if "Sources" in component_path.parts:
            continue
        if not component_path.stem.startswith(f"{args.corpus_id}_"):
            continue
        # PressMint sample components are expected under year folders such as 1908/.
        if not re.fullmatch(r"\d{4}", component_path.parent.name):
            continue
        summary = component_summary_from_xml(component_path, out_dir)
        if summary is None:
            continue
        rel, data = summary
        key = rel.as_posix()
        if key in seen:
            continue
        seen.add(key)
        collected.append((rel, data))

    collected.sort(key=lambda x: (x[1].get("date") or "", x[0].as_posix()))
    return [x[0] for x in collected], [x[1] for x in collected]



def deduplicate_manifest(manifest_path: Path) -> int:
    """Keep only the last row for each source item after repeated conversion runs."""
    if not manifest_path.exists():
        return 0
    with manifest_path.open("r", encoding="utf-8", newline="") as fh:
        reader = csv.DictReader(fh, delimiter="\t")
        if not reader.fieldnames:
            return 0
        fieldnames = reader.fieldnames
        keyed_rows = {}
        order = []
        for row in reader:
            key = (
                row.get("component_id", ""),
                row.get("source_item_id", ""),
                row.get("plaintext_file", ""),
                row.get("metadata_file", ""),
            )
            if key not in keyed_rows:
                order.append(key)
            keyed_rows[key] = row
    with manifest_path.open("w", encoding="utf-8", newline="") as fh:
        writer = csv.DictWriter(fh, delimiter="\t", fieldnames=fieldnames)
        writer.writeheader()
        for key in order:
            if key in keyed_rows:
                writer.writerow(keyed_rows[key])
    return len(keyed_rows)

def count_manifest_rows(manifest_path: Path) -> int:
    if not manifest_path.exists():
        return 0
    with manifest_path.open("r", encoding="utf-8", newline="") as fh:
        return max(0, sum(1 for _ in fh) - 1)

def make_readmes(out_dir: Path, args, n_components: int, n_items: int) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    sources_bullet = "- `Sources/`: conversion manifest used for traceability."
    if args.write_combined_plaintext:
        sources_bullet = "- `Sources/`: conversion manifest plus optional concatenated plaintext trace files."
    (out_dir / "README.md").write_text(f"""# Samples of the PressMint-GB corpus

This directory contains a PressMint TEI sample for Great Britain, generated from the British Library / Living with Machines `Widnes Examiner` plaintext and metadata files.

## Source

- Newspaper: {args.newspaper_title}
- Place of publication: {args.publication_place}
- Source page or dataset URL: {args.source_url or 'not supplied'}
- Corpus ID: {args.corpus_id}
- Components generated: {n_components}
- Source items processed: {n_items}

## Generated structure

- `{args.corpus_id}.xml`: corpus root file with XInclude links to issue components.
- `YYYY/`: issue-level TEI component files.
{sources_bullet}

## Validation

From the PressMint repository root, run:

```bash
make validate-TEI-GB
```

Review the `Sources/metadata/pressmint_gb_manifest.tsv` file before submission, especially skipped OCR fragments and licensing notes.
""", encoding="utf-8")

    sources_dir = out_dir / "Sources"
    sources_dir.mkdir(parents=True, exist_ok=True)
    combined_note = ""
    if args.write_combined_plaintext:
        combined_note = "\n- `combined_plaintext/`: optional one-file-per-issue plaintext trace files generated only when `--write-combined-plaintext` is used."
    (sources_dir / "README.md").write_text(f"""# Sources for PressMint-GB

This folder contains lightweight traceability files generated during conversion from British Library / Living with Machines source material into PressMint TEI.

- `metadata/pressmint_gb_manifest.tsv`: row-level mapping between source plaintext files, source metadata XML files and generated TEI divisions.{combined_note}

Very short OCR fragments are not silently discarded. By default, they are represented in the TEI as `<gap reason=\"ocrQuality\">` and recorded in the manifest. Adjust `--min-chars` or use `--keep-short` if you want different behaviour.
""", encoding="utf-8")

def process_issue_task(task: Tuple[str, str, str, str, object]) -> Optional[IssueResult]:
    """Convert one issue/date folder into a PressMint TEI component.

    This function is intentionally top-level so it can be used by
    ProcessPoolExecutor on Linux, macOS and Windows. It writes only the
    issue-specific TEI component and, optionally, the lightweight traceability
    plaintext file. The caller writes the shared manifest and rebuilds the
    corpus root to avoid concurrent writes to shared files.
    """
    issue_name, pt_issue_s, md_issue_s, out_dir_s, args = task
    pt_issue = Path(pt_issue_s)
    md_issue = Path(md_issue_s)
    out_dir = Path(out_dir_s)

    metadata_files = sorted(md_issue.glob("*.xml"), key=natural_key)
    metas: Dict[str, ItemMeta] = {}
    for mp in metadata_files:
        meta = parse_lwm_metadata(mp)
        key = meta.plain_text_file or re.sub(r"_metadata\.xml$", ".txt", mp.name)
        meta.source_file = key
        metas[key] = meta

    text_files = sorted(pt_issue.glob("*.txt"), key=natural_key)
    if not text_files:
        return None

    # Determine issue date from metadata first, then filename pattern, then folder name.
    issue_date = ""
    for m in metas.values():
        if m.issue_date:
            issue_date = m.issue_date
            break
    if not issue_date:
        m = re.search(r"_(\d{8})_", text_files[0].name)
        if m:
            raw = m.group(1)
            issue_date = f"{raw[:4]}-{raw[4:6]}-{raw[6:8]}"
        else:
            issue_date = issue_name

    year = issue_date[:4] if re.match(r"\d{4}", issue_date) else args.year
    slug = normalize_space_for_filename(args.newspaper_slug or args.newspaper_title)
    component_id = sanitize_xml_id(f"{args.corpus_id}_{issue_date}_{slug}")

    issue_records: List[Tuple[ItemMeta, Path, str, bool, str]] = []
    manifest_rows: List[dict] = []
    combined_chunks: List[str] = []
    issue_words = 0
    issue_texts = 0
    issue_paragraphs = 0
    issue_gaps = 0

    for txt_path in text_files:
        meta = metas.get(txt_path.name)
        if meta is None:
            # Try matching by stem.
            md_name = f"{txt_path.stem}_metadata.xml"
            md_path = md_issue / md_name
            meta = parse_lwm_metadata(md_path) if md_path.exists() else ItemMeta(
                metadata_file="", plain_text_file=txt_path.name, item_id=txt_path.stem.split("_")[-1]
            )
        raw_text = read_text_file(txt_path)
        cleaned = clean_ocr_text(raw_text, join_lines=not args.keep_linebreaks)
        chars = len(cleaned)
        words = count_words(cleaned)
        include = True
        reason = "included"
        if not args.keep_short and chars < args.min_chars:
            include = False
            reason = f"skipped/gap: fewer than {args.min_chars} non-control characters after cleanup"
        if include:
            issue_words += words
            issue_texts += 1
            issue_paragraphs += len(split_paragraphs(cleaned))
        else:
            issue_gaps += 1
        issue_records.append((meta, txt_path, cleaned, include, reason))
        div_type = map_item_type_to_div_type(meta.item_type, txt_path.name)
        manifest_rows.append({
            "component_id": component_id,
            "issue_folder": issue_name,
            "issue_date": issue_date,
            "source_item_id": meta.item_id or txt_path.stem.split("_")[-1],
            "div_type": div_type,
            "included": str(include).lower(),
            "reason": reason,
            "plaintext_file": txt_path.name,
            "metadata_file": meta.metadata_file,
            "chars": chars,
            "words": words,
            "source_word_count": meta.word_count if meta.word_count is not None else "",
            "ocr_quality_mean": f"{meta.ocr_quality_mean:.4f}" if meta.ocr_quality_mean is not None else "",
            "ocr_quality_sd": f"{meta.ocr_quality_sd:.4f}" if meta.ocr_quality_sd is not None else "",
            "item_title": meta.item_title,
            "item_type": meta.item_type,
            "publication_id": meta.publication_id,
            "publication_title": meta.newspaper_title,
            "publication_location": meta.publication_location,
            "input_sub_path": meta.input_sub_path,
            "input_filename": meta.input_filename,
        })
        if args.write_combined_plaintext:
            combined_chunks.append(f"===== {txt_path.name} | included={str(include).lower()} | {reason} =====\n{cleaned}\n")

    comp_xml = build_component_xml(component_id, issue_date, issue_records, issue_words, issue_texts, args)
    comp_path = out_dir / year / f"{component_id}.xml"
    write_xml(comp_xml, comp_path)

    if args.write_combined_plaintext:
        combined_dir = out_dir / "Sources" / "combined_plaintext"
        comb_path = combined_dir / year / f"{component_id}.txt"
        comb_path.parent.mkdir(parents=True, exist_ok=True)
        comb_path.write_text("\n".join(combined_chunks), encoding="utf-8")

    return IssueResult(
        issue_name=issue_name,
        issue_date=issue_date,
        component_rel_path=comp_path.relative_to(out_dir),
        component_summary={
            "date": issue_date,
            "words": issue_words,
            "texts": issue_texts,
            "divs": len(issue_records),
            "paragraphs": issue_paragraphs,
            "gaps": issue_gaps,
        },
        manifest_rows=manifest_rows,
        n_items=len(manifest_rows),
    )


def progress_completed_futures(futures: Dict[object, str], description: str, args, unit: str = "issue") -> Iterator[object]:
    """Yield completed futures with tqdm/plain progress reporting."""
    progress_mode = getattr(args, "progress", "auto")
    if progress_mode == "none":
        yield from as_completed(futures)
        return

    total = len(futures)
    use_tqdm = tqdm is not None and (progress_mode == "tqdm" or (progress_mode == "auto" and sys.stderr.isatty()))
    if use_tqdm:
        with tqdm(total=total, desc=description, unit=unit) as bar:
            for fut in as_completed(futures):
                bar.update(1)
                yield fut
        return

    for idx, fut in enumerate(as_completed(futures), 1):
        print(f"{description}: {idx}/{total} {unit}s - {futures[fut]}")
        yield fut


def process_issues(common_issue_names: Sequence[str], pt_issues: Dict[str, Path], md_issues: Dict[str, Path], out_dir: Path, args, run_label: str = "") -> List[IssueResult]:
    desc = f"{run_label} issues" if run_label else "Issues"
    tasks = [(name, str(pt_issues[name]), str(md_issues[name]), str(out_dir), copy.copy(args)) for name in common_issue_names]
    workers = max(1, int(getattr(args, "workers", 1) or 1))
    results: List[IssueResult] = []

    if workers == 1 or len(tasks) <= 1:
        for name in progress_iter(list(common_issue_names), desc, args, unit="issue"):
            result = process_issue_task((name, str(pt_issues[name]), str(md_issues[name]), str(out_dir), copy.copy(args)))
            if result is not None:
                results.append(result)
        return sorted(results, key=lambda r: (r.issue_date or "", r.component_rel_path.as_posix()))

    max_workers = min(workers, len(tasks))
    print(f"{desc}: using {max_workers} worker process(es)")
    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(process_issue_task, task): task[0] for task in tasks}
        for fut in progress_completed_futures(futures, desc, args, unit="issue"):
            result = fut.result()
            if result is not None:
                results.append(result)
    return sorted(results, key=lambda r: (r.issue_date or "", r.component_rel_path.as_posix()))


def convert(args, run_label: str = "") -> None:
    out_dir = Path(args.output)
    work_dir = Path(args.work_dir) if args.work_dir else Path(tempfile.mkdtemp(prefix="pressmint_widnes_"))
    work_dir.mkdir(parents=True, exist_ok=True)

    extracted_root = work_dir / "extracted"
    if extracted_root.exists():
        shutil.rmtree(extracted_root)
    extracted_root.mkdir(parents=True, exist_ok=True)

    if args.plaintext_dir and args.metadata_dir:
        plaintext_dir = Path(args.plaintext_dir)
        metadata_dir = Path(args.metadata_dir)
    elif args.plaintext_zip and args.metadata_zip:
        plaintext_zip = Path(args.plaintext_zip)
        metadata_zip = Path(args.metadata_zip)
        safe_extract_zip(plaintext_zip, extracted_root / "plaintext")
        safe_extract_zip(metadata_zip, extracted_root / "metadata")
        plaintext_dir = extracted_root / "plaintext"
        metadata_dir = extracted_root / "metadata"
    elif args.input:
        input_value = args.input
        if is_url(input_value):
            zip_path = download_url(input_value, work_dir / "downloads", match=args.download_match)
            args.source_url = args.source_url or input_value
            safe_extract_zip(zip_path, extracted_root / "input")
            plaintext_dir, metadata_dir = detect_dirs(extracted_root / "input")
        else:
            input_path = Path(input_value)
            if input_path.is_file() and input_path.suffix.lower() == ".zip":
                safe_extract_zip(input_path, extracted_root / "input")
                plaintext_dir, metadata_dir = detect_dirs(extracted_root / "input")
            elif input_path.is_dir():
                plaintext_dir, metadata_dir = detect_dirs(input_path)
            else:
                raise RuntimeError(f"Input not found or unsupported: {input_path}")
    else:
        raise RuntimeError("Provide --input, or --plaintext-zip plus --metadata-zip, or explicit --plaintext-dir and --metadata-dir.")

    pt_issues = child_issue_dirs(plaintext_dir, "txt")
    md_issues = child_issue_dirs(metadata_dir, "xml")
    common_issue_names = sorted(set(pt_issues).intersection(md_issues), key=natural_key)
    if not common_issue_names:
        raise RuntimeError(f"No matching issue/date subfolders found between {plaintext_dir} and {metadata_dir}")

    manifest_dir = out_dir / "Sources" / "metadata"
    manifest_dir.mkdir(parents=True, exist_ok=True)
    if args.write_combined_plaintext:
        (out_dir / "Sources" / "combined_plaintext").mkdir(parents=True, exist_ok=True)
    manifest_path = manifest_dir / "pressmint_gb_manifest.tsv"

    issue_results = process_issues(common_issue_names, pt_issues, md_issues, out_dir, args, run_label=run_label)
    component_rel_paths = [r.component_rel_path for r in issue_results]
    component_summaries = [r.component_summary for r in issue_results]
    n_items_total = sum(r.n_items for r in issue_results)

    manifest_exists = manifest_path.exists()
    manifest_mode = "a" if manifest_exists and not args.overwrite_manifest else "w"
    with manifest_path.open(manifest_mode, encoding="utf-8", newline="") as mf:
        writer = csv.DictWriter(mf, delimiter="\t", fieldnames=MANIFEST_FIELDNAMES)
        if manifest_mode == "w":
            writer.writeheader()
        for result in issue_results:
            for row in result.manifest_rows:
                writer.writerow(row)

    # Rebuild the corpus root from all component XML files currently present, not only
    # the files produced by this run. This prevents PressMint-GB.xml from losing
    # earlier issue includes when processing another ZIP/link later.
    all_component_rel_paths, all_component_summaries = collect_existing_component_summaries(out_dir, args)
    root_xml = build_root_xml(all_component_rel_paths, all_component_summaries, out_dir, args)
    write_xml(root_xml, out_dir / f"{args.corpus_id}.xml")

    deduplicate_manifest(manifest_path)
    total_manifest_rows = count_manifest_rows(manifest_path)
    make_readmes(out_dir, args, n_components=len(all_component_rel_paths), n_items=total_manifest_rows)

    prefix = f"{run_label}: " if run_label else ""
    print(f"{prefix}Done. Wrote {len(component_rel_paths)} new/updated component file(s) and {n_items_total} source item rows in this run.")
    print(f"{prefix}Corpus root now includes {len(all_component_rel_paths)} component file(s).")
    print(f"{prefix}Output: {out_dir}")
    print(f"{prefix}Manifest: {manifest_path}")
    if args.write_combined_plaintext:
        print(f"{prefix}Combined plaintext trace files: {out_dir / 'Sources' / 'combined_plaintext'}")
    print(f"{prefix}Next: run `make validate-TEI-GB` from the PressMint repository root.")

def parse_args(argv: Optional[List[str]] = None):
    parser = argparse.ArgumentParser(description="Convert Widnes Examiner BL/Living with Machines plaintext+metadata to PressMint TEI sample structure.")
    source = parser.add_argument_group("input")
    source.add_argument("--input", "-i", help="Single high-level ZIP, extracted high-level directory, or URL to a direct ZIP/page containing the ZIP.")
    source.add_argument("--inputs", nargs="+", help="Batch mode: multiple high-level ZIPs, extracted directories, direct ZIP URLs, or HTML page URLs.")
    source.add_argument("--inputs-file", help="Batch mode: UTF-8 text file containing one ZIP/directory/URL per line. Optional per-line match can be supplied after a tab or as ' match=TEXT'.")
    source.add_argument("--num-years", type=int, default=None, help="Process only the first N source-year entries from --inputs/--inputs-file. Default: all entries.")
    source.add_argument("--download-match", default="", help="String used to choose the right ZIP link when an input is an HTML page URL. In --inputs-file, this can also be supplied per line.")
    source.add_argument("--plaintext-zip", help="Plaintext ZIP for testing or partial conversion.")
    source.add_argument("--metadata-zip", help="Metadata ZIP for testing or partial conversion.")
    source.add_argument("--plaintext-dir", help="Explicit extracted plaintext directory.")
    source.add_argument("--metadata-dir", help="Explicit extracted metadata directory.")

    out = parser.add_argument_group("output and metadata")
    out.add_argument("--output", "-o", default="Samples/PressMint-GB", help="Output directory for PressMint-GB sample tree.")
    out.add_argument("--corpus-id", default="PressMint-GB")
    out.add_argument("--country", default="GB")
    out.add_argument("--language", default="en")
    out.add_argument("--year", default="1908", help="Fallback year if dates cannot be inferred.")
    out.add_argument("--newspaper-title", default="Widnes Examiner")
    out.add_argument("--newspaper-slug", default="WidnesExaminer")
    out.add_argument("--publication-place", default="Widnes, Cheshire, England")
    out.add_argument("--source-url", default="https://bl.iro.bl.uk/concern/datasets/96c2c510-5b7b-4bea-97af-ca2c6bee26be", help="Dataset/source URL to encode in sourceDesc.")
    out.add_argument("--encoder", default="PressMint-GB conversion script")
    out.add_argument("--funder", default="The CLARIN research infrastructure")
    out.add_argument("--edition", default="1.0")
    out.add_argument("--publisher", default="CLARIN research infrastructure")
    out.add_argument("--handle", default="", help="Optional persistent identifier/handle for the released corpus.")
    out.add_argument("--availability-status", choices=["free", "unknown", "restricted"], default="unknown")
    out.add_argument("--licence-url", default="", help="Licence URL, e.g. https://creativecommons.org/licenses/by/4.0/ after rights have been confirmed.")
    out.add_argument("--availability-note", default="Rights and redistribution status should be confirmed before public release through PressMint.")

    quality = parser.add_argument_group("OCR handling")
    quality.add_argument("--min-chars", type=int, default=20, help="Minimum cleaned character count required to encode a text item as paragraphs.")
    quality.add_argument("--keep-short", action="store_true", help="Encode even very short OCR fragments as paragraphs instead of <gap>.")
    quality.add_argument("--keep-linebreaks", action="store_true", help="Preserve OCR line breaks inside paragraph blocks rather than joining lines.")
    quality.add_argument("--include-item-notes", action="store_true", help="Add source metadata notes inside each article/advert div.")
    quality.add_argument("--workers", type=int, default=1, help="Number of worker processes for issue/date-folder conversion within each source. Default: 1.")
    quality.add_argument("--write-combined-plaintext", action="store_true", help="Write optional Sources/combined_plaintext trace files. Disabled by default to keep generated output light.")
    quality.add_argument("--work-dir", default="", help="Working directory for extraction/downloads. Defaults to a temporary directory. In batch mode, one subdirectory is created per input.")
    quality.add_argument("--overwrite-manifest", action="store_true", help="Overwrite Sources/metadata/pressmint_gb_manifest.tsv instead of appending to it. Use only when regenerating the whole output tree.")
    quality.add_argument("--progress", choices=["auto", "plain", "tqdm", "none"], default="auto", help="Progress display mode. 'auto' uses tqdm in an interactive terminal when available, otherwise plain logging.")
    quality.add_argument("--stop-on-error", action="store_true", help="In batch mode, stop at the first failed input instead of continuing and reporting failures at the end.")
    args = parser.parse_args(argv)
    if args.num_years is not None and args.num_years < 1:
        parser.error("--num-years must be a positive integer")
    if args.workers < 1:
        parser.error("--workers must be a positive integer")
    return args


def batch_convert(args, specs: List[SourceSpec]) -> int:
    if not specs:
        raise RuntimeError("No batch inputs were provided.")

    base_work_dir = Path(args.work_dir) if args.work_dir else Path(tempfile.mkdtemp(prefix="pressmint_widnes_batch_"))
    base_work_dir.mkdir(parents=True, exist_ok=True)

    total_specs = getattr(args, "total_source_specs", len(specs))
    if getattr(args, "num_years", None) is not None:
        print(f"Batch mode: {len(specs)} of {total_specs} source-year input(s) selected by --num-years {args.num_years}.")
    else:
        print(f"Batch mode: {len(specs)} input(s).")
    print(f"Output directory: {args.output}")
    print(f"Batch work directory: {base_work_dir}")

    successes: List[str] = []
    failures: List[Tuple[str, str]] = []

    for idx, spec in enumerate(specs, 1):
        label = f"[{idx}/{len(specs)}]"
        print(f"\n{label} Processing {display_source(spec.value)}")
        child_args = copy.copy(args)
        child_args.input = spec.value
        child_args.inputs = None
        child_args.inputs_file = None
        child_args.plaintext_zip = None
        child_args.metadata_zip = None
        child_args.plaintext_dir = None
        child_args.metadata_dir = None
        child_args.download_match = spec.download_match or args.download_match or ""
        child_args.work_dir = str(base_work_dir / f"{idx:03d}_{source_label(spec.value)}")
        # In batch mode, only the first run should be allowed to intentionally overwrite
        # the manifest. Later runs append and the manifest is deduplicated after each run.
        if idx > 1:
            child_args.overwrite_manifest = False

        try:
            convert(child_args, run_label=label)
            successes.append(spec.value)
        except Exception as exc:
            message = str(exc)
            failures.append((spec.value, message))
            print(f"{label} ERROR: {message}", file=sys.stderr)
            if args.stop_on_error:
                break

    print("\nBatch summary")
    print(f"  Successful: {len(successes)}")
    print(f"  Failed: {len(failures)}")
    if failures:
        for value, message in failures:
            print(f"  - {display_source(value)} :: {message}")
        return 1
    return 0


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    try:
        specs = collect_source_specs(args)
        if is_batch_request(args):
            return batch_convert(args, specs)
        if specs and not (args.plaintext_zip or args.metadata_zip or args.plaintext_dir or args.metadata_dir):
            # Single high-level --input path/URL. Keep existing single-input behaviour.
            args.input = specs[0].value
            args.download_match = specs[0].download_match or args.download_match or ""
        convert(args)
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
