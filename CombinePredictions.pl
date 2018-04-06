####### CombinePredictions.pl ##########

# By Leen Sevens 
# leen@ccl.kuleuven.be 
# Date: 04.04.2018

#---------------------------------------

# Pictograph prediction tool that uses predictions from the n-gram model and the association model to make better predictions
# Takes a series of pictographs (without .png extension) as input
# Example: CombinePredictions.pl -p beta -l experienced -o html 'ik zijn_ww blij'

#---------------------------------------

# See also: Sevens L., Daems J., De Vliegher A., Schuurman I., Vandeghinste V., Van Eynde F. (2017). Building an Accessible Pictograph Interface for Users with Intellectual Disabilities. In: Cudd P., de Witte L. (Eds.), Harnessing the Power of Technology to Improve Lives, (pp. 870-877) IOS Press.

# See also: Sevens L., Vandeghinste V., Schuurman I., Van Eynde F. (2015). Natural Language Generation from Pictographs. In Belz, A. (Ed.), Gatt, A. (Ed.), Portet, F. (Ed.), Purver, M. (Ed.), Proceedings of the 15th European Workshop on Natural Language Generation (ENLG). European Workshop on Natural Language Generation. Brighton, UK, 10-11 September 2015 (pp. 71-75) Association for Computational Linguistics.

#---------------------------------------

# Takes the following obligatory input options:

# -p sclera|beta sets the pictograph set used in the output
# -l experienced|beginner sets the pictograph user type: "experienced" predicts grammatically correct pictograph sequences (using the n-gram model as its core), whereas "beginner" predicts a semantic field (using the association model as its core)
# -n (number) sets the maximum amount of predictions
# -o html|text sets the output mode (html generates valid html with <img> tags, text generates text with filenames (without extensions))

#---------------------------------------

# Takes the following optional input options (location of the databases):

# -g sets the picto database name
# -j sets the picto database host
# -m sets the picto database port
# -u sets the picto database user
# -q sets the picto database password
# -a sets the language model database name
# -b sets the language model database host
# -e sets the language model database port
# -f sets the language model database user
# -i sets the language model database password

#---------------------------------------

use Getopt::Std;  
use FindBin qw($Bin);
use DB_File;
use Encode;

#--------------------------------------

# Prediction tools

$wordassociationtool="$Bin/WordAssociationPredictor.pl"; 
$ngramtool="$Bin/NGramPredictor.pl";

$wordassociationtooloutput="$Bin/../tmp/predictor/AssociationsOutput";
$ngramtooloutput="$Bin/../tmp/predictor/NGramOutput";

#--------------------------------------

getopt("abefgijlmnopqu",\%opts);
unless ($pictolanguage=$opts{p}) {
    print STDERR "Use -p option to set picto language (sclera/beta)\n";
}
unless ($usertype=$opts{l}) {
    print STDERR "Use -l option to set user type (experienced/beginner)\n";
}
unless ($maxpredicts=$opts{n}) {
    print STDERR "Use -n option to set maximum amount of predictions\n";
}
unless ($outputmode=$opts{o}) {
    print STDERR "Use -o option to set the output mode (html/text)\n";
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

#--------------------------------------

my %hash;

$in=shift(@ARGV);

if($usertype eq "experienced"){
	`perl $main::ngramtool -p $pictolanguage -a $lmdatabase -b $lmhost -e $lmport -f $lmuser -i $lmpwd '$in' > $main::ngramtooloutput$stamp.txt`;
	`perl $main::wordassociationtool -p $pictolanguage -g $database -j $host -m $port -u $user -q $pwd '$in' > $main::wordassociationtooloutput$stamp.txt`;
	open (NGRAM,"$main::ngramtooloutput$stamp.txt");
 	my $i=200;
	while (<NGRAM>) {
		chomp;
		my $picto;
		my $log;
		my $flag;
		($picto,$log)=split(/\t/,$_);
		open (ASSOC,"$main::wordassociationtooloutput$stamp.txt");
		my $j=200;
		while (<ASSOC>) {
			chomp;
			my $picto2;
			my $log2;
			($picto2,$log2)=split(/\t/,$_);
			if($picto eq $picto2){
				my $combinedlog=$i+$j;
				$flag="yes";
				$hash{$picto}=$combinedlog;
			}
			else{
				$j=$j-1;
			}
		}
		if ($flag eq "yes"){
			$i=$i-1;
			next;
		}
		else{
			$hash{$picto}=$i;
			$i=$i-1;
		}
	}
        `rm -f $main::ngramtooloutput$stamp.txt`;
        `rm -f $main::wordassociationtooloutput$stamp.txt`;
}

elsif($usertype eq "beginner"){
	`perl $main::ngramtool -p $pictolanguage -a $lmdatabase -b $lmhost -e $lmport -f $lmuser -i $lmpwd '$in' > $main::ngramtooloutput$stamp.txt`;
	`perl $main::wordassociationtool -p $pictolanguage -g $database -j $host -m $port -u $user -q $pwd '$in' > $main::wordassociationtooloutput$stamp.txt`;
	open (ASSOC,"$main::wordassociationtooloutput$stamp.txt");
 	my $i=200;
	while (<ASSOC>) {
		chomp;
		my $picto;
		my $log;
		my $flag;
		($picto,$log)=split(/\t/,$_);
		open (NGRAM,"$main::ngramtooloutput$stamp.txt");
		my $j=200;
		while (<NGRAM>) {
			chomp;
			my $picto2;
			my $log2;
			($picto2,$log2)=split(/\t/,$_);
			if($picto eq $picto2){
				my $combinedlog=$i+$j;
				$flag="yes";
				$hash{$picto}=$combinedlog;
			}
			else{
				$j=$j-1;
			}
		}
		if ($flag eq "yes"){
			$i=$i-1;
			next;
		}
		else{
			$hash{$picto}=$i;
			$i=$i-1;
		}
	}
        `rm -f $main::ngramtooloutput$stamp.txt`;
        `rm -f $main::wordassociationtooloutput$stamp.txt`;
}

my $i=0;

my (@inputpictos)=split(/\s/,$in);

if($main::outputmode eq "html"){
	print "<html>\n";
	foreach my $key (sort {$hash{$b} <=> $hash{$a}} keys %hash){
		if ((grep(/$key/,@inputpictos)) || ($key eq "hebben")){
			next;
		}
		else{
			print "<img src=\"http://webservices.ccl.kuleuven.be/picto/$main::pictolanguage/$key.png\" width=\"110\" heigth=\"110\">\n";
			$i++;
				if ($i eq $main::maxpredicts){
					last;
				}
				else{
					next;
				}
		}
	}
	print "</html>\n";
}
else{
	foreach my $key (sort {$hash{$b} <=> $hash{$a}} keys %hash){
		if ((grep(/$key/,@inputpictos)) || ($key eq "hebben")){
			next;
		}
		else{
			print "$key\t$hash{$key}\n";
			$i++;
				if ($i eq $main::maxpredicts){
					last;
				}
				else{
					next;
				}
		}
	}
}

