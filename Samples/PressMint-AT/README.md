# Samples of the PressMint-AT corpus

## Data source

The source of the PressMint-AT corpus will be all available issues of the *Wiener Abendpost* published between 1st July 1863 and 31st December 1921. High-quality scans and full-text transcriptions of the newspaper issues are accessible via ANNO (AustriaN Newspaper Online). However, as the transcriptions come with all the limitations of automatic OCR created some years ago without manual corrections, it is necessary to create new high-quality transcriptions. 

### Details of the source:

* __Source__: The *Wiener Abendpost* was a supplement of the *Wiener Zeitung*. It was published 6 days a week (except Sundays) and had on average between 4 and 8 pages. For the relevant time period, this results in a total of over 17,450 issues and 90,300 pages. 

* __Availability__: -

* __Content__: The newspaper is in German. In terms of content, the *Wiener Abendpost* contains a daily news section, a feuilleton section, and advertisements. 

* __Size__: Over 17,450 issues and 90,300 pages. 

* __Structure__: On ANNO, newspaper issues are organized by year, month, and date. Due to the *Wiener Abendpost* being a supplement, each issue is part of the corresponding issue of the *Wiener Zeitung*. Relevant pages will be extracted using an image classifier trained to recognize the first page of the *Wiener Abendpost* and the first page of the following supplement.

* __Correction__: -

* __Linguistic annotation__: -

* __Metadata__:

    The texts in the corpus have the following metadata:

    - Document ID 
    - Year
    - Month
    - Day
    - Publisher
    - (Issue number)
    
* __Format__: Scans.

* __Facsimile__: -

## Conversion plan

For the PressMint-AT corpus we plan to:
- extract all relevant pages using the image classifier. 
- create new high-quality transcriptions, using PERO OCR.
- convert the raw text to the PressMint TEI scheme.
- do the linguistic annotation via UDPipe and NameTag.
