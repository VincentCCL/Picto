####### sclera_dutch.pm ##########

# By Leen Sevens and Vincent Vandeghinste
# leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 25.11.2013

#---------------------------------------

# This file contains the pictogram set specific info for TextToPicto conversion

#---------------------------------------

1;

$VERSION="1.1"; # 31.10.14 Sclera pictographs for possessive pronouns have been added
#$VERSION="1.0"; # Language dependent info is taken from sclera.pm and put here

#---------------------------------------
package sclera;
#---------------------------------------

sub getPronouns {
    my ($pkg,$persbez,$person,$number,$gender)=@_;
    if ($person=~/1/) {
	if ($number eq 'ev') {
	    if ($persbez eq 'pers') {
		return 'ik.png';
	    }
	    elsif ($persbez eq 'bez') {
		return 'mijn-2.png';
	    }
	}
	else {
	    if ($persbez eq 'pers') {
		return 'wij.png';
	    }
	    elsif ($persbez eq 'bez') {
		return 'ons.png';
	    }
	}
    }
    elsif ($person=~/2/) {
	if (($number eq 'ev') or
	    ($number eq 'getal')) {
	    if ($persbez eq 'pers') {
		return 'jij.png';
	    }
	    elsif ($persbez eq 'bez') {
		return 'jouw.png';
	    }
	}
	else { 
	    if ($persbez eq 'pers') {
		return 'jullie.png';
	    }
	    elsif ($persbez eq 'bez') {
		return 'jullie-3.png';
	    }
	}
    }
    elsif ($person=~/3/) {
	if (($number eq 'ev') or
	    ($number eq 'getal')) {
	    if ($gender eq 'masc') {
		if ($persbez eq 'pers') {
		    return 'hij.png';
		}
		elsif ($persbez eq 'bez') {
		    return 'zijn.png';
		}
	    }
	    elsif ($gender eq 'fem') {
		if ($persbez eq 'pers') {
		    return 'zij.png';
		}
		elsif ($persbez eq 'bez') {
		    return 'haar-2.png';
		}
	    }
	}
	else {
	    if ($persbez eq 'pers') {
		return 'zij-2.png';
	    }
	    elsif ($persbez eq 'bez') {
		return 'jullie-3.png';
	    }
	}
    }
}

