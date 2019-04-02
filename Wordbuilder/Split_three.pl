#----------------------------------------------------------------------------------
#                               Split_three.pl
#----------------------------------------------------------------------------------

#----------------------------------------------------------------------------------
# the aim of this program is to check whether the input word can be splited up into
# three word parts
#----------------------------------------------------------------------------------

use Node;

#----------------------------------------------------------------------------------
# the two databases are the same as those of the program 'Compound.pl'
#----------------------------------------------------------------------------------
$dbase="/../../../Data/Lexical/DB/cgn_lexicon.db";
$quasibase="/../../../Data/Lexical/DB/quasi.db";

dbmopen(%LEXICON,$dbase,0644);
dbmopen(%QUASI,$quasibase,0644);
@posarray=('N','WW','ADJ','VZ');

@input_parts=@ARGV;
$word=$input_parts[0];
&try_divide($word);

#----------------------------------------------------------------------------------
# try to split up the input word into three word parts
#----------------------------------------------------------------------------------
sub try_divide{
    my $word=$_[0];
    my $length=length($word);
    my $position,$first,$last,$firstresult,$lastresult;
    my @firstkey,@lastkey;
    for($position=1;$position<=$length;$position++){
	($first,$last)=$word=~/(.{$position})(.+)$/;
	@firstkey=&judgement($first);
	@lastkey=&judgement($last);
	if (@firstkey && @lastkey){
            # estimate if the first part can be re-splited up
	    @firstresult=&re_divide(@firstkey);
	    if (@firstresult){
		print "$firstresult[0]\n";
		print "$firstresult[1]\n";
		print "$lastkey[0]\n";
		return;
	    }
            # estimate if the last part can be re-splited up
            @lastresult=&re_divide(@lastkey);
	    if (@lastresult){
		print "$firstkey[0]\n";
		print "$lastresult[0]\n";
		print "$lastresult[1]\n";
		return;
	    }
	}
    }
}


#----------------------------------------------------------------------------------
# try to re-split up the input word part
#----------------------------------------------------------------------------------
sub re_divide{
    my $reword=$_[0];
    my $relength=length($reword);
    my $reposition,$refirst,$relast,$refirstresult,$relastresult;
    my @refirstkey,@relastkey;
    for($reposition=1;$reposition<=$relength;$reposition++){
	($refirst,$relast)=$reword=~/(.{$reposition})(.+)$/;
	@refirstkey=&judgement($refirst);
	@relastkey=&judgement($relast);
	if (@refirstkey && @relastkey){
	    return (@refirstkey,@relastkey);
	}
    }
    return;
}


#----------------------------------------------------------------------------------
# estimate if the input word part is available in the cgn lexicon
# or in the quasi-word-list
#----------------------------------------------------------------------------------
sub judgement{
    my $part=$_[0];
 if ($LEXICON{$part}){
	$value=$LEXICON{$part};
       ($tag,$lemma)=split(/\t/,$value);
       ($pos,$bpos)=split(/\(/,$tag);
	foreach $key(@posarray){
	    if ($pos eq $key){
		return $part;
	    } 
	    }
	return ();
} elsif ($QUASI{$part}){
     return $part;
} else{
     return;
 }
}

