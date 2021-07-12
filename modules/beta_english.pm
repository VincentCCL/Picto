####### beta_english.pm ##########

# By Leen Sevens
# leen@ccl.kuleuven.be
# Date: Spring 2014

#---------------------------------------
# This file contains the pictogram set specific info for 
# TextToPicto conversion
#---------------------------------------
1;

$VERSION="1.0"; # English version of beta_dutch.pm (VERSION="1.0.1")

#---------------------------------------
package beta;
#---------------------------------------

sub getPronouns {
    # Give person, number and gender, and we give you the filename
    my ($pkg,$pronoun)=@_;
    if (($pronoun eq 'i') || ($pronoun eq 'me')){
	return 'ik.png';
    }
    elsif ($pronoun eq 'my'){
	return 'mijn.png';
    }
    elsif (($pronoun eq 'we') || ($pronoun eq 'us')){
	return 'wij.png';
    }
    elsif ($pronoun eq 'our'){
	return 'ons.png';
    }
    elsif ($pronoun eq 'you'){
	return 'jij.png';
    }
    elsif ($pronoun eq 'your'){
	return 'jouw.png';
    }
    elsif ($pronoun eq 'you'){
	return 'jullie_vnw.png';
    }
    elsif ($pronoun eq 'your'){
	return 'jullie_bvnw.png';
    }
    elsif (($pronoun eq 'he') || ($pronoun eq 'him')){
	return 'hij.png';
    }
    elsif ($pronoun eq 'it'){
	next;
    }
    elsif ($pronoun eq 'his'){
	return 'zijn_bvnw.png';
    }
    elsif ($pronoun eq 'she'){
	return 'zij_enkelv.png';
    }
    elsif ($pronoun eq 'her'){
	return 'haar_bvnw.png';
    }
    elsif (($pronoun eq 'they') || ($pronoun eq 'them')){
	return 'zij_meerv.png';
    }
    elsif ($pronoun eq 'their'){
	return 'hun.png';
    }
}

