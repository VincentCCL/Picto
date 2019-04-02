#----------------------------------------------------------------------------------
#                               Test_three.pl
#----------------------------------------------------------------------------------

#----------------------------------------------------------------------------------
# the aim of this program is to test the accuracy of compounding three word parts,
# input is a text file for testing
# output is the correct rate of compounding
#----------------------------------------------------------------------------------

## Main Program

#----------------------------------------------------------------------------------
# open an original text file
#----------------------------------------------------------------------------------
open (FILEHANDLE, "/../../../Aspe.txt")
    or die ("Cannot open Aspe.txt");

while ($in=<FILEHANDLE>) {
    chomp($in);
    push(@text,$in);
}
$text=join(' ',@text);
close(FILEHANDLE);

#----------------------------------------------------------------------------------
# pre-process the original text file and save as a 'lowercase' text file
#----------------------------------------------------------------------------------
$lowercase = lc "$text";# convert all uppercases into lowercases
$lowercase=~ s/([\.\,\:\;\!\?\'\"\&\(\)\<\>\[\]\{\}\^])/ $1/g;
# add spaces between words and punctuation marks
open (FILEHANDLE,">/../../../lowercase.txt") or die "Cannot open lowercase.txt";
print FILEHANDLE "$lowercase";
close(FILEHANDLE);

#----------------------------------------------------------------------------------
# try to split up all the words in the 'lowercase' text file into three parts and
# save all the results as a 'splitthree' text file
#----------------------------------------------------------------------------------
@words=split (/ /,$lowercase);# convert the lowercast.txt into a list of words
$preprocessnumber=@words;
foreach $word(@words){
    $word=~ s/([\&\;\:\"\(\)\'])/\\$1/g;
    push (@compareword,$word);
    # execute the 'Split_three.pl' program, $word as input
    @parts=`perl Split_three.pl "$word"`;
    if (@parts){
	foreach $part (@parts) {
	    chomp($part);
	    push (@partlist,$part);
	    print "$part\n";
	}
}else{
    push (@partlist,$word);
    print "$word\n";
}
}
$splitnumber=@partlist;
$partlist=join(' ',@partlist);
open (FILEHANDLE,">/../../../splitthree.txt") or die "Cannot open splitthree.txt";
print FILEHANDLE "$partlist";
close(FILEHANDLE);

#----------------------------------------------------------------------------------
# re-compound all the word parts in the 'splitthree' text file and save the results
# as a 'recompoundthree' text file
# add the frequency comparison for judgement
#----------------------------------------------------------------------------------
for ($loop=0;$loop<=$#partlist;$loop++){
    @threewords=();
    @recompound=();
    @threewords=("$partlist[$loop]","$partlist[$loop+1]","$partlist[$loop+2]");
    @recompound=&compound(@threewords);
    $cpt=0.00005;# compound probability threshold value 
    if (@recompound && ($recompound[1]>=$cpt)){
	push (@recompoundarray,$recompound[0]);
	$loop++;
	$loop++;
	print "$recompound[0]\n";
    } else {
	push (@recompoundarray,$partlist[$loop]);
	print "$partlist[$loop]\n";
    }
}
$recompoundnumber=@recompoundarray;
$recompoundarray=join(' ',@recompoundarray);
open (FILEHANDLE,">/../../../recompoundthree.txt") or die "Cannot open recompoundthree.txt";
print FILEHANDLE "$recompoundarray";
close(FILEHANDLE);


#----------------------------------------------------------------------------------
# calculate the correct identification rate of noncompounds and compounds,
# acquire the accuracy of the 'Compound' program 
#----------------------------------------------------------------------------------
$correct=0;
if ($preprocessnumber<$recompoundnumber){
    $boundary=$recompoundnumber-$preprocessnumber;
} else {
    $boundary=$preprocessnumber-$recompoundnumber;
}
# compare the words in 'lowercase' text file with the words in 'recompoundthree'
# text file one by one
for ($i=0;$i<=$#recompoundarray;$i++){
    if($i<=$boundary){
FOREVER:for ($j=0;$j<=$i+$boundary;$j++){
    if($recompoundarray[$i] eq $compareword[$j]){
	$correct++;
	last FOREVER;
    }
}
} else {
COMMENT:    for ($j=$i-$boundary;$j<=$i+$boundary;$j++){
	if($recompoundarray[$i] eq $compareword[$j]){
	    $correct++;
	    last COMMENT;
	}
       }
}
}
$correctpercent=($correct/$recompoundnumber)*100;
print "$correctpercent\%";
      


#----------------------------------------------------------------------------------
# re-compound the three input word parts
#----------------------------------------------------------------------------------
sub compound {
    my @compoundlist=@_;
    my @outlist=();
    $compoundnode=join(' ',@compoundlist);
    @output=`perl Compound.pl $compoundnode`;
    foreach $out (@output){
	chomp($out);
	push (@outlist,$out);
    }
    return @outlist;
}


