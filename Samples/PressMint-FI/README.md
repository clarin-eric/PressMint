# Samples of the PressMint-FI corpus

## Data source

The sources of the PressMint-FI corpus will be the copyright-free
years of the klk-fi-v2 (Finnish, already available through Korp and
the corresponding source format for download) and klk-sv-v2 (Swedish,
soure data is finished, pending publication in Korp) corpora of
newspapers and periodicals published in Finland, OCR'd by the National
Library, further processed and made available (so far in a version of
the CWB-VRT format) by the Language Bank of Finland (Kielipankki).

The two samples files consist of one random page for each decade from
1820 to 1919, which makes a total of 10 Finnish and 10 Swedish pages.
(Previous PUB corpora end in 1874 and 1879, respectively. It should be
possible to publish much newer material now, based on machine-readable
copyright statements from the National Library.)

### Details of the source:

* __Source__:

    Finnish and Swedish newspaper and periodical corpora klk-fi-v2
    (already published by Kielipankki) and klk-sv-v2 (being
    published). (Should really put proper links here. TODO)

* __Availability__:

    klk-fi-v2 is already available from Kielipankki both in Korp and
    for download in CWB-VRT format (older parts as CLARIN PUB, newer
    parts as ACA), klk-sv-v2 to be made available this fall (2026;
    spring publication did not happen because some of the metadata
    needed corrections, relevant to PressMint).

* __Content__:

    Newspapers and periodicals published in Finland since 1771, OCR
    carried out by the National Library, further processing of the
    METS/Alto pages in the Language Bank (Kielipankki)

* __Size__: lots, depending on what time period can be provided
    (numbers have been made, TODO find and add the numbers here)

* __Structure__: pages, segmented in paragraphs, sentences, tokens;
   metadata identifies issue and page number

* __Correction__: no manual corrections

* __Linguistic annotation__:

    The Finnish source data is annotated with a grammatical dependency
    model that predates Universal Dependencies (corresponding to an
    old Turku Dependency Treebank), the Swedish data with Sparv from
    the Swedish Language Bank (Språkbanken), so a very different
    looking dependency syntax. Reprocessing might be possible, likely
    with Trankit and its relatively current UD models. (But advice
    from PressMint project was to drop syntax annotations altogether.)

    Sentences are annotated with an identified language, paragraphs
    and texts with the counts of each identified language in them.

* __Metadata__:

    The texts (pages) in the source corpus have the following metadata:

    - Document ID (both a binding id and a generated text id)
    - Publication date
    - Publication title
    - Page number
    - Publication type (newspaper, periodical)
    - Skeletal image URL (turned out to be obsolete)
    - Nominal language of the publication
    - Identified languages (numbers of sentences)

* __Format__:

    Source is in a version of CWB-VRT, like TSV segmented with
    XML-like tags, with names provided for positional attributes in a
    special comment. Kielipankki has developed their own tools and
    skills for this.

* __Facsimile__:

    Links to National Library web pages can be generated from the
    metadata (actually just the issue identifier and page number are
    relevant, the skeletal URI in the source data turned out to be
    obsolete)

## Conversion plan

For the PressMint-FI corpus we plan to:

   - write (now wrote) specific conversion scripts in Python
   - possibly filter out "sentences" that were not identified as any
     known language (coded as xxx in the source, translated to und for TEI)
