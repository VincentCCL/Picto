#!/usr/bin/perl
####### TextToPicto.pl ##########

# By Leen Sevens and Vincent Vandeghinste
# leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 2019
$VERSION="4.0";
#---------------------------------------

# Generic Text-to-Pictograph translation for multiple languages (with advanced linguistic analysis)
# Example: perl TextToPicto.pl -p beta -s cornetto -o paralleljson -e on -b on -c simplify -t on 'dit wiekent ga ik naarhuis'

#---------------------------------------

# Takes the following obligatory input options:

# -p sclera|beta|rand sets the pictograph set used in the output
# -s cornetto|dutch|spanish|english sets the source language/database
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
# -l sets the name of the logfile
# -z maxtime before timeout (seconds)

#---------------------------------------

use Getopt::Std;  
use FindBin qw($Bin); 
use Encode qw(decode);
# use File::Path qw( rmtree ); ## WHAT IS THIS?
require "$Bin/GenericFunctions.pm";

#---------------------------------------


getopt("abcdefghijklmnopqrstuvwz",\%opts);
processOptions(%opts);


# Libraries 

require "$Bin/object.pm";
require "$Bin/Database.pm";
require "$Bin/synset.pm";
require "$Bin/picto.pm";
require "$Bin/synset_$sourcelanguage.pm";
unless ($simplificationlevel eq 'none') {
 require "$Bin/simplify_$sourcelanguage.pm";
}
else { 
 require "$Bin/shallow_$sourcelanguage.pm";
}
require "$Bin/wsd.pm" if $wsdoption eq 'on';


#---------------------------------------
# Main program
#---------------------------------------

$in=shift(@ARGV);
$in=decode("utf-8",$in);
$in=&externalSpellChecker($in) if $spellcheckoption eq 'on';
chomp($in);


$sessionid=shift(@ARGV);
$message=message->new(text,$in,
		      target,$targetlanguage,
		      logfile,$log);
$message->taglemmatize; # Improvement 2: Syntactic simplification and temporality detection

# `rm -rf $Bin/../AlpinoOutputDirectory$timestamp`; # DIT HOORT HIER NIET THUIS
$message->addSynsets;
$message->CornettoWsd if $wsdoption eq 'on'; # Improvement #3: Word sense disambiguation
$message->addPictoPaths($targetlanguage);
$message->$outputmode;
#---------------------------------------

