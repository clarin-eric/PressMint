#!/usr/bin/env perl
# Copy samples to official Git directories with samples
use warnings;
use utf8;
use open ':utf8';
use FindBin qw($Bin);
binmode(STDERR, ':utf8');
$inDirs = shift;
$outDirs = shift;

foreach $inDir (glob $inDirs) {
    if (my ($corpus, $bla, $mt) = $inDir =~ m|(PressMint-[A-Z]{2}(-[A-Z]{2})?)(-[a-z]{2})?$|) {
        $mt = '' unless $mt;
        $outDir = "$outDirs/$corpus";
        
        print STDERR "INFO: Copying $corpus$mt ($inDir -> $outDir)\n";
        unless (-e $outDir) {
            print STDERR "WARN: $outDir does not exist, creating it\n";
            `mkdir $outDir`
        }
        `cp -r $inDir/* $outDir`
    }
}
