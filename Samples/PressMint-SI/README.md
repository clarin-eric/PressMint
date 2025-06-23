# Samples of the PressMint-SI corpus

## Documentation

### Data source

The source of the PressMint-SI corpus will be a selection of texts from the
*Corpus of Slovenian periodicals (1771-1914) sPeriodika 1.0*
([http://hdl.handle.net/11356/1881](http://hdl.handle.net/11356/1881)).

Details of the source:

* *Source*: The periodical issues were retreived from [dLib](https://dlib.si), the Slovenia's national library's digital library service in
the form of OCR-ed PDF and TXT files.
* *Availability*: Available for [download](http://hdl.handle.net/11356/1881) and for on-line analysis via the [CLARIN.SI installation of the NoSketch Engine concordancer](https://www.clarin.si/ske/#dashboard?corpname=speriodika).
* *Licence*: The corpus is available under the CC BY-SA 4.0 licence.
* *Content*: Slovenian periodicals published during the 18th, 19th, and beginning of 20th century (1771-1914). The corpus contains not only newspapers but also other periodically appearing texts, such as magazines or yearbooks.
* *Size*: Around 150,000 texts and 910,000,000 tokens (50GB).
* *Structure*: The corpus is structured into texts (typically corresponding to one issue of a periodical) and paragraphs. No effort has been made to structure the texts into articles, mark their titles and similar. However
* *Correction*: The OCR-ed texts were corrected with [cSMTiser](https://github.com/clarinsi/csmtiser) trained on [a set of manually corrected samples](hdl.handle.net/11356/1907) from the original texts. 
* *Linguistic annotation*: The texts were then annotated with (CLASSLA-Stanza)[https://github.com/clarinsi/classla] for sentences,  tokens, lemmas, part-of-speech tags and named entities, following the Universal Dependencies formalism for tagging, and the standard 5-class NER system.
* *Metadata*: The texts in the corpus have the following metadata:

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
* *Format*: The corpus is formatted as a vertical file for the concordancer. Below is the start of a corpus text:
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
petek		petek-s		Sometn	Ncmsan	NOUN	Animacy=Inan Case=Acc Gender=Masc Number=Sing
15.		15.-k		Kav	Mdo	NUM	NumForm=Digit NumType=Ord
aprila		april-s	Somer	Ncmsg	NOUN	Case=Gen Gender=Masc Number=Sing
<g/>
.		.-u	U	Z	PUNCT	
</s>
</p>
    ```
