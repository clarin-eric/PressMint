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

## Statistics of the whole corpus

Counted from the BnF METS/ALTO delivery (15,819 issues); the corpus is not yet converted. Words are ALTO word strings (a word split at a line end counts twice). OCR confidence is the ALTO word confidence (`WC`, 0 to 1). *Date estimated*: the METS date is a placeholder and the date was estimated from the issue number (see Known issues). Issues with a two-day date are counted under the first day. The same table, with charts, is in `viewer/corpus-stats.html` of the converter.

| Year | Issues | Date estimated | No OCR | Pages | Words (millions) | Mean OCR confidence | Words below 0.5 |
|---|---:|---:|---:|---:|---:|---:|---:|
| 1900 | 373 | 6 | 0 | 1,473 | 12.76 | 0.874 | 11.5% |
| 1901 | 370 | 5 | 1 | 1,472 | 12.63 | 0.872 | 11.8% |
| 1902 | 371 | 4 | 0 | 1,468 | 12.59 | 0.859 | 13.2% |
| 1903 | 366 | 16 | 0 | 1,456 | 12.56 | 0.868 | 12.1% |
| 1904 | 374 | 3 | 0 | 1,474 | 12.69 | 0.861 | 13.0% |
| 1905 | 370 | 6 | 1 | 1,462 | 12.64 | 0.856 | 13.4% |
| 1906 | 369 | 11 | 0 | 1,462 | 12.72 | 0.833 | 15.7% |
| 1907 | 377 | 2 | 0 | 1,480 | 12.83 | 0.843 | 14.8% |
| 1908 | 371 | 2 | 2 | 1,455 | 12.82 | 0.823 | 16.8% |
| 1909 | 373 | 0 | 1 | 1,464 | 12.77 | 0.838 | 15.3% |
| 1910 | 372 | 0 | 3 | 1,470 | 12.72 | 0.832 | 15.9% |
| 1911 | 368 | 0 | 0 | 1,982 | 16.11 | 0.818 | 17.2% |
| 1912 | 369 | 0 | 10 | 2,228 | 17.11 | 0.845 | 14.5% |
| 1913 | 365 | 0 | 5 | 2,186 | 17.27 | 0.829 | 16.2% |
| 1914 | 373 | 0 | 0 | 1,953 | 14.95 | 0.835 | 15.5% |
| 1915 | 365 | 0 | 0 | 1,511 | 11.58 | 0.889 | 9.9% |
| 1916 | 370 | 0 | 1 | 1,517 | 11.26 | 0.876 | 11.2% |
| 1917 | 368 | 0 | 1 | 1,374 | 10.22 | 0.877 | 11.0% |
| 1918 | 368 | 0 | 1 | 1,314 | 9.67 | 0.808 | 17.9% |
| 1919 | 366 | 0 | 1 | 1,610 | 11.73 | 0.786 | 20.2% |
| 1920 | 364 | 1 | 0 | 1,600 | 11.80 | 0.802 | 18.6% |
| 1921 | 362 | 0 | 1 | 1,634 | 12.62 | 0.859 | 12.9% |
| 1922 | 365 | 0 | 1 | 1,774 | 13.90 | 0.834 | 15.5% |
| 1923 | 364 | 0 | 0 | 1,900 | 14.99 | 0.788 | 20.2% |
| 1924 | 370 | 0 | 3 | 1,966 | 15.14 | 0.782 | 20.8% |
| 1925 | 389 | 0 | 8 | 1,984 | 15.25 | 0.773 | 21.7% |
| 1926 | 386 | 0 | 0 | 2,054 | 16.13 | 0.784 | 20.6% |
| 1927 | 404 | 0 | 31 | 1,966 | 15.57 | 0.781 | 21.0% |
| 1928 | 417 | 0 | 0 | 2,296 | 18.10 | 0.809 | 18.1% |
| 1929 | 412 | 0 | 60 | 2,130 | 16.49 | 0.783 | 20.7% |
| 1930 | 445 | 0 | 3 | 2,588 | 20.18 | 0.792 | 19.8% |
| 1931 | 462 | 0 | 0 | 2,540 | 19.82 | 0.784 | 20.6% |
| 1932 | 417 | 0 | 21 | 2,416 | 18.48 | 0.792 | 19.8% |
| 1933 | 412 | 0 | 34 | 2,430 | 18.55 | 0.777 | 21.3% |
| 1934 | 358 | 0 | 0 | 2,634 | 20.25 | 0.789 | 20.1% |
| 1935 | 362 | 191 | 2 | 2,576 | 19.76 | 0.822 | 12.7% |
| 1936 | 363 | 0 | 59 | 2,182 | 16.42 | 0.775 | 21.5% |
| 1937 | 363 | 8 | 201 | 1,236 | 8.70 | 0.75 | 23.6% |
| 1938 | 362 | 349 | 1 | 2,605 | 19.37 | 0.889 | 3.0% |
| 1939 | 367 | 343 | 0 | 2,331 | 16.85 | 0.89 | 3.2% |
| 1940 | 345 | 321 | 1 | 1,118 | 7.53 | 0.918 | 1.9% |
| 1941 | 33 | 29 | 0 | 88 | 0.54 | 0.948 | 1.1% |
| 1942 | 272 | 236 | 0 | 998 | 6.34 | 0.93 | 2.1% |
| undated, no estimate | 27 | 0 | 0 | 152 | 0.48 | 0.934 | 1.2% |
| **Total** | **15,819** | **1,533** | **453** | **77,009** | **602.89** | **0.825** | **15.8%** |

## Conversion plan

For the PressMint-FR corpus we plan to:
* Convert the BnF METS/ALTO data to the PressMint TEI scheme
* Convert/supplement metadata to the common scheme
* Encode the text in reading order
* Evaluate the linguistic annotation and named entities on a manually checked part of the sample
* Process the whole corpus once the sample is accepted
