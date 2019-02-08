# GenericFunctionsSpellcheck.pm
1; #---------------------------

# Default and configuration values

###### DEFAULT VALUES ######

use FindBin qw($Bin); 

&LoadDefaultParameters;

sub LoadDefaultParameters {
  our (%default,%verbose); 

  # Runtime parameters

  $default{'a'}=210;
  $verbose{'a'}="Word builder penalty 1";

  $default{'b'}=120;
  $verbose{'b'}="Word builder penalty 2";

  $default{'c'}=100;
  $verbose{'c'}="Real word minimum frequency";

  $default{'d'}=8;
  $verbose{'d'}="Length of n-grams in fuzzy matching";

  $default{'e'}=0.2;
  $verbose{'e'}="Minimum fuzzy matching scores";

  $default{'f'}=1760;
  $verbose{'f'}="Word splitter penalty 1";

  $default{'g'}=220;
  $verbose{'g'}="Minimum frequency to retain a variant";

  $default{'h'}=100;
  $verbose{'h'}="Highest frequency threshold in fuzzy matching";

  $default{'i'}=1680;
  $verbose{'i'}="Word splitter penalty 2";

  $default{'E'}=4;
  $verbose{'E'}="Maximum character gap for replacement during fuzzy matching";

 # Picto database parameters

  $default{'j'}="cornetto3";
  $verbose{'j'}="Picto database name";
  $default{'k'}="gobelijn";
  $verbose{'k'}="Picto database host";
  $default{'l'}="5432";
  $verbose{'l'}="Picto database port";
  $default{'m'}="vincent";
  $verbose{'m'}="Picto database user";
  $default{'n'}="vincent";
  $verbose{'n'}="Picto database password";

  # Language model database parameters

  $default{'o'}="dutch_lm_large";
  $verbose{'o'}="Language model database name";
  $default{'p'}="gobelijn";
  $verbose{'p'}="Language model database host";
  $default{'q'}="5432";
  $verbose{'q'}="Language model database port";
  $default{'r'}="vincent";
  $verbose{'r'}="Language model database user";
  $default{'s'}="vincent";
  $verbose{'s'}="Language model database password";

# Paths to files

  $default{'t'}="$Bin/../data/spellchecklex.db";
  $verbose{'t'}="Spell check lexicon";
 
  $default{'u'}="$Bin/../data/firstnames.db";
  $verbose{'u'}="First names lexicon";

  $default{'v'}="$Bin/../data/total.freqs.db";
  $verbose{'v'}="Frequency database";
 
  $default{'w'}="$Bin/../Wordbuilder/SingleWordSplitter.pl";
  $verbose{'w'}="Word splitter script";

  $default{'x'}="$Bin/../Wordbuilder/outputsplitter";
  $verbose{'x'}="Output location for word splitter";

  $default{'y'}="$Bin/../tmp/spellcheck/inputfuzzymatch";
  $verbose{'y'}="Input location for fuzzy matching";

  $default{'z'}="$Bin/../tmp/spellcheck/outputfuzzymatch";
  $verbose{'z'}="Output location for fuzzy matching";

  $default{'A'}="$Bin/get_approxquerycov_matches.bash";
  $verbose{'A'}="Fuzzy matching script";

  $default{'B'}="$Bin/../data/CGNCorpusSplit.txt";
  $verbose{'B'}="Location of tokenised corpus";

  $default{'C'}="$Bin/../tmp/fuzzy";
  $verbose{'C'}="Temporary location for fuzzy matching";

  $default{'D'}=".";
  $verbose{'D'}="Location of the directory that contains get_nbest_matches.awk and the SALM directory";

  $default{'F'}="$Bin/object.pm";
  $verbose{'F'}="Location of object.pm";

  $default{'G'}="$Bin/Database.pm";
  $verbose{'G'}="Location of Database.pm";
}

sub processOptionsSpellcheck {
  my (%opts)=@_;

  foreach (sort keys %default) {
    unless ($opts{$_}) {
        $opts{$_}=$default{$_};
        print STDERR "$verbose{$_} set to default '$default{$_}'\n";
    }
  }

  our $wordbuilderpenalty1=$opts{'a'};
  our $wordbuilderpenalty2=$opts{'b'};
  our $realwordminimumfrequency=$opts{'c'};
  our $ngramlength=$opts{'d'};
  our $minimumscore=$opts{'e'};
  our $wordsplitterpenalty1=$opts{'f'};
  our $frequencyretainvariant=$opts{'g'};
  our $highestfreqthresh=$opts{'h'};
  our $wordsplitterpenalty2=$opts{'i'};
  our $maximumcharactergap=$opts{'E'};

  our $pictodatabase=$opts{'j'};
  our $pictohost=$opts{'k'};
  our $pictoport=$opts{'l'};
  our $pictouser=$opts{'m'};
  our $pictopwd=$opts{'n'};

  our $lmdatabase=$opts{'o'};
  our $lmhost=$opts{'p'};
  our $lmport=$opts{'q'};
  our $lmuser=$opts{'r'};
  our $lmpwd=$opts{'s'};

  our $spellchecklexfile=$opts{'t'};
  our $firstnamesfile=$opts{'u'};
  our $lexiconfile=$opts{'v'};
  our $singlewordsplitter=$opts{'w'};
  our $outputforsinglewordsplitter=$opts{'x'};
  our $inputfuzzymatch=$opts{'y'};
  our $outputfuzzymatch=$opts{'z'};
  our $fuzzymatcher=$opts{'A'};
  our $tokenizedcorpus=$opts{'B'};
  our $tmpdirectoryfuzzy=$opts{'C'};
  our $salmscriptsdirectory=$opts{'D'};
  our $objectpm=$opts{'F'};
  our $databasepm=$opts{'G'};

}
