#!/usr/bin/perl
####### JSON2Picto.pl ###########

# By Vincent Vandeghinste
# Date: 2021
$VERSION="0.1";
#----------------

# USAGE: perl JSON2Picto.pl < hindi.json

# Generic JSON-to-Pictograph translation 
# Expects a JSON input object of type
# [ { "lemma":"dog","synset_id":"02084071n"},{ "lemma":"mailman","synset_id":"10283037n" }, {"lemma":"have", "synset_id":"02630189v" }]
# All we require to generate a picto sequence is a number of synset ids

# -p sclera/beta/rand/arasaac sets the target language pictograph set
# -o html|text|json|paralleljson sets the output mode (html generates valid html with <img> tags, text generates text with filenames (without extensions), json generates JSON, paralleljson generates JSON with images and the associated original input words) 

# -v sets the Out of Vocabulary penalty                                                                                         
# -w sets the Wrong Number penalty                                                                                              
# -n sets the No Number penalty                                                                                                 
# -h sets the Hyperonym penalty                                                                                                 
# -k sets the XposNearSynonym penalty                                                                                           
# -a sets the Antonym penalty                                                                                                   
# -f sets the Penalty Threshold                                                                                                 
# -d sets the Dictionary Advantage                                                                                              
# -r sets the Word Sense Disambiguation Weight                                                                                  

# Takes the following optional input options (location of the WordNet database with the pictograph connections):                

# -g sets the picto database name                                                                                               
# -j sets the picto database host                                                                                               
# -m sets the picto database port                                                                                               
# -u sets the picto database user                                                                                               
# -q sets the picto database password                                                                                           
# -l sets the name of the logfile                                                                                               
# -z maxtime before timeout (seconds)                                                                                           

use FindBin qw($Bin);
use Encode qw(decode);
require "$Bin/modules/GenericFunctions.pm";
use JSON;
require "$Bin/modules/object.pm";
require "$Bin/modules/Database.pm";
require "$Bin/modules/synset.pm";
require "$Bin/modules/picto.pm";

##-------------------
## MAIN PROGRAM
##-------------------

my $json=&readInputJSON;
my $message=&convertJSON2Message($json);
$message->addPictoPaths($targetlanguage);
$message->$outputmode;
#---------------------------------------                                                                                   



sub readInputJSON {
    my $json;
    while (<STDIN>) {
	$json.=$_;
    }
    print $log "JSON input: $json\n" if $log;
    return $json;
}

sub convertJSON2Message {
    my ($json_text)=@_;
    my $json_array= from_json($json_text);
    my $message=message->new(target,$targetlanguage,
			     logfile,$log);
    my @words;
    foreach $el (@$json_array) {
	my $synset_id=$el->{synset_id};
	$synset_id=~s/[nav]$//;  # remove last letter with pos info from synset_id
	$synset=synset->new(logfile,$log,
			    synset,$synset_id,
			    target,$targetlanguage);
	$lexunit=lexunit->new(synset,$synset,
			      logfile,$log);
	$word=word->new(lemma,$el->{lemma},
			lexunits,[$lexunit],
			logfile,$log);
	push(@words,$word);
    }
    my $sentence=sentence->new(words,[@words],
			       logfile,$log);
    $message->{sentences}=[$sentence];
    print $log $message->showInLog if $log;
    return $message;
}

