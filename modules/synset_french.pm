####### synset_french.pm ########

# By Magali Norré, Leen Sevens and Vincent Vandeghinste
# magali.norre@uclouvain.be, leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 01/02/2021

#---------------------------------------

$VERSION="1.0"; # 01.12.20 French version based on synset_spanish.pm / synset_dutch.pm (VERSION="1.0") /synset_english.pm

#---------------------------------------

1;

#---------------------------------------
package cornetto;
#---------------------------------------

@ISA=("wordnet");

$database="fre30"; #!# spa30 / wonef30cfp
$host="gobelijn";
$port="5432";
$user="vincent";
$pwd="vincent";

#---------------------------------------
package object;
#---------------------------------------

# ->openWordnet # Used to be openCornetto

sub openWordnet {
    my ($pkg)=@_;
    unless ($pkg->{wordnetdb}) {
	my $db=DBI::db->new($cornetto::database,
			    $cornetto::host,
			    $cornetto::port,
			    $cornetto::user,
			    $cornetto::pwd);
	$pkg->{wordnetdb}=$db;
    }
}

#---------------------------------------
package word;
#---------------------------------------

sub addWordnet {
    my ($pkg)=@_;
    my $tok=$pkg->{token};
    my $log=$pkg->{logfile};
    # if ($pkg->{tag} =~/^(NN|NNS|NNP|NNPS|VB|VBD|VBG|VBN|VBP|VBZ|JJ|JJR|JJS|RBR|RB|RBS|CD)/){
    if ($pkg->{tag} =~/^(NOM|NAM|VER:cond|VER:futu|VER:impe|VER:impf|VER:infi|VER:pper|VER:ppre|VER:pres|VER:simp|VER:subi|VER:subp|ADJ|PRO:DEM|ADV|NUM)/){ #!# Spanish NC|NMEA|NP|VCLIger|VCLIinf|VCLIfin|VEadj|VEfin|VEger|VEinf|VHadj|VHfin|VHger|VHinf|VLadj|VLfin|VLger|VLinf|VMadj|VMfin|VMger|VMinf|VSadj|VSfin|VSger|VSinf|ADJ|DM|ADV|CARD|CSUBX
	$pkg->addLexUnits;
	$pkg->addSynsets;
	$pkg->filterLexUnitsAccordingToPos;
    }
    else {
	print $log "\tNo Wordnet info for $tok\n";
    }
    print $log "\t--------------\n";
}


sub filterLexUnitsAccordingToPos {
    my ($pkg)=@_;
    my $pos=$pkg->{tag};
    my $lexunits=$pkg->{lexunits};
    my $lupos;
    for ($i=0;$i<@$lexunits;$i++) {
	$lupos=$lexunits->[$i]->{synset}->{pos};
	if ($lupos=~/^VERB/) { # VERB comes from Posspecific in fre30 database
	    unless ($pos=~/^(VER:cond|VER:futu|VER:impe|VER:impf|VER:infi|VER:pper|VER:ppre|VER:pres|VER:simp|VER:subi|VER:subp)/) { #!# Spanish VCLIger|VCLIinf|VCLIfin|VEadj|VEfin|VEger|VEinf|VHadj|VHfin|VHger|VHinf|VLadj|VLfin|VLger|VLinf|VMadj|VMfin|VMger|VMinf|VSadj|VSfin|VSger|VSinf
		splice(@$lexunits,$i,1);
		$i--;
		next;
	    }
	}
	elsif ($lupos=~/^NOUN/) {
	    unless ($pos=~/^(NOM|NAM)/) { #!# Spanish NC|NMEA|NP
		splice(@$lexunits,$i,1);
		$i--;
		next;
	    }
	}
	elsif ($lupos=~/^ADJECTIVE/) {
	    unless ($pos=~/^(ADJ|PRO:DEM)/) { #!# Spanish ADJ|DM
		splice(@$lexunits,$i,1);
		$i--;
		next;
	    }
	}
	elsif ($lupos=~/^ADVERB/) {
	    unless ($pos=~/^(ADJ|ADV|PRO:DEM)/) { #!# Spanish ADJ|ADV|DM
		splice(@$lexunits,$i,1);
		$i--;
		next;
	    }
	}
    }
}
