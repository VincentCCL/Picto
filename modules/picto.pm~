####### picto.pm ##########

# By Leen Sevens and Vincent Vandeghinste
# leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 07.10.2013

#---------------------------------------

$VERSION="3.2.1"; # 23.01.2019 Bug fix in generation of complex pictos
#$VERSION="3.2"; # 21.01.2019 Cleanup
#$VERSION="3.1"; # 04.12.2018 Shorter version of addPictoSingle, addPictoComplex and addPictoAsDependent
                # checks for url column in database table and retrieves url from there and puts it in picto object
#$VERSION="3.0"; # 12.12.2016 Added JSON and Parallel JSON output options
#$VERSION="2.2.3"; # 07.01.15 Removed frequency feature again because of complex picto issues (nagels lakken: nagel as spijker, so no complex picto is formed)
#$VERSION="2.2.2"; # 19.11.14 The picto now contains frequency information from its connected synset, which is used for path finding
#$VERSION="2.2.1"; # 14.11.14 Added references to the Maxtime sub allowing for time-outs in the translation process
#$VERSION="2.2"; # 13.11.14 Moved the parameters to TextToPicto.pl and made them available as command line options
#$VERSION="2.0"; # 16.09.14 Picto can also retrieve synsets from the English database 
#$VERSION="1.5.1"; # 06.02.14 Bug fix in word::addPictos
#$VERSION="1.5"; # 30.01.14 Bug fix + improvements in addPictoToRelations + should be faster in word::addPictos
#$VERSION="1.4.1"; #28.01.14 Removal of all reference to Cornetto, use Wordnet instead
#$VERSION="1.4"; #24.01.14 Addition of near_antonym relation UNFINISHED !!
#$VERSION="1.3.1"; # 23.01.14 Changes into lookupFilename
#$VERSION="1.3"; # 20.01.14 Now takes into account the number of the PictoSingles
#$VERSION="1.2.1"; # 03.12.13 Changes in word::lookupFilename for usage in Picto2Text
#$VERSION="1.2"; # 26.11.13 Bug fix in OccursInWords
#$VERSION="1.1.5"; # 25.11.13 Language dependent stuff is moved to picto_dutch.pm
#$VERSION="1.1.4"; # 22.11.13 Dictionary advantage added
#$VERSION="1.1.3"; # 18.11.13 Update of lookupFilename + improvements on headOccurs
#$VERSION="1.1.2"; # 08.11.13 Further clean up + bug fix
#$VERSION="1.1.1"; # Clean up of certain subroutines
#$VERSION="1.1"; # Bug fix in addPictoSingle
#$VERSION="1.0.3"; # Synset id now included into picto, obsolete functions commented out
#$VERSION="1.0.2"; # ISNULL is now written as IS NULL for compatibility with MySQL and ~ is now LIKE
#$VERSION="1.0.1"; # SPEC(deeleigen) added to list of content tags
                   # GetExtension in existNegative added
#$VERSION="1.0"; # Version used in the first release for WAI-NOT

#---------------------------------------
# Links pictogram names with synsets
#---------------------------------------

print $log "picto.pm $VERSION loaded\n" if $log;
1;



require "$Bin/$targetlanguage.pm";
require "$Bin/picto_".$sourcelanguage.".pm";

#---------------------------------------
package picto;
#---------------------------------------

@ISA=("object");

sub existNegative {
    my ($pkg)=@_;
    my $targetlanguage=$pkg->{target};
    my $positive=$pkg->{file};
    $positive=~s/\.(png|gif)$//; 
    my $sql="select antonym from $targetlanguage where lemma='$positive';";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    if (my $antonym=$results->[0]->[0]) {
	$extension=$pkg->{target}->getExtension;
	$pkg->{file}=$antonym.$extension;
	$pkg->{negativepicto}="1";
	return 1;
    }
    else {
	return undef;
    }
}

sub adaptToPolarity {
    my ($pkg,$path)=@_;
    $not=$pkg->getNot;
    my $db=$pkg->{wordnetdb};
    if (my $polarity=$pkg->{polarity}) {
	my $negdisplay=image->new(filename,$pkg->{target}->negativePicto,
				  token,$not,
				  wordnetdb,$db,
				  target,$pkg->{target},
				  logfile,$pkg->{logfile});
	my $displays=$path->{display};
	push(@$displays,$negdisplay);
	my $wordlist=$path->{words};
	push(@$wordlist,$polarity);
    }
}

sub headOccurs {
    my ($pkg,$wtp)=@_;
    my $head=$pkg->{head};
    if ($head->occursInWords($wtp)) {
	$pkg->{pathlength}+=$head->{penalty};
	delete $head->{penalty};
	return 1;			
    }
    else {
	return undef;
    }
}

sub allDepsOccur {
    my ($pkg,$wordstoprocess)=@_;
    my $deps=$pkg->{dep};
    foreach (@$deps) {
	if ($_->occursInWords($wordstoprocess)) {
	    $pkg->{pathlength}+=$_->{penalty};
	    delete $_->{penalty};
	}
	else {
	    return undef;
	}
    }
    return 1;
}

sub replaceSynset {
    my ($pkg,$from,$to)=@_;
    if (my $head=$pkg->{head}) {
	if ($head->{synset} eq $from->{synset}) {
	    $pkg->{head}=$to;
	}
    }
    if (my $dep=$pkg->{dep}) {
	foreach (@$dep) {
	    if ($_->{synset} eq $from->{synset}) {
		$_=$to;
		last;
	    }
	}
    }
}

#---------------------------------------
package pictopath;
#---------------------------------------

@ISA=("object");

sub clone {
    my ($pkg)=@_;
    my @keys=keys %$pkg;
    my $newpath=pictopath->new();
    foreach (@keys) {
	if ($_ eq 'weight') {  
	    next;
	}
	$value=$pkg->{$_};
	if (ref($value) eq 'ARRAY') {
	    $newpath->{$_}=[@$value];
	}
	else {
	    $newpath->{$_}=$value;
	}
    }
    return $newpath;
}

sub weight {
    my ($pkg)=@_;
    my $weight;
    my $wordstoprocess=$pkg->{wordstoprocess};
    $weight=@$wordstoprocess;
    my $display=$pkg->{display};
    foreach (@$display) {
	$weight+=$_->{pathlength};
    }
    return $weight;
}

sub containsAllInfo {
    my ($pkg)=@_;
    if ($pkg->{wordstoprocess}->[0]) {
	return undef;
    }
    else {
	return 1;
    }
}

sub stringify {
    my ($pkg)=@_;
    my $displays=$pkg->{display};
    my @string;
    foreach (@$displays) {
	push(@string,$_->getContent);
    }
    return join('/',@string);
}
    
 sub printInLogfile {
     my ($pkg)=@_;
     my $log=$pkg->{logfile};
     unless ($log) { return;}
     my $display=$pkg->{display};
     print $log "\tPathweight: ".$pkg->weight."\n" if $log;
     if ($display) {
         print $log "\tDisplay: " if $log;
         foreach (@$display) {
             print $log $_->getContent.", " if $log;
         }
         print $log "\n" if $log;
     }
     else {
         print $log "\tDisplay: No words yet\n" if $log;
     }
     my $wordstoprocess=$pkg->{wordstoprocess};
     print $log "\tWords to process: " if $log;
     foreach (@$wordstoprocess) {
         my $token=$_->{token};
         print $log "$token, " if $log;
     }
     print $log "\n" if $log;
 }

sub extend {
    &main::Maxtime;
    my ($pkg)=@_;
     my $log=$pkg->{logfile};
     print $log "\nExtending path\n" if $log;
     $pkg->printInLogfile;
    my @newpaths;
    my $oldwordstoprocess=$pkg->{wordstoprocess};
    if (my $current=shift(@$oldwordstoprocess)) {
	if ($complexes=$current->getPictoComplexes) {
	    for (my $i=0;$i<@$complexes;$i++) {
		if ($complexes->[$i]->allDepsOccur([@$oldwordstoprocess])) {
		    my $newpath=$pkg->extendWithPicto( "complex", $current,
						       $complexes->[$i],
						       [@wordstoprocess]);
		    $newpath->spliceWordWithDep($complexes->[$i]);
 		    print $log "  Extended path with complex picto: \n" if $log;
                     $newpath->printInLogfile;
                    push(@newpaths,$newpath);
		}
	    }
	}
	if ($singles=$current->getPictoSingle) {
	    foreach $single (@$singles) {
		$newpath=$pkg->extendWithPicto(	"single",$current,
						$single,
						[@wordstoprocess]);
                print $log "  Extend path with single picto:\n" if $log;
                 $newpath->printInLogfile;
                push(@newpaths,$newpath);
	    }
	}
	if ($asdependents=$current->getPictoAsDependents) {
	    for (my $i=0;$i<@$asdependents;$i++) {
		if ($asdependents->[$i]->headOccurs([@$oldwordstoprocess])) {
		    if ($asdependents->[$i]->allDepsOccur([@$oldwordstoprocess,$current])) {
			my $newpath=$pkg->extendWithPicto( "complex", $current,
							   $asdependents->[$i],
							   [@wordstoprocess]);
			$newpath->spliceWordWithHead($asdependents->[$i]);
			$newpath->spliceWordWithDep($asdependents->[$i]); 
                         print $log "  Extend path with complex\n" if $log;
                         $newpath->printInLogfile;
                        push(@newpaths,$newpath);
		    }
		}
	    }			
	}
	unless (@newpaths) {
	    $newpath=$pkg->extendNoPicto($current);
	    print $log "  Extend path with word (no picto found)\n" if $log;
            if ($log) {$newpath->printInLogfile}
            push(@newpaths,$newpath);
	}
	return @newpaths;
    }
}

sub extendNoPicto {
    &main::Maxtime;
    my ($pkg,$word)=@_;
    my $db=$pkg->{wordnetdb};
    my $display=text->new(text,$word->{token},
			  pathlength,$main::oovpunishment,
			  wordnetdb,$db,
			  target,$pkg->{target},
			  logfile,$pkg->{logfile});
    my $newpath=$pkg->clone;
    $newpath->pushFeature(display,[$display]);
    $newpath->pushFeature(words,[$word]);
    if (my $neg=$word->{polarity}) {
	$display=image->new(text,$word->{token},
			    filename,$pkg->{target}->negativePicto,
			    wordnetdb,$db,
			    target,$pkg->{target},
			    logfile,$pkg->{logfile});
	$newpath->pushFeature(display,[$display]);
	$newpath->pushFeature(words,[$neg]);
	delete $word->{polarity};				   
    }
    return $newpath;
}

sub spliceWordWithHead {
    my ($pkg,$picto)=@_;
    my $head=$picto->{head};
    my $wtp=$pkg->{wordstoprocess};
    my $headword;
    for (my $i=0;$i<@$wtp;$i++) {
	if ($head->occursInWord($wtp->[$i])) {
	    $headword=splice(@$wtp,$i,1);
	    $pkg->pushFeature(words,[$headword]);
	}
    }
}

sub spliceWordWithDep {
    my ($pkg,$picto)=@_;
    my $deps=$picto->{dep};
    my $wtp=$pkg->{wordstoprocess};
    my $depword;
  DEPS:foreach (@$deps) {
      for (my $i=0;$i<@$wtp;$i++) {
	  if ($_->occursInWord($wtp->[$i])) {
	      $depword=splice(@$wtp,$i,1);
	      $pkg->pushFeature(words,[$depword]);
	      next DEPS;
	  }
      }
  }
}

sub extendWithPicto {
    &main::Maxtime;
    my ($pkg,$type,$word,$picto)=@_;
    $token=$word->{token};
    my $db=$pkg->{wordnetdb};
    if (($picto->{number}) &&
	($word->getNumber) &&
	($picto->{number} ne $word->getNumber)) {
	$picto->{pathlength}+=$main::wrongnumber;
	$picto->{pathlength};
    }
    elsif ($word->getNumber eq $picto->{number}) {
    }
    else {
	$picto->{pathlength}+=$main::nonumber;
	$picto->{pathlength};
    }
    my $display=image->new(filename,$picto->{file},
			   token,$token,
			   antonym,$picto->{antonym},
			   negativepicto,$picto->{negativepicto},
			   type,$type,
			   pathlength,$picto->{pathlength},
			   wordnetdb,$db,
			   url,$picto->{url},
			   target,$pkg->{target},
			   logfile,$pkg->{logfile});
    my $newpath=$pkg->clone;
    $newpath->pushFeature(display,[$display]);
    $newpath->pushFeature(words,[$word]);
    if ($picto->{antonym}) {
	my $negative=image->new(filename,$picto->{target}->negativePicto,
			        token,$token,
			        type,$type,
				antonympicto,"1",
				wordnetdb,$db,
				url,$picto->{url},
				target,$picto->{target},
				pathlength,1,
				logfile,$pkg->{logfile});
	$newpath->pushFeature(display,[$negative]);
	my $negword=word->getNegativeWord;
	$newpath->pushFeature(words,[$negword]);
    }
    $picto->adaptToPolarity($newpath); 
    return $newpath;
}
	
	
#---------------------------------------
package message;
#---------------------------------------

sub text {
    my ($pkg)=@_;
    my $sentences=$pkg->{sentences};
    foreach (@$sentences) {
	$_->TextOut;
    }
}

sub html {
    my ($pkg,$level)=@_;
    print "<html>\n";
    my $sentences=$pkg->{sentences};
    foreach (@$sentences) {
	$_->HTMLOut;
	print "<p>\n";
    }
    print "</html>\n";
}	

sub paralleljson {
    my ($pkg,$level)=@_;
    print "{ \n \"input\" :";
    my $text=$pkg->{text};
    print " \"$text\" ,\n \"output\" : [";
    my $sentences=$pkg->{sentences};
    foreach (@$sentences) {
	$_->ParallelOutOtherFile;
        $_->ParallelJSONOut;
        print "\"\\n\", ";
    }
    print "\"\\n\" ] \n}\n";
}

sub json {
    my ($pkg,$level)=@_;
    print "{ \n \"input\" :";
    my $text=$pkg->{text};
    print " \"$text\" ,\n \"output\" : [";
    my $sentences=$pkg->{sentences};
    foreach (@$sentences) {
       $_->JSONOut;
       print "\"\\n\", ";
    }
    print "\"\\n\" ] \n}\n";
}	

sub lookupPictoDictionary {
    my ($pkg,$level)=@_;
    $pkg->openWordnet;
    my $sentences=$pkg->{sentences};
    foreach (@$sentences) {
	$_->{wordnetdb}=$pkg->{wordnetdb};
	$_->lookupPictoDictionary($level+1);
    }
}

sub addPictoPaths {
    my ($pkg)=@_;
    my $log=$pkg->{logfile};
    print $log "\n\nmessage::addPictoPaths\n-------------------------------\n" if $log;
    $pkg->addPictos;
    $pkg->showInLog;
    $pkg->searchArgMax;	
    $pkg->showInLog;
}

sub searchArgMax {
    my ($pkg)=@_;
    my $sentences=$pkg->{sentences};
    foreach (@$sentences) {
	$_->searchArgMax;
    }
}

sub addPictos {
    my ($pkg)=@_;
    my $sentences=$pkg->{sentences};
    my $wordnet=$pkg->{wordnetdb};
    foreach (@$sentences) {
	$_->{wordnetdb}=$wordnet;
	$_->addPictos;
    }
}

#---------------------------------------
package sentence;
#---------------------------------------

#my $stamp=time.$main::sessionid; ## WAT DOET DIT HIER?

sub addPictos {
    &main::Maxtime;
    my ($pkg)=@_;
    my $words=$pkg->{words};
    my $wordnetdb=$pkg->{wordnetdb};
    my $flag;
    for (my $i=0;$i<@$words;$i++) {
	$flag=undef;
	$words->[$i]->{wordnetdb}=$wordnetdb;
	unless ($words->[$i]->addPictosNotInWordnet) {
	    if ($words->[$i]->lookupPictoDictionary) {
		$flag=1;
	    };
	    
	    if ($words->[$i]->isContentWord($pkg)) {
		$words->[$i]->addPictos;
	    }
	    elsif (!defined($flag)) {
		my $tok=$words->[$i]->{token};
		splice(@$words,$i,1);
		$i--;
	    }
	}
    }
}

sub searchArgMax {
    &main::Maxtime;
    my ($pkg)=@_;
    my $wordstoprocess=$pkg->{words};
    my $db=$pkg->{wordnetdb};
    my $q=[pictopath->new(wordstoprocess,[@$wordstoprocess],
			  wordnetdb,$db,
			  target,$pkg->{target},
			  logfile,$pkg->{logfile})];
    my ($firstpath,$i);
    until ((@$q == 0) ||
	   ($q->[0]->containsAllInfo)) {
	$firstpath=shift(@$q);
	my @newpaths=$firstpath->extend;
	push(@$q,@newpaths); 
	$q=$pkg->removeDoublePaths($q);
	$q=$pkg->sortQ($q);
    }
    $pkg->{path}=$q->[0];
}

sub removeDoublePaths {
    my ($pkg,$paths)=@_;
    my %PATHHASH;
    foreach (@$paths) {
	$string=$_->stringify;
	if (($oldvalue=$PATHHASH{$string}) &&
	    ($oldvalue->weight < $_->weight)) {
	    next;
	}
	$PATHHASH{$string}=$_;
    }
    my @newpaths=values(%PATHHASH);
    return [@newpaths];
}

sub sortQ {
    my ($pkg,$paths)=@_;
    my @paths=@$paths;
    my @sorted=sort {$a->weight <=> $b->weight} @paths;
    return [@sorted];
}

sub TextOut {
    my ($pkg)=@_;
    my $path=$pkg->{path};
    my $display=$path->{display};
    foreach (@$display) {
	if (ref($_) eq 'image') {
	    $filename=$_->{filename};
	    $filename=~s/\.png$//;
	    $filename=~s/\.gif$//;
	    print "$filename ";
	}
	else {
	    $text=$_->{text};
	    print "$text ";
	}
    }
    print "\n";
}

sub ParallelOutOtherFile {
    my ($pkg,$level)=@_;
    my $path=$pkg->{path};
    my $words=$path->{words};
    my $display=$path->{display};
    my $target=$pkg->{target};
    my $url=$target->getURL;
    my @pictodirs=$target->getPictoDirs;
    my $imgsize;
    open (PARALLEL,">$main::paralleloutput$stamp.txt");
    foreach (@$display) {
	@associatedwords=();
	if (ref($_) eq 'image') {
	    $filename=$_->{filename};
	    $antonym=$_->{antonym};
	    $complexity=$_->{type};
	    $negativepicto=$_->{negativepicto};
	    $token=$_->{token};
	    if($antonym eq "1"){
		    foreach $dir (@pictodirs) {
			if (-e "$dir/$filename") {
			    if ($url) {
				print PARALLEL "\"$url/$filename\"|";
			    }
			    else {
				print PARALLEL "\"$filename\"|";
			    }
			    last;
			}
		    }
	    }
 	    elsif($negativepicto eq "1"){
		  if(($main::sourcelanguage eq "cornetto") || ($main::sourcelanguage eq "dutch")){
			$not = "niet";
		  }
		  elsif($main::sourcelanguage eq "english"){
		        $not = "no";
		  }
		  elsif($main::sourcelanguage eq "spanish"){
			$not = "no";
		  }
		  foreach $dir (@pictodirs) {
					if (-e "$dir/$filename") {
					    if ($url) {
						print PARALLEL "\"$url/$filename\"\t\"$not $token\"\n";
					    }
					    else {
						print PARALLEL "\"$filename\"\t\"$not $token\"\n";
					    }
					    last;
					}
		  }
	    }
            elsif ($complexity eq "complex"){
		    foreach $word(@$words){
			$token=$word->{token};
			if($word->{picto_single}){
				$pictosingles=$word->{picto_single};
				foreach $pictosingle(@$pictosingles){
					$pictosinglefilename=$pictosingle->{file};
					if($filename eq $pictosinglefilename){
						push(@associatedwords,$token);
					}
				}
			}
			if($word->{picto_complex}){
				$pictocomplexes=$word->{picto_complex};
				foreach $pictocomplex(@$pictocomplexes){
					$pictocomplexfilename=$pictocomplex->{file};
					if($filename eq $pictocomplexfilename){
						push(@associatedwords,$token);
					}
				}
			}
			if($word->{picto_asdependent}){
				$pictoasdependents=$word->{picto_asdependent};
				foreach $pictodependent(@$pictoasdependents){
					$pictodependentfilename=$pictodependent->{file};
					if($filename eq $pictodependentfilename){
						push(@associatedwords,$token);
					}
				}
			}
		    }
		    my %seen=();
		    my @noduplicates= grep !$seen{$_}++, @associatedwords;
		    $scal = "@noduplicates";
		    foreach $dir (@pictodirs) {
			if (-e "$dir/$filename") {
			    if ($url) {
				print PARALLEL "\"$url/$filename\"\t\"$scal\"\n";
			    }
			    else {
				print PARALLEL "\"$filename\"\t\"$scal\"\n";
			    }
			    last;
			}
		    }
		}
		else{
			   foreach $dir (@pictodirs) {
						if (-e "$dir/$filename") {
						    if ($url) {
							print PARALLEL "\"$url/$filename\"\t\"$token\"\n";
						    }
						    else {
							print PARALLEL "\"$filename\"\t\"$token\"\n";
						    }
						    last;
						}
			   }
		}
	}
	else {
	    $text=$_->{text};
	    print PARALLEL "||$text\n";
	}
    }
    close PARALLEL;
}

sub HTMLOut { # new version, checks whether image object has a url field
    my ($pkg,$level)=@_;
    my $path=$pkg->{path};
    my $log=$pkg->{logfile};
    my $display=$path->{display};
    my ($url,@pictodirs);
    if (my $target=$pkg->{target}) {
      $url=$target->getURL;
      @pictodirs=$target->getPictoDirs;
    }
    else {
      print $log "No target set in package \n" if $log;
      $pkg->showInLog;
    }
    my $imgsize;
    if ($main::imgwidth) {
	$imgsize=" width=\"$main::imgwidth\" ";
    }
    if ($main::imgheigth) {
	$imgsize.=" heigth=\"$main::imgheigth\"";
    }
    DISPLAY:foreach (@$display) {
	if (ref($_) eq 'image') {
	  $filename=$_->{filename};
	  if ($imageurl=$_->{url}) {
	    print "<img src=\"$imageurl\" $imgsize alt=\"$filename\">\n";
	  }
	  else {
	    foreach $dir (@pictodirs) {
		if (-e "$dir/$filename") {
		    if ($url) {
			print "<img src=\"$url/$filename\" $imgsize alt=\"$filename\">\n";
		    }
		    else {
			print "<img src=\"$dir/$filename\" $imgsize alt=\"$filename\">\n";
		    }
		    next DISPLAY;
		    #last;
		}
	    }
	    # only get here when something else didn't work
	    print "<img src=\"$url/$filename\" $imgsize alt=\"$filename\">\n";
	  }
	}
	else {
	    $text=$_->{text};
	    print " $text ";
	}
    }  print "<p>\n";
}

sub ParallelJSONOut {
    my ($pkg,$level)=@_;
    open (PARALLEL,"$main::paralleloutput$stamp.txt");
    my $target=$pkg->{target};
    my $url=$target->getURL;
    my @pictodirs=$target->getPictoDirs;
    while(<PARALLEL>){
	  chomp $_;
  	  ($pictos,$text)=split(/\t/,$_);
  	  print "[$pictos,$text],";
    }
    `rm -f $main::paralleloutput$stamp.txt`;
}

sub JSONOut {
    my ($pkg,$level)=@_;
    my $path=$pkg->{path};
    my $display=$path->{display};
    my $target=$pkg->{target};
    my $url=$target->getURL;
    my @pictodirs=$target->getPictoDirs;
    my $imgsize;
    foreach (@$display) {
	if (ref($_) eq 'image') {
	    $filename=$_->{filename};
	    foreach $dir (@pictodirs) {
		if (-e "$dir/$filename") {
		    if ($url) {
			print "\"$url/$filename\", ";
		    }
		    else {
			print "\"$filename\", ";
		    }
		    last;
		}
	    }
	}
	else {
	    $text=$_->{text};
	    print "\"$text\", ";
	}
    }
}
	
#---------------------------------------
package word;
#---------------------------------------

sub lookupPictoDictionaryTokLemTag {
    my ($pkg,$toklemtag)=@_;
    my $db;
    my $dictionarytable=$pkg->{target}->getDictionaryTableName;
    unless ($db=$pkg->{wordnetdb}) {
	$pkg->openWordnet;
	$db=$pkg->{wordnetdb};
    }
    my ($tok,$lem,$tag)=@$toklemtag;
    my ($sql);
    $sql="select column_name from information_schema.columns where table_name='$dictionarytable' and column_name='url';";
    my $urlresult=$pkg->{wordnetdb}->lookup($sql);
    my $retrieve_columns;
    if (defined($urlresult->[0]->[0])) {
      $retrieve_columns="picto,url";
    }
    else {
       $retrieve_columns="picto";
    }
    if ($tok && $tag && $lem) {
	$sql="select $retrieve_columns from $dictionarytable where token='$tok' and lemma='$lem' and tag='$tag';";
    }
    elsif ($tok && $tag) {
	$sql="select $retrieve_columns from $dictionarytable where token='$tok' and tag='$tag';";
    }	
    elsif ($lem && $tag) {
	$sql="select $retrieve_columns from $dictionarytable where lemma='$lem' and tag='$tag';";
    }
    elsif ($tok) {
	$sql="select $retrieve_columns from $dictionarytable where token='$tok' and tag IS NULL;";
    }
    elsif ($lem) {
	$sql="select $retrieve_columns from $dictionarytable where lemma='$lem' and tag IS NULL;";
    }
    else {
	return undef;
    }
    $results=$db->lookup($sql);
    if ($results->[0]) {
	$picto=picto->new(file,$results->[0]->[0],
			  wordnetdb,$db,
			  target,$pkg->{target},
			  url,$results->[0]->[1],
			  pathlength,-$main::dictionary_advantage,
			  logfile,$pkg->{logfile});
	$pkg->{picto_single}=[$picto];
	return 1;
    }
    else {
	return undef;
    }
}


sub lookupFilename {
    my ($pkg)=@_;
    my $ext=$pkg->{target}->getExtension;
    my @pictodirs=$pkg->{target}->getPictoDirs;
    my $filename;
    my $picto;
    my $db=$pkg->{wordnetdb};
    $filename=$pkg->{lemma}.$ext;
    foreach (@pictodirs) {
	if (-e "$_/$filename") {
	    $picto=picto->new(file,$filename,
			      pathlength,0,
			      wordnetdb,$db,
			      target,$pkg->{target},
			      logfile,$pkg->{logfile});
	    $pkg->pushFeature(picto_single,[$picto]);;
	    return 1;								
	}
    }
    return undef;
}

sub getPictoComplexes {
    my ($pkg)=@_;
    return $pkg->{picto_complex};
}

sub getPictoAsDependents {
    my ($pkg)=@_;
    return $pkg->{picto_asdependent};
}

sub getPictoSingle {
    my ($pkg)=@_;
    my $return=$pkg->{picto_single};
    return $return;
}

sub addPictos {
    &main::Maxtime;
    my ($pkg)=@_;
    my $tok=$pkg->{token};
    my (%picto_single_already,$already,%picto_complex_already,%picto_asdep_already);
    my $other_picto_singles=$pkg->{picto_single}; 
    foreach (@$other_picto_singles) {
	$picto_single_already{$_->{file}}=$_;
    }
    my $lexunits=$pkg->{lexunits};
    foreach (@$lexunits) {
	if (@$other_picto_singles>0) {
	    $_->addPicto('nosingle');
	}
	else {
	    $_->addPicto;
	}
	my $picto_singles=$_->{picto_single};
	foreach $picto_single (@$picto_singles) {
	    if ($already=$picto_single_already{$picto_single->{file}}) {
		if ($already->{pathlength} > $picto_single->{pathlength}) {
		    $picto_single_already{$picto_single->{file}}=$picto_single;
		}
	    }
	    else {
		$picto_single_already{$picto_single->{file}}=$picto_single;
	    }
	}
	delete $_->{picto_single};
	my $picto_complexes=$_->{picto_complex};
	foreach $picto_complex (@$picto_complexes) {
	    if ($already=$picto_complex_already{$picto_complex->{file}}) {
		if ($already->{pathlength} > $picto_complex->{pathlength}) {
		    $picto_complex_already{$picto_complex->{file}}=$picto_complex;
		}
	    }
	    else {
		$picto_complex_already{$picto_complex->{file}}=$picto_complex;
	    }
	}
	delete $_->{picto_complex};
	my $picto_asdependents=$_->{picto_asdependent};
	foreach $picto_asdependent (@$picto_asdependents) {
	    if ($already=$picto_asdep_already{$picto_asdependent->{file}}) {
		if ($already->{pathlength} > $picto_asdependent->{pathlength}) {
		    $picto_asdep_already{$picto_asdependent->{file}}=$picto_asdependent;
		}
	    }
	    else {
		$picto_asdep_already{$picto_asdependent->{file}}=$picto_asdependent;
	    }
	}
	delete $_->{picto_asdependent};
    }
    if (%picto_single_already>0) {
	$pkg->{picto_single}=[sort {$a->{pathlength} <=> $b->{pathlength}} values %picto_single_already];
    }
    if (%picto_complex_already>0) {
	$pkg->{picto_complex}=[sort {$a->{pathlength} <=> $b->{pathlength}} values %picto_complex_already];
    }
    if (%picto_asdep_already>0) {
	$pkg->{picto_asdependent}=[sort {$a->{pathlength} <=> $b->{pathlength}} values %picto_asdep_already];
    }
    $pkg->adaptToPolarity;
}

sub adaptToPolarity {
    my ($pkg)=@_;
    if (my $negword=$pkg->{polarity}) {
	my $picto_complex=$pkg->{picto_complex};
	my $picto_single=$pkg->{picto_single};
	my $picto_asdep=$pkg->{picto_asdependent};
	my @pictos=(@$picto_complex,@$picto_single,@$picto_asdep);
	foreach (@pictos) {
	    unless ($_->existNegative) {
		$_->{polarity}=$negword;
	    }
	}	
    }
}


#---------------------------------------
package lexunit;
#---------------------------------------

sub addPicto {
    my ($pkg,$singleornot)=@_;
    my $lexid=$pkg->{id};
    if ($pkg->{synset}->{wsdscore}){
        $wsdscorenorm=$pkg->{synset}->{wsdscore};
    	$initpenal=0-($main::wsdweight*$wsdscorenorm); 
    }
    else{
    	$initpenal=0;
    }
    if ($pkg->{synset}) {
	$pkg->{synset}->addPicto($initpenal,$singleornot);
	my $single=$pkg->{synset}->{picto_single};
	if (@$single>0) {
	    $pkg->{picto_single}=$single;
	}
	delete $pkg->{synset}->{picto_single};
	my $complex=$pkg->{synset}->{picto_complex};
	if (@$complex>0) {
	    $pkg->{picto_complex}=$complex;
	}
	delete $pkg->{synset}->{picto_complex};
	my $asdep=$pkg->{synset}->{picto_asdependent};
	if (@$asdep) {
	    $pkg->{picto_asdependent}=$asdep;
	}
	delete $pkg->{synset}->{picto_asdependent};
    }
    else {
	return undef;
    }
}

sub getPictoComplexes {
    my ($pkg,$level)=@_;
    return ($pkg->{picto_complex});
}

sub getPictoSingle {
    my ($pkg,$level)=@_;
    return ($pkg->{picto_single});
}

#---------------------------------------
package synset;
#---------------------------------------

sub occursInSynset {
    my ($pkg,$synset)=@_;
    if ($pkg->{synset} eq $synset->{synset}) {
	return 1;
    }
    else {
	my $hyper=$synset->{hyperonyms};
	foreach (@$hyper) {
	    if ($pkg->occursInSynset($_)) {
		$synset->{penalty}+=$main::hyperonympenalty;
		return 1;
	    }
	}
    }
}

sub occursInLexunit {
    my ($pkg,$lu)=@_;
    my $penalty;
    if ($pkg->occursInSynset($lu->{synset})) {
	if ($penalty=$lu->{synset}->{penalty}) {
	    $lu->{penalty}=$penalty;
	    delete $lu->{synset}->{penalty};
	}
	return 1;
    }
    else {
	return undef;
    }
}

sub occursInWord {
    my ($pkg,$word)=@_;
    my $lexunits=$word->{lexunits};
    my ($minpenalty,$penalty,$flag);
    foreach (@$lexunits) {
	if ($pkg->occursInLexunit($_)) {
	    $flag=1;
	    $penalty=$_->{penalty};
	    unless ($penalty) {
		$penalty=0;
	    }
	    if ($minpenalty) {
		if ($penalty<$minpenalty) {
		    $minpenalty=$penalty;
		}
	    }
	    else {
		$minpenalty=$penalty;
	    }
	}
    }
    if ($flag) {
	$pkg->{penalty}=$minpenalty;
	return 1;
    }
    else {
	return undef;
    }
}

sub occursInWords {
    my ($pkg,$words)=@_;
    foreach (@$words) {
	if ($pkg->occursInWord($_)) {
	    return 1;
	}
    }
    return undef;
}

sub equal {
    my ($pkg,$ss2)=@_;
    my $ss1id=$pkg->{synset};
    my $ss2id=$ss2->{synset};
    if ($ss1id eq $ss2id) {
	return 1;
    }
    else {
	return undef;
    }
}

sub addPicto { 
    &main::Maxtime;
    my ($pkg,$penalty,$singleornot)=@_;
    my $synset=$pkg->{synset};
    my @types;
    if ($singleornot eq 'nosingle') {
	@types=(complex,asdependent);
    } 
    else {
	@types=(single,complex,asdependent);
    }
    $pkg->addPictoTypes([@types],$penalty);
    $pkg->addPictoToRelations([@types],$penalty,$singleornot);
}

sub addPictoToRelations {
    &main::Maxtime;
    my ($pkg,$types,$penalty,$singleornot)=@_;
    my $ss=$pkg->{synset};
    $pkg->addRelations;
    my ($xposnearsynonyms,$hyperonyms,$antonyms);
    my ($picto_array,$pictos,$picto);
    if ($penalty+$main::xpospenalty < $main::penaltythreshold) {
	$xposnearsynonyms=$pkg->{xposnearsynonyms};
	foreach (@$xposnearsynonyms) {
	    $relss=$_->{synset};
	    $_ -> addLemmas;
	    $lemmalist = $_ -> {lexunits};
 	    foreach (@$lemmalist){
		    $lemmalist2 = $_ -> {lexunits};
		    foreach (@$lemmalist2){
			$lemmas = $_ -> {lemma};
		    }
	    }
	    $_->addPicto($penalty+$main::xpospenalty,$singleornot);
	}
    }
    if ($penalty+$main::hyperonympenalty < $main::penaltythreshold) {
	$hyperonyms=$pkg->{hyperonyms};
	foreach (@$hyperonyms) {
	    $relss=$_->{synset};
	    $_ -> addLemmas;
	    $lemmalist = $_ -> {lexunits};
 	    foreach (@$lemmalist){
		    $lemmalist2 = $_ -> {lexunits};
		    foreach (@$lemmalist2){
			$lemmas = $_ -> {lemma};
		    }
	    }
	    $_->addPicto($penalty+$main::hyperonympenalty,$singleornot);
	}
    }
    if ($penalty+$main::antonympenalty < $main::penaltythreshold) {
	$antonyms=$pkg->{antonyms};
	foreach (@$antonyms) {
	    $relss=$_->{synset};
	    $_ -> addLemmas;
	    $lemmalist = $_ -> {lexunits};
 	    foreach (@$lemmalist){
		    $lemmalist2 = $_ -> {lexunits};
		    foreach (@$lemmalist2){
			$lemmas = $_ -> {lemma};
		    }
	    }
	    $_->addPicto($penalty+$main::antonympenalty,$singleornot);
	}
    }
    foreach $type (@$types) {
	$pictotype="picto_".$type;
	foreach (@$xposnearsynonyms,@$hyperonyms) {
	    if ($pictos=$_->{$pictotype}) {
		foreach $picto (@$pictos) {
		    $picto->replaceSynset($_,$pkg);
		}
		$pkg->pushFeature($pictotype,$pictos);
	    }
	}
	foreach (@$antonyms) {
	    if ($pictos=$_->{$pictotype}) {
		foreach $picto (@$pictos) {
		    $picto->replaceSynset($_,$pkg);
		    $picto->{antonym}=1;
		}
		$pkg->pushFeature($pictotype,$pictos);
	    }
	}
    }
    delete $pkg->{xposnearsynonyms};
    delete $pkg->{calling_xpos};
    delete $pkg->{calling_antonym};
    delete $pkg->{hyperonyms};
    delete $pkg->{antonyms};
}

sub addPictoTypes {
    my ($pkg,$types,$penalty)=@_;
    foreach (@$types) {
	$pictotype="picto_".$_;
	if ($_ eq 'single') {
	    $picto=$pkg->addPictoSingle($penalty);
	}
	elsif ($_ eq 'complex') {
	    $picto=$pkg->addPictoComplex($penalty);
	}
	elsif ($_ eq 'asdependent') {
	    $picto=$pkg->addPictoAsDependent($penalty);
	}
	if ($picto) {
	    foreach $p (@$picto) {
		$file=$p->{file};
	    }
	    $pkg->pushFeature($pictotype,$picto);
	}
	else {
	}
    }
}

sub addPictoSingle { # new and shorter version (VV)
    my ($pkg,$penalty)=@_;
    my $log=$pkg->{logfile};
    my $target=$pkg->{target};
    # check for url field in table
    my $sql="select column_name from information_schema.columns where table_name='$target' and column_name='url';";
    my $urlresult=$pkg->{wordnetdb}->lookup($sql);
    my $retrieve_columns;
    if (defined($urlresult->[0]->[0])) {
      $retrieve_columns="lemma,relation,number,url";
    }
    else {
    $retrieve_columns="lemma,relation,number";
    }
   # my $sql="select lemma,relation,number from $target where synset LIKE '%$pkg->{synset}%';"; # Version 2.0 for English
    my $sql="select $retrieve_columns from $target where synset = '$pkg->{synset}';";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    my (@picto,$pathlength);
    my @pictodirs=$target->getPictoDirs;
    my $extension=$target->getExtension;
    if ($pkg->{calling_antonym}) { # The picto is the antonym of what should be shown
	my $negative=$target->negativePicto;
    }
  RESULT:foreach (@$results) {
      my $current_penalty=$penalty;
      unless ($_->[1] eq 'synonym') {
	  $current_penalty+=$main::hyperonympenalty;
      }
    DIR:foreach $dir (@pictodirs) {
# 	if (-e "$dir/".$_->[0].$extension) {
	    $picto=picto->new(wordnetdb,$pkg->{wordnetdb},
			      file,"$_->[0]".$extension,
			      pathlength,$current_penalty,
			      logfile,$pkg->{logfile},
			      synset,$pkg->{synset},
			      target,$pkg->{target},
			      number,$_->[2]);
	    if ($negative) {
		$picto->{neg}=$negative;
	    }
	    if ($url=$_->[3]) {
	      $picto->{url}=$url;
	    }
	    push(@picto,$picto);
	    last DIR;
# 	}
# 	next RESULT;
    }
  }
    if (@picto) {
	return [@picto];
    }
    else {
	return undef;
    }
}


sub addPictoComplex {
    my ($pkg,$penalty)=@_;
    my $target=$pkg->{target};
    # check for url field in table
    my $sql="select column_name from information_schema.columns where table_name='$target' and column_name='url';";
    my $urlresult=$pkg->{wordnetdb}->lookup($sql);
    my $retrieve_columns;
    if (defined($urlresult->[0]->[0])) {
      $retrieve_columns="lemma,headrel,dependent,deprel,number,url";
    }
    else {
    $retrieve_columns="lemma,headrel,dependent,deprel,number";
    }
    my $sql="select $retrieve_columns from $target where head = '$pkg->{synset}';";
   # my $sql="select lemma,headrel,dependent,deprel from $target where head LIKE '%$pkg->{synset}%';"; # Version 2.0 for English
    my $results=$pkg->{wordnetdb}->lookup($sql);
    my (@picto,$pathlength,@depsynsets,@deprelations,@deps,$depweight,$depsynset);
    my $extension=$target->getExtension;
    foreach (@$results) {
	my $current_penalty=$penalty;
	unless ($_->[1] eq 'synonym') {
	    $current_penalty+=$main::hyperonympenalty;
	}
	@depsynsets=split(/,/,$_->[2]);
	@deprelations=split(/,/,$_->[3]);
	@deps=();
	$depweight=0;
	for (my $i=0;$i<@depsynsets;$i++) {
	    $depsynset=synset->new(wordnetdb,$pkg->{wordnetdb},
				   synset,$depsynsets[$i],
				   logfile,$pkg->{logfile},
				   target,$pkg->{target});
	    if ($deprelations[$i] eq 'hypernym') {
		$current_penalty+=$main::hyperonympenalty;
	    }
	    push(@deps,$depsynset);
	}
	my $picto=picto->new(wordnetdb,$pkg->{wordnetdb},
			       head,$pkg,
			       file,"$_->[0]".$extension,
			       dep,[@deps],
			       pathlength,$current_penalty,
			       logfile,$pkg->{logfile},
			       target,$pkg->{target});
	if ($url=$_->[5]) {
	  $picto->{url}=$url;
	}
	push(@picto,$picto);
	
    }
    if (@picto) {
	return [@picto]
    }
    else {
	return undef;
    }
}


sub addPictoAsDependent {
    # Adds the picto for which the current synset is a dependent
    # Does not add the other dependents to the picto !!
    my ($pkg,$penalty)=@_;
    my $target=$pkg->{target};
        # check for url field in table
    my $sql="select column_name from information_schema.columns where table_name='$target' and column_name='url';";
    my $urlresult=$pkg->{wordnetdb}->lookup($sql);
    my $retrieve_columns;
    if (defined($urlresult->[0]->[0])) {
      $retrieve_columns="lemma,head,headrel,dependent,deprel,number,url";
    }
    else {
      $retrieve_columns="lemma,head,headrel,dependent,deprel,number";
    }
    my $sql="select $retrieve_columns from $target where dependent = '$pkg->{synset}';";
    #my $sql="select lemma,head,headrel,dependent,deprel from $target where dependent LIKE '%$pkg->{synset}%';";
    my $results=$pkg->{wordnetdb}->lookup($sql);
    my (@picto,$headsynsetrel,$depsynset,$depsynsetrel,@depsynsets,@deprelations,@deps,$headsynset);
    my $extension=$target->getExtension;
    foreach (@$results) {
	my $current_penalty=$penalty;
	unless ($_->[2] eq 'synonym') {
	    $current_penalty+=$main::hyperonympenalty;
	}
	$headsynset=synset->new(wordnetdb,$pkg->{wordnetdb},
				synset,$_->[1],
				logfile,$pkg->{logfile},
				target,$pkg->{target});
	@depsynsets=split(/,/,$_->[3]);
	@deprelations=split(/,/,$_->[4]);
	@deps=();
	for (my $i=0;$i<@depsynsets;$i++) {
	    unless ($deprelations[$i] eq 'synonym') {
		$current_penalty+=$main::hyperonympenalty;
	    }
	    if ($depsynsets[$i] eq $pkg->{synset}) {
		push(@deps,$pkg); # Depsynset);
	    }
	    else {
		my $depsynset=synset->new(wordnetdb,$pkg->{wordnetdb},
					  synset,$depsynsets[$i],
					  logfile,$pkg->{logfile},
					  target,$pkg->{target});
		push(@deps,$depsynset);
	    }
	}
	$picto=picto->new(wordnetdb,$pkg->{wordnetdb},
			       head,$headsynset,
			       file,"$_->[0]".$extension,
			       dep,[@deps],
			       pathlength,$current_penalty,
			       logfile,$pkg->{logfile},
			       target,$pkg->{target});
	if ($url=$_->[6]) {
	  $picto->{url}=$url;
	}
        push(@picto,$picto);
    }
    if (@picto) {
	return [@picto]
    }
    else {
	return undef;
    }
}


sub addRelations {
    my ($pkg)=@_;
    $pkg->addXPosNearSynonyms;
    $pkg->addHyperonyms;
    $pkg->addAntonyms;
}


#---------------------------------------
package display;
#---------------------------------------

@ISA=("object");

#---------------------------------------
package image;
#---------------------------------------

@ISA=("display");

sub getContent {
    my ($pkg)=@_;
    return $pkg->{filename};
}

#---------------------------------------
package text;
#---------------------------------------

@ISA=("display");

sub getContent {
    my ($pkg)=@_;
    return $pkg->{text};
}
