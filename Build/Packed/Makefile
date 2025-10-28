upload:
	rsync *.tgz /project/clarin-upload/PressMint

CORPORA = AT BG CZ ES GR IS LV NL PL SI

unpack:
	for CORPUS in ${CORPORA}; do \
	tar xvzf PressMint-$${CORPUS}.tgz; \
	tar xvzf PressMint-$${CORPUS}.ana.tgz; \
	done;
