####### simplifybackup.pm ##########
# Originally named: cornetto.pm

# By Vincent Vandeghinste
# vincent@ccl.kuleuven.be
# Date: 22.11.2013

#---------------------------------------

# The original taglemmatise module for shallow linguistic analysis. This module is still activated when the simplification module is turned off, or when a time-out occurs during parsing.
# See also: Vandeghinste V., Schuurman I., Sevens L., Van Eynde F. (2015). Translating text into pictographs. Natural Language Engineering, 23 (2), 217-244.

#---------------------------------------

$VERSION="1.2"; # 11.02.2014 Spell checking checks first names
#$VERSION="1.1.4"; # 07.02.2014 No spell checking for numbers !
#$VERSION="1.1.3"; # 06.02.2014 AdaptPolarity is now logged +  bug fix + bug fix to spellchecker
#$VERSION="1.1.2"; # 28.01.2014 All ref to cornetto replaced by wordnet + addition of getNegativeWord
#$VERSION="1.1.1"; # 13.01.2014 Bug fix in word::findMostFrequent
#$VERSION="1.1"; # 10.12.2013 stamp=time.$main::sessionid
#$VERSION="1.0.2"; # 05.12.2013 More robust version of endOfSentence
#$VERSION="1.0.1"; # 23.11.2013 Improved logging for sepverbs
#$VERSION="1.0";

1;

#---------------------------------------

# Location of the Hunpos Tagger
# Halácsy, Péter, András Kornai, Csaba Oravecz (2007) HunPos - an open source trigram tagger In Proceedings of the 45th Annual Meeting of the Association for Computational Linguistics Companion Volume Proceedings of the Demo and Poster Sessions. Association for Computational Linguistics, Prague, Czech Republic, pages 209--212.

$hunposlocation="$Bin/Hunpos/"; # Path of the hunpos application
$hunpostraining="$Bin/../data/cgn+lassy_klein"; # Path of the hunpos training data

#---------------------------------------

# Location of compounding info for separable verbs
# Vandeghinste, V. (2002). Lexicon Optimization: Maximizing Lexical Coverage in Speech Recognition through Automated Compounding. In M. Rodríguez and C. Araujo (eds.), Proceedings of the 3rd International Conference on Language Resources and Evaluation (LREC). European Language Resources Association. Las Palmas, Spain. 

tie %lexicon,"DB_File","$Bin/../data/total.freqs.db"; # Location of the frequency lexicon (Berkeley)
tie %headmodsolo,"DB_File","$Bin/../data/ModHead.freqs.db"; # Location of the database containing frequency information about heads and modifiers in compound nouns (Berkeley)
tie %difmod,"DB_File","$Bin/../data/DifModsPerHead.db"; # Location of the database containing info on how many different mods were found per head (Berkeley)
$compoundprobthreshold=0.05; # Cf Vandeghinste (2002) for more info

        # P(stroopsmeren)=0.049
        # P(doorgeef)=0.0028

#---------------------------------------

# Lemma database extracted from CGN and Lassy
tie %LEMMAS,"DB_File","$Bin/../data/lemmas.db";

# Opentaal lexicon
tie %SPELLCHECKLEX,"DB_File","$Bin/../data/spellchecklex.db";

# Firstnames lexicon
tie %FIRSTNAMES,"DB_File","$Bin/../data/firstnames.db"; # List of all first names of all people living in Belgium in 2009 occuring more than once

$maxlengthwordinspellcheck=30;

#---------------------------------------
package message;
#---------------------------------------

sub findSeparableVerbs {
    my ($pkg)=@_;
    my $sentences=$pkg->{sentences};
    my $log=$pkg->{logfile};
    my $result;
    foreach (@$sentences) {
	$result=1;
	while ($result) {
	    $result=$_->findSeparableVerbs;
	}
    }
}

sub tag {
    my ($pkg)=@_;
    my $stamp=time.$main::sessionid;
    my $log=$pkg->{logfile};
    open (TMP,">$main::tempfilelocation/$stamp");
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
	    $word=word->new(logfile,$pkg->{logfile},
			    target,$pkg->{target},
			    token,$tok,
			    tag,$tag,
			    wordnetdb,$pkg->{wordnetdb});
	    push(@words,$word);
	}
    }
    unlink "$main::tempfilelocation/$stamp.tmp" || print "\nCannot delete $main::tempfilelocation/$stamp.tmp\n";
    $pkg->{words}=[@words];
}

#---------------------------------------
package sentence;
#---------------------------------------

sub findSeparableVerbs {
    my ($pkg)=@_;
    my $words=$pkg->{words};
    my (@pvs,@particles);
    for (my $i=0;$i<@$words;$i++) {
	if ($words->[$i]->{tag}=~/^WW\((pv|inf|vd)/) {
	    push(@pvs,$words->[$i]);
	}
	# DETECT POTENTIAL PARTICLES
	elsif (($words->[$i]->{tag} eq 'VZ(fin)') ||  
	       ($words->[$i]->{tag}=~/N\(soort.*stan/) ||
	       ($words->[$i]->{tag}=~/ADJ\(vrij/) ||
	       ($words->[$i]->{tag}=~/BW/)) {
	    push(@particles,$words->[$i])
	}
    }
    my ($freq,$topfreq,$topcomp,$toppv,$topparticle);
    my $log=$pkg->{logfile};
    # COMBINE PVS WITH PARTICLES AND CHECK FREQ IN CORPUS
    foreach (@pvs) {
	foreach $particle (@particles) {
	    $compound=$particle->{token}.$_->{token};
	    $freq=$main::lexicon{$compound};
	    chomp($freq);
	    if ($freq>$topfreq) {
		# CHECK IF TOP WORD IS MORE PROBABLE THAN SEPARATE WORDS
		my $result=$main::headmodsolo{$_->{token}};
		my ($ashead,$asmod,$solo)=split(/\t/,$result);
		my $difmods=$main::difmod{$_->{token}};
		my $compoundprob=$freq/$ashead * (1- $difmods/$ashead);
		if ($compoundprob > $main::compoundprobthreshold) {
		    $topfreq=$freq;
		    $topcomp=$compound;
		    $toppv=$_;
		    $tophead=$_->{token};
		    $topmod=$particle->{token};
		    $topparticle=$particle;
		}
		else {
		}
	    }
	    else {
		unless ($freq) {
		    $freq=0;
		}
	    }
	}
    }
    if ($toppv) {
	# CREATE COMPOUND WORD 
	$toppv->{token}=$topcomp;
	# AND ADAPT LIST OF WORDS
	for ($i=0;$i<@$words;$i++) {
	    if ($words->[$i] eq $topparticle) {
		splice(@$words,$i,1);
		last;
	    }
	}
	return 1;
    }
    else {
	return undef;
    }
}

sub adaptPolarity { 
    # If a negative word is found we look for the head of this word and put it in the feature polarity
    # And remove the negative word from the word list
    my ($pkg,$negwordindex)=@_;
    my $log=$pkg->{logfile};
    my $words=$pkg->{words};
    my ($head,$windowsize,$hypothesis);
    my $negword=$words->[$negwordindex];
    if (($negword->{tag} eq 'BW()') &&
	($negword->{lemma} eq 'niet')) {
	# LOOKING FOR THE HEAD OF 'NIET'
	my $maxwindowsize=3; 
	until ($head) {
	    $windowsize++;
	    if ($windowsize>$maxwindowsize) {
		last;
	    }
	    $hypothesis=$words->[$negwordindex+$windowsize];
	    if ($hypothesis->{tag}=~/WW|ADJ|BW/) {
		$head=$hypothesis
	    }
	    else {
		$hypothesis=$words->[$negwordindex-$windowsize];
		if ($hypothesis->{tag}=~/WW|ADJ|BW/) {
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
    if (($pkg->{lemma} eq 'niet') &&
	($pkg->{tag} eq 'BW()')) {
	return 1;
    } 
    elsif (($pkg->{lemma} eq 'geen') &&
	   ($pkg->{pos} =~/prenom/)) {
	return 1;
    }
    else {
	return undef;
    }
}

sub getNegativeWord {
    my ($pkg)=@_;
    my $negword=word->new(logfile,$pkg->{logfile},
			  lemma,'niet',
			  tag,'BW()',
			  token,'niet');
    return $negword;
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

sub lemmatize_rules { # If lemma is not found in the lexicon, apply hand-crafted rules (descriptions are given in Dutch)
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my $tag=$pkg->{tag};
    my $lemma;
    if ($tag=~/eigen/) {
	$lemma=$token;
    }
    else {
	$lemma=lc($token);
    }
    if ($tag=~/^VNW/) { # Verwijderen van -e bij voornaamwoorden (det), anders is lemma gelijk aan token
        if(($tag=~/met-e/) &&
           ($tag=~/det/)) {
            $lemma=~s/e$//;
        }
    }
    elsif (($tag=~/^N/) && # Verwijderen van diminutiefuitgang bij nouns
           ($tag=~/dim/)) {
	my ($dim)=$lemma=~/((et|p)?jes?)$/;
	unless ($dim) {
	    ($dim)=$lemma=~/(e?kes?)$/;
	}
	# Check for words like 'pakket'
	my $testlemma=$lemma;
	$testlemma=~s/je$//;
	if ($main::SPELLCHECKLEX{$testlemma}) { 
	    $lemma=$testlemma;
	}
	else {
	    $lemma=~s/$dim$//;
	    $lemma=~s/([fglmnr])\1$/\1/; # Verwijder dubbele medeklinker (mannetje)
	}
	
    }
    elsif (($tag=~/^N/) &&  # Verwijderen van uitgang enkelvoud en meervoud bij nouns
           ($tag=~/mv/)) {
        if ($token=~/'s$/) {
            $lemma=~s/'s$//;
        }
        elsif ($token=~/s$/) {
            $lemma=~s/s$//;
        }
        elsif ($token=~/en$/) { # Klinkerverdubbeling bij meervoud van open lettergreep (schapen - schaap)
            if ($token=~/([^aeiou])([aeou])([^aeiou])en$/) {
                $lemma=~s/en$//;
                $lemma=~s/([^aeiou])([aeou])([^aeiou])$/$1$2$2$3/;
            }
            elsif ($token=~/([^aeiou])([aeiou])([^aeiou])\3en$/) { # Medeklinkervereenvoudiging bij dubbele medeklinkers voor gesloten lettergreep in mv (mannen - man)
                $lemma=~s/en$//;
                $lemma=~s/([^aeiou])([aeiou])([^aeiou])\3$/$1$2$3/;
            }
            elsif ($token=~/zen$/) { # Medeklinkerwisseling van z naar s
                $lemma=~s/zen$/s/;
            }
	    elsif ($token=~/ven$/) { # Medeklinkerwisseling van v naar f
                $lemma=~s/ven$/f/;
            }
            else {$lemma=~s/en$//;}
        }
    }
    elsif (($tag=~/^WW/) &&
           ($tag=~/od/)) {
        if ($tag=~/met-e/) {
            $lemma=~s/de$//;
        }
        elsif (($tag=~/zonder/) && # Snorrende, komende, kennende en dergelijke hebben niet tag 'met-e' hoewel ze er toch op eindigen
               ($lemma=~/de$/)) {
            $lemma=~s/de$//;
        }
        else {$lemma=~s/d$//;}
    }
    elsif (($tag=~/^WW/) && # Voltooide deelwoorden
           ($tag=~/vd/)) {
        $lemma=~s/ge//;
        if ($tag=~/met-e/) {
            $lemma=~s/e$/en/;
        }
        elsif ($lemma=~/([aeiou])d$/) {
            $lemma.='en';
        }
        elsif ($lemma=~/([aeou])\1([^aeiou])d$/) { # Klinkervereenvoudiging
            $lemma=~s/d$//;
            $lemma=~s/([aeou])\1([^aeiou])$/$1$2/;
            $lemma.='en';
        }
        elsif ($lemma=~/([^aeiou])d$/) {
            $lemma=~s/d$//;
            $lemma.='en';
        }
        elsif ($lemma=~/([^aeiou])t$/) {
            $lemma=~s/t$//;
            if ($lemma=~/([aeiou])\1([^aeiou])$/) { # Gemaakt wordt maken
                $lemma=~s/([aeiou])\1([^aeiou])$/$1$2/;
                $lemma.='en';}
            else {$lemma.='en';} # Gehurkt wordt hurken
        }
        elsif ($lemma=~/([aeou])([^aeiou])$/) {
            $lemma=~s/([aeou])([^aeiou])$/$1$2$2/;
            $lemma.='en';
        }
        else {$lemma.='en';}
    }
    
    elsif (($tag=~/^WW/) &&
	   ($tag=~/verl/)) {
        if ($tag=~/mv/) {
            if ($lemma=~/([aeou])\1([^aeiou])den$/) { # Klinkervereenvoudiging (haalden - halen)
                $lemma=~s/([aeou])\1([^aeiou])den$/$1$2/;
                $lemma=~s/den$//;
            }
            else {$lemma=~s/den$//;}
        }
        elsif ($tag=~/ev/) {
            $lemma=~s/de$//;
        }
        $lemma.='en';
    }

    elsif (($tag=~/^WW/)&&
           ($tag=~/tgw/) &&
           ($tag=~/ev/))        {
        if ($token=~/([^aeiou])(e|a|i|o|u)([^aeiou])$/) { # Medeklinkerverdubbeling
            $lemma=~s/([^aeiou])(e|a|i|o|u)([^aeiou])$/$1$2$3$3/;
            $lemma.='en'; }
        elsif ($lemma=~/(e|o|u|a|i)\1([^aeiou])$/){ # Klinkervereenvoudiging
            $lemma=~s/(e|o|u|a)\1([^aoeui])$/$1$2/;
            $lemma=~s/f$/v/; # Geef - gef - gev
            $lemma=~s/s$/z/; # Lees - les - lez
            $lemma.='en'; }
        else {$lemma.='en';}
    }

    elsif ($tag=~/^TW/) { # Telwoorden
        if ($token=~/^(eerste)$/) {
            $lemma='één';
        }
        elsif ($token=~/^(derde)$/) {
            $lemma='drie';
        }
        else {$lemma=~s/de$//;}
    }

    elsif (($tag=~/^ADJ/) && # Comparatieven en superlatieven
           ($tag=~/comp/)) {
        $lemma=~s/er$//;
    }

    elsif (($tag=~/^ADJ/) &&
           ($tag=~/sup/) &&
           ($tag=~/met-e/)) {
        $lemma=~s/ste$//;
    }

    elsif (($tag=~/^WW/) &&
           ($tag=~/met-t/)) {
        $lemma=~s/t$//;
        if (($main::lexicon{$lemma."en"}) ||
        	($main::SPELLCHECKLEX{$lemma."en"})) {
        	$lemma.='en';
        }
        elsif ($lemma=~/([aeou])([^aeiou])([aeou])([^aeiou])$/) { # Gevallen als betekenen (wordt anders *betekennen door medeklinkerverdubbeling hieronder)
 	           $lemma.='en';}
        elsif ($lemma=~/([^aeiou])(e|a|i|o|u)([^aeiou])$/) { # Medeklinkerverdubbeling
            $lemma=~s/([^aeiou])(e|a|i|o|u)([^aeiou])$/$1$2$3$3/;
            $lemma.='en'; }

        elsif ($lemma=~/(e|o|u|a|i)\1([^aeiou])$/){ # Klinkervereenvoudiging
            $lemma=~s/(e|o|u|a)\1([^aoeui])$/$1$2/;
            $lemma.='en'; }
        elsif ($lemma=~/([aeiou])([aeiou])$/) { # Staat wordt staan ipv *staaen en ziet wordt zien
            $lemma.='n';
        }
        elsif ($lemma=~/f$/) {
            $lemma=~s/f$/ven/;
        }
        elsif ($lemma=~/s$/) {
            $lemma=~s/s$/zen/;
        }
        else {$lemma.='en';}
    }

    elsif (($tag=~/^ADJ/) &&
           ($tag=~/met-e/)) {
        $lemma=~s/e$//;
        if ($lemma=~/([^aeiou])([aeiou])z$/) { # Vb. boze wordt boos
            $lemma=~s/([^aeiou])([aeiou])z$/$1$2$2s/;
        }
        elsif ($lemma=~/([^aeiou])([aeiou])v$/) { # Vb. brave wordt braaf
            $lemma=~s/([^aeiou])([aeiou])v$/$1$2$2f/;
        }
        elsif ($lemma=~/([^aeiou])([aeiou])([^aeiou])$/) { # Klinkerverdubbeling bij open lettergreep
            $lemma=~s/([^aeiou])([aeiou])([^aeiou])$/$1$2$2$3/;
        }
    }
    $pkg->{lemma}=$lemma;
}
 	
