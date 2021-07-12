####### synset_english.pm ########

# By Leen Sevens and Vincent Vandeghinste
# leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: Spring 2014

#---------------------------------------

$VERSION="1.0"; # 16.09.14 English version based on synset_dutch.pm (VERSION="1.0")

#---------------------------------------

1;

#---------------------------------------
package cornetto;
#---------------------------------------

@ISA=("wordnet");

$database="princeton30new";
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
    # if ($pkg->{tag} =~/^(N|WW|ADJ|TW|BW|VZ\(fin\)|TSW)/) { # Maybe add more pos tags here
    if ($pkg->{tag} =~/^(NN|TO|NNS|NNP|NNPS|VB|VBD|VBG|VBN|VBP|VBZ|JJ|JJR|JJS|RBR|RB|RBS|CD|UH)/){
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
	if ($lupos=~/^VERB/) { # VERB comes from Posspecific in Princeton30 database
	    unless ($pos=~/^(VB|VBD|VBG|VBN|VBP|VBZ)/) {
		splice(@$lexunits,$i,1);
		$i--;
		next;
	    }
	}
	elsif ($lupos=~/^NOUN/) {
	    unless ($pos=~/^(NN|NNS|NNP|NNPS|CD)/) {
		splice(@$lexunits,$i,1);
		$i--;
		next;
	    }
	}
	elsif ($lupos=~/^ADJECTIVE/) {
	    unless ($pos=~/^(JJ|JJR|JJS)/) {
		splice(@$lexunits,$i,1);
		$i--;
		next;
	    }
	}
	elsif ($lupos=~/^ADVERB/) {
	    unless ($pos=~/^(RB|RBR|RBS|JJ|JJR|JJS)/) {
		splice(@$lexunits,$i,1);
		$i--;
		next;
	    }
	}
    }
}
