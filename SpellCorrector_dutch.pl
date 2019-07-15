####### SpellCorrector_cornetto.pl ##########

# By Leen Sevens 
# leen@ccl.kuleuven.be 
# Date: 14.01.2016

#!/bin/bash

#---------------------------------------

# Spelling corrector for people with an intellectual disability, trained on WAI-NOT data
# Example: perl SpellCorrector_cornetto.pl 'input'
# The input may consist of multiple sentences

#---------------------------------------

# See also: Sevens L., Vanallemeersch T., Schuurman I., Vandeghinste V., Van Eynde F. (2016). Automated Spelling Correction for Dutch Internet Users with Intellectual Disabilities. In Schuurman, I. (Ed.), Vandeghinste, V. (Ed.), Saggion, H. (Ed.), Proceedings of 1st Workshop on Improving Social Inclusion using NLP: Tools and Resources. Workshop on Improving Social Inclusion using NLP: Tools and Resources (ISI-NLP). Portorož, Slovenia, 23 May 2016 (pp. 11-19). ELRA: Paris.

#---------------------------------------

use Getopt::Std;
use FindBin qw($Bin); 
use DB_File;
use Encode qw(decode);

require "$Bin/FindCharacterRules.pm";
require "$Bin/GenericFunctionsSpellcheck.pm";

#---------------------------------------

# Parameters

getopt("abcdefghijklmnopqrstuvwxyzABCDEFGH",\%opts);
processOptionsSpellcheck(%opts);

require $objectpm;
require $databasepm;

our $spellcheckdatabase=DBI::db->new($pictodatabase,$pictohost,$pictoport,$pictouser,$pictopwd);
our $dutch_lm=DBI::db->new($lmdatabase,$lmhost,$lmport,$lmuser,$lmpwd);

tie %SPELLCHECKLEX,"DB_File",$spellchecklexfile;
tie %FIRSTNAMES,"DB_File",$firstnamesfile; 
tie %lexicon,"DB_File",$lexiconfile;

our $stamp=time;

#---------------------------------------

# Main program

$in=shift(@ARGV);
$sessionid=shift(@ARGV);
$message=message->new(text,$in,
		      logfile,\*LOG);
$message->compoundWords; 
$message->detectSentences; 
$message->spellcheck; 
print "\n";

#---------------------------------------
package message;
#---------------------------------------

sub compoundWords{
    my ($pkg)=@_;
    my $message=$pkg->{text};
    my $newmessage;
    $message=~s/([\(\),\.\"\?!]+)/ $1/g;
    my @messagewords=split(/[ ]+/,$message);
    for(my $i=0;$i<@messagewords;$i++){
	    	$newword=$messagewords[$i].$messagewords[$i+1];
		if ($main::lexicon{$newword} > $main::wordbuilderpenalty1){ 
			if(($main::lexicon{$messagewords[$i]} < $main::wordbuilderpenalty2) || ($main::lexicon{$messagewords[$i+1]} < $main::wordbuilderpenalty2)){ 
				$newmessage="$newmessage $newword";
				$i++;
			}
			else{
				$newmessage="$newmessage $messagewords[$i]";
			}
		}
		else{
			$newmessage="$newmessage $messagewords[$i]";
		}
    } 
    $newmessage=~s/^ ((.)*)/$1/g;
    $pkg->{text}=$newmessage;
}

sub detectSentences {
    my ($pkg)=@_;
    my $words;
    my $condition=$pkg->{condition};
    unless ($words=$pkg->{words}) { 
	$pkg->tokenize;
	$words=$pkg->{words};
    }
    my (@sentencewords,@sentences);
    for ($i=0;$i<@$words;$i++) {
	push(@sentencewords,$words->[$i]);
	if ($words->[$i]->endOfSentence) {
	    my $sentence=sentence->new(logfile, $pkg->{logfile},
				       words,[@sentencewords],
				       target,$pkg->{target},
				       wordnetdb,$pkg->{wordnetdb});
	    if ($condition) {
		$sentence->{condition}=$condition;
	    }
	    push(@sentences,$sentence);
	    @sentencewords=();
	}
    }
    if (@sentencewords>0) {
	my $sentence=sentence->new(logfile,$pkg->{logfile},
				   words,[@sentencewords],
				   target, $pkg->{target},
				   wordnetdb,$pkg->{wordnetdb});
	if ($condition) {
	    $sentence->{condition}=$condition;
	}
	push(@sentences,$sentence);
    }
    $pkg->{sentences}=[@sentences];
    delete $pkg->{words};
}

sub spellcheck{
	my ($pkg)=@_;
	my $sentences=$pkg->{sentences};
	foreach(@$sentences){
	  $_->spellCheck;
        }
}


#---------------------------------------
package sentence;
#---------------------------------------

sub spellCheck {
  my ($pkg)=@_;
  $pkg->removeCapitalOfFirstWord; # Lowercase the first word
  $pkg->changeUppercaseSequenceToLowercase; # Convert words consisting of only uppercase characters to lowercase characters
  $pkg->reduceFlooding; # Reduce "flooding" (i.e., when more than 2 identical characters appear in sequence, reduce the sequence to a maximum of 2 characters)
  $pkg->convertCommonAbbreviations; # Deal with a number of commonly appearing contractions and abbreviations (chatspeak-style text)
  $pkg->findNonWords; # Define what are the non-words and what are the real words
  $pkg->findVariants; # The actual variant generation step
  $pkg->filterVariants; # Based on a Dutch trigram language model, some rarely occurring combinations of variants are thrown away (in order to avoid combinatory explosion)
  $pkg->buildHypothesisSentences; # Create all possible combinations of variants; this results in a number of hypotheses
  $pkg->createSplitSentences; # Split the hypotheses into characters (pre-processing step for the character-based fuzzy matching)
  $pkg->performFuzzyMatch; # Fuzzy matching and best hypothesis selection
}

sub removeCapitalOfFirstWord{
    my ($pkg)=@_;
    my $words=$pkg->{words};
    my $firsttoken=lc(@$words[0]->{token});
    delete @$words[0]->{token};
    @$words[0]->{token}=$firsttoken;
}

sub changeUppercaseSequenceToLowercase{
    my ($pkg)=@_;
    my $words=$pkg->{words};
    foreach $word(@$words){
	$token=$word->{token};
	if ($token =~ /^\p{Uppercase}+$/) {
		$lowercasetoken=lc($token);
		delete $word->{token};
		$word->{token}=$lowercasetoken;
	}
    }
}

sub reduceFlooding{
    my ($pkg)=@_;
    my $words=$pkg->{words};
    foreach (@$words) {
	$token=$_->{token};
    	$token=~s/((.)\2{2,})/$2$2/ig;
	$_->{token}=$token;
    }
}

sub convertCommonAbbreviations{
    my ($pkg)=@_;
    my $words=$pkg->{words};
    foreach $word(@$words) {
	$token=$word->{token};
	$token=~s/^da$/dat/;
	$token=~s/^wa$/wat/;
	$token=~s/^nr$/nummer/;
	$token=~s/^ist$/is het/;
	$token=~s/^tis$/het is/;
	$word->{token}=$token;
    }
}

sub findNonWords {
    my ($pkg)=@_;
    my $words=$pkg->{words};
    foreach (@$words) {
	$_->lookupInDictionary;
    }
}

sub findVariants {
    my ($pkg)=@_;
    my $words=$pkg->{words};
    my $dictionary={","  => 1,
                    "!"  => 1,
                    "?"  => 1,
                    "hey" => 1,
                    "hallo" => 1,
                    "groetjes" => 1,
                    "sebiet" => 1,
                    "zijt" => 1,
                    "chat" => 1,
                    "chatten" => 1};
    #my @dictionaryarray = (",","!","?","hey","hallo","groetjes","sebiet","zijt","chat","chatten");
    foreach my $word_object (@$words) {
	my $spellcheck=$word_object->{spellcheck}; 
	my $word=$word_object->{token};
        my @alternatives=();	
	my $frequency=$main::lexicon{$word};
	chomp $frequency;
	unless ($dictionary->{$word} or $word=~/(\d)+/) {
	#unless ((grep( /^$word$/, @dictionaryarray)) || ($word =~ /(\d)+/)){
			unless (($spellcheck eq "Real") && (($frequency>$main::realwordminimumfrequency) ||  ($main::FIRSTNAMES{$word}))) { 
				push(@alternatives,$word_object->findPhoneticVariants); # Cognitive errors
				my @possiblealternatives;
				unless(@alternatives){ # Typographic errors
					push(@alternatives,$word_object->wordSplitter); 
					push(@possiblealternatives,$word_object->findOneInsertion); 
					push(@possiblealternatives,$word_object->findOneDeletion);
					push(@possiblealternatives,$word_object->findOneSubstitution);
					push(@possiblealternatives,$word_object->findOneTransposition);
					push(@alternatives,$word_object->returnRealWordAlternatives(@possiblealternatives)); 
				}
			}		
	}
	unless(@alternatives){ 
		push(@alternatives,$word);
	}
	my %hash=();
	%hash=map{$_=>1} @alternatives;
	my @unique = keys %hash;
	$word_object->{spellingalternatives}=[@unique]; 
    }
    return $pkg;
}

sub filterVariants{
    my ($pkg)=@_;
    my $words=$pkg->{words};
    unless (@$words<3){
	    my $amountofwordsminus1=@$words-1;
	    for(my $i=0;$i<@$words;$i++){
		$spellingalternatives=@$words[$i]->{spellingalternatives};
		$amountofspellingalternatives=scalar (@$spellingalternatives);
		if ($amountofspellingalternatives>1){
			@filteredalternatives=();
			foreach $alternative(@$spellingalternatives){
				my $rows;
				LOOP:{
					if($i eq "0"){
							$iplusonealternatives=@$words[$i+1]->{spellingalternatives};
							$iplustwoalternatives=@$words[$i+2]->{spellingalternatives};
							foreach $iplusonealternative(@$iplusonealternatives){
								foreach $iplustwoalternative(@$iplustwoalternatives){
									my $stmt = qq(select * from trigram where ngram='$alternative $iplusonealternative $iplustwoalternative';); 
							 	        $rows=$dutch_lm->lookup($stmt);
									last LOOP;
								}
							}
					}
					elsif($i eq $amountofwordsminus1){
							$iminustwoalternatives=@$words[$i-2]->{spellingalternatives};
							$iminusonealternatives=@$words[$i-1]->{spellingalternatives};
							foreach $iminustwoalternative(@$iminustwoalternatives){
								foreach $iminusonealternative(@$iminusonealternatives){
									my $stmt = qq(select * from trigram where ngram='$iminustwoalternative $iminusonealternative $alternative';); 
							 	        $rows=$dutch_lm->lookup($stmt);
									last LOOP;
								}
							}
					}
					else{
							$iminusonealternatives=@$words[$i-1]->{spellingalternatives};
							$iplusonealternatives=@$words[$i+1]->{spellingalternatives};
							foreach $iminusonealternative(@$iminusonealternatives){
								foreach $iplusonealternative(@$iplusonealternatives){
									my $stmt = qq(select * from trigram where ngram='$iminusonealternative $alternative $iplusonealternative';); 
						 	      	  	$rows=$dutch_lm->lookup($stmt);
									last LOOP;
								}
							}
					}
				}
				if(@$rows[0]){
					push(@filteredalternatives,$alternative);
				}
			}
			if(@filteredalternatives > 0){
				delete @$words[$i]->{spellingalternatives};
				@$words[$i]->{spellingalternatives}=[@filteredalternatives];
			}
		}
	    }
    }
}

sub buildHypothesisSentences{
    my ($pkg)=@_;
    my @arrayofarrays=();
    my $words=$pkg->{words};
    foreach (@$words) {
	$spellingalternatives=$_->{spellingalternatives};
	push(@arrayofarrays,$spellingalternatives);
    }
    my @results = ("");
    foreach my $subarray (@arrayofarrays) {
	    my @tmp_results = ();
	    my @subarray = @{$subarray};
		    foreach my $tmp_result (@results) {
			foreach my $element (@subarray) {
			    if ($tmp_result eq ""){
			    	my $string = "$element";
				push @tmp_results, $string;
			    }
			    else{
			    	my $string = "$tmp_result $element";
				push @tmp_results, $string;
			    }
			 }
		    }
	    @results = @tmp_results;
    }
    $pkg->{alternativesentences}=[@results];
}

sub createSplitSentences{
	my ($pkg)=@_;
	my @allsplitsentences=();
	my $alternativesentences=$pkg->{alternativesentences};
	foreach $alternativesentence(@$alternativesentences){
		$alternativesentence=~s/ /%/g;	
		$splitsentence=join(" ",split(//,$alternativesentence));	
		push(@allsplitsentences,$splitsentence);
	}
	$pkg->{splitsentences}=[@allsplitsentences];
}

sub performFuzzyMatch_ {
  my ($pkg)=@_;
  my $splitsentences=$pkg->{splitsentences};
  my $tokcorpus=$main::tokenizedcorpus.'_nolong';
  foreach (@$splitsentences) {
    $command="echo '$_' | $main::fuzzymatcher -n $main::ngramlength -t $main::tmpdirectoryfuzzy -p $main::highestfreqthresh -q $main::salmscriptsdirectory $main::inputfuzzymatch$stamp.txt $main::tokenizedcorpus $main::minimumscore 0";
    print STDERR "\n$command\n";
    @fuzzymatchoutput=`command`;
    $pkg->processFuzzyMatchOutputN($_,@fuzzymatchoutput);
  }
}

sub performFuzzyMatch { 
    my ($pkg)=@_;
    my $splitsentences=$pkg->{splitsentences};
    open (FUZZYMATCHINPUT,">$main::inputfuzzymatch$stamp.txt");
    foreach(@$splitsentences){
	    print FUZZYMATCHINPUT "$_\n";
    }
    close FUZZYMATCHINPUT;

 `cat $main::inputfuzzymatch$stamp.txt | salm_modified/Bin/Linux/Search/LocateEmbeddedNgramsInCorpus.O64 $main::tokenizedcorpus $main::highestfreqthresh 100000000 $main::ngramlength 10000000 $main::minimumscore 0 > $main::tmpdirectoryfuzzy/fuzzy$stamp.txt` ;

my $command= "gawk -v withmarkedsubseqs=0 \\
      'BEGIN { FS=\"\t\" }; \\
      { if (\$0 ~ /^0 /){ querypos++; queryseq=substr(\$1,3) } \\
        else if (\$1 ~ /^[0-9]+\$/){ \\
          split(\$5,linkarr,\" \"); split(\$2,seqarr,\" \"); \\
          for (i=1;(i in linkarr);i+=2) links=((i==1) ? \"\" : links \" \") \"? \" linkarr[i] \"-\" linkarr[i+1]; j=1; \\
          for (i=1;(i in seqarr);i++) { \\
            corpmark=((i==1) ? \"\" : corpmark \" \") \\
            (((j%2==1) && (linkarr[j]==i) && ++j) ? \"<<<\" (j/2) \" \" : \"\") seqarr[i] (((j%2==0) && (linkarr[j]==i) && ++j) ? \" \" (j-1)/2 \">>>\" : \"\") }; \\
          print \"querypos\t\" querypos \"\tcorppos\t\" \$1 \"\tsequence\t\" \$2 \"\tscore\t\" \$3 \"\tlinks\t\" links \"\tqueryDown\t\" \$4 (withmarkedsubseqs ? \"\tqueryseq\t\" queryseq \"\tcorpmark\t\" corpmark : \"\") } }' \\
$main::tmpdirectoryfuzzy/fuzzy$stamp.txt";

@fuzzymatchoutput=`$command`;
$pkg->processFuzzyMatchOutput(@fuzzymatchoutput);
}

sub processFuzzyMatchOutput {
	my ($pkg,@fuzzymatchoutput)=@_;
	my %hypothesishash=();
	my $count=1;
	open (FUZZYMATCHINPUT,"<$main::inputfuzzymatch$stamp.txt");
	while($lineinput=<FUZZYMATCHINPUT>){
		my $totalngramlength;
		chomp $lineinput;
		my %gaphash=();
 		foreach my $lineoutput (@fuzzymatchoutput) {
			($querypos,$queryposnumber,$corppos,$corpposnumber,$sequence,$sequencename,$score,$scorenumber,$links,$allcharacterpos,$rest)=split(/\t/,$lineoutput);
			if($queryposnumber eq $count){
				$allcharacterpos=~s/\? //g;
				@positionpairs=split(/ /,$allcharacterpos);
				foreach $positionpair(@positionpairs){ # A hypothesis that shares many and long n-grams with the corpus ($totaldifference) is the winning hypothesis
					my $ngramlength=$pkg->calculateNGramLength($positionpair);
					$totalngramlength=$totalngramlength+$ngramlength; 
				}
				$amountofpositionpairs=scalar @positionpairs;
				if ($amountofpositionpairs>1){ # An additional character sequence substitution is performed if similar substrings are found (with a maximum gap of n)
 					my ($leftmiddlerightsubstring,$scorenumber)=$pkg->performCharacterGapSubstitution($amountofpositionpairs,$sequencename,$lineinput,@positionpairs); 
					if($leftmiddlerightsubstring){
					 	$gaphash{$leftmiddlerightsubstring}=$scorenumber;
					}
				}
			}
		}
		if(%gaphash){
			my $highestvaluekey=(sort {$gaphash{$a} <=> $gaphash{$b}} keys %gaphash)[0];
			($leftsubstring,$middlesubstring,$rightsubstring)=split(/\t/,$highestvaluekey);
			$lineinput=~s/ //g;
			$lineinput =~s/(.*$leftsubstring).*($rightsubstring.*)/$1$middlesubstring$2/g;       
		}
		$hypothesishash{$lineinput}=$totalngramlength;
		$count++;
	}
	$pkg->printHighestScoringHypothesis(%hypothesishash);
}

sub calculateNGramLength{
	my ($pkg,$positionpair)=@_;
	($firstcharacter,$lastcharacter)=split(/-/,$positionpair);
	my $ngramlength=$lastcharacter-$firstcharacter;
	return $ngramlength;
}

sub performCharacterGapSubstitution{
	my ($pkg,$amountofpositionpairs,$sequencename,$lineinput,@positionpairs)=@_;
	for(my $i=0;$i<$amountofpositionpairs-1;$i++){
		($firstcharacter,$lastcharacter)=split(/-/,$positionpairs[$i]);
		($firstcharacter2,$lastcharacter2)=split(/-/,$positionpairs[$i+1]);
		$gap=$firstcharacter2-$lastcharacter;
		if ($gap<$main::maximumcharactergap){
			@letters=split(/ /,$sequencename);
			$leftsubstring="";
			$rightsubstring="";
			$middlesubstring="";
			$lineinput=~s/ //g;
			for (my $j=$firstcharacter-1;$j<$lastcharacter;$j++) {
				$leftsubstring=$leftsubstring."$letters[$j]";
			}
			for (my $k=$firstcharacter2-1;$k<$lastcharacter2;$k++) {
				$rightsubstring=$rightsubstring."$letters[$k]";
			}
			for (my $l=$lastcharacter;$l<$firstcharacter2-1;$l++) {
				$middlesubstring=$middlesubstring."$letters[$l]";
			}
			if(($lineinput =~ /.*$leftsubstring(.){1,3}$rightsubstring.*/) || ($lineinput =~ /.*$leftsubstring(){1,3}$rightsubstring.*/)){
				$leftmiddlerightsubstring="$leftsubstring\t$middlesubstring\t$rightsubstring";				
				return($leftmiddlerightsubstring,$scorenumber);				
			}
		}
	}
}

sub printHighestScoringHypothesis{
	($pkg,%hypothesishash)=@_;
	$highestscoring=(sort {$hypothesishash{$b} <=> $hypothesishash{$a}} keys %hypothesishash)[0];
	$highestscoring=~s/ //g;
	$highestscoring=~s/%/ /g;
	$highestscoring=~s/ ([!,\?\.])/$1/g;
	$highestscoringucfirst=ucfirst $highestscoring;
	print "$highestscoringucfirst";
	`rm -f $main::inputfuzzymatch$stamp.txt`;
        `rm -f $main::tmpdirectoryfuzzy/fuzzy$stamp.txt`;
}

#---------------------------------------
package word;
#---------------------------------------

sub endOfSentence {
    my ($pkg)=@_;
    if (($pkg->{tag}) &&
	($pkg->{tag} eq 'LET()') &&
	($pkg->{token}=~/[\.!\?]/)) {
	return 1;
    }	
    elsif ($pkg->{token}=~/[\.!\?]/) {
	return 1;
    }
    else {
	return undef;
    }
}
sub wordSplitter{
    my ($pkg)=@_;
    my $word=$pkg->{token};
    $frequency=$main::lexicon{$word};
    my $spellcheck=$pkg->{spellcheck};
    if(($spellcheck eq "Non-word") || ($frequency < $main::wordsplitterpenalty1)){
        my $command="perl $main::singlewordsplitter -i $main::wordsplitterpenalty2 '$word'";
        print STDERR "$command\n";
    	my @output=`$command`;
# 	open (OUTPUTSPLITTER,"<$main::outputforsinglewordsplitter$stamp.txt");
# 	while($line=<OUTPUTSPLITTER>){
        foreach $line (@output) {
		chomp $line;
		@outputwords=split(/\t/,$line);
		$amountofwords=scalar @outputwords;
		if ($amountofwords > 1){
			$line=~s/\t/ /g;
			return $line;
		}
	}
	#`rm -f $main::outputforsinglewordsplitter$stamp.txt`;
    }
    else{
	   return;
    }
}

sub lookupInDictionary {
    my ($pkg)=@_;
    my $word=$pkg->{token};
	if (($main::SPELLCHECKLEX{$word}) ||
		($main::SPELLCHECKLEX{lc($word)}) ||
		($main::FIRSTNAMES{$word}) ||
		($main::FIRSTNAMES{ucfirst($word)}) ||
		($word=~/^[\.\?\!\,\:\;\'\d]+$/)) {
	  	$pkg->{spellcheck}="Real";
	}
	else{
		$pkg->{spellcheck}="Non-word";
	}
    return $pkg;	
}

sub findOneInsertion {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my $target=$pkg->{target};
    my (@oneinsertions);
    push(@oneinsertions,$token);
    my $token="$token ";
    my @orig=split(//,$token);
    my @inserts=qw(a b c d e f g h i j k l m n o p q r s t u v w x y z ä ë ï ö ü à è ò ù é ç); 
    my @letters=@orig;
    my $amountofletters=scalar(@letters);
    my ($newtoken,$ucfirst);
	    for (my $i=0;$i<=$amountofletters;$i++) {
		foreach (@inserts) {
		    unless ($_ eq $letters[$i]) {
			splice(@letters,$i,0,$_);
			$newtoken=join("",@letters);
			$newtoken=~s/ //g;
			if (($main::SPELLCHECKLEX{$newtoken}) || ($main::FIRSTNAMES{$newtoken})) {
			    push(@oneinsertions,$newtoken);
			}
			elsif (($ucfirst=ucfirst($newtoken)) && ($main::FIRSTNAMES{$ucfirst})) {
			    push(@oneinsertions,$ucfirst);
			}
		    }
		   @letters=@orig;
		}
	    }
    return @oneinsertions;
}

sub findOneDeletion {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my $target=$pkg->{target};
    my (@onedeletions);
    push(@onedeletions,$token);
    my @orig=split(//,$token);
    my @letters=@orig;
    my ($word,$ucfirst);
	    for (my $i=0;$i<@letters;$i++) {
		splice(@letters,$i,1);
		$word=join("",@letters);
		if (($main::SPELLCHECKLEX{$word}) || ($main::FIRSTNAMES{$word})) {
		    push(@onedeletions,$word);
		}
		elsif (($ucfirst=ucfirst($word)) && ($main::FIRSTNAMES{$ucfirst})) {
		    push(@onedeletions,$ucfirst);
		}
		@letters=@orig;
	    }
    return @onedeletions;
}

sub findOneSubstitution {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my (@onesubstitutions);
    push(@onesubstitutions,$token);
    my @origs=split(//,$token);
    my @inserts=qw(a b c d e f g h i j k l m n o p q r s t u v w x y z ä ë ï ö ü à è ò ù é ç);
    my @letters=@origs;
    my ($newtoken,$ucfirst);
	    for (my $i=0;$i<@letters;$i++) {
		foreach (@inserts) {
		    unless ($_ eq $letters[$i]) {
			splice(@letters,$i,1,$_);
			$newtoken=join("",@letters);
			if (($main::SPELLCHECKLEX{$newtoken})|| ($main::FIRSTNAMES{$newtoken})) {
			    push(@onesubstitutions,$newtoken);
			}
			elsif (($ucfirst=ucfirst($newtoken)) && ($main::FIRSTNAMES{$ucfirst})) {
			    push(@onesubstitutions,$ucfirst);
			}
		    }
		    @letters=@origs;
		}
	    }
    return @onesubstitutions;
}

sub findOneTransposition {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my (@onetranspositions);
    push(@onetranspositions,$token);
    for my $i (0 .. length($token)-2) { 
    	(my $newtoken = $token) =~ s/(.{$i})(.)(.)/$1$3$2/;
			if (($main::SPELLCHECKLEX{$newtoken})|| ($main::FIRSTNAMES{$newtoken})) {
			    push(@onetranspositions,$newtoken);
			}
			elsif (($ucfirst=ucfirst($newtoken)) && ($main::FIRSTNAMES{$ucfirst})) {
			    push(@onetranspositions,$ucfirst);
			}
    }
    return @onetranspositions;
}

sub returnRealWordAlternatives{
    my ($pkg,@possiblealternatives)=@_;
    my @existingalternatives=();
    foreach $newword(@possiblealternatives){
	$frequency=$main::lexicon{$newword};
	if ((($main::SPELLCHECKLEX{$newword}) || ($main::SPELLCHECKLEX{lc($newword)}) || ($newword=~/^[\.\?\!\,\:\;\'\d]+$/)) && ($frequency > $main::frequencyretainvariant)){
		push(@existingalternatives,$newword);
	}
    }
    return @existingalternatives;
}
