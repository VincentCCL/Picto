# GenericFunctions.pm
1; #-------------------

$VERSION="2.0"; # french added
#$VERSION="1.2"; # added hindi to the possible source languages and default value for hyperparameters when source and target language are not set
#$VERSION="1.1";  # 29.03.2021 WSD only loaded when activated
#$VERSION="1.0"; # Initial version
# Default and configuration values

use Getopt::Std;  
&LoadDefaultValues;
getopt("abcdefghijklmnopqrstuvwz",\%opts);
processOptions(%opts);
&LoadConfigPaths;
1;

sub LoadConfigPaths {
  unless ($0 eq 'JSON2Picto') {  # only if the name of the calling script is not JSON2Picto
      &LoadShallowProcessingConfig;
      if ($wsdoption) {&LoadWSDConfig;}
      # Location of compounding info for separable verbs
      # Vandeghinste, V. (2002). Lexicon Optimization: Maximizing Lexical Coverage in Speech Recognition through Automated Compounding. In M. Rodríguez and C. Araujo (eds.), Proceedings of the 3rd International Conference on Language Resources and Evaluation (LREC). European Language Resources Association. Las Palmas, Spain.
      if ($sourcelanguage eq 'dutch') {
	  require "$Bin/modules/shallow_dutch.pm"; 
	  &LoadShallowProcessingConfigDutch;  # do somthing similar for English
      }
      #$paralleloutput="$Bin/../tmp/output/ParallelOutput";  # What is this?
  }
  $imgwidth=110;  # this should move to html_out
  $imgheigth=110; # this should move to html_out

}

sub LoadShallowProcessingConfig {
    # Shallow Processing Configuration Paths
    our $tempfilelocation="$Bin/../log/t2p/";
    print $log "tempfilelocation: $tempfilelocation\n" if $log;
    unless (-e $tempfilelocation) {
	`mkdir -p $tempfilelocation`;
	print $log "$tempfilelocation did not exist. Made a new dir\n" if $log;
    }
    # Location of the Hunpos Tagger used in shallow processing
    # Halácsy, Péter, András Kornai, Csaba Oravecz (2007) HunPos - an open source trigram tagger In Proceedings of the 45th Annual Meeting of the Association for Computational Linguistics Companion Volume Proceedings of the Demo and Poster Sessions. Association for Computational Linguistics, Prague, Czech Republic, pages 209--212.
    our $hunposlocation="$Bin/modules/Hunpos/"; # Path of the hunpos application
    unless (-e $hunposlocation) {
	print $log "Set location of HunPos does not exist: $hunposlocation\n";
	die;
    }
    print $log "Tagger location: $hunposlocation\n" if $log;
}

sub LoadWSDConfig {
 our $wsdpath="$Bin/../log/wsd/";
 print $log "wsd path: $wsdpath\n" if $log;
 unless (-e $wsdpath) {
    `mkdir -p $wsdpath`;
    print $log "$wsdpath did not exist. Made a new dir\n" if $log;
 }
 our $wsdinput="$wsdpath/wsdinput";
 our $wsdoutput="$wsdpath/wsdoutput";
 our $wsdconvertedoutput="$wsdpath/wsdconvertedoutput";
 our $wsdtool="$Bin/modules/DutchWSD/svm_wsd-master/dsc_wsd_tagger.py"; 
 unless (-e $wsdtool) {
     print $log "$wsdtool not found.\n" if $log;
     return undef;
 }
 our $wsdconverter="$Bin/modules/TwigDutchSemCor.pl";
 unless (-e $wsdconverter) {
     print $log "$wsdconverter not found.\n" if $log;
     return undef;
 }
}

sub LoadDefaultValues {
    ###### DEFAULT VALUES ###############################
    our (%default,%verbose);
    # source and target language
    $default{'s'}='dutch';
    $verbose{'s'}="-s Source language (dutch/english/spanish/french)";
    $options{'s'}={'dutch'   => 1,
		   'english' => 1,
		   'spanish' => 1,
		   'french' =>1};
    
    $default{'p'}='sclera';
    $verbose{'p'}="-p Target pictograph set (sclera/beta/rand/arasaac)";
    $options{'p'}={'sclera'   => 1,
		   'beta'     => 1,
		   'rand'     => 1,
		   'arasaac'  => 1,};
    
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
		   "dutch,sclera" => 8,
		   "english,beta" => 9,
		   "english,sclera" => 2,
		   "spanish,beta" => 4,
		   "spanish,sclera" => 0,
		   "french,beta" => 2,
		   "french,sclera" => 5,
		   "french,arasaac" => 2,
		   "" => 1};
    $verbose{'v'}="-v Out of Vocabulary penalty";

    $default{'w'}={"dutch,beta"   => 2,
		   "dutch,sclera" => 4,
		   "english,beta" => 0,
		   "english,sclera" => 0,
		   "spanish,beta" => 2,
		   "spanish,sclera" => 1,
		   "french,beta" => 8,
		   "french,sclera" => 2,
		   "french,arasaac" => 6,
		   "" =>1};
    $verbose{'w'}="-w Wrong number penalty";

    $default{'n'}={"dutch,beta"   => 9,
		   "dutch,sclera" => 6,
		   "english,beta" => 4,
		   "english,sclera" => 2,
		   "spanish,beta" => 5,
		   "spanish,sclera" => 4,
		   "french,beta" => 3,
		   "french,sclera" => 2,
		   "french,arasaac" => 10,
		   "" => 1};
    
    $verbose{'n'}="-n No Number penalty";
    
    $default{'h'}={"dutch,beta"   => 7,
		   "dutch,sclera" => 4,
		   "english,beta" => 7,
		   "english,sclera" => 8,
		   "spanish,beta" => 4,
		   "spanish,sclera" => 3,
		   "french,beta"   => 9, 
		   "french,sclera"  => 13, 
		   "french,arasaac" => 10,      
		   "" => 1};
    $verbose{'h'}="-h Hyperonym penalty";

    $default{'k'}={"dutch,beta"   => 6,
		   "dutch,sclera" => 3,
		   "english,beta" => 10,
		   "english,sclera" => 10,
		   "spanish,beta" => 1,
		   "spanish,sclera" => 2,
		   "french,beta"   => 10, 
		   "french,sclera"  => 3,
		   "french,arasaac" => 9,
		   "" => 1};
    $verbose{'k'}="-k XposNearSynonym penalty";

    $default{'a'}={"dutch,beta"   => 7,
		   "dutch,sclera" => 2,
		   "english,beta" => 9,
		   "english,sclera" => 7,
		   "spanish,beta" => 10,
		   "spanish,sclera" => 6,
		   "french,beta"   => 6,            
		   "french,sclera"  => 6,
		   "french,arasaac" => 2,
		   "" => 1};
    $verbose{'a'}="-a Antonym penalty";

    $default{'f'}={"dutch,beta"   => 8,
		   "dutch,sclera" => 11,
		   "english,beta" => 19,
		   "english,sclera" => 9,
		   "spanish,beta" => 10,
		   "spanish,sclera" => 10,
		   "french,beta"   => 12,
		   "french,sclera"  => 11,
		   "french,arasaac" => 12,
		   "" => 8};
    $verbose{'f'}="-f Penalty Threshold";

    $default{'d'}={"dutch,beta"   => 5,
		   "dutch,sclera" => 3,
		   "english,beta" => 8,
		   "english,sclera" => 6,
		   "spanish,beta" => 5,
		   "spanish,sclera" => 5,
		   "french,beta"   => 5, 
		   "french,sclera"  => 12,
		   "french,arasaac" => 9,
		   ""=> 1};
    $verbose{'d'}="-d Dictionary Advantage";

    $default{'r'}={"dutch,beta"   => 2,
		   "dutch,sclera" => 2, 
		   "english,sclera" => 2,
		   "english,beta" => 2,
		   "french,beta"   => 2,
		   "french,sclera"  => 2,
		   "french,arasaac" => 2,
		   "" => 1};
    $verbose{'r'}="-r WSD weight";
    
    # database parameters
    $default{'g'}={"dutch,beta" => "cornetto3",
		   "dutch,sclera" => "cornetto3",
		   "english,beta" => "princeton30new",
		   "english,sclera" => "princeton30new",
		   "spanish,sclera" => "spa30new",
		   "spanish,beta" => "spa30new",
		   "french,sclera" => "fre30",
		   "french,beta" => "fre30",
		   "french,arasaac" => "fre30",
		   "" => "cornetto3" };
    $verbose{'g'}="-g Picto database name";
    $default{'j'}="localhost";
    $verbose{'j'}="-j Picto database host";
    $default{'m'}="5432";
    $verbose{'m'}="-m Picto database port";
    $default{'u'}="vincent";
    $verbose{'u'}="-u Picto database user";
    $default{'q'}="vincent";
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
  else {
      $log=\*STDERR;
  }
  foreach ('s','o','p',sort keys %default) { 
  # we first process -s source, -o output mode, -p pictograph set
    unless ($opts{$_}) {
      if (ref($default{$_}) eq 'HASH') {
        $key="$opts{'s'},$opts{'p'}";
        if ($value=$default{$_}->{$key}) {
	    $opts{$_}=$value;
	}
	else {
	    $value=$default{$_}->{''};
	}
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
  
  our $database=$opts{'g'};#->{"$sourcelanguage,$targetlanguage"};
  #our $database=$opts{'g'};
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
  print $log "Output from $externalSpellCheckerCommand:\n$correct\n";
  chomp $correct;
  
  return $correct;
}
