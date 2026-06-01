SHELL := /bin/bash

XML_FILES := $(wildcard 1884/*.xml)

TXT_FILES  := $(XML_FILES:.xml=.txt)
TSV_FILES  := $(XML_FILES:.xml=-meta.tsv)
VERT_FILES := $(XML_FILES:.xml=.vert)

SAXON := java -jar ../../Scripts/bin/saxon.jar

.PHONY: all clean

all: $(TXT_FILES) $(TSV_FILES) $(VERT_FILES)

1884/%.txt: 1884/%.xml
	$(SAXON) -xsl:../../Scripts/pressmint-tei2text.xsl $< > $@

1884/%-meta.tsv: 1884/%.xml
	$(SAXON) -xsl:../../Scripts/pressmint2meta.xsl $< > $@

1884/%.vert: 1884/%.xml
	perl ../../Scripts/pressmint-xml2vert.pl $< > $@

clean:
	rm -f 1884/*.txt 1884/*-meta.tsv 1884/*.vert
