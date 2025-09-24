# Samples of the PressMint-LV corpus

## Data source

The source of the PressMint-LV corpus will be digitized historical newspaper "Jaunākās ziņas" (1911-1940) from the collection of National Library of Latvia.

### Details of the source:

* __Source__: The paper issues have been scanned and OCR-ed with both Tesseract 3.02 and ABBYY Finereader 12.0.

* __Availability__: The issues are available at [https://periodika.lndb.lv/](https://periodika.lndb.lv/#periodicalItem:1330)

* __Content__: The daily newspaper "Jaunākās Ziņas", published in Latvia from 1911 to 1940.

* __Size__: Around 8,700 issues, 388,000 articles.

* __Structure__: The corpus is structured into issues, pages and articles.

* __Correction__: The OCR-ed texts contain a significant amount of errors. The language has been modernized and many errors corrected using the multimodal Gemini 2.5 Flash model. The prompt is provided in the prompt.txt file.

* __Linguistic annotation__: The texts can be linguistically annotated using modern processing pipelines with good precision, since the texts are modernized.

* __Metadata__: 
    Each article contains:
    - URI
    - Volume number
    - Issue number
    - Date of publication in iso8601 (yyyymmdd)
    - Title
    - Subheadline (if available)
    - Section (if available)
    - Author (if available)

* __Format__: The OCR-ed text is available in ALTO XML format. Individual articles are extracted in txt format and then further corrected.

* __Facsimile__: The image files for complete texts are available as JPEGs. 

## Conversion plan

For the PressMint-LV corpus we plan to automatically annotate the data and prepare it in PressMint format, retaining all available metadata. We do not plan to introduce new metadata.
