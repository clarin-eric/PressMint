# Samples of the PressMint-FR corpus

## Data source

The source of the PressMint-FR corpus is the digitised French daily *Le Temps* (Paris), held by the Bibliothèque nationale de France (BnF) and available through [Gallica](https://gallica.bnf.fr/).

The sample consists of two issues:

* 1920-01-01 (no. 21340), [ark:/12148/bpt6k243877q](https://gallica.bnf.fr/ark:/12148/bpt6k243877q)
* 1920-01-14 (no. 21352), [ark:/12148/bpt6k243890r](https://gallica.bnf.fr/ark:/12148/bpt6k243890r)

### Details of the source:

* __Source__: BnF / Gallica, *Le Temps* (journal ARK `ark:/12148/cb34431794k`, set ARK `ark:/12148/bc6p0j3t4`)

* __Delivery__: The BnF METS/ALTO packages of the whole corpus were obtained from a file share of La Rochelle Université (`ao.univ-lr.fr`, folder `Mill-Ehnas-tout-LeTemps/2026-01-17`). The delivery has one zip per issue.

* __Availability__: Publicly available through Gallica. Terms of reuse are subject to BnF/Gallica licensing; the licence for the corpus is still to be confirmed (the period 1900-1942 is of uncertain status, CC BY-NC is suggested).

* __Content__: Newspaper issues of *Le Temps*. The sample contains two issues (1920-01-01 and 1920-01-14).

* __Size__: Sample: 2 issues, 8 pages, 1,649 paragraphs, 59,963 words. Whole corpus (counted from the delivery, not yet converted): 15,819 issues from 1900-01-01 to 1942-11-17, 77,009 pages and about 603 million words (ALTO word strings; a word split at a line end counts twice). Issues per year: 345 to 462 in 1900-1940, 33 in 1941, 272 in 1942. Statistics per year: `viewer/corpus-stats.html` of the converter.

* __Known issues in the delivery__:

    - 1,560 issues (9.9%) have the placeholder date `1861-1942` in the METS. Their issue number is in the title, and the date is estimated from the issue numbers of the dated issues around it (marked `cert="medium"` on `date`). 27 of them cannot be dated this way.
    - 453 issues (2.9%) have a manifest but no OCR files and cannot be converted.
    - 78 issues cover two days (e.g. `1928/07/15-1928/07/16`); the first day is used as the date.
    - OCR quality: mean word confidence 0.825; 15.8% of the words are below 0.5. It is best in 1915-1917 (about 10% of words below 0.5) and worst in 1935-1937 (about 25%).

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
