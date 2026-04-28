# PressMint-UA

## Data source

The PressMint-UA corpus is based on historical newspaper texts from GRAC (General Regionally Annotated Corpus of Ukrainian).

### Source description

- **Source**: GRAC newspaper texts have been collected from multiple sources, including, but not limited to, the following: the historical press archive curated by Orest Drul on the [Zbruch portal](https://zbruc.eu), [LIBRARIA](https://libraria.ua/), and the [Archive of Old Newspapers](https://oldnewspapers.com.ua/).
- **License**: CC BY 4.0
- **Content**:  the collection comprises newspaper titles published before 1939 and reflects the political fragmentation, regional variation, and orthographic diversity of the Ukrainian-language press from the late nineteenth century to WWII.
- **Volume**:
    - GRAC historical newspaper collection: 117 newspaper titles before 1939, approximately 22 million tokens.
    - current PressMint-UA sample: 32 plain text files, 32 plain TEI files, 32 morphologically annotated TEI files, 32 GRAC XML files with nlp_uk tagging, one GRAC sample metadata file; a total of 8,743 words.
- **Structure**: the text corpus is organized at the article level according to the standard PressMint schema.
- **Proofreading**: the corpus texts have been manually checked by the [contributors](https://uacorpus.org/en/informaciya-pro-grak/rozrobniki).
- **Linguistic annotation**: the .ana version contains:
    - sentence segmentation and tokenization using [nlp_uk](https://github.com/brown-uk/nlp_uk)
    - lemmas, part-of-speech tags, and morphological features by [UDPipe 2](https://lindat.mff.cuni.cz/services/udpipe/) ([ukrainian-parlamint-ud-2.17-251125](https://universaldependencies.org/treebanks/uk_parlamint/index.html))
    - NER tags derived from proper noun [tags](https://github.com/brown-uk/dict_uk/blob/master/doc/tags.txt) by nlp_uk
- **Metadata**: each document contains the following fields:
    - Article level:
        - local path to the source in [PluG (PluG: A Corpus of Pre-Modern Ukrainian Texts)](https://zenodo.org/records/19482961)
        - title
        - language
        - number of paragraphs, sentences, and words (where available)
    - Newspaper issue level:
        - newspaper title
        - media type
        - city of publication
        - publication date
        - issue number
    - [Region](https://uacorpus.org/rozmitka-tekstiv/regionalna-rozmitka) and [administrative metadata](https://uacorpus.org/rozmitka-tekstiv/vidomosti-pro-media):
        - country
        - location code
        - macroregion
        - political-administrative unit: AHI (Austro-Hungarian Empire), DIA (Western Diaspora), ZUNR (West Ukrainian People's Republic), MAX (Makhnovist Movement), POL (Interwar Poland), CZE (Interwar Czechoslovakia), ROM (Interwar Romania), OUN (Organization of Ukrainian Nationalists), RUK (Reichskommissariat Ukraine), RUI (Russian Empire), SOV (Ukrainian Soviet Socialist Republic)
- **Format**: UTF-8 plain text and tagged GRAC XML; PressMint TEI XML and PressMint .ana TEI XML.

![Tokens of old newspaper texts by year and macroregion: West, East, Center, South, North, Kyiv](https://i.ibb.co/FkGG4ZcH/image.png)

_Figure 1: Tokens of old newspaper texts by year and macroregion: West, East, Center, South, North, Kyiv._

#### Plans for the complete corpus

The complete PressMint-UA corpus aims to cover the entire collection of GRAC historical newspapers through 1939. 

A significant portion of the Western Ukrainian materials is written in Zhelekhivka, a spelling standard from the late 19th to early 20th centuries that was widespread in Western Ukraine. These texts will require a specially trained UDPipe 2 model for historical Western Ukrainian texts.

## Conversion plan

The conversion pipeline has been applied to the sample:

- GRAC sample source files and metadata have been converted to PressMint TEI XML
- region and media administration taxonomies have been added
- nlp_uk was used for tokenization and sentence segmentation
- UDPipe 2 was used for lemmatization and morphosyntactic annotation
- NER tags from nlp_uk were aligned with the PressMint taxonomy

Before scaling to the entire corpus, it is necessary to:

- verify metadata for other newspapers
- improve named entity recognition, especially for organizations and multi-token entities
- [integrate](https://github.com/clarin-eric/PressMint/issues/51) additional [nlp_uk morphological annotation](https://github.com/brown-uk/dict_uk/blob/master/doc/tags.txt)
- run the same pipeline on the rest of the historical newspaper collection
- determine a strategy for processing texts written in Zhelekhivka


