### Validate SI sample
validate:
	$j PressMint-SI.xml
	$j ????/*.xml

### Produce PressMint TEI from JSON:
convert:
	Scripts/sPeriodika-json2tei.pl text 'Sources/*.json' .
	Scripts/sPeriodika-json2tei.pl ana  'Sources/*.json' .

###################This is large!
get-full-corpus-from-repo:
	curl --remote-name-all https://www.clarin.si/repository/xmlui/bitstream/handle/11356/1881{/sPeriodika.1.0.json.tgz}
	tar xvz sPeriodika.1.0.json.tgz

###################################Some useful program variables
j = java -jar ../../Scripts/bin/jing.jar ../../TEI/PressMint.odd.rng
s = java -jar ../../Scripts/bin/saxon.jar
P = parallel --gnu --halt 2 --jobs 5

