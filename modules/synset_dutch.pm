# synset_dutch.pm
# previously synset_cornetto.pm ########

# By Vincent Vandeghinste
# vincent@ccl.kuleuven.be
# Date: 28.01.2014

#---------------------------------------

$VERSION='1.1'; # 09.04.2021 object::openWordnet is moved to object.pm
#$VERSION='1.0'; # Functions taken over from synset.pm to remove language dependence

#---------------------------------------------

print $log "synset_dutch.pm loaded\n" if $log;
1;

#---------------------------------------
package word;
#---------------------------------------

sub addWordnet {
    my ($pkg)=@_;
    my $tok=$pkg->{token};
    if ($pkg->{tag} =~/^(N|VG|WW|ADJ|TW|BW|VZ\(fin\)|TSW)/) { 
	$pkg->addLexUnits;
	$pkg->addSynsets;
	$pkg->filterLexUnitsAccordingToPos;
    }
    else {
    }
}


sub filterLexUnitsAccordingToPos {
    my ($pkg)=@_;
    my $pos=$pkg->{tag};
    my $lexunits=$pkg->{lexunits};
    my $lupos;
    for ($i=0;$i<@$lexunits;$i++) {
	$lupos=$lexunits->[$i]->{synset}->{pos};
	if ($lupos=~/^VERB/) {
	    unless ($pos=~/^WW/) {
		splice(@$lexunits,$i,1);
		$i--;
		next;
	    }
	}
	elsif ($lupos=~/^NOUN/) {
	    unless ($pos=~/^N|ADJ|WW\(nom|TW/) {
		splice(@$lexunits,$i,1);
		$i--;
		next;
	    }
	    if ($lupos=~/DE$/) {
	      if ($pos=~/onz/ && $pos!~/dim/) {
	         splice(@$lexunits,$i,1);
	         $i--;
	         next;
	      }
	    }
	    elsif ($lupos=~/HET$/) {
	      if ($pos=~/zijd/) {
	        splice(@$lexunits,$i,1);
	        $i--;
	        next;
	      }
	    }
	}
	elsif ($lupos=~/^ADJECTIVE/) {
	    unless ($pos=~/^ADJ/) {
		splice(@$lexunits,$i,1);
		$i--;
		next;
	    }
	}
	elsif ($lupos=~/^ADVERB/) {
	    unless ($pos=~/^BW|ADJ/) {
		splice(@$lexunits,$i,1);
		$i--;
		next;
	    }
	}
    }
}
