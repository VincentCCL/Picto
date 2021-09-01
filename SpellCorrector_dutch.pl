####### SpellCorrector_dutch.pl ##########

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

require "$Bin/modules/FindCharacterRules.pm";
require "$Bin/modules/GenericFunctionsSpellcheck.pm";

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
$message->addExtraStops;
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

sub addExtraStops{
    my ($pkg)=@_;
    my $text=$pkg->{text};
    $text=~s/\./ ./ig;
    $text=~s/\?/ ?/ig;
    $text=~s/\!/ !/ig;
    my @words=split(/\s/,$text);
    my $i=1;
    my $newstring="";
    foreach $word(@words){
	    if($i eq "20"){
		$word="$word.";
		$newstring="$newstring $word";
		$i=1;
	    }
	    elsif (($word eq ".") || ($word eq "?") || ($word eq "!")){
		$newstring="$newstring $word";
		$i=1;
	    }
	    else{
		$newstring="$newstring $word";
		$i++;
	    }
    }
    $newstring=~s/^ //ig;
    $pkg->{text}=$newstring;
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
    foreach my $word_object (@$words) {
	my $spellcheck=$word_object->{spellcheck}; 
	my $word=$word_object->{token};
        my @alternatives=();	
	my $frequency=$main::lexicon{$word};
	chomp $frequency;
	unless ($dictionary->{$word} or $word=~/(\d)+/) {
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

sub performFuzzyMatch { 
    my ($pkg)=@_;
    my $splitsentences=$pkg->{splitsentences};
    $input=join("\\n",@$splitsentences);
    $cmd="echo -e \"$input\" | salm_modified/Bin/Linux/Search/LocateEmbeddedNgramsInCorpus.O64 $main::tokenizedcorpus $main::highestfreqthresh 100000000 $main::ngramlength 10000000 $main::minimumscore 0" ;
    @fuzzysalm=`$cmd`;
    my $querypos=0;
    my @fuzzytransformed=();
    foreach (@fuzzysalm) {
	if (/(^0) (.+$)/) { 
	   $querypos++;
           $inputzin=$2;
        }
        elsif (/^\d+/) { 
          chomp;
          ($linenr,$string,$score,$querydown,$position)=split(/\t/);
	  push(@fuzzytransformed,[$querypos,$inputzin,$linenr,$string,$score,$position]);
        }
     }
     $pkg->processFuzzyMatchOutput(@fuzzytransformed);
}

sub processFuzzyMatchOutput {
  my ($pkg,@fuzzy)=@_;
  my (%INPUTSENTENCE,%SCORE,%GAPHASH)=();
  foreach (@fuzzy) {
     my ($querypos,$input,$line,$str,$score,$position)=@$_;
     my @positionpairs=split(/\s/,$position);
     if (@positionpairs>2) { 
        my ($leftmiddlerightsubstring)=$pkg->performCharacterGapSubstitution($str,$input,@positionpairs);
	if($leftmiddlerightsubstring){
	 	$gaphash{$leftmiddlerightsubstring}=$score;
	}
     }
     my ($begin, $end);
     while (@positionpairs) {
       $begin=shift(@positionpairs);
       $end=shift(@positionpairs);
       $SCORE{$querypos}+=$end-$begin;  # Add the difference between end and begin positions of the match
     }
     if(%gaphash){
	  my $highestvaluekey=(sort {$gaphash{$a} <=> $gaphash{$b}} keys %gaphash)[0];
	  ($leftsubstring,$middlesubstring,$rightsubstring)=split(/\t/,$highestvaluekey);
	  $input=~s/ //g;
	  $input =~s/(.*$leftsubstring).*($rightsubstring.*)/$1$middlesubstring$2/g;       
     }
     $INPUTSENTENCE{$querypos}=$input;   
  }
  @highest=sort{$SCORE{$b} <=> $SCORE{$a}} keys %SCORE; # Get highest score
  $output=&makenicestring($INPUTSENTENCE{$highest[0]}); 
  print "$output";
}

sub makenicestring{
   my ($str)= @_;
   $str=~s/ //g;
   $str=~s/%/ /g;
   $str=~s/ ([!,\?\.])/$1/g;
   $str=ucfirst $str;
   return $str;
}

sub performCharacterGapSubstitution{
        my ($pkg,$sequencename,$lineinput,@positionpairs)=@_;
        my (@begins,@ends);
        while (@positionpairs) {
           push(@begins,shift(@positionpairs));
           push(@ends,shift(@positionpairs));
        }
        for(my $i=0;$i<@begins-1;$i++){
                $gap=$begins[$i+1]-$ends[$i];
		if ($gap<$main::maximumcharactergap){
			@letters=split(/ /,$sequencename);
			$leftsubstring="";
			$rightsubstring="";
			$middlesubstring="";
			$lineinput=~s/ //g;
			for (my $j=$begins[$i]-1;$j<$ends[$i];$j++) {
				$leftsubstring=$leftsubstring."$letters[$j]";
			}
			for (my $k=$begins[$i+1]-1;$k<$ends[$i+1];$k++) {
				$rightsubstring=$rightsubstring."$letters[$k]";
			}
			for (my $l=$ends[$i];$l<$begins[$i+1]-1;$l++) {
				$middlesubstring=$middlesubstring."$letters[$l]";
			}
			if(($lineinput =~ /.*$leftsubstring(.){1,3}$rightsubstring.*/) || ($lineinput =~ /.*$leftsubstring(){1,3}$rightsubstring.*/)){
				$leftmiddlerightsubstring="$leftsubstring\t$middlesubstring\t$rightsubstring";				
				return($leftmiddlerightsubstring);				
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
        foreach $line (@output) {
		chomp $line;
		@outputwords=split(/\t/,$line);
		$amountofwords=scalar @outputwords;
		if ($amountofwords > 1){
			$line=~s/\t/ /g;
			return $line;
		}
	}
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
