#!/usr/bin/env perl
# Pack PressMint corpora into .tgz files ready for distribution

use warnings;
use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

sub usage {
    print STDERR ("Usage:\n");
    print STDERR ("pack-pressmint.pl -help\n");
    print STDERR ("pack-pressmint.pl -codes '<Codes>' -in <Input> -out <Output>\n");
    print STDERR ("    Packs PressMint corpora into .tgz.\n");
    print STDERR ("    <Codes> is the list of country codes of the corpora to be processed.\n");
    print STDERR ("    <Input> is the directory with input README-XX*.md files and PressMint-XX.*/ directories.\n");
    print STDERR ("    <Output> is the directory where output .tgz are written.\n");
    print STDERR ("\n");
    print STDERR ("    The script produces two .tgz files:\n");
    print STDERR ("    - PressMint-XX.TEI.tgz (README-XX.md + PalaMint-XX.PressMint-XX.TEI/ + PressMint-XX.txt\n");
    print STDERR ("    - PressMint-XX.TEI.ana.tgz (README-XX.ana.md + PressMint-XX.TEI.ana/ + PressMint-XX.conllu/ + PressMint-XX.txt/ + PressMint-XX.vert/\n");
}

use Getopt::Long;
use FindBin qw($Bin);
use File::Spec;
use File::Copy;

GetOptions
    (
     'help'     => \$help,
     'codes=s'  => \$countryCodes,
     'in=s'     => \$inDir,
     'out=s'    => \$outDir,
);

if ($help) {
    &usage;
    exit;
}

$inDir = File::Spec->rel2abs($inDir);
$outDir = File::Spec->rel2abs($outDir);

$XX_template = "PressMint-XX";

foreach my $countryCode (split(/[, ]+/, $countryCodes)) {
    print STDERR "INFO: ***Packing $countryCode\n";
    $teiReadme = "README-$countryCode.md";
    $anaReadme = "README-$countryCode.ana.md";
    
    $XX = $XX_template;
    $XX =~ s|XX|$countryCode|g;
    $teiDir  = "$XX.TEI";
    $anaDir  = "$XX.TEI.ana";
    $txtDir  = "$XX.txt";
    $conlDir = "$XX.conllu";
    $vertDir = "$XX.vert";

    $outTei = "$XX.tgz";
    $outAna = "$XX.ana.tgz";
    
    unless (-e "$inDir/$teiDir" and -e "$inDir/$txtDir") {
	print STDERR "WARN: *Cant find $teiDir or $txtDir, won't pack .TEI version!\n";
    }
    else {
	print STDERR "INFO: *Packing $teiReadme, $teiDir/, $txtDir/\n";
	die "FATAL ERROR: Can't find $inDir/$teiReadme\n" unless -e "$inDir/$teiReadme";
	die "FATAL ERROR: Can't find $inDir/$txtDir\n" unless -e "$inDir/$txtDir";
	`rm -fr $outDir/$outTei`;
	`cd $inDir; tar -czf $outTei --mode='a+rwX' $teiReadme $teiDir $txtDir`;
	move("$inDir/$outTei", $outDir);
    }
    
    print STDERR "INFO: *Packing $anaReadme, $anaDir/, $conlDir/, $txtDir/, $vertDir/\n";
    if (-e "$inDir/$anaDir/$XX.ana.xml") {
	die "FATAL ERROR: Can't find $inDir/$anaReadme\n" unless -e "$inDir/$anaReadme";
        die "FATAL ERROR: Can't find $inDir/$anaDir\n" unless -e "$inDir/$anaDir"; 
        die "FATAL ERROR: Can't find $inDir/$conlDir\n" unless -e "$inDir/$conlDir";
        die "FATAL ERROR: Can't find $inDir/$txtDir\n" unless -e "$inDir/$txtDir";
        die "FATAL ERROR: Can't find $inDir/$vertDir\n" unless -e "$inDir/$vertDir";
        `rm -fr $outDir/$outAna`;
        `cd $inDir; tar -czf $outAna --mode='a+rwX' $anaReadme $anaDir $txtDir $conlDir $vertDir`;
        move("$inDir/$outAna", $outDir);
    }
    else {
        print STDERR "WARN: No ana root file, skipping\n";
    }
}
