####### FindCharacterRules.pm ##########

# By Leen Sevens 
# leen@ccl.kuleuven.be 
# Date: 14.01.2016

1;

#---------------------------------------
# Contains the character substitution rules
#---------------------------------------

#$VERSION="1.1"; # 15.01.2019; # Character rewrite rules are moved to the Cornetto database
#$VERSION="1.0"; # 14.01.2016; # Version used in Sevens et al. (2016) and Sevens (2018)

#---------------------------------------
package word;
#---------------------------------------

sub findPhoneticVariants { 
    my ($pkg)=@_;
    my @wordvariants=$pkg->createVariants;
    my @retrievedwords=$pkg->returnRealWordVariants(@wordvariants);
    return @retrievedwords;
}

sub createVariants{
    my ($pkg)=@_;
    my $word=$pkg->{token};
    my $spellcheck=$pkg->{spellcheck};
    my @wordvariants=();
    my @retrievedwords=();
    my @allvariantletters=();
    my $nopenalty = 1;
    $frequencytest=$main::lexicon{$word};
    unless($word=~/.*\s.*/){
    if(($spellcheck eq "Non-word") || ($frequencytest < $main::realwordminimumfrequency)){ 
	    $word=lc($word);
	    my @oneletters=split(//,$word);
	    for (my $i=0;$i<@oneletters;$i++) { 
		    my @variantletters=();
	    	    $twoletters="$oneletters[$i]$oneletters[$i+1]";
	    	    $threeletters="$oneletters[$i]$oneletters[$i+1]$oneletters[$i+2]";
	    	    $fourletters="$oneletters[$i]$oneletters[$i+1]$oneletters[$i+2]$oneletters[$i+3]";
                    my $stmt = qq(select * from characterrewriterules where source='$fourletters';); 
		    $rows=$main::spellcheckdatabase->lookup($stmt);
		    if(@$rows){
			while ($row=shift(@$rows)) {
				      my $newcombi=$row->[1];
				      push(@variantletters,$newcombi);
			}
			$i=$i+3;
		    }	
		    else{
			my $stmt2 = qq(select * from characterrewriterules where source='$threeletters';); 
			$rows2=$main::spellcheckdatabase->lookup($stmt2);
			if(@$rows2){
				while ($row2=shift(@$rows2)) {
					      my $newcombi=$row2->[1];
					      push(@variantletters,$newcombi);
				}
				$i=$i+2;
			}	
			else{
				my $stmt3 = qq(select * from characterrewriterules where source='$twoletters';); 
				$rows3=$main::spellcheckdatabase->lookup($stmt3);
				if(@$rows3){
					while ($row3=shift(@$rows3)) {
						      my $newcombi=$row3->[1];
						      push(@variantletters,$newcombi);
					}
					$i++;
				}
				else{
					my $stmt4 = qq(select * from characterrewriterules where source='$oneletters[$i]';); 
					$rows4=$main::spellcheckdatabase->lookup($stmt4);
					if(@$rows4){
						while ($row4=shift(@$rows4)) {
							      my $newcombi=$row4->[1];
							      push(@variantletters,$newcombi);
						}
					}
				}
			   }	
			}	           
			push(@allvariantletters,[@variantletters]);
		      }
		}	
	    }
    my $pattern = join "", map "{$_}", map join( ",", @$_ ), @allvariantletters; 
    push(@wordvariants,glob $pattern);
    return @wordvariants;
}

sub returnRealWordVariants{
    my ($pkg,@wordvariants)=@_;
    my @retrievedwords;
    foreach my $wordvariant (@wordvariants){
	$frequency=$main::lexicon{$wordvariant};
	if ((($main::SPELLCHECKLEX{$wordvariant}) ||
		($main::SPELLCHECKLEX{lc($wordvariant)}) ||
		($wordvariant=~/^[\.\?\!\,\:\;\'\d]+$/)) && ($frequency > $main::frequencyretainvariant)) {
			push(@retrievedwords,$wordvariant);
	}
    }
    return @retrievedwords;
}
