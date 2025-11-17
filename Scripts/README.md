# PressMint scripts

This directory contains the scripts that are used to validate or
convert PressMint XML corpora to other formats. Most scripts have an
explanation of how to run them in comments and the start of the
script. Note that these scripts should be typically run via the repository
[Makefile](../Makefile); for instructions how to use it, pls. see the
repository [CONTRIBUTING](../CONTRIBUTING.md) file.

The main scripts are listed below, although there also exist other, maintenance scripts.

## Validation

* [validate-pressmint.pl](validate-pressmint.pl): Perl script that
  runs all the validation scripts below
* [validate-pressmint.xsl](validate-pressmint.xsl): checks for common
  encoding or metadata mistakes
* [check-links.xsl](check-links.xsl):checks that all IDs that are referred to actually exist
* [pressmint2root.xsl](pressmint2root.xsl): not strictly validation (altough the result can be used for such), makes the PressMint corpus root files [PressMint.xml](../PressMint.xml) and [PressMint.ana.xml](../PressMint.ana.xml) on the basis of the individual corpora roots.

## Conversion

* [pressmint-tei2text.xsl](pressmint-tei2text.xsl): transforms a PressMint corpus component file to plain text
* [pressmint2conllu.pl](pressmint2conllu.pl): runs the pressmint2conllu XSLT script as well as running the
  UD validator on the resulting files. Not that it is assumed that this directory contains (gitignored) the UD  validator, which is installed with `git clone git@github.com:UniversalDependencies/tools.git`
* [pressmint2conllu.xsl](pressmint2conllu.xsl): convert the linguistically annotated TEI corpus
  component to CoNLL-U format. It expects the TEI root corpus file as the value of the `$meta` parameter.
* [pressmint2xmlvert.xsl](pressmint2xmlvert.xsl): convert the linguistically annotated TEI corpus compoment to
  vertical format for the CQP line of concordancers.
  It expects the TEI root corpus file as the value of the `hdr`
  parameter. Note that the produced files is still in XML - to convert it to "proper"
  vertical format, use `pressmint-xml2vert.pl`.
* [corpus2sample.xsl](corpus2sample.xsl): takes a root corpus file as input and outputs a sample in output 
  directory, which is specified via the `$outDir` parameter. The script retains the
  first and last component file from the corpus, and first and last $Range utterances in them.

