####### sclera_spanish.pm ##########

# By Leen Sevens
# leen@ccl.kuleuven.be
# Spring 2014

#---------------------------------------
# This file contains the pictogram set specific info for 
# TextToPicto conversion
#---------------------------------------
1;

$VERSION="1.1"; # 31.10.14 Sclera pictographs for possessive pronouns have been added
#$VERSION="1.0"; # Language dependent info is taken from sclera.pm and put here

#---------------------------------------
package sclera;
#---------------------------------------

sub getPronouns {
    # Give person, number and gender, and we give you the filename
    my ($pkg,$pronoun)=@_;
    if ($pronoun eq 'yo'){
	return 'ik.png';
    }
    elsif (($pronoun eq 'mi') || ($pronoun eq 'mis') ||  ($pronoun eq 'mí') || ($pronoun eq 'mío') || ($pronoun eq 'mía') || ($pronoun eq 'míos') || ($pronoun eq 'mías')){
	return 'mijn-2.png';
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
	return 'jullie.png';
    }
    elsif (($pronoun eq 'vuestro') || ($pronoun eq 'vuestra') || ($pronoun eq 'vuestros') || ($pronoun eq 'vuestras')){
	return 'jullie-3.png';
    }
    elsif ($pronoun eq 'él'){
	return 'hij.png';
    }
    elsif (($pronoun eq 'su') || ($pronoun eq 'sus') || ($pronoun eq 'suyo') || ($pronoun eq 'suya') || ($pronoun eq 'suyos') || ($pronoun eq 'suyas')){
	return 'zijn.png';
    }
    elsif ($pronoun eq 'ella'){
	return 'zij.png';
    }
    elsif (($pronoun eq 'ellos') || ($pronoun eq 'ellas')){
	return 'zij-2.png';
    }
}

