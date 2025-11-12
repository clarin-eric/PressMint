########### Makefile for making a distributable version of the PressMint TEI and TEI.ana corpora and metadata overviews
#### Variables give the included countries, version, handle, paths and scripts to use
#### make nohup1 starts make all and saves the log in Logs/ 
#### make all builds the plain text and linguistically annotated corpora
#### and there are a lot of test- targets to test various parts of the build.

### VARIABLES

### COMPLETE SET OF CORPORA
CORPORA=AT BG CZ ES GR IS LV NL PL SI UA
CORPORA=SI

# Used in targets that run only on one corpus
CORPUS=SI

# Version number and PID of next PressMint release
VERSION = 1.0
HANDLE-TEI = http://hdl.handle.net/11356/2067
HANDLE-ANA = http://hdl.handle.net/11356/2068

#Absolute paths are needed otherwise problems with XSLT
PRESSMINT := $(shell realpath .. | tr -d '\n')# get real absolute path to PressMint directory
HERE = ${PRESSMINT}/Build
TEMP = ${HERE}/Temp
SCH = ${PRESSMINT}/TEI
# Where the submitted corpora are found: PressMint-XX.TEI/ and PressMint-XX.TEI.ana
SOURCES = ${HERE}/Sources-TEI
# Where the polished corpora in TEI and derived formats are output
OUTPUTS = ${HERE}/Distro

#Where the produced corpora are put for inspection
WEB = tomaz@nl.ijs.si:/home/tomaz/www/tmp/PressMint

##Note that script variables are at the end of the Makefile!

###### Targets

### Overviews to be put in Metadata/
### This should be done once all the corpora have been built
metadata:	metadata-quant-tsv metadata-quant-tex
#Make overview LaTeX tables
metadata-quant-tex:
	$s mode=tex -xsl:Scripts/pressmint2cnt-overview.xsl   Distro/PressMint.xml > Metadata/PressMint-overview-stats.tex
	$s mode=tex -xsl:Scripts/pressmint2cnt-speeches.xsl   Distro/PressMint.xml > Metadata/PressMint-speeches-stats.tex
#Make overview TSV tables
metadata-quant-tsv:
	$s mode=tsv -xsl:Scripts/pressmint2cnt-overview.xsl   Distro/PressMint.xml > Metadata/PressMint-overview-stats.tsv
	$s mode=tsv -xsl:Scripts/pressmint2cnt-speeches.xsl   Distro/PressMint.xml > Metadata/PressMint-speeches-stats.tsv

### Make overall root(.ana) for PressMint for Sources-TEI/ and Distro/, 
### This should be done once all the corpora have been built
all-roots:	source-roots master-roots
source-roots:
	$s base=${SOURCES} type=TEI -xsl:../Scripts/pressmint2root.xsl \
	../Scripts/PressMint-rootTemplate.xml > ${SOURCES}/PressMint.xml
	$s base=${SOURCES} type=TEI.ana -xsl:../Scripts/pressmint2root.xsl \
	../Scripts/PressMint-rootTemplate.xml > ${SOURCES}/PressMint.ana.xml
master-roots:
	$s base=${OUTPUTS} type=TEI -xsl:../Scripts/pressmint2root.xsl \
	../Scripts/PressMint-rootTemplate.xml > ${OUTPUTS}/PressMint.xml
	$s base=${OUTPUTS} type=TEI.ana -xsl:../Scripts/pressmint2root.xsl \
	../Scripts/PressMint-rootTemplate.xml > ${OUTPUTS}/PressMint.ana.xml

###### Various tests over 1 corpus
make-1:
	${FINALIZE} -all -codes ${CORPUS} -in ${SOURCES} -out ${OUTPUTS}
make-1-sample:
	${FINALIZE} -sample -codes ${CORPUS} -in ${OUTPUTS} -out ${OUTPUTS}
make-1-text:
	${FINALIZE} -txt -codes ${CORPUS} -in ${OUTPUTS} -out ${OUTPUTS}
make-1-vert:
	${FINALIZE} -vert -codes ${CORPUS} -in ${OUTPUTS} -out ${OUTPUTS}
make-1-conll1:
	${FINALIZE} -conll -codes ${CORPUS} -in ${OUTPUTS} -out ${OUTPUTS}
make-1-tei:
	${FINALIZE} -ana -tei -valid -codes ${CORPUS} -in ${SOURCES} -out ${OUTPUTS}

test-text:
	../Scripts/pressmintp-tei2text.pl -jobs 2 -in ${OUTPUTS}/PressMint-${CORPUS}.TEI -out Test
test-meta:
	$s out-lang=en meta=${OUTPUTS}/PressMint-${CORPUS}.TEI/PressMint-${CORPUS}.xml -xsl:../Scripts/pressmint2meta.xsl \
	${HERE}/Test/test.xml > Test/test.tei.tsv
	$s out-lang=en meta=${OUTPUTS}/PressMint-${CORPUS}.TEI/PressMint-${CORPUS}.xml -xsl:../Scripts/pressmint2meta.xsl \
	${HERE}/Test/test.ana.xml > Test/test.ana.tsv
test-vert:
	$s meta=${OUTPUTS}/PressMint-SI.TEI.ana/PressMint-SI.ana.xml \
	-xsl:../Scripts/pressmint2xmlvert.xsl  ${HERE}/Test/test.ana.xml > Test/test.vert
test-conll2:
	../Scripts/pressmintp2conllu.pl -jobs 1 -in ${HERE}/PressMint-${CORPUS}.TEI.ana -out ${HERE}/Test
test-conll1:
	$s meta=${OUTPUTS}/PressMint-SI.TEI.ana/PressMint.ana.xml \
	-xsl:../Scripts/pressmint2conllu.xsl ${HERE}/Test/test.ana.xml > Test/test.conllu
test-valid:
	${FINALIZE} -valid -codes ${CORPUS} -in ${OUTPUTS} -out ${OUTPUTS}
test-release:
	$s anaDir=${OUTPUTS}/PressMint-${CORPUS}.TEI.ana outDir=Test -xsl:../Scripts/pressmint2release.xsl \
	${HERE}/PressMint-${CORPUS}.TEI/PressMint-${CORPUS}.xml

##########################

# Post-hoc copy READMEs to master, in case they need to be changed after the corpora have been built
cp-readmes:
	Scripts/cp-readmes.pl -codes "${CORPORA}" -version ${VERSION} -teihandle ${HANDLE-TEI} -anahandle ${HANDLE-ANA} \
	-docs Sources-Distro -out ${OUTPUTS}

# Make samples only
all-samples:	samples cp-samples
samples:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -sample -codes $${CORPUS} -in ${SOURCES} -out ${OUTPUTS} 2> Logs/PressMint-$${CORPUS}-samples.log; \
	done;
#Merge original and MTed samples into official Samples directory
cp-samples:
	Scripts/cp-samples.pl 'Distro/PressMint-*' ../Samples


# Make vertical file with en metadata, a hack:
XX-CORPORA=AT-xx BG-xx CZ-xx ES-xx GR-xx IS-xx LV-xx NL-xx PL-xx SI-xx UA-xx
make-verts-xx-nohup:
	nohup time make make-verts-xx > Logs/PressMint-Verts-xx.log &
make-verts-xx:
	for CORPUS in ${CORPORA}; do \
        ../Scripts/pressmintp-tei2vert-xx.pl -jobs ${THREADS} \
        -in ${OUTPUTS}/PressMint-$${CORPUS}.TEI.ana -out Temp/PressMint-$${CORPUS}-xx.vert; \
	done;
	perl ../Scripts/join-all-verts.pl -codes '${XX-CORPORA}' -in 'Temp' -out Verts/PressMint-XX.${VERSION}.vert

# Make vertical files only
make-verts:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -vert -codes $${CORPUS} -in ${SOURCES} -out ${OUTPUTS}; \
	done;
	make verts

# Put logs and packed build to web for inspection by corpus compilers
web-nohup:
	nice nohup time make web > PressMint-Web.log &
web:
	rsync -av Logs/*.log ${WEB}/Logs
	rsync -av Packed/*.tgz ${WEB}/Repo


###### Targets for producing releasable version of PressMint corpora
FINALIZE = perl ../Scripts/pressmint2distro.pl -version ${VERSION} -teihandle ${HANDLE-TEI} -anahandle ${HANDLE-ANA} -schema ${SCH} -docs Sources-Distro -procMemGB ${JAVA-MEMORY} -procChunkSize ${CHUNK-SIZE} -procThreads ${THREADS}

### For real
nohup:
	nice nohup time make all > Logs/PressMint.log &
all:	final join-verts pack
xall:	final join-verts pack

pack-logs:
	mkdir -p Packed/PressMint-logs
	rm -f Packed/PressMint-logs/*
	for CORPUS in ${CORPORA}; do \
	cp Logs/PressMint-$${CORPUS}.*log Packed/PressMint-logs; \
	done
	cd Packed; tar -czf PressMint-logs.tgz PressMint-logs
	rm -fr Packed/PressMint-logs
	mkdir -p Packed/PressMint-en-logs
	rm -f Packed/PressMint-en-logs/*

pack:
	perl Scripts/pack-pressmint.pl -codes '${CORPORA}' -in Distro -out Packed
join-verts:
	perl Scripts/join-verts.pl -version ${VERSION} -codes '${CORPORA}' -in Distro -out Verts
final:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -all -codes $${CORPUS} -in ${SOURCES} -out ${OUTPUTS} 2> Logs/PressMint-$${CORPUS}.log; \
	grep -a -i 'fatal' Logs/PressMint-$${CORPUS}.log >  Logs/PressMint-$${CORPUS}.error.log;  \
	grep -a -i 'error' Logs/PressMint-$${CORPUS}.log >> Logs/PressMint-$${CORPUS}.error.log;  \
	grep -a -i 'warn'  Logs/PressMint-$${CORPUS}.log >  Logs/PressMint-$${CORPUS}.warn.log;  \
	echo "$${CORPUS}.warn"; \
	cat Logs/PressMint-$${CORPUS}.warn.log | wc -l;  \
	cat Logs/PressMint-$${CORPUS}.warn.log | sort | uniq | wc -l;  \
	echo "$${CORPUS}.error"; \
	cat Logs/PressMint-$${CORPUS}.error.log | wc -l;  \
	cat Logs/PressMint-$${CORPUS}.error.log | sort | uniq | wc -l;  \
	done;

# Join all verts, probably doesn't work
join-all-verts:
	perl ../Scripts/join-all-verts.pl -codes '${CORPORA}' -in 'Distro' -out Verts/PressMint-XX.${VERSION}.vert

###################### SCRIPT VARIABLES
#Set java memory maxsize in GB
JAVA-MEMORY=480
JM := $(shell test -n "$(JAVA-MEMORY)" && echo -n "-Xmx$(JAVA-MEMORY)g")

CHUNK-SIZE=500
THREADS=10

P = parallel --citation --gnu --halt 2
#Run java with a large heap, as a complete corpus needs to be read in
s = java -jar $(JM) ../Scripts/bin/saxon.jar
j = java -jar ../Scripts/bin/jing.jar

pm = $j ${SCH}/PressMint.odd.rng 	        # Validate with PressMint ODD
