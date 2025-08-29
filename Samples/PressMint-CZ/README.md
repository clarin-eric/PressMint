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

| title                                      |   pages |       words |
|-------------------------------------------|--------:|-----------:|
| [Národní nowiny](https://www.digitalniknihovna.cz/mzk/periodical/uuid:5abfd8d0-b9f1-11e9-8fdf-005056827e52)                            |    2 446 |   5 580 345 |
| [Moravská orlice](https://www.digitalniknihovna.cz/mzk/periodical/uuid:02203ad6-32f0-11de-992b-00145e5790ea)                           |   82 428 | 205 386 790 |
| [Národní listy](https://www.digitalniknihovna.cz/mzk/periodical/uuid:ae876087-435d-11dd-b505-00145e5790ea)                             |  181 419 | 681 521 395 |
| [Lidové noviny](https://www.digitalniknihovna.cz/mzk/periodical/uuid:bdc405b0-e5f9-11dc-bfb2-000d606f5dc6)                             |   73 792 | 166 273 100 |
| [Katolické listy](https://www.digitalniknihovna.cz/mzk/periodical/uuid:b138db20-a5e4-11e8-99aa-005056827e51)                           |   19 786 |  40 013 163 |
| [Čech: politický týdenník katolický](https://www.digitalniknihovna.cz/mzk/periodical/uuid:5c259210-2182-11e6-918e-5ef3fc9ae867)        |   67 667 | 146 565 919 |

## Conversion plan

