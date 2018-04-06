####### SpellCorrector_cornetto.pl ##########

# By Leen Sevens 
# leen@ccl.kuleuven.be 
# Date: 14.01.2016

#---------------------------------------

# Spelling corrector for people with an intellectual disability, trained on WAI-NOT data
# Example: perl SpellCorrector_cornetto.pl 'input'
# The input may consist of multiple sentences

#---------------------------------------

# See also: Sevens L., Vanallemeersch T., Schuurman I., Vandeghinste V., Van Eynde F. (2016). Automated Spelling Correction for Dutch Internet Users with Intellectual Disabilities. In Schuurman, I. (Ed.), Vandeghinste, V. (Ed.), Saggion, H. (Ed.), Proceedings of 1st Workshop on Improving Social Inclusion using NLP: Tools and Resources. Workshop on Improving Social Inclusion using NLP: Tools and Resources (ISI-NLP). Portorož, Slovenia, 23 May 2016 (pp. 11-19). ELRA: Paris.

#---------------------------------------

# Libraries

use Getopt::Std;
use FindBin qw($Bin); 
use DB_File;
use Encode;

require "$Bin/object.pm";
require "$Bin/FindCharacterRules.pm";
require "$Bin/Database.pm";

tie %lexicon,"DB_File","home/leen/Picto2.0/data/total.freqs.db"; 

my @dictionaryarray = (",","!","?","hey","hallo","groetjes","sebiet","zijt","chat","chatten");

#---------------------------------------

# Language model database

our $db="dutch_lm_large";
our $host="gobelijn";
our $port="5432";
our $user="vincent";
our $pwd="vincent";
our $dutch_lm=DBI::db->new($db,$host,$port,$user,$pwd);

#----------------------------------------

# PARAMETERS

getopt("abcdefghi",\%opts);
unless (defined($wordbuilderpenalty1=$opts{a})) {
	$wordbuilderpenalty1=210;
}
unless (defined($wordbuilderpenalty2=$opts{b})) {
	$wordbuilderpenalty2=120;
}
unless (defined($realwordminimumfrequency=$opts{c})) {
	$realwordminimumfrequency=100;
}
unless (defined($ngramlength=$opts{d})) {
	$ngramlength=8;
}
unless (defined($minimumscore=$opts{e})) {
	$minimumscore=0.2;
}
unless (defined($wordsplitterpenalty=$opts{f})) {
	$wordsplitterpenalty=1760;
}
unless (defined($frequencyretainvariant=$opts{g})) {
	$frequencyretainvariant=220;
}
unless (defined($highestfreqthresh=$opts{h})) {
	$highestfreqthresh=100;
}
unless (defined($wordsplitterpenalty2=$opts{i})) {
	$wordsplitterpenalty2=1680;
}

#---------------------------------------

# MAIN PROGRAM

$maxlengthwordinspellcheck=30;
tie %SPELLCHECKLEX,"DB_File","$Bin/../data/spellchecklex.db";
tie %FIRSTNAMES,"DB_File","$Bin/../data/firstnames.db"; 
tie %lexicon,"DB_File","$Bin/../data/total.freqs.db";

our $stamp=time;

our $singlewordsplitter="$Bin/Wordbuilder/SingleWordSplitter.pl";
our $outputforsinglewordsplitter="$Bin/Wordbuilder/outputsplitter";

our $inputfuzzymatch="$Bin/../tmp/spellcheck/inputfuzzymatch";
our $outputfuzzymatch="$Bin/../tmp/spellcheck/outputfuzzymatch";
our $fuzzymatcher="$Bin/get_approxquerycov_matches.bash";
our $tokenizedcorpus="$Bin/../data/CGNCorpusSplit.txt";

$in=shift(@ARGV);
$sessionid=shift(@ARGV);
$message=message->new(text,$in,
		      logfile,\*LOG);
$message->wordBuilder; 
$message->tokenize; 
$message->detectSentences; 
$message->spellcheck; 
print "\n";

#---------------------------------------
package message;
#---------------------------------------

sub wordBuilder{
    my ($pkg)=@_;
    my $message=$pkg->{text};
    my $newmessage;
    $message=~s/([\(\),\.\"\?!]+)/ $1/g;
    my @messagewords=split(/[ ]+/,$message);
    for(my $i=0;$i<@messagewords;$i++){
	    	$newword=$messagewords[$i].$messagewords[$i+1];
		if ($main::lexicon{$newword} > $main::wordbuilderpenalty1){ # When the compound word appears more than x times in the lexicon
			if(($main::lexicon{$messagewords[$i]} < $main::wordbuilderpenalty2) || ($main::lexicon{$messagewords[$i+1]} < $main::wordbuilderpenalty2)){ # And at least one of the separate parts less than y times
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
		$_->removeCapitalFirstWord; # Lowercase the first word of each sentence so we can look it up in the lexicon
		$_->changeAllUpperCaseToLower; # Some people write in ALL uppercase - convert to lowercase first
		$_->removeFlooding; # Tackle "flooding" (i.e., more than 2 identical characters in sequence, reduce it to max. 2 characters)
		$_->convertContractionsAndCommonAbbreviations; # Tackle some commonly appearing contractions and abbreviations
		$_->findNonWords; # What are the non-words and what are the real words?
		$_->findVariants; # The actual variant generation step
		$_->filterVariants; # Based on the language model, non-occurring combinations of variants are thrown away
		$_->buildAllSentences; # Create all possible combinations of variants - this results in a number of hypotheses
		$_->makeSplitSentences; # Split the hypotheses into characters (pre-processing step for the character-based fuzzy match)
		$_->fuzzyMatch; # Fuzzy matching and best hypothesis selection
	}
}

#---------------------------------------
package sentence;
#---------------------------------------

sub convertContractionsAndCommonAbbreviations{
    my ($pkg)=@_;
    my $words=$pkg->{words};
    foreach $word(@$words) {
	$token=$word->{token};
	$token=~s/^da$/dat/;
	$token=~s/^wa$/wat/;
	$token=~s/^nr$/nummer/;
	$token=~s/^das$/dat is/;
	$token=~s/^ist$/is het/;
	$token=~s/^tis$/het is/;
	$word->{token}=$token;
    }
}

sub removeCapitalFirstWord{
    my ($pkg)=@_;
    my $words=$pkg->{words};
    $firsttoken=lc(@$words[0]->{token});
    delete @$words[0]->{token};
    @$words[0]->{token}=$firsttoken;
}

sub changeAllUpperCaseToLower{
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

sub removeFlooding{
    my ($pkg)=@_;
    my $words=$pkg->{words};
    foreach (@$words) {
	$token=$_->{token};
    	$token=~s/((.)\2{2,})/$2$2/ig;
	$_->{token}=$token;
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
    foreach $words(@$words) {
	my $spellcheck=$words->{spellcheck};
	my $word=$words->{token};
	$frequency=$main::lexicon{$word};
	chomp $frequency;
        my @allalternatives=();	
	unless ((grep( /^$word$/, @dictionaryarray)) || ($word =~ /(\d)+/)){
		push(@allalternatives,$words->findPhoneticVariants); # COGNITIVE ERRROS
		unless(@allalternatives){ # If no cognitive variants are found, check for typographic errors
			if (($spellcheck eq "Real") && (($frequency>$main::realwordminimumfrequency) ||  ($main::FIRSTNAMES{$word}))) { 
					$flag;	
			}	
			else{
				push(@allalternatives,$words->wordSplitter); # Split a non-word if its separate parts each form an existing word with a minimum frequency
				push(@allalternatives,$words->findOneInsertion); # TYPOGRAPHIC ERRORS
				push(@allalternatives,$words->findOneDeletion); # TYPOGRAPHIC ERRORS
				push(@allalternatives,$words->findOneSubstitution); # TYPOGRAPHIC ERRORS
				push(@allalternatives,$words->findOneTransposition); # TYPOGRAPHIC ERRORS
			}
		}
	}
	unless(@allalternatives){ # If no alternatives are found, keep the original word
		push(@allalternatives,$word);
	}
	my %hash=();
	%hash=map{$_=>1} @allalternatives;
	my @unique = keys %hash;
	$words->{spellingalternatives}=[@unique]; # Remove duplicates
    }
    return $pkg;
}

sub filterVariants{
    my ($pkg)=@_;
    my $words=$pkg->{words};
    $amountofwords=scalar (@$words);
    if ($amountofwords eq "3"){
	    for(my $i=0;$i<@$words;$i++){
		$spellingalternatives=@$words[$i]->{spellingalternatives};
		$amountofspellingalternatives=scalar (@$spellingalternatives);
		if ($amountofspellingalternatives > 1){
			@filteredalternatives=();
				if($i eq "0"){
					foreach $alternative(@$spellingalternatives){
					LOOP: {
						$secondwordsspellingalternatives=@$words[$i+1]->{spellingalternatives};
						$thirdwordsspellingalternatives=@$words[$i+2]->{spellingalternatives};
						foreach $secondwordsspellingalternative(@$secondwordsspellingalternatives){
							foreach $thirdwordsspellingalternative(@$thirdwordsspellingalternatives){
								my $stmt = qq(select * from trigram where ngram='$alternative $secondwordsspellingalternative $thirdwordsspellingalternative';); 
						 	        $rows=$dutch_lm->lookup($stmt);
								if (@$rows[0]) {
									push(@filteredalternatives,$alternative);
									last LOOP;
								}
							}
						}
					}
					}
				}
				elsif($i eq "1"){
					foreach $alternative(@$spellingalternatives){
					LOOP: {
						$firstwordsspellingalternatives=@$words[$i-1]->{spellingalternatives};
						$thirdwordsspellingalternatives=@$words[$i+1]->{spellingalternatives};
						foreach $firstwordsspellingalternative(@$firstwordsspellingalternatives){
							foreach $thirdwordsspellingalternative(@$thirdwordsspellingalternatives){
								my $stmt = qq(select * from trigram where ngram='$firstwordsspellingalternative $alternative $thirdwordsspellingalternative';); 
						 	        $rows=$dutch_lm->lookup($stmt);
								if (@$rows[0]) {
									push(@filteredalternatives,$alternative);
									last LOOP;
								}
							}
						}
					}
					}
				}
				elsif($i eq "2"){
					foreach $alternative(@$spellingalternatives){
					LOOP: {
						$firstwordsspellingalternatives=@$words[$i-2]->{spellingalternatives};
						$secondwordsspellingalternatives=@$words[$i-1]->{spellingalternatives};
						foreach $firstwordsspellingalternative(@$firstwordsspellingalternatives){
							foreach $secondwordsspellingalternative(@$secondwordsspellingalternatives){
								my $stmt = qq(select * from trigram where ngram='$firstwordsspellingalternative $secondwordsspellingalternative $alternative';); 
						 	        $rows=$dutch_lm->lookup($stmt);
								if (@$rows[0]) {
									push(@filteredalternatives,$alternative);
									last LOOP;
								}
							}
						}
					}
					}
				}
				if(@filteredalternatives > 0){
					delete @$words[$i]->{spellingalternatives};
					@$words[$i]->{spellingalternatives}=[@filteredalternatives];
				}
		}
	   }
    }
    elsif ($amountofwords > 3){
	    my $amountofwordsminus1=$amountofwords - 1;
	    for(my $i=0;$i<@$words;$i++){
		$spellingalternatives=@$words[$i]->{spellingalternatives};
		$amountofspellingalternatives=scalar (@$spellingalternatives);
		if ($amountofspellingalternatives > 1){
			@filteredalternatives=();
				if($i eq "0"){
					foreach $alternative(@$spellingalternatives){
					LOOP: {
						$secondwordsspellingalternatives=@$words[$i+1]->{spellingalternatives};
						$thirdwordsspellingalternatives=@$words[$i+2]->{spellingalternatives};
						foreach $secondwordsspellingalternative(@$secondwordsspellingalternatives){
							foreach $thirdwordsspellingalternative(@$thirdwordsspellingalternatives){
								my $stmt = qq(select * from trigram where ngram='$alternative $secondwordsspellingalternative $thirdwordsspellingalternative';); 
						 	        $rows=$dutch_lm->lookup($stmt);
								if (@$rows[0]) {
									push(@filteredalternatives,$alternative);
									last LOOP;
								}
							}
						}
					}
					}
				}
				elsif($i eq $amountofwordsminus1){
					foreach $alternative(@$spellingalternatives){
					LOOP: {
						$firstwordsspellingalternatives=@$words[$i-2]->{spellingalternatives};
						$secondwordsspellingalternatives=@$words[$i-1]->{spellingalternatives};
						foreach $firstwordsspellingalternative(@$firstwordsspellingalternatives){
							foreach $secondwordsspellingalternative(@$secondwordsspellingalternatives){
								my $stmt = qq(select * from trigram where ngram='$firstwordsspellingalternative $secondwordsspellingalternative $alternative';); 
						 	        $rows=$dutch_lm->lookup($stmt);
								if (@$rows[0]) {
									push(@filteredalternatives,$alternative);
									last LOOP;
								}
							}
						}
					}
					}
				}
				else{
					foreach $alternative(@$spellingalternatives){
					LOOP: {
						$firstwordsspellingalternatives=@$words[$i-1]->{spellingalternatives};
						$thirdwordsspellingalternatives=@$words[$i+1]->{spellingalternatives};
						foreach $firstwordsspellingalternative(@$firstwordsspellingalternatives){
							foreach $thirdwordsspellingalternative(@$thirdwordsspellingalternatives){
								my $stmt = qq(select * from trigram where ngram='$firstwordsspellingalternative $alternative $thirdwordsspellingalternative';); 
						 	        $rows=$dutch_lm->lookup($stmt);
								if (@$rows[0]) {
									push(@filteredalternatives,$alternative);
									last LOOP;
								}
							}
						}
					}
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

sub buildAllSentences{
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

sub makeSplitSentences{
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

sub fuzzyMatch{ # Fuzzy match chooses the correct combination of variants within its context
    my ($pkg)=@_;
    my $splitsentences=$pkg->{splitsentences};
    open (FUZZYMATCHINPUT,">$main::inputfuzzymatch$stamp.txt");
    foreach(@$splitsentences){
	    print FUZZYMATCHINPUT "$_\n";
    }
    close FUZZYMATCHINPUT;
    `bash $main::fuzzymatcher -n $main::ngramlength -t ../tmp/fuzzy -p $main::highestfreqthresh $main::inputfuzzymatch$stamp.txt $main::tokenizedcorpus $main::minimumscore 0 $main::outputfuzzymatch$stamp.txt`; 
    `rm -f ../tmp/fuzzy/_approxquerycov*`;
    $pkg->retrieveLines;
}

sub retrieveLines{
	my ($pkg)=@_;
	my %data=();
	open (FUZZYMATCHINPUT,"<$main::inputfuzzymatch$stamp.txt");
	my $count=1;
	my %data=();
	while($lineinput=<FUZZYMATCHINPUT>){
		my $totaldifference;
		chomp $lineinput;
		open (FUZZYMATCHOUTPUT,"<$main::outputfuzzymatch$stamp.txt");
		my %scorehash=();
		while ($lineoutput=<FUZZYMATCHOUTPUT>){
			($querypos,$queryposnumber,$corppos,$corpposnumber,$sequence,$sequencename,$score,$scorenumber,$rank,$ranknumber,$links,$allcharacterpos,$rest)=split(/\t/,$lineoutput);
			if($queryposnumber eq $count){
				$allcharacterpos=~s/\? //g;
				@positionpairs=split(/ /,$allcharacterpos);
				foreach $positionpair(@positionpairs){
					($firstcharacter,$lastcharacter)=split(/-/,$positionpair);
					$difference=$lastcharacter-$firstcharacter;
					$key="$lineinput\t$sequencename\t$positionpair";
					$totaldifference=$totaldifference+$difference; # The winning hypothesis is the one that shares many and long character n-grams with the monolingual corpus
				}
				$amountofpositionpairs=scalar @positionpairs;
				if ($amountofpositionpairs > 1){ # Additional correction if a high-scoring match is found 
					for(my $i=0;$i<$amountofpositionpairs-1;$i++){
						($firstcharacter,$lastcharacter)=split(/-/,$positionpairs[$i]);
						($firstcharacter2,$lastcharacter2)=split(/-/,$positionpairs[$i+1]);
						$gap=$firstcharacter2-$lastcharacter;
						if ($gap<4){
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
								$scorehash{$leftmiddlerightsubstring}=$scorenumber;
							}
						}
					}
				}
			}
		}
						my $highestvaluekey=(sort {$scorehash{$a} <=> $scorehash{$b}} keys %scorehash)[0];
						($leftsubstring,$middlesubstring,$rightsubstring)=split(/\t/,$highestvaluekey);
	 					my ($originalmiddlestring) = $lineinput =~  /.*$leftsubstring((.){1,3})$rightsubstring.*/igs;
						if ((($main::SPELLCHECKLEX{$originalmiddlestring}) ||
					        ($main::SPELLCHECKLEX{lc($originalmiddlestring)}) ||
				                ($main::FIRSTNAMES{$originalmiddlestring}) ||
						($main::FIRSTNAMES{ucfirst($originalmiddlestring)})) && ($frequency>1000)){	
							$flag;
						}
						else{
							$lineinput =~s/(.*$leftsubstring).*($rightsubstring.*)/$1$middlesubstring$2/g; 
																       
						}
		$data{$lineinput}=$totaldifference;
		$count++;
	}
	$highestscoring=(sort {$data{$b} <=> $data{$a}} keys %data)[0];
	$highestscoring=~s/ //g;
	$highestscoring=~s/%/ /g;
	$highestscoring=~s/ !/!/g;
	$highestscoring=~s/ ,/,/g;
	$highestscoring=~s/ \?/\?/g;
	$highestscoring=~s/ \./\./g;
	$highestscoringucfirst=ucfirst $highestscoring;
	print "$highestscoringucfirst ";
  	`rm -f $main::inputfuzzymatch$stamp.txt`;
   	`rm -f $main::inputfuzzymatch$stamp.txt_nolong`;
        `rm -f $main::outputfuzzymatch$stamp.txt`;
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
    if(($spellcheck eq "Non-word") || ($frequency < $main::wordsplitterpenalty)){
    	`perl $singlewordsplitter -i $main::wordsplitterpenalty2 '$word' > $main::outputforsinglewordsplitter$stamp.txt`;
	open (OUTPUTSPLITTER,"<$main::outputforsinglewordsplitter$stamp.txt");
	while($line=<OUTPUTSPLITTER>){
		chomp $line;
		@outputwords=split(/\t/,$line);
		$amountofwords=scalar @outputwords;
		if ($amountofwords > 1){
			$line=~s/\t/ /g;
			return $line;
		}
	}
	`rm -f $main::outputforsinglewordsplitter$stamp.txt`;
    }
    else{
	   return;
    }
}

sub lookupInDictionary {
    my ($pkg)=@_;
    my $word=$pkg->{token};
    if (length($word)<$main::maxlengthwordinspellcheck) {
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
			if (($main::SPELLCHECKLEX{$newtoken}) ||
			    ($main::FIRSTNAMES{$newtoken})) {
			    push(@oneinsertions,$newtoken);
			}
			elsif (($ucfirst=ucfirst($newtoken)) &&
			       ($main::FIRSTNAMES{$ucfirst})) {
			    push(@oneinsertions,$ucfirst);
			}
			else {
				$flag;
			}
		    }
		   @letters=@orig;
		}
	    }
    my @existingoneinsertions=();
    foreach $newword(@oneinsertions){
	$frequency=$main::lexicon{$newword};
	if ((($main::SPELLCHECKLEX{$newword}) ||
			($main::SPELLCHECKLEX{lc($newword)}) ||
			($newword=~/^[\.\?\!\,\:\;\'\d]+$/)) && ($frequency > $main::frequencyretainvariant)){
		push(@existingoneinsertions,$newword);
	}
    }
	return @existingoneinsertions;
}


sub findOneDeletion {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my $target=$pkg->{target};
    my (@onedeletions);
    push(@onedeletions,$token);
    my @orig=split(//,$token);
    my (@onedeletions);
    my @letters=@orig;
    my ($word,$ucfirst);
	    for (my $i=0;$i<@letters;$i++) {
		splice(@letters,$i,1);
		$word=join("",@letters);
		if (($main::SPELLCHECKLEX{$word}) ||
		    ($main::FIRSTNAMES{$word})) {
		    push(@onedeletions,$word);
		}
		elsif (($ucfirst=ucfirst($word)) &&
		       ($main::FIRSTNAMES{$ucfirst})) {
		    push(@onedeletions,$ucfirst);
		}
		else {
		    $flag;
		}
		@letters=@orig;
	    }
    my @existingonedeletions=();
    foreach $newword(@onedeletions){
	$frequency=$main::lexicon{$newword};
	chomp $frequency;
	if ((($main::SPELLCHECKLEX{$newword}) ||
			($main::SPELLCHECKLEX{lc($newword)}) ||
			($newword=~/^[\.\?\!\,\:\;\'\d]+$/)) && ($frequency > $main::frequencyretainvariant)){
		push(@existingonedeletions,$newword);
	}
    }
	return @existingonedeletions;
}

sub findOneSubstitution {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my (@oneinsertions);
    push(@oneinsertions,$token);
    my @origs=split(//,$token);
    my @inserts=qw(a b c d e f g h i j k l m n o p q r s t u v w x y z ä ë ï ö ü à è ò ù é ç);
    my @letters=@origs;
    my ($newtoken,$ucfirst);
	    for (my $i=0;$i<@letters;$i++) {
		foreach (@inserts) {
		    unless ($_ eq $letters[$i]) {
			splice(@letters,$i,1,$_);
			$newtoken=join("",@letters);
			if (($main::SPELLCHECKLEX{$newtoken})||
			    ($main::FIRSTNAMES{$newtoken})) {
			    push(@oneinsertions,$newtoken);
			}
			elsif (($ucfirst=ucfirst($newtoken)) &&
			       ($main::FIRSTNAMES{$ucfirst})) {
			    push(@oneinsertions,$ucfirst);
			}
			else {
				$flag;
			}
		    }
		    @letters=@origs;
		}
	    }
    my @existingoneinsertions=();
    foreach $newword(@oneinsertions){
	$frequency=$main::lexicon{$newword};
	if ((($main::SPELLCHECKLEX{$newword}) ||
			($main::SPELLCHECKLEX{lc($newword)}) ||
			($newword=~/^[\.\?\!\,\:\;\'\d]+$/)) && ($frequency > $main::frequencyretainvariant)){
		push(@existingoneinsertions,$newword);
	}
    }
	return @existingoneinsertions;
}

sub findOneTransposition {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my (@onetranspositions);
    push(@onetranspositions,$token);
    for my $i (0 .. length($token)-2) { 
    	(my $newtoken = $token) =~ s/(.{$i})(.)(.)/$1$3$2/;
			if (($main::SPELLCHECKLEX{$newtoken})||
			    ($main::FIRSTNAMES{$newtoken})) {
			    push(@onetranspositions,$newtoken);
			}
			elsif (($ucfirst=ucfirst($newtoken)) &&
			    ($main::FIRSTNAMES{$ucfirst})) {
			    push(@onetranspositions,$ucfirst);
			}
			else {
				$flag;
			}
    }
    my @existingonetranspositions=();
    foreach $newword(@onetranspositions){
	$frequency=$main::lexicon{$newword};
	if ((($main::SPELLCHECKLEX{$newword}) ||
			($main::SPELLCHECKLEX{lc($newword)}) ||
			($newword=~/^[\.\?\!\,\:\;\'\d]+$/)) && ($frequency > $main::frequencyretainvariant)){
		push(@existingonetranspositions,$newword);
	}
    }
	return @existingonetranspositions;
}
