####### WordAssociationPredictor.pl ##########

# By Leen Sevens 
# leen@ccl.kuleuven.be 
# Date: 04.04.2018

#---------------------------------------

# Semantic associations based prediction tool
# Example: perl WordAssociationPredictor.pl -p beta 'ik zijn_ww blij'

#---------------------------------------

# See also: Sevens L., Daems J., De Vliegher A., Schuurman I., Vandeghinste V., Van Eynde F. (2017). Building an Accessible Pictograph Interface for Users with Intellectual Disabilities. In: Cudd P., de Witte L. (Eds.), Harnessing the Power of Technology to Improve Lives, (pp. 870-877) IOS Press.

# See also: Sevens L., Vandeghinste V., Schuurman I., Van Eynde F. (2015). Natural Language Generation from Pictographs. In Belz, A. (Ed.), Gatt, A. (Ed.), Portet, F. (Ed.), Purver, M. (Ed.), Proceedings of the 15th European Workshop on Natural Language Generation (ENLG). European Workshop on Natural Language Generation. Brighton, UK, 10-11 September 2015 (pp. 71-75) Association for Computational Linguistics.

#---------------------------------------

# Takes the following obligatory input options:

# -p sclera|beta sets the pictograph set used in the output

#---------------------------------------

# Takes the following optional input options (location of the database):

# -g sets the picto database name
# -j sets the picto database host
# -m sets the picto database port
# -u sets the picto database user
# -q sets the picto database password

#---------------------------------------

getopt("gjmpqu",\%opts);
unless ($pictolanguage=$opts{p}) {
    print STDERR "Use -p option to set picto language (sclera/beta)\n";
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

use Getopt::Std; 
use FindBin qw($Bin); 
use DB_File;
use Encode;
require "$Bin/Database.pm";
require "$Bin/synset.pm";
require "$Bin/object.pm";

$database="$main::database";
$host="$main::host";
$port="$main::port";
$user="$main::user";
$pwd="$main::pwd";

$DiscoTool="$Bin/disco_linguatools/disco-1.4.jar";
$DiscoDirectory="$Bin/disco_linguatools/nl-general-20081004";
$DiscoOutput="$Bin/../tmp/disco/disco";

$revlemmatizer="$Bin/../data/revlemmas.sonar41.db";

tie %lexicon,"DB_File","$Bin/../data/total.freqs.db"; 
tie %LEMMAS,"DB_File","$Bin/../data/DutchTokenLemma.db"; 

my $stamp=time.$main::sessionid;

#---------------------------------------

# MAIN PROGRAM

$in=shift(@ARGV);
$message=message->new(text,$in,
		      logfile,\*LOG,
		      target,$pictolanguage);
$message->tokenize2;
$message->retrieveAssociations;
$message->intersectAssociations;

#---------------------------------------
package message;
#---------------------------------------

sub tokenize2 {
    my ($pkg)=@_;
    $_=$pkg->{text};
    my $log=$pkg->{logfile};
    print $log "Tokenize '$_'\n";
    my @words;
    s/([\(\),\.\"\?!]+)/ $1 /g;
    my @tokens=split(/\s+/);
    foreach (@tokens) {
    	push(@words,word->new(logfile,$pkg->{logfile},
			      token,$_,
			      target,$pkg->{target},
			      wordnetdb,$pkg->{wordnetdb}));
	print $log "\t$_\n";
    }
    print $log "--------------\n";
    $pkg->{words}=[@words];
}

sub retrieveAssociations {
    my ($pkg)=@_;
    $pkg->openDatabase;
    my $pictos=$pkg->{words};
    foreach (@$pictos) {
	$_->{target}=$pkg->{target};
	$_->{wordnetdb}=$pkg->{wordnetdb};
	$_->retrieveLemmas;
        $mostFreqLemma=$_->findMostFrequentLemma;
	$_->{mostFreqLemma}=$mostFreqLemma;
	$_=$_->findAssociations;
        $_->lemmatizeAssociations;
	if($_->{dependentlemmalist}){
		$mostFreqDepLemma=$_->findMostFrequentDepLemma;
		$_->{mostFreqDepLemma}=$mostFreqDepLemma;
		$_=$_->findDepAssociations;
  		$_->lemmatizeDepAssociations;
	}
    }
}

sub intersectAssociations {
     my ($pkg)=@_;
     my %hash=(); 
     my $words=$pkg->{words};
     my $target=$pkg->{target};
     my $amountofwords=scalar(@$words);
     foreach(@$words){
	my $associations=$_->{associations};
	my $depAssociations=$_->{depassociations};
        foreach(@$associations){
		($lemma,$freq)=split(/\t/,$_);
		if (exists $hash{$lemma}) {
			$hash{$lemma}=$hash{$lemma}+$freq;
		}
		else{
			$hash{$lemma}=$freq;
		}
	}
 	foreach(@$depAssociations){
		($lemma,$freq)=split(/\t/,$_);
		if (exists $hash{$lemma}) {
			$hash{$lemma}=$hash{$lemma}+$freq;
		}
		else{
			$hash{$lemma}=$freq;
		}
	}
     }
     foreach my $key (keys %hash) {
	 my $newfreq=$hash{$key}/$amountofwords;
    	 $hash{$key}=$newfreq;
     }
     my $i=0;
     my @array=();
     LOOP: {
	     foreach my $key (sort {$hash{$b} <=> $hash{$a}} keys %hash){
	     my $sql="select id from lexunits where seq='1' and lemma='$key';";
	     my $results=$pkg->{wordnetdb}->lookup($sql);
	     foreach $result (@$results) {
		     my $sql2="select synset from lex2syn where lexunit='$result->[0]';";
	   	     my $results2=$pkg->{wordnetdb}->lookup($sql2);
		     foreach $result2 (@$results2) {
		   	my $sql3="select lemma from $target where synset='$result2->[0]';";
	   	     	my $results3=$pkg->{wordnetdb}->lookup($sql3);
			   if(@$results3){
				if (grep(/^@$results3[0]->[0]$/,@array)){
					next;
				}
				else{
					my $logarithm=log($hash{$key})/log(10);
					print "@$results3[0]->[0]\t$logarithm\n";
					push(@array,@$results3[0]->[0]);
					$i++;
					if ($i eq 200){
						last LOOP;
					}
					else{
						next;
					}
				}
			   }
			   else{
			   	next;
			   }
		     }
	     }
     }
     }
}

sub openDatabase{  
    my ($pkg)=@_;
    unless ($pkg->{wordnetdb}) {
	    my $db=DBI::db->new($main::database,
				$main::host,
				$main::port,
				$main::user,
				$main::pwd);
	    $pkg->{wordnetdb}=$db;
   }
}

#---------------------------------------
package word;
#---------------------------------------
		       
sub retrieveLemmas {
    my ($pkg)=@_;
    my $target=$pkg->{target};
    my $token=$pkg->{token};
    my (@directRoute,@lemmaList,@dependentLemmaList);
    if (-e "$main::Bin/../$target/$token.png") { 
	$pkg->findSynsets;
        push(@lemmaList,$pkg->makeLemmaList);
        push(@dependentLemmaList,$pkg->makeDependentList);
	push(@directRoute,$pkg->checkDictionary); 
	push(@directRoute,$pkg->checkPronouns); 
	foreach(@directRoute){
		$lemma=$_->{lemma};
		push(@lemmaList,$lemma);	
	}
	my @uniqueLemmaList = do { my %seen; grep { !$seen{$_}++ } @lemmaList };
	my @uniqueDepLemmaList = do { my %seen; grep { !$seen{$_}++ } @dependentLemmaList };
        $pkg->{lemmalist}=[@uniqueLemmaList];
        if (@uniqueDepLemmaList){
        	$pkg->{dependentlemmalist}=[@uniqueDepLemmaList];
	}
	delete $pkg->{synsets};
    }
    else{
	next;
    }
}

sub makeLemmaList {
    my ($pkg)=@_;
    my @lemmaList;
    my $synsets=$pkg->{synsets};
    foreach(@$synsets){
	$lexunits=$_->{lexunits};
	foreach(@$lexunits){
		$lemma=$_->{lexunits}->[0]->{lemma};
		if ($lemma){
			push(@lemmaList,$lemma);
		}
	}
    }
    return @lemmaList;
}

sub makeDependentList {
    my ($pkg)=@_;
    my @dependentLemmaList;
    my $synsets=$pkg->{synsets};
    foreach(@$synsets){
	$dependents=$_->{dependents};
	foreach(@$dependents){
		$lexunits=$_->{lexunits};
		foreach(@$lexunits){
			$lemma=$_->{lexunits}->[0]->{lemma};	
			if ($lemma){
				push(@dependentLemmaList,$lemma);
			}
		}	
	}
    }
    return @dependentLemmaList;
}

sub findMostFrequentLemma {
    my ($pkg)=@_;
    my $lemmaList=$pkg->{lemmalist};
    my $maxfreq=0;
    my $best;
    foreach (@$lemmaList) {
	if ($main::lexicon{$_} > $maxfreq) {
	    $best=$_;
	    $maxfreq=$main::lexicon{$_};
	}
    }
    return $best;
}

sub findMostFrequentDepLemma {
    my ($pkg)=@_;
    my $dependentLemmaList=$pkg->{dependentlemmalist};
    my $maxfreq=0;
    my $best;
    foreach (@$dependentLemmaList) {
	if ($main::lexicon{$_} > $maxfreq) {
	    $best=$_;
	    $maxfreq=$main::lexicon{$_};
	}
    }
    return $best;
}

sub findAssociations {
    my ($pkg)=@_;
    my $mostFreqLemma=$pkg->{mostFreqLemma};
    @discoOutput=();
    if ($mostFreqLemma){
	    if(($mostFreqLemma eq "zijn") || ($mostFreqLemma eq "gaan")){
		next;
	    }
	    else{
		    `java -jar $main::DiscoTool $main::DiscoDirectory -bn $mostFreqLemma 200 >> $main::DiscoOutput$stamp.txt`;
		    open (Disco,"$main::DiscoOutput$stamp.txt"); 
		    while (<Disco>) {
			push(@discoOutput,$_);	
		    }	
		    `rm -f $main::DiscoOutput$stamp.txt`;
		    $pkg->{associations}=[@discoOutput];
	    }
    }
    return $pkg;
}

sub findDepAssociations {
    my ($pkg)=@_;
    my $mostFreqDepLemma=$pkg->{mostFreqDepLemma};
    @discoOutput=();
    if ($mostFreqDepLemma){
	    if(($mostFreqLemma eq "zijn") || ($mostFreqLemma eq "gaan")){
		next;
	    }
	    else{
		    `java -jar $main::DiscoTool $main::DiscoDirectory -bn $mostFreqDepLemma 200 >> $main::DiscoOutput$stamp.txt`;
		    open (Disco,"$main::DiscoOutput$stamp.txt"); 
		    while (<Disco>) {
			push(@discoOutput,$_);	
		    }	
		    `rm -f $main::DiscoOutput$stamp.txt`;
		    $pkg->{depassociations}=[@discoOutput];
	    }
    }
    return $pkg;
}

sub lemmatizeAssociations {
    my ($pkg)=@_;
    my $associations=$pkg->{associations};
    my @lemmatizedAssociations;
    foreach (@$associations){
	($token,$freq,$end)=split(/\t/,$_);
	my $lemma=$main::LEMMAS{$token};
	$lemmafreq=$lemma."\t".$freq;
	push(@lemmatizedAssociations,$lemmafreq);
    }
    $pkg->{associations}=[@lemmatizedAssociations];
}

sub lemmatizeDepAssociations {
    my ($pkg)=@_;
    my $dependentAssociations=$pkg->{dependentassociations};
    my @lemmatizedDependentAssociations;
    foreach (@$dependentAssociations){
	($token,$freq,$end)=split(/\t/,$_);
	my $lemma=$main::LEMMAS{"$tok"};
	$lemmafreq=$lemma."\t".$freq;
	push(@lemmatizedDependentAssociations,$lemmafreq);
    }
    $pkg->{dependentassociations}=[@lemmatizedDependentAssociations];
}

sub findSynsets {
    my ($pkg)=@_;
    my $target=$pkg->{target};
    my $token=$pkg->{token};
    my $sql="select * from $pkg->{target} where lemma='$token';";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    foreach (@$results) {
	($token,$synset,$relation,$headsynset,$headrelation,$depsynsets,$deprelation)=@$_;
	if ($synset) {
 		$synsetobject=synset->new(logfile,$pkg->{logfile},
				wordnetdb,$pkg->{wordnetdb},
				synset,$synset,
				target,$pkg->{target});
	    	$synsetobject->addLemmas;
	    	$pkg->pushFeature(synsets,[$synsetobject]);
	}
	elsif ($headsynset) {
		$headsynsetobject=synset->new(logfile,$pkg->{logfile},
				    wordnetdb,$pkg->{wordnetdb},
				    synset,$headsynset,
				    target,$pkg->{target});
	   	$headsynsetobject->addLemmas;
		$pkg->pushFeature(synsets,[$headsynsetobject]);
		@depsynsets=split(/,/,$depsynsets);
   		foreach $depsynset (@depsynsets) {
			$depsynsetobject=synset->new(logfile,$pkg->{logfile},
					       wordnetdb,$pkg->{wordnetdb},
					       synset,$depsynset,
					       target,$pkg->{target});
			$depsynsetobject->addLemmas;
			$headsynsetobject->pushFeature(dependents,[$depsynsetobject]);
		}
	}
    }
}

sub checkDictionary {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my $file=$token.".png";
    my $target=$pkg->{target};
    my $dicttable=$target."_dictionary";
    my $sql="select * from $dicttable where picto = '$file';";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    my @alternatives;
    foreach (@$results) {
	$wo=word->new(target,$pkg->{target},
		      wordnetdb,$pkg->{wordnetdb},
		      logfile,$pkg->{logfile});
	if ($_->[1]) {
	    $wo->{lemma}=$_->[1];
	    push(@alternatives,$wo);	
	}
    }
    return @alternatives;
}

sub checkPronouns {
	my ($pkg)=@_;
	my @alternatives;
	if ($pkg->{target} eq 'beta') {
	      my $token=$pkg->{token};
	      if ($token eq 'ik'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'ik');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'mijn'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'mijn');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'mij');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'wij'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'wij');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'we');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'ons'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'ons');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'onze');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'jij'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'jij');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'je');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'jouw'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'jouw');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'je');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'jou');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'jullie_vnw'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'jullie');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'jullie_bvnw'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'jullie');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'hij'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'hij');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'zijn_bvnw'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'zijn');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'hem');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'zij_enkelv'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'zij');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'ze');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'haar_bvnw'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'haar');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'zij_meerv'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'zij');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'ze');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'hun'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'hun');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'hen');
		push(@alternatives,$wo);
		return @alternatives;
	        }
	}   
	elsif ($pkg->{target} eq 'sclera') {
	      my $token=$pkg->{token};
	      if ($token eq 'ik'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'ik');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'mijn-2'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'mijn');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'mij');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'wij'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'wij');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'we');
		push(@alternatives,$wo);
		return @alternatives;
              }
	      if ($token eq 'ons'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'ons');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'onze');
		push(@alternatives,$wo);
 		return @alternatives;
	      }
	      if ($token eq 'jij'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'jij');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'je');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'jouw'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'jouw');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'je');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'jou');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'jullie'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'jullie');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'jullie-3'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'jullie');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'hij'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'hij');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'zijn'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'zijn');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'hem');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'zij'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'zij');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'ze');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'haar-2'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'haar');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'zij-2'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'zij');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'ze');
		push(@alternatives,$wo);
		return @alternatives;
	      }
	      if ($token eq 'jullie-3'){
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'hun');
		push(@alternatives,$wo);
		$wo=word->new(target,$pkg->{target},
			  wordnetdb,$pkg->{wordnetdb},
			  logfile,$pkg->{logfile},
			  lemma,'hen');
		push(@alternatives,$wo);
		return @alternatives;
	        }
	}
return ();
}
