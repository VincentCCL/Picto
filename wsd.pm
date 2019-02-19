#!/usr/bin/perl

####### wsd.pm ##########

# By Leen Sevens
# leen@ccl.kuleuven.be
# Date: 14.07.2016

#---------------------------------------
$VERSION="0.2"; # 08.02.2019 VV. Making the whole thing more language independent
#my $VERSION="0.1";
#---------------------------------------

# Implementation of the word sense disambiguation tool by Ruben Izquierdo (https://github.com/rubenIzquierdo/wsd_svm) into the Text-to-Pictograph translation pipeline 
# See also: Sevens L., Jacobs G., Vandeghinste V., Schuurman I., Van Eynde F. (2016). Improving Text-to-Pictograph Translation Through Word Sense Disambiguation. Proceedings of the 5th Joint Conference on Lexical and Computational Semantics. Conference on Lexical and Computational Semantics. Berlin, 11-12 August 2016 (pp. 1-5) Association for Computational Linguistics.

#---------------------------------------

1;

#Locations

# our $wsdinput="$Bin/../tmp/wsd/wsdinput";
# our $wsdoutput="$Bin/../tmp/wsd/wsdoutput";
# our $wsdconvertedoutput="$Bin/../tmp/wsd/wsdconvertedoutput";
# our $wsdtool="$Bin/../DutchWSD/svm_wsd-master/dsc_wsd_tagger.py"; 
# our $wsdconverter="$Bin/TwigDutchSemCor.pl";

#---------------------------------------
package message;
#---------------------------------------

my $stamp=time.$main::sessionid;

sub wsd { # LANGUAGE INDEPENDENT METHOD
  my ($pkg)=@_;
  my $source=$pkg->{source};
  my $method=$source.'wsd';
  $pkg->$method;
}

sub englishwsd {  # THESE ARE NOT IMPLEMENTED (YET)
}
sub spanishwsd { # THESE ARE NOT IMPLEMENTED (YET)
}
########## DUTCH  ##################
#sub CornettoWsd {
sub dutchwsd {
    my ($pkg)=@_;
    $pkg->createNewTextAndLabelObjects;
    #if($main::wsdoption eq "on"){
	    $pkg->generateWsdInputFile;
	    $pkg->useWsdTool;
	    $pkg->convertWsd;
	    $pkg->addWsdScores;	
    #}
}

sub createNewTextAndLabelObjects {
  my ($pkg)=@_; 
  my $i=0;
  my @arrayofsentences;
#   my $target=$pkg->{target};
  my $sentences=$pkg->{sentences};
  foreach (@$sentences){
	$_->{sentenceid}=$i;
# 	$sentence->{target}=$target;
	my $words=$_->{words};
	my @arrayofwords;
	foreach $word(@$words){
		$word->{wordid}=$j;
		push(@arrayofwords,$word->{token});
		$j++;
	}	
  	$i++;
	$period=".";
        #push(@arrayofwords,$period);
	push(@arrayofsentences,@arrayofwords);
  }
$pkg->{newtext}="@arrayofsentences"; 
}

sub generateWsdInputFile{ 
    my ($pkg)=@_;
    my $message=$pkg->{newtext};
    my $pictolanguage=$pkg->{target};
    my $log=$pkg->{logfile};
    print $log "Creating WSD Inputfile $main::wsdinput$stamp-$pictolanguage.txt: \n" if $log;
    open (WSDINPUT,">$main::wsdinput$stamp-$pictolanguage.txt") or die "Can't open $main::wsdinput$stamp-$pictolanguage.txt\n";
    print WSDINPUT "$message";
    print $log "$message\nEnd of WSD Inputfile\n" if $log;
    close WSDINPUT;
    return $pkg;
}

sub useWsdTool{
  my ($pkg)=@_;
  my $log=$pkg->{logfile};
  my $pictolanguage=$main::targetlanguage;
  my $command="cat $main::wsdinput$stamp-$pictolanguage.txt | python $main::wsdtool > $main::wsdoutput$stamp-$pictolanguage.txt";  
  print $log "COMMAND:\n$command\n" if $log;
    `$command`;
    `rm -f $main::wsdinput$stamp-$pictolanguage.txt`;
}

sub convertWsd{
  my ($pkg)=@_;
  my $pictolanguage=$main::targetlanguage;
  my $log=$pkg->{logfile};
  my $command="perl $main::wsdconverter -V $main::database -W $main::host -X $main::port -Y $main::user -Z $main::pwd $main::wsdoutput$stamp-$pictolanguage.txt > $main::wsdconvertedoutput$stamp-$pictolanguage.txt";  
  print $log "COMMAND:\n$command\n" if $log;
  `$command`;
    `rm -f $main::wsdoutput$stamp-$pictolanguage.txt`;
}

sub addWsdScores{
    my ($pkg)=@_;
    my $pictolanguage=$main::targetlanguage;
    my $sentences=$pkg->{sentences};
    foreach (@$sentences){
	my $sentenceid=$_->{sentenceid};
	my $words=$_->{words};
			foreach $word (@$words){
					my $wordid=$word->{wordid};
					my $lexunits=$word->{lexunits};
					foreach $lexunit(@$lexunits){
						my $lexunitid=$lexunit->{id};
						my $synset=$lexunit->{synset};
						$synsetid=$synset->{synset};
					    	open (SCOREFILE,"$main::wsdconvertedoutput$stamp-$pictolanguage.txt");
						while(my $line=<SCOREFILE>){
							chomp $line;
							($wsdsentenceid,$wsdwordid,$wsdtoken,$wsdlemma,$wsdlexunit,$wsdsynset,$wsdscore)=split(/\t/,$line);
							if (($wsdsentenceid eq $sentenceid) && ($wsdwordid eq $wordid) && ($wsdlexunit eq $lexunitid) && ($wsdsynset eq $synsetid)){
								$lexunit->{wsdscore}=$wsdscore;
								$synset->{wsdscore}=$wsdscore; 
							}
						}
						close SCOREFILE;
					}
			}
    } 		$flag;
`rm -f $main::wsdconvertedoutput$stamp-$pictolanguage.txt`;
 $pkg->showInLog;
}
