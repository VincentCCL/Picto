# Lemmatizer.pl
#
# written by Vincent Vandeghinste
#
# version 0.4  15.10.2021 added FindBin
# version 0.3
# 09.06.2004 default return value added if no entry found
# version 0.2
# 18.02.2004 bug fix for words like "&eacute;&eacute;n"
# date 13.10.2003
#########################################
#
# gets a word as its first argument
# returns the words lemma

use FindBin qw($Bin);  # Added in 0.4
use DB_File;

$word=shift(@ARGV);
tie %CGN,"DB_File","$Bin/data/cgn_lexicon.db"; 

while ($CGN{"$word"}) {
    ($tag,$lemma)=split(/\t/,$CGN{"$word"});
    $ANSWER{$lemma}=1;
    $word.="%";
    $found_in_lex=1;
}

foreach $key (keys %ANSWER) {
    print "$key\n";
}

unless ($found_in_lex==1) {
    print "$word\n";
}
