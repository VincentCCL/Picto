#----------------------------------------------------------------------------------
#                               Test_two.pl
#----------------------------------------------------------------------------------

#----------------------------------------------------------------------------------
# the aim of this program is to test the accuracy of compounding two word parts,
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
open (FILEHANDLE,">/../../../lowercase.txt")
    or die "Cannot open lowercase.txt";
print FILEHANDLE "$lowercase";
close(FILEHANDLE);

#----------------------------------------------------------------------------------
# try to split up all the words in the 'lowercase' text file into two parts and
# save all the results as a 'splittwo' text file
#----------------------------------------------------------------------------------
@words=split (/ /,$lowercase);# convert the lowercast.txt into a list of words
$preprocessnumber=@words;
foreach $word(@words){
    $word=~ s/([\&\;\:\"\(\)\'])/\\$1/g;
    push(@compareword,$word);
    @parts=`perl Split_two.pl "$word"`;
    # execute the 'Split_two.pl' program, $word as input
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
open (FILEHANDLE,">/../../../splittwo.txt")
    or die "Cannot open splittwo.txt";
print FILEHANDLE "$partlist";
close(FILEHANDLE);

#----------------------------------------------------------------------------------
# re-compound all the word parts in the 'splittwo' text file and save the results
# as a 'recompoundtwo' text file
# add the frequency comparison for judgement
#----------------------------------------------------------------------------------
for ($loop=0;$loop<=$#partlist;$loop++){
    @twowords=();
    @recompound=();
    @twowords=("$partlist[$loop]","$partlist[$loop+1]");
    @recompound=&compound(@twowords);
    $cpt=0.00001;# compound probability threshold value 
    if (@recompound && ($recompound[1]>=$cpt)){
	push (@recompoundarray,$recompound[0]);
	$loop++;
	print "$recompound[0]\n";
    } else {
	push (@recompoundarray,$partlist[$loop]);
	print "$partlist[$loop]\n";
    }
}
$recompoundnumber=@recompoundarray;
$recompoundarray=join(' ',@recompoundarray);
open (FILEHANDLE,">/../../../recompoundtwo.txt")
    or die "Cannot open recompoundtwo.txt";
print FILEHANDLE "$recompoundarray";
close(FILEHANDLE);


#----------------------------------------------------------------------------------
# calculate the correct identification rate of noncompounds and compounds,
# acquire the accuracy of the 'Compound' program 
#----------------------------------------------------------------------------------
$correct=0;
if ($preprocessnumber<$recompoundnumber){
    $boundary=($recompoundnumber-$preprocessnumber)*2;
} else {
    $boundary=($preprocessnumber-$recompoundnumber)*2;
}

# compare the words in 'lowercase' text file with the words in 'recompoundtwo'
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
# re-compound the two input word parts
#----------------------------------------------------------------------------------
sub compound {
    my @compoundlist=@_;
    my @outlist=();
    $compoundnode=join(' ',@compoundlist);
    # execute the 'Compound' program, return the compound and frequency information
    @output=`perl Compound.pl $compoundnode`;
    foreach $out (@output){
	chomp($out);
	push (@outlist,$out);
    }
    return @outlist;
}



