check: prepare val-odd html mount

# Validate and compile ODD to RelaxNG, validate samples, make HTML
all:	prepare val-odd xml-schemas
xall:	prepare val-odd xml-schemas val-samples html

# Builds html and pushes it
deploy:	html
	git commit -m "Deploy GitHub pages" ../docs
	git push

# Put the docs directory somewhere where the HTML can be viewed
# This is a local thing!
mount:
	rsync -a ../docs/ tomaz@nl.ijs.si:/home/tomaz/www/tmp/PressMint/Pages

# PressMint TEI documentation and schema, as expanded by prepare target
ODD = tmp/PressMint.xml

# The infamous TEI P5 subset from the Guidelines, either local or from the Web
SUBSET = --localsource=p5subset.xml
#SUBSET = --localsource=https://tei-c.org/release/xml/tei/odd/p5subset.xml

# Location and directory name of the profile for conversion to HTML
PROFILE = --profiledir=$(shell pwd) --profile=profile

# Convert to HTML
html:	prepare val-schema
	Stylesheets/bin/teitohtml ${PROFILE} --odd ${SUBSET} ${OUTPUT} ${ODD} ../docs/index.html

# Compile schemas to RelaxNG, DTD and XSD; best use the RelaxNG one.
xml-schemas:	val-odd
	Stylesheets/bin/teitorng        ${SUBSET} ${ODD} PressMint.odd.rng
	Stylesheets/bin/teitornc        ${SUBSET} ${ODD} PressMint.odd.rnc

val:	val-odd val-samples
val-odd:
	$j tei_odds.rng tmp/PressMint.xml
	$s -xsl:../Scripts/check-links.xsl tmp/PressMint.xml

# Validate samples
DATA = ../Samples
val-samples:
	./validate.pl samples ${DATA}

# Make one file from the ODD
prepare: 
	rm -f tmp/*
	$s -xi -xsl:copy-odd.xsl PressMint.odd.xml > tmp/PressMint.xml

# Initialise
setup:
	mkdir -p tmp
	git -C ../Scripts clone git@github.com:TEIC/Stylesheets.git

#Prerequisites
s = java -jar ../Scripts/bin/saxon.jar
j = java -jar ../Scripts/bin/jing.jar
