# Sources for PressMint-GB

This folder contains lightweight traceability files generated during conversion from British Library / Living with Machines source material into PressMint TEI.

- `metadata/pressmint_gb_manifest.tsv`: row-level mapping between source plaintext files, source metadata XML files and generated TEI divisions.

Very short OCR fragments are not silently discarded. By default, they are represented in the TEI as `<gap reason="ocrQuality">` and recorded in the manifest. Adjust `--min-chars` or use `--keep-short` if you want different behaviour.
