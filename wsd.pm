#!/usr/bin/perl

####### wsd.pm ##########

# By Leen Sevens
# leen@ccl.kuleuven.be
# Date: 14.07.2016

#---------------------------------------
my $VERSION="0.1";
#---------------------------------------

# Implementation of the word sense disambiguation tool by Ruben Izquierdo (https://github.com/rubenIzquierdo/wsd_svm) into the Text-to-Pictograph translation pipeline 
# See also: Sevens L., Jacobs G., Vandeghinste V., Schuurman I., Van Eynde F. (2016). Improving Text-to-Pictograph Translation Through Word Sense Disambiguation. Proceedings of the 5th Joint Conference on Lexical and Computational Semantics. Conference on Lexical and Computational Semantics. Berlin, 11-12 August 2016 (pp. 1-5) Association for Computational Linguistics.

#---------------------------------------

1;

#Locations

our $wsdinput="$Bin/../tmp/wsd/wsdinput";
our $wsdoutput="$Bin/../tmp/wsd/wsdoutput";
our $wsdconvertedoutput="$Bin/../tmp/wsd/wsdconvertedoutput";
our $wsdtool="$Bin/../DutchWSD/svm_wsd-master/dsc_wsd_tagger.py"; 
our $wsdconverter="$Bin/../DutchWSD/svm_wsd-master/TwigDSC.pl";

#---------------------------------------
package message;
#---------------------------------------

my $stamp=time.$main::sessionid;

sub CornettoWsd {
    my ($pkg)=@_;
    $pkg->createNewTextAndLabelObjects;
    if($main::wsdoption eq "on"){
	    $pkg->generateWsdInputFile;
	    $pkg->useWsdTool;
	    $pkg->convertWsd;
	    $pkg->addWsdScores;	
    }
}

sub createNewTextAndLabelObjects {
  my ($pkg)=@_; 
  my $i=0;
  my @arrayofsentences;
  my $target=$pkg->{target};
  my $sentences=$pkg->{sentences};
  foreach $sentence(@$sentences){
	$sentence->{sentenceid}=$i;
	$sentence->{target}=$target;
	$words=$sentence->{words};
	my $j=0;
	my @arrayofwords;
	foreach $word(@$words){
		$word->{wordid}=$j;
		push(@arrayofwords,$word->{token});
		$j++;
	}	
  	$i++;
	$period=".";
        push(@arrayofwords,$period);
	push(@arrayofsentences,@arrayofwords);
  }
$pkg->{newtext}="@arrayofsentences"; 
}

sub generateWsdInputFile{ 
    my ($pkg)=@_;
    my $message=$pkg->{newtext};
    my $pictolanguage=$main::targetlanguage;
    open (WSDINPUT,">$main::wsdinput$stamp-$pictolanguage.txt");
    print WSDINPUT "$message";
    close WSDINPUT;
    return $pkg;
}

sub useWsdTool{
    my $pictolanguage=$main::targetlanguage;
    `cat $main::wsdinput$stamp-$pictolanguage.txt | python $main::wsdtool > $main::wsdoutput$stamp-$pictolanguage.txt`;  
    `rm -f $main::wsdinput$stamp-$pictolanguage.txt`;
}

sub convertWsd{
    my $pictolanguage=$main::targetlanguage;
    `perl $main::wsdconverter $main::wsdoutput$stamp-$pictolanguage.txt > $main::wsdconvertedoutput$stamp-$pictolanguage.txt`;  
    `rm -f $main::wsdoutput$stamp-$pictolanguage.txt`;
}

sub addWsdScores{
    my $pictolanguage=$main::targetlanguage;
    my ($pkg)=@_;
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
}
