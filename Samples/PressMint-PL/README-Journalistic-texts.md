# Samples of the PressMint-PL Journalistic texts

## Data source

The source of the PressMint-PL Journalistic texts will be a selection of texts from the
_Microcorpus of Nineteenth-Century Polish (1830-1918)_
([https://heiup.uni-heidelberg.de/catalog/view/361/555/84011](https://heiup.uni-heidelberg.de/catalog/view/361/555/84011)).

The corpus is described in:

* Bilińska, J., Kwiecień, M., & Derwojedowa, M. (2016).
[Microcorpus of Nineteenth-Century Polish](https://doi.org/10.17885/heiup.361.c4712).
*Heidelberg University Publishing*.

### Details of the source:

* __Source__: The journalistic texts were retrieved from various digital libraries including the Polish National Library on-line Polona, Warsaw University Digital Library, and Digital Library of Wielkopolska, in the form of OCR-ed PDF, DjVu, and TXT files.

* __Availability__: Available for download from [http://www.f19.uw.edu.pl/download/korpus-f19-v1-0/](http://www.f19.uw.edu.pl/download/korpus-f19-v1-0/) and for on-line analysis via the Polish National Corpus Poliqarp engine at [https://szukajwslownikach.uw.edu.pl](https://szukajwslownikach.uw.edu.pl).

* __Content__: Polish journalistic texts published during the 19th century (1830-1918). The journalistic subcorpus includes texts published in newspapers, journals and books. The most characteristic feature of the style is the anonymity of texts — almost half of them are signed only by initials, a pseudonym or collective author.

* __Size__: 200 samples of 1000 tokens each, totaling approximately 200,000 tokens.

* __Structure__: The corpus is structured into samples (typically corresponding to one article or text fragment) and continuous text fragments. Each sample comprises a fragment of continuous text, its metadata, and a source graphic file.

* __Correction__: The source documents were primarily selected based on the availability of embedded text layers (PDF, DjVu formats). For documents lacking text layers, optical character recognition (OCR) was applied. All texts underwent subsequent manual verification and correction procedures to ensure accuracy.

* __Linguistic annotation__: No linguistic annotation is available for the corpus.

* __Metadata__:

    The texts in the corpus have the following metadata:

    - Author (often anonymous, signed with initials, pseudonym, or collective author)
    - Title (article or text title)
    - Publication date (with varying granularity)
    - Place of publication
    - Editor (if available)
    - Book title (if applicable)
    - Newspaper/magazine/series title
    - Issue number
    - Publisher (if available)
    - Page numbers
    - Style classification ("publicystyka")
    - Source library
    - Link to original digital resource

* __Format__: The corpus is formatted as plain text files with corresponding metadata files and a source graphic file.
Below is the start of a corpus text sample:

    ```
    III. Wiadomość o uobyczaieniu Afryki. 
    (Dokończenie.) (Obacz zeszyt drugi Czasopisma z tego roku na stronie 24téy). 
    Już okazaliśmy główne przeszkody naszego zbliżenia się do ludów Murzyńskich. Naypiérwsza iest nieufność zaszczepiona w nich przez nasze zamiary, nieufność zbyt usprawiedliwiona przez nasze postępki. Przez trzy wieki czegożeśmy żądali od Afryki? Nic innego prócz niewolników i złota. Cożeśmy iéy dali zato w zamianę? Oto strzelbę i proch, a to dla tego żeby ułatwić iéy dziecióm wzaiemne siebie wyplenianie; mocne napoie zniżaiące ich do zwierząt; kilka przedmiotów płochego zbytku, bursztyn, ziarnka szklanne, galonowane kapelusze, suknie szarletańskie; toż to iest wszystko co opłaciło wolność i życie ludzkie!
    ```

* __Facsimile__: The original documents are available as PDF or DjVu image files. Links to original location of source documents are stored in the metadata information.

## Conversion plan

For the PressMint-PL Journalistic texts we plan to:

* Develop conversion procedure for plain text to PressMint format and annotation

    * we retain all the available metadata & do not plan to introduce new metadata
    * preserve the original 19th-century Polish spelling and orthography
    * The texts will be annotated for sentences, tokens, lemmas, part-of-speech tags and features, and named entities
