####### LanguageModeling_cornetto.pm ##########

# By Leen Sevens and Vincent Vandeghinste
# leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 03.11.14

#---------------------------------------

1;

$VERSION="3.0"; # 05.04.2018 Disabled the generation of variants for pronouns and changed database information from trigram to fivegram
#$VERSION="2.0"; # 03.11.2014 All language-independent modules are grouped together in languageModeling.pm, while language-dependent modules are moved to separate files
#$VERSION="0.5"; # The tool deals with multiple lexical units within one synset
#$VERSION="0.4"; # All ref to Cornetto replaced by Wordnet
#$VERSION="0.3"; # Param settings removed
#$VERSION="0.2"; # POS restrictions added
#$version="0.1";

use Encode;

#---------------------------------------
package ngram;
#---------------------------------------

@ISA=("object");

$database{tok}="$main::lmdatabase";
$host="$main::lmhost";
$port="$main::lmport";
$user="$main::lmuser";
$pwd="$main::lmpwd";

#---------------------------------------
package word;
#---------------------------------------

sub isNoun {
    my ($pkg)=@_;
    my $tags=$pkg->{tag};
    my $lemma=$pkg->{lemma};
    if (($lemma eq "mij") || ($lemma eq "ik") || ($lemma eq "mijn") || ($lemma eq "jij") || ($lemma eq "je") || ($lemma eq "jou") || ($lemma eq "jouw") || ($lemma eq "hij") || ($lemma eq "zij") || ($lemma eq "ze") || ($lemma eq "hem") || ($lemma eq "wij") || ($lemma eq "we") || ($lemma eq "ons") || ($lemma eq "jullie")  || ($lemma eq "hallo")){
	return 0;
    }
    else{           
    foreach (@$tags) {
	if (/^N.soort/) {
	    return 1;
	}
    }
    }
}

sub isNeuter {
    my ($pkg)=@_;
    my $tags=$pkg->{tag};
    foreach (@$tags) {
	if (/onz/) {
	    return 1;
	}
    }
}

sub isNonNeuter {
    my ($pkg)=@_;
    my $tags=$pkg->{tag};
    foreach (@$tags) {
	if (/zijd/) {
	    return 1;
	}
    }
}

sub isPlural {
    my ($pkg)=@_;
    my $tags=$pkg->{tag};
    foreach (@$tags) {
	if (/mv/) {
	    return 1;
	}
    }
}

sub getArticles {
    my ($pkg)=@_;
    my @art;
    my $condition=$pkg->{condition};
    if ($pkg->isNeuter) {
	push(@art,word->new(target,$pkg->{target},
			    wordnetdb,$pkg->{wordnetdb},
			    logfile,$pkg->{logfile},
			    token,'het',
			    token,'het',
			    tag,['LID(bep,stan,evon)']
	     ));
	push(@art,word->new(target,$pkg->{target},
			    wordnetdb,$pkg->{wordnetdb},
			    logfile,$pkg->{logfile},
			    token,'een',
			    token,'een',
			    tag,['LID(onbep,stan,agr)']
	     ));
    }
    elsif ($pkg->isNonNeuter) {
	push(@art,word->new(target,$pkg->{target},
			    wordnetdb,$pkg->{wordnetdb},
			    logfile,$pkg->{logfile},
			    token,'de',
			    token,'de',
			    tag,['LID(bep,stan,rest)']
	     ));
	push(@art,word->new(target,$pkg->{target},
			    wordnetdb,$pkg->{wordnetdb},
			    logfile,$pkg->{logfile},
			    token,'een',
			    token,'een',
			    tag,['LID(onbep,stan,agr)']
	     ));
    }
    elsif ($pkg->isPlural) {
	push(@art,word->new(target,$pkg->{target},
			    wordnetdb,$pkg->{wordnetdb},
			    logfile,$pkg->{logfile},
			    token,'de',
			    token,'de',
			    tag,['LID(bep,stan,rest)']
	     ));
    }
    if ($condition) {
	foreach (@art) {
	    $_->{condition}=$condition;
	}
    }
    return [@art];
}
    
sub FilterPos { 
    my ($pos,@values)=@_;
    my @newvalues=();
    foreach (@values) {
	if ($pos eq 'ADVERB') {
	    if (/BW|ADJ\(vrij/) {
		push(@newvalues,$_);
	    }
	}
	elsif (($pos eq 'NOUN_MASCULINE') ||
	       ($pos eq 'NOUN_DE') ||
	       ($pos eq 'NOUN_FEMININE')) {
	    if (/N\(soort,ev,basis,zijd|N\(soort,mv|ADJ\(nom/) {
		push(@newvalues,$_);
	    }
	}
	elsif ($pos=~/NOUN_HET/) {
	    if (/N\(soort,ev,basis,onz|N\(soort,mv|ADJ\(nom|WW\(nom/) {
		push(@newvalues,$_);
	    }
	}
	elsif ($pos=~/NOUN_PLURAL/) {
	    if (/N\(soort,mv/) {
		push(@newvalues,$_);
	    }
	}
	elsif ($pos=~/^VERB/) {
	    if (/WW/) {
		push(@newvalues,$_);
	    }
	}
	elsif ($pos=~/ADJECTIVE/) {
	    if (/ADJ/) {
		push(@newvalues,$_);
	    }
	}
    }
    return @newvalues;
}
	
#---------------------------------------
package sentencePath;
#---------------------------------------

@ISA=("object");

sub printOutput {
    my ($pkg)=@_;
    my $words=$pkg->{processed};
    my $sentence=join(" ",@$words);
    print "$sentence\n";
}
		
#---------------------------------------
package picto;
#---------------------------------------
		
sub checkInOverrule {
  my ($pkg)=@_;
  my (@alternatives,$lem);
  if ($pkg->{target} eq 'sclera') {
      my $lem=$pkg->{file};
      if ($lem eq 'hallo-zeggen-2.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'hallo',
		  condition,$pkg->{condition});
	return @alternatives;
       }
  }
  elsif ($pkg->{target} eq 'beta') {
      my $lem=$pkg->{file};
      if ($lem eq 'goeiendag.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'hallo',
		  condition,$pkg->{condition});
	return @alternatives;
       }
  }
  return ();
}

sub checkInPronouns {
  my ($pkg)=@_;
  my (@alternatives,$lem);
  if ($pkg->{target} eq 'beta') {
      my $lem=$pkg->{file};
      if ($lem eq 'ik.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'ik',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'mijn.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'mijn',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'mij',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'wij.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'wij',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'we',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'ons.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'ons',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'onze',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'jij.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'jij',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'je',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'jouw.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'jouw',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'je',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'jou',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'jullie_vnw.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'jullie',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'jullie_bvnw.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'jullie',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'hij.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'hij',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'zijn_bvnw.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'zijn',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'hem',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'zij_enkelv.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'zij',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'ze',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'haar_bvnw.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'haar',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'zij_meerv.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'zij',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'ze',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'hun.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'hun',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'hen',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
  }   
elsif ($pkg->{target} eq 'sclera') {
      my $lem=$pkg->{file};
      if ($lem eq 'ik.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'ik',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'mijn-2.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'mijn',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'mij',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'wij.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'wij',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'we',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'ons.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'ons',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'onze',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'jij.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'jij',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'je',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'jouw.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'jouw',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'je',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'jou',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'jullie.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'jullie',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'jullie-3.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'jullie',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'hij.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'hij',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'zijn.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'zijn',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'hem',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'zij.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'zij',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'ze',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'haar-2.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'haar',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'zij-2.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'zij',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'ze',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
      if ($lem eq 'jullie-3.png'){
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'hun',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	$wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  token,'hen',
		  condition,$pkg->{condition});
	push(@alternatives,[$wo]);
	return @alternatives;
}
}
  return ();
}
