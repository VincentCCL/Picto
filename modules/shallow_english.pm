####### english.pm ########

# By Leen Sevens and Vincent Vandeghinste
# leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 16.09.14

#---------------------------------------
# Functions taken over from object.pm to remove all language dependent info
#---------------------------------------

$VERSION="1.0.2."; # 26.09.2014 Lemmatizer takes token as lemma if no lemma is found
#$VERSION="1.0.1."; # 22.09.2014 Utf-8 compliant, works with accented input
#$VERSION="1.0"; # 16.09.14 English version based on dutch.pm (VERSION="1.2")

1;

#---------------------------------------

## LOCATIONS OF HUNPOS TAGGER 
# Halácsy, Péter, András Kornai, Csaba Oravecz (2007) HunPos - an open source trigram tagger In Proceedings of the 45th Annual Meeting of the Association for Computational Linguistics Companion Volume Proceedings of the Demo and Poster Sessions. Association for Computational Linguistics, Prague, Czech Republic, pages 209--212.

$hunposlocation="$Bin/Hunpos/"; # Path of the hunpos application
$hunpostraining="$Bin/modules/hunpos_data/english.model"; # Path of the hunpos training data

#---------------------------------------

# LEMMA DATABASE: AMERICAN NATIONAL CORPUS http://www.americannationalcorpus.org/SecondRelease/frequency2.html
tie %LEMMAS,"DB_File","$Bin/modules/ANClemma/ANC_lemma.db" or die; # Location of the lemma database

## SPELL CHECKING INPUT WORDS

# LEMMA AND FREQUENCY DATABASE: AMERICAN NATIONAL CORPUS http://www.americannationalcorpus.org/SecondRelease/frequency2.html
$lexname="$Bin/modules/ANClemma/ANC_lemmafreq.db";
tie %SPELLCHECKLEX,"DB_File",$lexname;
tie %lexicon,"DB_File",$lexname;

# Firstnames lexicon
tie %FIRSTNAMES,"DB_File","$Bin/modules/ANClemma/english_firstnames.db"; # http://www.quietaffiliate.com/free-first-name-and-last-name-databases-csv-and-sql

$maxlengthwordinspellcheck=30;

#---------------------------------------
package message;
#---------------------------------------

sub taglemmatize {
    # If $nospellcheck contains 'nospellcheck' spellchecking is skipped
    # If $nospellcheck contains 'sclera' the sclera dictionary is also checked before spellchecking
    my ($pkg,$nospellcheck)=@_;
    $pkg->addFullStop;
    $pkg->findCompound;
    $pkg->tokenize;
    unless ($nospellcheck eq 'nospellcheck') {
	$pkg->spellCheck($nospellcheck);
    }
    $pkg->tag;
    $pkg->detectSentences;
    $pkg->lemmatize;
}

sub findCompound {
    my ($pkg)=@_;
    my $words=$pkg->{text};
    my $words=lc($words);
    $words=~s/(.*)how are you doing(.*)/$1how_are_you$2/g;
    $words=~s/(.*)how are you(.*)/$1how_are_you$2/g;
    $words=~s/(.*)it's(.*)/$1it is$2/g;
    $words=~s/(.*)that's(.*)/$1that is$2/g;
    $words=~s/(.*)i'm(.*)/$1i am$2/g;
    $words=~s/(.*)i've(.*)/$1i have$2/g;
    $words=~s/(.*)there's(.*)/$1there is$2/g;
    $words=~s/(.*)you've(.*)/$1you have$2/g;
    $words=~s/(.*)we've(.*)/$1we have$2/g;
    $words=~s/(.*)he's(.*)/$1he is$2/g;
    $words=~s/(.*)she's(.*)/$1she is$2/g;
    $words=~s/(.*)they're(.*)/$1they are$2/g;
    $words=~s/(.*)we're(.*)/$1we are$2/g;
    $words=~s/(.*)you're(.*)/$1you are$2/g;
    $words=~s/(.*)doesn't(.*)/$1does not$2/g;
    $words=~s/(.*)don't(.*)/$1do not$2/g;
    $words=~s/(.*)let's(.*)/$1let us$2/g;
    $words=~s/(.*)wasn't(.*)/$1was not$2/g;
    $words=~s/(.*)i'll(.*)/$1i will$2/g;
    $words=~s/(.*)you'll(.*)/$1you will$2/g;
    $words=~s/(.*)we'll(.*)/$1we will$2/g;
    $words=~s/(.*)can't(.*)/$1can not$2/g;
    $words=~s/(.*)how's(.*)/$1how is$2/g;
    $words=~s/(.*)guinea\spig(.*)/$1guinea_pig$2/g;
    $words=~s/(.*)bottled\swater(.*)/$1bottled_water$2/g;
    $words=~s/(.*)crossword\spuzzle(.*)/$1crossword_puzzle$2/g;
    $words=~s/(.*)hot\sdog(.*)/$1hot_dog$2/g;
    $words=~s/(.*)ice\scream(.*)/$1ice_cream$2/g;
    $words=~s/(.*)light\sbulb(.*)/$1light_bulb$2/g;
    $words=~s/(.*)paper\sclip(.*)/$1paper_clip$2/g;
    $words=~s/(.*)post\soffice(.*)/$1post_office$2/g;
    $words=~s/(.*)report\scard(.*)/$1report_card$2/g;
    $words=~s/(.*)rib\scage(.*)/$1rib_cage$2/g;
    $words=~s/(.*)prime\sminister(.*)/$1prime_minister$2/g;
    $words=~s/(.*)ring\sfinger(.*)/$1ring_finger$2/g;
    $words=~s/(.*)roller\scoaster(.*)/$1roller_coaster$2/g;
    $words=~s/(.*)sleeping\sbag(.*)/$1sleeping_bag$2/g;
    $words=~s/(.*)phone\snumber(.*)/$1phone_number$2/g;
    $words=~s/(.*)tree\shouse(.*)/$1tree_house$2/g;
    $words=~s/(.*)video\sgame(.*)/$1video_game$2/g;
    $words=~s/[^[:ascii:]]//g;
    $pkg->{text}=$words;
}

sub tag {
    my ($pkg)=@_;
    my $stamp=time.$main::sessionid;
    my $log=$pkg->{logfile};
    print $log "Part of Speech Tagging\n";
    open (TMP,">:utf8","$main::tempfilelocation/$stamp");
    my $words=$pkg->{words};
    foreach (@$words) {
    	$token=$_->{token};
    	print TMP "$token\n";
    }
    close TMP;
    `$main::hunposlocation/hunpos-tag $main::hunpostraining < $main::tempfilelocation/$stamp > $main::tempfilelocation/$stamp.tmp`;
    unlink "$main::tempfilelocation/$stamp";
    open (TMP,"$main::tempfilelocation/$stamp.tmp");
    my @words;
    while (<TMP>) {
    	chomp;
	($tok,$tag)=split(/\t/,$_);
	if (defined($tok)) {
	    print $log "\t$tok\t$tag\n";
	    $word=word->new(logfile,$pkg->{logfile},
			    target,$pkg->{target},
			    token,$tok,
			    tag,$tag,
			    wordnetdb,$pkg->{wordnetdb});
	    push(@words,$word);
	}
    }
    unlink "$main::tempfilelocation/$stamp.tmp" || print $log "\nCannot delete $main::tempfilelocation/$stamp.tmp\n";
    print $log "--------------\n";
    $pkg->{words}=[@words];
}

#---------------------------------------
package sentence;
#---------------------------------------

sub adaptPolarity { 
    # If a negative word is found we look for the head of this word and 
    # Put it in the feature polarity
    # And remove the negative word from the word list
    my ($pkg,$negwordindex)=@_;
    my $log=$pkg->{logfile};
    my $words=$pkg->{words};
    my ($head,$windowsize,$hypothesis);
    my $negword=$words->[$negwordindex];
    if (($negword->{tag} eq 'RB') && # Adverb
	($negword->{lemma} eq 'not')) {
	# LOOKING FOR THE HEAD OF 'NOT'
	my $maxwindowsize=3; ## PARAMETER
	until ($head) {
	    $windowsize++;
	    if ($windowsize>$maxwindowsize) {
		last;
	    }
	    $hypothesis=$words->[$negwordindex+$windowsize];
	    if ($hypothesis->{tag}=~/VB|VBD|VBG|VBN|VPB|VBZ|JJ|JJR|JJS|RN|RBS|RBR/) {
		$head=$hypothesis
	    }
	    else {
		$hypothesis=$words->[$negwordindex-$windowsize];
		if ($hypothesis->{tag}=~/VB|VBD|VBG|VBN|VPB|VBZ|JJ|JJR|JJS|RN|RBS|RBR/) {
		    $head=$hypothesis
		}
	    }
	}
    }
    if ($head) {
	# Remove negative word
	splice(@$words,$negwordindex,1);
	# Adapt polarity of word
	my $headtoken=$head->{token};
	print $log "Negative word 'not' detected and removed\n";
	print $log "Polarity of '$headtoken' adapted\n";
	$head->{polarity}=$negword;
	return 1;
    }
    return undef;
}

#---------------------------------------
package word;
#---------------------------------------

sub isNegative {
    my ($pkg)=@_;
    if (($pkg->{lemma} eq 'not') &&
	($pkg->{tag} eq 'RB')) {
	return 1;
    } 
    elsif (($pkg->{lemma} eq 'no') &&
	   ($pkg->{pos} =~/DT/)) {
	return 1;
    }
    else {
	return undef;
    }
}

sub getNegativeWord {
    my ($pkg)=@_;
    my $negword=word->new(logfile,$pkg->{logfile},
			  lemma,'not',
			  tag,'RB',
			  token,'not');
    return $negword;
}

sub spellCheck {
    # If Sclera is defined, this indicates that the word should
    # Also be looked up in the Sclera lexicon -> if it occurs, no spellcheck!	
    my ($pkg)=@_;
    my $picto=$pkg->{target};
    my $word=$pkg->{token};
    my $log=$pkg->{logfile};
    if (length($word)<$main::maxlengthwordinspellcheck) {
	unless (($main::SPELLCHECKLEX{$word}) ||
		($main::SPELLCHECKLEX{lc($word)}) ||
		($main::FIRSTNAMES{$word}) ||
		($main::FIRSTNAMES{ucfirst($word)}) ||
		($word=~/^[\.\?\!\,\:\;\'\d]+$/)) {
	    unless (($picto) &&
		    ($pkg->lookupPictoDictionary ||
		    ($pkg->addLexUnits))) {
		$alternatives=$pkg->findSpellingAlternatives;
		if ($bestcorrection=findMostFrequent($alternatives)) {
		    $pkg->{token}=$bestcorrection;
		}
	    }
	}
    }	
}
sub findMostFrequent {
    my ($alternatives)=@_;
    my $maxfreq=0;
    my $best;
    foreach (@$alternatives) {
	if ($main::lexicon{$_} > $maxfreq) {
	    $best=$_;
	    $maxfreq=$main::lexicon{$_};
	}
    }
    return $best;
}
sub findOneDeletion {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my $target=$pkg->{target};
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
	    $hypothesis=word->new('token',$word,
				  wordnetdb,$pkg->{wordnetdb},
				  target,$target,
				  logfile,$pkg->{logfile});
	    if ($hypothesis->addLexUnits) {
		push(@onedeletions,$word);
	    }
	}
	@letters=@orig;
    }
    return [@onedeletions];
}

sub findOneInsertion {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my $target=$pkg->{target};
    my @orig=split(//,$token);
    my @inserts=qw(a b c d e f g h i j k l m n o p q r s t u v w x y z ä ë ï ö ü à è ò ù é ç);
#   push(@inserts,map uc,@inserts);
    my (@oneinsertions);
    my @letters=@orig;
    my ($newtoken,$ucfirst);
    for (my $i=0;$i<@letters;$i++) {
	foreach (@inserts) {
	    unless ($_ eq $letters[$i]) {
		splice(@letters,$i,0,$_);
		$newtoken=join("",@letters);
		if (($main::SPELLCHECKLEX{$newtoken}) ||
		    ($main::FIRSTNAMES{$word})) {
		    push(@oneinsertions,$newtoken);
		}
		elsif (($ucfirst=ucfirst($newtoken)) &&
		       ($main::FIRSTNAMES{$ucfirst})) {
		    push(@oneinsertions,$ucfirst);
		}
		else {
		    $hypothesis=word->new('token',$newtoken,
					  wordnetdb,$pkg->{wordnetdb},
					  target,$target,
					  logfile,$pkg->{logfile});
		    if ($hypothesis->addLexUnits) {
			push(@oneinsertions,$newtoken);
		    }
		}
	    }
	    @letters=@orig;
	}
    }
    return [@oneinsertions];
}

sub findOneSubstitution {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my @origs=split(//,$token);
    my @inserts=qw(a b c d e f g h i j k l m n o p q r s t u v w x y z ä ë ï ö ü à è ò ù é ç);
 #  push(@inserts,map uc,@inserts);
    my (@oneinsertions);
    @letters=@origs;
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
		    $hypothesis=word->new('token',$newtoken,
					  wordnetdb,$pkg->{wordnetdb},
					  target,$target,
					  logfile,$pkg->{logfile});
		    if ($hypothesis->addLexUnits) {
			push(@oneinsertions,$newtoken);
		    }
		}
	    }
	    @letters=@origs;
	}				
    }
    return [@oneinsertions];
}

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

sub lemmatize {
    my ($pkg)=@_;
    my $tok=$pkg->{token};
    my $tok=lc($tok);
    my $tag=$pkg->{tag};
    if (my $lemma=$main::LEMMAS{"$tok\t$tag"}) {
	$pkg->{lemma}=$lemma;
    }
    else {
	$pkg->lemmatize_rules;
    }
    if ($pkg->{lemma} eq '_') {
	$pkg->{lemma}=$tok;
    }
    elsif ($pkg->{lemma} eq '') {
	$pkg->{lemma}=$tok;
    }
}

sub lemmatize_rules {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my $tag=$pkg->{tag};
    my $lemma;
    $pkg->{lemma}=$lemma;
}
 	
