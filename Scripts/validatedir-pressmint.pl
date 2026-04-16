#!/usr/bin/env perl
# Validate all PressMint files in parameter $inDirs
use warnings;
use utf8;
use FindBin qw($Bin);
use File::Spec;

$schemaDir = File::Spec->rel2abs(shift);
$inDirs = File::Spec->rel2abs(shift);

binmode(STDOUT, 'utf8');
binmode(STDERR, 'utf8');

$Jing    = "java -jar $Bin/bin/jing.jar";
$Saxon   = "java -jar $Bin/bin/saxon.jar";

$Links = "$Bin/check-links.xsl";
$Val   = "$Bin/validate-pressmint.xsl";

foreach my $inDir (glob "$inDirs") {
    next unless -d $inDir;
    print STDERR "INFO: Validating directory $inDir\n";
    my $rootFile = '';
    my $rootAnaFile = '';
    my @compFiles = ();
    my @compAnaFiles = ();
    foreach $inFile (glob "$inDir/*.xml") {
        my ($fName) = $inFile =~ m|([^/]+)$|
            or die "FATAL ERROR: Bad file '$inFile'!\n";
        if    ($fName =~ m|PressMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?\.xml|) {$rootFile = $inFile}
        elsif ($fName =~ m|PressMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?\.ana\.xml|) {$rootAnaFile = $inFile}
        elsif ($fName =~ m|PressMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?_.+\.ana\.xml|) {push(@compAnaFiles, $inFile)}
        elsif ($fName =~ m|PressMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?_.+\.xml|) {push(@compFiles, $inFile)}
        else {die "FATAL ERROR: Bad file '$fName' in '$inFile'!\n"}
    }
    if ($rootFile) {
        &run("$Jing $schemaDir/PressMint-teiCorpus.rng", $rootFile);
        foreach my $file (@compFiles) {
            &run("$Jing $schemaDir/PressMint-TEI.rng", $file);
            &run("$Saxon -xsl:$Val", $file);
            &run("$Saxon meta=$rootFile -xsl:$Links", $file);
        }
    }
    else {
        print STDERR "WARN: Couldn't find root file in $inDir/*.xml\n"
    }
    if ($rootAnaFile) {
        &run("$Jing $schemaDir/PressMint-teiCorpus.ana.rng", $rootAnaFile);
        foreach my $file (@compAnaFiles) {
            &run("$Jing $schemaDir/PressMint-TEI.ana.rng", $file);
            &run("$Saxon -xsl:$Val", $file);
            &run("$Saxon meta=$rootAnaFile -xsl:$Links", $file);
        }
    }
    else {
        print STDERR "WARN: Couldn't find ana root file in $inDir/*.xml\n"
    }
}

sub run {
    my $command = shift;
    my $file = shift;
    my ($fName) = $file =~ m|([^/]+)$|
        or die "FATAL ERROR: Bad file '$file'\n";
    if ($command =~ /$Jing/) {
        print STDERR "INFO: XML validation for $fName\n"
    }
    elsif ($command =~ /$Val/) {
        print STDERR "INFO: Content validaton for $fName\n"
    }
    elsif ($command =~ /$Links/) {
        print STDERR "INFO: Link checking for $fName\n"
    }
    else {die "FATAL ERROR: Weird command!\n"}
    `$command $file 1>&2`;
}
