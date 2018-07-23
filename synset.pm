####### synset.pm ##########

# By Vincent Vandeghinste
# vincent@ccl.kuleuven.be
# Date: 07.10.2013

#---------------------------------------

$VERSION="1.3.5"; # 19.11.14 Add frequency information of tokens that could have multiple senses to lexunit and synset
#$VERSION="1.3.4"; # 29.09.14 Allow for multiple lemma's to be retrieved in AddLemmas
#$VERSION="1.3.3"; # 11.02.14 Bug fix in word::addLexUnits
#$VERSION="1.3.2"; # 06.02.14 word::addLexUnit now also works without lemmas
#$VERSION="1.3.1"; # 30.01.14 AddAntonyms and AddXPosNearSynonym are now symmetrical
#$VERSION="1.3"; # 28.01.14 All language dependence is removed from this file
#$VERSION="1.2"; # 23.01.14 Adapted for NearAntonyms
#$VERSION="1.1.1"; # 20.01.14 TSW added to Cornetto entries
#$VERSION="1.1"; # 26.11.13 TW added to Cornetto entries
#$VERSION="1.0.5"; # 22.11.13 More robust word::addSynsets
#$VERSION="1.0.4"; # 19.11.13 Bug fix in filterLexUnitsAccordingToPos
#$VERSION="1.0.3"; # 08.11.13 More robust word::filterLexUnitsAccordingToPos
#$VERSION="1.0.2"; # Bug fix in synset::addHyponyms, addition of synset::getLemmas and lexunit::getLemma
#$VERSION="1.0.1"; # word::getSynsets added
#$VERSION="1.0"; # Version used in the first release for WAI-NOT

#---------------------------------------------

1;

#---------------------------------------
package wordnet;
#---------------------------------------

@ISA=("object");

#---------------------------------------
package message;
#---------------------------------------

sub addSynsets {
    my ($pkg)=@_;
    $pkg->openWordnet;
    my $sentences=$pkg->{sentences};
    foreach (@$sentences) {
	$_->{wordnetdb}=$pkg->{wordnetdb};
	$_->addSynsets;
    }
}

#---------------------------------------
package sentence;
#---------------------------------------

sub addSynsets {
    my ($pkg)=@_;
    $pkg->openWordnet;
    my $words=$pkg->{words};
    foreach (@$words) {
	$_->{wordnetdb}=$pkg->{wordnetdb};
	$_->addWordnet;
    }
}

#-------------------------------
package word;
#-------------------------------

sub addSynsets {
    my ($pkg)=@_;
    my $lexunits=$pkg->{lexunits};
    unless ($lexunits) {
	if ($pkg->addLexUnits) {
	    $lexunits=$pkg->{lexunits};
	}
	else {
	    return undef;
	}
    }
    my $db=$pkg->{wordnetdb};
    for (my $i=0;$i<@$lexunits;$i++) {
	$lexunits->[$i]->{wordnetdb}=$db;
	unless ($lexunits->[$i]->addSynset) {
	    splice (@$lexunits,$i,1);
	    $i--;
	}
    }
}

sub addLexUnits {
    my ($pkg)=@_;
    my $lemma;
    unless ($lemma=$pkg->{lemma}) {
	$lemma=$pkg->{token};
    }
    $lemma=~s/'/\\\'/g; 
    my $sql="select id,wsdfreq from lexunits where lemma='$lemma' and disable is null;";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    my @lexunits;
    foreach (@$results) {
	$lexunit=lexunit->new(lemma,$lemma,
			      id,$_->[0],
			      freq,$_->[1],
			      wordnetdb,$pkg->{wordnetdb},
			      target,$pkg->{target});
	push(@lexunits,$lexunit);
    }
    if (@lexunits>0) {
	$pkg->{lexunits}=[@lexunits];
    }
    else {
	return undef;
    }
}

sub getSynsets {
    my ($pkg)=@_;
    my $lus=$pkg->{lexunits};
    my @synsets;
    foreach (@$lus) {
	push(@synsets,$_->{synset});
    }
    return @synsets;
}

#---------------------------------------
package lexunit;
#---------------------------------------

@ISA=("object");

sub addSynset { 
    my ($pkg)=@_;
    my $id=$pkg->{id};
    my $sql="select synset from lex2syn where lexunit='$id';";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    if ($results->[0]->[0]) {
	my $synset=synset->new(synset,$results->[0]->[0],
		               freq,$pkg->{freq},
			       wordnetdb,$pkg->{wordnetdb},
			       target,$pkg->{target});
	$pkg->{synset}=$synset;
	$synset->addPos;
	return 1;
    }
    else {
	return undef;
    }
}

sub addLemma { 
    my ($pkg)=@_;
    my $id=$pkg->{id};
    my @lexunits=();
    my $sql="select lemma from lexunits where id='$id' and disable is null;";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    foreach (@$results) {
	$lexunit=lexunit->new(lemma,$_->[0],
			      id,$pkg->{id},
			      wordnetdb,$pkg->{wordnetdb},
			      target,$pkg->{target});
	push(@lexunits,$lexunit);
    }
    if (@lexunits>0) {
	$pkg->{lexunits}=[@lexunits];
    }
    else {
	next;
    }
}

sub getLemma {
    my ($pkg)=@_;
    if ($lemma=$pkg->{lemma}) {
	return $lemma;
    }
    else {
	return $pkg->addLemma;
    }
}
#---------------------------------------
package synset;
#---------------------------------------

@ISA=("object");

sub addLemmas {
    my ($pkg)=@_;
    my ($lexunits);
    my @lemmas;
    unless ($lexunits=$pkg->{lexunits}) {
	$pkg->addLexUnits;
	$lexunits=$pkg->{lexunits};
    } 
    foreach (@$lexunits) {
	push(@lemmas,$_->addLemma);
    }
    return @lemmas;
}

sub addPos {
    my ($pkg)=@_;
    my $db=$pkg->{wordnetdb};
    my $synsetid=$pkg->{synset};
    my $sql="select pos from posspecific where synset='$synsetid';";
    my $results=$db->lookup($sql);
    $pkg->{pos}=$results->[0]->[0];
}

sub addLexUnits {
    my ($pkg)=@_;
    my $sql="select lexunit from lex2syn where synset='$pkg->{synset}';";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    my @lexunits;
    foreach (@$results) {
	$lexunit=lexunit->new(id,$_->[0],
			      wordnetdb,$pkg->{wordnetdb},
			      target,$pkg->{target});
	push(@lexunits,$lexunit);
    }
    if (@lexunits>0) {
	$pkg->{lexunits}=[@lexunits];
    }
    else {
	return undef;
    }
}

sub addXPosNearSynonyms {
    my ($pkg)=@_;
    my $sql="select target from relations where synset='$pkg->{synset}' and relation='XPOS_NEAR_SYNONYM';";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    my $sql="select synset from relations where target='$pkg->{synset}' and relation='XPOS_NEAR_SYNONYM';";
    my $res2=$pkg->{wordnetdb}->lookup($sql);
    push(@$results,@$res2);
    my (@relations,$calling_synset_id);
    if (my $calling_synset_object=$pkg->{calling_xpos}) {
	$calling_synset_id=$calling_synset_object->{synset};
    }
    my $xposalready;
    foreach (@$results) {
	if ($xposalready{$_->[0]}) { 
	    next;
	}
	else {
	    $xposalready{$_->[0]}=1;
	}
	unless ($_->[0] eq $calling_synset_id) {
	    my $synset=synset->new(synset,$_->[0],
				   wordnetdb,$pkg->{wordnetdb},
				   calling_xpos,$pkg,
				   target,$pkg->{target});
	    push(@relations,$synset);
	}
    }
    if (@relations>0) {
	$pkg->{xposnearsynonyms}=[@relations];
    }
    else {
	return undef;
    }	
}

sub addHyperonyms {
    my ($pkg)=@_;
    my $sql="select target from relations where synset='$pkg->{synset}' and relation='HAS_HYPERONYM';";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    my @relations;
    foreach (@$results) {
	my $synset=synset->new(synset,$_->[0],
			       wordnetdb,$pkg->{wordnetdb},
			       target,$pkg->{target});
	push(@relations,$synset);
    }
    if (@relations>0) {
	$pkg->{hyperonyms}=[@relations];
    }
    else {
	return undef;
    }
}

sub addAntonyms {
    my ($pkg)=@_;
    my $sql="select target from relations where synset='$pkg->{synset}' and relation='NEAR_ANTONYM';";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    my $sql="select synset from relations where target='$pkg->{synset}' and relation='NEAR_ANTONYM';";
    my $res2=$pkg->{wordnetdb}->lookup($sql);
    push(@$results,@$res2);
    my (@relations,$calling_synset_id);
    if (my $calling_synset_object=$pkg->{calling_antonym}) {
	$calling_synset_id=$calling_synset_object->{synset};
    }
    my %antoalready;
    foreach (@$results) {
	if ($antoalready{$_->[0]}) { 
	    next;
	}
	else {
	    $antoalready{$_->[0]}=1;
	}
	unless ($_->[0] eq $calling_synset_id) {
	    my $synset=synset->new(synset,$_->[0],
				   wordnetdb,$pkg->{wordnetdb},
				   calling_antonym,$pkg,
				   target,$pkg->{target});
	    push(@relations,$synset);
	}
    }
    if (@relations>0) {
	$pkg->{antonyms}=[@relations];
    }
    else {
	return undef;
    }
}

sub addHyponyms {
    my ($pkg)=@_;
    my $sql="select synset from relations where target='$pkg->{synset}' and relation='HAS_HYPERONYM';";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    my @relations;
    foreach (@$results) {
	push(@relations,synset->new(synset,$_->[0],
				    wordnetdb,$pkg->{wordnetdb},
				    target,$pkg->{target}));
    }
    if (@relations>0) {
	$pkg->{hyponyms}=[@relations];
    }
    else {
	return undef;
    }
}

sub getLemmas {
    my ($pkg)=@_;
    my $lexunits=$pkg->{lexunits};
    my @lemmas=();
    foreach (@$lexunits) {
	push(@lemmas,$_->getLemma);
    }
    return @lemmas;
}
