####### simplify_dutch.pm ##########

# used to be simplify_cornetto
# adapted by VV

# By Leen Sevens 
# leen@ccl.kuleuven.be 
# Date: 17.05.2017

#---------------------------------------

# Simplification module and temporal analysis module for advanced linguistic analysis
# See also: Sevens L., Vandeghinste V., Schuurman I., Van Eynde F. (2017). Simplified Text-to-Pictograph Translation for People with Intellectual Disabilities. In: Frasincar F., Ittoo A., Nguyen L., Métais E. (Eds.), Natural Language Processing and Information Systems: 22nd International Conference on Applications of Natural Language to Information Systems (NLDB 2017), (pp. 185-196). Cham: Springer International Publishing.

#---------------------------------------

1;

use XML::Twig;
use DB_File;
use Encode;

#---------------------------------------

#require "$Bin/simplifybackup.pm"; # Activated when the simplification module is turned off, or when a time-out occurs during parsing
require "$Bin/modules/GenericFunctionsSimplify.pm"; 

#---------------------------------------

#getopt("abcdefghi",\%opts);
processOptionsSimplify(%opts);

tie %FIRSTNAMES,"DB_File",$firstnamesdb; 

#---------------------------------------

# Hard-coded arrays (can be extended with more terms)

our @arrayofgreetings=("hoi","hallo","hey","ey","allo","yo","goedemorgen","goedemiddag","goedendag","goeiendag","dag","ja","nee");
our @arrayoftitles=("juffrouw","juf","meester","meneer","mama","papa","iedereen","allemaal");
our @arrayofgoodbyes=("groetjes","groeten","doei","daag","daaag","bye","ciao", "x", "xx", "xxx", "xxxx", "xxxxx");
our @arrayofhowareyou=("hoe gaat het( met je| met jou)*","hoe is het( met je| met jou)*");
our @arrayofsubordinateconjunctions=("nadat","na","zodra","toen","wanneer","al","hoewel","ofschoon","hoezeer");
our @arrayofclausetypes=("oti","ti","rel","ssub","ppres","du","smain","whq","sv1","whsub","whrel");
our @arrayoftemporalexpressions=("eergisteren","gisteren","morgen","overmorgen");
our @arrayoftimeunits=("jaar","week","maand","eeuw");
our @arrayofreferences=("volgend", "vorig");

#---------------------------------------
package message;
#---------------------------------------

sub taglemmatize {
    my ($pkg,$nospellcheck)=@_;
    my ($alpino,$new_sentences);
    $pkg->addFullStop; 
    $pkg->preProcessText; 
    $pkg->detectSentences;
    if (my $address=$main::alpino{'server'}) {
      my $sentences=$pkg->{sentences};
      foreach (@$sentences) { # THIS IS NOW ALL CHANGED TO THE SENTENCE LEVEL
        $_->taglemmatize($address);
        my $new_sentences=$_->{sentences};
        push(@sentences,@$new_sentences);
      }
      $pkg->{sentences}=[@sentences];
    }
    else { # go to shallow analysis
      require "shallow_dutch.pm";
      $pkg->taglemmatize;
    }
}


sub preProcessText{
    my ($pkg)=@_;
    my $message=$pkg->{text};
    my $message=lc($message);
    my $greetingregex=join '|',@arrayofgreetings;
    my $titleregex=join '|',@arrayoftitles;
    my $goodbyeregex=join '|',@arrayofgoodbyes;
    my $howareyouregex=join '|',@arrayofhowareyou;
    $message=~s/($howareyouregex)/hoe_gaat_het/g;
    $message=~s/[^[:ascii:]]//g; 
    $message=~s/,/ ,/g;
    $message=~s/[\x{2018}\x{201A}\x{201B}\x{FF07}\x{2019}\x{60}]/'/g;
    $message=~s/([0-1]?[0-9]|2[0-3])[\.:]([0-5][0-9])?/$1/g;
    if ($message=~/^($greetingregex)\s*($titleregex)*\s*[^\s]*\s[,]*/){
	 my ($match,$greeting,$title,$name)=$message=~/(^($greetingregex)\s*($titleregex)*\s*([^\s]*)\s[,]*)/;
	 if($title && $name){
	   	 if ((($main::FIRSTNAMES{ucfirst($name)}) && (($name ne "ik")||($name ne "je")||($name ne "jij")))){
	     	    $message=~s/^($match)/$greeting $title ./g;
		 }
	 }
	 elsif($name){
	   	 if ((($main::FIRSTNAMES{ucfirst($name)}) && (($name ne "ik")||($name ne "je")||($name ne "jij")))){
		 }
		 else{
	 	    $message=~s/^($greeting)/$greeting . /g;
		 }
	 }
	 else{
	 	$message=~s/^($match)/$greeting . /g;
	 }
    } 
    if ($message=~/\s($goodbyeregex).*$/){
	 my ($match,$greeting)=$message=~/(\s($goodbyeregex).*)$/;
         $message=~s/($match)/\n$greeting/g;
    }
#     $message=~s/([\.\?!:;]+)/ $1\n/g;
    $message=~s/:/\./g;
    chomp $message;
    $pkg->{text}=$message;
}


#--------------------------------
package sentence;
#--------------------------------

sub taglemmatize {
  my ($pkg,$address)=@_;
  my ($log)=$pkg->{logfile};
  print $log "Parsing sentence\n-------------------\n" if $log;
  $pkg->parseWithAlpinoServer($address);
  $pkg->showInLog;
  $pkg->identifySyntacticPhenomena;
  $pkg->simplify; 
  if($main::timeanalysis eq "on"){
    $pkg->performTemporalAnalysis; 
  }
  if($main::simplificationlevel eq "compress"){
    $pkg->compress;
  }
}

sub identifySyntacticPhenomena {
    my($pkg)=@_;
    my $log=$pkg->{logfile};
    my $alpinoxml=$pkg->{'parse'};
    my @allsentences;
    my $tree=XML::Twig->new(pretty_print => 'indented');
    $tree->parse($alpinoxml);
    my ($alpino_ds)=$tree->root;
    my ($top)=$alpino_ds->descendants("node[\@rel=\"top\"]"); # For every top, we first check whether a main clause can be found among its descendants
    my @mainclauses=();
    unless($top->descendants("node[\@cat=\"smain\" or \@rel=\"dp\" or \@rel=\"tag\" or \@cat=\"sv1\"]")){ #If this is not the case, we will treat the non-sentence as a main clause
	my @topchildren=$top->children;
	foreach $topchild(@topchildren){
		unless($topchild->{'att'}->{'pt'} eq "let"){
			push(@mainclauses,$topchild);
		}
	}
    }
    else {
      @mainclauses=$alpino_ds->descendants("node[\@cat=\"smain\" or \@rel=\"dp\" or \@rel=\"tag\"  or \@cat=\"sv1\"]");
    }
    # Main clauses
    foreach $mainclause(@mainclauses){
	unless($mainclause->descendants("node[\@cat=\"smain\" or \@rel=\"dp\" or \@rel=\"tag\" or \@cat=\"sv1\"]")){ 
	        print $log "Idenfitying Syntactic Phenomena in main clause\n" if $log;
		$sentence_object=$pkg->identifySyntacticPhenomenaInMainClause($mainclause);
		push(@allsentences,$sentence_object);
		if ($mainclause->descendants("node[\@cat=\"ssub\" or \@cat=\"ti\"]")){ # Inside a main clause, we might find a SSUB or OTI (SSUB can be regular SSUB, REL or question)
		    print $log "Embedded clause found\n" if $log;
		    @allsentences=$pkg->identifySyntacticPhenomenaInSSUBClause($mainclause,@allsentences);
		}
		elsif ($mainclause->descendants("node[\@cat=\"whsub\"]")){ # Inside a main clause, we might find a WHSUB without SSUB 
		        print $log "Interrogative Clause found\n" if $log;
			@clauses=$mainclause->descendants("node[\@cat=\"whsub\"]"); 	
			foreach $clause(@clauses){
				my $subsentence_object=$pkg->buildInterrogativeSentence($clause);
				push(@allsentences,$subsentence_object);	
			}								
		}
		if ($mainclause->descendants("node[\@rel=\"app\"]")){ # Inside a main clause, we might find an apposition
			print $log "Apposition Clause found\n" if $log;
			@clauses=$mainclause->descendants("node[\@rel=\"app\"]"); 
			foreach $clause(@clauses){
				my $subsentence_object=$pkg->buildAppSentence($clause);
				push(@allsentences,$subsentence_object);	
			}
		}
		if ($mainclause->descendants("node[\@cat=\"ppres\"]")){ #  Inside a main clause, we might find an adverbial modifier
		        print $log "Adverbial Modifier found\n" if $log;
			@clauses=$mainclause->descendants("node[\@cat=\"ppres\"]"); 
		        foreach $clause(@clauses){
		         	my $subsentence_object=$pkg->buildPPRESSentence($clause,$mainclause);
				push(@allsentences,$subsentence_object);	
			}
		}
	}
    }
   $pkg->{sentences}=[@allsentences];    
   return $pkg;
}

sub identifySyntacticPhenomenaInMainClause{
	my ($pkg,$mainclause)=@_;
	my $sentence_object;
	my $log=$pkg->{logfile};
	if($mainclause->prev_sibling){ # Three syntactic phenomena must be checked for main clauses: interrogativity, ellipsis, and SV1
	  if($mainclause->prev_sibling->{'att'}->{'rel'} eq "whd"){ 
	    # First case: the main clause could be introduced by a question word
	    print $log "Main clause introduced by question word\n" if $log;
	    $sentence_object=$pkg->buildInterrogativeSentence($mainclause);
          }
	  else{ # Second case: the main clause could be missing its subject (due to conjunction with ellipsis)
	    print $log "Main clause could be missing its subject (ellipsis)\n" if $log;
	    $sentence_object=$pkg->buildMainSentenceWithPotentialSubjectEllipsis($mainclause,$alpino_ds);
	  }
	}
	elsif($mainclause->{'att'}->{'cat'} eq "sv1"){ # Third case: SV1s function like a normal main clause, but we need to add a question mark later on
	  print $log "Verb firsts (SV1) function like normal main clause -- add question mark later\n" if $log;
	  $sentence_object=$pkg->buildMainSentence($mainclause);
	  $sentence_object->{type}="sv1";
	}
	else{ # This is the normal case for main clauses
	  print $log "Normal case for main clause\n" if $log;
	  $sentence_object=$pkg->buildMainSentence($mainclause);
	}
	$sentence_object->showInLog;
	return $sentence_object;
}

sub identifySyntacticPhenomenaInSSUBClause{
	my ($pkg,$mainclause,@allsentences)=@_;
	my @clauses=$mainclause->descendants("node[\@cat=\"ssub\" or \@cat=\"ti\"]"); 
	my $parentclause;
	my $log=$pkg->{logfile};
        foreach $clause(@clauses){ # This clause might be a conjunction, in which case the antecedent will have to be found at a higher level
		if(($clause->prev_sibling) && ($clause->{'att'}->{'rel'} eq "cnj")){
		        print $log "This clause is a conjunction, in which case the antecedent will have to be found at a higher level\n" if $log;
			$parentclause=$clause->parent;
		}
		elsif($clause->prev_sibling){
			$parentclause=$clause;
		}
		else{
			$parentclause=$clause->parent;
		}
		if($parentclause->prev_sibling->{'att'}->{'postag'}=~/VNW\(betr.*/){
		       print $log "RELP is a SSUB with a relative pronoun, so check the sibling\n" if $log;
			my $subsentence_object=$pkg->buildRelSentence($clause);  # First case: RELP is a SSUB with a relative pronoun, so check the sibling
			push(@allsentences,$subsentence_object);
		}
		elsif($parentclause->prev_sibling->{'att'}->{'rel'} eq "whd") { 
			my $subsentence_object=$pkg->buildInterrogativeSentence($clause); # Second case: the clause could be introduced by a question word
			push(@allsentences,$subsentence_object);	
		}
		elsif($clause->{'att'}->{'cat'} eq "ti"){
			my $subsentence_object=$pkg->buildOTISentence($clause,$mainclause); # Third case: the clause could be an OTI sentence			
			push(@allsentences,$subsentence_object);
		}
		else{ # This is the normal case for SSUB
			@allsentences=$pkg->buildRegularSSUBSentence($parentclause,$clause,$mainclause,@allsentences);
		}					
	}
	return @allsentences;
}

sub buildInterrogativeSentence{
	my ($pkg,$mainclause)=@_;
	my @syntax;
	my $sentence_object=sentence->new(type,"question",
	                                  logfile,$pkg->{logfile},
	                                  target,$pkg->{target}); 	
	$sentence_object->{questionword}=$pkg->findQuestionWord($mainclause); 
	@syntax=$pkg->buildWordObjects($mainclause); 
	$sentence_object->{syntax}=[@syntax];
	return $sentence_object;
}

sub findQuestionWord{
	my ($pkg,$clause)=@_;
	my $log=$pkg->{logfile};
	my $sibling=$clause->prev_sibling;
	my $word_object=word->new(type,"word",
		target,$pkg->{target},
		lemma,$sibling->{'att'}->{'lemma'},
		token,$sibling->{'att'}->{'word'},
		tag,$sibling->{'att'}->{'postag'},
		indexnumber,$sibling->{'att'}->{'index'},
		transitivity,$sibling->{'att'}->{'sc'},
		function,$sibling->{'att'}->{'rel'},
		logfile,$log,
		);	
	return $word_object;
}

sub buildMainSentenceWithPotentialSubjectEllipsis{
	my ($pkg,$mainclause,$root)=@_;
	my @syntax;
	my $sentence_object=sentence->new(type,"main"); 
	@syntax=$pkg->buildWordObjects($mainclause);
	$sentence_object->{syntax}=[@syntax];
	my $allsyntaxobjects=$sentence_object->{syntax};
	my $index;	
	foreach $syntaxobject(@$allsyntaxobjects){
		if($syntaxobject->{type} eq "word"){
			if((($syntaxobject->{function} eq "su") || ($syntaxobject->{function} eq "sup")) && ($syntaxobject->{token} eq undef)){
				$index=$syntaxobject->{indexnumber}; 
			}
		}
	}
	if($index){
		my @referees=$root->descendants("node[\@index=\"$index\"]");
		my $referee=@referees[0]; 
		my $head;
		if($referee->descendants){
			my @heads=$referee->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]"); 
			$head=@heads[0];
		}
		else{
			$head=$referee;
		}
		my $head_object=word->new(type,"word",
			target,$pkg->{target},
			lemma,$head->{'att'}->{'lemma'},
			token,$head->{'att'}->{'word'},
			tag,$head->{'att'}->{'postag'},
			indexnumber,$head->{'att'}->{'index'},
			transitivity,$head->{'att'}->{'sc'},
			function,$head->{'att'}->{'rel'});
		$sentence_object->{functionofantecedent}="su";					
		$sentence_object->{antecedent}=$head_object;					
	}
	return $sentence_object;
}

sub buildMainSentence{
	my ($pkg,$mainclause)=@_;
	my @syntax;
	my $sentence_object=sentence->new(type,"main",
	                                  target,$pkg->{target},
	                                  wordnetdb,$pkg->{wordnetdb},
	                                  logfile,$pkg->{logfile});
	@syntax=$pkg->buildWordObjectsPerSentence($mainclause); 
	$sentence_object->{syntax}=[@syntax];
	return $sentence_object;
}

sub buildRelSentence{
	my ($pkg,$clause)=@_;
	my @syntax;
	my $log=$pkg->{logfile};
	my $subsentence_object=sentence->new(logfile,$log,
	                                     target,$pkg->{target},
	                                     wordnetdb,$pkg->{wordnetdb});
	if(($clause->prev_sibling) && ($clause->{'att'}->{'rel'} eq "cnj")){
		$parentclause=$clause->parent;
	}
	elsif($clause->prev_sibling){
		$parentclause=$clause;
	}
	else{
		$parentclause=$clause->parent;
	}
	$indexofrelativepronoun=$parentclause->prev_sibling->{'att'}->{'index'};
	my @indicatorsofantecedentfunction=$parentclause->descendants("node[\@index=\"$indexofrelativepronoun\"]"); 
	my $syntacticfunction=$indicatorsofantecedentfunction[0]->{'att'}->{'rel'};
	$subsentence_object->{type}="rel";
	$subsentence_object->{functionofantecedent}=$syntacticfunction;
	$subsentence_object->{antecedent}=$pkg->findAntecedent($clause); 
	@syntax=$pkg->buildWordObjectsPerSentence($clause); 
	$subsentence_object->{syntax}=[@syntax];
	print $log "\nBuilt Relative Sentence\n" if $log;
	$subsentence_object->showInLog;
	return $subsentence_object;
}

sub findAntecedent{ 
	my ($pkg,$clause)=@_;
	if(($clause->prev_sibling) && ($clause->{'att'}->{'rel'} eq "cnj")){
		$parentclause=$clause->parent;
	}
	elsif($clause->prev_sibling){
		$parentclause=$clause;
	}
	else{
		$parentclause=$clause->parent;
	}
	my $parent=$parentclause->parent;
	my $grandparent=$parent->parent;
	if (@descendants=$grandparent->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]")){  
#		@descendants=$grandparent->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]"); 
		$descendant=@descendants[0];
		my $lemma=$descendant->{'att'}->{'lemma'};
		unless($lemma eq "hoe_gaat_het"){
			$lemma=~s/_//g;
			$lemma=~s/DIM//g;
		}
		my $word_object=word->new(type,"word",
			target,$pkg->{target},
			lemma,$lemma,
			token,$descendant->{'att'}->{'word'},
			tag,$descendant->{'att'}->{'postag'},
			indexnumber,$descendant->{'att'}->{'index'},
			transitivity,$descendant->{'att'}->{'sc'},
			function,$descendant->{'att'}->{'rel'},
			logfile,$pkg->{logfile});
	return $word_object;
	}
}

sub buildOTISentence{
	my ($pkg,$clause,$mainclause)=@_;
	my @syntax;
	my $log=$pkg->{logfile};
	my $subsentence_object=sentence->new(type,"oti",
	                                     logfile,$log,
	                                     target,$pkg->{target}); 
	@syntax=$pkg->buildWordObjectsPerSentence($clause);
	$subsentence_object->{syntax}=[@syntax];
	my @clausedescendants;
	my @referees;
	my $referee;
	if($clause->descendants("node[\@rel=\"su\"]")){
		@clausedescendants=$clause->descendants("node[\@rel=\"su\"]");
		my $subject=@clausedescendants[0];
		my $index=$subject->{'att'}->{'index'};
         	@referees=$mainclause->descendants("node[\@index=\"$index\"]"); 
		$referee=@referees[0];
	}
	else{
		@referees=$mainclause->descendants("node[\@rel=\"su\"]");
		$referee=@referees[-1];
	}
	my $head;
	my $parent;
	my $grandparent;
	if($referee){
		if($referee->{'att'}->{'postag'}=~/VNW\(betr.*/){
			$parent=$referee->parent;
			$grandparent=$parent->parent;
			my @parentsdescendants=$grandparent->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]");
			$head=@parentsdescendants[0];
		}
		else{
			if($referee->descendants){ 
				my @heads=$referee->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]");
				$head=@heads[0];
			}
			else{
				$head=$referee;
			}
		}
		my $lemma=$head->{'att'}->{'lemma'};
		if($lemma eq "hoe_gaat_het"){
	        }
		else{
		$lemma=~s/_//g;
		$lemma=~s/DIM//g;
		}
		my $head_object=word->new(type,"word", ## WHAT IF THERE IS NO LEMMA, IF IT IS AN INDEXED NODE
		                                       ## je moet een hond zijn om te blaffen
			target,$pkg->{target},
			lemma,$lemma,
			token,$head->{'att'}->{'word'},
			tag,$head->{'att'}->{'postag'},
			indexnumber,$head->{'att'}->{'index'},
			transitivity,$head->{'att'}->{'sc'},
			function,$head->{'att'}->{'rel'},
			logfile,$log);
		$subsentence_object->{functionofantecedent}="su";
		$subsentence_object->{antecedent}=$head_object;	
	}
	return $subsentence_object;
}

sub buildRegularSSUBSentence{
	my ($pkg,$parentclause,$clause,$mainclause,@allsentences)=@_;
	my $grandparentclause;
	my $subsentence_object=$pkg->buildSSUBSentence($clause,$mainclause);
	if($parentclause->prev_sibling->{'att'}->{'rel'} eq "cmp"){
		$grandparentclause=$parentclause;
	}
	elsif($parentclause->parent->prev_sibling){
		if($parentclause->parent->prev_sibling->{'att'}->{'rel'} eq "cmp"){
			$grandparentclause=$parentclause->parent;
		}
		else{
			$grandparentclause=$parentclause;
		}
	}
	else{
		$grandparentclause=$parentclause;
	}
	@allsentences=$pkg->changeClauseOrder($grandparentclause,$subsentence_object,@allsentences);
	return @allsentences;
}

sub buildSSUBSentence{
	my ($pkg,$clause,$mainclause)=@_;
	my @syntax;
 	my $subsentence_object=sentence->new(logfile,$pkg->{logfile},
 	                                     target,$pkg->{target}); 
	my $type=$clause->{'att'}->{'cat'}; 
	$subsentence_object->{type}="ssub";
	@syntax=$pkg->buildWordObjectsPerSentence($clause);
	$subsentence_object->{syntax}=[@syntax];
	my $allsyntaxobjects=$subsentence_object->{syntax};
	my $index;	
	foreach $syntaxobject(@$allsyntaxobjects){
		if($syntaxobject->{type} eq "word"){
			if((($syntaxobject->{function} eq "su") || ($syntaxobject->{function} eq "sup")) && ($syntaxobject->{token} eq undef)){ 
				$index=$syntaxobject->{indexnumber}; 
			}
		}
	}
	if($index){
		my @referees=$mainclause->descendants("node[\@index=\"$index\"]");
		my $referee=@referees[0];
		my $head;
		if($referee->descendants){
			my @heads=$referee->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]");
			$head=@heads[0];
		}
		else{
			$head=$referee;
		}
		my $head_object=word->new(type,"word",
			target,$main::targetlanguage,
			lemma,$head->{'att'}->{'lemma'},
			token,$head->{'att'}->{'word'},
			tag,$head->{'att'}->{'postag'},
			indexnumber,$head->{'att'}->{'index'},
			transitivity,$head->{'att'}->{'sc'},
			function,$head->{'att'}->{'rel'},
			logfile,$pkg->{logfile});
		$subsentence_object->{functionofantecedent}="su";
		$subsentence_object->{antecedent}=$head_object;
	}
	return $subsentence_object;
}

sub changeClauseOrder{
	my ($pkg,$grandparentclause,$subsentence_object,@allsentences)=@_;
	if($grandparentclause->prev_sibling){
		$clauseword=$grandparentclause->prev_sibling->{'att'}->{'lemma'};
   		my $conjunctionregex=join '|',@arrayofsubordinateconjunctions;
		if($clauseword=~/$conjunctionregex/){
			unshift(@allsentences,$subsentence_object);
		}						
		else{				
			push(@allsentences,$subsentence_object);
		}
	}
	else{
		push(@allsentences,$subsentence_object);
	}
	return @allsentences;
}

sub buildAppSentence{
	my ($pkg,$clause)=@_;
 	my $subsentence_object=sentence->new(logfile,$pkg->{logfile},
 	                                     target,$pkg->{target}); 
	$subsentence_object->{type}="app";
	$subsentence_object->{antecedent}=$pkg->findAppositionAntecedent($clause); 
	@syntax=$pkg->buildWordObjectsPerSentence($clause); 
	$subsentence_object->{syntax}=[@syntax];
	return $subsentence_object;
}

sub findAppositionAntecedent{ 
   my ($pkg,$clause)=@_;
   my $parent=$clause->parent;
   my @siblings=$parent->children; 
   my $descendant;
   foreach $sibling(@siblings){
	if (($sibling->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]") || (($sibling->{'att'}->{'rel'} eq "hd") && (($sibling->{'att'}->{'pt'} eq "n") || ($sibling->{'att'}->{'pos'} eq "name"))))){ 
		if(($sibling->{'att'}->{'rel'} eq "hd") && (($sibling->{'att'}->{'pt'} eq "n") || ($sibling->{'att'}->{'pos'} eq "name"))){
			$descendant=$sibling;
		}
		else{
			@descendants=$sibling->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]"); 
			$descendant=@descendants[0];
		}
		my $lemma=$descendant->{'att'}->{'lemma'};
		if($lemma eq "hoe_gaat_het"){
	        }
		else{
		$lemma=~s/_//g;
		$lemma=~s/DIM//g;
		}
		my $word_object=word->new(type,"word",
			target,$main::targetlanguage,
			lemma,$lemma,
			token,$descendant->{'att'}->{'word'},
			tag,$descendant->{'att'}->{'postag'},
			indexnumber,$descendant->{'att'}->{'index'},
			transitivity,$descendant->{'att'}->{'sc'},
			function,$descendant->{'att'}->{'rel'},
			logfile,$pkg->{logfile});
		return $word_object;
	}
   }
}

sub buildPPRESSentence{
	my ($pkg,$clause,$mainclause)=@_;
	my $subsentence_object=sentence->new(logfile,$pkg->{logfile},
	                                     target,$pkg->{target});
	$subsentence_object->{type}="ppres";
	my @referees=$mainclause->descendants("node[\@rel=\"su\"]");
	my $referee=@referees[0];
	my $head;
	if($referee->descendants){
		my @heads=$referee->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]"); 
		$head=@heads[0];
	}
	else{
		$head=$referee;
	}					
	my $head_object=word->new(type,"word",
		target,$main::targetlanguage,
		lemma,$head->{'att'}->{'lemma'},
		token,$head->{'att'}->{'word'},
		tag,$head->{'att'}->{'postag'},
		indexnumber,$head->{'att'}->{'index'},
		transitivity,$head->{'att'}->{'sc'},
		function,$head->{'att'}->{'rel'},
		logfile,$pkg->{logfile});
	$subsentence_object->{antecedent}=$head_object;		
	@syntax=$pkg->buildWordObjectsPerSentence($clause); 
	$subsentence_object->{syntax}=[@syntax];
	return $subsentence_object;
}

sub buildWordObjectsPerSentence{ # There exist words (terminals) and phrases (non-terminals), in which case a recursive function will be called
   my ($pkg,$clause)=@_;
   my @syntax;
   my $log=$pkg->{logfile};
   if(my @children=$clause->children){
# 	   my @children=$clause->children;
	   foreach $child(@children){
	  	my @phrasearray;
	   	if ($child->children<1) {
			if(($child->{'att'}->{'rel'} eq "svp") || ($child->{'att'}->{'rel'} eq "cmp") || ($child->{'att'}->{'rel'} eq "dlink")){
				next;
			}
			else{
				my $lemma=$child->{'att'}->{'lemma'};
				unless($lemma eq "hoe_gaat_het"){
					$lemma=~s/_//g;
					$lemma=~s/DIM//g;
				}
				my $word_object=word->new(type,"word",
					target,$main::targetlanguage,
					lemma,$lemma,
					token,$child->{'att'}->{'word'},
					tag,$child->{'att'}->{'postag'},
					indexnumber,$child->{'att'}->{'index'},
					transitivity,$child->{'att'}->{'sc'},
					function,$child->{'att'}->{'rel'},
					logfile,$log);
				push(@syntax,$word_object);
			}
		}
		else{
	                my $clausetypesregex=join '|',@arrayofclausetypes;
			unless(($child->{'att'}->{'cat'}=~/$clausetypesregex/)||($child->{'att'}->{'rel'} eq "app")||($child->{'att'}->{'rel'} eq "dp")){
				my $phrase_object=phrase->new(type,"phrase",
				                           target,$pkg->{target},
				                           logfile,$pkg->{logfile},
		      					   indexnumber,$child->{'att'}->{'index'},
							   phrasetype,$child->{'att'}->{'cat'},
							   function,$child->{'att'}->{'rel'},
							   logfile,$log);
				my @childrenofchild=$child->children;
				foreach $childofchild(@childrenofchild){
					unless(($childofchild->{'att'}->{'cat'}=~/$clausetypesregex/)||($childofchild->{'att'}->{'rel'} eq "app")||($childofchild->{'att'}->{'rel'} eq "dp")){
						push(@phrasearray,$pkg->buildPhraseObjects($childofchild));
					}
				}
				$phrase_object->{syntax}=[@phrasearray];
				push(@syntax,$phrase_object);
			}
		}
	   }
	   return @syntax;
	}
	else{
		my $lemma=$clause->{'att'}->{'lemma'};
		unless($lemma eq "hoe_gaat_het"){
			$lemma=~s/_//g;
			$lemma=~s/DIM//g;
		}
		my $word_object=word->new(type,"word",
                       target,$main::targetlanguage,
		       lemma,$lemma,
		       token,$clause->{'att'}->{'word'},
		       tag,$clause->{'att'}->{'postag'},
		       indexnumber,$clause->{'att'}->{'index'},
		       transitivity,$clause->{'att'}->{'sc'},
		       function,$clause->{'att'}->{'rel'},
		       logfile,$log);
		push(@syntax,$word_object);
	        return @syntax;
	}
}

sub buildPhraseObjects{
   my ($pkg,$child)=@_;
   my @syntax;
   my $log=$pkg->{logfile};
   my @phrasearray;
   if ($child->children<1) {
		if(($child->{'att'}->{'rel'} eq "svp") || ($child->{'att'}->{'rel'} eq "cmp") || ($child->{'att'}->{'rel'} eq "dlink")){
			next;
		}
		else{
			my $lemma=$child->{'att'}->{'lemma'};
			unless($lemma eq "hoe_gaat_het"){
				$lemma=~s/_//g;
				$lemma=~s/DIM//g;
			}
			my $word_object=word->new(type,"word",
				target,$pkg->{target},
				logfile,$pkg->{logfile},
				lemma,$lemma,
				token,$child->{'att'}->{'word'},
				tag,$child->{'att'}->{'postag'},
				indexnumber,$child->{'att'}->{'index'},
				transitivity,$child->{'att'}->{'sc'},
				function,$child->{'att'}->{'rel'},
				logfile,$log);
		return $word_object;
		}
   }
   else{
                my $clausetypesregex=join '|',@arrayofclausetypes;
		unless(($child->{'att'}->{'cat'}=~/$clausetypesregex/)||($child->{'att'}->{'rel'} eq "app")||($child->{'att'}->{'rel'} eq "dp")){
			my $phrase_object=phrase->new(type,"phrase",
		     				      indexnumber,$child->{'att'}->{'index'},
						      phrasetype,$child->{'att'}->{'cat'},	
						      function,$child->{'att'}->{'rel'},
						      logfile,$log);
			my @childrenofchild=$child->children;
			foreach $childofchild(@childrenofchild){
				unless(($childofchild->{'att'}->{'cat'}=~/$clausetypesregex/)||($childofchild->{'att'}->{'rel'} eq "app")||($childofchild->{'att'}->{'rel'} eq "dp")){
					push(@phrasearray,$pkg->buildPhraseObjects($childofchild));
				}
		}
		$phrase_object->{syntax}=[@phrasearray];
		return $phrase_object;
	}
   }
}

sub simplify {
    my ($pkg)=@_;
    my $log=$pkg->{logfile};
    my $sentences=$pkg->{sentences};
    my ($simplified_words,@words);
    foreach (@$sentences) {
	$_->movePPsToBack;
	$_->checkForPassives;
	$_->changeOrder;
	$_->buildWordObjects;
	$_->addQuestionMark;
	}
    print $log "\nSentence After Simplification:\n" if $log;
    $pkg->showInLog;
}

sub simplify_{
	my ($pkg)=@_;
	my $sentences=$pkg->{sentences};  
	my $i=0;
	while($i<=$#$sentences){
		@$sentences[$i]->movePPsToBack; # Move PPs and adverbs at the beginning of the sentence (in front of subject) to the back of the sentence
		@$sentences[$i]->checkForPassives; # Check if the sentence is a passive sentence 
		@$sentences[$i]->addPolarityFeature; # Give words a polarity feature if a negative is found
		@$sentences[$i]->changeOrder; # Move verbs, subjects, and antecedents with the aim of obtaining an active SVO order
		@$sentences[$i]->buildWordObjects; # Flatten the word object structure for further picto operations
		@$sentences[$i]->addQuestionMark; # Add a question mark word object when the sentence type is a question or SV1
		$firstwordinarray=@$sentences[$i]->{words}->[0];
		if ($firstwordinarray eq undef){
			splice(@$sentences,$i,1);
		}
		else{
			$i++;
		}
	}
}

sub performTemporalAnalysis{
    my ($pkg)=@_;
    my $sentences=$pkg->{sentences}; 
    foreach $sentence(@$sentences){
	$sentence->addTimeRules; # Apply the time rules to determine temporality and whether all verbs should be retained and in what order
	$sentence->changeVerbOrder; # Determine verb order and remove verbs that do not contribute to the meaning of the message
	$sentence->generateTimePicto; # This will generate a picto for future or past
    }
}

sub compress{
    my ($pkg)=@_;
    my $sentences=$pkg->{sentences};  
    my $i=0;
    while($i <= $#$sentences){
	 @$sentences[$i]->compress;
	 $i++;
    }
}

sub deleteTempFiles{
    `rm -f $main::treebankoutput/treebank.sents.*`;
    `rm -f $main::treebankoutput/inputfile*`;
    `rm -f $main::treebankoutput/logging`;
    `rm -f $main::treebankoutput/treebank.xml`;
}

#---------------------------------------
#package sentence;
#---------------------------------------

sub parseWithAlpinoServer {
  my ($pkg,$address)=@_;
  my $txt=$pkg->{text};
  chomp $txt;
  $txt=~s/\n/ /g;
  my @xml=`echo $txt | nc $address`;
  unless (@xml>0) { 
    my $log=$pkg->{logfile};
    print $log "Parsing didn't work.\n" if $pkg->{logfile};
    die "Parsing didn't work. Check whether parser server host is active\n";
  }
  $pkg->{"parse"}=join("",@xml);
  return $pkg;
}

sub movePPsToBack{ 
	my ($pkg)=@_;
	my $syntaxelements=$pkg->{syntax};
	my $i=0;
	my $amountofsyntaxelements=scalar(@$syntaxelements);
	my $amountofsyntaxelementsindex=$amountofsyntaxelements-1;
	my $modifier;
	my $phrasetype=$pkg->{type};
	if($phrasetype eq "app"){
		return $pkg;
	}
	else{
		while ($i <= $#$syntaxelements) { 			
			if((@$syntaxelements[$i]->{phrasetype} eq "pp") || (@$syntaxelements[$i]->{function} eq "mod")){
				$modifier=@$syntaxelements[$i];
				splice(@$syntaxelements,$i,1);						
				splice @$syntaxelements, $amountofsyntaxelementsindex, 0, $modifier;
				$i++;
			}
			else{
				$i++;
			}
		}
	return $pkg;
	}
}


sub checkForPassives{
	my ($pkg)=@_;
	my $syntaxelements=$pkg->{syntax};
	my $i=0;
	while ($i<=$#$syntaxelements) { 
		if(@$syntaxelements[$i]->{type} eq "word"){
			if (@$syntaxelements[$i]->{transitivity} eq "passive"){
				$pkg->{mode}="passive";
				last;
			}
			else{
				$i++;
			}
		}
		else{
			$passive=checkPhraseForPassives(@$syntaxelements[$i]);
			if($passive eq undef){
				$i++;
			}
			else{
				$pkg->{mode}="passive";
				last;
			}
		}
	}
	unless($pkg->{mode} eq "passive"){
		$pkg->{mode}="active";
	}
	return $pkg;
}

sub checkPhraseForPassives{
	my ($pkg)=@_;
	my $phraseelements=$pkg->{syntax};
	my $j=0;
	while ($j<=$#$phraseelements) {
		if(@$phraseelements[$j]->{type} eq "word"){
			if (@$phraseelements[$j]->{transitivity} eq "passive"){
				my $passive=@$phraseelements[$j];				
				return $passive;
				last;
			}
			else{
				$j++;
			}
		}
		else{
			$phrase=checkPhraseForPassives(@$phraseelements[$j]);
			if($phrase eq undef){
				$j++;
			}
			else{
				return $phrase;
			}		
		}
	}
}

sub addPolarityFeature{
        my ($pkg)=@_;
	my $syntaxelements=$pkg->{syntax};
	my $i=0;
	while ($i<=$#$syntaxelements) {
		if (@$syntaxelements[$i]->{type} eq "word"){
			my $head;
			if(@$syntaxelements[$i]->{lemma} eq "niet"){
				foreach $syntaxelement(@$syntaxelements){
					my $maxwindowsize=4;
	   				my $windowsize;
					until ($head) {
	  				    $windowsize++;
					    if ($windowsize>$maxwindowsize) {
						last;
					    }
					    $hypothesis=@$syntaxelements[$i+$windowsize];
					    if (($hypothesis->{tag}=~/WW|ADJ/) && ($hypothesis->{token} ne "niet")) {
						$head=$hypothesis;
					    }
					    else {
					   	$hypothesis=@$syntaxelements[$i-$windowsize];
						if (($hypothesis->{tag}=~/WW|ADJ/) &&  ($hypothesis->{token} ne "niet")) {
						    $head=$hypothesis;
						}
					    }
					}
					if($head){
						$head->{polarity}=@$syntaxelements[$i];
			    			splice (@$syntaxelements,$i,1);
						last;
					}
					else{
						$i++;
					}
				}
			}
			elsif(@$syntaxelements[$i]->{lemma} eq "geen"){
				foreach $syntaxelement(@$syntaxelements){
					my $maxwindowsize=4;
	   				my $windowsize;
					until ($head) {
	  				    $windowsize++;
					    if ($windowsize>$maxwindowsize) {
						last;
					    }
					    $hypothesis=@$syntaxelements[$i+$windowsize];
					    if (($hypothesis->{tag}=~/N/) && ($hypothesis->{token} ne "geen")) {
						$head=$hypothesis;
					    }
					    else {
					   	$hypothesis=@$syntaxelements[$i-$windowsize];
				                if (($hypothesis->{tag}=~/N/) && ($hypothesis->{token} ne "geen")) {
						    $head=$hypothesis;
						}
					    }
					}
					if($head){
						$head->{polarity}=@$syntaxelements[$i];
			    			splice (@$syntaxelements,$i,1);
						last;
					}
					else{
						$i++;
					}
				}
			}
			else{
				$i++;
			}
		}
		else{
			addPolarityFeature(@$syntaxelements[$i]);
			$i++;
		}
	}
   return $pkg;
}

sub changeOrder{
	my($pkg)=@_;
	$pkg->findAllVerbs; # Group all verbs
	if (($pkg->{type} eq "ssub") || ($pkg->{type} eq "main") || ($pkg->{type} eq "oti")){
		$pkg->moveMainAndSSUBVerbs; # Situation #1: There is already a subject - the verbs need to be moved behind the subject
	}
	elsif((($pkg->{type} eq "rel") && ($pkg->{functionofantecedent} eq "obj1")) || (($pkg->{type} eq "rel") && ($pkg->{functionofantecedent} eq "obj2"))){
		$pkg->moveRelObjectVerbs; # Situation #2: There is already a subject - the verbs need to be moved behind the subject. We also need to add the object 
	}
	elsif(((($pkg->{type} eq "rel") && (($pkg->{functionofantecedent} eq "su") || ($pkg->{functionofantecedent} eq "sup"))) || ($pkg->{type} eq "ppres"))){
		$pkg->moveRelSubjectVerbs; # Situation #3: The subject must be moved to the first position
	}
        elsif($pkg->{type} eq "app"){
		$pkg->createAppositiveSentences; # Situation #3: In appositions, we add the antecedent and "to be" to the front
	}
	elsif(($pkg->{type} eq "question") || ($pkg->{type} eq "sv1")){
		$pkg->moveInterrogativeVerbs; # Situation #5: Move the verbs behind the question word and the subject (question word - SVO)
	}
	if($pkg->{mode} eq "passive"){
		$pkg->makeActive; # Convert passive sentences into active sentences when "door" is found
	}
}

sub findAllVerbs{
	my ($pkg)=@_;
        my @verbsarray;
	my $i=0;
	my $syntaxelements=$pkg->{syntax};
	while ($i <= $#$syntaxelements) {
		if (@$syntaxelements[$i]->{type} eq "word"){
			if((@$syntaxelements[$i]->{tag}=~/^WW.*/) && (@$syntaxelements[$i]->{tag}!~/^WW\(vd,prenom*/) && (@$syntaxelements[$i]->{tag}!~/^WW\(inf,nom*/) && (@$syntaxelements[$i]->{tag}!~/^WW\(od,prenom*/)){
				push(@verbsarray,@$syntaxelements[$i]);
	    			splice (@$syntaxelements,$i,1);
			}
			else{
				$i++;
			}
		}
		else{
			my $j=0;
			my $syntaxelementsofsyntaxelement=@$syntaxelements[$i]->{syntax};
			while ($j <= $#$syntaxelementsofsyntaxelement) {
				$findallverbsinphrase=findAllVerbsInPhrase(@$syntaxelementsofsyntaxelement[$j]);
				if($findallverbsinphrase eq undef){
					$j++;
				}
				else{
					if(@$syntaxelementsofsyntaxelement[$j]->{syntax}){
						push(@verbsarray,$findallverbsinphrase);
						$j++;
					}
					else{
						push(@verbsarray,$findallverbsinphrase);
		    				splice(@$syntaxelementsofsyntaxelement,$j,1);
					}
				}
			}
			$i++;
		}
	}
   my @list = flatten([@verbsarray]);
   $pkg->{verbs}=[@list];
   return $pkg;
}

sub findAllVerbsInPhrase{
    my ($pkg)=@_;
    my @verbsarray;
    if ($pkg->{type} eq "word"){
	if(($pkg->{tag}=~/^WW.*/) && ($pkg->{tag}!~/^WW\(vd,prenom*/) && ($pkg->{tag}!~/^WW\(inf,nom*/) && ($pkg->{tag}!~/^WW\(od,prenom*/)){
		return $pkg;
	}
    }
    else{
	my $k=0;
	my $phraseelements=$pkg->{syntax};
	while ($k<=$#$phraseelements) {
			my $findallverbsinphrase=findAllVerbsInPhrase(@$phraseelements[$k]);
			if($findallverbsinphrase eq undef){
				$k++;
			}
			else{
				if(@$phraseelements[$k]->{syntax}){
					$k++; 
					push(@verbsarray,$findallverbsinphrase);
				}
				else{
				    	splice (@$phraseelements,$k,1);
					push(@verbsarray,$findallverbsinphrase);
				}
			}
	} 	
	if(@verbsarray){
		return [@verbsarray];
	}
    }
}

sub flatten{map{ref $_ eq 'ARRAY' ? flatten(@$_):$_} @_}

sub moveMainAndSSUBVerbs{
	my ($pkg)=@_; 
	if($pkg->{antecedent}){
		$pkg->moveSubjectToFront;
	}
	$pkg->moveAllVerbsBehindSubject;
}

sub moveRelObjectVerbs{
	my ($pkg)=@_; 
	$pkg->moveAllVerbsBehindSubject;
	$pkg->moveObjectBehindVerbs;
}

sub moveRelSubjectVerbs{
	my ($pkg)=@_; 
	$pkg->moveAllVerbsToFront;
	$pkg->moveSubjectToFront;
}

sub createAppositiveSentences{
	my ($pkg)=@_;
	$pkg->moveToBeToFront;
	$pkg->moveSubjectToFront;
}

sub moveInterrogativeVerbs{
	my ($pkg)=@_; 
	$pkg->moveAllVerbsBehindSubject;
	$pkg->moveQuestionWordToFront;
}

sub moveAllVerbsBehindSubject{
	my ($pkg)=@_;
	my $verbs=$pkg->{verbs};
	my $verb_object;
	my $amountofverbs=scalar(@$verbs);
	my $i;
	if ($amountofverbs>1){
		$verb_object=phrase->new(type,"phrase",
			phrasetype,"vc",	
			function,"hd",
			syntax,$verbs);
	}
	else{
		$verb_object=@$verbs[0];
	}
	my $syntaxelements=$pkg->{syntax};
	my $index=1;
	my $subjectcheck="nosubjectfound";
	foreach $syntaxelement(@$syntaxelements){
		my $function=$syntaxelement->{function};
		if (($function eq "su") || ($function eq "sup")){
			splice @$syntaxelements, $index, 0, $verb_object;
			$subjectcheck="subjectfound";
			last;
		}
		else{
			$index++;
		}
	}
	if($subjectcheck eq "nosubjectfound"){
		splice @$syntaxelements, 0, 0, $verb_object;
	}
	delete $pkg->{verbs};
	return $pkg;
}

sub moveAllVerbsToFront{
	my ($pkg)=@_;
	my $verbs=$pkg->{verbs};
	my $verb_object;
	my $amountofverbs=scalar(@$verbs);
	my $syntaxelements=$pkg->{syntax};
	if ($amountofverbs>1){
		$verb_object=phrase->new(type,"phrase",
			phrasetype,"vc",	
			function,"hd",
			syntax,$verbs);
	}
	else{
		$verb_object=@$verbs[0];
	}
	splice @$syntaxelements, 0, 0, $verb_object;
	delete $pkg->{verbs};
	return $pkg;
}

sub moveObjectBehindVerbs{ 
	my ($pkg)=@_;
	my $antecedent=$pkg->{antecedent};
	my $functionofantecedent=$pkg->{functionofantecedent};
	$antecedent->{function}=$functionofantecedent;
	my $syntaxelements=$pkg->{syntax};
	my $index=1;
	foreach $syntaxelement(@$syntaxelements){
		my $function=$syntaxelement->{function};
		if ($function eq "hd"){
			splice @$syntaxelements, $index, 0, $antecedent;
			last;
		}
		else{
			$index++;
		}
	}
	delete $pkg->{antecedent};
	delete $pkg->{functionofantecedent};
	return $pkg;	
}

sub moveSubjectToFront{
	my ($pkg)=@_;
	my $antecedent=$pkg->{antecedent};
	if ($pkg->{functionofantecedent}){
		my $functionofantecedent=$pkg->{functionofantecedent};
		$antecedent->{function}=$functionofantecedent;
	}
	my $syntaxelements=$pkg->{syntax};
	splice @$syntaxelements, 0, 0, $antecedent;
	delete $pkg->{antecedent};
	delete $pkg->{functionofantecedent};
	return $pkg;	
}

sub moveQuestionWordToFront{
	my ($pkg)=@_;
	my $questionword=$pkg->{questionword};
	my $syntaxelements=$pkg->{syntax};
	splice @$syntaxelements, 0, 0, $questionword;
	delete $pkg->{questionword};
	return $pkg;
}

sub moveToBeToFront{
	my ($pkg)=@_;
	my $syntaxelements=$pkg->{syntax};
	$be_object=word->new(type,"word",
		function,"hd",
		target,$main::targetlanguage,
		lemma,"zijn",
		tag,"WW(pv,tgw,ev)",
		token,"is/zijn",
		transitivity, undef);
	splice @$syntaxelements, 0, 0, $be_object;
	return $pkg;
}

sub makeActive{
	my ($pkg)=@_;
	my $agentphrase;
	my $patiensphrase;
	my $syntaxelements=$pkg->{syntax};
	my $i=0;
	while ($i<=$#$syntaxelements) { # Finding the agens
		if (@$syntaxelements[$i] eq undef){
		    	splice(@$syntaxelements,$i,1);
		}
		elsif (@$syntaxelements[$i]->{type} eq "word"){
			$i++;
		}
		else{
			($agentphrase,$splice)=findAgens(@$syntaxelements[$i]);
			if($agentphrase eq undef){
				$i++;
			}
			else{
				if($splice eq "spliced"){
					last;
				}
				else{
		    			splice(@$syntaxelements,$i,1);
					last;
				}
			}
		}
	}	
	if($agentphrase){
		my $k=0;
		while ($k<=$#$syntaxelements) { # Find the patiens
			if (@$syntaxelements[$k] eq undef){
		    		splice(@$syntaxelements,$k,1);
			}
			if ((@$syntaxelements[$k]->{function} eq "su") || (@$syntaxelements[$k]->{function} eq "sup")){
				$patiensphrase=@$syntaxelements[$k];
		    		splice(@$syntaxelements,$k,1);
				last;
			}
			else{
				$k++;
			}
		}
		my $l=0;
		while ($l<=$#$syntaxelements) { # Insert the agens at first position
			splice @$syntaxelements, 0, 0, $agentphrase;
			last;
		}
		my $n=0;
		if($patiensphrase){
			while ($n<=$#$syntaxelements) { # Insert the patiens behind the verb or verb phrase
				if (@$syntaxelements[$n]->{phrasetype} eq "vc"){
					my $nn=$n+1;
					splice @$syntaxelements, $nn, 0, $patiensphrase;
					last;
				}
				else{
					$n++;
				}
			}	
		}
		my $m=0;
		BREAK : {
			while ($m<=$#$syntaxelements){ 
				my $verbphrases=@$syntaxelements[$m]->{syntax};
				my $o=0;
				while ($o<=$#$verbphrases){ 
					if (@$verbphrases[$o]->{lemma} eq "worden"){
						splice(@$verbphrases,$o,1);
						last BREAK;
					}
					else{
						$o++;
					}
				}
				$m++;
			}
		}
	}
}

sub findAgens{
	my ($pkg)=@_;
	my $agentphrase;
	my $j=0;
	my $syntaxelements=$pkg->{syntax};
	while ($j<=$#$syntaxelements) {
		if (@$syntaxelements[$j]->{type} eq "word"){
			if (@$syntaxelements[$j]->{token} eq "door"){
				my $agens=@$syntaxelements[$j+1];
				return $agens;
			}
			else{
				$j++;
			}
		}
		else{
			($agentphrase,$splice)=findAgens(@$syntaxelements[$j]);
			if($agentphrase eq undef){
				$j++;
			}
			else{
				if($splice eq "spliced"){
 					return ($agentphrase,"spliced");
				}
				else{
					splice (@$syntaxelements,$j,1);
					return ($agentphrase,"spliced");
				}
			}		
		}
	}
}

sub compress{
    my ($pkg)=@_;
    my @compressedsentence;
    my $i;
    my $words=$pkg->{words};
    foreach $word(@$words){
	if (($word->{tag} =~ /^N.*/) || ($word->{tag} =~ /^WW.*/) || ($word->{tag} =~ /^VNW\(pers.*/) || ($word->{tag} =~ /^TW.*/) || ($word->{tag} =~ /^SPEC\(deel.*/)){
		push(@compressedsentence,$word);
	}
	elsif(($word->{function} eq "predc") || ($word->{token} eq "weinig")){
		push(@compressedsentence,$word);
	}
	elsif ($word->{tag} =~ /^ADJ.*/){
		if((($word->{tag} =~ /^ADJ.*/) && (@$words[$i-1]->{transitivity} eq "copula")) || (($word->{tag} =~ /^ADJ.*/) && (@$words[$i-2]->{transitivity} eq "copula"))){
			push(@compressedsentence,$word);
		}
	}
	$i++;
    }
    $pkg->{words}=[@compressedsentence];
    $flag;
}

sub buildWordObjects{
    my ($pkg)=@_;
    my @wordsarray;
    my $syntaxelements=$pkg->{syntax};
    foreach $syntaxelement(@$syntaxelements){
    	if ($syntaxelement->{type} eq "word"){
		if(($syntaxelement->{token} eq undef) || ($syntaxelement->{function} eq "dlink")){
			$flag;
		}
		else{
			push (@wordsarray,$syntaxelement);
		}
	}
	else{
		push(@wordsarray,getWords($syntaxelement));
	}
    }
    if(@wordsarray){
	    if(@wordsarray[-1]->{function} eq "crd"){
		delete @wordsarray[-1];
	    }
    }
    $pkg->{words}=[@wordsarray];
    delete $pkg->{syntax}; 
    return $pkg;
}

sub getWords{
    my ($pkg)=@_;
    if ($pkg->{type} eq "word"){
	if(($pkg->{token} eq undef) || ($syntaxelement->{function} eq "dlink")){
		return undef;
	}
	else{
		return $pkg;
	}
    }
    else{
        my @wordsarray;
	my $phraseelements=$pkg->{syntax};
	foreach $phraseelement(@$phraseelements){
		if(getWords($phraseelement) eq undef){
			$flag;
		}
		else{
			push(@wordsarray,getWords($phraseelement));
		}
	}
	return @wordsarray;
    }
}

sub addQuestionMark{
	my ($pkg)=@_;
	my $sentencetype=$pkg->{type};
	my $words=$pkg->{words};
	my $amountofwords=scalar(@$words);
	if (($sentencetype eq "sv1") || ($sentencetype eq "question")){
		my $questionmark=word->new(type,"word",
			target,$main::targetlanguage,
			lemma,"?",
			token,"?",
			tag,"LET()",
			indexnumber,undef,
			transitivity,undef,
			function,"--");
		splice @$words, $amountofwords, 0, $questionmark;
	}
}

sub addTimeRules{
	my ($pkg)=@_;
	my @verbarray;
	my $words=$pkg->{words};
	foreach(@$words){
		if(($_->{tag} =~ /WW\(pv/) || ($_->{tag} =~ /WW\(inf/) || ($_->{tag} =~ /WW\(vd/)) {
			push (@verbarray,$_);
		}
	}
	$pkg->{amountofverbs}=scalar @verbarray; 
	$pkg->applyVerbRules;
	return $pkg;
}

sub applyVerbRules{
	my ($pkg)=@_;
	my $amountofverbs=$pkg->{amountofverbs};
	if ($amountofverbs eq "1"){
		$pkg->applyOneVerbRules;
	}
	elsif($amountofverbs eq "2"){
		$pkg->applyTwoVerbsRules;
	}
	else{
		$pkg->applyThreeVerbsRules;
	}
	return $pkg;
}

sub applyOneVerbRules{
	my ($pkg)=@_;
	my $words=$pkg->{words};
	open (ONEVERBRULES,"$main::oneverbrules");
	FOO: {
		while (<ONEVERBRULES>) {
			chomp;
			($verb,$result)=split(/\t+-> /); 
			($tag,$verbnumber,$lemma)=split(/_/,$verb); 
			($time,$resultlemma)=split(/ /,$result); 
			foreach(@$words){ 
				if(($_->{tag} =~ /^$tag.*/) && (($_->{lemma} eq $lemma) || ($lemma eq "anyverb"))){ 
					$_->{timeindication}=$time;
					$_->{verbnumber}="L_$verbnumber"; 
					$pkg->{timeindication}=$time; 
					$pkg->{verborder}=$result;
					last FOO;
				}	
			}
		}
	}
	return $pkg;
}

sub applyTwoVerbsRules{
	my ($pkg)=@_;
	my $words=$pkg->{words};
	open (TWOVERBSRULES,"$main::twoverbsrules");
	FOO: {
	        while (<TWOVERBSRULES>) {
			chomp;
			($verbs,$result)=split(/\t+-> /); 
			($verb1,$verb2)=split(/ /,$verbs); 
			($tag1,$verbnumber1,$lemmas1)=split(/_/,$verb1); 
			($lemma1,$lemma2)=split(/\|/,$lemmas1);
			($tag2,$verbnumber2)=split(/_/,$verb2); 
			($time,@resultinglemmas)=split(/ /,$result); 
			foreach $word1(@$words){ 
				if(($word1->{tag} =~ /^$tag1.*/) && (($word1->{lemma} eq $lemma1) || ($word1->{lemma} eq $lemma2) || ($lemma1 eq "anyverb"))){ 
					foreach $word2(@$words){ 
						if($word2->{tag} =~ /^$tag2.*/){ 
							$word1->{timeindication}=$time; 
							$word2->{timeindication}=$time; 
							$word1->{verbnumber}="L_$verbnumber1";
							$word2->{verbnumber}="L_$verbnumber2"; 
							$pkg->{timeindication}=$time;
							$pkg->{verborder}=$result; 
							last FOO;
						}
					}
				}
			}
		}
	}
	return $pkg;
}

sub applyThreeVerbsRules{
	my ($pkg)=@_;
	my $words=$pkg->{words};
	open (THREEVERBSRULES,"$main::threeverbsrules");
	FOO: {
	        while (<THREEVERBSRULES>) {
			chomp;
			($verbs,$result)=split(/\t+-> /);
			($verb1,$verb2,$verb3)=split(/ /,$verbs);
			($tag1,$verbnumber1,$lemmas1)=split(/_/,$verb1); 
			(@lemmas1)=split(/\|/,$lemmas1);
			($tag2,$verbnumber2,$lemmas2)=split(/_/,$verb2); 
			(@lemmas2)=split(/\|/,$lemmas2);
			($tag3,$verbnumber3,$lemmas3)=split(/_/,$verb3); 	
			(@lemmas3)=split(/\|/,$lemmas3);
			($time,@resultinglemmas)=split(/ /,$result);
			foreach $word1(@$words){
				foreach $lemma1(@lemmas1){
					if(($word1->{tag} =~ /^$tag1.*/) && (($word1->{lemma} eq $lemma1) || ($lemma1 eq "anyverb"))){ 
						foreach $word2(@$words){ 
							foreach $lemma2(@lemmas2){
								if(($word2->{tag} =~ /^$tag2.*/) && (($word2->{lemma} eq $lemma2) || ($lemma2 eq "anyverb"))){ 
									foreach $word3(@$words){ 
										foreach $lemma3(@lemmas3){
											if(($word3->{tag} =~ /^$tag3.*/) && ($word3 ne $word2) &&(($word3->{lemma} eq $lemma3) || ($lemma3 eq "anyverb"))){ 
												$word1->{timeindication}=$time; 
												$word2->{timeindication}=$time; 
												$word3->{timeindication}=$time; 
												$word1->{verbnumber}="L_$verbnumber1"; 
												$word2->{verbnumber}="L_$verbnumber2"; 
												$word3->{verbnumber}="L_$verbnumber3"; 
												$pkg->{timeindication}=$time; 
												$pkg->{verborder}=$result; 
												last FOO;
											} 
										} 
									}
								}
							}
						}
					}
				}
			}
		} 
	}
	return $pkg;
}

sub changeVerbOrder{
        my ($pkg)=@_; # The order of the verbs will change depending on the right-hand side of the time rules (the result), and some verbs might even disappear
	@newwords=();	
	my $words=$pkg->{words};
	my @newwords2=();
	my $j = 0;
	for (my $j=0;$j<@$words;$j++) {
		if ($words->[$j]->{tag}=~/^WW\(pv.*/){
			push(@newwords2,$words->[$j]);	
			splice (@$words, $j, 1);
			$j++;
			my @afterPVwords=(); 
			foreach $afterPVword(@$words){
				if($afterPVword->{verbnumber} eq "2"){
					unshift(@afterPVwords,$afterPVword);
				}
				else{
					push(@afterPVwords,$afterPVword);		
				}
			}
			push(@newwords2, @afterPVwords);
			last;
		}
		else{
			push(@newwords2,$words->[$j]);		
			splice (@$words, $j, 1);
			$j--;
		}
	}
	$pkg->{words}=[@newwords2];
	my $words=$pkg->{words}; 
	my $verborder=$pkg->{verborder};
	my ($time,@verbs)=split(/ /,$verborder);
	foreach $word(@$words){
		if($word->{verbnumber}){
			$verbnumber=$word->{verbnumber};
			foreach $verbinorder(@verbs){
				if($verbnumber eq $verbinorder){
					push(@newwords,$word);
					last;
				}
				else{
					next;
				}
			}
		}
		else{
			push(@newwords,$word);
		}
	}
	$pkg->{words}=[@newwords];
}

sub generateTimePicto{
	my ($pkg)=@_;
	my @newwords;
	my $words=$pkg->{words};
	my $timeindication=$pkg->{timeindication};
	my $j;
	my $i;
	my $timecheck;
        my $temporalarray=join '|',@arrayoftemporalexpressions;
        my $referentialarray=join '|',@arrayofreferences;
        my $timearray=join '|',@arrayoftimeunits;
  	while ($i <= $#$words) { 
		if((@$words[$i]->{lemma}=~/($temporalarray)/) || ((@$words[$i]->{lemma}=~/($referentialarray)/) && (@$words[$i+1]->{lemma}=~/($timearray)/))){
			$timecheck="yes";	
			last;	
		}
		else{
			$i++;
		}
	}
	unless ($timecheck eq "yes"){
		while ($j <= $#$words) { 
			if(@$words[$j]->{tag} =~ /^WW.*/){
				if($timeindication eq "P"){
					    $timepicto=word->new(logfile,$pkg->{logfile},
	     					        target,$main::targetlanguage,
					   		token,'past_picto', 
		 			  		tag,'N(soort,ev,basis,zijd,stan)',
				 	  		lemma,'past_picto',
					  		wordnetdb,$pkg->{wordnetdb});
					    splice @$words, $j, 0, $timepicto;
					    last;
				}
				elsif($timeindication eq "F"){
					    $timepicto=word->new(logfile,$pkg->{logfile},
	      					        target,$main::targetlanguage,
					   		token,'future_picto', 
		 			  		tag,'N(soort,ev,basis,zijd,stan)',
				 	  		lemma,'future_picto',
					  		wordnetdb,$pkg->{wordnetdb});
					    splice @$words, $j, 0, $timepicto;
					    last;
				}	
				else{
					$j++;
				}		
			}
			else{
				$j++;
			}
		}
	}
	return $pkg;
}

1;
