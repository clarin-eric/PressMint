#!/usr/bin/env perl
# Convert sPeriodika JSON to PressMint-SI
use warnings;
use utf8;
use JSON::XS;
use POSIX qw(locale_h);
use POSIX qw(strftime);
use Number::Format qw(:subs :vars);
#use DateTime;
setlocale(LC_TIME, "sl_SI.UTF-8");

#ToDo:
# - give place of publication for all newspapers?
# - insert Wikipedia URL?

# Good if higher i.e. closer to 0
$perplexity_treshold = -84.00;

#Prerequisite for validation:
#In PressMint:
$jing = 'java -jar ../../Scripts/bin/jing.jar';
$schema = '../../TEI/PressMint.odd.rng';
#In sPeriodika:
$jing = 'java -jar /project/corpora/Parla/PressMint/PressMint/Scripts/bin/jing.jar';
$schema = '/project/corpora/Parla/PressMint/PressMint/TEI/PressMint.odd.rng';

# Mode parameter should be either "text" or "ana"
my $mode = shift;
my $inFiles = shift;
my $outDir = shift;

binmode STDERR, 'utf8';

# Probably not needed but inserted anyway:
$edition = '0.1';
$handle = 'http://handle.net/XXX';

$xpos_prefix = 'mte';    # We assume XPOS is MULTEXT-East MSD

# Input example:
#     "csmt_rate": 0.04,
#     "date": "1877-08-15",
#     "dlib_date": "1877 08 15",
#     "dlib_url": "https://dlib.si/details/URN:NBN:SI:DOC-000TTDCE/",
#     "issue_number": "33",
#     "number_of_pages": 1,
#     "periodical_name": "Kmetijske in rokodelske novice",
#     "publisher": "Jo\u017eef Blaznik",
#     "title": "Gospodarske sku\u0161nje",
#     "URN": "URN:NBN:SI:DOC-000TTDCE",
#     "volume_number": 35,
#     "year": "1877"
#     "pages": [
#         {
#             "align_ratio": 100.0,
#             "final_line_index": 2,
#             "image_url": "https://nl.ijs.si/inz/periodika/0/000TTDCE/000TTDCE-0.jpg",
#             "page_index": 0,
#             "pdf_text": "260 \nGospodarske sku\u0161nje. \n..."
#             "text": "\n260\n\nGospodarske sku\u0161nje.\n\n* ..."
#             "text_csmtised": "\n260\n\nGospodarske sku\u0161nje.\n\n*..."
#             "text_csmtised_kenlm_perplexity": {
#                 "mean": -84.12516357421875,
#                 "stdev": 6.49344779660705
#             },
#             "text_csmtised_splitfixed": "\n260 Gospodarske sku\u0161nje.\n\n*..."
#             "text_csmtised_splitfixed_CONLLU": "# newpar id = 1\n# sent_id = 1.1\n# text = 260 Gospodarske sku\u0161nje.\n1\t260..."
#           }
#         ]
# }

$today = strftime "%Y-%m-%d", localtime;
$today_sl = strftime "%e. %B %Y", localtime;

#Get the TEI skeleton template 
while (<DATA>) {$TEI_template .= $_}

$i = 0;

if ($mode eq 'text') {$stamp = 'PressMint'}
else  {$stamp = 'PressMint.ana'}

mkdir $outDir unless -d $outDir;

foreach $inFile (glob $inFiles) {
    print STDERR "INFO: processing $inFile\n";

    #Process input, return file date, file ID, and the PressMint TEI output
    open(IN, '<:utf8', $inFile);
    my ($date, $fname, $TEI) = &processFile;
    close IN;
    
    #A basic sanity check on date:
    unless (($y, $m, $d) = $date =~ /^(\d\d\d\d)-(\d\d)-(\d\d)$/ and
            $y >= 1771 and $y <= 1914 and
            $m >= 1 and $m <= 12 and
            $d >= 1 and $d <= 31) {
        print STDERR "ERROR: Bad date $date for $inFile, skipping\n";
        next
    }
    #Make year directory for file and name file:
    (my $year) = $date =~ /(\d\d\d\d)/;
    $outYearDir = "$outDir/$year";
    mkdir $outYearDir unless -d $outYearDir;
    $outName = "PressMint-SI_$date-$fname";
    if ($mode eq 'text') {$outName .= '.xml'}
    else  {$outName .= '.ana.xml'}
    $outFile = "$outYearDir/$outName";
    print STDERR "      -> $outFile\n";

    #Write file:
    open(OUT, '>:utf8', $outFile) or die "Can't open output file $outFile\n";
    print OUT $TEI;
    close OUT;

    #Validate:
    $error = `$jing $schema $outFile`;
    print STDERR "ERROR: Mistakes in file $outFile:\n$error\n"
        if $error
}

sub processFile {
    while (<IN>) {
        $i++;
        # Get and decode JSON:
        $record = JSON::XS->new->utf8->decode ($_);

        # Have local variables
        $title     = ${$record}{'title'};
        $newspaper = ${$record}{'periodical_name'};
        $pubdate   = ${$record}{'date'};
        $volume    = ${$record}{'volume_number'};
        $issue     = ${$record}{'issue_number'};
        $pages     = ${$record}{'number_of_pages'};
        $publisher = ${$record}{'publisher'};
        $urn       = ${$record}{'URN'};
        $dlib_url  = ${$record}{'dlib_url'};
        
        ($title, $newspaper, $place) = &fix_name($title, $newspaper);
        
        $fname = $urn;

        # Compute some more variables:
        $fname =~ s/.+-(.+)/$1/;
        $id = "PressMint-SI_$pubdate-$fname";

        # Now substitute various pieces of the TEI file:
        $facs = &prepFacs;
        ($words, $tokens) = &count_wt;
        
        $pubdate_sl = $pubdate;
        $pubdate_sl =~ s/(\d+)-(\d+)-(\d+)/$3.$2.$1/;
        $pubdate_sl =~ s/^0//; $pubdate_sl =~ s/ 0/ /g;
        $pubdate_en = $pubdate;
        $pubdate_en =~ s|(\d+)-(\d+)-(\d+)|$2/$3/$1|;
        $pubdate_en =~ s/^0//; $pubdate_en =~ s/ 0/ /g;
        
        $THOUSANDS_SEP   = '.';
        $pages_sl = format_number($pages);
        $words_sl = format_number($words);
        $tokens_sl = format_number($tokens);
        $THOUSANDS_SEP   = ',';
        $pages_en = format_number($pages);
        $words_en = format_number($words);
        $tokens_en = format_number($tokens);
        
        # Get image url from first page, for prefixDef
        $image_url = ${@{${$record}{'pages'}}[0]}{'image_url'};
        # Sic!
        # JSON "image_url": "https://nl.ijs.si/inz/periodika/0/000TTDCE/000TTDCE-0.jpg"
        # Actual URL:        https://nl.ijs.si/inz/speriodika/000TTDCE-0.jpg
        $image_url =~ s|https://nl.ijs.si/inz/periodika/[^/]+/[^/]+/|https://nl.ijs.si/inz/speriodika/|;

        ($page_prefix) = $image_url =~ /(.+)-\d+\.jpg/;
        
        if ($mode eq 'text') {$text = &prepText}
        else {$text = &prepAna}
        
        $tagUsage = &tagUsage($facs . $text);
        
        $TEI = &prepTEI($TEI_template);
    }
    return ($pubdate, $fname, $TEI)
}
    
# Count words and tokens from CoNLL-U
sub count_wt {
    my $w;
    my $t;
    foreach $page (@{${$record}{'pages'}}) {
        my $page = ${$page}{'text_csmtised_splitfixed_CONLLU'};
        foreach my $line (split(/\n/, $page)) {
            if ($line =~ /\t/) {
                $t++;
                $w++ if $line !~ /\tPUNCT\t/
            }
        }
    }
    return ($w, $t)
}   

sub facs_url2id {
    my $fname = shift;
    $image_url = shift;
    (my $n) = $image_url =~ /-(\d+)\./;
    return $fname . '.page' . ++$n;
}

sub prepFacs {
    my $facs;
    foreach $page (@{${$record}{'pages'}}) {
        my $url = ${$page}{'image_url'};
        (my $suffix) = $url =~ /-(\d+)\./;
        $facs .= "      <surface xml:id=\"". &facs_url2id($id, $url) . "\">\n";
        $facs .= "         <graphic url=\"facs:" . $suffix . "\"/>\n";
        $facs .= "      </surface>\n";
    }
    $facs =~ s/\n$//;
    return $facs
}

sub prepText {
    my $text;
    my $pbN = 0;
    foreach $page (@{${$record}{'pages'}}) {
        $pbN++;
        $pbID = "$id.pb$pbN";
        my $facs_id = &facs_url2id($id, ${$page}{'image_url'});
        my $quality = &quality(${$page}{'text_csmtised_kenlm_perplexity'}{'mean'});
        $text .= "        <pb xml:id=\"$pbID\" facs=\"#$facs_id\"/>\n";
        my $page = ${$page}{'text_csmtised_splitfixed'};
        $pN = 0;
        foreach my $line (split(/\n\n+/, $page)) {
            $pN++;
            $pID = "$pbID.p$pN";
            $line =~ s/^\n//;
            $line =~ s/\n$//;
            if ($line) {
                $text .= "        <p xml:id=\"$pID\" ana=\"#$quality\">";
                $str = &fix_chars($line);
                $text .= &xml_encode($str);
                $text .= "</p>\n";
            }
            else {print STDERR "WARN: Empty paragraph for $pID\n"}
        }
    }
    $text =~ s/\n$//;
    return $text
}

sub prepAna {
    my $text;
    foreach $page (@{${$record}{'pages'}}) {
        my $facs_id = &facs_url2id($id, ${$page}{'image_url'});
        $text .= "        <pb facs=\"#$facs_id\"/>\n";
        $first_p = 1;
        my $page = ${$page}{'text_csmtised_splitfixed_CONLLU'};
        foreach my $sent (split(/\n\n/, $page)) {
            if ($sent =~ /^# newpar/) {
                if ($first_p) {$first_p = 0}
                else {$text .= "        </p>\n"}
                $text .= "        <p>\n";
            }
            $text .= &conllu2tei($sent);
        }
        $text .= "        </p>\n" unless $first_p;
    }
    return $text
}

#Convert one CoNLL-U sentence into TEI
sub conllu2tei {
    my $conllu = shift;
    my $tei;
    my $tag;
    my $element;
    my $space;
    my $ner_prev;
    my $ner;
    my @toks = ();
    $tei = "<s>\n";
    foreach my $line (split(/\n/, $conllu)) {
        next unless $line =~ /^\d+\t/;
        chomp;
        my ($n, $token, $lemma, $upos, $xpos, $ufeats, $link, $role, $extra, $local) 
            = split /\t/, $line;
        $xpos =~ s/-+$//;   # Get rid of trailing dashes sometimes introduced by Stanford NLP

        $token = &fix_chars($token);
        $lemma = &fix_chars($lemma);

        if ($token =~ /^[[:punct:]]+$/) {
            $tag = 'pc';
            if ($token =~ /[$~%§©+−×÷=<>&#\pS]/) {
                if ($upos ne 'SYM') {
                    print STDERR "WARN: Changing UPoS from $upos to SYM for $token\n";
                    $upos = 'SYM';
                    $ufeats = '_';
                }
            }
            elsif ($upos ne 'PUNCT' and $upos ne 'SYM') {
                print STDERR "WARN: Changing UPoS from $upos to PUNCT for $token\n";
                $upos = 'PUNCT';
                $ufeats = '_';
            }
            $xpos = 'Z';
        }
        else {$tag = 'w'}
        
        if ($upos =~ /_/) {
            print STDERR "ERROR: Empty UPoS for $token\n";
        }
        else {
            $feats = "UPosTag=$upos";
            $feats .= "|$ufeats" if $ufeats ne '_';
        }
        
        if ($lemma =~ /_/) {
            print STDERR "WARN: Empty lemma for $token\n";
            $lemma = $token
        }
        if (($ner) = $local =~ /NER=([A-Z-]+)/) {
            if (($type) = $ner =~ /^B-(.+)/) {
                if ($ner_prev and $ner_prev ne 'O') {
                    push(@toks, "</name>")
                }
                push(@toks, "<name type=\"$type\">");
            }
	    #Sometimes NER begins with I! (bug in CLASSLA)
            elsif (($type) = $ner =~ /^I-(.+)/) {
                if (not($ner_prev) or $ner_prev eq 'O') {
		    push(@toks, "<name type=\"$type\">");
                }
            }
            elsif ($ner eq 'O' and $ner_prev and $ner_prev ne 'O') {
		push(@toks, "</name>")
            }
            $ner_prev = $ner
        }
        
        $space = $local !~ s/SpaceAfter=No//;
        $token = &xml_encode($token);
        $lemma = &xml_encode($lemma);
        $lemma =~ s|"|&quot;|g;

        if ($tag eq 'w') {$element = "<$tag>$token</$tag>"}
        elsif ($tag eq 'pc') {$element = "<$tag>$token</$tag>"}
        if ($xpos ne '_') {$element =~ s|>| ana=\"$xpos_prefix:$xpos\">|}
        if ($feats and $feats ne '_') {$element =~ s|>| msd=\"$feats\">|}
        if ($tag eq 'w' and $lemma ne '_') {$element =~ s|>| lemma=\"$lemma\">|}
        $element =~ s|>| join="right">| unless $space;
        push @toks, $element;
    }
    if ($ner_prev and $ner_prev ne 'O') {
        push(@toks, '</name>')
    }
    $tei .= join "\n", @toks;
    $tei .= "\n</s>\n";
    return $tei
}

sub fix_name {
    my $title = shift;
    my $periodical = shift;

    unless ($periodical) {
        return ($title, $periodical)
    }
    else {
        # Remove spurious whitespace
        $periodical =~ s/^\s+//;
        $periodical =~ s/\s+$//;
        $periodical =~ s/\s+/ /g;
        $title =~ s/^\s+//;
        $title =~ s/\s+$//;
        $title =~ s/\s+/ /g;
        
        #Get place of publication, if available
        $pubPlace = '';
        if ((my $xtra) = $periodical =~ / \((.+)\)/) {
            $pubPlace = $xtra if
                $xtra =~ /^\p{Lu}\p{Ll}+$/
        }
        #Remove year or place of publication, e.g. "Zora (1872)", "Popotnik (1880-1941)", "Zvonček (Ljubljana)"
        $periodical =~ s/ \(.+\)//;
        
        # Check if title is same as name of periodical, then delete it, e.g.
        # Slovenski narod	Slovenski narod
        # Zvon: leposloven list	Zvon (1870)
        # but also
        # Popotnik: časopis za sodobno pedagogiko: letno kazalo	Popotnik (1880-1941)
        if ($title eq $periodical) {$title = ''}
        elsif (my ($ptitle) = $title =~ /^(.+): [^:]+$/) {
            if ($ptitle eq $periodical) {$title = ''}
        }
        
        # Join spread word, e.g. "D a n i c i"
        if ($title =~ /^(\w )+\w$/) {$title =~ s/ //g}
        # Decap title, e.g. "BASEN O SRAKI"
        if ($title =~ /^[[:upper:] ]+$/) {$title = ucfirst($title)}
        
        # Fix XML entities, e.g. "Društvo ,,Straža&quot;"
        $title =~ s/&amp;/&/g;
        $title =~ s/&quot;/"/g;
        
        return ($title, $periodical, $pubPlace)
    }
}

sub fix_chars {
    my $str = shift;
    my $input = $str;
    $str =~ s|[\x{0D}\x{AD}\x{FEFF}]||g;     # CTRL-M, SOFT HYPHEN,  ZERO WIDTH NO-BREAK SPACE
    $str =~ s|[\x{A0}\x{2000}-\x{200A}]| |g; # NO-BREAK SPACE, NON-STANDARD SPACES
    $str =~ s|[\x{2011}]|-|g;                # NON-BREAKING HYPHEN
    $str =~ s|[\x{E800}-\x{F8FF}]||g;        # PUA
    $str =~ s|\s+| |g; s|^ ||; s| $||;       # Normalize spaces
    unless ($str or $str == 0) {
        print STDERR "ERROR: nothing left if bad chars removed in '$input'\n";
        return $input
    }
    else {return $str}
}

sub quality {
    my $perplexity = shift;
    if (not defined $perplexity) {return 'quality.low'}
    elsif ($perplexity > $perplexity_treshold) {return 'quality.high'}
    else {return 'quality.low'}
}

sub xml_encode {
    my $str = shift;
    $str =~ s|&|&amp;|g;
    $str =~ s|<|&lt;|g;
    $str =~ s|>|&gt;|g;
    return $str
}

sub tagUsage {
    my $tei = shift;
    my %tags;
    my $tagusage;
    foreach my $item (split(/>/, $tei)) {
        my ($tag) = $item =~ m|<([^/ ]+)|;
        $tags{$tag}++ if $tag
    }
    foreach my $tag (sort keys %tags) {
        $tagusage .= "               <tagUsage gi=\"" . $tag . "\" occurs=\"$tags{$tag}\"/>\n";
    }
    $tagusage =~ s/\n$//;
    return $tagusage;
}

#Prepare the TEI, esp. the teiHeader
sub prepTEI {
    my $TEI = shift;
    $TEI =~ s|==STAMP==|$stamp|g;
    $TEI =~ s|==TODAY==|$today|g;
    $TEI =~ s|==TODAY-SL==|$today_sl|g;
    $TEI =~ s|==EDITION==|$edition|g;
    $TEI =~ s|==HANDLE==|$handle|g;
    $TEI =~ s|==ID==|$id|g;
    $TEI =~ s|==DLIB-URL==|$dlib_url|g;
    $TEI =~ s|==URN==|$urn|g;
    $TEI =~ s|==NEWSPAPER==|$newspaper|g;
    $TEI =~ s|==PUBDATE==|$pubdate|g;
    $TEI =~ s|==PUBDATE-SL==|$pubdate_sl|g;
    $TEI =~ s|==PUBDATE-EN==|$pubdate_en|g;
    $TEI =~ s|==PAGE-PREFIX==|$page_prefix|g;

    $TEI =~ s|==PAGES==|$pages|g;
    $TEI =~ s|==PAGES-SL==|$pages_sl|g;
    $TEI =~ s|==PAGES-EN==|$pages_en|g;
    $TEI =~ s|==WORDS==|$words|g;
    $TEI =~ s|==WORDS-SL==|$words_sl|g;
    $TEI =~ s|==WORDS-EN==|$words_en|g;
    $TEI =~ s|==TOKENS==|$tokens|g;
    $TEI =~ s|==TOKENS-SL==|$tokens_sl|g;
    $TEI =~ s|==TOKENS-EN==|$tokens_en|g;

    if ($title and $title ne '-') {$TEI =~ s|==TITLE==|$title|g}
    else {$TEI =~ s|\n.*==TITLE==.*||g}
    if ($volume and $volume ne '-') {$TEI =~ s|==VOLUME==|$volume|g}
    else {$TEI =~ s|\n.*==VOLUME==.*||g}
    if ($issue and $issue ne '-') {$TEI =~ s|==ISSUE==|$issue|g}
    else {$TEI =~ s|\n.*==ISSUE==.*||g}
    if ($publisher and $publisher ne '-') {$TEI =~ s|==PUBLISHER==|$publisher|g}
    else {$TEI =~ s|\n.*==PUBLISHER==.*||g}
    if ($place and $place ne '-') {$TEI =~ s|==PLACE==|$place|g}
    else {$TEI =~ s|\n.*==PLACE==.*||g}
    
    $TEI =~ s|==FACS==|$facs|;
    $TEI =~ s|==TAGUSAGE==|$tagUsage|;
    
    print STDERR "ERROR: unconsumed variables in:\n$TEI"
        if $TEI =~ m|==[A-Z-]+==|;
    #text must come after, in case it has '==' in it

    $TEI =~ s|!!TEXT!!|$text|;
    return $TEI
}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="==ID==" xml:lang="sl">
   <teiHeader>
      <fileDesc>
         <titleStmt>
            <title>Korpus starejših slovenskih časopisov PressMint-SI, ==NEWSPAPER==, ==PUBDATE-SL== [==STAMP==]</title>
            <title xml:lang="en">Slovenian historical newspaper corpus PressMint-SI, "==NEWSPAPER==", ==PUBDATE-EN== [==STAMP==]</title>
         </titleStmt>
         <editionStmt>
            <edition>==EDITION==</edition>
         </editionStmt>
         <extent>
            <measure unit="pages" quantity="==PAGES==" xml:lang="sl">==PAGES-SL== strani</measure>
            <measure unit="pages" quantity="==PAGES==" xml:lang="en">==PAGES-EN== pages</measure>
            <measure unit="words" quantity="==WORDS==" xml:lang="sl">==WORDS-SL== besed</measure>
            <measure unit="words" quantity="==WORDS==" xml:lang="en">==WORDS-EN== words</measure>
            <measure unit="tokens" quantity="==TOKENS==" xml:lang="sl">==TOKENS-SL== pojavnic</measure>
            <measure unit="tokens" quantity="==TOKENS==" xml:lang="en">==TOKENS-EN== tokens</measure>
         </extent>
         <publicationStmt>
            <publisher>
               <orgName xml:lang="sl">Raziskovalna infrastruktura CLARIN</orgName>
               <orgName xml:lang="en">CLARIN research infrastructure</orgName>
               <ref target="https://www.clarin.eu/">www.clarin.eu</ref>
            </publisher>
            <idno type="URI" subtype="handle">==HANDLE==</idno>
            <availability status="free">
               <licence>http://creativecommons.org/licenses/by/4.0/</licence>
               <p xml:lang="en">This work is licensed under the <ref target="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</ref>.</p>
               <p xml:lang="sl">To delo je ponujeno pod <ref target="http://creativecommons.org/licenses/by/4.0/">Creative Commons Priznanje avtorstva 4.0 mednarodna licenca</ref>.</p>
            </availability>
            <date when="==TODAY==">==TODAY-SL==</date>
         </publicationStmt>
         <sourceDesc>
            <bibl>
               <title level="j">==NEWSPAPER==</title>
               <title level="a">==TITLE==</title>
               <publisher>==PUBLISHER==</publisher>
               <pubPlace>==PLACE==</pubPlace>
               <date when="==PUBDATE==">==PUBDATE-SL==</date>
               <biblScope unit="volume">==VOLUME==</biblScope>
               <biblScope unit="issue">==ISSUE==</biblScope>
               <idno type="URN">==URN==</idno>
               <idno type="URI">==DLIB-URL==</idno>
            </bibl>
         </sourceDesc>
      </fileDesc>
      <encodingDesc>
         <tagsDecl>
            <namespace name="http://www.tei-c.org/ns/1.0">
==TAGUSAGE==
            </namespace>
         </tagsDecl>
         <listPrefixDef>
            <prefixDef ident="facs"
                       matchPattern="(.+)"
                       replacementPattern="==PAGE-PREFIX==-$1.jpg">
               <p xml:lang="en">The URIs with this prefix point to the facsimile images of this corpus component.</p>
            </prefixDef>
         </listPrefixDef>
      </encodingDesc>
      <revisionDesc>
         <change when="==TODAY==">
            <name>Tomaž Erjavec</name>: Made sample.</change>
      </revisionDesc>
   </teiHeader>
   <facsimile>
==FACS==
   </facsimile>
   <text xml:lang="sl">
      <body>
!!TEXT!!
      </body>
   </text>
</TEI>
