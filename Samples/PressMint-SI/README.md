# Samples of the PressMint-SI corpus

## Data source

The source of the PressMint-SI corpus will be a selection of texts from the
_Corpus of Slovenian periodicals (1771-1914) sPeriodika 1.0_
([http://hdl.handle.net/11356/1881](http://hdl.handle.net/11356/1881)).

The corpus is described in:

* Dobranić et al. 2024. [A Lightweight Approach to a Giga-Corpus of Historical Periodicals: The Story of a Slovenian Historical Newspaper Collection](https://aclanthology.org/2024.lrec-main.61/) *LREC-COLING 2024*.

* Pretnar Žagar, A. (2024). A Corpus Linguistic Characterisation of sPeriodika. *Conference on Language Technologies and Digital Humanities (JT-DH-2024)*. [https://doi.org/10.5281/zenodo.13936418](https://doi.org/10.5281/zenodo.13936418).


### Details of the source:

* __Source__: The periodical issues were retreived from [dLib](https://dlib.si),
the Slovenia's national library's digital library service in
the form of OCR-ed PDF and TXT files.

* __Availability__: Available for [download](http://hdl.handle.net/11356/1881) under the CC BY-SA 4.0 licence and
for on-line analysis via the
[CLARIN.SI installation of the NoSketch Engine concordancer](https://www.clarin.si/ske/#dashboard?corpname=speriodika).

* __Content__: Slovenian periodicals published during the 18th, 19th, and beginning of 20th century (1771-1914).
The corpus contains not only newspapers but also other periodically appearing texts, such as magazines or yearbooks.

* __Size__: Around 150 thousand texts and 910 million tokens (50GB).

* __Structure__: The corpus is structured into texts (typically corresponding to one issue of a periodical) and paragraphs.
No effort has been made to structure the texts into articles, mark their titles and similar.

* __Correction__: The OCR-ed texts were corrected with [cSMTiser](https://github.com/clarinsi/csmtiser) trained on
[a set of manually corrected samples](hdl.handle.net/11356/1907) from the original texts. 

* __Linguistic annotation__: The texts were then annotated with [CLASSLA-Stanza](https://github.com/clarinsi/classla) for
sentences, tokens, lemmas, part-of-speech tags and named entities,
following the Universal Dependencies formalism for tagging, and the standard CoNLL03 4-class NER system.

* __Metadata__: The texts in the corpus have the following metadata:

    - Document ID (URN)
    - Source (URL of the original digitised document available at dlib.si)
    - Document title (title of the specific issue of the periodical) 
    - Name of the periodical
    - Publisher
    - Volume number (if available)
    - Issue number (if available)
    - Date of publication (of varying granularity, based on original metadata available)
    - Year of publication (sometimes only as a date range, e.g. 1882/1888 or 1909-1910)
    The paragraphs have the following metadata:
    - Image (not available for all documents)
    - OCR quality estimation (either "low" or "good")

* __Format__: The corpus is formatted as a vertical file for the concordancer.
Below is the start of a corpus text:

    ```
    <text id="248H5BK1" source="https://dlib.si/details/URN:NBN:SI:DOC-248H5BK1/"
          publisher="Narodna tiskarna" title="Slovenski narod" periodical="Slovenski narod"
          issue="86" volume="25" date="1892-04-15" year="1892">
    <p id="248H5BK1.1.1" quality="good" image="248H5BK1-0.jpg">
    <s id="248H5BK1.1.1.1">
    86.		86.-k		Kav	Mdo	NUM	NumForm=Digit NumType=Ord
    številka	številka-s	Sozei	Ncfsn	NOUN	Case=Nom Gender=Fem Number=Sing
    <g/>
    .		.-u		U	Z	PUNCT	
    </s>
    </p>
    <p id="248H5BK1.1.2" quality="good" image="248H5BK1-0.jpg">
    <s id="248H5BK1.1.2.1">
    <name type="LOC">
    Ljubljana	Ljubljana-s	Slzei	Npfsn	PROPN	Case=Nom Gender=Fem Number=Sing
    </name>
    <g/>
    ,		,-u		U	Z	PUNCT	
    v		v-d		Dt	Sa	ADP	Case=Acc
    petek	petek-s		Sometn	Ncmsan	NOUN	Animacy=Inan Case=Acc Gender=Masc Number=Sing
    15.		15.-k		Kav	Mdo	NUM	NumForm=Digit NumType=Ord
    aprila	april-s	Somer	Ncmsg	NOUN	Case=Gen Gender=Masc Number=Sing
    <g/>
    .		.-u	U	Z	PUNCT	
    </s>
    </p>
    ```

* __Facsimile__: The image files for complete texts are available as PDFs from their original locations in dLib.
For most of the corpus per-page JPEGs are available on the Web and intergrated into the concordancer search.
However, they are not of high quality (quality: 50).
[Here](https://nl.ijs.si/inz/speriodika/4OVRPKTJ-2.jpg) is an example.
