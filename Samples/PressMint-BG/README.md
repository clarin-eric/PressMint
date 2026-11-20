# Samples of the PressMint-BG corpus


## Data source


The source of the PressMint-BG corpus will be digitized historical newspapers published in Bulgarian from 1879 to 1944 from the collection of the National Library in Plovdiv.


### Details of the source:


* __Source__: The paper issues have been scanned and OCR-ed with ABBYY FineReader. ABBYY FineReader is trained for each publisher.


* __Availability__: The issues are available at https://digital.libplovdiv.com/bg/v/periodicals


* __Content__: Newspapers, published in Bulgarian from 1879 to 1944.


* __Size__: 309 periodical editions and about 150 000 pages.


* __Structure__: The corpus is structured into issues and pages.


* __Correction__: The OCR-ed texts contain errors and need the following corrections. 54 issues from 45 newspapers manually processed.


* __Linguistic annotation__: The texts can be linguistically annotated using modern processing pipelines with good precision after several preprocessing steps, including data cleaning. The task is still in implementation phase.


* __Metadata__:
    Each issue contains:
    - Signature
    - Kind
    - Name
    - Subtitle
    - Publishing place
    - Publishing year
    - Language
    - Periodicity
    - Issue number     
    
* __Format__: The OCR-ed text is available in searchable PDF.


* __Facsimile__: The image files for complete texts are available as PDFs.


## Conversion plan


For the PressMint-BG corpus we plan to automatically clean and annotate the data and convert it to the PressMint TEI schema while retaining the available metadata. We do not plan to introduce new metadata.
