####### sclera_english.pm ##########

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
    # give person, number and gender, and we give you the filename
    my ($pkg,$pronoun)=@_;
    if (($pronoun eq 'i') || ($pronoun eq 'me')){
	return 'ik.png';
    }
    elsif ($pronoun eq 'my'){
	return 'mijn-2.png';
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
	return 'jullie.png';
    }
    elsif ($pronoun eq 'your'){
	return 'jullie-3.png';
    }
    elsif (($pronoun eq 'he') || ($pronoun eq 'him')){
	return 'hij.png';
    }
    elsif ($pronoun eq 'it'){
	next;
    }
    elsif ($pronoun eq 'his'){
	return 'zijn.png';
    }
    elsif ($pronoun eq 'she'){
	return 'zij.png';
    }
    elsif ($pronoun eq 'her'){
	return 'haar-2.png';
    }
    elsif (($pronoun eq 'they') || ($pronoun eq 'them')){
	return 'zij-2.png';
    }
    elsif ($pronoun eq 'their'){
	return 'jullie-3.png';
    }
}
