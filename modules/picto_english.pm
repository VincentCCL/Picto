####### picto_english.pm ##########

# By Leen Sevens and Vincent Vandeghinste
# leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 16.09.2014

#---------------------------------------

1;

$VERSION="1.1"; # 12.07.21 Changed location for modules
#$VERSION="1.0"; # 16.09.14 English version based on picto_dutch.pm (VERSION="1.3")

require "$Bin/modules/sclera_english.pm";
require "$Bin/modules/beta_english.pm";
require "$Bin/modules/imagenet_english.pm";

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
    if ($pkg->{tag}=~/^(NN|TO|NNS|NNP|NNPS|IN|VB|VBD|VBG|VBN|VBP|VBZ|JJ|JJR|JJS|RBR|RB|RBS|CD|UH)/) {
	# if (($pkg->{lemma} eq 'have') || ($pkg->{lemma} eq 'do') ||  ($pkg->{lemma} eq 'let')) {
	#    return undef;
	# }
	# else {
	    return 1;
	# }
    }
    else {
	return undef;
    }
}

sub addPictosNotInWordnet {
    my ($pkg)=@_;
    my ($file,$feat,$picto);
    my ($pronoun);
    if (($feat)=$pkg->{tag}=~/(PRP$|PRP\$|FW$)/) {
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
