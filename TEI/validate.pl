#!/usr/bin/env perl
# Validate PressMint corpora (either samples or complete corpora)
# with the PressMint ODD derived schema

use warnings;
use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use FindBin qw($Bin);

$what = shift;
if ($what eq 'samples') {
    $mask = 'PressMint-*/PressMint-*.xml';
}
elsif ($what eq 'master') {
    $mask  = 'PressMint-*.TEI/PressMint-*.xml ';
    $mask .= 'PressMint-*.TEI/*/PressMint-*.xml ';
    $mask .= 'PressMint-*.TEI.ana/PressMint-*.xml ';
    $mask .= 'PressMint-*.TEI.ana/*/PressMint-*.xml';
}
else {
    die "First parameter must be 'samples' or 'master'\n"
}
# Skip validatin of taxonomies, personList, orgLis:
#$black = '(taxonomy|list)';
# Validate all files:
$black = 'NULL';  

$inDir = shift;
unless (-d $inDir) {
    die "Second parameter must be top level input directory\n"
}
#Execution
$Jing   = "java -jar /usr/share/java/jing.jar";
$Schema = "$Bin/PressMint.odd.rng";
foreach my $inFile (glob "$inDir/$mask") {
    next if $inFile =~ /$black/;
    ($fName) = $inFile =~ m|([^/]+\.xml)|;
    print STDERR "INFO: Validating $fName\n";
    #`$Jing $Schema $inFile`;
    system("$Jing $Schema $inFile") == 0
	or print STDERR "ERROR: Validation of $fName failed!\n";
}
