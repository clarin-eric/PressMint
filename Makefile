.DEFAULT_GOAL := help

PRESS := AT BG CZ ES GR IS LV NL PL SI

##$JAVA-MEMORY## Set a java memory maxsize in GB
JAVA-MEMORY =
JM := $(shell test -n "$(JAVA-MEMORY)" && echo -n "-Xmx$(JAVA-MEMORY)g")
PARALLEL-JOBS = 10

LANG-LIST =
leftBRACKET := (
rightBRACKET := )
LANG-CODE-LIST := $(shell echo "$(LANG-LIST)" | sed "s/$(leftBRACKET)[^$(rightBRACKET)]*$(rightBRACKET),*/ /g" | tr -s " " | sed 's/ $$//' )

TAXONOMIES-TRANSLATE-INTERF = NER.ana
TAXONOMIES-TRANSLATE = $(addprefix PressMint-taxonomy-, $(TAXONOMIES-TRANSLATE-INTERF))

TAXONOMIES-COPY-INTERF =
TAXONOMIES-COPY = $(addprefix PressMint-taxonomy-, $(TAXONOMIES-COPY-INTERF))


-include Makefile.local



##$DATADIR## Folder with country corpus folders. Default value is 'Samples'.
DATADIR = Samples
DATACORPORADIR = Build/Distro
SHARED = Build

ROOT_FORMATS := TEI TEI.ana

# Generate PATHROOT_{TEI,TEI.ana}_XX = $(DATADIR)/PressMint-XX/PressMint-XX{,.ana}.xml
$(foreach f,$(ROOT_FORMATS), $(foreach c,$(PRESS), $(eval PATHROOT_$(f)_$(c) := $(DATADIR)/PressMint-$(c)/PressMint-$(c)$(subst TEI,,$(f)).xml) ) )

# Generate PATHBASE_{TEI,TEI.ana}_XX = $(DATADIR)/PressMint-XX
$(foreach f,$(ROOT_FORMATS), $(foreach c,$(PRESS), $(eval PATHBASE_$(f)_$(c) := $(DATADIR)/PressMint-$(c)) ) )



###### Setup
## check-prereq ## test if prerequisities are installed, more about installing prerequisities in CONTRIBUTING.md file
check-prereq:
	@uname -a|grep -iq ubuntu || \
	  ( echo -n "WARN: not running on ubuntu-derived system: " && uname -a )
	@echo -n "Saxon: "
	@test -f ./Scripts/bin/saxon.jar && \
	  unzip -p ./Scripts/bin/saxon.jar META-INF/MANIFEST.MF|grep 'Main-Class:'| grep -q 'net.sf.saxon.Transform' && \
	  echo "OK" || echo "FAIL"
	@echo -n "Jing: "
	@test -f ./Scripts/bin/jing.jar && \
	  unzip -p ./Scripts/bin/jing.jar META-INF/MANIFEST.MF|grep 'Main-Class:'| grep -q 'relaxng' && \
	  echo "OK" || echo "FAIL"
	@which parallel > /dev/null && \
	  echo "parallel: OK" || echo "WARN: command parallel is missing"
	@echo "INFO: Maximum java heap size (saxon needs 5-times more than the size of processed xml file)$(JM)"
	@java $(JM) -XX:+PrintFlagsFinal -version 2>&1| grep " MaxHeapSize"|sed "s/^.*= *//;s/ .*$$//"|awk '{print "\t" $$1/1024/1024/1024 " GB"}'
	@echo "INFO: Setup guide in CONTRIBUTING.md file"


setup-press:
ifndef PRESS-CODE
	$(error PRESS-CODE is not set - use "make TARGET PRESS-CODE='<CODE>'" )
endif
ifndef PRESS-NAME
	$(error PRESS-NAME is not set - use "make TARGET PRESS-NAME='<COUNTRY>'" )
endif
ifndef LANG-LIST
	$(error LANG-LIST is not set - use "make TARGET LANG-LIST='<langcode1> (Language1), <langcode2> (Language2)'" )
endif
	test ! -d ./Samples/PressMint-$(PRESS-CODE)
	mkdir ./Samples/PressMint-$(PRESS-CODE)
	echo "# PressMint directory for samples of country $(PRESS-CODE) ($(PRESS-NAME))" > ./Samples/PressMint-$(PRESS-CODE)/README.md
	echo "## Languages: $(LANG-LIST)" >> ./Samples/PressMint-$(PRESS-CODE)/README.md
	echo "LANG-CODE-LIST=$(LANG-CODE-LIST)"
	make initTaxonomies-$(PRESS-CODE) PRESS="$(PRESS-CODE)" LANG-CODE-LIST="$(LANG-CODE-LIST)"
	git status ./Samples/PressMint-$(PRESS-CODE)/*


## initTaxonomies-XX ## initialize taxonomies in folder PressMint-XX
#### parameter LANG-CODE-LIST can contain space separated list of languages
initTaxonomies-XX = $(addprefix initTaxonomies-, $(PRESS))
$(initTaxonomies-XX): initTaxonomies-%: $(addprefix initTaxonomy-%--, $(TAXONOMIES-TRANSLATE)) $(addprefix copyTaxonomy-%--, $(TAXONOMIES-COPY))

# initTaxonomy-XX-tt = $(foreach X,$(PRESS),$(foreach Y,$(TAXONOMIES-TRANSLATE), initTaxonomy-$X-$Y))
initTaxonomy-XX-tt = $(foreach X,$(PRESS),$(addprefix initTaxonomy-${X}--, $(TAXONOMIES-TRANSLATE) ) )
$(initTaxonomy-XX-tt): initTaxonomy-%:
	@test -z "$(LANG-CODE-LIST)" && echo "WARNING: no language specified in " `echo -n '$*' | sed 's/^.*--//'` " taxonomy preparation" || echo "INFO: preparing " `echo -n '$*' | sed 's/^.*--//'` "taxonomy"
	@${s} langs="$(LANG-CODE-LIST)" $(TAXONOMYPARAMS)  pressmint="PressMint-"`echo -n '$*' | sed 's/--.*$$//'` -xsl:Scripts/pressmint-init-taxonomy.xsl \
	  ${SHARED}/Taxonomies/`echo -n '$*.xml' | sed 's/^.*--//'` \
		| ${formatAndPolish} \
	  > ${DATADIR}/PressMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'`

copyTaxonomy-XX-tt = $(foreach X,$(PRESS),$(addprefix copyTaxonomy-${X}--, $(TAXONOMIES-COPY) ) )
$(copyTaxonomy-XX-tt): copyTaxonomy-%:
	@echo "INFO: copying " `echo -n '$*' | sed 's/^.*--//'` "taxonomy"
	@${s} langs="$(LANG-CODE-LIST)" if-lang-missing="skip" -xsl:Scripts/pressmint-init-taxonomy.xsl \
	  ${SHARED}/Taxonomies/`echo -n '$*.xml' | sed 's/^.*--//'` \
	  > ${DATADIR}/PressMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'`

initTaxonomies4release-XX = $(addprefix initTaxonomies4release-, $(PRESS))
$(initTaxonomies4release-XX): initTaxonomies4release-%: $(addprefix initTaxonomy4release-%--, $(TAXONOMIES-TRANSLATE)) $(addprefix copyTaxonomy-%--, $(TAXONOMIES-COPY))


initTaxonomy4release-XX-tt = $(foreach X,$(PRESS),$(addprefix initTaxonomy4release-${X}--, $(TAXONOMIES-TRANSLATE) ) )
$(initTaxonomy4release-XX-tt): initTaxonomy4release-%:
	$(eval $@_XX := $(shell echo -n '$*' | sed 's/--.*$$//'))
	$(eval $@_tt := $(shell echo -n '$*' | sed 's/^.*--//'))
	$(eval $@_langs := $(shell grep 'PressMint-$($@_XX)$$' ${SHARED}/Taxonomies/taxonomy-translation-include.tsv|cut -f1|tr "\n" " "|sed "s/ $$//"))
	@echo "INFO: PressMint $($@_XX)"
	@echo "INFO: Taxonomy $($@_tt)"
	@echo "INFO: Languages $($@_langs)"
	make initTaxonomy-$($@_XX)--$($@_tt) LANG-CODE-LIST="$($@_langs)" TAXONOMYPARAMS='if-lang-missing="skip"'


translateTaxonomies-XX = $(addprefix translateTaxonomies-, $(PRESS))
$(translateTaxonomies-XX): translateTaxonomies-%: $(addprefix translateTaxonomy-%--, $(TAXONOMIES-TRANSLATE))


translateTaxonomy-XX-tt = $(foreach X,$(PRESS),$(addprefix translateTaxonomy-${X}--, $(TAXONOMIES-TRANSLATE) ) )
$(translateTaxonomy-XX-tt): translateTaxonomy-%:
	$(eval $@_XX := $(shell echo -n '$*' | sed 's/--.*$$//'))
	$(eval $@_tt := $(shell echo -n '$*' | sed 's/^.*--//'))
	$(eval $@_langs := $(shell grep 'PressMint-$($@_XX)$$' ${SHARED}/Taxonomies/taxonomy-translation-responsibility.tsv|cut -f1|tr "\n" " "))
	@echo "INFO: PressMint $($@_XX)"
	@echo "INFO: Taxonomy $($@_tt)"
	@echo "INFO: Languages $($@_langs)"
	@mkdir tmp || :
	@test -e `pwd`/${DATADIR}/PressMint-$($@_XX)${CORPUSDIR_SUFFIX}/$($@_tt).xml \
	|| echo -n "\nERROR: missing taxonomy  ${DATADIR}/PressMint-$($@_XX)${CORPUSDIR_SUFFIX}/$($@_tt).xml\n"
	@echo -n "INFO: validating translation taxonomy ${DATADIR}/PressMint-$($@_XX)${CORPUSDIR_SUFFIX}/$($@_tt).xml: " \
	&& ${val_taxonomy} ${DATADIR}/PressMint-$($@_XX)${CORPUSDIR_SUFFIX}/$($@_tt).xml \
	&& echo OK \
	&& echo "INFO: translating $($@_tt) taxonomy" \
	&& ${s} pressmint="PressMint-$($@_XX)${CORPUSDIR_SUFFIX}" \
	      translation-input=`pwd`/${DATADIR}/PressMint-$($@_XX)${CORPUSDIR_SUFFIX}/$($@_tt).xml  \
	      langs="$($@_langs) -" \
	      -xsl:Scripts/pressmint-add-translation-to-taxonomy.xsl \
	      ${SHARED}/Taxonomies/$($@_tt).xml \
		    | ${formatAndPolish} \
	      > tmp/temporary-taxonomy.xml \
	&& echo -n "INFO: validating output taxonomy with new translations: " \
	&& ${val_taxonomy} tmp/temporary-taxonomy.xml \
	&& echo OK \
	&& cp tmp/temporary-taxonomy.xml ${SHARED}/Taxonomies/$($@_tt).xml \
	|| echo -n "\nERROR: validations failed ${DATADIR}/PressMint-$($@_XX)${CORPUSDIR_SUFFIX}/$($@_tt).xml\n"


initTaxonomies4translation-XX = $(addprefix initTaxonomies4translation-, $(PRESS))
$(initTaxonomies4translation-XX): initTaxonomies4translation-%: $(addprefix initTaxonomy4translation-%--, $(TAXONOMIES-TRANSLATE))


initTaxonomy4translation-XX-tt = $(foreach X,$(PRESS),$(addprefix initTaxonomy4translation-${X}--, $(TAXONOMIES-TRANSLATE) ) )
$(initTaxonomy4translation-XX-tt): initTaxonomy4translation-%:
	$(eval $@_XX := $(shell echo -n '$*' | sed 's/--.*$$//'))
	$(eval $@_tt := $(shell echo -n '$*' | sed 's/^.*--//'))
	$(eval $@_langs := $(shell grep 'PressMint-$($@_XX)$$' ${SHARED}/Taxonomies/taxonomy-translation-responsibility.tsv|cut -f1|tr "\n" " "|sed "s/ $$//"))
	@echo "INFO: PressMint $($@_XX)"
	@echo "INFO: Taxonomy $($@_tt)"
	@echo "INFO: Languages $($@_langs)"
	make initTaxonomy-$($@_XX)--$($@_tt) LANG-CODE-LIST="$($@_langs)"


###### Validate

validate-XX = $(addprefix validate-, $(PRESS))
validate: $(validate-XX)
$(addprefix MSG-validate-start-, $(PRESS)): MSG-validate-start-%:
	@echo "INFO: $* validation start"

## validate-XX ## validate TEI and TEI.ana corpora
$(validate-XX): validate-%: MSG-validate-start-% validateTaxonomies-% validate-TEI-% validate-TEI.ana-%
	@echo "INFO: $* validation done"


validate-TEI-XX = $(addprefix validate-TEI-, $(PRESS))
validate-TEI: $(validate-TEI-XX)
$(addprefix MSG-validate-TEI-start-, $(PRESS)): MSG-validate-TEI-start-%:
	@echo "INFO: $* TEI validation start"

## validate-TEI-XX ## validate TEI corpus
$(validate-TEI-XX): validate-TEI-%: MSG-validate-TEI-start-% validate-TEI-root-% validate-TEI-comp-%
	@echo "INFO: $* TEI validation done"

## validate-TEI-root-XX ## validate TEI teiCorpus
$(addprefix validate-TEI-root-, $(PRESS)): validate-TEI-root-%:
	@echo "validating $(PATHROOT_TEI_$*)"
	@${val_root} $(PATHROOT_TEI_$*) \
	  || echo "ERROR: validating ($@) $(PATHROOT_TEI_$*) failed"

## validate-TEI-comp-XX ## validate TEI component files included in teiCorpus
$(addprefix validate-TEI-comp-, $(PRESS)): validate-TEI-comp-%:
	@echo "validating component files in $(PATHROOT_TEI_$*)"
	@echo $(PATHROOT_TEI_$*)|$(getcomponentincludes)| xargs -I {} ${val_comp} $(PATHBASE_TEI_$*)/{} \
	  || echo "ERROR: validating ($@) $(PATHROOT_TEI_$*) failed"


validate-TEI.ana-XX = $(addprefix validate-TEI.ana-, $(PRESS))
validate-TEI.ana: $(validate-TEI.ana-XX)
$(addprefix MSG-validate-TEI.ana-start-, $(PRESS)): MSG-validate-TEI.ana-start-%:
	@echo "INFO: $* TEI.ana validation start"

## validate-TEI.ana-XX ## validate-TEI.ana corpus
$(validate-TEI.ana-XX): validate-TEI.ana-%: MSG-validate-TEI.ana-start-% validate-TEI.ana-root-% validate-TEI.ana-comp-%
	@echo "INFO: $* TEI.ana validation done"

## validate-TEI.ana-root-XX ## validate TEI.ana teiCorpus
$(addprefix validate-TEI.ana-root-, $(PRESS)): validate-TEI.ana-root-%:
	@echo "validating $(PATHROOT_TEI.ana_$*)"
	@${val_root} $(PATHROOT_TEI.ana_$*) \
	  || echo "ERROR: validating ($@) $(PATHROOT_TEI.ana_$*) failed"

## validate-TEI.ana-comp-XX ## validate TEI.ana component files included in teiCorpus
$(addprefix validate-TEI.ana-comp-, $(PRESS)): validate-TEI.ana-comp-%:
	@echo "validating component files in $(PATHROOT_TEI.ana_$*)"
	@echo $(PATHROOT_TEI.ana_$*)|$(getcomponentincludes)| xargs -I {} ${val_comp} $(PATHBASE_TEI.ana_$*)/{} \
	  || echo "ERROR: validating ($@) $(PATHROOT_TEI.ana_$*) failed"


## validateTaxonomies-XX ## validate taxonomies in folder PressMint-XX
validateTaxonomies-XX = $(addprefix validateTaxonomies-, $(PRESS))
$(validateTaxonomies-XX): validateTaxonomies-%: $(addprefix validateTaxonomy-%--, $(TAXONOMIES-TRANSLATE)) validateTaxonomiesSpecific-%

validateTaxonomy-XX-tt = $(foreach X,$(PRESS),$(addprefix validateTaxonomy-${X}--, $(TAXONOMIES-TRANSLATE) ) )
$(validateTaxonomy-XX-tt): validateTaxonomy-%:
	@test -e `pwd`/${DATADIR}/PressMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'` \
	|| echo -n "\nERROR: missing taxonomy " ${DATADIR}/PressMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'`,"\n"
	@echo -n "INFO: validating translation taxonomy" ${DATADIR}/PressMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'` ": " \
	&& ${val_taxonomy} ${DATADIR}/PressMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'` \
	&& echo OK \
	|| echo -n "\nERROR: validation failed  " ${DATADIR}/PressMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'`,"\n"


## validateTaxonomiesSpecific-XX ## validate corpus-specific taxonomies in folder PressMint-XX
validateTaxonomiesSpecific-XX = $(addprefix validateTaxonomiesSpecific-, $(PRESS))
$(validateTaxonomiesSpecific-XX): validateTaxonomiesSpecific-%: 
	@find -H ${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "PressMint-$*-taxonomy*.xml" -exec make --no-print-directory _validateTaxonomySpecific CORPUS=$* SPECIFICTAXONOMY={} \;

_validateTaxonomySpecific:
	@echo -n "INFO: validating ${CORPUS}-specific taxonomy ${SPECIFICTAXONOMY}\n"
	@grep -Ho 'xml:id="[^"]*"' ${SPECIFICTAXONOMY} \
	  | grep -vP '(PressMint-${CORPUS}-taxonomy.*)\.xml:xml:id="\1"' \
	  | grep -vP 'xml:id="${CORPUS}-.*"' \
		| sed 's/\(.*\):xml:id="\(.*\)"/ERROR: Missing prefix "${CORPUS}-" in xml:id="\2" in \1/'
	@${val_taxonomy} ${SPECIFICTAXONOMY} \
	&& echo schema OK \
	|| echo -n "\nERROR: schema validation failed ${SPECIFICTAXONOMY}\n"

uniqIdsTaxonomies-XX = $(addprefix uniqIdsTaxonomies-, $(PRESS))

$(uniqIdsTaxonomies-XX): uniqIdsTaxonomies-%:
	@{ if cat ${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX}/PressMint-*taxonomy*.xml|grep -o 'xml:id="[^"]*"'|sort| uniq -d | grep . >/dev/null; then \
		echo "ERROR: duplicate IDs found"; exit 1; \
	  else \
		echo "INFO: No duplicit IDs in taxonomies"; \
	  fi; }







###### Convert

###### Patch
## patchTaxonomiesSpecific-XX ## patch corpus-specific taxonomies in folder PressMint-XX (= add XX prefix)
patchTaxonomiesSpecific-XX = $(addprefix patchTaxonomiesSpecific-, $(PRESS))
$(patchTaxonomiesSpecific-XX): patchTaxonomiesSpecific-%: uniqIdsTaxonomies-%
	@mkdir ${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX}.patchTaxonomiesSpecific
	@rsync -av --quiet --include='*/' --include='*.xml' --exclude='*' ${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX}/ ${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX}.patchTaxonomiesSpecific/
	@find -H ${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "PressMint-$*-taxonomy*.xml" -exec make --no-print-directory _patchTaxonomySpecific-getIds CORPUS=$* SPECIFICTAXONOMY={} \; \
	  > ${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX}.patchTaxonomiesSpecific/taxonomy-ids.patch
	@echo "INFO: Patching ids and references to $*-specific taxonomies"
	@echo -n "INFO: IDs = { "
	@cat ${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX}.patchTaxonomiesSpecific/taxonomy-ids.patch | tr "\n" " " 
	@echo "}"
	@find ${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX}.patchTaxonomiesSpecific -type f -name "*.xml" \
	 | parallel --gnu --halt 2 --jobs 10  'perl ./Scripts/patch-replaceIDs.pl -prefix $* -ids ${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX}.patchTaxonomiesSpecific/taxonomy-ids.patch < {} > {}.tmp && mv {}.tmp {}'
	@rm ${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX}.patchTaxonomiesSpecific/taxonomy-ids.patch
	@echo "INFO: Taxonomies and references patched: ${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX}.patchTaxonomiesSpecific"

_patchTaxonomySpecific-getIds:
	@grep -Ho 'xml:id="[^"]*"' ${SPECIFICTAXONOMY} \
	  | grep -vP '(PressMint-${CORPUS}-taxonomy.*)\.xml:xml:id="\1"' \
	  | grep -vP 'xml:id="${CORPUS}-.*"' \
		| sed 's/"$$//;s/.*="//'

###### Geters

get-file-if-exists:
	@if [ -f "$(PATH)" ]; then \
	    echo $(PATH); \
	else \
	  echo "WARN: missing file $(PATH)" ; \
		exit 1; \
	fi

$(addprefix get-corpus-path-TEI-, $(PRESS)): get-corpus-path-TEI-%:
	@make -s get-file-if-exists PATH=${DATADIR}/PressMint-$*${CORPUSDIR_SUFFIX}/PressMint-$*.xml


###### Help

help-intro:
	@echo "replace XX with country code or run target without -XX to process all countries: \n\t ${PARLIAMENTS}\n "

help-variables:
	@echo "\033[1m\033[32mVARIABLES:\033[0m"
	@echo "Variable VAR with value 'value' can be set when calling target TARGET in $(MAKEFILE_LIST): make VAR=value TARGET"
	@grep -E '^## *\$$[a-zA-Z_-]*.*?##.*$$' $(MAKEFILE_LIST) |sed 's/^## *\$$/##/'| awk 'BEGIN {FS = " *## *"}; {printf "\033[1m%s\033[0m\033[36m%-18s\033[0m %s\n", $$4, $$2, $$3}'

help-targets:
	@echo "\033[1m\033[32mTARGETS:\033[0m"
	@grep -E '^## *[a-zA-Z_-]+.*?##.*$$|^####' $(MAKEFILE_LIST) | awk 'BEGIN {FS = " *## *"}; {printf "\033[1m%s\033[0m\033[36m%-25s\033[0m %s\n", $$4, $$2, $$3}'


.PHONY: help
## help ## print this help
help: help-intro help-variables help-targets

## help-advanced ## print full help
help-advanced: help
	@echo "\033[1m\033[32mADVANCED:\033[0m"
	@echo "If you want to run target on multiple targets but not all, you can overwrite PARLIAMENTS variable. E.g. make check-links PARLIAMENTS=\"GB CZ\""
	@grep -E '^## *![a-zA-Z_-]+.*?##.*$$|^##!##' $(MAKEFILE_LIST) |sed 's/^## *!/##/'| awk 'BEGIN {FS = " *## *"}; {printf "\033[1m%s\033[0m\033[35m%-25s\033[0m %s\n", $$4, $$2, $$3}'


######################VARIABLES
SAXON = ./Scripts/bin/saxon.jar

s = java $(JM) -jar $(SAXON)
P = parallel --gnu --halt 2
j = java $(JM) -jar ./Scripts/bin/jing.jar

getincludes = xargs -I % java -cp $(SAXON) net.sf.saxon.Query -xi:off \!method=adaptive -qs:'//*[local-name()="include"]/@href' -s:% |sed 's/^ *href="//;s/"//'
getheaderincludes = xargs -I % java -cp $(SAXON) net.sf.saxon.Query -xi:off \!method=adaptive -qs:'//*[local-name()="teiHeader"]//*[local-name()="include"]/@href' -s:% |sed 's/^ *href="//;s/"//'
getcomponentincludes = xargs -I % java -cp $(SAXON) net.sf.saxon.Query -xi:off \!method=adaptive -qs:'/*/*[local-name()="include"]/@href' -s:% |sed 's/^ *href="//;s/"//'

formatAndPolish = tr '\n' ' '| sed 's/  */ /g;s/ \(<\/\)/\1/g;s/\(<[^\/>]*>\) /\1/g' | xmllint --format - | sed 's/  /   /g' | perl Scripts/polish-xml.pl

val_taxonomy = $j TEI/PressMint-taxonomy.rng
val_root = $j TEI/PressMint.odd.rng
val_comp = $j TEI/PressMint.odd.rng



