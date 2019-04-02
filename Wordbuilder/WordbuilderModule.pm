######################################################
#
# Wordbuilder module
#
######################################################
#
# Programmed by Vincent Vandeghinste
# Centrum voor Computerlinguistiek
# K.U.Leuven
#
######################################################
1;
# version 4.0
# updated for perl 5.8
#
######################################################
#
# call this module using 
# @results=&wordbuilder(@input);
# with @input being an array with each element being a word part
# and @results being an array of Node objects with the following
# structure:
# Node=HASH(0x83acc40)
#   'cgn' => 1
#   'diffmods' => 124
#   'headfreq' => 4944
#   'modfreq' => 337
#   'parts' => 2
#   'prob' => 0.048903708591238
#   'rf' => 1
#   'tag' => 'N(soort,ev,basis,onz,stan)
#'
#   'word' => 'arbeidsbureau'
#
# you can access any of these fields by calling e.g.
# $word=$node->get_word();
#
# so add get_ before the fieldname and you've got the accessor

## MAIN PROGRAM

use DB_File;

sub wordbuilder {
    &file_opener;
    my @input=@_;
    $nr_of_input_parts=@input;
    my ($ref_nodes,@results)=&calculate_results(@input);
    @results=&show_results($ref_nodes,@results);
    return @results;
}

#######################################################

sub file_opener {
    tie %CGN,"DB_File","/home/pricie/vincent/Lingware/Data/Lexical/DB/CGN_for_WB.db"; 
    tie %NONC,"DB_File","/home/pricie/vincent/Lingware/Data/Lexical/DB/noncompound.db"; 
    tie %QUASI,"DB_File","/home/pricie/vincent/Lingware/Data/Lexical/DB/quasi.db"; 
    tie %RF,"DB_File","/home/pricie/vincent/Lingware/Data/Lexical/DB/relfreq8.3.db"; 
    tie %MODHEAD,"DB_File","/home/pricie/vincent/Lingware/Data/Lexical/DB/ModHead.freqs.db"; 
    tie %TOTALFREQS,"DB_File","/home/pricie/vincent/Lingware/Data/Lexical/DB/total.freqs.db"; 
    tie %DIFMODS,"DB_File","/home/pricie/vincent/Lingware/Data/Lexical/DB/DifModsPerHead.db"; 
	require "/home/paco/web/picto/script/Wordbuilder/Node.pm";
    #$problimit=0.001;
    @posarray=('N','ADJ','VZ','WW','VNW','TSW','BW','TW','LID','VG');
    #$rflimit=0.05;
    $nr_of_comps=79862581;
}

sub calculate_results {
    my @parts=@_;
    my @nodes=&create_nodes(@parts);
    my @results=&try_compounding(@nodes);
    my $ref_nodes=&create_ref(@nodes);
    ($ref_nodes,@results);
}

sub create_nodes {
    my @parts=@_;
    local $part,@partlist;
    @partlist=();
    foreach $part (@parts) {
	push(@partlist,&find_part($part));
    }
    @partlist;
}

sub find_part {
    my $part=$_[0];
    local @partnodes,$tagfreq;
    my @tags=find_in_lexica($part);
    if (@tags==1) {
	($relfreq,$headfreq,$modfreq,$diffmods)=&find_freq($part,$tags[0]);
	unless ($relfreq) {
	    $relfreq=1;
	}
	push(@partnodes,Node->new($part,$tags[0],$relfreq,$headfreq,$modfreq,1,$diffmods));
    }
    else {
	foreach $tag (@tags) {
	    if ($tag eq 'QUASI') {
		$tagfreq=1;
		$headfreq=0;
		$modfreq=1;
	    }
	    else {
		($tagfreq,$headfreq,$modfreq,$diffmods)=&find_freq($part,$tag);
	    }
	    push(@partnodes,Node->new($part,$tag,$tagfreq,$headfreq,$modfreq,1,$diffmods));
	}
    }
    \@partnodes;
}

sub find_in_lexica {
    my $part=$_[0];
    my @tags,$pos,$key,$tag;
    if ($NONC{$part}) {
	foreach $pos (@posarray) {
	    $key="$part $pos";
	    $tag=$CGN{$key};
	    if ($tag) {
		push(@tags,$tag);
	    }
	}
    }
    if ($QUASI{$part}) {
	push(@tags,'QUASI');
    }
    @tags;
}

sub find_freq {
    my $part=$_[0];
    my $tag=$_[1];
    my $pos,$head,$mod,$solo;
    ($pos)=$tag=~/^(.{1,3})\(/;
    my $key="$part $pos";
    my $relfreq=$RF{$key};
    my $modheadsolo=$MODHEAD{$part};
    ($head,$mod,$solo)=split(/\t/,$modheadsolo);
    if ($head==0) { $head=1;}
    if ($mod==0) { $mod=1;}
    my $diffmods=$DIFMODS{$part};
    ($relfreq,$head,$mod,$diffmods);
}

sub try_compounding {
    my @nodes=@_;
    my $number_of_nodes=@nodes;
    my @hypos;
    my @currenthypos;
    if ($number_of_nodes == 2) {
	push(@hypos,&check_compound(@nodes));
    }
    elsif ($number_of_nodes == 3) {
	@currenthypos=&try_compounding($nodes[0],$nodes[1]);
	if (@currenthypos) {
	    @hypos=&try_compounding(\@currenthypos,$nodes[2]);
	}
	@currenthypos=&try_compounding($nodes[1],$nodes[2]);
	if (@currenthypos) {
	    push(@hypos,&try_compounding($nodes[0],\@currenthypos));
	}
    }
    elsif ($number_of_nodes == 4) {
	@currenthypos=&try_compounding($nodes[0],$nodes[1]);
	if (@currenthypos) {
	    @currenthypos2=&try_compounding($nodes[2],$nodes[3]);
	    if (@currenthypos2) {
		@hypos=&try_compounding(\@currenthypos,\@currenthypos2);
	    }
	    push(@hypos,&try_compounding(\@currenthypos,@nodes[2,3]));
	}
	@currenthypos=&try_compounding($nodes[1],$nodes[2]);
	if (@currenthypos) {
	    push(@hypos,&try_compounding($nodes[0],\@currenthypos,$nodes[3]));
	}
	@currenthypos=&try_compounding($nodes[2],$nodes[3]);
	if (@currenthypos) {
	    push(@hypos,&try_compounding(@nodes[0,1],\@currenthypos));
	}
    }
    @hypos;
}

sub check_compound {
    my @modifier=@{$_[0]};
    my @head=@{$_[1]};
    my $mod,$head,$result;
    local @hypos;
    foreach $mod (@modifier) {
	$rfMod=$mod->get_rf();
	if ($rfMod<$rflimit) {
	    next;
	}
	foreach $head (@head) {
	    $rfHead=$head->get_rf();
	    if ($rfHead<$rflimit) {
		next;
	    }
	    $result=&check_conditions($mod,$head);
	    if ($result) {
		push(@hypos,$result);
	    }
	}
    }
    @hypos;
}

sub check_conditions {
    my $_mod=$_[0];
    my $_head=$_[1];
    my $mod=$_mod->get_word();
    my $head=$_head->get_word();
    my $rfMod=$_mod->get_rf();
    my $rfHead=$_head->get_rf();
    my $modfreqMod=$_mod->get_modfreq();
    my $headfreqHead=$_head->get_headfreq();
    my $htag=$_head->get_tag();
    my $mtag=$_mod->get_tag();
    my $difmod=$_head->get_diffmods();
######## CALCULATE P(Comp(mod,head)) / P(Comp(*,head))
    my $comp_freq=$TOTALFREQS{$mod.$head};
    unless ($comp_freq) {
	$comp_freq=$TOTALFREQS{"$mod-$head"};
    }
    if ($headfreqHead == 0) {
	$headfreqHead=1;
    }
    my $discount=($difmod/$headfreqHead);
    if ($comp_freq) {
	$prob_comp=($comp_freq/$headfreqHead)*(1-$discount);
    }
    else {
	$prob_comp=$discount*$modfreqMod/$nr_of_comps; # is the total freq
    }
   
########
    my $modfreqSst=$_head->get_modfreq();
    my $headfreqSst=$headfreqHead;
    my @newnodearray=($mod,$head,$htag,$headfreqSst,$modfreqSst,$prob_comp,$difmod,$nr_of_input_parts);
    my $newnode;
    if ($htag eq 'QUASI') { return undef;}
    else {
	$hpos=$_head->get_pos();
	$hfeat=$_head->get_features();
	# mod = QUASI
	if (($mtag eq 'QUASI') &&
	    (($hpos eq 'N') ||
	     ($hpos eq 'ADJ'))) {
	    $newnode=&create_compound_node(@newnodearray);
	}
	else {
	    $mpos=$_mod->get_pos();
	    $mfeat=$_mod->get_features();

	    # Vorming van werkwoorden
	    if ($hpos eq 'WW') {
		if ((($mpos eq 'VZ') &&
		     (check_vz($mod))) ||
		    (($mpos eq 'BW') &&
		     (check_bw($mod)))) {
		    $htag=~s/\|pv,tgw,ev//;
		    $htag=~s/\|pv,tgw,met-t//;
		    @newnodearray=($mod,$head,$htag,$modrfSst,$headrfSst,$prob_comp,$difmod,$nr_of_input_parts);
		    $newnode=&create_compound_node(@newnodearray);
		}
		elsif (($mpos eq 'ADJ') &&
		       ($mfeat=~/basis,zonder/)) {
		    $newnode=&create_compound_node(@newnodearray);
		}
		
		# Vorming van adj obv volt. deelw.
		elsif (($hfeat=~/vd/) &&
		       ($mpos eq 'N')) {
		    $hfeat=~s/vd,//g;
		    $htag='ADJ('.$hfeat.')';
		    @newnodearray=($mod,$head,$htag,$modrfSst,$headrfSst,$prob_comp,$difmod,$nr_of_input_parts);
		    $newnode=&create_compound_node(@newnodearray);
		}
		elsif (($mtag eq 'QUASI') &&
		       ($mod eq 'on') &&
		       ($hpos eq 'WW') &&
		       ($hfeat=~/vd|od/)) {
		    $hfeat=~s/vd,//g;
		    $hfeat=~s/od,//g;
		    $htag='ADJ('.$hfeat.')';
		    @newnodearray=($mod,$head,$htag,$modrfSst,$headrfSst,$prob_comp,$difmod,$nr_of_input_parts);
		    $newnode=&create_compound_node(@newnodearray);
		}
	    }
	    # subst + WW en WW+WW zijn niet productief (ANS p 636)

	    # Vorming van Nouns
	    elsif (($hpos eq 'N') &&
		   ($hfeat=~/soort/)) {
		if ((($mpos eq 'TW') && check_noun($head)) ||
		    (($mpos eq 'VZ') && check_vz($mod)) ||
		    (($mpos eq 'BW') && check_bw($mod))) {
		    $newnode=&create_compound_node(@newnodearray);
		}
		elsif ($mpos eq 'N') {
		    if ($mfeat=~/dim/) {
			if ($mod=~/s$/) {
			    $newnode=&create_compound_node(@newnodearray);
			}
		    }
		    else {
			$newnode=&create_compound_node(@newnodearray);
		    }
		}
		elsif (($mpos eq 'ADJ') &&
		       ($hfeat!~/onz/) &&
		       ($mfeat=~/basis,zonder/)) {
		    $newnode=&create_compound_node(@newnodearray);
		}
#LAATST TOEGEVOEGD - 
		elsif (($mpos eq 'ADJ') &&
		       (($mfeat=~/^nom/) ||
			($mfeat=~/\|nom/))) {
		    $newnode=&create_compound_node(@newnodearray);
		}
		elsif (($mpos eq 'WW') &&
		       ($mfeat=~/pv,tgw,ev/)) {
		    $newnode=&create_compound_node(@newnodearray);
		}
	    }

	    # Vorming van Adjectieven
	    elsif ($hpos eq 'ADJ') {
		if (($mpos eq 'N') ||
		    (($mpos eq 'VZ') && check_vz($mod))) {
		    $newnode=&create_compound_node(@newnodearray);
		}
		elsif (($mpos eq 'WW') &&
		       ($mfeat=~/imp,ev/)) {
		    $newnode=&create_compound_node(@newnodearray);
		}
		elsif (($mpos eq 'ADJ')  &&
		       ($mfeat=~/basis,zonder/)) {
		    $newnode=&create_compound_node(@newnodearray);
		}
		elsif (($mpos eq 'TW') &&
		       ($head=~/jarige$/)) {
		    $newnode=&create_compound_node(@newnodearray);
		}
	    }
	    elsif (($hpos eq 'TW') &&
		   ($mpos eq 'TW')) {
		$newnode=&create_compound_node(@newnodearray);
	    }
	}
    }
    $newnode;
}

sub create_compound_node {
    my ($mod,$head,$htag,$modrfSst,$headrfSst,$prob,$difmod,$nr_of_input_parts)=@_;
    my $newword;
    if ((($mod=~/a$/) && (($head=~/^u/) || 
			  ($head=~/^e/) ||
			  ($head=~/^a/))
	 ) ||
	(($mod=~/e$/) && (($head=~/^e/) ||
			  ($head=~/^i/) ||
			  ($head=~/^u/))
	 ) ||
	(($mod=~/i$/) && (($head=~/^e/) ||
			  ($head=~/^i/) ||
			  ($head=~/^j/))
	 ) ||
	(($mod=~/o$/) && (($head=~/^e/) ||
			  ($head=~/^i/) ||
			  ($head=~/^o/) ||
			  ($head=~/^u/))
	 ) ||
	(($mod=~/u$/) && (($head=~/^a/) ||
			  ($head=~/^i/) ||
			  ($head=~/^o/) ||
			  ($head=~/^u/))
	 )){
	$newword=$mod.'-'.$head;
    }
    else {
	$newword=$mod.$head;
    }
    $newnode=Node->new($newword,$htag,1,$modrfSst,$headrfSst,$prob,$difmod,$nr_of_input_parts);
    $newnode;
}

#--------------------------------
sub check_vz {
#--------------------------------
# neemt een vz als argument
# en gaat na of dit voorzetsel kan samengesteld worden
    my $vz=$_[0];
    my @vzetsel_list=('aan','achter','bij','binnen','boven','buiten','door','in','langs',
		      'na','om','onder','op','over','rond','tegen','tegenover','uit',
		      'voor','af','heen','mede','mee','toe','tussen');
    for (@vzetsel_list) {
	if ($vz eq $_) {
	    return 1;
	}
    }
    return 0;
}

#--------------------------------
sub check_bw {
#--------------------------------
# neemt een bw als argument
# en gaat na of dit bijwoord kan samengesteld worden
    my $bw=$_[0];
    my @bw_list=('mis','neer','vast','voort','weer','weg','neder','samen','tegemoet',
		 'teloor','terug','teweeg','weder','teniet','achterna','achterom',
		 'achterop','achterover','achteruit','onderuit','vooraf','voorop',
		 'voorover','vooruit','aaneen','bijeen','dooreen','ineen','ondereen',
		 'opeen','overeen','uiteen','vaneen','overhoop','thuis','omhoog',
		 'omlaag','omver','verder','tewerk','teleur','opzij','vooraan','eerst',
		 'terneer','zelf');
    for (@bw_list) {
	if ($bw eq $_) {
	    return 1;
	}
    }
    return 0;
}

#----------------------------------------
sub check_noun {
#----------------------------------------
# contains list of nouns which can be head with a quantifier as modifier
# TW + N
    my $head=@_[0];
    my @nounlist=('tal','tallen','hoek','hoeken');
    foreach $noun (@nounlist) {
	if ($head eq $noun) {
	    return 1;
	}
    }
    return 0;
}

sub show_results {
    my ($ref_nodes,@results)=@_;
    my $quasi;
    if (&check_quasi($ref_nodes)) {
	$quasi=1;
    }
    my $word,$prob,$tag,$pos;
    my @above_threshold=();
    foreach $result (@results) {
	$word=$result->get_word();
	$prob=$result->get_prob();
	$pos=$result->get_pos();
	if (($prob>$problimit) ||
	    ($quasi)) {
	    if (&check_cgn("$word $pos")) {
		$result=$result->set_cgn(1);
		#return 1;
	    }
	    else {
		$result=$result->set_cgn(2);
		#return 2;
	    }
	    push (@above_threshold,$result);
	}
    }
    return @above_threshold;
}

sub check_cgn {
    my $key=$_[0];
    if ($CGN{$key}) {
	return 1;
    }
    else {
	return 0;
    }
}

sub check_quasi {
    my $ref_nodes=$_[0];
    my ($first_word_node)=@$ref_nodes;
    my ($first_node)=@$first_word_node;
    if ($first_node) {
	my $tag_firstnode=$first_node->get_tag();
	if ($tag_firstnode eq 'QUASI') {
	    return 1;
	}
	else {
	    return 0;
	}
    }
    else {
	return 0;
    }
}

sub create_ref {
    my @input=@_;
    return \@input;
}

