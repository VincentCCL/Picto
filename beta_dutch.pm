####### beta_dutch.pm ##########

# By Vincent Vandeghinste
# vincent@ccl.kuleuven.be
# Date: 25.11.2013

#---------------------------------------

# This file contains the pictogram set specific info for TextToPicto conversion

#---------------------------------------

1;

$VERSION="1.0.1"; # 29.11.13 .png instead of .gif
#$VERSION="1.0"; # Language dependent info is taken from beta.pm and put here

#---------------------------------------
package beta;
#---------------------------------------

sub getPronouns {
    my ($pkg,$persbez,$person,$number,$gender)=@_;
    if ($person=~/1/) {
	if ($number eq 'ev') {
	    if ($persbez eq 'pers') {
		return 'ik.png';
	    }
	    elsif ($persbez eq 'bez') {
		return 'mijn.png';
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
		return 'jullie_vnw.png';
	    }
	    elsif ($persbez eq 'bez') {
		return 'jullie_bvnw.png';
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
		    return 'zijn_bvnw.png';
		}
	    }
	    elsif ($gender eq 'fem') {
		if ($persbez eq 'pers') {
		    return 'zij_enkelv.png';
		}
		elsif ($persbez eq 'bez') {
		    return 'haar_bvnw.png';
		}
	    }
	}
	else {
	    if ($persbez eq 'pers') {
		return 'zij_meerv.png';
	    }
	    elsif ($persbez eq 'bez') {
		return 'hun.png';
	    }
	}
    }
}

