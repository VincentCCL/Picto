####### picto_french.pm ##########

# By Magali Norré, Leen Sevens and Vincent Vandeghinste
# magali.norre@uclouvain.be, leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 22.02.2021

#---------------------------------------

1;

$VERSION="2.1"; # 15.03.2021 Tryout in lookupPictoDictionary (see lookupSynonymResyf in picto.pm)
#$VERSION="1.0"; # 22.02.2021 French version based on picto_spanish.pm (VERSION="1.3")

require "$Bin/modules/sclera.pm"; 
require "$Bin/modules/beta.pm"; 
require "$Bin/modules/arasaac.pm"; 

use utf8; #!#

#---------------------------------------
package word;
#---------------------------------------

sub getNumber {
    my ($pkg)=@_;
    if ($pkg->{tag}=~/\bev\b/) {
	return 1;
    }
    elsif ($pkg->{tag}=~/\bmv\b/) {
	return 2;
    }
    else {
	return undef;
    }
}

sub lookupPictoDictionary {
    my ($pkg)=@_;
    my ($token,$lctoken,$lemma,$lclemma,$tag,$shorttag);
    if ($token=$pkg->{token}) {
	$token=~s/\'/&pos;/g;
	$lctoken=lc($token);
    }
    if ($lemma=$pkg->{lemma}) {
	$lemma=~s/\'/&pos;/g;
 	$lclemma=lc($lemma);
    }
    if ($tag=$pkg->{tag}) {
	($shorttag)=$tag=~/^([A-Z]+)/;
    }
    my $log=$pkg->{logfile};
    my @query_array=([$token,$lemma,$tag],
		     [$lctoken,$lclemma,$tag],
		     [undef,$lemma,$tag],
		     [undef,$lclemma,$tag],
		     [$token,undef,$tag],
		     [$lctoken,undef,$tag],
		     [$token,$lemma,$shorttag],
		     [$lctoken,$lclemma,$shorttag],
		     [undef,$lemma,$shorttag],
		     [undef,$lclemma,$shorttag],
		     [$token,undef,$shorttag],
		     [$lctoken,undef,$shorttag],
		     [$token,undef,undef],
		     [$lctoken,undef,undef],
		     [undef,$lemma,undef],
		     [undef,$lclemma,undef]
	);
    while ($current=shift(@query_array)) {
	if ($pkg->lookupPictoDictionaryTokLemTag($current)) {
	    return 1;
	}
	#if ($pkg->lookupSynonymResyf($current)) {
	    #return 1;
	#}
    }
    return undef;
}

sub isContentWord {
    my ($pkg,$sentence)=@_;
    # if ($pkg->lookupFilename) {
    #	return 1;
    #  }
    if ($pkg->{tag}=~/^(NOM|NAM|PRP|PRP:det|VER:cond|VER:futu|VER:impe|VER:impf|VER:infi|VER:pper|VER:ppre|VER:pres|VER:simp|VER:subi|VER:subp|ADJ|PRO:DEM|ADV|NUM)/) {
	#!# if ($pkg->{tag}=~/^(NC|PREP|NMEA|NP|VCLIger|VCLIinf|VCLIfin|VEadj|VEfin|VEger|VEinf|VHadj|VHfin|VHger|VHinf|VLadj|VLfin|VLger|VLinf|VMadj|VMfin|VMger|VMinf|VSadj|VSfin|VSger|VSinf|ADJ|DM|ADV|CARD|CSUBX)/) {
	if ($pkg->{lemma} eq 'XXXX') { #|| ($pkg->{lemma} eq 'être')) { #!# if (($pkg->{lemma} eq 'haber') || ($pkg->{lemma} eq 'tener')) {
	    return undef;
	}
	else {
	    return 1;
	}
    }
    else {
	return undef;
    }
}

sub addPictosNotInWordnet {
    my ($pkg)=@_;
    my ($file,$feat,$picto);
    my ($pronoun);
    if (($feat)=$pkg->{tag}=~/(PRO:PER|DET:POS|PRO:POS|ADJ)/) #!# Spanish PPC|PPO|PPX|ADJ
	#!# Spanish (Clitic personal pronoun (le, les)|Possessive pronouns (mi, su, sus)|Clitics and personal pronouns (nos, me, nosotras, te, sí)|Adjectives (mayores, mayor))
{
	$pronoun=$pkg->{token};
	#$file=$pkg->{target}->getPronouns($pronoun); #!#
	if ($file) {
	    my $log=$pkg->{logfile};
	    my $tok=$pkg->{token};
	    print $log "'$tok': $file (not in Cornetto)\n";
	    my $picto=picto->new(file,$file,
				 logfile,$pkg->{logfile},
				 wordnetdb,$pkg->{wordnetdb},
				 target,$pkg->{target});
	    $pkg->pushFeature(picto_single,[$picto]);
	}
	else {
	    return undef;
	}
    }
    else {
	return undef;
    }
}


#---------------------------------------
package picto; #!#
#---------------------------------------

sub getNot { #!#
  return "niet" if ($pkg->{target} ne 'arasaac'); #!#
  return "pas" if ($pkg->{target} eq 'arasaac'); #!#
} #!#
