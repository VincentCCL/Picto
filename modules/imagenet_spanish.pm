####### beta_spanish.pm ##########

# By Leen Sevens
# leen@ccl.kuleuven.be
# Date: Spring 2014

#---------------------------------------
# This file contains the pictogram set specific info for 
# TextToPicto conversion
#---------------------------------------
1;

$VERSION="1.0"; # Spanish version of beta_dutch.pm (VERSION="1.0.1")

#---------------------------------------
package imagenet;
#---------------------------------------

sub getPronouns {
    # Give person, number and gender, and we give you the filename
    my ($pkg,$pronoun)=@_;
    if ($pronoun eq 'yo'){
	return 'ik.png';
    }
    elsif (($pronoun eq 'mi') || ($pronoun eq 'mis') ||  ($pronoun eq 'mí') || ($pronoun eq 'mío') || ($pronoun eq 'mía') || ($pronoun eq 'míos') || ($pronoun eq 'mías')){
	return 'mijn.png';
    }
    elsif (($pronoun eq 'nosotros') || ($pronoun eq 'nosotras')){
	return 'wij.png';
    }
    elsif (($pronoun eq 'nuestro') || ($pronoun eq 'nuestra') || ($pronoun eq 'nuestros') || ($pronoun eq 'nuestras')){
	return 'ons.png';
    }
    elsif (($pronoun eq 'tú') || ($pronoun eq 'usted')){
	return 'jij.png';
    }
    elsif (($pronoun eq 'tuyo') || ($pronoun eq 'tuya') || ($pronoun eq 'tuyos') || ($pronoun eq 'tuyas') || ($pronoun eq 'ti') || ($pronoun eq 'tu') || ($pronoun eq 'tus')){
	return 'jouw.png';
    }
    elsif (($pronoun eq 'vosotros') || ($pronoun eq 'vosotras') || ($pronoun eq 'ustedes')){
	return 'jullie_vnw.png';
    }
    elsif (($pronoun eq 'vuestro') || ($pronoun eq 'vuestra') || ($pronoun eq 'vuestros') || ($pronoun eq 'vuestras')){
	return 'jullie_bvnw.png';
    }
    elsif ($pronoun eq 'él'){
	return 'hij.png';
    }
    elsif (($pronoun eq 'su') || ($pronoun eq 'sus') || ($pronoun eq 'suyo') || ($pronoun eq 'suya') || ($pronoun eq 'suyos') || ($pronoun eq 'suyas')){
	return 'zijn_bvnw.png';
    }
    elsif ($pronoun eq 'ella'){
	return 'zij_enkelv.png';
    }
    elsif (($pronoun eq 'ellos') || ($pronoun eq 'ellas')){
	return 'zij_meerv.png';
    }
}

