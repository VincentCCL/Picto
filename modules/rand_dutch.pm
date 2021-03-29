####### rand_dutch.pm ##########

# By Ineke Schuurman, Leen Sevens and Vincent Vandeghinste
# leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 03.12.2018


#---------------------------------------

# This file contains the pictogram set specific info for TextToPicto conversion

#---------------------------------------

1;

$VERSION="0.1"; # 03.12.2018 copied from sclera_dutch, adapted for Rand (Ineke Schuurman)

#---------------------------------------
package rand;
#---------------------------------------

sub getPronouns { # returns nothings -- should be solved through the dictionary
}

sub getPronouns_ {
    my ($pkg,$persbez,$person,$number,$gender)=@_;
    if ($person=~/1/) {
	if ($number eq 'ev') {
	    if ($persbez eq 'pers') {
		return 'ik.png';
	    }
      	}
	else {
	    if ($persbez eq 'pers') {
		return 'wij.png';
	    }	  
	}
    }
    elsif ($person=~/2/) {
	if (($number eq 'ev') or
	    ($number eq 'getal')) {
	    if ($persbez eq 'pers') {
		return 'jij.png';
	    }	   
	} 
   
	else { 
	    if ($persbez eq 'pers') {
		return 'jullie.png';
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
	    }
	}
	    elsif ($gender eq 'fem') {
		if ($persbez eq 'pers') {
		    return 'zij2.png';
		}
	    }
     }
	else {
	    if ($persbez eq 'pers') {
		return 'zij.png';
	    }
	    elsif ($persbez eq 'bez') {
		return 'jullie-3.png';
	    }
	}
    }

   
