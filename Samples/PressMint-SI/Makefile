### Copy files produced in Temp/ to PressMint/Build/Sources-TEI 
copy-files:
	Scripts/cp-files.pl Temp ../../Build/Sources-TEI/
	#cp Temp/PressMint-taxonomy-NER.ana.xml ../../Build/Sources-TEI/PressMint-SI.TEI.ana

### Produce initial PressMint TEI from JSON:
preconvert:
	Scripts/sPeriodika-json2tei.pl text 'Sources/*.json' Temp
	Scripts/sPeriodika-json2tei.pl ana  'Sources/*.json' Temp

###################This is large!
get-full-corpus-from-repo:
	curl --remote-name-all https://www.clarin.si/repository/xmlui/bitstream/handle/11356/1881{/sPeriodika.1.0.json.tgz}
	tar xvz sPeriodika.1.0.json.tgz

###################################Some useful program variables
j = java -jar ../../Scripts/bin/jing.jar ../../TEI/PressMint.odd.rng
s = java -jar ../../Scripts/bin/saxon.jar
P = parallel --gnu --halt 2 --jobs 5

