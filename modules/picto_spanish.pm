####### picto_spanish.pm ##########

# By Leen Sevens and Vincent Vandeghinste
# leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 16.09.2014

#---------------------------------------

1;

$VERSION="1.0"; # 16.09.14 Spanish version based on picto_dutch.pm (VERSION="1.3")

require "$Bin/modules/sclera_spanish.pm";  # could be made dependent on target language switch
require "$Bin/modules/beta_spanish.pm";
require "$Bin/modules/imagenet_spanish.pm";

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
    }
    return undef;
}
sub isContentWord {
    my ($pkg,$sentence)=@_;
    # if ($pkg->lookupFilename) {
    #	return 1;
    #  }
    if ($pkg->{tag}=~/^(NC|PREP|NMEA|NP|VCLIger|VCLIinf|VCLIfin|VEadj|VEfin|VEger|VEinf|VHadj|VHfin|VHger|VHinf|VLadj|VLfin|VLger|VLinf|VMadj|VMfin|VMger|VMinf|VSadj|VSfin|VSger|VSinf|ADJ|DM|ADV|CARD|CSUBX)/) {
	if (($pkg->{lemma} eq 'haber') || ($pkg->{lemma} eq 'tener')) {
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
    if (($feat)=$pkg->{tag}=~/(PPC|PPO|PPX|ADJ)/) 
{
	$pronoun=$pkg->{token};
	$file=$pkg->{target}->getPronouns($pronoun);
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
