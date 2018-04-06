####### simplify_cornetto.pm ##########

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

require "$Bin/simplifybackup.pm"; # The original cornetto.pm, activated when the simplification module is turned off, or when a time-out occurs during parsing

#---------------------------------------

our $stamp=time.$main::sessionid;

# Sentence analysis locations

$inputforalpino="$Bin/../tmp/alpino/inputforalpino";
$alpinoparsefile="$Bin/parse_file.sh";
$treebankoutput="$Bin/../AlpinoOutputDirectory$stamp";
$treebankoutputfile="$Bin/../AlpinoOutputDirectory$stamp/treebank.xml";

# Verb rules

$oneverbrules="$Bin/../data/Regels_V2_1ww.txt";
$twoverbsrules="$Bin/../data/Regels_V2_2ww.txt";
$threeverbsrules="$Bin/../data/Regels_V2_3ww.txt";

# First names lexicon

tie %FIRSTNAMES,"DB_File","$Bin/../../Picto2.0/data/firstnames.db"; 

#---------------------------------------
package message;
#---------------------------------------

sub taglemmatize {
    my ($pkg,$nospellcheck)=@_;
    my $alpino;
    $pkg->addFullStop; # Add a period
    $pkg->preProcess; # Remove emoji and deal with the "hoe gaat het" expressions, which generate one pictograph
    $pkg->createInputFileForAlpino; # Create input file for Alpino (one sentence per line)
    if($main::simplificationlevel eq "none"){ # The baseline system can still be activated
		 $pkg->tokenize; # Tokenization
		 $pkg->tag; # Tagging with Hunpos
		 $pkg->detectSentences; # Pictograph translation takes place on the sentence level
		 $pkg->findSeparableVerbs; # Rule-based separable verb detection
		 $pkg->lemmatize; # List-based and rule-based lemmatization
    }
    else{
	    $pkg->applyAlpino; # Alpino applies tagging, lemmatization, shows the dependencies, etc. We copy this structure in the form of (embedded) sentence objects and word objects
	    open (ALPINOOUTPUT,"$main::treebankoutputfile");
	    while($line=<ALPINOOUTPUT>){
		chomp $line;
		if ($line eq "TIMEOUT"){
			 $alpino="failed"; # If the parse takes too long, we will do shallow linguistic analysis instead
		}
	 	else{
			 $alpino="success";

		}
		if($alpino eq "success"){
		   	 $pkg->addSyntaxInfo; # We use Alpino's output to build a hierarchy of sentence and word objects
			 $pkg->simplify; # Take care of a number of syntactic constructions that need to be simplified
			 if($main::timeanalysis eq "on"){
				 $pkg->analyzeTime; # Add time pictographs for future and past and remove verbs that do not contribute to the message
			 }
			 $pkg->checkCompress; # Sentence compression
		}
		if(($alpino eq "failed") || ($pkg->{sentences} eq undef)){ # The baseline system activates when parsing takes too long
			 $pkg->tokenize; 
			 $pkg->tag; 
			 $pkg->detectSentences; 
			 $pkg->findSeparableVerbs; 
			 $pkg->lemmatize; 
		}
	    }
     }
    close ALPINOOUTPUT;
    `rm -f $main::treebankoutput/treebank.sents.*`;
    `rm -f $main::treebankoutput/inputfile*`;
    `rm -f $main::treebankoutput/logging`;
    `rm -f $main::treebankoutput/treebank.xml`;
    my $sentences=$pkg->{sentences};
}

sub preProcess{
    my ($pkg)=@_;
    my $words=$pkg->{text};
    my $words=lc($words);
    $words=~s/(.*)hoe gaat het met je(.*)/$1hoe_gaat_het$2/g;
    $words=~s/(.*)hoe gaat het met jou(.*)/$1hoe_gaat_het$2/g;
    $words=~s/(.*)hoe gaat het(.*)/$1hoe_gaat_het$2/g;
    $words=~s/(.*)hoe is het met je(.*)/$1hoe_gaat_het$2/g;
    $words=~s/(.*)hoe is het met jou(.*)/$1hoe_gaat_het$2/g;
    $words=~s/(.*)hoe is het(.*)/$1hoe_gaat_het$2/g;
    $words=~s/[^[:ascii:]]//g; 
    $pkg->{text}=$words;
}

sub createInputFileForAlpino {
    my ($pkg)=@_;
    my $message=$pkg->{text};
    open (ALPINOINPUT,">:utf8","$main::inputforalpino$stamp.txt");
    $message=~s/,/ ,/g;
    $message=~s/[\x{2018}\x{201A}\x{201B}\x{FF07}\x{2019}\x{60}]/'/g;
    $message=~s/([0-1]?[0-9]|2[0-3])[\.:]([0-5][0-9])?/$1/g;
    if ($message=~/^(hoi|hallo|hey|ey|allo|yo|goedemorgen|goedemiddag|goedendag|goeiendag|dag|ja|nee)\s*(juffrouw|juf|meester|meneer|mama|papa|iedereen|allemaal)*\s*[^\s]*\s[,]*/){
	 my ($match,$groet,$titel,$naam)=$message=~/(^(hoi|hallo|hey|ey|allo|yo|goedemorgen|goedemiddag|goedendag|goeiendag|dag|ja|nee)\s*(juffrouw|juf|meester|meneer|mama|papa|iedereen|allemaal)*\s*([^\s]*)\s[,]*)/;
	 if($titel && $naam){
	   	 if ((($main::FIRSTNAMES{ucfirst($naam)}) && ($naam ne "ik")) || (($main::FIRSTNAMES{$naam}) && ($naam ne "ik"))){
	     	    $message=~s/^($match)/$groet $titel\n/g;
		 }
	 }
	 elsif($naam){
	   	 if ((($main::FIRSTNAMES{ucfirst($naam)}) && ($naam ne "ik")) || (($main::FIRSTNAMES{$naam}) && ($naam ne "ik"))){
		 }
		 else{
	 	    $message=~s/^($groet)/$groet\n/g;
		 }
	 }
	 else{
	 	$message=~s/^($match)/$groet\n/g;
	 }
    } 
    if ($message=~/\s(groetjes|groeten|doei|daag|daaag|bye|ciao|x|xx|xxx|xxxx|xxxxx|xxxxxx|xxxxxxx).*$/){
	 my ($match,$groet)=$message=~/(\s(groetjes|groeten|doei|daag|daaag|bye|ciao).*)$/;
         $message=~s/($match)/\ngroetjes/g;
    }
    $message=~s/([\.\?!:;]+) /$groet/g;
    $message=~s/([\.\?!:;]+)/$groet\n/g;
    $message=~s/:/\./g;
    print ALPINOINPUT $message;
    chomp $message;
    $pkg->{text}=$message;
    close ALPINOINPUT;
}


sub applyAlpino{
    my($pkg)=@_;
    eval { 
	    local $SIG{ALRM} = sub { die "alarm\n" }; 
	    alarm 30; 
	    `$main::alpinoparsefile -t 40 $main::inputforalpino$stamp.txt $main::treebankoutput`; 
	    alarm 0; 
    }; 
    if ($@) { 
	    die unless $@ eq "alarm\n";
	    my $timeoutmessage="TIMEOUT";
	    open (OUTPUT,">$main::treebankoutputfile");
	    print OUTPUT $timeoutmessage;
	    close OUTPUT;
    } 
    else { 
	#    print "Alpino parse done.\n";
    }
    return $pkg;
}

sub addSyntaxInfo {
    my($pkg)=@_;
    my @newwordobjects;
    my @allsentences;
    my $tree=XML::Twig->new();
    $tree->parsefile($main::treebankoutputfile);
    my $root=$tree->root;
    my @alpino_ds=$root->children;
    foreach $alpino_ds(@alpino_ds){
	    my @mainclauses=$alpino_ds->descendants("node[\@cat=\"smain\" or \@rel=\"dp\" or \@rel=\"tag\"  or \@cat=\"sv1\"]"); # Main types of sentences (SMain, DP, SV1 sentences)
	    my @top=$alpino_ds->descendants("node[\@rel=\"top\"]"); # For every top, we check if we actually found a main type of sentence
	    foreach $top(@top){
	    	if($top->descendants("node[\@cat=\"smain\" or \@rel=\"dp\" or \@rel=\"tag\" or \@cat=\"sv1\"]")){
			$flag;
		}
		else{ # If this is not the case, we want to retain the non-sentence and just treat it as a main sentence, which could also contain a SSUB or another clause (Ex. "Dat ik de problemen aanpak zodat de volgende generaties het beter hebben")
			my @topchildren=$top->children;
			foreach $topchild(@topchildren){
				if($topchild->{'att'}->{'pt'} eq "let"){
					$flag;
				}
				else{
					push(@mainclauses,$topchild);
				}
			}
		}
	    }
    	    foreach $mainclause(@mainclauses){
			if($mainclause->descendants("node[\@cat=\"smain\" or \@rel=\"dp\" or \@rel=\"tag\" or \@cat=\"sv1\"]")){ # Some rare parses "erroneously" show an Smain inside a DP, in which case everything is doubled. We avoid this by checking if their descendants include a main type of sentence
				$flag;
			}
			else{
				if($mainclause->prev_sibling){ # There are some special types of main sentences, for which we will have to retain some extra information
					if($mainclause->prev_sibling->{'att'}->{'rel'} eq "whd"){ # First case: the sentence could be introduced by a question word
						my $sentence_object=buildQuestionSentence($mainclause);
						push(@allsentences,$sentence_object);				
					}
					else{ # Second case: the sentence could be missing its subject (conjunction with ellipsis)
						my $sentence_object=buildMainSentenceWithSubjectCheck($mainclause,$alpino_ds);
						push(@allsentences,$sentence_object);
					}			
				}
				elsif($mainclause->{'att'}->{'cat'} eq "sv1"){ # Third case: SV1s work like a normal main clause, but we need to indicate that it's an SV1 to add a question mark later
					my $sentence_object=buildMainSentence($mainclause);
					$sentence_object->{type}="sv1";				
					push(@allsentences,$sentence_object);		
				}
				else{ # Normal case for main clauses
					my $sentence_object=buildMainSentence($mainclause);
					push(@allsentences,$sentence_object);
				}
				if ($mainclause->descendants("node[\@cat=\"ssub\" or \@cat=\"ti\"]")){ # Inside a main clause, we might find a SSUB or OTI (SSUB can be regular SSUB, REL or question)
					my @clauses=$mainclause->descendants("node[\@cat=\"ssub\" or \@cat=\"ti\"]"); 
					my $parentclause;
				        foreach $clause(@clauses){ # This clause might be a conjunction, in which case the antecedent will have to be found at a higher level
						if(($clause->prev_sibling) && ($clause->{'att'}->{'rel'} eq "cnj")){
							$parentclause=$clause->parent;
						}
						elsif($clause->prev_sibling){
							$parentclause=$clause;
						}
						else{
							$parentclause=$clause->parent;
						}
						if($parentclause->prev_sibling->{'att'}->{'postag'}=~/VNW\(betr.*/){
							my $subsentence_object=buildRelSentence($clause);  # First case: RELP is a SSUB with a relative pronoun, so check the sibling
							push(@allsentences,$subsentence_object);
						}
						elsif($parentclause->prev_sibling->{'att'}->{'rel'} eq "whd") { 
							my $subsentence_object=buildQuestionSentence($clause); # Second case: the clause could be introduced by a question word
							push(@allsentences,$subsentence_object);				
						}
						elsif($clause->{'att'}->{'cat'} eq "ti"){
							my $subsentence_object=buildOTISentence($clause,$mainclause); # Third case: the clause could be an OTI sentence			
							push(@allsentences,$subsentence_object);
						}
						else{
							my $grandparentclause;
							my $subsentence_object=buildSSUBSentence($clause,$mainclause);
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
							if($grandparentclause->prev_sibling){
								$clauseword=$grandparentclause->prev_sibling->{'att'}->{'lemma'}; # Determine the clause word so we know whether we need to unshift or push the sentence
								if(($clauseword eq "nadat") || ($clauseword eq "na") || ($clauseword eq "zodra") || ($clauseword eq "toen") || ($clauseword eq "wanneer") || ($clauseword eq "al") || ($clauseword eq "hoewel") || ($clauseword eq "ofschoon") || ($clauseword eq "hoezeer")){ # Determines order of SSUB 
									unshift(@allsentences,$subsentence_object);
								}						
								else{				
									push(@allsentences,$subsentence_object);
								}
							}
							else{
								push(@allsentences,$subsentence_object);
							}
						}					
					}
				}
				elsif ($mainclause->descendants("node[\@cat=\"whsub\"]")){ # WHSUB without SSUB (Ex. "Maar wat dan met de doelstelling voor hernieuwbare energie?")
					@clauses=$mainclause->descendants("node[\@cat=\"whsub\"]"); 	
					foreach $clause(@clauses){
						my $subsentence_object=buildQuestionSentence($clause);
						push(@allsentences,$subsentence_object);	
					}								
				}
				if ($mainclause->descendants("node[\@rel=\"app\"]")){ # Appositions
					@clauses=$mainclause->descendants("node[\@rel=\"app\"]"); 
				        foreach $clause(@clauses){
						my $subsentence_object=buildAppSentence($clause);
						push(@allsentences,$subsentence_object);	
					}
				}
				if ($mainclause->descendants("node[\@cat=\"ppres\"]")){ # Adverbial modifiers
					@clauses=$mainclause->descendants("node[\@cat=\"ppres\"]"); 
				        foreach $clause(@clauses){
			    	         	my $subsentence_object=buildPPRESSentence($clause,$mainclause);
						push(@allsentences,$subsentence_object);	
					}
				}
			}
   	$pkg->{sentences}=[@allsentences];    
    } }
   `rm -f $main::inputforalpino$stamp.txt`;
   return $pkg;
}

sub buildQuestionSentence{
	my ($mainclause)=@_;
	my @syntax;
	my $sentence_object=sentence->new(type,"question"); 	
	$sentence_object->{questionword}=fetchQuestionWord($mainclause); # Find the question word
	@syntax=buildSyntacticClauseObjects($mainclause); 
	$sentence_object->{syntax}=[@syntax];
	return $sentence_object;
}

sub fetchQuestionWord{
   my ($clause)=@_;
   my $sibling=$clause->prev_sibling;
   my $word_object=word->new(type,"word",
	       target,$main::targetlanguage,
	       lemma,$sibling->{'att'}->{'lemma'},
	       token,$sibling->{'att'}->{'word'},
	       tag,$sibling->{'att'}->{'postag'},
	       indexnumber,$sibling->{'att'}->{'index'},
	       transitivity,$sibling->{'att'}->{'sc'},
               function,$sibling->{'att'}->{'rel'});	
   return $word_object;
}

sub buildMainSentenceWithSubjectCheck{
	my ($mainclause,$root)=@_;
	my @syntax;
	my $sentence_object=sentence->new(type,"main"); 
	@syntax=buildSyntacticClauseObjects($mainclause);
	$sentence_object->{syntax}=[@syntax];
	my $allsyntaxobjects=$sentence_object->{syntax};
	my $index;	
	foreach $syntaxobject(@$allsyntaxobjects){
		if($syntaxobject->{type} eq "word"){
			if((($syntaxobject->{function} eq "su") || ($syntaxobject->{function} eq "sup")) && ($syntaxobject->{token} eq undef)){ # Check if the sentence already has its own non-dummy subject
				$index=$syntaxobject->{indexnumber}; # The dummy subject, which is undefined and has an index, allows us to find the non-dummy subject
			}
		}
	}
	if($index){
		my @referees=$root->descendants("node[\@index=\"$index\"]");
		my $referee=@referees[0]; 
		my $head;
		if($referee->descendants){
			my @heads=$referee->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]"); # The subject can be a noun/pronoun with a head function, or a proper name. We choose not to display the complete NP but only the head
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
					  function,$head->{'att'}->{'rel'});
		$sentence_object->{functionofantecedent}="su";					
		$sentence_object->{antecedent}=$head_object;					
	}
	return $sentence_object;
}

sub buildMainSentence{
	my ($mainclause)=@_;
	my @syntax;
	my $sentence_object=sentence->new(type,"main");			
	@syntax=buildSyntacticClauseObjects($mainclause); 
	$sentence_object->{syntax}=[@syntax];
	return $sentence_object;
}

sub buildRelSentence{
	my ($clause)=@_;
	my @syntax;
	my $subsentence_object=sentence->new;
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
	$subsentence_object->{antecedent}=fetchAntecedent($clause); # We will retain the antecedent of the RELP and its function (subject, obj1, obj2)
	@syntax=buildSyntacticClauseObjects($clause); 
	$subsentence_object->{syntax}=[@syntax];
	return $subsentence_object;
}

sub fetchAntecedent{ # Antecedent (head) search for relative clauses. The antecedent is in front of the relative clause
   my ($clause)=@_;
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
	if ($grandparent->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]")){  # The subject can be a noun/pronoun with a head function, or a proper name. We choose not to display the complete NP but only the head
		@descendants=$grandparent->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]"); 
		$descendant=@descendants[0];
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
				       function,$descendant->{'att'}->{'rel'});
		return $word_object;
	}
}

sub buildOTISentence{
	my ($clause,$mainclause)=@_;
	my @syntax;
	my $subsentence_object=sentence->new(type,"oti"); 
	@syntax=buildSyntacticClauseObjects($clause);
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
				my @heads=$referee->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]"); # The subject can be a noun/pronoun with a head function, or a proper name. We choose not to display the complete NP but only the head
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
		my $head_object=word->new(type,"word",
	 	                          target,$main::targetlanguage,
					  lemma,$lemma,
					  token,$head->{'att'}->{'word'},
					  tag,$head->{'att'}->{'postag'},
					  indexnumber,$head->{'att'}->{'index'},
					  transitivity,$head->{'att'}->{'sc'},
					  function,$head->{'att'}->{'rel'});
		$subsentence_object->{functionofantecedent}="su";					
		$subsentence_object->{antecedent}=$head_object;	
	}
	return $subsentence_object;
}

sub buildSSUBSentence{
	my ($clause,$mainclause)=@_;
	my @syntax;
 	my $subsentence_object=sentence->new; 
	my $type=$clause->{'att'}->{'cat'}; # Regular SSUB
	$subsentence_object->{type}="ssub";
	@syntax=buildSyntacticClauseObjects($clause);
	$subsentence_object->{syntax}=[@syntax];
	my $allsyntaxobjects=$subsentence_object->{syntax};
	my $index;	
	foreach $syntaxobject(@$allsyntaxobjects){
		if($syntaxobject->{type} eq "word"){
			if((($syntaxobject->{function} eq "su") || ($syntaxobject->{function} eq "sup")) && ($syntaxobject->{token} eq undef)){ # Check if the sentence already has its own non-dummy subject
				$index=$syntaxobject->{indexnumber}; # The dummy subject, which is undefined and has an index, allows us to find the non-dummy subject
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
					  function,$head->{'att'}->{'rel'});
		$subsentence_object->{functionofantecedent}="su";					
		$subsentence_object->{antecedent}=$head_object;					
	}
	return $subsentence_object;
}

sub buildAppSentence{
	my ($pkg)=@_;
 	my $subsentence_object=sentence->new; 
	$subsentence_object->{type}="app";
	$subsentence_object->{antecedent}=fetchAppositionAntecedent($clause); # Antecedent search for apposition
	@syntax=buildSyntacticClauseObjects($clause); 
	$subsentence_object->{syntax}=[@syntax];
	return $subsentence_object;
}

sub fetchAppositionAntecedent{ 
   my ($clause)=@_;
   my $parent=$clause->parent;
   my @siblings=$parent->children; 
   my $descendant;
   foreach $sibling(@siblings){
	if (($sibling->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]") || (($sibling->{'att'}->{'rel'} eq "hd") && (($sibling->{'att'}->{'pt'} eq "n") || ($sibling->{'att'}->{'pos'} eq "name"))))){  # The antecedent can be a noun/pronoun with a head function, or a proper name. We choose not to display the complete NP but only the head
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
				       function,$descendant->{'att'}->{'rel'});
		return $word_object;
	}
   }
}

sub buildPPRESSentence{
	my ($clause,$mainclause)=@_;
	my $subsentence_object=sentence->new;
	$subsentence_object->{type}="ppres";
	my @referees=$mainclause->descendants("node[\@rel=\"su\"]");
	my $referee=@referees[0];
	my $head;
	if($referee->descendants){
		my @heads=$referee->descendants("node[\(\@rel=\"hd\" and \@pt=\"n\"\) or \(\@rel=\"mwp\" and \@pt=\"n\"\) or \(\@pos=\"name\"\)]");  # The antecedent can be a noun/pronoun with a head function, or a proper name. We choose not to display the complete NP but only the head
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
				  function,$head->{'att'}->{'rel'});
	$subsentence_object->{antecedent}=$head_object;		
	@syntax=buildSyntacticClauseObjects($clause); 
	$subsentence_object->{syntax}=[@syntax];
	return $subsentence_object;
}

sub buildSyntacticClauseObjects{ # There are both words (terminals) and phrases (non-terminals), in which case a recursive function will be called
   my ($clause)=@_;
   my @syntax;
   if($clause->children){
	   my @children=$clause->children;
	   foreach $child(@children){
	  	my @phrasearray;
	   	if ($child->children<1) {
			if(($child->{'att'}->{'rel'} eq "svp") || ($child->{'att'}->{'rel'} eq "cmp") || ($child->{'att'}->{'rel'} eq "dlink")){
				next;
			}
			else{
				my $lemma=$child->{'att'}->{'lemma'};
				if($lemma eq "hoe_gaat_het"){
				}
				else{
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
						       function,$child->{'att'}->{'rel'});
				push(@syntax,$word_object);
			}
		}
		else{
			if(($child->{'att'}->{'cat'} eq "oti") || ($child->{'att'}->{'cat'} eq "ti") || ($child->{'att'}->{'cat'} eq "rel") || ($child->{'att'}->{'cat'} eq "ssub") || ($child->{'att'}->{'rel'} eq "dp")  || ($child->{'att'}->{'cat'} eq "ppres") || ($child->{'att'}->{'rel'} eq "app") || ($child->{'att'}->{'cat'} eq "du") || ($child->{'att'}->{'cat'} eq "smain") || ($child->{'att'}->{'cat'} eq "whq") || ($child->{'att'}->{'cat'} eq "sv1") || ($child->{'att'}->{'cat'} eq "whsub") || ($child->{'att'}->{'cat'} eq "whrel")){ # We do this in order to avoid processing these clauses multiple times (because they're part of another clause)
				$flag;
			}
			else{
				my $phrase_object=phrase->new(type,"phrase",
		      					   indexnumber,$child->{'att'}->{'index'},
							   phrasetype,$child->{'att'}->{'cat'},
							   function,$child->{'att'}->{'rel'});
				my @childrenofchild=$child->children;
				foreach $childofchild(@childrenofchild){
					if(($childofchild->{'att'}->{'cat'} eq "oti") || ($childofchild->{'att'}->{'cat'} eq "ti") || ($childofchild->{'att'}->{'cat'} eq "rel") || ($childofchild->{'att'}->{'cat'} eq "ssub") || ($childofchild->{'att'}->{'cat'} eq "oti") || ($childofchild->{'att'}->{'rel'} eq "dp") || ($childofchild->{'att'}->{'cat'} eq "ppres") || ($childofchild->{'att'}->{'rel'} eq "app") || ($childofchild->{'att'}->{'cat'} eq "du") || ($childofchild->{'att'}->{'cat'} eq "smain") || ($childofchild->{'att'}->{'cat'} eq "whq") || ($childofchild->{'att'}->{'cat'} eq "sv1") || ($childofchild->{'att'}->{'cat'} eq "whsub") || ($childofchild->{'att'}->{'cat'} eq "whrel")){
						$flag;
					}
					else{
						push(@phrasearray,buildSyntacticPhraseObjects($childofchild)); # Apply the recursive function until all words are found
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
		if($lemma eq "hoe_gaat_het"){
	        }
		else{
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
			       function,$clause->{'att'}->{'rel'});
		push(@syntax,$word_object);
	        return @syntax;
	}
}

sub buildSyntacticPhraseObjects{
   my ($child)=@_;
   my @syntax;
   my @phrasearray;
   if ($child->children<1) {
		if(($child->{'att'}->{'rel'} eq "svp") || ($child->{'att'}->{'rel'} eq "cmp") || ($child->{'att'}->{'rel'} eq "dlink")){
			next;
		}
		else{
			my $lemma=$child->{'att'}->{'lemma'};
			if($lemma eq "hoe_gaat_het"){
			}
			else{
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
				        function,$child->{'att'}->{'rel'});
		return $word_object;
		}
   }
   else{
		if(($child->{'att'}->{'cat'} eq "oti") || ($child->{'att'}->{'cat'} eq "ti") || ($child->{'att'}->{'cat'} eq "rel") || ($child->{'att'}->{'cat'} eq "ssub") || ($child->{'att'}->{'rel'} eq "dp")  || ($child->{'att'}->{'cat'} eq "ppres") || ($child->{'att'}->{'rel'} eq "app") || ($child->{'att'}->{'cat'} eq "du") || ($child->{'att'}->{'cat'} eq "smain") || ($child->{'att'}->{'cat'} eq "whq") || ($child->{'att'}->{'cat'} eq "sv1") || ($child->{'att'}->{'cat'} eq "whsub") || ($child->{'att'}->{'cat'} eq "whrel")){ # We do this in order to avoid processing these clauses multiple times (because they're part of another clause)
		$flag;
	}
	else{	
		my $phrase_object=phrase->new(type,"phrase",
	     				      indexnumber,$child->{'att'}->{'index'},
					      phrasetype,$child->{'att'}->{'cat'},	
			        	      function,$child->{'att'}->{'rel'});
		my @childrenofchild=$child->children;
		foreach $childofchild(@childrenofchild){
				if(($childofchild->{'att'}->{'cat'} eq "rel") || ($childofchild->{'att'}->{'cat'} eq "ti") ||($childofchild->{'att'}->{'cat'} eq "ssub") || ($childofchild->{'att'}->{'cat'} eq "oti") || ($childofchild->{'att'}->{'rel'} eq "dp") || ($childofchild->{'att'}->{'cat'} eq "ppres") || ($childofchild->{'att'}->{'rel'} eq "app") || ($childofchild->{'att'}->{'cat'} eq "du") || ($childofchild->{'att'}->{'cat'} eq "smain") || ($childofchild->{'att'}->{'cat'} eq "whq") || ($childofchild->{'att'}->{'cat'} eq "sv1") || ($childofchild->{'att'}->{'cat'} eq "whsub") || ($childofchild->{'att'}->{'cat'} eq "whrel")){
					$flag;
				}
				else{
					push(@phrasearray,buildSyntacticPhraseObjects($childofchild));
				}
		}
		$phrase_object->{syntax}=[@phrasearray];
		return $phrase_object;
	}
   }
}

sub simplify{
    my ($pkg)=@_;
    my $sentences=$pkg->{sentences};  
    my $i=0;
    while($i <= $#$sentences){
	@$sentences[$i]->movePPsToBack; # PPs and adverbs at the beginning of the sentence (in front of subject) are moved to the back of the sentence
	@$sentences[$i]->checkForPassives; # Check if the sentence is a passive sentence and indicate this as one of the sentence's features
	@$sentences[$i]->addPolarity; # Give words a polarity feature if a negative is found
	@$sentences[$i]->changeOrder; # Move verbs, subjects, and antecedents to obtain an active SVO order
	@$sentences[$i]->buildWordObjects; # Flatten the word object structure for picto operations
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

sub analyzeTime{
    my ($pkg)=@_;
    my $sentences=$pkg->{sentences}; 
    foreach $sentence(@$sentences){
	$sentence->addTimeRules; # Apply the time rules to determine temporality and whether all verbs should be retained and in what order
	$sentence->changeVerbOrder; # Determine verb order and remove verbs that do not contribute to the meaning of the message
	$sentence->generateTimePicto; # This will generate a picto for future or past
    }
}

sub checkCompress{
    my ($pkg)=@_;
    my $sentences=$pkg->{sentences};  
    my $i=0;
    if($main::simplificationlevel eq "compress"){
   	 while($i <= $#$sentences){
		@$sentences[$i]->compress; # We only display the heads
		$i++;
	 }
    }
}

#---------------------------------------
package sentence;
#---------------------------------------

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
	while ($i <= $#$syntaxelements) { 
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
	if($pkg->{mode} eq "passive"){
		$flag;	
	}
	else{
		$pkg->{mode}="active";
	}
	return $pkg;
}

sub checkPhraseForPassives{
	my ($pkg)=@_;
	my $phraseelements=$pkg->{syntax};
	my $j=0;
	while ($j <= $#$phraseelements) {
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

sub addPolarity{
        my ($pkg)=@_;
	my $syntaxelements=$pkg->{syntax};
	my $i=0;
	while ($i <= $#$syntaxelements) {
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
			addPolarity(@$syntaxelements[$i]);
			$i++;
		}
	}
   return $pkg;
}

sub changeOrder{
	my($pkg)=@_;
	$pkg->findAllVerbs; # Find all verbs, cut them from tree (wherever they are)
	if (($pkg->{type} eq "ssub") || ($pkg->{type} eq "main") || ($pkg->{type} eq "oti")){
		$pkg->moveMainAndSSUBVerbs; # In these situations, there is already a subject - the verbs need to be moved behind the subject
	}
	elsif((($pkg->{type} eq "rel") && ($pkg->{functionofantecedent} eq "obj1")) || (($pkg->{type} eq "rel") && ($pkg->{functionofantecedent} eq "obj2"))){
		$pkg->moveRelObjectVerbs; # In these situations, there is already a subject - the verbs need to be moved behind the subject. We also need to add the object 
	}
	elsif(((($pkg->{type} eq "rel") && (($pkg->{functionofantecedent} eq "su") || ($pkg->{functionofantecedent} eq "sup"))) || ($pkg->{type} eq "ppres"))){
		$pkg->moveRelSubjectVerbs; # In these situations, the subject must be moved to the first position
	}
        elsif($pkg->{type} eq "app"){
		$pkg->createAppositionSentences; # In appositions, we add the antecedent and "to be" to the front
	}
	elsif(($pkg->{type} eq "question") || ($pkg->{type} eq "sv1")){
		$pkg->moveQuestionVerbs; # In these situations, move the verbs behind the question word and the subject (question word - SVO)
	}
	if($pkg->{mode} eq "passive"){
		$pkg->makeActive; # Make passive sentences active when "door" is found
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
				$flag;
				$i++;
			}
		}
		else{
			my $j=0;
			my $syntaxelementsofsyntaxelement=@$syntaxelements[$i]->{syntax};
			while ($j <= $#$syntaxelementsofsyntaxelement) {
				$findallverbsinphrase=findAllVerbsInPhrase(@$syntaxelementsofsyntaxelement[$j]);
				if($findallverbsinphrase eq undef){
					$flag;
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
	else{
		$flag;
	}
    }
    else{
	my $k=0;
	my $phraseelements=$pkg->{syntax};
	while ($k <= $#$phraseelements) {
			my $findallverbsinphrase=findAllVerbsInPhrase(@$phraseelements[$k]);
			if($findallverbsinphrase eq undef){
				$flag; 
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
	else{
		$flag;
	}
    }
}

sub flatten{map{ref $_ eq 'ARRAY' ? flatten(@$_):$_} @_}

sub moveMainAndSSUBVerbs{
	my ($pkg)=@_; 
	if($pkg->{antecedent}){
		$pkg->addSubjectToFront;
	}
	$pkg->moveAllVerbsBehindSubject;
}

sub moveRelObjectVerbs{
	my ($pkg)=@_; 
	$pkg->moveAllVerbsBehindSubject;
	$pkg->addObjectBehindVerbs;
}

sub moveRelSubjectVerbs{
	my ($pkg)=@_; 
	$pkg->moveAllVerbsToFront;
	$pkg->addSubjectToFront;
}

sub createAppositionSentences{
	my ($pkg)=@_;
	$pkg->addToBeInFront;
	$pkg->addSubjectToFront;
}

sub moveQuestionVerbs{
	my ($pkg)=@_; 
	$pkg->moveAllVerbsBehindSubject;
	$pkg->addQuestionWordToFront;
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

sub addObjectBehindVerbs{ 
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

sub addSubjectToFront{
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

sub addQuestionWordToFront{
	my ($pkg)=@_;
	my $questionword=$pkg->{questionword};
	my $syntaxelements=$pkg->{syntax};
	splice @$syntaxelements, 0, 0, $questionword;
	delete $pkg->{questionword};
	return $pkg;
}

sub addToBeInFront{
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
	while ($i <= $#$syntaxelements) { # Finding the agens
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
		while ($k <= $#$syntaxelements) { # Finding the patiens
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
		while ($l <= $#$syntaxelements) { # Inserting the agens at first position
			splice @$syntaxelements, 0, 0, $agentphrase;
			last;
		}
		my $n=0;
		if($patiensphrase){
			while ($n <= $#$syntaxelements) { # Inserting the patiens behind the verb or verb phrase
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
			while ($m <= $#$syntaxelements){ 
				my $verbphrases=@$syntaxelements[$m]->{syntax};
				my $o=0;
				while ($o <= $#$verbphrases){ 
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
	while ($j <= $#$syntaxelements) {
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
	$pkg->{amountofverbs}=scalar @verbarray; # We count the amount of verbs inside the clause, depending on that, we apply a different rule set
	$pkg->applyVerbRules;
	return $pkg;
}

sub applyVerbRules{
	my ($pkg)=@_;
	my $words=$pkg->{words};
	my $amountofverbs=$pkg->{amountofverbs};
	if ($amountofverbs eq "1"){
		open (ONEVERBRULES,"$main::oneverbrules");
			FOO: {
	        while (<ONEVERBRULES>) {
			chomp;
			($verb,$result)=split(/\t+-> /); # Split left side (condition) and right side (result) from arrow
			($tag,$verbnumber,$lemma)=split(/_/,$verb); # The verb has a tag, order number (that is always 1 if you only have 1 verb) and a lemma ("anyverb" or a specific lemma)
			($time,$resultlemma)=split(/ /,$result); # The result will be a time label and a lemma
			foreach(@$words){ # Now we must check if the tag and the lemma combination appears in our verb objects
				if(($_->{tag} =~ /^$tag.*/) && (($_->{lemma} eq $lemma) || ($lemma eq "anyverb"))){ # So we found a match
					$_->{timeindication}=$time;
					$_->{verbnumber}="L_$verbnumber"; # Number of the verb (in this case always 1)
					$pkg->{timeindication}=$time; # Add time indication for the clause, as well
					$pkg->{verborder}=$result; # The whole rule (the right-hand side of the condition) will be stored as well, so we can change verb order later
					last FOO;
				}	
			}
			}
		}
	}
	elsif($amountofverbs eq "2"){
		open (TWOVERBSRULES,"$main::twoverbsrules");
			FOO: {
	        while (<TWOVERBSRULES>) {
			chomp;
			($verbs,$result)=split(/\t+-> /); # Split left side (condition) and right side (result) from arrow
			($verb1,$verb2)=split(/ /,$verbs); # Split the two verbs
			($tag1,$verbnumber1,$lemmas1)=split(/_/,$verb1); # The main verb has a tag, order number and a lemma ("anyverb" or a specific lemma)
			($lemma1,$lemma2)=split(/\|/,$lemmas1);
			($tag2,$verbnumber2)=split(/_/,$verb2); # The second verb has a tag and an order number
			($time,@resultinglemmas)=split(/ /,$result); # The result will be a time label and one or two lemma
			foreach $word1(@$words){ # Now we must check if the tag and the lemma combinations appear in our verb objects
				if(($word1->{tag} =~ /^$tag1.*/) && (($word1->{lemma} eq $lemma1) || ($word1->{lemma} eq $lemma2) || ($lemma1 eq "anyverb"))){ # So we found a match
					foreach $word2(@$words){ # Check if there is a match with the second verb
						if($word2->{tag} =~ /^$tag2.*/){ 
							$word1->{timeindication}=$time; 
							$word2->{timeindication}=$time; 
							$word1->{verbnumber}="L_$verbnumber1"; # Number of the main verb 
							$word2->{verbnumber}="L_$verbnumber2"; # Number of the second verb
							$pkg->{timeindication}=$time; # Add time indication for the clause, as well
							$pkg->{verborder}=$result; # The whole rule (the right-hand side of the condition) will be stored as well, so we can change verb order later
							last FOO;
						}
					}
				}
				}
			}
		}
	}
	else{
		open (THREEVERBSRULES,"$main::threeverbsrules");
			FOO: {
	        while (<THREEVERBSRULES>) {
			chomp;
			($verbs,$result)=split(/\t+-> /); # Split left side (condition) and right side (result) from arrow
			($verb1,$verb2,$verb3)=split(/ /,$verbs); # Split the three verbs
			($tag1,$verbnumber1,$lemmas1)=split(/_/,$verb1); # The main verb has a tag, order number and a lemma ("anyverb" or a specific lemma)
			(@lemmas1)=split(/\|/,$lemmas1);
			($tag2,$verbnumber2,$lemmas2)=split(/_/,$verb2); # The second verb has a tag and an order number and a lemma ("anyverb" or a specific lemma)
			(@lemmas2)=split(/\|/,$lemmas2);
			($tag3,$verbnumber3,$lemmas3)=split(/_/,$verb3); # The third verb has a tag and an order number and a lemma ("anyverb" or a specific lemma)	
			(@lemmas3)=split(/\|/,$lemmas3);
			($time,@resultinglemmas)=split(/ /,$result); # The result will be a time label and one or multiple lemma
			foreach $word1(@$words){ # Now we must check if the tag and the lemma combinations appear in our verb objects
				foreach $lemma1(@lemmas1){
					if(($word1->{tag} =~ /^$tag1.*/) && (($word1->{lemma} eq $lemma1) || ($lemma1 eq "anyverb"))){ # So we found a match
						foreach $word2(@$words){ # Check if there is a match with the second verb
							foreach $lemma2(@lemmas2){
								if(($word2->{tag} =~ /^$tag2.*/) && (($word2->{lemma} eq $lemma2) || ($lemma2 eq "anyverb"))){ 
									foreach $word3(@$words){ # Check if there is a match with the third verb
										foreach $lemma3(@lemmas3){
											if(($word3->{tag} =~ /^$tag3.*/) && ($word3 ne $word2) &&(($word3->{lemma} eq $lemma3) || ($lemma3 eq "anyverb"))){ 
												$word1->{timeindication}=$time; 
												$word2->{timeindication}=$time; 
												$word3->{timeindication}=$time; 
												$word1->{verbnumber}="L_$verbnumber1"; # Number of the main verb 
												$word2->{verbnumber}="L_$verbnumber2"; # Number of the second verb
												$word3->{verbnumber}="L_$verbnumber3"; # Number of the third verb
												$pkg->{timeindication}=$time; # Add time indication for the clause, as well
												$pkg->{verborder}=$result; # The whole rule (the right-hand side of the condition) will be stored as
															   # well, so we can change verb order later
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
		} }
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
	while ($i <= $#$words) { 
		if((@$words[$i]->{lemma} eq "eergisteren") || (@$words[$i]->{lemma} eq "gisteren") || (@$words[$i]->{lemma} eq "morgen") || (@$words[$i]->{lemma} eq "overmorgen")){
			$timecheck="yes";	
			last;	
		}
		elsif(((@$words[$i]->{lemma} eq "volgen") &&  ((@$words[$i+1]->{lemma} eq "week") || (@$words[$i+1]->{lemma} eq "jaar") || (@$words[$i+1]->{lemma} eq "maand"))) || ((@$words[$i]->{lemma} eq "vorig") &&  ((@$words[$i+1]->{lemma} eq "week") || (@$words[$i+1]->{lemma} eq "jaar") || (@$words[$i+1]->{lemma} eq "maand")))){
			$timecheck="yes";	
			last;	
		}
		else{
			$i++;
		}
	}
	if ($timecheck eq "yes"){
		$flag;
	}
	else{
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
