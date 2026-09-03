# Samples of the PressMint-HU corpus

## Data source

The source of the PressMint-HU corpus will be the Hungaricana digital library database, focusing on historical Hungarian periodicals from the late 19th and early 20th centuries. For this pilot, we have processed three consecutive daily issues of the *Pesti Hírlap* from January 1884.

### Details of the source:

* __Source__: Digitized page-images compiled as monthly aggregate PDF files from Hungaricana.

* __Availability__: Sourced and distributed under secured project rights clearance.

* __Content__: *Pesti Hírlap*, a highly influential daily political newspaper published in Budapest, Hungary.

* __Size__: 3 daily issues from January 1884 (45 total pages, containing 134 paragraphs and 18,924 words).

* __Structure__: Structured into daily TEI XML component files containing text body segments nested inside paragraphs (`<p>`).

* __Correction__: 

  - Text was extracted using **Google Cloud Vision API** (`DOCUMENT_TEXT_DETECTION` model) to accurately parse the complex multi-column print layout into reading order.
  - No manual correction was performed (raw OCR baseline).
  - Post-OCR normalizations (whitespace collapsing, U+00AD soft hyphen removal, U+00A0 non-breaking space replacement) and end-of-line de-hyphenation were handled systematically during TEI compilation via a custom Python packaging script.
  - Bounding-box overlap duplication errors introduced by the Vision API were resolved programmatically during TEI packaging.

* __Linguistic annotation__: None.

* __Metadata__:

    The texts in the corpus have the following metadata:

    - Document ID (e.g. `PressMint-HU_1884-01-01-PestiHirlap`)
    - Source (Original digitised document URL at Hungaricana)
    - Newspaper Title
    - Date of publication (ISO 8601: YYYY-MM-DD)
    - Publisher (Budapest)
    - Extent measures (texts, paragraphs, and words)
    - Language (hu, en)

* __Format__: TEI XML (with XInclude), raw plain text (.txt), metadata tables (.tsv), and vertical format (.vert) for corpus engine indexing.

* __Facsimile__: High-quality page PDFs sourced from Hungaricana.

## Conversion plan

For the PressMint-HU corpus we plan to:

1. Segment monthly aggregated source PDFs into separate daily issue PDFs.
2. Run high-accuracy OCR via the Google Cloud Vision API to handle multi-column layouts without manual transcriptions.
3. Run python-based cleaning and normalization scripts (`package_tei_xml.py`) to structure the raw OCR into TEI XML components with robust metadata.
4. Utilize the central PressMint build pipelines to automatically validate and export derived formats (.txt, .tsv, .vert).
