#use WordbuilderModule;
use FindBin qw($Bin);
require "$Bin/WordbuilderModule.pm";
use DB_File;
use Getopt::Std;

    tie %CGN,"DB_File","$Bin/data/cgn_lexicon.db"; 
    tie %NONSPLIT,"DB_File","$Bin/data/nonsplitups.db"; 
    tie %QUASI,"DB_File","$Bin/data/quasi.db"; 
    tie %lexicon,"DB_File","$Bin/data/total.freqs.db";

getopt("i",\%opts);
unless (defined($wordsplitterpenalty2=$opts{i})) {
	$wordsplitterpenalty2=500;
	print STDERR "Use -i option to set the minimum frequency for both words needed to accept the split version of the word (default=$wordsplitterpenalty2)\n";
}

my $word=shift(@ARGV);
my $lengte=length($word);
my @lemmata=&Get_Lemma($word);

foreach $lemma (@lemmata) {
    unless ($NONSPLIT{$lemma}) {
	($mod,$head,$prob)=&Split_Up($word,$lengte);
	while (@$mod) {
	    $current_mod=shift(@$mod);
	    $current_head=shift(@$head);
	    $current_prob=shift(@$prob);
	    print "$current_mod\t$current_head\t$current_prob\n";
	}
    }
}

sub Split_Up {
    my ($word,$lengte)=@_;
    my ($cursor,$mod,$head,$headlengte);
    for ($cursor=2;$cursor<($lengte-1);$cursor++) {
	$headlengte=$lengte-$cursor;
	($mod,$head)=$word=~/^(.{$cursor,$cursor})(.{$headlengte,$headlengte})$/;
	if (find_word($mod) &&
	    find_word($head)) {
	    print "$mod\t$head\n";
	}
    }
}

##################################
sub find_word {
##################################
    my $word=$_[0];
    if (find_noncomp($word) ||
        find_quasi($word)) {
        return 1;
    }
}

##################################
sub find_noncomp {
##################################
    my $word=$_[0];
    if (($NONSPLIT{$word}) && ($main::lexicon{$word} > $wordsplitterpenalty2) && ($word ne "ge") && ($word ne "en")){
        return 1;
    }
}

##################################
sub find_quasi {
##################################
    my $word=$_[0];
    if (($QUASI{$word}) && ($main::lexicon{$word} > $wordsplitterpenalty2)) {
        return 1;
    }
}

##################################
sub Get_Lemma {
##################################
    my ($word)=@_;
    my @lemmata=`perl /home/pricie/leen/Documents/Werk/Scripts/Wordbuilder/Lemmatizer.pl "$word"`;
    chop(@lemmata);
    foreach $lemma (@lemmata) {
	if ($lemma eq 'zijn') {
	    return ($lemma);
	}
    }
    return @lemmata;
}

####################
sub refer {
    my @array=@_;
    return \@array;
}
