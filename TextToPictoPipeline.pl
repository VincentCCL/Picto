####### TextToPictoPipeline.pl ##########

# By Leen Sevens and Vincent Vandeghinste
# leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 04.04.2018

#---------------------------------------

# Text-to-Pictograph translation for Dutch with advanced linguistic analysis
# Example: perl TextToPictoPipeline.pl -p beta -s cornetto -o paralleljson -e on -b on -c simplify -t on 'dit wiekent ga ik naarhuis'

#---------------------------------------

# Takes the following obligatory input options:

# -p sclera|beta sets the pictograph set used in the output
# -s cornetto sets the source language/database
# -o html|text|json|paralleljson sets the output mode (html generates valid html with <img> tags, text generates text with filenames (without extensions), json generates JSON, paralleljson generates JSON with images and the associated original input words)
# -e on|off sets the spelling correction module
# -b on|off sets the WSD module
# -c none|simplify|compress sets the simplification level
# -t on|off sets the time analysis module (only works with -c simplify)

#---------------------------------------

# Takes the following optional input options (systems's parameters, which were tuned beforehand):
# See also: Vandeghinste V., Schuurman I., Sevens L., Van Eynde F. (2015). Translating text into pictographs. Natural Language Engineering, 23 (2), 217-244.

# -v sets the Out of Vocabulary penalty
# -w sets the Wrong Number penalty
# -n sets the No Number penalty
# -h sets the Hyperonym penalty
# -k sets the XposNearSynonym penalty
# -a sets the Antonym penalty
# -f sets the Penalty Threshold
# -d sets the Dictionary Advantage
# -r sets the Word Sense Disambiguation Weight

#---------------------------------------

# Takes the following optional input options (location of the WordNet database with the pictograph connections):

# -g sets the picto database name
# -j sets the picto database host
# -m sets the picto database port
# -u sets the picto database user
# -q sets the picto database password

#---------------------------------------

use Getopt::Std;  
use FindBin qw($Bin); 
use Encode qw(decode);
use File::Path qw( rmtree );

#---------------------------------------

# Maximum time for processing

$starttime=time;
$maxtime=60;

sub Maxtime {
    $now=time;
    if ($starttime == -1) {
	return;
    }
    $elapsed=$now-$starttime;
    if ($elapsed > $maxtime) {
	die "Maximum time ($maxtime seconds) exceeded. All further processing stopped.\n";        
    }
}

#---------------------------------------

# Input options

getopt("abcdefghijklmnopqrstuvw",\%opts);

print STDERR "Use -e option to activate spelling correction (on/off)\nUse -b option to activate WSD (on/off)\nUse -c option to set simplification level (none/simplify/compress)\nUse -t option to put time analysis on or off (on/off) (only works with -c simplify)\nUse -p option to set target language (sclera/beta)\nUse -s option to set source language (cornetto)\n";

unless ($spellcheckoption=$opts{e}) {
    print STDERR "Use -e option to activate spelling correction (on/off)\n";
}
unless ($wsdoption=$opts{b}) {
    print STDERR "Use -b option to activate WSD (on/off)\n";
}
unless ($simplificationlevel=$opts{c}) {
    print STDERR "Use -c option to set simplification level (none/simplify/compress)\n";
}
unless ($timeanalysis=$opts{t}) {
    print STDERR "Use -t option to put time analysis on or off (on/off)\n";
}
unless ($targetlanguage=$opts{p}) {
    print STDERR "Use -p option to set target language (sclera/beta)\n";
}
unless ($outputmode=$opts{o}) {
    print STDERR "Use -o option to set output (html/text/json)\n";
}
unless ($sourcelanguage=$opts{s}) {
    print STDERR "Use -s option to set source language/database (cornetto)\n";
}
unless (defined($oovpunishment=$opts{v})) {
    if(($sourcelanguage eq "cornetto") & ($targetlanguage eq "beta")){
            $oovpunishment=2;
	    print STDERR "Use -v option to set Out Of Vocabulary punishment (default=$oovpunishment)\n";
    }
    elsif(($sourcelanguage eq "cornetto") & ($targetlanguage eq "sclera")){ 
	    $oovpunishment=8;
	    print STDERR "Use -v option to set Out Of Vocabulary punishment (default=$oovpunishment)\n";
    }
}
unless (defined($wrongnumber=$opts{w})) {
    if(($sourcelanguage eq "cornetto") & ($targetlanguage eq "beta")){
            $wrongnumber=2;
	    print STDERR "Use -w option to set Wrong Number penalty (default=$wrongnumber)\n";
    }
    elsif(($sourcelanguage eq "cornetto") & ($targetlanguage eq "sclera")){ 
            $wrongnumber=4;
	    print STDERR "Use -w option to set Wrong Number penalty (default=$wrongnumber)\n";
    }
}
unless (defined($nonumber=$opts{n})) {
    if(($sourcelanguage eq "cornetto") & ($targetlanguage eq "beta")){
            $nonumber=9;
	    print STDERR "Use -n option to set No Number penalty (default=$nonumber)\n";
    }
    elsif(($sourcelanguage eq "cornetto") & ($targetlanguage eq "sclera")){
            $nonumber=6;
	    print STDERR "Use -n option to set No Number penalty (default=$nonumber)\n";
    }
}
unless (defined($hyperonympenalty=$opts{h})) {
    if(($sourcelanguage eq "cornetto") & ($targetlanguage eq "beta")){
	    $hyperonympenalty=7;
	    print STDERR "Use -h option to set Hyperonym penalty (default=$hyperonympenalty)\n";
    }
    elsif(($sourcelanguage eq "cornetto") & ($targetlanguage eq "sclera")){
	    $hyperonympenalty=4;
	    print STDERR "Use -h option to set Hyperonym penalty (default=$hyperonympenalty)\n";
    }
}
unless (defined($xpospenalty=$opts{k})) {
    if(($sourcelanguage eq "cornetto") & ($targetlanguage eq "beta")){
            $xpospenalty=6;
	    print STDERR "Use -k option to set XPosNearSynonym penalty (default=$xpospenalty)\n";
    }
    elsif(($sourcelanguage eq "cornetto") & ($targetlanguage eq "sclera")){
            $xpospenalty=3;
	    print STDERR "Use -k option to set XPosNearSynonym penalty (default=$xpospenalty)\n";
    }
}
unless (defined($antonympenalty=$opts{a})) {
    if(($sourcelanguage eq "cornetto") & ($targetlanguage eq "beta")){
	    $antonympenalty=7;
	    print STDERR "Use -a option to set Antonym penalty (default=$antonympenalty)\n";
    }
    elsif(($sourcelanguage eq "cornetto") & ($targetlanguage eq "sclera")){
            $antonympenalty=2;
	    print STDERR "Use -a option to set Antonym penalty (default=$antonympenalty)\n";
    }
}
unless (defined($penaltythreshold=$opts{f})) {
    if(($sourcelanguage eq "cornetto") & ($targetlanguage eq "beta")){
	    $penaltythreshold=8;
	    print STDERR "Use -f option to set penalty threshold (default=$penaltythreshold)\n";
    }
    elsif(($sourcelanguage eq "cornetto") & ($targetlanguage eq "sclera")){
	    $penaltythreshold=11;
	    print STDERR "Use -f option to set penalty threshold (default=$penaltythreshold)\n";
    }
}
unless (defined($dictionary_advantage=$opts{d})) {
    if(($sourcelanguage eq "cornetto") & ($targetlanguage eq "beta")){
	    $dictionary_advantage=5;
	    print STDERR "Use -d option to set Dictionary Advantage (default=$dictionary_advantage)\n";
    }
    elsif(($sourcelanguage eq "cornetto") & ($targetlanguage eq "sclera")){
	    $dictionary_advantage=3;
	    print STDERR "Use -d option to set Dictionary Advantage (default=$dictionary_advantage)\n";
    }
}
unless (defined($wsdweight=$opts{r})) {
    if(($sourcelanguage eq "cornetto") & ($targetlanguage eq "beta")){
	    $wsdweight=2;
	    print STDERR "Use -r option to set WSD weight (default=$wsdweight)\n";
    }
    elsif(($sourcelanguage eq "cornetto") & ($targetlanguage eq "sclera")){
	    $wsdweight=2;
	    print STDERR "Use -r option to set WSD weight (default=$wsdweight)\n";
    }
}
unless (defined($database=$opts{g})) {
    $database="cornetto2";
    print STDERR "Use -g option to set picto database name (default=$database)\n";
}
unless (defined($host=$opts{j})) {
    $host="gobelijn";
    print STDERR "Use -j option to set picto database host (default=$host)\n";
}
unless (defined($port=$opts{m})) {
    $port="5432";
    print STDERR "Use -m option to set picto database port (default=$port)\n";
}
unless (defined($user=$opts{u})) {
    $user="vincent";
    print STDERR "Use -u option to set picto database user (default=$user)\n";
}
unless (defined($pwd=$opts{q})) {
    $pwd="vincent";
    print STDERR "Use -q option to set picto database password (default=$pwd)\n";
}

#---------------------------------------

# Libraries 

require "$Bin/object.pm";
require "$Bin/Database.pm";
require "$Bin/synset.pm";
require "$Bin/simplify_$sourcelanguage.pm";
require "$Bin/picto.pm";
require "$Bin/picto_$sourcelanguage.pm";
require "$Bin/synset_$sourcelanguage.pm";
require "$Bin/wsd.pm";

our $timestamp=time.$main::sessionid;

#---------------------------------------

# Main program

$in=shift(@ARGV);
$in=decode("utf-8",$in);
if ($spellcheckoption eq 'on') { # Improvement 1: Spelling correction 
	$in=`perl $Bin/SpellCorrector_$sourcelanguage.pl "$in"`;
	chomp $in;
}
$sessionid=shift(@ARGV);
$message=message->new(text,$in,
		      target,$targetlanguage);
$message->taglemmatize; # Improvement 2: Syntactic simplification and temporality detection
`rm -rf $Bin/../AlpinoOutputDirectory$timestamp`;
$message->addSynsets;
$message->CornettoWsd; # Improvement #3: Word sense disambiguation
$message->addPictoPaths($targetlanguage);

#---------------------------------------

# Output mode

if ($outputmode eq 'html') {
    $message->HTMLOut; # Generates HTML
}
elsif ($outputmode eq 'text') {
    $message->TextOut; # Generates text
}
elsif ($outputmode eq 'json') {
    $message->JSONOut; # Generates JSON
}
elsif ($outputmode eq 'paralleljson') {
    $message->ParallelJSONOut; # Generates JSON with parallel text
}
else {
    print STDERR "Invalid outputmode, generating text anyway\n";
    $message->TextOut; # Generates text
}
