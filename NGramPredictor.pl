####### NGramPredictor.pl ##########

# By Leen Sevens 
# leen@ccl.kuleuven.be 
# Date: 04.04.2018

#---------------------------------------

# N-gram based prediction tool
# Example: NGramPredictor.pl -p beta 'ik zijn_ww blij'

#---------------------------------------

# See also: Sevens L., Daems J., De Vliegher A., Schuurman I., Vandeghinste V., Van Eynde F. (2017). Building an Accessible Pictograph Interface for Users with Intellectual Disabilities. In: Cudd P., de Witte L. (Eds.), Harnessing the Power of Technology to Improve Lives, (pp. 870-877) IOS Press.

# See also: Sevens L., Vandeghinste V., Schuurman I., Van Eynde F. (2015). Natural Language Generation from Pictographs. In Belz, A. (Ed.), Gatt, A. (Ed.), Portet, F. (Ed.), Purver, M. (Ed.), Proceedings of the 15th European Workshop on Natural Language Generation (ENLG). European Workshop on Natural Language Generation. Brighton, UK, 10-11 September 2015 (pp. 71-75) Association for Computational Linguistics.

#---------------------------------------

# Takes the following obligatory input options:

# -p sclera|beta sets the pictograph set used in the output

#---------------------------------------

# Takes the following optional input options (location of the database):

# -a sets the language model database name
# -b sets the language model database host
# -e sets the language model database port
# -f sets the language model database user
# -i sets the language model database password

#---------------------------------------

getopt("abefip",\%opts);
unless ($pictolanguage=$opts{p}) {
    print STDERR "Use -p option to set picto language (sclera/beta)\n";
}
unless (defined($lmdatabase=$opts{a})) {
    $lmdatabase="$pictolanguage"."_lm2";
    print STDERR "Use -a option to set language model database name (default=$lmdatabase)\n";
}
unless (defined($lmhost=$opts{b})) {
    $lmhost="gobelijn";
    print STDERR "Use -b option to set language model database host (default=$lmhost)\n";
}
unless (defined($lmport=$opts{e})) {
    $lmport="5432";
    print STDERR "Use -e option to set language model database port (default=$lmport)\n";
}
unless (defined($lmuser=$opts{f})) {
    $lmuser="vincent";
    print STDERR "Use -f option to set language model database user (default=$lmuser)\n";
}
unless (defined($lmpwd=$opts{i})) {
    $lmpwd="vincent";
    print STDERR "Use -i option to set language model database password (default=$lmpwd)\n";
}

#---------------------------------------

# Libraries

use Getopt::Std;  
use FindBin qw($Bin); 
use DB_File;
use Encode;
require "$Bin/Database.pm";
require "$Bin/object.pm";

$database{beta}="$main::lmdatabase";
$host="$main::lmhost";
$port="$main::lmport";
$user="$main::lmuser";
$pwd="$main::lmpwd";

$database{sclera}="$main::lmdatabase";
$host="$main::lmhost";
$port="$main::lmport";
$user="$main::lmuser";
$pwd="$main::lmpwd";

#---------------------------------------

# Main program

$in=shift(@ARGV);
$message=message->new(text,$in,
		      logfile,\*LOG,
		      target,$pictolanguage);
$message->tokenize2;
$message->predictNextWord;

#---------------------------------------
package message;
#---------------------------------------

my $i=0;

sub tokenize2 {
    my ($pkg)=@_;
    $_=$pkg->{text};
    my $log=$pkg->{logfile};
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
    $pkg->{words}=[@words];
}

sub predictNextWord {
    my ($pkg)=@_;
    $pkg->openNGramDatabase;
    my $words=$pkg->{words};
    unshift(@$words,$pkg->generateStartOfSentence);
    if (@$words==1) { # There was no input, only start of sentence: find the most likely word for "<s> UNKNOWN"
	$pkg->findBestBiGrams;
    }
    elsif (@$words>=2) { # There were at least two input words (this may include the start of the sentence): find most likely word for "inputword inputword UNKNOWN"
	$pkg->findBestTriGrams;
    }
}

sub generateStartOfSentence {
    my ($pkg)=@_;
    my $word=word->new(logfile,$pkg->{logfile},
		       target,$pkg->{target},
		       token,"<s>",
		       wordnetdb,$pkg->{wordnetdb});
    return $word;
}

sub openNGramDatabase{  
    my ($pkg)=@_;
    unless ($pkg->{ngramdb}) {
	    my $db=DBI::db->new($main::database{$pkg->{target}}, # Separate databases for Sclera and Beta
				$main::host,
				$main::port,
				$main::user,
				$main::pwd);
	    $pkg->{ngramdb}=$db;
   }
}

sub findBestBiGrams{
    my ($pkg)=@_;
    my %hash=();
    my $target = $pkg->{target};
    my $firstword=$pkg->{words}->[0]->{token};
    my $sql="select * from bigram where ngram like '$firstword %';";
    my $results=$pkg->{ngramdb}->lookup($sql);
    foreach(@$results){
	 $bigramlogprob=$_->[0];
	 $bigramword=$_->[1];
	 ($firstword, $predictedword)=split(/ /,$bigramword);
   	 unless (exists $hash{$predictedword}) {
	 	$hash{$predictedword}=$bigramlogprob; 
	 }
    }
    foreach my $key (sort {$hash{$b} <=> $hash{$a}} keys %hash){
	if (-e "$main::Bin/../$target/$key.png") {
		print "$key\t$hash{$key}\n";
		$i++;
		if ($i eq 200){
			last;
		}
		else{
			next;
		}
	}
	else{
		next;
 	}
    }
}

sub findBestTriGrams{
    my ($pkg)=@_;
    my %trigramhash=();
    my %bigramhash=();
    my %unigramhash=();
    my $j;
    my $target = $pkg->{target};
    my $firstword=$pkg->{words}->[-2]->{token};
    my $secondword=$pkg->{words}->[-1]->{token};
    my $sql="select * from trigram where ngram like '$firstword $secondword %';";
    my $results=$pkg->{ngramdb}->lookup($sql);
    if (@$results) {
	 foreach(@$results){
		 $trigramlogprob=$_->[0];
		 $trigramword=$_->[1];
 		 ($firstword, $secondword, $predictedword)=split(/ /,$trigramword);
		 if (-e "$main::Bin/../$target/$predictedword.png") {
		         $trigramhash{$predictedword}=$trigramlogprob; 
			 $j++;
		 }
	 }
			 foreach my $key (sort {$trigramhash{$b} <=> $trigramhash{$a}} keys %trigramhash){
					print "$key\t$trigramhash{$key}\n";
					$i++;
					if ($i eq 200){
						last;
					}
					else{
						next;
					}
			 }
    }
    if($j<200){ # Backoff to bigram
	my $sql2="select * from bigram where ngram = '$firstword $secondword';"; # Find the alfa for the previous two words
        my $results2=$pkg->{ngramdb}->lookup($sql2);
      	my $alfa=$results2->[0]->[2];
	my $sql3="select * from bigram where ngram like '$secondword %';";
    	my $results3=$pkg->{ngramdb}->lookup($sql3);
	if(@$results3){
		foreach(@$results3){
			$bigramlogprob=$_->[0];
			$bigramword=$_->[1];
			($secondword, $predictedword)=split(/ /,$bigramword);
			unless (exists $trigramhash{$predictedword}) {
				if (-e "$main::Bin/../$target/$predictedword.png") {
					my $logprobwithbackoff=$alfa+$bigramlogprob;
	 				$bigramhash{$predictedword}=$logprobwithbackoff; 
					$j++;
		 		}
			}
		}
					foreach my $key (sort {$bigramhash{$b} <=> $bigramhash{$a}} keys %bigramhash){
							print "$key\t$bigramhash{$key}\n";
							$i++;
							if ($i eq 200){
								last;
							}
							else{
								next;
							}
					}
	}
	if($j<200) { # Backoff to unigram
		my $sql5="select * from unigram where ngram = '$secondword';"; # Find the alfa for the previous word
    		my $results5=$pkg->{ngramdb}->lookup($sql5);
      		my $alfa2=$results5->[0]->[2];
		my $sql4="select * from unigram;";
		my $results4=$pkg->{ngramdb}->lookup($sql4);
		foreach(@$results4){
			$unigramlogprob=$_->[0];
			$predictedword=$_->[1];
			unless ((exists $trigramhash{$predictedword}) || (exists $bigramhash{$predictedword})) {
				if (-e "$main::Bin/../$target/$predictedword.png") {
					my $logprobwithbackoff=$alfa2+$unigramlogprob;
	 				$unigramhash{$predictedword}=$logprobwithbackoff;  
				}
			}
		}
					foreach my $key (sort {$unigramhash{$b} <=> $unigramhash{$a}} keys %unigramhash){
							print "$key\t$unigramhash{$key}\n";
							$i++;
							if ($i eq 200){
								last;
							}
							else{
								next;
							}
					}
	}
    }
}



