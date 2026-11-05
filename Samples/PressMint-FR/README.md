# Samples of the PressMint-FR corpus

## Data source

The source of the PressMint-FR corpus is the digitised French daily *Le Temps* (Paris), held by the Bibliothèque nationale de France (BnF) and available through [Gallica](https://gallica.bnf.fr/).

The sample is the issue of 1920-01-01 (no. 21340), [ark:/12148/bpt6k243877q](https://gallica.bnf.fr/ark:/12148/bpt6k243877q).

### Details of the source:

* __Source__: BnF / Gallica, *Le Temps* (journal ARK `ark:/12148/cb34431794k`, set ARK `ark:/12148/bc6p0j3t4`)

* __Availability__: Publicly available through Gallica. Terms of reuse are subject to BnF/Gallica licensing; the licence for the corpus is still to be confirmed (the period 1900-1942 is of uncertain status, CC BY-NC is suggested).

* __Content__: Newspaper issues of *Le Temps*. The sample contains one issue (1920-01-01).

* __Size__: Sample: 1 issue, 4 pages, 781 paragraphs, 31,721 words. Size of the whole corpus: to be decided.

* __Structure__: METS (issue metadata and physical page order) with one ALTO file per page (text blocks, lines, words, coordinates and OCR confidence). The source has no logical structure (articles, sections).

* __Correction__: Uncorrected BnF OCR. Only whitespace is normalised and line-end hyphens are joined.

* __Linguistic annotation__: None in the source. Annotation of the corpus is still to be decided.

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

* __Format__: BnF METS/ALTO (`alto_prod` namespace). The original files of the sample are in `Sources/0243877/` (`manifest.xml` and `ocr/X0000001.xml` to `X0000004.xml`).

* __Facsimile__: Page images are served by Gallica through IIIF. The TEI sample links to them and encodes the layout (page body, text blocks, lines, tables and illustrations) as facsimile zones.

## Conversion plan

For the PressMint-FR corpus we plan to:
* Convert the BnF METS/ALTO data to the PressMint TEI scheme
* Convert/supplement metadata to the common scheme
* Encode the text in reading order
* Decide how to add linguistic annotation (UD) and named entities
* Process the whole corpus once the sample is accepted
