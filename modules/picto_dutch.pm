####### picto_cornetto.pm ##########

# By Vincent Vandeghinste
# vincent@ccl.kuleuven.be
# Date: 25.11.2013

#---------------------------------------

1;
$VERSION="1.6.1"; # 29.03.2021 put all modules in the module subdir
#$VERSION="1.6"; # 21.01.2019 cleanup
#$VERSION="1.5"; # 04.12.2018 also for rand_dutch
#$VERSION="1.4"; # 26.09.2014 Removed lookup filename in isContentWord
#$VERSION="1.3"; # 28.01.2014 All ref to cornetto replaced by Wordnet
#$VERSION="1.2"; # 20.01.2014 TSW added to content categories
#$VERSION="1.1"; # 26.11.2013 Cardinals/ordinals added to content words
#$VERSION="1.0"; # Taken language dependent subroutines from picto.pm and put them here

print $log "picto_dutch $VERSION loaded\n" if $log;

require "$Bin/modules/".$targetlanguage."_dutch.pm";


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
    if ($pkg->{tag}=~/^(N|VG|VNW|VZ|WW|ADJ|BW|TW|TSW|SPEC\(deeleigen\))/) {
	if ($pkg->{lemma} eq 'al') {
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
    my ($persbez,$person,$number,$gender);
    if (($feat)=$pkg->{tag}=~/VNW\((.+)\)/) {
    	my @feat=split(/,/,$feat);
	if ($feat[0]=~/pers/) {
	    $persbez=$feat[0];
	    $person=$feat[4];
	    $number=$feat[5];
	    $gender=$feat[6];
	}
	elsif ($feat[0]=~/bez/) {
	    $persbez=$feat[0];
	    $person=$feat[4];
	    $number=$feat[5];
	    $gender=$feat[8];
	    if ($gender eq 'agr') {
		if ($pkg->{lemma} eq 'zijn') {
		    $gender='masc';
		}
		elsif ($pkg->{lemma} eq 'haar') {
		    $gender='fem';
		}
	    }
	}
	else {
	    return undef;
	}
	$file=$pkg->{target}->getPronouns($persbez,$person,$number,$gender);
	if ($file) {
	    my $tok=$pkg->{token};
	    my $picto=picto->new(file,$file,
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


#--------------
package picto;
#--------------

sub getNot {
  return "niet";
}
