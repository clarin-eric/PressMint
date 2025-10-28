## Link README.md files from the Samples directory to here, so they can be used in a distribution

all:	ln_readmes

SAMPLES=../../../Samples
README_CORPORA=AT BG CZ ES GR IS LV NL PL SI

# Main readmes from Samples/, link to them in README.md
ln_readmes:
	#rm -f *.md
	for CORPUS in ${README_CORPORA}; do \
	ln -s ${SAMPLES}/PressMint-$${CORPUS}/README.md README-$${CORPUS}.md; \
	done;
