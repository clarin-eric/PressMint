# Samples of the PressMint-NL corpus

## Data source

The source of the PressMint-SI corpus will be a selection of texts from historical corpora available at INT.

We will start from the data of the current published version of the ([Couranten corpus](https://couranten.ivdnt.org/)).

Cf ([Documentation] (https://couranten.ivdnt.org/corpus-frontend/couranten/about)) 

### Details of the source:

* __Source__: 

* __Availability__: Publicly available at taalmaterialen.ivdnt.org

* __Content__: 17-th century newspapers

* __Size__: 18,232,836 tokens

* __Structure__:  TEI-ish (not validated)

* __Correction__: Corrected OCR

* __Linguistic annotation__: According to the Tagset Diachronic Dutch ([TDN] (https://ivdnt.org/wp-content/uploads/2024/11/TDNV2_combi.pdf)) tagged with ([INT huggingface tagger](https://github.com/instituutnederlandsetaal/int-huggingface-tagger))

* __Metadata__:

    The texts in the corpus have the following relevant metadata:

   - pid
   - sourceID
   - sourceUrl
   - date (year, month, day)
   - articleClass (text type)
   - titleLevel1 (article title, e.g. *Londen den 9 November*.)
   - titleLevel2 (newspaper name, e.g. *Oprechte Haerlemsche courant*)
   - newspaperSection (title of containing section, e.g. *ENGELANDT*)
   - settingLocation_country (country the from which the news originates, e.g. *Verenigd Koningkrijk* (United Kindom))
   - settingLocation_place (city from which the news originates, e.g. *Londen*)
   - colophon
   
* __Format__: TEI-ish (not validated)


* __Facsimile__: Link to page facsimile at the National Library of the Netherlands for each article

## Conversion

For the PressMint-NL corpus we:
* Convert to the PressMint TEI scheme (done, offline validation with Scripts/validate-pressmint.pl and Scripts/pressmintp2conllu.pl satisfied)
  * Problems
    * We can not link to the facsimile, we just have a link to the online repository of the Royal Library for an article (e.g https://www.delpher.nl/nl/kranten/view?coll=ddd&identifier=ddd:010926959:mpeg21:a0003)
    * How to encode the settingLocation info (cf. above)
    * Topic classification: CAP categories do not map very well to 17th century
      * Maybe look at https://huggingface.co/datasets/oberbics/Topic-specific-genre-classification_german_historical-newspapers
    * Linguistic annotation
      * We have training data for PoS and Lemma.
        * Tagset is different but features can be converted to UD
        * Accuracy is reasonable, cf https://couranten.ivdnt.org/blacklab-frontend/couranten/about
      * We have no relevant training material for syntax
      * We  have some for NER of historical dutch, but may have to supplement some for the newspapers
  
* Convert/supplement metadata to common scheme. Looks like this now:
  ```xml
        <sourceDesc>
          <bibl>
            <title level="j">Oprechte Haerlemsche courant</title>
            <title level="s">ENGELANDT, &amp;C.</title>
            <title level="a">Londen den 9 November.</title>
            <publisher>Ghedruckt tot Haerlem, by ABRAHAM CASTELEYN, StadtsDrucker, op de Maerckt, in de Blye Druck. Den 15 November, Anno 1670.</publisher>
            <date when="1670-11-15">1670-11-15</date>
            <idno type="URN">ddd:010926959:mpeg21:a0003</idno>
            <idno type="URI" subtype="URL">https://www.delpher.nl/nl/kranten/view?coll=ddd&amp;identifier=ddd:010926959:mpeg21:a0003</idno>
          </bibl>
        </sourceDesc>
  ```

   * `<title level='s'>` indicates a section above article level
   * `<publisher>` now contains the colophon. TEI element colophon needs msItem or msItemStruct which seems awkward

  

  

