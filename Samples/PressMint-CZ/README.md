# Samples of the PressMint-CZ corpus

## Data source

The source of the PressMint-CZ corpus will be a selection of texts from the digital library Kramerius, which is a project of the National Library of the Czech Republic.

### Details of the source:

* __Source__: The newspapers will be downloaded from [Moravian Library](https://www.digitalniknihovna.cz/mzk) through available API.
The library conains two relevant collections:
  - [Daily Press](https://www.digitalniknihovna.cz/mzk/collection/uuid:e8f61172-5e38-43bc-88ed-8737fc210bfc)
  - [Local Press](https://www.digitalniknihovna.cz/mzk/collection/uuid:9df7d62c-b572-4338-a0d1-b9c63e07a26e)


* __Availability__: 

* __Content__:  The texts are in Czech(`cs`) and German(`de`) languages and covers period 1812-1914. 

* __Size__: 

  - issues: 11(Local Press), 22(Daily Press), 26(both)
  - volumes: 504
  - copies: 139 k
  - pages: 954 k
  - words: 2.1 G _(very raugh estimation - used available recognized texts and `wc -w` command)_
  - facimiles: 954k * 6MB = 5.7 TB  (raugh estimation - not downloaded yet)

* __Structure__: 
It is possible to reconstruct all relations collection-issue-volume-copie-page. Pages corresponds to scan of the page in jpg format and automaticaly recognized text.

* __Correction__: -

* __Linguistic annotation__: -

* __Metadata__:

    The texts in the corpus have the following metadata:

    - Document ID 
    - ...
    
* __Format__: Raw text, not sure if it always follow the order of columns in article.

* __Facsimile__: The image files for single page is available from original source, eg ![1st page, Národní listy 1.1.1961](https://api.kramerius.mzk.cz/search/iiif/uuid:1c0e0e26-435f-11dd-b505-00145e5790ea/full/max/0/default.jpg)

#### Details of the exepected source:

Only daily and not local press will be included:
![words per year](https://raw.githubusercontent.com/ufal/PressMint-CZ-pipeline/refs/heads/main/DataStats/chart-year-word-issue.png)


## Conversion plan

