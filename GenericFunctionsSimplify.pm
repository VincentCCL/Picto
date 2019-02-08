# GenericFunctionsSimplify.pm
1; #---------------------------

# Default and configuration values

###### DEFAULT VALUES ######

our (%alpino,%path);
# Paths to files

$alpino{'server'}="jerom 11222"; # contains the server and port for alpino server in docker https://github.com/rug-compling/alpino-docker

# unless ($alpino{'server'}) {
#   $path{'a'}="$Bin/../tmp/alpino/inputforalpino";
#   $verbose{'a'}="-a Temporary input file for Alpino";
# 
#   $path{'b'}="$Bin/parse_file.sh";
#   $verbose{'b'}="-b Alpino parser script";
# 
#   $path{'c'}="$Bin/../AlpinoOutputDirectory$stamp";
#   $verbose{'c'}="-c Temporary Alpino treebank output directory";
# 
#   $path{'d'}="$Bin/../AlpinoOutputDirectory$stamp/treebank.xml";
#   $verbose{'d'}="-d Treebank XML file in Alpino output directory";
# }


$path{'e'}="$Bin/../data/Regels_V2_1ww.txt";
$verbose{'e'}="-e Rules for verb group consisting of 1 verb";

$path{'f'}="$Bin/../data/Regels_V2_2ww.txt";
$verbose{'f'}="-f Rules for verb group consisting of 2 verbs";

$path{'g'}="$Bin/../data/Regels_V2_3ww.txt";
$verbose{'g'}="-g Rules for verb group consisting of 3 verbs";

$path{'h'}="$Bin/../../Picto2.0/data/firstnames.db";
$verbose{'h'}="-h First names lexicon";

# Alpino parser timeout parameter

$path{'i'}=40;
$verbose{'i'}="Alpino parser timeout parameter";

sub processOptionsSimplify {
  my (%opts)=@_;
  print $log "============ SIMPLIFICATION OPTIONS ===========\n" if $log;
  foreach (sort keys %path) {
    unless ($opts{$_}) {
        $opts{$_}=$path{$_};
        print $log "$verbose{$_} set to default '$path{$_}'\n" if $log;
    }
  }

  our $inputforalpino=$opts{'a'};
  our $alpinoparsefile=$opts{'b'};
  our $treebankoutput=$opts{'c'};
  our $treebankoutputfile=$opts{'d'};
  our $oneverbrules=$opts{'e'};
  our $twoverbsrules=$opts{'f'};
  our $threeverbsrules=$opts{'g'};
  our $firstnamesdb=$opts{'h'};

  our $timeout=$opts{'i'};

}
