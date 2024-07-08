####### spanish.pm ########

# By Leen Sevens and Vincent Vandeghinste
# leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 16.09.14

#---------------------------------------
# functions taken over from object.pm to remove all language dependent info
#---------------------------------------

$VERSION="1.2"; # 24.06.2024 Paths adapted to new installation, tmpfile usage for teeetagger removed
#$VERSION="1.1"; # 27.01.2015 Major changes in the spelling checker: now via Postgres instead of DB files to deal with (and correct) Spanish accents
#$VERSION="1.0.2."; # 26.09.2014 Lemmatizer takes token as lemma if no lemma is found
#$VERSION="1.0.1."; # 22.09.2014 Utf-8 compliant, works with accented input
#$VERSION="1.0"; # 16.09.14 Spanish version based on dutch.pm (VERSION="1.2")

1;

#---------------------------------------

## LOCATIONS OF TAGGER: FINDS POS TAG AND LEMMA 
our $taggerlocation="$Bin/modules/TreeTagger/cmd"; # Path of the TreeTagger application http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/

#---------------------------------------

## SPELL CHECKING INPUT WORDS

#tie %SPELLCHECKLEX,"DB_File","$Bin/../data/SpanishTokenFreq.db";
#tie %lexicon,"DB_File","$Bin/../data/SpanishTokenFreq.db";

# Firstnames lexicon
#tie %FIRSTNAMES,"DB_File","$Bin/../data/LemmaDBNames.db"; # http://www.quietaffiliate.com/free-first-name-and-last-name-databases-csv-and-sql

$maxlengthwordinspellcheck=30;

#---------------------------------------
package message;
#---------------------------------------

sub taglemmatize {
    # If $nospellcheck contains 'nospellcheck' spellchecking is skipped
    # If $nospellcheck contains 'sclera' the sclera dictionary is also checked before spellchecking
    my ($pkg)=@_;#,$nospellcheck)=@_;
    $pkg->addFullStop;
    $pkg->findCompound;
    $pkg->tokenize;
    $pkg->tag;
    $pkg->detectSentences;
}

sub findCompound {
    my ($pkg)=@_;
    my $words=$pkg->{text};
    my $words=lc($words);
    $words=~s/(.*)cómo estás(.*)/$1cómo_estás$2/g;
    $words=~s/(.*)patata frita(.*)/$1patata_frita$2/g;
    $words=~s/(.*)patatas fritas(.*)/$1patatas_fritas$2/g;
    $words=~s/(.*)fin de semana(.*)/$1fin_de_semana$2/g;
    $words=~s/(.*)de menos(.*)/$1$2/g;
    $pkg->{text}=$words;
}

sub tag {
    my ($pkg)=@_;
    my $stamp=time.$main::sessionid;
    my (@lastthreetokens,$i,$flag);
    my $i = 0;
    my $log=$pkg->{logfile};
    print $log "Part of Speech Tagging and lemmatization\n";
    #print $log "Creating tempfile $main::tempfilelocation/$stamp\n";
    #open (TMP,">:utf8","$main::tempfilelocation/$stamp") or die;
    my @tokens;
    my $words=$pkg->{words};
    foreach (@$words) {
    	push(@tokens,$_->{token});
    }
#    close TMP;
    my $wordstring=join("\n",@tokens);
    my $systemcommand = "echo \$\'$wordstring\' | $main::taggerlocation/tree-tagger-spanish";
    print $log "$systemcommand\n" if $log;
    @taggeroutput = `$systemcommand`;
    #`$main::taggerlocation/tree-tagger-spanish < $main::tempfilelocation/$stamp > $main::tempfilelocation/$stamp.tmp`;
    #unlink "$main::tempfilelocation/$stamp";
    #open (TMP,"$main::tempfilelocation/$stamp.tmp");
    #my @words;
    #while (<TMP>) {
    foreach (@taggeroutput) {
    	chomp;
	($tok,$tag,$lemma)=split(/\t/,$_);
	if (defined($tok)) {
	    my $flag = 0;
            print $log "\t$tok\t$tag\t$lemma\n";
	    if ((($tag eq 'VLfin') || ($tag eq 'VEfin') || ($tag eq 'VSfin') ||  ($tag eq 'VHfin')) && (($tok=~/.*o$/) || ($tok=~/.*é$/) || ($tok=~/.*í$/) || ($tok=~/^he$/) ||  ($tok=~/^soy$/) || ($tok=~/^voy$/) || ($tok=~/^estoy$/) || ($tok=~/^estaba$/))) {
                for ($i-1) {
		    if (@lastthreetokens[$_] eq 'yo') {
                        $flag=1;
                        last;
		    }
                }
                for ($i-2) {
                   if (@lastthreetokens[$_] eq 'yo') {
                        $flag=1;
                        last;
                   }
                }
                for ($i-3) {
                   if (@lastthreetokens[$_] eq 'yo') {
                        $flag=1;
                        last;
                   }
                }
		if($flag eq '0'){
			print $log "\tThis is a first person singular\n";
			$prodroppedword=word->new(logfile,$pkg->{logfile},
				    target,$pkg->{target},
				    token,'yo',
	 			    tag,'PPX',
			 	    lemma,'yo',
				    wordnetdb,$pkg->{wordnetdb});
			push(@words,$prodroppedword);
		}
	    }
 	    elsif ((($tag eq 'VLfin') || ($tag eq 'VEfin') || ($tag eq 'VHfin') || ($tag eq 'VSfin')) && (($tok=~/.*mos$/) || ($tok=~/^somos$/) || ($tok=~/^hemos$/) || ($tok=~/^estamos$/))) {
                for ($i-1) {
                   if ((@lastthreetokens[$_] eq 'nosotros') || (@lastthreetokens[$_] eq 'nosotras'))  {
                        $flag=1;
                        last;
                   }
                }
                for ($i-2) {
                   if ((@lastthreetokens[$_] eq 'nosotros') || (@lastthreetokens[$_] eq 'nosotras')) {
                        $flag=1;
                        last;
                   }
                }
                for ($i-3) {
                   if ((@lastthreetokens[$_] eq 'nosotros') || (@lastthreetokens[$_] eq 'nosotras')) {
                        $flag=1;
                        last;
                   }
                }
		if($flag eq '0'){
			print $log "\tThis is a first person plural\n";
			$prodroppedword=word->new(logfile,$pkg->{logfile},
				    target,$pkg->{target},
				    token,'nosotros',
	 			    tag,'PPX',
			 	    lemma,'nosotros',
				    wordnetdb,$pkg->{wordnetdb});
			push(@words,$prodroppedword);
		}
	    }
 	    elsif ((($tag eq 'VLfin') || ($tag eq 'VEfin') || ($tag eq 'VHfin') || ($tag eq 'VSfin')) && (($tok=~/.+es$/) || ($tok=~/.*as$/) || ($tok=~/.*abas$/) || ($tok=~/.*iste$/) || ($tok=~/^estás$/) || ($tok=~/^eres$/) || ($tok=~/^has$/))) {
                   for ($i-1) {
                   if (@lastthreetokens[$_] eq 'tú') {
                        $flag=1;
                        last;
                   }
                }
                for ($i-2) {
                   if (@lastthreetokens[$_] eq 'tú') {
                        $flag=1;
                        last;
                   }
                }
                for ($i-3) {
                   if (@lastthreetokens[$_] eq 'tú') {
                        $flag=1;
                        last;
                   }
                }
		if($flag eq '0'){
			print $log "\tThis is a second person singular\n";
			$prodroppedword=word->new(logfile,$pkg->{logfile},
				    target,$pkg->{target},
				    token,'tú',
	 			    tag,'PPX',
			 	    lemma,'tú',
				    wordnetdb,$pkg->{wordnetdb});
			push(@words,$prodroppedword);
		}
	    }
 	    elsif ((($tag eq 'VLfin') || ($tag eq 'VEfin') || ($tag eq 'VHfin') || ($tag eq 'VSfin')) && (($tok=~/.*ís$/) || ($tok=~/.*áis$/) || ($tok=~/.*éis$/) || ($tok=~/.*eis$/) || ($tok=~/.*ais$/) || ($tok=~/^sois$/) || ($tok=~/^habéis$/) || ($tok=~/^estáis$/))) {
                for ($i-1) {
                   if ((@lastthreetokens[$_] eq 'vosotros') || (@lastthreetokens[$_] eq 'vosotras'))  {
                        $flag=1;
                        last;
                   }
                }
                for ($i-2) {
                   if ((@lastthreetokens[$_] eq 'vosotros') || (@lastthreetokens[$_] eq 'vosotras')) {
                        $flag=1;
                        last;
                   }
                }
                for ($i-3) {
                   if ((@lastthreetokens[$_] eq 'vosotros') || (@lastthreetokens[$_] eq 'vosotras')) {
                        $flag=1;
                        last;
                   }
                }
		if($flag eq '0'){
			print $log "\tThis is a second person plural\n";
			$prodroppedword=word->new(logfile,$pkg->{logfile},
				    target,$pkg->{target},
				    token,'vosotros',
	 			    tag,'PPX',
			 	    lemma,'vosotros',
				    wordnetdb,$pkg->{wordnetdb});
			push(@words,$prodroppedword);
		}
	    }
	    if($lemma eq '<unknown>'){
   	    $word=word->new(logfile,$pkg->{logfile},
			    target,$pkg->{target},
			    token,$tok,
			    tag,$tag,
		 	    lemma,$tok,
			    wordnetdb,$pkg->{wordnetdb});
	    }
	    elsif($tok eq 'hermana'){
   	    $word=word->new(logfile,$pkg->{logfile},
			    target,$pkg->{target},
			    token,$tok,
			    tag,$tag,
		 	    lemma,$tok,
			    wordnetdb,$pkg->{wordnetdb});
	    }
	    else{
	    $word=word->new(logfile,$pkg->{logfile},
			    target,$pkg->{target},
			    token,$tok,
			    tag,$tag,
		 	    lemma,$lemma,
			    wordnetdb,$pkg->{wordnetdb});
	    }
	    push(@lastthreetokens,$tok);
	    push(@words,$word);
	    $i++;
 	    $pkg->{words}=[@words];
	}
    }
#    unlink "$main::tempfilelocation/$stamp.tmp" || print $log "\nCannot delete $main::tempfilelocation/$stamp.tmp\n";
    print $log "--------------\n";
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
    if (($negword->{tag} eq 'NEG') && # Adverb
	($negword->{lemma} eq 'no')) {
	# LOOKING FOR THE HEAD OF 'NOT'
	my $maxwindowsize=3; ## PARAMETER
	until ($head) {
	    $windowsize++;
	    if ($windowsize>$maxwindowsize) {
		last;
	    }
	    $hypothesis=$words->[$negwordindex+$windowsize];
	    if ($hypothesis->{tag}=~/VCLIger|VCLIinf|VCLIfin|VEadj|VEfin|VEger|VEinf|VHadj|VHfin|VHger|VHinf|VLadj|VLfin|VLger|VLinf|VMadj|VMfin|VMger|VMinf|VSadj|VSfin|VSger|VSinf|ADJ|DM|ADV|CARD/) {
		$head=$hypothesis
	    }
	    else {
		$hypothesis=$words->[$negwordindex-$windowsize];
		if ($hypothesis->{tag}=~/VCLIger|VCLIinf|VCLIfin|VEadj|VEfin|VEger|VEinf|VHadj|VHfin|VHger|VHinf|VLadj|VLfin|VLger|VLinf|VMadj|VMfin|VMger|VMinf|VSadj|VSfin|VSger|VSinf|ADJ|DM|ADV|CARD/) {
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
use utf8;
use DB_File; # From CPAN

sub isNegative {
    my ($pkg)=@_;
    if (($pkg->{lemma} eq 'no') &&
	($pkg->{tag} eq 'NEG')) {
	return 1;
    } 
    else {
	return undef;
    }
}

sub getNegativeWord {
    my ($pkg)=@_;
    my $negword=word->new(logfile,$pkg->{logfile},
			  lemma,'no',
			  tag,'NEG',
			  token,'no');
    return $negword;
}

sub spellCheck {
    # If Sclera is defined, this indicates that the word should
    # Also be looked up in the Sclera lexicon -> if it occurs, no spellcheck!	
    my ($pkg)=@_;
    my $picto=$pkg->{target};
    my $word=$pkg->{token};
    my $lcword=lc($word);
    my $log=$pkg->{logfile};
    
    if (length($word)<$main::maxlengthwordinspellcheck) {
	#unless (($main::SPELLCHECKLEX{$word}) ||
	#	($main::SPELLCHECKLEX{lc($word)}) ||
	 unless(($word=~/^[\.\?\!\,\:\;\'\d]+$/) ||
                ($word=$pkg->existsindictionary) ||
	        ($lcword=$pkg->existsindictionary) ||
         	($main::FIRSTNAMES{$word}) ||
		($main::FIRSTNAMES{ucfirst($word)})) {
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

sub existsindictionary {
    my ($pkg)=@_;
    my $sql="select number from spellcheck where word='$pkg->{token}';";
    my $db=DBI::db->new($cornetto::database,
			    $cornetto::host,
			    $cornetto::port,
			    $cornetto::user,
			    $cornetto::pwd);
    $pkg->{wordnetdb}=$db;
    my $results=$pkg->{wordnetdb}->lookup($sql);
    if (my $number=$results->[0]->[0]) {
	return 1;
    }
    else{
	return undef;
    }
}

sub findMostFrequent {
    my ($alternatives)=@_;
    my $maxfreq=0;
    my $best;
    foreach (@$alternatives) {
	my $sql="select frequency from spellcheck where word='$_';";
        my $db=DBI::db->new($cornetto::database,
			    $cornetto::host,
			    $cornetto::port,
			    $cornetto::user,
			    $cornetto::pwd);
        $pkg->{wordnetdb}=$db;
	my $results=$pkg->{wordnetdb}->lookup($sql);
        if ($results->[0]->[0] > $maxfreq) {
	 #if ($main::lexicon{$_} > $maxfreq) {
	  #  $best=$_;
	  #  $maxfreq=$main::lexicon{$_};
	     $best=$_ ;
	     $maxfreq=$results->[0]->[0];
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
    my @inserts=qw(a b c d e f g h i j k l m n o p q r s t u v w x y z ä ë ï ö ü à è ò ù é í á ó ú ñ ç);
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
}

sub lemmatize_rules {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my $tag=$pkg->{tag};
    my $lemma;
    $pkg->{lemma}=$lemma;
}
 	
