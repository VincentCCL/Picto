########## object.pm ##########

# By Vincent Vandeghinste
# vincent@ccl.kuleuven.be
# Date: 07.10.2013

#---------------------------------------

$VERSION="1.2"; # 09.04.2021 openWordnet added
#$VERSION="1.1.6"; # 29.03.2021 removed use DB_File;
#$VERSION="1.1.5"; # Moved tmpfilelocations to GenericFunctions.pm
#$VERSION="1.1.4"; # Make two tempfilelocations so it is possible to run a Beta-based script and a Sclera-based script at the same time for parameter tuning
#$VERSION="1.1.3"; # 06.02.14 Adaptated logging
#$VERSION="1.1.2"; # 28.01.14 All ref to cornetto replaced by wordnet
#$VERSION="1.1.1"; # 05.12.13 DetectSentences made more robust
#$VERSION="1.1"; # 22.11.13 Source language dependent info is taken out of this module
                 # And transferred to dutch.pm
#$VERSION="1.0.5"; # 08.11.13 sentence::adaptPolarity is adapted: 
                  # Head of negative can now also be adj or bw
                  # PushFeature is made more robust
#$VERSION="1.0.4"; # Cornettodb is passed on in all ->new 
#$VERSION="1.0.3"; # Log methods commented out
#$VERSION="1.0.2"; # Methods made more robust for baseline application
#$VERSION="1.0.1"; # Lemmatization changed for SPEC(deeleigen)
                  # Negatives now also for ADJ heads
#$VERSION="1.0"; # Version used in the first release for WAI-NOT

#---------------------------------------

# Libraries

#use DB_File; 

#---------------------------------------

1;
print $log "object.pm version $VERSION loaded\n" if $log;
#---------------------------------------


#---------------------------------------
package object;
#---------------------------------------

sub new {
    my ($pkg,@featvals)=@_;
    my %hash;
    while ($feat=shift(@featvals)) {
	$val=shift(@featvals);
	$hash{$feat}=$val;
    }
    return bless {%hash},$pkg;
}

sub pushFeature {
    my ($pkg,$feature,$value)=@_;
    if ($value) {
	if (my $oldvalue=$pkg->{$feature}) {
	    push(@$oldvalue,@$value);
	}
	else {
	    $pkg->{$feature}=$value;
	}
    }
}

sub showInLog {
  my ($pkg,$indent,$already)=@_;
  if ($already->{$pkg}) { return undef;}
  $already->{$pkg}=1;
  my $skips={'logfile' =>1,  # these are the features not shown in the logfile
             'wordnetdb' => 1,
             'target' => 1};
  my $maxels=10;
  if (my $log=$pkg->{logfile}) {
    my $ref=ref($pkg);
    print $log "$ref\n";
    foreach (sort keys %$pkg) {
      if ($skips->{$_}) {next;}
      my $value=$pkg->{$_};
      if ($value eq '') { next;}
      print $log &Space($indent)." $_\t";
      if (ref($value) eq 'ARRAY') {
        print $log "ARRAY\n";
        my $elnr=-1;
        foreach my $el (@$value) {
          $elnr++;
          if ($elnr>$maxels) {
            print $log &Space($indent)."...\n";
            last;
          }
          print $log &Space($indent)." Element $elnr: ";
          unless ($el->showInLog($indent+1,$already)) {
            print $log "already shown\n";
          }
        }
      }
      elsif (ref($value) eq '') {
        print $log "$value\n";
      }
      elsif ($value->isa("object")) {
        unless ($value->showInLog($indent+1,$already)) {
         print $log "already shown\n";
        }
      }
    }
  }
  return 1;
}
  
sub Space {
    my ($level)=@_;
    my $distance=2;
    my ($space,$spacedistance);
    for ($i=0;$i<$distance;$i++) {
        $spacedistance.=" ";
    }
    for ($i=0;$i<$level;$i++) {
        $space.=$spacedistance;
    }
    return $space;
}

sub openWordnet {
    my ($pkg)=@_;
    unless ($pkg->{wordnetdb}) {
        my $db=DBI::db->new($main::database,
                            $main::host,
                            $main::port,
                            $main::user,
                            $main::pwd);
        $pkg->{wordnetdb}=$db;
    }
}


#---------------------------------------
package message;
#---------------------------------------

@ISA=("object");

sub addFullStop {
    my ($pkg)=@_;
    if ($pkg->{text}!~/[\.\?\!]$/) {
	$pkg->{text}.=".";
    }
}

sub lemmatize {
    my ($pkg)=@_;
    my $sentences=$pkg->{sentences};
    foreach (@$sentences) {
	$_->lemmatize;
    }
}

sub detectSentences {
    my ($pkg)=@_;
    my $words;
    my $condition=$pkg->{condition};
    unless ($words=$pkg->{words}) { 
	$pkg->tokenize;
	$words=$pkg->{words};
    }
    my (@sentencewords,@sentences);
    for ($i=0;$i<@$words;$i++) {
	push(@sentencewords,$words->[$i]);
	if ($words->[$i]->endOfSentence) {
	    my $sentence=sentence->new(words,[@sentencewords],
				       target,$pkg->{target},
				       wordnetdb,$pkg->{wordnetdb},
				       logfile,$pkg->{logfile});
	    $sentence->addTextField;
	    if ($condition) {
		$sentence->{condition}=$condition;
	    }
	    push(@sentences,$sentence);
	    @sentencewords=();
	}
    }
    if (@sentencewords>0) {
	my $sentence=sentence->new(words,[@sentencewords],
				   target, $pkg->{target},
				   wordnetdb,$pkg->{wordnetdb},
				   logfile,$pkg->{logfile});
	$sentence->addTextField;
	if ($condition) {
	    $sentence->{condition}=$condition;
	}
	push(@sentences,$sentence);
    }
    $pkg->{sentences}=[@sentences];
    delete $pkg->{words};
}

sub tokenize {
    my ($pkg)=@_;
    $_=$pkg->{text};
    my @words;
    s/([\(\),\.\"\?!]+)/ $1 /g;
    my @tokens=split(/\s+/);
    foreach (@tokens) {
    	push(@words,word->new(token,$_,
			      target,$pkg->{target},
			      wordnetdb,$pkg->{wordnetdb},
			      logfile,$pkg->{logfile}));
    }
    $pkg->{words}=[@words];
}

#---------------------------------------
package sentence;
#---------------------------------------

@ISA=('object');

sub lemmatize {
    my ($pkg)=@_;
    my $words=$pkg->{words};
    my ($tok,$lem);
    foreach (@$words) {
	$_->lemmatize;
	$tok=$_->{token};
	$lem=$_->{lemma};
    }
}

sub addTextField {
  my ($pkg)=@_;
  my $words=$pkg->{words};
  my @text;
  if (@$words>0) {
    foreach (@$words) {
      push(@text,$_->{token});
    }
    $pkg->{text}=join(' ',@text);
    return 1;
  }
  return undef;
}

#---------------------------------------------
package word;
#---------------------------------------------

@ISA=('object');

sub findSpellingAlternatives {
    my ($pkg)=@_;
    my $deletions=$pkg->findOneDeletion;
    my $insertions=$pkg->findOneInsertion;
    my $substitutions=$pkg->findOneSubstitution;
    return [@$deletions,@$insertions,@$substitutions];
}

sub endOfSentence {
    my ($pkg)=@_;
    if (($pkg->{tag}) &&
	($pkg->{tag} eq 'LET()') &&
	($pkg->{token}=~/[\.!\?]/)) {
	return 1;
    }	
    elsif ($pkg->{token}=~/[\.!\?]/) {
	return 1;
    }
    else {
	return undef;
    }
}

#---------------------------------------------
package phrase;
#---------------------------------------------

@ISA=('object');

