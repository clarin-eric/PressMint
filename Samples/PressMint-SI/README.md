# Samples of the PressMint-SI corpus

## Data source

The source of the PressMint-SI corpus will be a selection of texts from the
_Corpus of Slovenian periodicals (1771-1914) sPeriodika 1.0_
([http://hdl.handle.net/11356/1881](http://hdl.handle.net/11356/1881)).

The corpus is described in:

* Dobranić et al. (2024).
[A Lightweight Approach to a Giga-Corpus of Historical Periodicals:
The Story of a Slovenian Historical Newspaper Collection](https://aclanthology.org/2024.lrec-main.61/).
*LREC-COLING 2024*.

* Pretnar Žagar, A. (2024).
[A Corpus Linguistic Characterisation of sPeriodika](https://doi.org/10.5281/zenodo.13936418).
*JT-DH 2024*.


### Details of the source:

* __Source__: The periodical issues were retreived from [dLib](https://dlib.si),
the Slovenia's national library's digital library service in
the form of OCR-ed PDF and TXT files.

* __Availability__: Available for [download](http://hdl.handle.net/11356/1881) under the CC BY-SA 4.0 licence and
for on-line analysis via the
[CLARIN.SI installation of the NoSketch Engine concordancer](https://www.clarin.si/ske/#dashboard?corpname=speriodika).

* __Content__: Slovenian periodicals published during the 18th, 19th, and beginning of 20th century (1771-1914).
The corpus contains not only newspapers but also other periodically appearing texts, such as magazines or yearbooks.

* __Size__: Around 150 thousand texts or 910 million tokens (50GB).

* __Structure__: The corpus is structured into texts (typically corresponding to one issue of a periodical and
sometimes to a particular article) and paragraphs.
No effort has been made to structure the texts into articles, mark their titles and similar.

* __Correction__: The OCR-ed texts were corrected with [cSMTiser](https://github.com/clarinsi/csmtiser) trained on
[a set of manually corrected samples](hdl.handle.net/11356/1907) from the original texts. 

* __Linguistic annotation__: The texts were annotated with [CLASSLA-Stanza](https://github.com/clarinsi/classla) for
sentences, tokens, lemmas, part-of-speech tags and features, and named entities,
following the Universal Dependencies formalism for tagging, and the standard CoNLL03 4-class system for NEs.

* __Metadata__:

    The texts in the corpus have the following metadata:

    - Document ID (its dLib URN)
    - Source (URL of the original digitised document available at dlib.si)
    - Article title (when the file is a specific article)
    - Publisher
    - Name of the periodical
    - Date of publication (of varying granularity, based on original metadata available)
    - Year of publication (sometimes only as a date range, e.g. 1882/1888 or 1909-1910)
    - Volume number (if available)
    - Issue number (if available)
    - Number of pages
    - The ration of corrections made my cSMTIser
    
    Each of the pages contained have the following metadata:
    
    - Page number, starting with 0
    - URL of the page image where the paragraph appears (not available for all documents)
    - Alignment ratio between source and cSMTiser text

   The transcription for each page is given in several variants:

   - The text taken from the source PDF
   - White-space (?) normalised text
   - cSMTiser corrected text with quality estimation in terms of KenLM perplexity (mean and standard deviation)
   - Corrected text with end-of line normalised words (?)
   - Normalised text in CoNLL-U format processed with CLASSLA
   
* __Format__: The corpus is available both as a vertical file for the concordancer as well as JSON files.
  We will take the JSON files as our source. 
  Below the content of one JSON file:

```json
{"csmt_rate": 0.04,"date": "1877-08-15","dlib_date": "1877 08 15","dlib_url": "https://dlib.si/details/URN:NBN:SI:DOC-000TTDCE/","issue_number": "33","number_of_pages": 1,"pages": [ {"align_ratio": 100.0, "final_line_index": 2, "image_url": "https://nl.ijs.si/inz/periodika/0/000TTDCE/000TTDCE-0.jpg", "page_index": 0, "pdf_text": "260 \nGospodarske sku\u0161nje. \n* Goveda in konji se dado nadle\u017enih muh obva\u00ad\nrovati, \u010de se s sukneno cunjo, katera je bila v ribjo \nmaBt pomo\u010dena, po \u017eivotu dobro oribajo. Ker pa ribja \nmast smrdi in tudi dober kup ni, so na ve\u010d krajih \nNem\u010dije za bolje spoznali pelinovovodo, s katero \nse \u017eivina, kolikorkrrat treba, umije. ", "text": "\n260\n\nGospodarske sku\u0161nje.\n\n* Goveda in konji se dado nadle\u017enih muh obvarovati, \u010de se s sukneno cunjo, katera je bila v ribjo maBt pomo\u010dena, po \u017eivotu dobro oribajo. Ker pa ribja mast smrdi in tudi dober kup ni, so na ve\u010d krajih Nem\u010dije za bolje spoznali pelinovovodo, s katero se \u017eivina, kolikorkrrat treba, umije.\n", "text_csmtised": "\n260\n\nGospodarske sku\u0161nje.\n\n* Goveda in konji se dado nadle\u017enih muh obvarovati, \u010de se s sukneno cunjo, katera je bila v ribjo mast pomo\u010dena, po \u017eivotu dobro oribajo. Ker pa ribja mast smrdi in tudi dober kup ni, so na ve\u010d krajih Nem\u010dije za bolje spoznali pelinovovodo, s katero se \u017eivina, kolikorkrrat treba, umije.\n", "text_csmtised_kenlm_perplexity": {"mean": -84.12516357421875, "stdev": 6.49344779660705}, "text_csmtised_splitfixed": "\n260 Gospodarske sku\u0161nje.\n\n* Goveda in konji se dado nadle\u017enih muh obvarovati, \u010de se s sukneno cunjo, katera je bila v ribjo mast pomo\u010dena, po \u017eivotu dobro oribajo. Ker pa ribja mast smrdi in tudi dober kup ni, so na ve\u010d krajih Nem\u010dije za bolje spoznali pelinovovodo, s katero se \u017eivina, kolikorkrrat treba, umije.\n", "text_csmtised_splitfixed_CONLLU": "# newpar id = 1\n# sent_id = 1.1\n# text = 260 Gospodarske sku\u0161nje.\n1\t260\t260\tNUM\tMdc\tNumForm=Digit|NumType=Card\t_\t_\t_\tNER=O\n2\tGospodarske\tgospodarski\tADJ\tAgpfsg\tCase=Gen|Degree=Pos|Gender=Fem|Number=Sing\t_\t_\t_\tNER=O\n3\tsku\u0161nje\tsku\u0161nja\tNOUN\tNcfsg\tCase=Nom|Gender=Fem|Number=Plur\t_\t_\t_\tNER=O|SpaceAfter=No\n4\t.\t.\tPUNCT\tZ\t_\t_\t_\t_\tNER=O\n\n# newpar id = 2\n# sent_id = 2.1\n# text = * Goveda in konji se dado nadle\u017enih muh obvarovati, \u010de se s sukneno cunjo, katera je bila v ribjo mast pomo\u010dena, po \u017eivotu dobro oribajo.\n1\t*\t*\tPUNCT\tZ\t_\t_\t_\t_\tNER=O\n2\tGoveda\tgoveda\tNOUN\tNcfsn\tCase=Nom|Gender=Masc|Number=Sing\t_\t_\t_\tNER=O\n3\tin\tin\tCCONJ\tCc\t_\t_\t_\t_\tNER=O\n4\tkonji\tkonj\tNOUN\tNcmpn\tCase=Nom|Gender=Masc|Number=Plur\t_\t_\t_\tNER=O\n5\tse\tse\tPRON\tPx------y\tPronType=Prs|Reflex=Yes|Variant=Short\t_\t_\t_\tNER=O\n6\tdado\tdati\tVERB\tVmer3p\tAspect=Perf|Mood=Ind|Number=Plur|Person=3|Tense=Pres|VerbForm=Fin\t_\t_\t_\tNER=O\n7\tnadle\u017enih\tnadle\u017een\tADJ\tAgpfpg\tCase=Gen|Degree=Pos|Gender=Fem|Number=Plur\t_\t_\t_\tNER=O\n8\tmuh\tmuha\tNOUN\tNcfpg\tCase=Gen|Gender=Fem|Number=Plur\t_\t_\t_\tNER=O\n9\tobvarovati\tobvarovati\tVERB\tVmen\tAspect=Perf|VerbForm=Inf\t_\t_\t_\tNER=O|SpaceAfter=No\n10\t,\t,\tPUNCT\tZ\t_\t_\t_\t_\tNER=O\n11\t\u010de\t\u010de\tSCONJ\tCs\t_\t_\t_\t_\tNER=O\n12\tse\tse\tPRON\tPx------y\tPronType=Prs|Reflex=Yes|Variant=Short\t_\t_\t_\tNER=O\n13\ts\tz\tADP\tSi\tCase=Ins\t_\t_\t_\tNER=O\n14\tsukneno\tsuknen\tADJ\tAppfsi\tCase=Ins|Degree=Pos|Gender=Fem|Number=Sing\t_\t_\t_\tNER=O\n15\tcunjo\tcunja\tNOUN\tNcfsi\tCase=Ins|Gender=Fem|Number=Sing\t_\t_\t_\tNER=O|SpaceAfter=No\n16\t,\t,\tPUNCT\tZ\t_\t_\t_\t_\tNER=O\n17\tkatera\tkateri\tDET\tPq-fsn\tCase=Nom|Gender=Fem|Number=Sing|PronType=Int\t_\t_\t_\tNER=O\n18\tje\tbiti\tAUX\tVa-r3s-n\tMood=Ind|Number=Sing|Person=3|Polarity=Pos|Tense=Pres|VerbForm=Fin\t_\t_\t_\tNER=O\n19\tbila\tbiti\tAUX\tVa-p-sf\tGender=Fem|Number=Sing|VerbForm=Part\t_\t_\t_\tNER=O\n20\tv\tv\tADP\tSa\tCase=Acc\t_\t_\t_\tNER=O\n21\tribjo\tribji\tADJ\tAgpfsa\tCase=Acc|Degree=Pos|Gender=Fem|Number=Sing\t_\t_\t_\tNER=O\n22\tmast\tmast\tNOUN\tNcfsa\tCase=Acc|Gender=Fem|Number=Sing\t_\t_\t_\tNER=O\n23\tpomo\u010dena\tpomo\u010den\tADJ\tAppfsn\tCase=Nom|Degree=Pos|Gender=Fem|Number=Sing|VerbForm=Part\t_\t_\t_\tNER=O|SpaceAfter=No\n24\t,\t,\tPUNCT\tZ\t_\t_\t_\t_\tNER=O\n25\tpo\tpo\tADP\tSl\tCase=Loc\t_\t_\t_\tNER=O\n26\t\u017eivotu\t\u017eivot\tNOUN\tNcmsl\tCase=Loc|Gender=Masc|Number=Sing\t_\t_\t_\tNER=O\n27\tdobro\tdobro\tADV\tRgp\tDegree=Pos\t_\t_\t_\tNER=O\n28\toribajo\toribati\tVERB\tVmpr3p\tAspect=Imp|Mood=Ind|Number=Plur|Person=3|Tense=Pres|VerbForm=Fin\t_\t_\t_\tNER=O|SpaceAfter=No\n29\t.\t.\tPUNCT\tZ\t_\t_\t_\t_\tNER=O\n\n# sent_id = 2.2\n# text = Ker pa ribja mast smrdi in tudi dober kup ni, so na ve\u010d krajih Nem\u010dije za bolje spoznali pelinovovodo, s katero se \u017eivina, kolikorkrrat treba, umije.\n1\tKer\tker\tSCONJ\tCs\t_\t_\t_\t_\tNER=O\n2\tpa\tpa\tCCONJ\tCc\t_\t_\t_\t_\tNER=O\n3\tribja\tribji\tADJ\tAgpfsn\tCase=Nom|Degree=Pos|Gender=Fem|Number=Sing\t_\t_\t_\tNER=O\n4\tmast\tmast\tNOUN\tNcfsn\tCase=Nom|Gender=Fem|Number=Sing\t_\t_\t_\tNER=O\n5\tsmrdi\tsmrdeti\tVERB\tVmpr3s\tAspect=Imp|Mood=Ind|Number=Sing|Person=3|Tense=Pres|VerbForm=Fin\t_\t_\t_\tNER=O\n6\tin\tin\tCCONJ\tCc\t_\t_\t_\t_\tNER=O\n7\ttudi\ttudi\tPART\tQ\t_\t_\t_\t_\tNER=O\n8\tdober\tdober\tADJ\tAgpmsnn\tCase=Nom|Definite=Ind|Degree=Pos|Gender=Masc|Number=Sing\t_\t_\t_\tNER=O\n9\tkup\tkup\tNOUN\tNcmsn\tCase=Nom|Gender=Masc|Number=Sing\t_\t_\t_\tNER=O\n10\tni\tbiti\tVERB\tVa-r3s-y\tMood=Ind|Number=Sing|Person=3|Polarity=Neg|Tense=Pres|VerbForm=Fin\t_\t_\t_\tNER=O|SpaceAfter=No\n11\t,\t,\tPUNCT\tZ\t_\t_\t_\t_\tNER=O\n12\tso\tbiti\tAUX\tVa-r3p-n\tMood=Ind|Number=Plur|Person=3|Polarity=Pos|Tense=Pres|VerbForm=Fin\t_\t_\t_\tNER=O\n13\tna\tna\tADP\tSl\tCase=Loc\t_\t_\t_\tNER=O\n14\tve\u010d\tve\u010d\tDET\tRgc\tPronType=Ind\t_\t_\t_\tNER=O\n15\tkrajih\tkraj\tNOUN\tNcmpl\tCase=Loc|Gender=Masc|Number=Plur\t_\t_\t_\tNER=O\n16\tNem\u010dije\tNem\u010dija\tPROPN\tNpfsg\tCase=Gen|Gender=Fem|Number=Sing\t_\t_\t_\tNER=B-LOC\n17\tza\tza\tADP\tSa\tCase=Acc\t_\t_\t_\tNER=O\n18\tbolje\tdobro\tADV\tRgc\tDegree=Cmp\t_\t_\t_\tNER=O\n19\tspoznali\tspoznati\tVERB\tVmbp-pm\tGender=Masc|Number=Plur|VerbForm=Part\t_\t_\t_\tNER=O\n20\tpelinovovodo\tpelinovovoda\tNOUN\tNcfsa\tCase=Acc|Gender=Fem|Number=Sing\t_\t_\t_\tNER=O|SpaceAfter=No\n21\t,\t,\tPUNCT\tZ\t_\t_\t_\t_\tNER=O\n22\ts\tz\tADP\tSi\tCase=Ins\t_\t_\t_\tNER=O\n23\tkatero\tkateri\tDET\tPq-fsi\tCase=Ins|Gender=Fem|Number=Sing|PronType=Int\t_\t_\t_\tNER=O\n24\tse\tse\tPRON\tPx------y\tPronType=Prs|Reflex=Yes|Variant=Short\t_\t_\t_\tNER=O\n25\t\u017eivina\t\u017eivina\tNOUN\tNcfsn\tCase=Nom|Gender=Fem|Number=Sing\t_\t_\t_\tNER=O|SpaceAfter=No\n26\t,\t,\tPUNCT\tZ\t_\t_\t_\t_\tNER=O\n27\tkolikorkrrat\tkolikorkrrat\tNOUN\tNcmsn\tCase=Nom|Gender=Masc|Number=Sing\t_\t_\t_\tNER=O\n28\ttreba\ttreba\tADV\tRgp\tDegree=Pos\t_\t_\t_\tNER=O|SpaceAfter=No\n29\t,\t,\tPUNCT\tZ\t_\t_\t_\t_\tNER=O\n30\tumije\tumiti\tVERB\tVmer3s\tAspect=Perf|Mood=Ind|Number=Sing|Person=3|Tense=Pres|VerbForm=Fin\t_\t_\t_\tNER=O|SpaceAfter=No\n31\t.\t.\tPUNCT\tZ\t_\t_\t_\t_\tNER=O\n\n"}],"periodical_name": "Kmetijske in rokodelske novice","publisher": "Jo\u017eef Blaznik","title": "Gospodarske sku\u0161nje","URN": "URN:NBN:SI:DOC-000TTDCE","volume_number": 35,"year": "1877"}

```

* __Facsimile__: The image files for complete texts are available as PDFs from their original locations in dLib. 
For most of the corpus per-page JPEGs are available on the Web and integrated into the concordancer search.
However, they are not of high quality (quality: 50).
[Here](https://nl.ijs.si/inz/speriodika/4OVRPKTJ-2.jpg) is an example.

## Conversion plan

For the PressMint-SI corpus we plan to:

* Sample sPeriodika to:

    * remove texts that are not newspapers
    * remove text older than 1850 (they use the old alphabet incorrectly recognised by OCR)
    * remove texts with too many paragraphs (pages) of low OCR quality
    * (maybe) remove paragraphs (pages) with low OCR quality

* Develop conversion procedure for JSON to PressMint format
    * a parameter specifies whether to produce plain text or .ana version
    * Start of work in [Makefile](Makefile)
 
