# Samples of the PressMint-FR corpus

## Data source

The source of the PressMint-FR corpus is the digitised French daily *Le Temps* (Paris), held by the Bibliothèque nationale de France (BnF) and available through [Gallica](https://gallica.bnf.fr/).

The sample consists of two issues:

* 1920-01-01 (no. 21340), [ark:/12148/bpt6k243877q](https://gallica.bnf.fr/ark:/12148/bpt6k243877q)
* 1920-01-14 (no. 21352), [ark:/12148/bpt6k243890r](https://gallica.bnf.fr/ark:/12148/bpt6k243890r)

### Details of the source:

* __Source__: BnF / Gallica, *Le Temps* (journal ARK `ark:/12148/cb34431794k`, set ARK `ark:/12148/bc6p0j3t4`)

* __Availability__: Publicly available through Gallica. Terms of reuse are subject to BnF/Gallica licensing; the licence for the corpus is still to be confirmed (the period 1900-1942 is of uncertain status, CC BY-NC is suggested).

* __Content__: Newspaper issues of *Le Temps*. The sample contains two issues (1920-01-01 and 1920-01-14).

* __Size__: Sample: 2 issues, 8 pages, 1,649 paragraphs, 59,963 words. Size of the whole corpus: to be decided.

* __Structure__: METS (issue metadata and physical page order) with one ALTO file per page (text blocks, lines, words, coordinates and OCR confidence). The source has no logical structure (articles, sections).

* __Correction__: Uncorrected BnF OCR. Only whitespace is normalised and line-end hyphens are joined.

* __Linguistic annotation__: None in the source. The TEI.ana sample (`PressMint-FR.ana.xml` and `1920/*.ana.xml`) is annotated automatically on the uncorrected OCR text:

    - sentences, tokens, lemmas, UD part-of-speech tags and morphological features: [spaCy](https://spacy.io/models/fr) `fr_core_news_md`
    - named entities: [historical-ner-baseline](https://huggingface.co/emanuelaboros/historical-ner-baseline) (BERT fine-tuned on HIPE-2022). Its labels are mapped to the PressMint categories: `pers` to PER, `loc` to LOC, `org` to ORG and `prod` to MISC. Entities labelled `time` or `scope` are not marked.

    The OCR is not corrected, so the annotation is unreliable where the OCR is poor (e.g. mastheads and advertisements). The annotation was produced with `src/annotate_ana.py` of the converter. The sample has 2 issues, 62,818 words (plus 11,838 punctuation tokens), 6,682 sentences and 3,652 named entities.

* __Metadata__:

    The texts in the corpus have the following metadata:

    - date of the issue
    - periodical title
    - issue number
    - publisher and place of publication
    - language
    - issue, journal and set ARK identifiers
    - BnF production and version identifiers
    - links to the page images

* __Format__: BnF METS/ALTO (`alto_prod` namespace). The original files of the sample are in `Sources/0243877/` and `Sources/0243890/` (each with `manifest.xml` and `ocr/X0000001.xml` to `X0000004.xml`).

* __Facsimile__: Page images are served by Gallica through IIIF. The TEI sample links to them and encodes the layout (page body, text blocks, lines, tables and illustrations) as facsimile zones.

## Conversion plan

For the PressMint-FR corpus we plan to:
* Convert the BnF METS/ALTO data to the PressMint TEI scheme
* Convert/supplement metadata to the common scheme
* Encode the text in reading order
* Evaluate the linguistic annotation and named entities on a manually checked part of the sample
* Process the whole corpus once the sample is accepted
