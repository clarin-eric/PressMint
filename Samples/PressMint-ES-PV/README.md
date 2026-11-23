# Samples of the PressMint-ES-PV corpus

## Data source

The source of the PressMint-ES-PV corpus will be scanned issues of Basque-language newspapers,
starting with the weekly *Argia* (Donostia, 1921–1936).

### Details of the source:

* __Source__: PDF scans (300 dpi, image only, no text layer), e.g. `Sources/PDF/arg_1921_05_01.pdf`.

* __Availability__: TODO (holding institution / URL of the digitised collection and its licence).

* __Content__: Weekly Basque-language newspaper *Argia*; sample: year I, no. 2, 1 May 1921, 4 pages.

* __Size__: Sample: 1 issue, 4 pages, ca. 420 paragraphs, ca. 6,300 words.

* __Structure__: Pages and OCR-detected paragraphs, each linked to its zone on the page image.
  Masthead encoded as a banner in `<front>`. Articles are not yet delimited.

* __Correction__: None (raw Tesseract 5.3.4 OCR, `eus+spa` tessdata_best models), apart from the masthead.

* __Linguistic annotation__: None yet.

* __Metadata__:

    The texts in the corpus have the following metadata:

    - Document ID
    - Newspaper title
    - Place of publication
    - Date of publication
    - Volume (year) and issue number

* __Format__: PDF (source), PressMint TEI (sample).

* __Facsimile__: Page images from the source PDF, referenced per page; paragraph bounding boxes as `<zone>`s.

## Conversion plan

For the PressMint-ES-PV corpus we plan to:

* improve OCR (a model adapted to Arana's orthography: ŕ, ĺ, etc.) or post-correct it;
* segment pages into articles (`<div type="article">` with `<head>` and `<byline>`) and advertisements (`<back>`);
* add linguistic annotation for Basque.
