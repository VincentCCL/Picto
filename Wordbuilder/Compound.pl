#----------------------------------------------------------------------------------
#                               Compound.pl
#----------------------------------------------------------------------------------

#----------------------------------------------------------------------------------
# the aim of this program is to compound the input word parts and get a confidence
# measure about the compound
#----------------------------------------------------------------------------------

use Node;

#----------------------------------------------------------------------------------
# cgn_lexicon.db: containing most frequent entries with word forms, parts of
# speech, morpho-syntactic information, lemmas and phonological information
#
# quasi.db: containing all the word parts which can not occur by themselves,
# but which are variations on words that do exist by themselves
#
# wordgrammar.lst: the rules for compounding two word parts
#
# ModHead.freqs.db: containing the frequency of the word part as a head with any
# modifier and the frequency of the word part as a modifier with any head
#
# DifModsPerHead.db: containing the number of different modifiers occuring with the
# word part as a head
#
# total.freqs.db: containing the frequency that two word parts form a compound
#----------------------------------------------------------------------------------

$dbase="/../../Data/Lexical/DB/cgn_lexicon.db";
$quasibase="/../../../Data/Lexical/DB/quasi.db";
$rules_file="wordgrammar.lst";
$modhead="/../../../Data/Lexical/DB/ModHead.freqs.db";
$difmods="/../../../Data/Lexical/DB/DifModsPerHead.db";
$totalfreqs="/../../../Data/Lexical/DB/total.freqs.db";

dbmopen(%LEXICON,$dbase,0644);
dbmopen(%QUASI,$quasibase,0644);
dbmopen(%MODHEAD,$modhead,0644);
dbmopen(%DIFMODS,$difmods,0644);
dbmopen(%TOTALFREQS,$totalfreqs,0644);

@input_parts=@ARGV;# input an array of the word parts
%RULESET=&Read_Rules($rules_file);
$nr_of_comps=79862581;

&calculate_results (@input_parts);


sub calculate_results {
    my @parts=@_;
    my @nodes=&create_nodes(@parts);
    my @nw=&try_compounding(@nodes);
    my $result,$prob;
    if (@nw){
        $result=$nw[0]->get_word();
        $prob=$nw[0]->get_prob();
        print "$result\n";
        print "$prob\n";
    }
}

#----------------------------------------------------------------------------------
# input the array of the word parts, create the array of the entries with 'POS' and
# frequency information
#----------------------------------------------------------------------------------
sub create_nodes {
    my @parts=@_;
    local $part,@partlist;
    @partlist=();
    foreach $part (@parts) {
        push(@partlist,&find_parta ($part));
    }
    @partlist;
}



#----------------------------------------------------------------------------------
# obtain the part of speech and the frequency information of one input unit
#----------------------------------------------------------------------------------
sub find_parta {
    my $part=$_[0];
    local @partnodes;
    my $value,$word,$tag,$lemma,$pos,$bpos,$modheadsolo,$headfreq,$modfreq,$solo;
    my $diffmods,$object,$newword;
 if ($LEXICON{$part}){
     $value=$LEXICON{$part};# $part is in the cgn lexicon
     $word=$part;
    ($tag,$lemma)=split(/\t/,$value);
    ($pos,$bpos)=split(/\(/,$tag);# obtain the 'POS' of $part from the cgn_lexicon.db
     $modheadsolo=$MODHEAD{$part};
    ($headfreq,$modfreq,$solo)=split(/\t/,$modheadsolo);
    # $headfreq: the sum of the frequency of all the words with $part as a head
    # $modfreq: the sum of the frequency of all the words with $part as a modifier
     unless ($modfreq) {
         $modfreq=1;
     }
     unless ($headfreq) {
         $headfreq=1;
     }
     $diffmods=$DIFMODS{$part};
    # $diffmods: the number of different modifiers occuring with $part as a head
     unless ($diffmods) {
         $diffmods=1;
     }
    push(@partnodes,Node->new($word,$tag,$lemma,$pos,$headfreq,$modfreq,$diffmods,$prob));
    # use the 'Node' package and creat the objects
     return @partnodes;

}
 elsif ($QUASI{$part}){
     $value=$QUASI{$part};# $part is in the quasi-word-list
     $word=$part;
     $tag=$value;
     $lemma=$value;
     $pos="QUASI";
     $headfreq=0;
     $modfreq=1;
     $diffmods=$DIFMOD{$part};
     unless ($diffmods) {
         $diffmods=1;
     }
    push(@partnodes,Node->new($word,$tag,$lemma,$pos,$hedafreq,$modfreq,$diffmods,$prob));
     return @partnodes;
 } else {
     $word=$part;
     $modfreq=1;
     $headfreq=1;
     $diffmods=1;
     push(@partnodes,Node->new($word,$tag,$lemma,$pos,$hedafreq,$modfreq,$diffmods,$prob));
     return @partnodes;
 }
}


#---------------------------------------------------------------------------------------
# select the compounding method according to the number of the input units (two or three)
#---------------------------------------------------------------------------------------
sub try_compounding {
    my @nodes=@_;
    my $number_of_nodes=@nodes;
    my $part;
    my @hypos, @currenthypos;
    if ($number_of_nodes == 2) {
        push(@hypos,&compound(@nodes));
    }
    elsif ($number_of_nodes == 3) {
        @currenthypos=&try_compounding($nodes[0],$nodes[1]);
        if (@currenthypos) {
            push(@hypos,&try_compounding(@currenthypos,$nodes[2]));
        }
        @currenthypos=&try_compounding($nodes[1],$nodes[2]);
        if (@currenthypos) {
            push(@hypos,&try_compounding($nodes[0],@currenthypos));
        }
    }
    # compound three input units two by two recursively
    @hypos;
}

#----------------------------------------------------------------------------------
# compound the two input word parts
#----------------------------------------------------------------------------------
sub compound {
    my @nodes=@_;
    my $part,$mod,$head,$modpos,$headpos,$newword,$key,$value,$modheadfreq;
    my $headheadfreq,$modmodfreq,$headmodfreq,$moddiffmods,$headdiffmod,$probcomp;
    my @n_pos,@n_word,@partnodes,@arraynewword;
    foreach $part (@nodes){
        push(@n_pos,$part->get_pos());
        push(@n_word,$part->get_word());
        push(@n_headfreq,$part->get_headfreq());
        push(@n_modfreq,$part->get_modfreq());
        push(@n_diffmods,$part->get_diffmods());
        # execute the operation 'get_*' of the package 'Node'
    }
    $mod=$n_word[0];
    $head=$n_word[1];

    $modpos=$n_pos[0];
    $headpos=$n_pos[1];

    $modheadfreq=$n_headfreq[0];
    $headheadfreq=$n_headfreq[1];# the 'head frequency' of the second word part

    $modmodfreq=$n_modfreq[0];# the 'mod frequency' of the first word part
    $headmodfreq=$n_modfreq[1];

    $moddiffmods=$n_diffmods[0];
    $headdiffmods=$n_diffmods[1];
    # the number of different modifiers occuring with the second word part as a head

    @n_pos=();
    @n_word=();
    @n_headfreq=();
    @n_modfreq=();
    @n_diffmods=();

%RULESET=&Read_Rules($rules_file);

    $key="$modpos+$headpos";

if ($RULESET{$key}){
     $value=$RULESET{$key};
     $newword=$mod.$head;# compound the units according to the rules
     $probcomp=&calculate($headheadfreq,$modmodfreq,$headdiffmods,$mod,$head);
     @partnodes=&find_partb ($newword,$probcomp);
     return @partnodes;
 } else {
     return ();
 }
}

#----------------------------------------------------------------------------------
# read the rule list and creat a hash table
#----------------------------------------------------------------------------------
sub Read_Rules {
   my $file=$_[0];
   open(IN,$file) || die;
   while ($line=<IN>) {
        chomp($line);
        ($lhs,$rhs)=split(/\t/,$line);
        $RULES{$lhs}=$rhs;
    }
    return %RULES;
}

#----------------------------------------------------------------------------------
# calculate the compound probability to get a confidence measure about the compound
#----------------------------------------------------------------------------------
sub calculate {
    my $headfreqHead=$_[0];
    my $modfreqMod=$_[1];
    my $difmod=$_[2];
    my $themod=$_[3];
    my $thehead=$_[4];
    my $comp_freq=$TOTALFREQS{$themod.$thehead};
    # $comp_freq is the frequency of the compound ($themod+$thehead)
    unless ($comp_freq) {
        $comp_freq=$TOTALFREQS{"$themod-$thehead"};
    }
    if ($headfreqHead==0) {
        $headfreqHead=1;
    }
    my $discount=($difmod/$headfreqHead);
    # $discount is the mount of the total frequency which is reserved for words
    # that can not be found in the total frequency list
    if ($comp_freq) {
        $prob_comp=($comp_freq/$headfreqHead)*(1-$discount);
        # 1-$discount is the amount of the total frequency which is reserved for words
        # that can be found in the total frequency list
    } else {
        $prob_comp=($discount*$modfreqMod/$nr_of_comps);
        # $nr_of_comps is the total frequency of all words
    }
    return $prob_comp;
}


#----------------------------------------------------------------------------------
# create the entry of the compound with 'pos' and frequency information
# most of the sub-program 'find_partb' the same as 'find_parta'
#----------------------------------------------------------------------------------
sub find_partb {
    my $part=$_[0];
    my $probcomp=$_[1];
    local @partnodes;
    my $value,$word,$tag,$lemma,$pos,$bpos,$modheadsolo,$headfreq,$modfreq,$solo;
    my $diffmods,$object,$newword;
 if ($LEXICON{$part}){
     $value=$LEXICON{$part};
     $word=$part;
     $prob=$probcomp;
    ($tag,$lemma)=split(/\t/,$value);
    ($pos,$bpos)=split(/\(/,$tag);
     $modheadsolo=$MODHEAD{$part};
    ($headfreq,$modfreq,$solo)=split(/\t/,$modheadsolo);
     unless ($modfreq) {
         $modfreq=1;
     }
     unless ($headfreq) {
         $headfreq=1;
     }
     $diffmods=$DIFMODS{$part};
     unless ($diffmods) {
         $diffmods=1;
     }
    push(@partnodes,Node->new($word,$tag,$lemma,$pos,$headfreq,$modfreq,$diffmods,$prob));
     return @partnodes;

}
 elsif ($QUASI{$part}){
     $value=$QUASI{$part};
     $word=$part;
     $prob=$probcomp;
     $tag=$value;
     $lemma=$value;
     $pos="QUASI";
     $headfreq=0;
     $modfreq=1;
     $diffmods=$DIFMOD{$part};
     unless ($diffmods){
         $diffmods=1;
     }
    push(@partnodes,Node->new($word,$tag,$lemma,$pos,$hedafreq,$modfreq,$diffmods,$prob));
     return @partnodes;
 } else {
     $word=$part;
     $prob=$probcomp;
     push(@partnodes,Node->new($word,$tag,$lemma,$pos,$hedafreq,$modfreq,$diffmods,$prob));
     return @partnodes;
 }
}
