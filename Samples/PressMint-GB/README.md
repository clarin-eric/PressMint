# Samples of the PressMint-GB corpus

This directory contains a PressMint TEI sample for Great Britain, generated from the British Library / Living with Machines `Widnes Examiner` plaintext and metadata files.

## Source

- Newspaper: Widnes Examiner
- Place of publication: Widnes, Cheshire, England
- Source page or dataset URL: https://bl.iro.bl.uk/concern/datasets/96c2c510-5b7b-4bea-97af-ca2c6bee26be
- Corpus ID: PressMint-GB
- Components generated: 747
- Source items processed: 76043

## Generated structure

- `PressMint-GB.xml`: corpus root file with XInclude links to issue components.
- `YYYY/`: issue-level TEI component files.
- `Sources/`: conversion manifest used for traceability.

## Validation

From the PressMint repository root, run:

```bash
make validate-TEI-GB
```

Review the `Sources/metadata/pressmint_gb_manifest.tsv` file before submission, especially skipped OCR fragments and licensing notes.
