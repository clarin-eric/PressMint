# PressMint Build directory

This directory contains the build environemnt for a release, i.e. the input data sources, the output
distribution-ready corpora, and the dedicated scripts.

Note that the complete corpora are to large to be stored on GitHub, so most of the data files are gitignored.

Here you can find the following directories:

* [Sources-TEI/](Sources-TEI/): source PressMint TEI encoded corpora
  (input to the release pipeline for PressMint)
* [Sources-Distro/](Sources-Distro/): supplementary documents included with a PressMint release
* [Taxonomies/](Taxonomies/): directory for development of common taxonomies
* [Makefile](Makefile): targets with the release pipeline
* [Scripts/](Scripts/): local scripts used for preparing a PressMint release
* [Logs/](Logs/): logs of the pipeline used to prepare a PressMint release
* [Distro/](Distro/): distribtion directory with corpora ready for a PressMint release
  (output of the release pipeline)
* [Packed/](Packed/): distribution corpora packed (i.e. compressed) for a PressMint release on a CLARIN repository
* [Metadata/](Metadata/): automatically generated metadata of the corpus
* [Verts/](Verts/): distribution vertical files joined together into one file per corpus, ready for importing to the concordancers
* [Test/](Test/): directory for test data, used for debugging the release pipeline
* [Temp/](Temp/): directory for temporary files, used in the release pipeline
