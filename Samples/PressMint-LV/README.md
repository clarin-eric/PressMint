# Samples of the PressMint-LV corpus

## Data source

The source of the PressMint-LV corpus will be digitized historical newspaper "Jaunākās ziņas" (1911-1940) from the collection of National Library of Latvia.

### Details of the source:

* __Source__: The paper issues have been scanned and OCR-ed with both Tesseract 3.02 and ABBYY Finereader 12.0.

* __Availability__: The issues are available at [https://periodika.lndb.lv/](https://periodika.lndb.lv/#periodicalItem:1330)

* __Content__: The daily newspaper "Jaunākās Ziņas", published in Latvia from 1911 to 1940.

* __Size__: Around 8,700 issues, 388,000 articles.

* __Structure__: The corpus is structured into issues, pages and articles.

* __Correction__: The OCR-ed texts contain a significant amount of errors. The language has been modernized and many errors corrected using the multimodal Gemini 2.5 Flash model. The prompt is provided at the end of this file.

* __Linguistic annotation__: The texts can be linguistically annotated using modern processing pipelines with good precision, since the texts are modernized.

* __Metadata__: 
    Each article contains:
    - URI
    - Volume number
    - Issue number
    - Date of publication in iso8601 (yyyymmdd)
    - Title
    - Subheadline (if available)
    - Section (if available)
    - Author (if available)

* __Format__: The OCR-ed text is available in ALTO XML format. Individual articles are extracted in txt format and then further corrected.

* __Facsimile__: The image files for complete texts are available as JPEGs. 

## Conversion plan

For the PressMint-LV corpus we plan to automatically annotate the data and prepare it in PressMint format, retaining all available metadata. We do not plan to introduce new metadata.

## Prompt for multimodal Gemini 2.5 Flash model

```
messages = [
    {
        "role": "system",
        "content": "You are a linguist interested in intrinsics of all aspects of language."
    },
    {
        "role": "user",
        "content": [
            {
                "type": "text",
                "text": (
                    f"You are a linguist and OCR expert. Your task is to improve the OCR quality of text while adhering strictly to the following rules. "
                    f"Use the provided image of the original newspaper page (page {page_number}) to guide your corrections.\n\n"
                    f"Improve the OCR quality and normalize the following text to modern Latvian both in metadata and following text"
                    f"so that its meaning resembles the original text in the newspaper as closely as possible. Do not change the text otherwise. "
                    f"Very important: Do not add any interpretations, explanations to text or metadata, information about structure in the output files. "
                    f"Ensure the output is plain text unless otherwise specified. "
                    f"Preserve the line breaks and metadata structure as they are in plaintext provided. Do not merge lines or paragraphs. It is better to have more lines than less. "
                    f"It is better to add empty lines after paragraphs than let them touch or merge. "
                    f"Ensure that output files do not contain any other information that the plaintext provided - it should not include same paragraphs that appears in other files. "
                    f"In metadata, modernize only the content after the colon in metadata lines. "
                    f"Here is the text:\n\n{plaintext}"
                ),
            },
            {
                "type": "image_url",
                "image_url": {"url": data_url},
            },
        ],
    }
]

payload = {
    "model": "google/gemini-2.5-flash-preview",
    "messages": messages,
}
```
