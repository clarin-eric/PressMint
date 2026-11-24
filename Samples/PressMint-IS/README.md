# Samples of the PressMint-IS corpus

## Data source

The source of the PressMint-IS corpus is **MC-19v2**, a corpus of Icelandic newspapers and periodicals compiled at the [Árni Magnússon Institute for Icelandic Studies](https://www.arnastofnun.is) from the page images published by the National and University Library of Iceland (Landsbókasafn Íslands - Háskólabókasafn) at [timarit.is](https://timarit.is). The PressMint part contains the issues from 1870 to 1920 of the 58 newspapers selected for the Icelandic part of PressMint.

### Details of the source:

* __Source__: Page images (JPEG) of newspaper issues digitised by the National and University Library of Iceland and published at [timarit.is](https://timarit.is). The images were OCR-ed anew for MC-19 (see *Correction*).

* __Content__: Icelandic newspapers published 1870-1920, and other publications tagged with the keyword 'news' by the national library and having at least 12 issues per year. 58 titles.

* __Size__: 58 publications, 27,040 issues, 107,152 pages and approximately 127.8 million words. The sample issue (*Bjarki*, no. 28, 14 July 1900) has 4 pages, 176 paragraphs and headings, 378 sentences, 5,505 words and 6,324 tokens.

* __Structure__: Each issue is one TEI file. The text is divided into pages, and each page into units (news, advertisements, notices, mastheads, listings ...) found by a combination of layout analysis and using an LLM (Gemma-4-31B) to combine columns into articles and to categorize the texts. Units continued on a later page are linked with `@prev`/`@next`. Units contain headings and paragraphs, which are split into sentences and tokens. Each unit has a category (e.g. `news.foreign`, `opinion.column`, `advertisement.display`), and articles have free topic keywords.

* __Correction__: OCR with [dots.ocr](https://huggingface.co/dots-studio/dots.mocr) on the whole page image. The OCR text was then checked by an ensemble of independent readings of each text line (three Tesseract models, Calamari, and dots.ocr on the cropped line): a word is changed only when independent engines agree on the same different word and the page-level model was not confident, with a guard that protects old spellings. No language model was used in the correction. Blank pages with show-through print were removed. The corrected text has **not** been proofread and contains OCR errors.

* __Linguistic annotation__: The running text is in the original spelling. Each word also has an automatically modernised form (present-day standard spelling), and the annotation is made on the modernised text: lemmas, MIM-GOLD (IFD) PoS tags, UD part-of-speech and features, UD dependencies, and named entities (PER, LOC, ORG, MISC). Modernisation typically covers *je*-spelling (*jeg, hjer, sjer, fjelag, brjef* > *ég, hér, sér, félag, bréf*), *í/ú/á/ei/au* before *ng/nk* (*þíng, lángt, úngir, einginn, aungvan* > *þing, langt, ungir, enginn, engan*), *alt* > *allt*, *-st/-nst* and similar. In the sample issue 506 words have a modernised form, and in 30 cases modernisation changes the number of words (e.g. *fyrirfram* > *fyrir fram*, *o. s. frv.* > *o.s.frv.*). The modernisation makes errors, e.g. in the sample *aunga/aungar* > *unga/ungar* (should be *enga/engar*), *frjetst* > *frjálst* (*frést*), *smjer* > *sér*, *þeóríum* > *þóríum*. Further work includes trying to improve the modernisation.

* __Metadata__:

    The texts (issues) in the corpus have the following metadata:

    - Document ID (MC-19 ID, from the timarit.is publication and issue IDs, e.g. `MC19v2-28-51276`)
    - Title of the newspaper
    - Issue (number and date as printed, e.g. *28. tölublað (14.07.1900)*)
    - Date of publication (ISO 8601)
    - URL of the issue and of the publication at timarit.is
    - Number of words, tokens, sentences and pages

    Each page has:

    - Printed page number
    - Image ID at timarit.is, and URL of the page at timarit.is

    Each unit has:

    - Type (article, ad, notice, listing, masthead) and category (from the MC-19 category taxonomy)
    - Link to the preceding / following part, if continued on another page
    - Topic keywords (articles)

* __Format__: TEI XML, in three variants per issue: annotated (original spelling in the text, modern form in `w/@norm`, or in `choice/orig`+`reg` when the number of words differs), and two unannotated, sentence-aligned texts, one in the original and one in modernised spelling. Below is the start of the annotated sample (`linkGrp` with dependencies shortened):

    ```xml
    <pb n="109" xml:id="p48414191" facs="https://timarit.is/page/953715"/>
    <div type="masthead" xml:id="a48414191-0" ana="#cat.masthead">
      <p xml:id="a48414191-0.1"><s xml:id="a48414191-0.1.s1">
        <w xml:id="a48414191-0.1.w1" lemma="einn" pos="tfhen" msd="UPosTag=DET|Case=Nom|Gender=Neut|Number=Sing|NumType=Card">Eitt</w>
        <w xml:id="a48414191-0.1.w2" lemma="blað" pos="nhen" msd="UPosTag=NOUN|Case=Nom|Definite=Ind|Gender=Neut|Number=Sing">blað</w>
        ...
        <w xml:id="a48414191-0.1.w5" norm="minnst" lemma="minna" pos="sþmhen" msd="UPosTag=DET|Voice=Mid">minst</w>
        <pc xml:id="a48414191-0.1.w6" pos="pl" msd="UPosTag=PUNCT">.</pc>
        <linkGrp targFunc="head argument" type="UD-SYN">...</linkGrp></s>
        ...
        <choice><orig><w>fyrirfram</w></orig><reg><w xml:id="a48414191-0.1.w21" lemma="fyrir" pos="aa" msd="UPosTag=ADP">fyrir</w> <w xml:id="a48414191-0.1.w22" lemma="fram" pos="aa" msd="UPosTag=ADP">fram</w></reg></choice>
    ```

* __Facsimile__: The page images are available at timarit.is, directly as JPEG at
  `https://timarit.is/files/<image ID>` (e.g. [https://timarit.is/files/48414191](https://timarit.is/files/48414191)).

## Sample files

* `Sources/` - the sample issue *Bjarki*, no. 28, 14 July 1900 ([timarit.is/issue/51276](https://timarit.is/issue/51276)),
  converted to PressMint TEI (first version, see below):
    - `PressMint-IS_1900-07-14-Bjarki-51276.xml` - the unannotated text, in the original spelling;
    - `PressMint-IS_1900-07-14-Bjarki-51276.ana.xml` - the linguistically annotated text.

## Conversion plan

For the PressMint-IS corpus we convert the MC-19 v2 TEI to PressMint TEI with a script; a first version has been run on the sample. The conversion:

* makes one PressMint component per issue, named `PressMint-IS_<date>-<newspaper>-<timarit.is issue ID>`;
* keeps the original spelling in the text of the plain-text (`.xml`) version, and adds the linguistic annotation to the `.ana.xml` version: lemma, UD part-of-speech and features (`@msd`), MIM-GOLD tag (`@pos`), named entities (`<name>`), and spacing from the original text (`@join`);
* keeps the modernised form in `w/@norm`; where modernisation changes the number of words, it uses nested `<w>` elements as described in the PressMint guidelines (section *Syntactic words*): 
  `<w>fyrirfram<w norm="fyrir" lemma="fyrir" .../><w norm="fram" lemma="fram" .../></w>` and `<w norm="o.s.frv." lemma="o.s.frv." ...><w>o.</w><w>s.</w><w>frv.</w></w>`;
* maps the units to `div` elements: masthead at the top to `front/div[@type="banner"]`, masthead at the end to `back/div[@type="colophon"]`, advertisements to `back/div[@type="advertisement"]`, articles, notices and listings to `body/div[@type="article"]`; the MC-19 category is kept in `div/@ana`, pointing to `PressMint-IS-taxonomy-category.xml`;
* joins units continued on the next page into one `div` (with a `<pb/>` inside), when no other unit comes in between;
* links every page break to its page image at timarit.is (`pb/@facs`); there is no `<facsimile>` and no coordinates.

Open questions / still to do:

* UD dependency relations are in MC-19 but are dropped, as the PressMint schema has no `linkGrp` yet. We would like to keep them (as in ParlaMint).
* The topic keywords of MC-19 are free keywords and are not yet mapped to the PressMint topic taxonomy.
* Two units in the sample continue on the next page but have another unit (a short notice) between the parts; these are kept as separate `div`s, as `div` cannot have `@prev`/`@next` in PressMint.
* A modernised variant (`PressMint-IS-modern`) could be made from the modernised text, if wanted.
