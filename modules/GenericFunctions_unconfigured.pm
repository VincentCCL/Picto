# GenericFunctions.pm
1; #-------------------

$VERSION="1.0"; # Initial version
# Default and configuration values

use Getopt::Std;  
&LoadDefaultValues;
getopt("abcdefghijklmnopqrstuvwz",\%opts);
processOptions(%opts);
&LoadConfigPaths;
1;

sub LoadConfigPaths {
  &LoadShallowProcessingConfig;
  &LoadWSDConfig;
 # Location of compounding info for separable verbs
 # Vandeghinste, V. (2002). Lexicon Optimization: Maximizing Lexical Coverage in Speech Recognition through Automated Compounding. In M. Rodríguez and C. Araujo (eds.), Proceedings of the 3rd International Conference on Language Resources and Evaluation (LREC). European Language Resources Association. Las Palmas, Spain. 
 use DB_File;
 tie %lexicon,"DB_File","$Bin/../data/total.freqs.db"; # Location of the frequency lexicon (Berkeley)
 tie %headmodsolo,"DB_File","$Bin/../data/ModHead.freqs.db"; # Location of the database containing frequency information about heads and modifiers in compound nouns (Berkeley)
 tie %difmod,"DB_File","$Bin/../data/DifModsPerHead.db"; # Location of the database containing info on how many different mods were found per head (Berkeley)
 $compoundprobthreshold=0.05; # Cf Vandeghinste (2002) for more info
       # P(stroopsmeren)=0.049
        # P(doorgeef)=0.0028
 #---------------------------------------
 # Lemma database extracted from CGN and Lassy
 tie %LEMMAS,"DB_File","$Bin/../data/lemmas.db";

 # Opentaal lexicon
 tie %SPELLCHECKLEX,"DB_File","$Bin/../data/spellchecklex.db";

 # Firstnames lexicon
 tie %FIRSTNAMES,"DB_File","$Bin/../data/firstnames.db"; # List of all first names of all people living in Belgium in 2009 occuring more than once
 $maxlengthwordinspellcheck=30;
 $paralleloutput="$Bin/../tmp/output/ParallelOutput";
 $imgwidth=110; 
 $imgheigth=110; 

}

sub LoadShallowProcessingConfig {
 # Shallow Processing Configuration Paths
 our $tempfilelocation="$Bin/../tmp/picto/";
 print $log "tempfilelocation: $tempfilelocation\n" if $log;
 unless (-e $tempfilelocation) {
    `mkdir -p $tempfilelocation`;
    print $log "$tempfilelocation did not exist. Made a new dir\n" if $log;
 }
 # Location of the Hunpos Tagger used in shallow processing
 # Halácsy, Péter, András Kornai, Csaba Oravecz (2007) HunPos - an open source trigram tagger In Proceedings of the 45th Annual Meeting of the Association for Computational Linguistics Companion Volume Proceedings of the Demo and Poster Sessions. Association for Computational Linguistics, Prague, Czech Republic, pages 209--212.
 our $hunposlocation="$Bin/../Hunpos/"; # Path of the hunpos application
 print $log "Tagger location: $hunposlocation\n" if $log;
}

sub LoadWSDConfig {
 our $wsdpath="$Bin/../tmp/wsd/";
 print $log "wsd path: $wsdpath\n" if $log;
 unless (-e $wsdpath) {
    `mkdir -p $wsdpath`;
    print $log "$wsdpath did not exist. Made a new dir\n" if $log;
 }
 our $wsdinput="$wsdpath/wsdinput";
 our $wsdoutput="$wsdpath/wsdoutput";
 our $wsdconvertedoutput="$wsdpath/wsdconvertedoutput";
 our $wsdtool="$Bin/../DutchWSD/svm_wsd-master/dsc_wsd_tagger.py"; 
 our $wsdconverter="$Bin/TwigDutchSemCor.pl";
}

sub LoadDefaultValues {
 ###### DEFAULT VALUES ###############################
 our (%default,%verbose);
 # source and target language
 $default{'s'}='dutch';
 $verbose{'s'}="-s Source language (dutch/english/spanish)";
 $options{'s'}={'dutch'   => 1,
                'english' => 1,
                'spanish' => 1};

 $default{'p'}='sclera';
 $verbose{'p'}="-p Target pictograph set (sclera/beta/rand)";
 $options{'p'}={'sclera'   => 1,
                'beta'     => 1,
                'rand'     => 1};

 $default{'o'}='html';
 $verbose{'o'}="-o Output mode (html/text/json/paralleljson)";
 $options{'o'}={'html'    => 1,
                'text'    => 1,
                'json'    => 1,
                'paralleljson' => 1};

 # modules
 $default{'e'}='off';
 $verbose{'e'}="-e Spell checker (on/off)";
 $options{'e'}={'on'   => 1,
                'off' => 1};

 $default{'b'}='off';
 $verbose{'b'}="-b WSD module (on/off)";
 $options{'b'}={'on'   => 1,
                'off' => 1};

 $default{'c'}='none';
 $verbose{'c'}="-c Simplification level (none/simplify/compress)";
 $options{'c'}={'none'     => 1,
                'simplify' => 1,
                'compress' => 1};

 $default{'t'}='off';
 $verbose{'t'}="-t Time analysis module (only works with -c simplify) (on/off)";
 $options{'t'}={'on'   => 1,
                'off' => 1};

 # runtime parameters
 $default{'z'}=120;
 $verbose{'z'}="-z maxtime (seconds)";

 $default{'v'}={"dutch,beta"   => 2,
               "dutch,sclera" => 8};
 $verbose{'v'}="-v Out of Vocabulary penalty";

 $default{'w'}={"dutch,beta"   => 2,
               "dutch,sclera" => 4};
 $verbose{'w'}="-w Wrong number penalty";

 $default{'n'}={"dutch,beta"   => 9,
               "dutch,sclera" => 6};
 $verbose{'n'}="-n No Number penalty";

 $default{'h'}={"dutch,beta"   => 7,
               "dutch,sclera" => 4};
 $verbose{'h'}="-h Hyperonym penalty";

 $default{'k'}={"dutch,beta"   => 6,
               "dutch,sclera" => 3};
 $verbose{'k'}="-k XposNearSynonym penalty";

 $default{'a'}={"dutch,beta"   => 7,
               "dutch,sclera" => 2};
 $verbose{'a'}="-a Antonym penalty";

 $default{'f'}={"dutch,beta"   => 8,
               "dutch,sclera" => 11};
 $verbose{'f'}="-f Penalty Threshold";

 $default{'d'}={"dutch,beta"   => 5,
               "dutch,sclera" => 3};
 $verbose{'d'}="-d Dictionary Advantage";

 $default{'r'}={"dutch,beta"   => 2,
               "dutch,sclera" => 2};
 $verbose{'r'}="-r WSD weight";

 # database parameters
 $default{'g'}="picto";
 $verbose{'g'}="-g Picto database name";
 $default{'j'}="picto";
 $verbose{'j'}="-j Picto database host";
 $default{'m'}="5432";
 $verbose{'m'}="-m Picto database port";
 $default{'u'}="picto";
 $verbose{'u'}="-u Picto database user";
 $default{'q'}="picto";
 $verbose{'q'}="-q Picto database password";
}

sub processOptions {
  my (%opts)=@_;
  our $starttime=time;
  our $timestamp=time.$main::sessionid;
  if ($logfile=$opts{'l'}) {
    $log=&OpenLogfile($logfile);
    print $log "\nOptions & Parameters\n" if $log;
    print $log "=====================\n" if $log;
  }
  foreach ('s','o','p',sort keys %default) { 
  # we first process -s source, -o output mode, -p pictograph set
    unless ($opts{$_}) {
      if (ref($default{$_}) eq 'HASH') {
        $key="$opts{'s'},$opts{'p'}";
        $value=$default{$_}->{$key};
        $opts{$_}=$value;
        print STDERR "$verbose{$_} set to default '$value'\n";
        print $log "$verbose{$_} set to default '$value'\n" if $log;
      }
      else {
        $opts{$_}=$default{$_};
        print STDERR "$verbose{$_} set to default '$default{$_}'\n";
        print $log "$verbose{$_} set to default '$default{$_}'\n" if $log;
      }
    }
    else {
      # check if option is possible
      if (my $options=$options{$_}) {
        unless ($options->{$opts{$_}}) {
          # option is not defined
          print STDERR "Set option '$opts{$_}' is not a possible option for switch '$_'\n";
          print $log "Set option '$opts{$_}' is not a possible option for switch '$_'\n" if $log;
          $opts{$_}=$default{$_};
          print STDERR "$verbose{$_} set to default '$opts{$_}'\n";
          print $log "$verbose{$_} set to default '$opts{$_}'\n" if $log;
        }
      }
    }
  }
  print $log "\n==========================================\n" if $log;
  our $sourcelanguage=$opts{'s'};
  our $outputmode=$opts{'o'};
  our $targetlanguage=$opts{'p'};
  
  our $spellcheckoption=$opts{'e'};
  our $wsdoption=$opts{'b'};
  our $simplificationlevel=$opts{'c'};
  our $timeanalysis=$opts{'t'};
  our $maxtime=$opts{'z'};
  
  our $oovpunishment=$opts{'v'}->{"$sourcelanguage,$targetlanguage"};
  our $wrongnumuber=$opts{'w'}->{"$sourcelanguage,$targetlanguage"};
  our $nonumber=$opts{'n'}->{"$sourcelanguage,$targetlanguage"};
  our $hyperonympenalty=$opts{'h'}->{"$sourcelanguage,$targetlanguage"};
  our $xpospenalty=$opts{'k'}->{"$sourcelanguage,$targetlanguage"};
  our $antonympenalty=$opts{'a'}->{"$sourcelanguage,$targetlanguage"};
  our $penaltythreshold=$opts{'f'}->{"$sourcelanguage,$targetlanguage"};
  our $dictionary_advantage=$opts{'d'}->{"$sourcelanguage,$targetlanguage"};
  our $wsdweight=$opts{'r'}->{"$sourcelanguage,$targetlanguage"};
  
  our $database=$opts{'g'};
  our $host=$opts{'j'};
  our $port=$opts{'m'};
  our $user=$opts{'u'};
  our $pwd=$opts{'q'};
}

#---------------------------------------
# LOG FILE HEADER
sub OpenLogfile {
  my ($logfile)=@_;
  open(LOG,">:utf8",$logfile) or warn ("Can't open $logfile\n");
  print LOG "TextToPicto.pl version 4.\n"; 
  print LOG "-------------------------\n";
  print LOG "(c) 2019\nTime stamp: $timestamp\n";
  return \*LOG;
}
#---------------------------------------
# Maximum time for processing
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
sub externalSpellChecker {
  my ($in)=@_;
  my $externalSpellCheckerCommand="perl $Bin/SpellCorrector_$sourcelanguage.pl";
  my $correct;
  if ($log) {
    print $log "$externalSpellCheckerCommand \"$in\"\n";
    print $log "\n========== EXTERNAL SPELL CHECKER LOGGING=================\n"; 
    close $log;
    $correct=`$externalSpellCheckerCommand "$in" 2>> $logfile`;
  }
  else {
    $correct=`$externalSpellCheckerCommand "$in"`;
  }
  if ($log) {
    open(LOG,">>:utf8",$logfile);
    $log=\*LOG;
    print $log "\n========== END OF EXTERNAL SPELL CHECKER LOGGING==============\n";
  }
  chomp $correct;
  return $correct;
}
