## Copy over registry files so they can be included in a distribution
all:	cp_regis

SRC=/project/clarinsi-cqp/registry/
REGIST_VERSION=10
REGIST_CORPORA=at bg cz es gr is lv nl pl si

# Registry files 
cp_regis:
	rm -f registry/*
	for CORPUS in ${REGIST_CORPORA}; do \
	cp -f ${SRC}/pressmint${REGIST_VERSION}_$${CORPUS} pressmint${REGIST_VERSION}_$${CORPUS}; \
	done;
