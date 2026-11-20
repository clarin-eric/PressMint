#!/usr/bin/env perl
# Copy produced samples to official build sources so they can be used for testing
use warnings;
use utf8;
use open ':utf8';
use FindBin qw($Bin);
binmode(STDERR, ':utf8');
$inDir = shift;
$outDir = shift;

$teiOutDir = "$outDir/PressMint-SI.TEI";
if (-e $teiOutDir) {`rm -fr $teiOutDir/*`}
else {`mkdir $teiOutDir`}
`cp $inDir/PressMint-SI.xml $teiOutDir/`;
`cp $inDir/PressMint-taxonomy-OCR.xml $teiOutDir/`;
foreach $teiFile (glob "$inDir/*/*.xml") {
    my ($slice, $file) = $teiFile =~ m|$inDir/(....)/(.*\.xml)$| or die;
    next if $file =~ m|\.ana\.|;
    unless (-e "$teiOutDir/$slice") {`mkdir $teiOutDir/$slice`}
    `cp $teiFile $teiOutDir/$slice`
}

$anaOutDir = "$outDir/PressMint-SI.TEI.ana";
if (-e $anaOutDir) {`rm -fr $anaOutDir/*`}
else {`mkdir $anaOutDir`}
`cp $inDir/PressMint-SI.ana.xml $anaOutDir/`;
`cp $inDir/PressMint-taxonomy-OCR.xml $anaOutDir/`;
`cp $inDir/PressMint-taxonomy-NER.ana.xml $anaOutDir/`;
foreach $teiFile (glob "$inDir/*/*.xml") {
    my ($slice, $file) = $teiFile =~ m|$inDir/(....)/(.*\.xml)$| or die;
    next unless $file =~ m|\.ana\.|;
    unless (-e "$anaOutDir/$slice") {`mkdir $anaOutDir/$slice`}
    `cp $teiFile $anaOutDir/$slice`
}
