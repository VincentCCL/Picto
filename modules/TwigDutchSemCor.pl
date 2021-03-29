use FindBin qw($Bin); # from CPAN
use XML::Twig;
use Getopt::Std;  

require "$Bin/Database.pm";

getopt("VWXYZ",\%opts);

unless (defined($database=$opts{V})) {
	$database="cornetto3";
}
unless (defined($host=$opts{W})) {
        $host="gobelijn";
}
unless (defined($port=$opts{X})) {
        $port="5432";
}
unless (defined($user=$opts{Y})) {
        $user="vincent";
}
unless (defined($pwd=$opts{Z})){
        $pwd="vincent";
}

$cornetto=DBI::db->new($database,$host,$port,$user,$pwd);

my $file = $ARGV[0];
my $t= XML::Twig->new(twig_handlers => {text => \&page});
$t->parsefile($file);
$t->flush; 
    
sub page { 
	my($t,$page)= @_;  
        my @sentences= $page->children;
	foreach(@sentences){
		my $i=0;
		my $sentencenumber= $_->{'att'}->{'sent_num'};
		my @wfs= $_->children;
		foreach $wf(@wfs){
			my $token=$wf->text;
			my $lemma= $wf->{'att'}->{'lemma'};
			my $senses_confidences= $wf->{'att'}->{'senses_confidences'};
			($removeleftbracket,$rightsidebracket)=split(/\[/,$senses_confidences);
			($leftsidebracket,$removerightbracket)=split(/\]/,$rightsidebracket);
			@senses_confidences_pairs=split(/\), /,$leftsidebracket);
			if(@senses_confidences_pairs){
				foreach(@senses_confidences_pairs){
					($lexunitidwithu,$confidencescore)=split(/', /,$_);
					($randomu,$lexunitid)=split(/'/,$lexunitidwithu);
					$confidencescore=~s/(.*)\)/$1/g;
				
					my $stmt = qq(select synset from lex2syn where lexunit = '$lexunitid';);
					$rows=$cornetto->lookup($stmt);
					while ($row=shift(@$rows)) {
					my $synset = $row->[0];
						print "$sentencenumber\t$i\t$token\t$lemma\t$lexunitid\t$synset\t$confidencescore\n";					
					}
	
				}
			}
			else{
					print "$sentencenumber\t$i\t$token\t$lemma\n";	
			}
			$i++;
		}
	}
	$page->purge;       
}
