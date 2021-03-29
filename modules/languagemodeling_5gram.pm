####### languagemodeling_5gram.pm ##########

# By Leen Sevens and Vincent Vandeghinste
# leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 03.11.14

#---------------------------------------

1;

$VERSION="3.0"; # 05.04.2018 Implementation of 5-gram decoder
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

sub estimateProb {
    my ($pkg)=@_;
    my $words=$pkg->{words};
    my $string=join(" ",@$words);
    my ($windowposition,$ngram,$logprob);
    unless ($logprob=$NGRAMCACHE{$string}) {
	if (@$words==1) {
	    $ngram=unigram->new(words,$words,
				ngramdb,$pkg->{ngramdb});
	    $ngram->estimateProb;
	    $logprob=$ngram->{logprob};
	}
	elsif (@$words==2) {
	    $ngram=bigram->new(words,$words,
			       ngramdb,$pkg->{ngramdb});
	    $ngram->estimateProb;
	    $logprob=$ngram->{logprob};
	}
	elsif (@$words==3) {
		 $ngram=trigram->new(words,$words,
			       ngramdb,$pkg->{ngramdb});
		$ngram->estimateProb;
		$logprob+=$ngram->{logprob};
	    $ngram->{logprob}=$logprob;
	}
	elsif (@$words==4) {
		 $ngram=fourgram->new(words,$words,
			       ngramdb,$pkg->{ngramdb});
		$ngram->estimateProb;
		$logprob+=$ngram->{logprob};
	    $ngram->{logprob}=$logprob;
	}
	else { 
	    for ($windowposition=0;$windowposition<@$words-4;$windowposition++) {
		$ngram=fivegram->new(words,[@$words[$windowposition..$windowposition+4]],
				    ngramdb,$pkg->{ngramdb});
		$ngram->estimateProb;
		$logprob+=$ngram->{logprob};
	    }
	    $ngram->{logprob}=$logprob;
	}
	$NGRAMCACHE{$string}=$logprob;
    }
    $pkg->{logprob}=$logprob;
}

#---------------------------------------
package object;
#---------------------------------------

sub openNGramDatabase {
    my ($pkg)=@_;
    unless ($pkg->{ngramdb}) {
	my $db=DBI::db->new($ngram::database{$pkg->{condition}},
			    $ngram::host,
			    $ngram::port,
			    $ngram::user,
			    $ngram::pwd);
	$pkg->{ngramdb}=$db;
    }
}

#--------------------------------------- 
package fivegram;
#---------------------------------------

@ISA=("ngram");

sub estimateProb {
    my ($pkg)=@_;
    my $fivegram=join(" ",@{$pkg->{words}});
    $fivegram=~s/\'/&apos;/g;
    unless ($logprob=$FIVEGRAMCACHE{$fivegram}) {
	my $sql="select * from fivegram where ngram='$fivegram';";
	my $results=$pkg->{ngramdb}->lookup($sql);
	if (@$results>0) {
	    # Pk(r|x,y,z,q)=P*(r|x,y,z,q) if C(x,y,z,q,r)>0
	    $pkg->{logprob}=$results->[0]->[0];
	}

	else{

 			my $xyzq=fourgram->new(words,[@{$pkg->{words}}[0..3]],
				       ngramdb,$pkg->{ngramdb});
		        $xyzq->getAlfa;
		        if ($xyzq->{alfa}<0) {
         		    # Pk(r|x,y,z,q)=alfa(x,y,z,q) Pk(r|y,z,q) if C(x,y,z,q)>0
			    my $yzqr=fourgram->new(words,[@{$pkg->{words}}[1..4]],
					   ngramdb,$pkg->{ngramdb});
			    $yzqr->estimateProb;
			    $pkg->{logprob}=$xyzq->{alfa}+$yzqr->{logprob};
		        }	
		else{
		        my $yzq=trigram->new(words,[@{$pkg->{words}}[1..3]],
				       ngramdb,$pkg->{ngramdb});
		        $yzq->getAlfa;
		        if ($yzq->{alfa}<0) {
			    # Pk(r|x,y,z,q)=alfa(y,z,q) Pk(r|z,q) if C(y,z,q)>0
			    my $zqr=trigram->new(words,[@{$pkg->{words}}[2..4]],
					   ngramdb,$pkg->{ngramdb});
			    $zqr->estimateProb;
			    $pkg->{logprob}=$yzq->{alfa}+$zqr->{logprob};
		        }		 
			else {
			    my $zq=bigram->new(words,[@{$pkg->{words}}[2..3]],
					       ngramdb,$pkg->{ngramdb});
			    $zq->getAlfa;
			    if ($zq->{alfa}<0) {
				# Pk(r|x,y,z,q)=alfa(z,q) Pk(r|q) if C(z,q)>0
				my $qr=bigram->new(words,[@{$pkg->{words}}[3..4]],
						   ngramdb,$pkg->{ngramdb});
				$qr->estimateProb;
				$pkg->{logprob}=$zq->{alfa}+$qr->{logprob};
			    }
			    else {
				# Pk(r|x,y,z,q)=P*(r) 
				my $r=unigram->new(words,[$pkg->{words}->[4]],
						   ngramdb,$pkg->{ngramdb});
				$r->estimateProb;
				$pkg->{logprob}=$r->{logprob};
			    }
			    
			}
		}
	}
	$FIVEGRAMCACHE{$fivegram}=$pkg->{logprob};
    }
    else {
	$pkg->{logprob}=$logprob;
    }
    $pkg->{prob}=10**$pkg->{logprob};
}


#--------------------------------------- 
package fourgram;
#---------------------------------------

@ISA=("ngram");

sub estimateProb {
    my ($pkg)=@_;
    my $fourgram=join(" ",@{$pkg->{words}});
    $fourgram=~s/\'/&apos;/g;
    unless ($logprob=$FOURGRAMCACHE{$fourgram}) {
	my $sql="select * from fourgram where ngram='$fourgram';";
	my $results=$pkg->{ngramdb}->lookup($sql);
	if (@$results>0) {
	    # Pk(q|x,y,z)=P*(q|x,y,z) if C(x,y,z,q)>0
	    $pkg->{logprob}=$results->[0]->[0];
	}

	else{
          # Pk(q|x,y,z)=alfa(x,y,z) Pk(q|y,z) if C(x,y,z)>0
	  my $xyz=trigram->new(words,[@{$pkg->{words}}[0..2]],
			       ngramdb,$pkg->{ngramdb});
	  $xyz->getAlfa;
          if ($xyz->{alfa}<0) {
	    my $yzq=trigram->new(words,[@{$pkg->{words}}[1..3]],
    			         ngramdb,$pkg->{ngramdb});
	    $yzq->estimateProb;
	    $pkg->{logprob}=$xyz->{alfa}+$yzq->{logprob};
        }		 
	else {
       	# Pk(q|x,y,z)=alfa(y,z) Pk(q|z) if C(y,z)>0
	    my $yz=bigram->new(words,[@{$pkg->{words}}[1..2]],
			       ngramdb,$pkg->{ngramdb});
	    $yz->getAlfa;
	    if ($yz->{alfa}<0) {
		my $zq=bigram->new(words,[@{$pkg->{words}}[2..3]],
				   ngramdb,$pkg->{ngramdb});
		$zq->estimateProb;
		$pkg->{logprob}=$yz->{alfa}+$zq->{logprob};
	    }
	    else {
		# Pk(q|x,y,z)=P*(q) 
		my $q=unigram->new(words,[$pkg->{words}->[3]],
				   ngramdb,$pkg->{ngramdb});
		$q->estimateProb;
		$pkg->{logprob}=$q->{logprob};
	    }
	}

	}
	$FOURGRAMCACHE{$fourgram}=$pkg->{logprob};
    }
    else {
	$pkg->{logprob}=$logprob;
    }
    $pkg->{prob}=10**$pkg->{logprob};
}

sub getAlfa {
    my ($pkg)=@_;
    my $fourgram=join(" ",@{$pkg->{words}});
    $fourgram=~s/\'/&apos;/g;
    if ($alfa=$FOURGRAMALFACACHE{$fourgram}) {
	$pkg->{alfa}=$alfa;
    }
    else {
	my $sql="select * from fourgram where ngram='$fourgram';";
	my $results=$pkg->{ngramdb}->lookup($sql);
	if (@$results>0) {
	    $pkg->{alfa}=$results->[0]->[2];
	}
	$FOURGRAMALFACACHE{$fourgram}=$pkg->{alfa};
    }
}    
 
#--------------------------------------- 
package trigram;
#---------------------------------------

@ISA=("ngram");

sub estimateProb {
    my ($pkg)=@_;
    my $trigram=join(" ",@{$pkg->{words}});
    $trigram=~s/\'/&apos;/g;
    unless ($logprob=$TRIGRAMCACHE{$trigram}) {
	my $sql="select * from trigram where ngram='$trigram';";
	my $results=$pkg->{ngramdb}->lookup($sql);
	if (@$results>0) {
	    # Pk(z|x,y)=P*(z|x,y) if C(x,y,z)>0
	    $pkg->{logprob}=$results->[0]->[0];
	}
	else {
	    my $xy=bigram->new(words,[@{$pkg->{words}}[0..1]],
			       ngramdb,$pkg->{ngramdb});
	    $xy->getAlfa;
	    if ($xy->{alfa}<0) {
		# Pk(z|x,y)=alfa(x,y) Pk(z|y) if C(x,y)>0
		my $yz=bigram->new(words,[@{$pkg->{words}}[1..2]],
				   ngramdb,$pkg->{ngramdb});
		$yz->estimateProb;
		$pkg->{logprob}=$xy->{alfa}+$yz->{logprob};
	    }
	    else {
		# Pk(z|x,y)=P*(z) if C(x,y)=0
		my $z=unigram->new(words,[$pkg->{words}->[2]],
				   ngramdb,$pkg->{ngramdb});
		$z->estimateProb;
		$pkg->{logprob}=$z->{logprob};
	    }
	    
	}
	$TRIGRAMCACHE{$trigram}=$pkg->{logprob};
    }
    else {
	$pkg->{logprob}=$logprob;
    }
    $pkg->{prob}=10**$pkg->{logprob};
}
    
sub getAlfa {
    my ($pkg)=@_;
    my $trigram=join(" ",@{$pkg->{words}});
    $trigram=~s/\'/&apos;/g;
    if ($alfa=$TRIGRAMALFACACHE{$trigram}) {
	$pkg->{alfa}=$alfa;
    }
    else {
	my $sql="select * from trigram where ngram='$trigram';";
	my $results=$pkg->{ngramdb}->lookup($sql);
	if (@$results>0) {
	    $pkg->{alfa}=$results->[0]->[2];
	}
	$TRIGRAMALFACACHE{$bigram}=$pkg->{alfa};
    }
}

 
#---------------------------------------
package bigram;
#---------------------------------------

@ISA=("ngram");

sub estimateProb {
    my ($pkg)=@_;
    my $bigram=join(" ",@{$pkg->{words}});
    $bigram=~s/\'/&apos;/g;
    if ($logprob=$BIGRAMCACHE{$bigram}) {
	$pkg->{logprob}=$logprob;
    }
    else {
	my $sql="select * from bigram where ngram='$bigram';";
	my $results=$pkg->{ngramdb}->lookup($sql);
	if (@$results>0) {
	    # Pk(y|x) = P*(y|x) if C(x,y)>0 
	    $pkg->{logprob}=$results->[0]->[0];
	    $pkg->{prob}=10**$pkg->{logprob};
	}
	else {
	    # Pk(y|x) = alfa(x) P*(y) if C(x,y)=0
	    my $x=unigram->new(words,[$pkg->{words}->[0]],
			       ngramdb,$pkg->{ngramdb});
	    $x->getAlfa;
	    my $y=unigram->new(words,[$pkg->{words}->[1]],
			       ngramdb,$pkg->{ngramdb});
	    $y->estimateProb;
	    $pkg->{logprob}=$x->{alfa}+$y->{logprob};
	    $pkg->{prob}=10**($pkg->{logprob});
	}
	$BIGRAMCACHE{$bigram}=$pkg->{logprob};
    }
}

sub getAlfa {
    my ($pkg)=@_;
    my $bigram=join(" ",@{$pkg->{words}});
    $bigram=~s/\'/&apos;/g;
    if ($alfa=$BIGRAMALFACACHE{$bigram}) {
	$pkg->{alfa}=$alfa;
    }
    else {
	my $sql="select * from bigram where ngram='$bigram';";
	my $results=$pkg->{ngramdb}->lookup($sql);
	if (@$results>0) {
	    $pkg->{alfa}=$results->[0]->[2];
	}
	$BIGRAMALFACACHE{$bigram}=$pkg->{alfa};
    }
}

#---------------------------------------
package unigram;
#---------------------------------------

@ISA=("ngram");

sub getAlfa {
    my ($pkg)=@_;
    my $unigram=$pkg->{words}->[0];
    $unigram=~s/\'/&apos;/g;
    if ($alfa=$UNIGRAMALFACACHE{$unigram}) {
	$pkg->{alfa}=$alfa;
    }
    else {
	my $sql="select * from unigram where ngram='$unigram';";
	my $results=$pkg->{ngramdb}->lookup($sql);
	if (@$results>0) {
	    $pkg->{alfa}=$results->[0]->[2];
	}
	else{
		my $sql="select * from unigram where ngram='An';";
		my $results=$pkg->{ngramdb}->lookup($sql);
		if (@$results>0) {
		    $pkg->{alfa}=$results->[0]->[2];
		}
	}
	$UNIGRAMALFACACHE{$unigram}=$pkg->{alfa};
    }
}

sub estimateProb {
    my ($pkg)=@_;
    my $unigram=$pkg->{words}->[0];
    $unigram=~s/\'/&apos;/g;
    if ($logprob=$UNIGRAMCACHE{$unigram}) {
	$pkg->{logprob}=$logprob;
    }
    else {
	if ($unigram eq '<s>') {
	    $pkg->{logprob}=0;
	    $pkg->{prob}=1;
	}
	else {
	    my $sql="select * from unigram where ngram='$unigram';";
	    my $results=$pkg->{ngramdb}->lookup($sql);
	    if (@$results>0) {
		# Pk(x)= P*(x)
		$pkg->{logprob}=$results->[0]->[0];
	    }
	    else {
		    my $sql="select * from unigram where ngram='An';";
		    my $results=$pkg->{ngramdb}->lookup($sql);
		    if (@$results>0) {
			# Pk(x)= P*(x)
			$pkg->{logprob}=$results->[0]->[0];
		    }
	    }
	    $pkg->{prob}=10**($pkg->{logprob});
	}
	$UNIGRAMCACHE{$unigram}=$pkg->{logprob};
    }
}

#---------------------------------------
package word;
#---------------------------------------

sub getAlternativeWordObjects {
    my ($pkg,$pos)=@_;
    unless ($pkg->{lemma}) {
	$pkg->{lemma}=$pkg->{token};
    }
    return $pkg->getParadigm($pos);
}

sub getParadigm {
    my ($pkg,$wordnetpos)=@_;
    my $condition=$pkg->{condition};
    my $origtoken=$pkg->{token};
    my $values=$main::REVLEMMAS{$pkg->{lemma}};
    my $token;
    $values = Encode::decode("iso-8859-1", $values);
    my @values=split(/\t/,$values);
    if ($wordnetpos) {
	@values=&FilterPos($wordnetpos,@values);
    }
    my ($vtok,$vtag,$tag,$alt,@alternatives,%ParadigmCache);
    foreach (@values) {
	($token,$tag)=split(/\|/);
	$alt=word->new(target,$pkg->{target},
		       wordnetdb,$pkg->{wordnetdb},
		       logfile,$pkg->{logfile},
		       lemma,$pkg->{lemma},
		       token,$token,
		       tag,[$tag],
		       condition,$condition);
	push(@alternatives,[$alt]);
    }
    unless (@alternatives) {
	$pkg->{token}=$pkg->{lemma};
	$pkg->{unknown}=1;
	push(@alternatives,[$pkg]);
    }
    return @alternatives;
}
		       
sub generateAlternatives {
    my ($pkg)=@_;
    my (@alternatives,$picto,%STRING);
    unless ($pkg->{lemma}) {
	$pkg->{lemma}=$pkg->{token};
    }
    if ($pkg->lookupFilename) {
	$picto=$pkg->{picto_single}->[0];
	$picto->{condition}=$pkg->{condition};
	@alternatives=$picto->getAlternativeWordObjects;
    }
    else {
	@alternatives=$pkg->getAlternativeWordObjects;
    }
    foreach (@alternatives) {
	my $string='';
	foreach $el (@$_) {
	    $string.=' '.$el->getString;
	}
	unless ($STRING{$string}) {
	    $STRING{$string}=$_;
	}
    }
    @alternatives=values(%STRING);
    for ($i=0;$i<@alternatives;$i++) {
	if ($noun=&containsNoun($alternatives[$i])) {
	    my $arts=$noun->getArticles;
	    foreach $art (@$arts) {
		splice(@alternatives,$i,0,[$art,@{$alternatives[$i]}]);
		$i++;
	    }
	}
    }
    return [@alternatives];
}

sub getString {
    my ($pkg)=@_;
    if ($pkg->{condition} eq 'tok') {
	return $pkg->{token};
    }
    elsif ($pkg->{condition} eq 'toktag') {
	return $pkg->{token}.'%%'.$pkg->{tag};
    }
    else {
	die "Invalid condition\n";
    }
}
       
sub containsNoun {
    my ($alt)=@_;
    foreach (@$alt) {
	if ($_->isNoun) {
	    return $_;
	}
    }
    return undef;
}
   
#---------------------------------------
package message;
#---------------------------------------

sub generateProperText {
    my ($pkg)=@_;
    my $sentences=$pkg->{sentences};
    foreach (@$sentences) {
	$_->generateProperText;
    }
}

#---------------------------------------
package sentence;
#---------------------------------------

sub generateProperText {
   my ($pkg)=@_;
   my @nodes=$pkg->generateAlternatives;
   my $sentencepath=sentencePath->new(toprocess,[[[$pkg->generateStartOfSentence]],
						 @nodes,
						 [[$pkg->generateEndOfSentence]]],
				      logprob,0,
				      processed,[],
				      condition,$pkg->{condition});
   $sentencepath->openNGramDatabase;
   %sentencePath::BESTLOGPROBS=();
   my $q=[$sentencepath];
   until ((@$q==0) ||
	  ($q->[0]->containsAllInfo)) {
       my $firstpath=shift(@$q);
       my @newpaths=$firstpath->extend;
       push(@$q,@newpaths); 
       $scalar=scalar(@$q);
       if($scalar>1){
       		$q=$pkg->sortSentencePathQ($q);
       }
       $qnr=0;
       %sentencePath::BESTLOGPROBS=();
       foreach (@$q) {
	   my $logprob=$_->{logprob};
	   my $toproc=$_->{toprocess};
	   my $nrtoproc=@$toproc;
           unless (defined($sentencePath::BESTLOGPROBS{$nrtoproc})) {
              $sentencePath::BESTLOGPROBS{$nrtoproc}=-999999999;
           }
	   if ($logprob>$sentencePath::BESTLOGPROBS{$nrtoproc}) {
	       $sentencePath::BESTLOGPROBS{$nrtoproc}=$logprob;
	   }
       }
   }
   $q->[0]->hypothesisSolved;
   $q->[0]->printOutput;
   $dummy;
}

sub generateAlternatives {
    my ($pkg)=@_;
    my $words=$pkg->{words};
    my @nodes;
    foreach (@$words) {
	$_->{condition}=$pkg->{condition};
	push(@nodes,$_->generateAlternatives);
    }
    return @nodes;
}

sub generateStartOfSentence {
    my ($pkg)=@_;
    my $condition=$pkg->{condition};
    my $word=word->new(target,$pkg->{target},
		       wordnetdb,$pkg->{wordnetdb},
		       logfile,$pkg->{logfile},
		       lemma,"<s>",
		       token,"<s>",
		       condition,$condition);
    return $word;
}
    
sub generateEndOfSentence {
    my ($pkg)=@_;
    my $condition=$pkg->{condition};
    my $word=word->new(target,$pkg->{target},
		       wordnetdb,$pkg->{wordnetdb},
		       logfile,$pkg->{logfile},
		       lemma,"</s>",
		       token,"</s>",
		       condition,$condition);
    return $word;
}

sub sortSentencePathQ {
    my ($pkg,$q)=@_;
    my @sorted=sort {$b->cost <=> $a->cost} @$q;
    for ($i=0;$i<@sorted;$i++) {
	$nrtoprocess=@{$sorted[$i]->{toprocess}};
	if ($sorted[$i]->{logprob}<$sentencePath::BESTLOGPROBS{$nrtoprocess}-$main::thresholdpruning) {
	    splice(@sorted,$i,1);
	    $i--;
	}
    }
    if (@sorted>$main::histopruning) {
	return [@sorted[0..$main::histopruning-1]];
    }
    else{
	return [@sorted];
    }
}

#---------------------------------------
package sentencePath;
#---------------------------------------
@ISA=("object");

sub cost {
    my ($pkg)=@_;
    my $cost=$pkg->{logprob}-$main::cost_estimate*@{$pkg->{toprocess}};
    $pkg->{cost}=$cost;
    return $cost;
}
						    
sub hypothesisSolved {
    my ($pkg)=@_;
    $pkg->pushFeature(processed,$pkg->{hypothesis});
    $processed=$pkg->{processed};
    shift(@$processed);
    pop(@$processed);
    delete $pkg->{hypothesis};
}

sub containsAllInfo {
    my ($pkg)=@_;
    if (@{$pkg->{toprocess}} <1) {
	return 1;
    }
    else {
	return undef;
    }
}

sub extend {
    my ($pkg)=@_;
    $extend++;
    if ($extend > $main::extend_die) {
	die "\nToo slow - time out";
    }
    my @toprocess=@{$pkg->{toprocess}};
    my $nextnode=shift(@toprocess);
    my $nrtoprocess=@toprocess;
    my $hypothesis=$pkg->{hypothesis};
    my $processed=$pkg->{processed};
    my (@newhypo,@hypo,$ngram,@processed,$sentencepath,@paths,$alt,@tags,$tag,@oldhypo,$bestlogprob);
    unless ($bestlogprob=$BESTLOGPROBS{$nrtoprocess}) {
      $bestlogprob=-999999;
    }
    my @reservepaths;
    foreach $alt (@$nextnode) {
	@newhypo=();
	@hypo=@$hypothesis;
	foreach (@$alt) {
	    if ($_->{condition} eq 'toktag') {
		if (@{$_->{tag}}>0) { 
		    push(@hypo,$_->{token}.'%%'.$_->{tag}->[0]);
		}
		else {
		    push(@hypo,$_->{token});
		}
	    }
	    elsif ($_->{condition} eq 'tok') {
		push(@hypo,$_->{token});
	    }
	    else {
		die "Invalid condition. Use tok/toktag\n";
	    }
	}
	$ngram=ngram->new(words,[@hypo],
			  ngramdb,$pkg->{ngramdb},
			  logfile,$pkg->{logfile});
	$ngram->estimateProb;
	$testedngrams++;
	while ((@hypo>0) &&
	       (@newhypo<4)) {
	    unshift(@newhypo,pop(@hypo));
	}
	@processed=@$processed;
	if (@processed<1) {
	    $logprob=0;
	}
	else {
	    $logprob=$pkg->{logprob};
	}
	push(@processed,@hypo);
	$sentencepath=sentencePath->new(ngramdb,$pkg->{ngramdb},
					logfile,$pkg->{logfile},
					hypothesis,[@newhypo],
					processed,[@processed],
					logprob,$logprob+$ngram->{logprob},
					toprocess,[@toprocess],
					condition,$pkg->{condition});
	push(@reservepaths,$sentencepath);

	if ($sentencepath->{logprob}>$bestlogprob) {
	    $bestlogprob=$sentencepath->{logprob};
	    $BESTLOGPROBS{$nrtoprocess}=$bestlogprob;
	}
	if ($sentencepath->{logprob}>=$bestlogprob-$main::thresholdpruning) {
	    push(@paths,$sentencepath);
	}
    }
    if(@paths){
	    return @paths;
    }
    else{ 
            return @reservepaths;
    }
}

#---------------------------------------
package synset;
#---------------------------------------

sub getAlternativeWordObjects {
    my ($pkg)=@_;
    my $lus=$pkg->{lexunits};
    my (@alts,@newalts,@deps,@alternatives)=();
    my $wordnetpos=$pkg->{pos};
    my $condition=$pkg->{condition};
    my $knownflag=undef; 
    foreach (@$lus) {
        my $lus2=$_->{lexunits};
        foreach(@$lus2){
	if ($condition) {
	    $_->{condition}=$condition;
	}
	my @newalts=$_->getAlternativeWordObjects($wordnetpos);
	unless ($newalts[0]->[0]->{unknown}) {
	    $knownflag=1; 
	}
	if ($knownflag) {
	    unless ($newalts[0]->[0]->{unknown}) {
		push(@alts,@newalts);
	    }
	}
	else { 
	    push(@alts,@newalts);
	}
	}
    
    }
    if ($knownflag) {
	for (my $i=0;$i<@alts;$i++) {
	    if ($alts[$i]->[0]->{unknown}) {
		splice(@alts,$i,1);
		$i--;
	    }
	}
    }
    my $deps=$pkg->{dependents};
    if (@$deps >0) {
	foreach (@$deps) {
	    if ($condition) {
		$_->{condition}=$condition;
	    }
	    push(@deps,$_->getAlternativeWordObjects);
	}
	foreach (@alts) {
	    foreach $dep (@deps) {
		push(@newalts,[@$_,@$dep]);
		push(@newalts,[@$dep,@$_]);
	    }
	}
	return @newalts;
    }
    else {
	return @alts;
    }
}

#---------------------------------------
package lexunit;
#---------------------------------------

sub getAlternativeWordObjects {
    my ($pkg,$wordnetpos)=@_;
    my $wo=word->new(target,$pkg->{target},
		     wordnetdb,$pkg->{wordnetdb},
		     logfile,$pkg->{logfile},
		     lemma,$pkg->{lemma});
    if ($pkg->{condition}) {
	$wo->{condition}=$pkg->{condition};
    }
    return $wo->getAlternativeWordObjects($wordnetpos);
}

#---------------------------------------		  
package picto;
#---------------------------------------

sub getAlternativeWordObjects {
    my ($pkg)=@_;
    $pkg->addSynsets;
    my (@alternatives,@alternativess,@newalternatives,$altss);
	   push(@alternatives,$pkg->checkInDictionary);
	   push(@alternatives,$pkg->checkInPronouns);
	   if($pkg->checkInOverrule){
		@alternatives=();
	   	push(@alternatives,$pkg->checkInOverrule);
	   }
    unless(@alternatives){
    if(($pkg->{synsets}[0]->{lemma}) || ($pkg->{synsets}[0]->{lexunits})){
	    if ($synsets=$pkg->{synsets}) {
		foreach (@$synsets) {
		    push(@alternatives,$_->getAlternativeWordObjects);
		}
	    }
    }
    else {
      $ext=$pkg->{target}->getExtension;
      $token=$pkg->{file};
      $token=~s/$ext$//;
      $wo=word->new(target,$pkg->{target},
		  wordnetdb,$pkg->{wordnetdb},
		  logfile,$pkg->{logfile},
		  lemma,$token);
      if ($condition=$pkg->{condition}) {
	$wo->{condition}=$condition;
      }
      push(@alternatives,$wo->getAlternativeWordObjects);
    }
    }
    return @alternatives;
}

sub checkInDictionary {
    my ($pkg)=@_;
    my $file=$pkg->{file};
    my $target=$pkg->{target};
    my $dicttable=$target->getDictionaryTableName;
    my $sql="select * from $dicttable where picto = '$file';";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    my @alternatives;
    foreach (@$results) {
	$wo=word->new(target,$pkg->{target},
		      wordnetdb,$pkg->{wordnetdb},
		      logfile,$pkg->{logfile},
		      condition,$pkg->{condition});
	if ($_->[0]) {
	    $wo->{token}=$_->[0];
	}
	if ($_->[1]) {
	    $wo->{lemma}=$_->[1];
	}
	if ($_->[2]) {
	    $wo->{tag}=$_->[2];
	}
	push(@alternatives,$wo->getAlternativeWordObjects);
    }
    return @alternatives;
}

sub addSynsets {
    my ($pkg)=@_;
    if ($pkg->{synsets}) {
	return;
    }
    my $db=$pkg->{wordnetdb};
    my $file=$pkg->{file};
    $file=~s/\..+?$//;
    my $sql="select * from $pkg->{target} where lemma='$file';";
    my $results=$db->lookup($sql);
    my $condition=$pkg->{condition};
 foreach (@$results) {
	($lem,$ss,$rel,$headss,$headrel,$depss,$deprel)=@$_;
	unless($ss eq 'N/A'){
	if ($ss ne '') {
	    $synset=synset->new(logfile,$pkg->{logfile},
				wordnetdb,$pkg->{wordnetdb},
				synset,$ss,
				target,$pkg->{target});
	    if ($condition) {
		$synset->{condition}=$condition;
	    }
	    $synset->addLemmas;
	    $synset->addPos;
	    $pkg->pushFeature(synsets,[$synset]);
	}
	elsif ($headss) {
	    unless($headss eq 'N/A'){
	    $headsynset=synset->new(logfile,$pkg->{logfile},
				    wordnetdb,$pkg->{wordnetdb},
				    synset,$headss,
				    target,$pkg->{target});
	    if ($condition) {
		$headsynset->{condition}=$condition;
	    }
	    $headsynset->addLemmas;
	    $headsynset->addPos;
	    $pkg->pushFeature(synsets,[$headsynset]);
	    @depss=split(/,/,$depss);
	    foreach $deps (@depss) {
		unless($deps eq 'N/A'){
		$depsynset=synset->new(logfile,$pkg->{logfile},
				       wordnetdb,$pkg->{wordnetdb},
				       synset,$deps,
				       target,$pkg->{target});
		if ($condition) {
		    $depsynset->{condition}=$condition;
		}
		$depsynset->addLemmas;
		$depsynset->addPos;
		$headsynset->pushFeature(dependents,[$depsynset]);
		}
	    }
	}
	}
	}
    }
}
