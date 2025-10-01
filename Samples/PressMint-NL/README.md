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

    The texts in the corpus have the following metadata:

   - pid
   - sourceID
   - witnessYearLevel1_from
   - decade
   - witnessDateLevel1_from
   - witnessDateLevel2_from
   - witnessMonthLevel1_from
   - witnessDayLevel1_from
   - witnessYearLevel1_to
   - witnessMonthLevel1_tp
   - witnessDayLevel1_to
   - witnessYearLevel2_from
   - witnessMonthLevel2_from
   - witnessDayLevel2_from
   - witnessYearLevel2_to
   - witnessMonthLevel2_to
   - witnessDayLevel2_to
   - sourceUrl
   - corpusProvenance
   - editorLevel3
   - articleClass
   - titleLevel2
   - newspaperSection
   - titleLevel1
   - settingLocation_country
   - settingLocation_place
   - colophon

* __Format__: TEI-ish (not validated)


* __Facsimile__: Link to page facsimile at the National Library of the Netherlands for each article

## Conversion plan

For the PressMint-NL corpus we plan to:
* Convert to the PressMint TEI scheme
* Convert/supplement metadata to commont scheme
* Find the best feasible way to convert/add linguistical annotation according to UD

