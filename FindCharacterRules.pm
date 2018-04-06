####### FindCharacterRules.pm ##########

# By Leen Sevens 
# leen@ccl.kuleuven.be 
# Date: 14.01.2016

1;

#---------------------------------------

# Contains the character substitution rules for SpellCorrector_cornetto.pl

#---------------------------------------
package word;
#---------------------------------------

sub findPhoneticVariants { 
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
	    my @oneletters=split(//,$word);
	    for (my $i=0;$i<@oneletters;$i++) { 
		    my @variantletters=();
		    $j=$i+1;
		    $k=$i+2; 
	            $l=$i+3;
	    	    $twoletters="$oneletters[$i]$oneletters[$j]";
	    	    $threeletters="$oneletters[$i]$oneletters[$j]$oneletters[$k]";
	    	    $fourletters="$oneletters[$i]$oneletters[$j]$oneletters[$k]$oneletters[$l]";
 		        if ($fourletters eq "aagt") {
				push(@variantletters,"aagd|0.25");
				push(@variantletters,"aagt|0.75");
				$i=$i+3;
			}
			elsif ($fourletters eq "aait") {
				push(@variantletters,"aaid|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "aall") {
				push(@variantletters,"all|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "aalp") {
				push(@variantletters,"lap|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "aand") {
				push(@variantletters,"aand|0.909090909090909");
				push(@variantletters,"and|0.0909090909090909");
				$i=$i+3;
			}
			elsif ($fourletters eq "aane") {
				push(@variantletters,"anne|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "aapa") {
				push(@variantletters,"apa|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "aape") {
				push(@variantletters,"ape|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "aard") {
				push(@variantletters,"aard|0.9");
				push(@variantletters,"aart|0.1");
				$i=$i+3;
			}
			elsif ($fourletters eq "aart") {
				push(@variantletters,"aagt|0.125");
				push(@variantletters,"aard|0.125");
				push(@variantletters,"aart|0.75");
				$i=$i+3;
			}
			elsif ($fourletters eq "aase") {
				push(@variantletters,"ase|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "aate") {
				push(@variantletters,"ate|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "adle") {
				push(@variantletters,"alle|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "akas") {
				push(@variantletters,"akan|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "allo") {
				push(@variantletters,"all|0.0208333333333333");
				push(@variantletters,"allo|0.979166666666667");
				$i=$i+3;
			}
			elsif ($fourletters eq "alls") {
				push(@variantletters,"als|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "altt") {
				push(@variantletters,"att|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ameh") {
				push(@variantletters,"amen|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "amme") {
				push(@variantletters,"ame|0.25");
				push(@variantletters,"amme|0.75");
				$i=$i+3;
			}
			elsif ($fourletters eq "amyo") {
				push(@variantletters,"amio|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "andw") {
				push(@variantletters,"antw|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "anee") {
				push(@variantletters,"nnee|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ange") {
				push(@variantletters,"ang|0.5");
				push(@variantletters,"ange|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "anka") {
				push(@variantletters,"aka|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ansi") {
				push(@variantletters,"anti|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "anta") {
				push(@variantletters,"anto|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ants") {
				push(@variantletters,"ant|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ardj") {
				push(@variantletters,"artj|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "areo") {
				push(@variantletters,"aro|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "aroc") {
				push(@variantletters,"arok|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "atte") {
				push(@variantletters,"at|0.0714285714285714");
				push(@variantletters,"atte|0.928571428571429");
				$i=$i+3;
			}
			elsif ($fourletters eq "badl") {
				push(@variantletters,"ball|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "bben") {
				push(@variantletters,"b|0.0625");
				push(@variantletters,"bben|0.9375");
				$i=$i+3;
			}
			elsif ($fourletters eq "bbro") {
				push(@variantletters,"bro|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "beec") {
				push(@variantletters,"beet|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "belt") {
				push(@variantletters,"beld|0.5");
				push(@variantletters,"belt|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "bent") {
				push(@variantletters,"ben|0.1");
				push(@variantletters,"bent|0.9");
				$i=$i+3;
			}
			elsif ($fourletters eq "byou") {
				push(@variantletters,"you|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "chal") {
				push(@variantletters,"cha|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "chat") {
				push(@variantletters,"cha|0.0227272727272727");
				push(@variantletters,"chat|0.977272727272727");
				$i=$i+3;
			}
			elsif ($fourletters eq "chee") {
				push(@variantletters,"che|0.25");
				push(@variantletters,"chee|0.5");
				push(@variantletters,"chre|0.25");
				$i=$i+3;
			}
			elsif ($fourletters eq "chif") {
				push(@variantletters,"chip|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "chjt") {
				push(@variantletters,"cht|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "chri") {
				push(@variantletters,"chre|0.0909090909090909");
				push(@variantletters,"chri|0.909090909090909");
				$i=$i+3;
			}
			elsif ($fourletters eq "chry") {
				push(@variantletters,"chri|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "daag") {
				push(@variantletters,"daag|0.9");
				push(@variantletters,"dag|0.1");
				$i=$i+3;
			}
			elsif ($fourletters eq "dest") {
				push(@variantletters,"best|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "dinn") {
				push(@variantletters,"din|0.5");
				push(@variantletters,"dinn|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "djes") {
				push(@variantletters,"djes|0.75");
				push(@variantletters,"tjes|0.25");
				$i=$i+3;
			}
			elsif ($fourletters eq "doed") {
				push(@variantletters,"doet|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "dtje") {
				push(@variantletters,"tje|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "dwoo") {
				push(@variantletters,"twoo|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eaan") {
				push(@variantletters,"aan|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ebbe") {
				push(@variantletters,"eb|0.0625");
				push(@variantletters,"ebbe|0.9375");
				$i=$i+3;
			}
			elsif ($fourletters eq "ebie") {
				push(@variantletters,"ubie|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eden") {
				push(@variantletters,"eden|0.8");
				push(@variantletters,"nden|0.2");
				$i=$i+3;
			}
			elsif ($fourletters eq "edje") {
				push(@variantletters,"edje|0.75");
				push(@variantletters,"etje|0.25");
				$i=$i+3;
			}
			elsif ($fourletters eq "edtj") {
				push(@variantletters,"etj|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eege") {
				push(@variantletters,"eeg|0.166666666666667");
				push(@variantletters,"eege|0.166666666666667");
				push(@variantletters,"ege|0.666666666666667");
				$i=$i+3;
			}
			elsif ($fourletters eq "eeke") {
				push(@variantletters,"eeke|0.5");
				push(@variantletters,"eke|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "eele") {
				push(@variantletters,"ele|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eelu") {
				push(@variantletters,"elu|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eeme") {
				push(@variantletters,"eme|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eete") {
				push(@variantletters,"ete|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eetg") {
				push(@variantletters,"eet|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eeve") {
				push(@variantletters,"reve|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eevt") {
				push(@variantletters,"eeft|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "efee") {
				push(@variantletters,"eef|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "egea") {
				push(@variantletters,"ega|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "egen") {
				push(@variantletters,"egen|0.954545454545455");
				push(@variantletters,"gen|0.0454545454545455");
				$i=$i+3;
			}
			elsif ($fourletters eq "ehwo") {
				push(@variantletters,"enwo|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ejaa") {
				push(@variantletters,"jaa|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eken") {
				push(@variantletters,"eken|0.964285714285714");
				push(@variantletters,"nken|0.0357142857142857");
				$i=$i+3;
			}
			elsif ($fourletters eq "ekom") {
				push(@variantletters,"eko|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ekre") {
				push(@variantletters,"ekr|0.125");
				push(@variantletters,"ekre|0.875");
				$i=$i+3;
			}
			elsif ($fourletters eq "elke") {
				push(@variantletters,"elk|0.2");
				push(@variantletters,"elke|0.8");
				$i=$i+3;
			}
			elsif ($fourletters eq "ello") {
				push(@variantletters,"allo|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eloo") {
				push(@variantletters,"eloo|0.5");
				push(@variantletters,"elov|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "ente") {
				push(@variantletters,"ende|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ents") {
				push(@variantletters,"ends|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eote") {
				push(@variantletters,"ete|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "epje") {
				push(@variantletters,"etje|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "epoo") {
				push(@variantletters,"ppo|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "erda") {
				push(@variantletters,"erd|0.0769230769230769");
				push(@variantletters,"erda|0.923076923076923");
				$i=$i+3;
			}
			elsif ($fourletters eq "erle") {
				push(@variantletters,"erl|0.333333333333333");
				push(@variantletters,"erle|0.666666666666667");
				$i=$i+3;
			}
			elsif ($fourletters eq "esme") {
				push(@variantletters,"esm|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "eteg") {
				push(@variantletters,"etig|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ette") {
				push(@variantletters,"ette|0.666666666666667");
				push(@variantletters,"itte|0.333333333333333");
				$i=$i+3;
			}
			elsif ($fourletters eq "ezic") {
				push(@variantletters,"ezic|0.5");
				push(@variantletters,"ezig|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "feed") {
				push(@variantletters,"eft|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ffol") {
				push(@variantletters,"ffel|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "flie") {
				push(@variantletters,"flip|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "fven") {
				push(@variantletters,"ven|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "gaan") {
				push(@variantletters,"ga|0.0645161290322581");
				push(@variantletters,"gaan|0.903225806451613");
				push(@variantletters,"gaat|0.032258064516129");
				$i=$i+3;
			}
			elsif ($fourletters eq "geaa") {
				push(@variantletters,"gaa|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "geel") {
				push(@variantletters,"gel|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "gent") {
				push(@variantletters,"gend|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "gery") {
				push(@variantletters,"gri|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "goej") {
				push(@variantletters,"goei|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "goet") {
				push(@variantletters,"goed|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "groo") {
				push(@variantletters,"gro|0.333333333333333");
				push(@variantletters,"groo|0.666666666666667");
				$i=$i+3;
			}
			elsif ($fourletters eq "gron") {
				push(@variantletters,"grond|0.333333333333333");
				$i=$i+3;
			}
			elsif ($fourletters eq "haal") {
				push(@variantletters,"hal|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "haan") {
				push(@variantletters,"gaan|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "haar") {
				push(@variantletters,"haar|0.9");
				push(@variantletters,"haat|0.1");
				$i=$i+3;
			}
			elsif ($fourletters eq "halt") {
				push(@variantletters,"hat|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "hard") {
				push(@variantletters,"hard|0.888888888888889");
				push(@variantletters,"hart|0.111111111111111");
				$i=$i+3;
			}
			elsif ($fourletters eq "hart") {
				push(@variantletters,"hard|0.333333333333333");
				push(@variantletters,"hart|0.666666666666667");
				$i=$i+3;
			}
			elsif ($fourletters eq "hatt") {
				push(@variantletters,"hat|0.0769230769230769");
				push(@variantletters,"hatt|0.923076923076923");
				$i=$i+3;
			}
			elsif ($fourletters eq "hebb") {
				push(@variantletters,"heb|0.0625");
				push(@variantletters,"hebb|0.9375");
				$i=$i+3;
			}
			elsif ($fourletters eq "hebt") {
				push(@variantletters,"heb|0.2");
				push(@variantletters,"hebt|0.8");
				$i=$i+3;
			}
			elsif ($fourletters eq "heel") {
				push(@variantletters,"heel|0.980769230769231");
				push(@variantletters,"hel|0.0192307692307692");
				$i=$i+3;
			}
			elsif ($fourletters eq "heev") {
				push(@variantletters,"heef|0.5");
				push(@variantletters,"hrev|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "heey") {
				push(@variantletters,"hey|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "hefe") {
				push(@variantletters,"hee|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "hell") {
				push(@variantletters,"hall|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "helt") {
				push(@variantletters,"het|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "hiem") {
				push(@variantletters,"hien|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "hjij") {
				push(@variantletters,"hij|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "hjtj") {
				push(@variantletters,"htj|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "hoed") {
				push(@variantletters,"goed|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "hoob") {
				push(@variantletters,"hob|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "hrij") {
				push(@variantletters,"hre|0.111111111111111");
				push(@variantletters,"hrij|0.888888888888889");
				$i=$i+3;
			}
			elsif ($fourletters eq "hwon") {
				push(@variantletters,"nwon|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ichj") {
				push(@variantletters,"ich|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "iede") {
				push(@variantletters,"iede|0.8");
				push(@variantletters,"inde|0.2");
				$i=$i+3;
			}
			elsif ($fourletters eq "ieft") {
				push(@variantletters,"iefd|0.5");
				push(@variantletters,"ieft|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "ieke") {
				push(@variantletters,"ieke|0.833333333333333");
				push(@variantletters,"inke|0.166666666666667");
				$i=$i+3;
			}
			elsif ($fourletters eq "iens") {
				push(@variantletters,"ien|0.666666666666667");
				push(@variantletters,"iens|0.333333333333333");
				$i=$i+3;
			}
			elsif ($fourletters eq "ient") {
				push(@variantletters,"iend|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "iepo") {
				push(@variantletters,"ipp|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "iete") {
				push(@variantletters,"iete|0.5");
				push(@variantletters,"ieti|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "iett") {
				push(@variantletters,"iet|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "iine") {
				push(@variantletters,"onne|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ijfv") {
				push(@variantletters,"ijv|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ijve") {
				push(@variantletters,"eve|0.166666666666667");
				push(@variantletters,"ijft|0.166666666666667");
				push(@variantletters,"ijve|0.666666666666667");
				$i=$i+3;
			}
			elsif ($fourletters eq "ille") {
				push(@variantletters,"il|0.5");
				push(@variantletters,"ille|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "inde") {
				push(@variantletters,"ind|0.2");
				push(@variantletters,"inde|0.8");
				$i=$i+3;
			}
			elsif ($fourletters eq "indt") {
				push(@variantletters,"ind|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "inen") {
				push(@variantletters,"nnen|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "innd") {
				push(@variantletters,"iend|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "isie") {
				push(@variantletters,"ecie|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "itta") {
				push(@variantletters,"ita|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "itte") {
				push(@variantletters,"it|0.25");
				push(@variantletters,"itte|0.75");
				$i=$i+3;
			}
			elsif ($fourletters eq "iute") {
				push(@variantletters,"ite|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "jfve") {
				push(@variantletters,"jve|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "jouw") {
				push(@variantletters,"jou|0.583333333333333");
				push(@variantletters,"jouw|0.416666666666667");
				$i=$i+3;
			}
			elsif ($fourletters eq "jtje") {
				push(@variantletters,"tje|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "jven") {
				push(@variantletters,"jft|0.166666666666667");
				push(@variantletters,"jven|0.666666666666667");
				push(@variantletters,"ven|0.166666666666667");
				$i=$i+3;
			}
			elsif ($fourletters eq "kamy") {
				push(@variantletters,"cami|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "kans") {
				push(@variantletters,"kant|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ken.") {
				push(@variantletters,"ken|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "kent") {
				push(@variantletters,"kend|0.5");
				push(@variantletters,"kent|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "kige") {
				push(@variantletters,"kig|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "king") {
				push(@variantletters,"kig|0.5");
				push(@variantletters,"king|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "kiye") {
				push(@variantletters,"kije|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "koel") {
				push(@variantletters,"cool|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "kome") {
				push(@variantletters,"kom|0.0333333333333333");
				push(@variantletters,"kome|0.966666666666667");
				$i=$i+3;
			}
			elsif ($fourletters eq "komm") {
				push(@variantletters,"kom|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "komt") {
				push(@variantletters,"kom|0.1");
				push(@variantletters,"komt|0.9");
				$i=$i+3;
			}
			elsif ($fourletters eq "kont") {
				push(@variantletters,"komt|0.5");
				push(@variantletters,"kont|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "koom") {
				push(@variantletters,"kom|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "kost") {
				push(@variantletters,"kon|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "kree") {
				push(@variantletters,"kre|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "laap") {
				push(@variantletters,"laap|0.666666666666667");
				push(@variantletters,"lap|0.333333333333333");
				$i=$i+3;
			}
			elsif ($fourletters eq "leeg") {
				push(@variantletters,"leeg|0.5");
				push(@variantletters,"leg|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "leel") {
				push(@variantletters,"lel|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "leen") {
				push(@variantletters,"leen|0.875");
				push(@variantletters,"len|0.125");
				$i=$i+3;
			}
			elsif ($fourletters eq "liee") {
				push(@variantletters,"lieg|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "liep") {
				push(@variantletters,"lipp|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "llen") {
				push(@variantletters,"l|0.0769230769230769");
				push(@variantletters,"llen|0.923076923076923");
				$i=$i+3;
			}
			elsif ($fourletters eq "lloo") {
				push(@variantletters,"llo|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "loge") {
				push(@variantletters,"oge|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "loof") {
				push(@variantletters,"loof|0.5");
				push(@variantletters,"lov|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "ltte") {
				push(@variantletters,"tte|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "luke") {
				push(@variantletters,"luke|0.5");
				push(@variantletters,"lukk|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "luuk") {
				push(@variantletters,"leuk|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "mant") {
				push(@variantletters,"mand|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "mder") {
				push(@variantletters,"nder|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "mehw") {
				push(@variantletters,"menw|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "mest") {
				push(@variantletters,"mst|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "miek") {
				push(@variantletters,"mink|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "mien") {
				push(@variantletters,"mijn|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "miet") {
				push(@variantletters,"niet|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "mmen") {
				push(@variantletters,"men|0.111111111111111");
				push(@variantletters,"mmen|0.833333333333333");
				push(@variantletters,"mmer|0.0555555555555556");
				$i=$i+3;
			}
			elsif ($fourletters eq "moed") {
				push(@variantletters,"moed|0.5");
				push(@variantletters,"moet|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "myon") {
				push(@variantletters,"mion|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "naar") {
				push(@variantletters,"na|0.0131578947368421");
				push(@variantletters,"naar|0.986842105263158");
				$i=$i+3;
			}
			elsif ($fourletters eq "ndag") {
				push(@variantletters,"dag|0.0588235294117647");
				push(@variantletters,"ndag|0.941176470588235");
				$i=$i+3;
			}
			elsif ($fourletters eq "nden") {
				push(@variantletters,"nd|0.166666666666667");
				push(@variantletters,"nden|0.833333333333333");
				$i=$i+3;
			}
			elsif ($fourletters eq "ndin") {
				push(@variantletters,"ndi|0.0555555555555556");
				push(@variantletters,"ndin|0.944444444444444");
				$i=$i+3;
			}
			elsif ($fourletters eq "ndwo") {
				push(@variantletters,"ntwo|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "neem") {
				push(@variantletters,"neem|0.5");
				push(@variantletters,"nem|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "nger") {
				push(@variantletters,"ngr|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "niet") {
				push(@variantletters,"niet|0.992125984251969");
				$i=$i+3;
			}
			elsif ($fourletters eq "nkan") {
				push(@variantletters,"kan|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "nnde") {
				push(@variantletters,"ende|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "noot") {
				push(@variantletters,"nodi|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "nsie") {
				push(@variantletters,"ntie|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ntaf") {
				push(@variantletters,"ntof|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ntsc") {
				push(@variantletters,"ndsc|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ntsi") {
				push(@variantletters,"nti|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oedj") {
				push(@variantletters,"oetj|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oedt") {
				push(@variantletters,"oet|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oeje") {
				push(@variantletters,"oeie|0.5");
				push(@variantletters,"oeje|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "oepj") {
				push(@variantletters,"oetj|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oesn") {
				push(@variantletters,"oen|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ofen") {
				push(@variantletters,"ven|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oije") {
				push(@variantletters,"oie|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "olgu") {
				push(@variantletters,"olge|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "omde") {
				push(@variantletters,"onde|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "omen") {
				push(@variantletters,"om|0.03125");
				push(@variantletters,"omen|0.96875");
				$i=$i+3;
			}
			elsif ($fourletters eq "omme") {
				push(@variantletters,"ome|0.5");
				push(@variantletters,"omme|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "oobb") {
				push(@variantletters,"obb|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oofe") {
				push(@variantletters,"ove|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ooft") {
				push(@variantletters,"oofd|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ooie") {
				push(@variantletters,"ooi|0.166666666666667");
				push(@variantletters,"ooie|0.833333333333333");
				$i=$i+3;
			}
			elsif ($fourletters eq "ooij") {
				push(@variantletters,"ooi|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oome") {
				push(@variantletters,"ome|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oomu") {
				push(@variantletters,"ome|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oore") {
				push(@variantletters,"oord|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oorr") {
				push(@variantletters,"oor|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oort") {
				push(@variantletters,"oord|0.5");
				push(@variantletters,"oort|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "oote") {
				push(@variantletters,"odi|0.5");
				push(@variantletters,"ote|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "oren") {
				push(@variantletters,"ord|0.2");
				push(@variantletters,"oren|0.8");
				$i=$i+3;
			}
			elsif ($fourletters eq "orie") {
				push(@variantletters,"orie|0.8");
				push(@variantletters,"orry|0.2");
				$i=$i+3;
			}
			elsif ($fourletters eq "oriy") {
				push(@variantletters,"orry|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "orrd") {
				push(@variantletters,"ord|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oteg") {
				push(@variantletters,"dig|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "oten") {
				push(@variantletters,"ten|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "owen") {
				push(@variantletters,"wen|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "paap") {
				push(@variantletters,"pap|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "paas") {
				push(@variantletters,"paas|0.833333333333333");
				push(@variantletters,"pas|0.166666666666667");
				$i=$i+3;
			}
			elsif ($fourletters eq "peel") {
				push(@variantletters,"peel|0.9");
				push(@variantletters,"pel|0.1");
				$i=$i+3;
			}
			elsif ($fourletters eq "pend") {
				push(@variantletters,"pend|0.5");
				push(@variantletters,"pent|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "pitt") {
				push(@variantletters,"pit|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "pjes") {
				push(@variantletters,"tjes|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "praa") {
				push(@variantletters,"pra|0.166666666666667");
				push(@variantletters,"praa|0.833333333333333");
				$i=$i+3;
			}
			elsif ($fourletters eq "pree") {
				push(@variantletters,"pre|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "pris") {
				push(@variantletters,"prec|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "raar") {
				push(@variantletters,"raag|0.5");
				push(@variantletters,"raar|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "raat") {
				push(@variantletters,"raat|0.888888888888889");
				push(@variantletters,"rat|0.111111111111111");
				$i=$i+3;
			}
			elsif ($fourletters eq "rdaa") {
				push(@variantletters,"rda|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "rdje") {
				push(@variantletters,"rtje|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "reeg") {
				push(@variantletters,"reg|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "reek") {
				push(@variantletters,"reek|0.2");
				push(@variantletters,"rek|0.8");
				$i=$i+3;
			}
			elsif ($fourletters eq "reom") {
				push(@variantletters,"rom|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "reug") {
				push(@variantletters,"rug|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "rijf") {
				push(@variantletters,"rij|0.2");
				push(@variantletters,"rijf|0.8");
				$i=$i+3;
			}
			elsif ($fourletters eq "rijv") {
				push(@variantletters,"rev|0.25");
				push(@variantletters,"rijf|0.25");
				push(@variantletters,"rijv|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "risi") {
				push(@variantletters,"reci|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "rkiy") {
				push(@variantletters,"rkij|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "rlee") {
				push(@variantletters,"rle|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "roed") {
				push(@variantletters,"roe|0.5");
				push(@variantletters,"roet|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "roep") {
				push(@variantletters,"roep|0.666666666666667");
				push(@variantletters,"roet|0.333333333333333");
				$i=$i+3;
			}
			elsif ($fourletters eq "root") {
				push(@variantletters,"root|0.666666666666667");
				push(@variantletters,"rot|0.333333333333333");
				$i=$i+3;
			}
			elsif ($fourletters eq "rrde") {
				push(@variantletters,"rde|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "rstu") {
				push(@variantletters,"rst|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "saal") {
				push(@variantletters,"sla|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "sach") {
				push(@variantletters,"zach|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "samm") {
				push(@variantletters,"sam|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "sche") {
				push(@variantletters,"sch|0.166666666666667");
				push(@variantletters,"sche|0.666666666666667");
				push(@variantletters,"schr|0.166666666666667");
				$i=$i+3;
			}
			elsif ($fourletters eq "sebi") {
				push(@variantletters,"subi|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "segt") {
				push(@variantletters,"zegt|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "sies") {
				push(@variantletters,"cies|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "slaa") {
				push(@variantletters,"sla|0.25");
				push(@variantletters,"slaa|0.75");
				$i=$i+3;
			}
			elsif ($fourletters eq "smes") {
				push(@variantletters,"sms|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "snda") {
				push(@variantletters,"sda|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "sori") {
				push(@variantletters,"sorr|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "spee") {
				push(@variantletters,"spe|0.1");
				push(@variantletters,"spee|0.9");
				$i=$i+3;
			}
			elsif ($fourletters eq "spre") {
				push(@variantletters,"spr|0.25");
				push(@variantletters,"spre|0.75");
				$i=$i+3;
			}
			elsif ($fourletters eq "stuu") {
				push(@variantletters,"stu|0.111111111111111");
				push(@variantletters,"stuu|0.888888888888889");
				$i=$i+3;
			}
			elsif ($fourletters eq "tafo") {
				push(@variantletters,"toff|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "tbad") {
				push(@variantletters,"tbal|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "teeg") {
				push(@variantletters,"teg|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "tege") {
				push(@variantletters,"ige|0.125");
				push(@variantletters,"tege|0.875");
				$i=$i+3;
			}
			elsif ($fourletters eq "tery") {
				push(@variantletters,"ter|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "tijt") {
				push(@variantletters,"tijd|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "toor") {
				push(@variantletters,"oor|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "tsch") {
				push(@variantletters,"dsch|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "tsie") {
				push(@variantletters,"tie|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ttab") {
				push(@variantletters,"tab|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "tten") {
				push(@variantletters,"t|0.05");
				push(@variantletters,"tten|0.95");
				$i=$i+3;
			}
			elsif ($fourletters eq "ture") {
				push(@variantletters,"teru|0.0769230769230769");
				push(@variantletters,"ture|0.923076923076923");
				$i=$i+3;
			}
			elsif ($fourletters eq "tuur") {
				push(@variantletters,"tur|0.1");
				push(@variantletters,"tuur|0.9");
				$i=$i+3;
			}
			elsif ($fourletters eq "uffo") {
				push(@variantletters,"uffe|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ufra") {
				push(@variantletters,"ufro|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "uowe") {
				push(@variantletters,"uwe|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "ureg") {
				push(@variantletters,"erug|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "uten") {
				push(@variantletters,"ten|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "uure") {
				push(@variantletters,"ure|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "uurt") {
				push(@variantletters,"uurd|0.875");
				push(@variantletters,"uurt|0.125");
				$i=$i+3;
			}
			elsif ($fourletters eq "vaan") {
				push(@variantletters,"van|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "vakz") {
				push(@variantletters,"vaka|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "vank") {
				push(@variantletters,"vak|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "vant") {
				push(@variantletters,"want|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "vied") {
				push(@variantletters,"vind|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "vint") {
				push(@variantletters,"vind|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "vlog") {
				push(@variantletters,"vog|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "waan") {
				push(@variantletters,"wann|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "wand") {
				push(@variantletters,"wand|0.5");
				push(@variantletters,"want|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "wani") {
				push(@variantletters,"wann|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "weet") {
				push(@variantletters,"weet|0.952380952380952");
				push(@variantletters,"wet|0.0476190476190476");
				$i=$i+3;
			}
			elsif ($fourletters eq "weja") {
				push(@variantletters,"wja|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "wiel") {
				push(@variantletters,"wil|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "wiin") {
				push(@variantletters,"wonn|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "will") {
				push(@variantletters,"wil|0.5");
				push(@variantletters,"will|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "woes") {
				push(@variantletters,"woe|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "woor") {
				push(@variantletters,"woo|0.25");
				push(@variantletters,"woor|0.75");
				$i=$i+3;
			}
			elsif ($fourletters eq "wort") {
				push(@variantletters,"word|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "wtoo") {
				push(@variantletters,"woo|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "wwat") {
				push(@variantletters,"wat|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "zeek") {
				push(@variantletters,"zeek|0.5");
				push(@variantletters,"zek|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "zegt") {
				push(@variantletters,"zegd|0.111111111111111");
				push(@variantletters,"zegt|0.888888888888889");
				$i=$i+3;
			}
			elsif ($fourletters eq "zett") {
				push(@variantletters,"zett|0.5");
				push(@variantletters,"zitt|0.5");
				$i=$i+3;
			}
			elsif ($fourletters eq "zich") {
				push(@variantletters,"zich|0.666666666666667");
				push(@variantletters,"zig|0.333333333333333");
				$i=$i+3;
			}
			elsif ($fourletters eq "zien") {
				push(@variantletters,"zie|0.0714285714285714");
				push(@variantletters,"zien|0.928571428571429");
				$i=$i+3;
			}
			elsif ($fourletters eq "ziet") {
				push(@variantletters,"zit|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "zijd") {
				push(@variantletters,"zijt|1");
				$i=$i+3;
			}
			elsif ($fourletters eq "zitt") {
				push(@variantletters,"zit|0.25");
				push(@variantletters,"zitt|0.75");
				$i=$i+3;
			}
			elsif ($fourletters eq "zohe") {
				push(@variantletters,"zone|1");
				$i=$i+3;
			}
			elsif ($threeletters eq "aag") {
				push(@variantletters,"aag|0.970149253731343");
				push(@variantletters,"ag|0.0298507462686567");
				push(@variantletters,"raag|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "aal") {
				push(@variantletters,"aal|0.75");
				push(@variantletters,"al|0.166666666666667");
				push(@variantletters,"la|0.0833333333333333");
				push(@variantletters,"aalt|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "aan") {
				push(@variantletters,"a|0.0224719101123595");
				push(@variantletters,"aan|0.943820224719101");
				push(@variantletters,"aat|0.0112359550561798");
				push(@variantletters,"an|0.0112359550561798");
				push(@variantletters,"ann|0.0112359550561798");
				$i=$i+2;
			}
			elsif ($threeletters eq "aap") {
				push(@variantletters,"aap|0.6");
				push(@variantletters,"ap|0.4");
				$i=$i+2;
			}
			elsif ($threeletters eq "aar") {
				push(@variantletters,"aag|0.0100502512562814");
				push(@variantletters,"aar|0.979899497487437");
				push(@variantletters,"aar|0.333333333333333");
				push(@variantletters,"aars|0.333333333333333");
				push(@variantletters,"raag|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "aas") {
				push(@variantletters,"aas|0.888888888888889");
				push(@variantletters,"as|0.111111111111111");
				push(@variantletters,"arts|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "aat") {
				push(@variantletters,"aat|0.9875");
				push(@variantletters,"at|0.0125");
				$i=$i+2;
			}
			elsif ($threeletters eq "ach") {
				push(@variantletters,"acht|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "adl") {
				push(@variantletters,"all|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "afo") {
				push(@variantletters,"off|1");
				push(@variantletters,"offe|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "age") {
				push(@variantletters,"agen|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "agt") {
				push(@variantletters,"agd|0.25");
				push(@variantletters,"agt|0.75");
				$i=$i+2;
			}
			elsif ($threeletters eq "ait") {
				push(@variantletters,"aid|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ake") {
				push(@variantletters,"akke|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "akz") {
				push(@variantletters,"aka|1");
				push(@variantletters,"akan|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ale") {
				push(@variantletters,"alle|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "alj") {
				push(@variantletters,"altj|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "all") {
				push(@variantletters,"al|0.0338983050847458");
				push(@variantletters,"all|0.966101694915254");
				push(@variantletters,"alle|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "alo") {
				push(@variantletters,"allo|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "alp") {
				push(@variantletters,"ap|1");
				push(@variantletters,"ape|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "alt") {
				push(@variantletters,"alt|0.857142857142857");
				push(@variantletters,"at|0.142857142857143");
				$i=$i+2;
			}
			elsif ($threeletters eq "amm") {
				push(@variantletters,"am|0.25");
				push(@variantletters,"amm|0.75");
				$i=$i+2;
			}
			elsif ($threeletters eq "amy") {
				push(@variantletters,"ami|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "and") {
				push(@variantletters,"and|0.96078431372549");
				push(@variantletters,"ant|0.0392156862745098");
				push(@variantletters,"and|0.5");
				push(@variantletters,"anda|0.25");
				push(@variantletters,"eant|0.25");
				$i=$i+2;
			}
			elsif ($threeletters eq "ane") {
				push(@variantletters,"ane|0.857142857142857");
				push(@variantletters,"nne|0.142857142857143");
				push(@variantletters,"anne|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ang") {
				push(@variantletters,"ange|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ani") {
				push(@variantletters,"ani|0.933333333333333");
				push(@variantletters,"ann|0.0666666666666667");
				push(@variantletters,"anne|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ank") {
				push(@variantletters,"ak|0.0714285714285714");
				push(@variantletters,"ank|0.928571428571429");
				$i=$i+2;
			}
			elsif ($threeletters eq "ann") {
				push(@variantletters,"aan|0.0714285714285714");
				push(@variantletters,"ann|0.928571428571429");
				$i=$i+2;
			}
			elsif ($threeletters eq "ans") {
				push(@variantletters,"ans|0.733333333333333");
				push(@variantletters,"ant|0.266666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "ant") {
				push(@variantletters,"and|0.0178571428571429");
				push(@variantletters,"ant|0.982142857142857");
				$i=$i+2;
			}
			elsif ($threeletters eq "anw") {
				push(@variantletters,"antw|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ard") {
				push(@variantletters,"ard|0.916666666666667");
				push(@variantletters,"art|0.0833333333333333");
				push(@variantletters,"ard|0.5");
				push(@variantletters,"arda|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "are") {
				push(@variantletters,"ar|0.2");
				push(@variantletters,"are|0.8");
				push(@variantletters,"aar|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "aro") {
				push(@variantletters,"aaro|0.8");
				push(@variantletters,"arom|0.2");
				$i=$i+2;
			}
			elsif ($threeletters eq "art") {
				push(@variantletters,"agt|0.027027027027027");
				push(@variantletters,"ard|0.0540540540540541");
				push(@variantletters,"art|0.918918918918919");
				$i=$i+2;
			}
			elsif ($threeletters eq "asi") {
				push(@variantletters,"anti|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ate") {
				push(@variantletters,"atte|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "atn") {
				push(@variantletters,"aten|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "att") {
				push(@variantletters,"at|0.0714285714285714");
				push(@variantletters,"att|0.928571428571429");
				$i=$i+2;
			}
			elsif ($threeletters eq "aud") {
				push(@variantletters,"houd|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "aze") {
				push(@variantletters,"aase|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "bad") {
				push(@variantletters,"bal|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ban") {
				push(@variantletters,"ban|0.777777777777778");
				push(@variantletters,"ben|0.111111111111111");
				push(@variantletters,"dan|0.111111111111111");
				push(@variantletters,"bean|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "bbe") {
				push(@variantletters,"b|0.0625");
				push(@variantletters,"bbe|0.9375");
				$i=$i+2;
			}
			elsif ($threeletters eq "bbr") {
				push(@variantletters,"br|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ben") {
				push(@variantletters,"ben|0.992248062015504");
				push(@variantletters,"bben|0.142857142857143");
				push(@variantletters,"ben|0.285714285714286");
				push(@variantletters,"bent|0.428571428571429");
				push(@variantletters,"bijn|0.142857142857143");
				$i=$i+2;
			}
			elsif ($threeletters eq "bes") {
				push(@variantletters,"best|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "bgr") {
				push(@variantletters,"begr|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "biu") {
				push(@variantletters,"bui|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "bji") {
				push(@variantletters,"bij|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ble") {
				push(@variantletters,"ble|0.666666666666667");
				push(@variantletters,"bli|0.333333333333333");
				push(@variantletters,"blij|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "bri") {
				push(@variantletters,"beri|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "byo") {
				push(@variantletters,"yo|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "cha") {
				push(@variantletters,"chat|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "che") {
				push(@variantletters,"ch|0.0833333333333333");
				push(@variantletters,"che|0.833333333333333");
				push(@variantletters,"chr|0.0833333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "chi") {
				push(@variantletters,"chri|0.5");
				push(@variantletters,"schi|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "chj") {
				push(@variantletters,"ch|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "daa") {
				push(@variantletters,"da|0.0555555555555556");
				push(@variantletters,"daa|0.916666666666667");
				push(@variantletters,"dar|0.0277777777777778");
				push(@variantletters,"daa|0.4");
				push(@variantletters,"dar|0.2");
				push(@variantletters,"dart|0.2");
				push(@variantletters,"edaa|0.2");
				$i=$i+2;
			}
			elsif ($threeletters eq "dag") {
				push(@variantletters,"daag|0.166666666666667");
				push(@variantletters,"dag|0.5");
				push(@variantletters,"jdag|0.166666666666667");
				push(@variantletters,"sdag|0.166666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "dak") {
				push(@variantletters,"dank|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "das") {
				push(@variantletters,"da's|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "dek") {
				push(@variantletters,"denk|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "den") {
				push(@variantletters,"ben|0.137931034482759");
				push(@variantletters,"d|0.0344827586206897");
				push(@variantletters,"den|0.827586206896552");
				$i=$i+2;
			}
			elsif ($threeletters eq "deo") {
				push(@variantletters,"doe|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "des") {
				push(@variantletters,"bes|0.2");
				push(@variantletters,"des|0.8");
				$i=$i+2;
			}
			elsif ($threeletters eq "did") {
				push(@variantletters,"dit|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "dik") {
				push(@variantletters,"dikk|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "din") {
				push(@variantletters,"di|0.0476190476190476");
				push(@variantletters,"din|0.952380952380952");
				$i=$i+2;
			}
			elsif ($threeletters eq "dis") {
				push(@variantletters,"dins|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "dje") {
				push(@variantletters,"dje|0.818181818181818");
				push(@variantletters,"tje|0.181818181818182");
				$i=$i+2;
			}
			elsif ($threeletters eq "dle") {
				push(@variantletters,"lle|1");
				push(@variantletters,"llen|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "doe") {
				push(@variantletters,"doe|0.25");
				push(@variantletters,"doen|0.25");
				push(@variantletters,"doet|0.25");
				push(@variantletters,"tdoe|0.25");
				$i=$i+2;
			}
			elsif ($threeletters eq "dre") {
				push(@variantletters,"dere|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "dtj") {
				push(@variantletters,"tj|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "dwo") {
				push(@variantletters,"two|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eaa") {
				push(@variantletters,"aa|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ebb") {
				push(@variantletters,"eb|0.0625");
				push(@variantletters,"ebb|0.9375");
				$i=$i+2;
			}
			elsif ($threeletters eq "ebe") {
				push(@variantletters,"ebbe|0.5");
				push(@variantletters,"ebe|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "ebi") {
				push(@variantletters,"ubi|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ebt") {
				push(@variantletters,"eb|0.2");
				push(@variantletters,"ebt|0.8");
				$i=$i+2;
			}
			elsif ($threeletters eq "ece") {
				push(@variantletters,"etje|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ede") {
				push(@variantletters,"ede|0.923076923076923");
				push(@variantletters,"nde|0.0769230769230769");
				$i=$i+2;
			}
			elsif ($threeletters eq "edj") {
				push(@variantletters,"edj|0.75");
				push(@variantletters,"etj|0.25");
				$i=$i+2;
			}
			elsif ($threeletters eq "edr") {
				push(@variantletters,"eder|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "edt") {
				push(@variantletters,"et|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "edu") {
				push(@variantletters,"etu|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eec") {
				push(@variantletters,"eet|1");
				push(@variantletters,"eetj|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eed") {
				push(@variantletters,"eft|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eef") {
				push(@variantletters,"heef|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eeg") {
				push(@variantletters,"eeg|0.5");
				push(@variantletters,"eg|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "eek") {
				push(@variantletters,"eek|0.772727272727273");
				push(@variantletters,"ek|0.227272727272727");
				$i=$i+2;
			}
			elsif ($threeletters eq "eel") {
				push(@variantletters,"eel|0.956043956043956");
				push(@variantletters,"el|0.043956043956044");
				push(@variantletters,"eli|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eem") {
				push(@variantletters,"eem|0.666666666666667");
				push(@variantletters,"em|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "een") {
				push(@variantletters,"een|0.992063492063492");
				$i=$i+2;
			}
			elsif ($threeletters eq "ees") {
				push(@variantletters,"eest|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eet") {
				push(@variantletters,"eet|0.96551724137931");
				push(@variantletters,"et|0.0344827586206897");
				push(@variantletters,"eget|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eev") {
				push(@variantletters,"eef|0.5");
				push(@variantletters,"rev|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "eey") {
				push(@variantletters,"ey|0.666666666666667");
				push(@variantletters,"hey|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "eez") {
				push(@variantletters,"ez|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "efe") {
				push(@variantletters,"ee|0.25");
				push(@variantletters,"efe|0.75");
				$i=$i+2;
			}
			elsif ($threeletters eq "eft") {
				push(@variantletters,"efd|0.0714285714285714");
				push(@variantletters,"eft|0.928571428571429");
				$i=$i+2;
			}
			elsif ($threeletters eq "ege") {
				push(@variantletters,"eg|0.032258064516129");
				push(@variantletters,"ege|0.935483870967742");
				push(@variantletters,"ge|0.032258064516129");
				push(@variantletters,"egge|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "egt") {
				push(@variantletters,"egd|0.1");
				push(@variantletters,"egt|0.9");
				push(@variantletters,"echt|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "egv") {
				push(@variantletters,"egev|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ehw") {
				push(@variantletters,"enw|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eie") {
				push(@variantletters,"seie|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eja") {
				push(@variantletters,"ja|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eje") {
				push(@variantletters,"eie|0.5");
				push(@variantletters,"eje|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "eka") {
				push(@variantletters,"ka|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eke") {
				push(@variantletters,"eke|0.96969696969697");
				push(@variantletters,"nke|0.0303030303030303");
				$i=$i+2;
			}
			elsif ($threeletters eq "eko") {
				push(@variantletters,"enko|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ekr") {
				push(@variantletters,"enkr|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "elg") {
				push(@variantletters,"eleg|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ell") {
				push(@variantletters,"all|0.0714285714285714");
				push(@variantletters,"ell|0.928571428571429");
				$i=$i+2;
			}
			elsif ($threeletters eq "elt") {
				push(@variantletters,"eld|0.2");
				push(@variantletters,"elt|0.6");
				push(@variantletters,"et|0.2");
				$i=$i+2;
			}
			elsif ($threeletters eq "elu") {
				push(@variantletters,"elu|0.5");
				push(@variantletters,"eluk|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "en.") {
				push(@variantletters,"en|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ena") {
				push(@variantletters,"ijna|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "end") {
				push(@variantletters,"end|0.980769230769231");
				push(@variantletters,"ent|0.0192307692307692");
				$i=$i+2;
			}
			elsif ($threeletters eq "ene") {
				push(@variantletters,"en|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ens") {
				push(@variantletters,"en|0.0526315789473684");
				push(@variantletters,"ens|0.947368421052632");
				$i=$i+2;
			}
			elsif ($threeletters eq "ent") {
				push(@variantletters,"en|0.0571428571428571");
				push(@variantletters,"end|0.171428571428571");
				push(@variantletters,"ent|0.771428571428571");
				$i=$i+2;
			}
			elsif ($threeletters eq "eom") {
				push(@variantletters,"om|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eon") {
				push(@variantletters,"en|1");
				push(@variantletters,"oen|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eot") {
				push(@variantletters,"et|1");
				push(@variantletters,"oet|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "epj") {
				push(@variantletters,"etj|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "epo") {
				push(@variantletters,"pp|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "era") {
				push(@variantletters,"erra|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "erj") {
				push(@variantletters,"erj|0.666666666666667");
				push(@variantletters,"ertj|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "erl") {
				push(@variantletters,"erle|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "eru") {
				push(@variantletters,"erug|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ery") {
				push(@variantletters,"er|0.333333333333333");
				push(@variantletters,"ery|0.333333333333333");
				push(@variantletters,"ri|0.333333333333333");
				push(@variantletters,"erj|0.5");
				push(@variantletters,"rij|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "esc") {
				push(@variantletters,"esc|0.4");
				push(@variantletters,"issc|0.6");
				$i=$i+2;
			}
			elsif ($threeletters eq "esd") {
				push(@variantletters,"ensd|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "esj") {
				push(@variantletters,"estj|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "esn") {
				push(@variantletters,"en|1");
				push(@variantletters,"ens|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "est") {
				push(@variantletters,"est|0.984375");
				push(@variantletters,"st|0.015625");
				push(@variantletters,"eest|0.111111111111111");
				push(@variantletters,"est|0.777777777777778");
				push(@variantletters,"este|0.111111111111111");
				$i=$i+2;
			}
			elsif ($threeletters eq "ete") {
				push(@variantletters,"ete|0.972972972972973");
				push(@variantletters,"eti|0.027027027027027");
				push(@variantletters,"eten|0.333333333333333");
				push(@variantletters,"ette|0.333333333333333");
				push(@variantletters,"gete|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "etg") {
				push(@variantletters,"et|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "etn") {
				push(@variantletters,"eten|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ett") {
				push(@variantletters,"et|0.166666666666667");
				push(@variantletters,"ett|0.666666666666667");
				push(@variantletters,"itt|0.166666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "eug") {
				push(@variantletters,"eug|0.5");
				push(@variantletters,"ug|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "euw") {
				push(@variantletters,"euwe|0.5");
				push(@variantletters,"euwt|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "evt") {
				push(@variantletters,"eft|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ewe") {
				push(@variantletters,"euw|0.5");
				push(@variantletters,"ewe|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "ewi") {
				push(@variantletters,"ewo|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ewj") {
				push(@variantletters,"euwj|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ewo") {
				push(@variantletters,"ewon|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "fde") {
				push(@variantletters,"efde|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "fee") {
				push(@variantletters,"ef|0.0666666666666667");
				push(@variantletters,"fee|0.933333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "fen") {
				push(@variantletters,"en|0.166666666666667");
				push(@variantletters,"fen|0.833333333333333");
				push(@variantletters,"ffen|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "fes") {
				push(@variantletters,"fees|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ffo") {
				push(@variantletters,"ffe|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "fol") {
				push(@variantletters,"fel|1");
				push(@variantletters,"ffel|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "fra") {
				push(@variantletters,"fra|0.5");
				push(@variantletters,"fro|0.5");
				push(@variantletters,"frou|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "fri") {
				push(@variantletters,"frie|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "fve") {
				push(@variantletters,"ve|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "gaa") {
				push(@variantletters,"ga|0.0674157303370786");
				push(@variantletters,"gaa|0.932584269662921");
				push(@variantletters,"gaa|0.5");
				push(@variantletters,"gaan|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "gat") {
				push(@variantletters,"chat|0.666666666666667");
				push(@variantletters,"gaat|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "gda") {
				push(@variantletters,"geda|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "gea") {
				push(@variantletters,"ga|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "gee") {
				push(@variantletters,"ge|0.0476190476190476");
				push(@variantletters,"gee|0.952380952380952");
				push(@variantletters,"gege|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "geg") {
				push(@variantletters,"geg|0.5");
				push(@variantletters,"gege|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "gel") {
				push(@variantletters,"gel|0.5");
				push(@variantletters,"gele|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "gen") {
				push(@variantletters,"egen|0.142857142857143");
				push(@variantletters,"gen|0.142857142857143");
				push(@variantletters,"ggen|0.714285714285714");
				$i=$i+2;
			}
			elsif ($threeletters eq "ger") {
				push(@variantletters,"ger|0.833333333333333");
				push(@variantletters,"gr|0.166666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "gko") {
				push(@variantletters,"geko|0.5");
				push(@variantletters,"gko|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "gli") {
				push(@variantletters,"geli|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "glu") {
				push(@variantletters,"gelu|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "goe") {
				push(@variantletters,"goed|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "gre") {
				push(@variantletters,"groe|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "gri") {
				push(@variantletters,"egri|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "gro") {
				push(@variantletters,"gr|0.0113636363636364");
				push(@variantletters,"gro|0.988636363636364");
				$i=$i+2;
			}
			elsif ($threeletters eq "gud") {
				push(@variantletters,"ged|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "gut") {
				push(@variantletters,"het|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "gva") {
				push(@variantletters,"geva|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "gve") {
				push(@variantletters,"geve|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "haa") {
				push(@variantletters,"gaa|0.0476190476190476");
				push(@variantletters,"ha|0.0952380952380952");
				push(@variantletters,"haa|0.857142857142857");
				push(@variantletters,"haat|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hal") {
				push(@variantletters,"ha|0.0196078431372549");
				push(@variantletters,"hal|0.980392156862745");
				push(@variantletters,"hall|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hap") {
				push(@variantletters,"hap|0.8");
				push(@variantletters,"heb|0.2");
				$i=$i+2;
			}
			elsif ($threeletters eq "hat") {
				push(@variantletters,"ha|0.0222222222222222");
				push(@variantletters,"hat|0.977777777777778");
				push(@variantletters,"chat|0.5");
				push(@variantletters,"hatt|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "hau") {
				push(@variantletters,"hou|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "heb") {
				push(@variantletters,"he|0.0153846153846154");
				push(@variantletters,"heb|0.969230769230769");
				push(@variantletters,"hee|0.0153846153846154");
				push(@variantletters,"geb|0.25");
				push(@variantletters,"heb|0.25");
				push(@variantletters,"hebb|0.25");
				push(@variantletters,"heef|0.25");
				$i=$i+2;
			}
			elsif ($threeletters eq "hed") {
				push(@variantletters,"ged|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hee") {
				push(@variantletters,"he|0.0428571428571429");
				push(@variantletters,"hee|0.942857142857143");
				push(@variantletters,"hre|0.0142857142857143");
				$i=$i+2;
			}
			elsif ($threeletters eq "hef") {
				push(@variantletters,"he|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hei") {
				push(@variantletters,"hei|0.888888888888889");
				push(@variantletters,"hey|0.111111111111111");
				$i=$i+2;
			}
			elsif ($threeletters eq "hej") {
				push(@variantletters,"hey|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hel") {
				push(@variantletters,"hal|0.125");
				push(@variantletters,"he|0.125");
				push(@variantletters,"hel|0.75");
				push(@variantletters,"heel|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hep") {
				push(@variantletters,"heb|1");
				push(@variantletters,"hebt|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hes") {
				push(@variantletters,"ges|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hie") {
				push(@variantletters,"hier|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hif") {
				push(@variantletters,"hip|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hij") {
				push(@variantletters,"hrij|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hin") {
				push(@variantletters,"hien|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hji") {
				push(@variantletters,"hi|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hjt") {
				push(@variantletters,"ht|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hoe") {
				push(@variantletters,"goe|0.0338983050847458");
				push(@variantletters,"hoe|0.966101694915254");
				$i=$i+2;
			}
			elsif ($threeletters eq "hoo") {
				push(@variantletters,"ho|0.0158730158730159");
				push(@variantletters,"hoo|0.984126984126984");
				$i=$i+2;
			}
			elsif ($threeletters eq "hri") {
				push(@variantletters,"hre|0.0909090909090909");
				push(@variantletters,"hri|0.909090909090909");
				$i=$i+2;
			}
			elsif ($threeletters eq "hry") {
				push(@variantletters,"hri|1");
				push(@variantletters,"hrij|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "hut") {
				push(@variantletters,"het|0.857142857142857");
				push(@variantletters,"hut|0.142857142857143");
				$i=$i+2;
			}
			elsif ($threeletters eq "hwo") {
				push(@variantletters,"nwo|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ich") {
				push(@variantletters,"ich|0.928571428571429");
				push(@variantletters,"ig|0.0714285714285714");
				$i=$i+2;
			}
			elsif ($threeletters eq "ict") {
				push(@variantletters,"icht|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ida") {
				push(@variantletters,"ijda|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ido") {
				push(@variantletters,"itdo|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ied") {
				push(@variantletters,"ied|0.9");
				push(@variantletters,"ind|0.1");
				push(@variantletters,"iede|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "iee") {
				push(@variantletters,"ieg|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "iek") {
				push(@variantletters,"iek|0.909090909090909");
				push(@variantletters,"ink|0.0909090909090909");
				$i=$i+2;
			}
			elsif ($threeletters eq "iel") {
				push(@variantletters,"iel|0.875");
				push(@variantletters,"il|0.125");
				$i=$i+2;
			}
			elsif ($threeletters eq "iem") {
				push(@variantletters,"iem|0.916666666666667");
				push(@variantletters,"ien|0.0833333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "ien") {
				push(@variantletters,"ie|0.019047619047619");
				push(@variantletters,"ien|0.971428571428571");
				push(@variantletters,"tie|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "iep") {
				push(@variantletters,"ipp|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ies") {
				push(@variantletters,"iets|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "iet") {
				push(@variantletters,"iet|0.987179487179487");
				push(@variantletters,"iets|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "iew") {
				push(@variantletters,"ieuw|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ifd") {
				push(@variantletters,"iefd|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ige") {
				push(@variantletters,"ig|0.125");
				push(@variantletters,"ige|0.875");
				$i=$i+2;
			}
			elsif ($threeletters eq "iik") {
				push(@variantletters,"~ik|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "iin") {
				push(@variantletters,"onn|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ijd") {
				push(@variantletters,"ijd|0.909090909090909");
				push(@variantletters,"ijt|0.0909090909090909");
				$i=$i+2;
			}
			elsif ($threeletters eq "ije") {
				push(@variantletters,"ie|0.25");
				push(@variantletters,"ije|0.75");
				push(@variantletters,"ijde|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ijf") {
				push(@variantletters,"ij|0.142857142857143");
				push(@variantletters,"ijf|0.857142857142857");
				push(@variantletters,"rijf|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ijn") {
				push(@variantletters,"ijn|0.99");
				push(@variantletters,"ein|0.5");
				push(@variantletters,"ijn|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "ijt") {
				push(@variantletters,"ijd|0.375");
				push(@variantletters,"ijt|0.625");
				$i=$i+2;
			}
			elsif ($threeletters eq "ijv") {
				push(@variantletters,"ev|0.166666666666667");
				push(@variantletters,"ijf|0.166666666666667");
				push(@variantletters,"ijv|0.666666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "ike") {
				push(@variantletters,"ieke|0.666666666666667");
				push(@variantletters,"ikke|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "ile") {
				push(@variantletters,"ile|0.5");
				push(@variantletters,"itle|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "ilj") {
				push(@variantletters,"ik|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ill") {
				push(@variantletters,"il|0.2");
				push(@variantletters,"ill|0.8");
				$i=$i+2;
			}
			elsif ($threeletters eq "ima") {
				push(@variantletters,"ema|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ine") {
				push(@variantletters,"ine|0.875");
				push(@variantletters,"nne|0.125");
				$i=$i+2;
			}
			elsif ($threeletters eq "ing") {
				push(@variantletters,"ig|0.0416666666666667");
				push(@variantletters,"ing|0.958333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "inn") {
				push(@variantletters,"ien|0.166666666666667");
				push(@variantletters,"in|0.166666666666667");
				push(@variantletters,"inn|0.666666666666667");
				push(@variantletters,"rien|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "int") {
				push(@variantletters,"ind|0.0909090909090909");
				push(@variantletters,"int|0.909090909090909");
				$i=$i+2;
			}
			elsif ($threeletters eq "iot") {
				push(@variantletters,"iot|0.0416666666666667");
				push(@variantletters,"uit|0.958333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "isc") {
				push(@variantletters,"issc|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "isi") {
				push(@variantletters,"eci|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "isn") {
				push(@variantletters,"ins|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "iss") {
				push(@variantletters,"issc|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ist") {
				push(@variantletters,"is't|0.8");
				push(@variantletters,"iste|0.2");
				$i=$i+2;
			}
			elsif ($threeletters eq "ite") {
				push(@variantletters,"iete|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "its") {
				push(@variantletters,"iets|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "itt") {
				push(@variantletters,"it|0.4");
				push(@variantletters,"itt|0.6");
				$i=$i+2;
			}
			elsif ($threeletters eq "iut") {
				push(@variantletters,"it|1");
				push(@variantletters,"uit|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "iye") {
				push(@variantletters,"ije|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "jaa") {
				push(@variantletters,"ja|0.0952380952380952");
				push(@variantletters,"jaa|0.904761904761905");
				$i=$i+2;
			}
			elsif ($threeletters eq "jau") {
				push(@variantletters,"jou|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "jde") {
				push(@variantletters,"jde|0.666666666666667");
				push(@variantletters,"je|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "jen") {
				push(@variantletters,"jden|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "jes") {
				push(@variantletters,"tjes|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "jet") {
				push(@variantletters,"jet|0.5");
				push(@variantletters,"het|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "jfv") {
				push(@variantletters,"jv|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "jid") {
				push(@variantletters,"rijd|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "jij") {
				push(@variantletters,"ij|0.0120481927710843");
				push(@variantletters,"je|0.0120481927710843");
				push(@variantletters,"jij|0.975903614457831");
				$i=$i+2;
			}
			elsif ($threeletters eq "jin") {
				push(@variantletters,"jn|1");
				push(@variantletters,"ijn|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "joe") {
				push(@variantletters,"joe|0.5");
				push(@variantletters,"koe|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "jou") {
				push(@variantletters,"jouw|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "jtj") {
				push(@variantletters,"tj|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "juf") {
				push(@variantletters,"juff|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "jul") {
				push(@variantletters,"jull|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "jve") {
				push(@variantletters,"jft|0.166666666666667");
				push(@variantletters,"jve|0.666666666666667");
				push(@variantletters,"ve|0.166666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "kam") {
				push(@variantletters,"cam|0.2");
				push(@variantletters,"kam|0.8");
				$i=$i+2;
			}
			elsif ($threeletters eq "kan") {
				push(@variantletters,"kan|0.966666666666667");
				push(@variantletters,"ken|0.0333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "kas") {
				push(@variantletters,"kan|0.333333333333333");
				push(@variantletters,"kas|0.666666666666667");
				push(@variantletters,"kant|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "keb") {
				push(@variantletters,"ekeb|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "keg") {
				push(@variantletters,"kkig|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ken") {
				push(@variantletters,"eken|0.333333333333333");
				push(@variantletters,"kent|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "ker") {
				push(@variantletters,"kker|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "kge") {
				push(@variantletters,"kige|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "kie") {
				push(@variantletters,"kige|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "kik") {
				push(@variantletters,"kiek|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "kin") {
				push(@variantletters,"ki|0.2");
				push(@variantletters,"kin|0.8");
				push(@variantletters,"kki|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "kiy") {
				push(@variantletters,"kij|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "kke") {
				push(@variantletters,"kke|0.5");
				push(@variantletters,"kken|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "kki") {
				push(@variantletters,"kkig|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "kli") {
				push(@variantletters,"klei|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "koe") {
				push(@variantletters,"coo|0.125");
				push(@variantletters,"koe|0.875");
				push(@variantletters,"nkoe|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "kog") {
				push(@variantletters,"koc|1");
				push(@variantletters,"ekoc|0.5");
				push(@variantletters,"koch|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "kom") {
				push(@variantletters,"ko|0.0112359550561798");
				push(@variantletters,"kom|0.98876404494382");
				$i=$i+2;
			}
			elsif ($threeletters eq "kon") {
				push(@variantletters,"kom|0.5");
				push(@variantletters,"kon|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "koo") {
				push(@variantletters,"ko|0.833333333333333");
				push(@variantletters,"koo|0.166666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "kos") {
				push(@variantletters,"kon|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "kre") {
				push(@variantletters,"kr|0.111111111111111");
				push(@variantletters,"kre|0.777777777777778");
				push(@variantletters,"kri|0.111111111111111");
				push(@variantletters,"kree|0.5");
				push(@variantletters,"krij|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "kri") {
				push(@variantletters,"nkri|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "laa") {
				push(@variantletters,"la|0.0625");
				push(@variantletters,"laa|0.9375");
				$i=$i+2;
			}
			elsif ($threeletters eq "lat") {
				push(@variantletters,"late|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "lee") {
				push(@variantletters,"le|0.2");
				push(@variantletters,"lee|0.8");
				push(@variantletters,"ele|0.5");
				push(@variantletters,"llee|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "leg") {
				push(@variantletters,"tleg|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "lem") {
				push(@variantletters,"lem|0.5");
				push(@variantletters,"llem|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "len") {
				push(@variantletters,"l|0.025");
				push(@variantletters,"len|0.975");
				push(@variantletters,"llen|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "les") {
				push(@variantletters,"lles|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "lgd") {
				push(@variantletters,"legd|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "lge") {
				push(@variantletters,"lege|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "lgu") {
				push(@variantletters,"lge|1");
				push(@variantletters,"lgen|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "lie") {
				push(@variantletters,"lie|0.991735537190083");
				push(@variantletters,"llie|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "lif") {
				push(@variantletters,"lief|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "lij") {
				push(@variantletters,"elij|0.5");
				push(@variantletters,"lei|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "lje") {
				push(@variantletters,"ltje|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "lke") {
				push(@variantletters,"lk|0.166666666666667");
				push(@variantletters,"lke|0.833333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "lle") {
				push(@variantletters,"l|0.0126582278481013");
				push(@variantletters,"lle|0.987341772151899");
				push(@variantletters,"lle|0.5");
				push(@variantletters,"llen|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "llo") {
				push(@variantletters,"ll|0.0204081632653061");
				push(@variantletters,"llo|0.979591836734694");
				$i=$i+2;
			}
			elsif ($threeletters eq "lls") {
				push(@variantletters,"ls|1");
				push(@variantletters,"lles|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "log") {
				push(@variantletters,"og|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "loo") {
				push(@variantletters,"lo|0.333333333333333");
				push(@variantletters,"loo|0.333333333333333");
				push(@variantletters,"lov|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "ltt") {
				push(@variantletters,"tt|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "lue") {
				push(@variantletters,"leu|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "luk") {
				push(@variantletters,"luk|0.333333333333333");
				push(@variantletters,"lukk|0.666666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "luu") {
				push(@variantletters,"leu|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "lva") {
				push(@variantletters,"ieva|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "man") {
				push(@variantletters,"mand|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "mde") {
				push(@variantletters,"nde|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "med") {
				push(@variantletters,"med|0.777777777777778");
				push(@variantletters,"met|0.222222222222222");
				push(@variantletters,"met|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "meg") {
				push(@variantletters,"mag|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "meh") {
				push(@variantletters,"men|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "men") {
				push(@variantletters,"m|0.0144927536231884");
				push(@variantletters,"men|0.971014492753623");
				push(@variantletters,"mer|0.0144927536231884");
				push(@variantletters,"mijn|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "mer") {
				push(@variantletters,"mmer|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "mes") {
				push(@variantletters,"mes|0.333333333333333");
				push(@variantletters,"mis|0.333333333333333");
				push(@variantletters,"ms|0.333333333333333");
				push(@variantletters,"miss|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "mie") {
				push(@variantletters,"mie|0.25");
				push(@variantletters,"mij|0.25");
				push(@variantletters,"min|0.25");
				push(@variantletters,"nie|0.25");
				push(@variantletters,"hmin|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "mij") {
				push(@variantletters,"mij|0.125");
				push(@variantletters,"mijn|0.875");
				$i=$i+2;
			}
			elsif ($threeletters eq "mil") {
				push(@variantletters,"mil|0.888888888888889");
				push(@variantletters,"wil|0.111111111111111");
				$i=$i+2;
			}
			elsif ($threeletters eq "mis") {
				push(@variantletters,"mis|0.5");
				push(@variantletters,"miss|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "mji") {
				push(@variantletters,"mij|0.666666666666667");
				push(@variantletters,"mji|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "mme") {
				push(@variantletters,"me|0.08");
				push(@variantletters,"mme|0.92");
				$i=$i+2;
			}
			elsif ($threeletters eq "moe") {
				push(@variantletters,"moet|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "mor") {
				push(@variantletters,"morg|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "mss") {
				push(@variantletters,"miss|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "mus") {
				push(@variantletters,"miss|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "mut") {
				push(@variantletters,"moet|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "myo") {
				push(@variantletters,"mio|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "naa") {
				push(@variantletters,"na|0.0120481927710843");
				push(@variantletters,"naa|0.987951807228916");
				$i=$i+2;
			}
			elsif ($threeletters eq "nda") {
				push(@variantletters,"da|0.0277777777777778");
				push(@variantletters,"nda|0.972222222222222");
				push(@variantletters,"nda|0.333333333333333");
				push(@variantletters,"ndaa|0.333333333333333");
				push(@variantletters,"nsda|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "nde") {
				push(@variantletters,"nd|0.0285714285714286");
				push(@variantletters,"nde|0.971428571428571");
				push(@variantletters,"nden|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ndt") {
				push(@variantletters,"nd|0.5");
				push(@variantletters,"ndt|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "ndw") {
				push(@variantletters,"ntw|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "nee") {
				push(@variantletters,"ne|0.0434782608695652");
				push(@variantletters,"nee|0.956521739130435");
				push(@variantletters,"ne|0.6");
				push(@variantletters,"nnee|0.4");
				$i=$i+2;
			}
			elsif ($threeletters eq "nek") {
				push(@variantletters,"nenk|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "nen") {
				push(@variantletters,"nnen|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "nge") {
				push(@variantletters,"ng|0.0714285714285714");
				push(@variantletters,"nge|0.928571428571429");
				$i=$i+2;
			}
			elsif ($threeletters eq "ngv") {
				push(@variantletters,"ngev|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "nie") {
				push(@variantletters,"niet|0.714285714285714");
				push(@variantletters,"nieu|0.285714285714286");
				$i=$i+2;
			}
			elsif ($threeletters eq "nij") {
				push(@variantletters,"bij|0.5");
				push(@variantletters,"nij|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "niu") {
				push(@variantletters,"nie|1");
				push(@variantletters,"niet|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "nka") {
				push(@variantletters,"ka|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "nke") {
				push(@variantletters,"nken|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "nnd") {
				push(@variantletters,"end|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "nne") {
				push(@variantletters,"nnen|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "noo") {
				push(@variantletters,"nod|0.2");
				push(@variantletters,"noo|0.8");
				push(@variantletters,"nod|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "nsi") {
				push(@variantletters,"nti|1");
				push(@variantletters,"ntie|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "nta") {
				push(@variantletters,"nta|0.5");
				push(@variantletters,"nto|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "nte") {
				push(@variantletters,"nde|0.2");
				push(@variantletters,"nte|0.8");
				$i=$i+2;
			}
			elsif ($threeletters eq "nts") {
				push(@variantletters,"nds|0.333333333333333");
				push(@variantletters,"nt|0.666666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "num") {
				push(@variantletters,"numm|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "nuu") {
				push(@variantletters,"nu|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "nwt") {
				push(@variantletters,"ntw|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "oco") {
				push(@variantletters,"okko|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "oed") {
				push(@variantletters,"oe|0.010752688172043");
				push(@variantletters,"oed|0.956989247311828");
				push(@variantletters,"oet|0.032258064516129");
				$i=$i+2;
			}
			elsif ($threeletters eq "oej") {
				push(@variantletters,"oei|0.5");
				push(@variantletters,"oej|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "oel") {
				push(@variantletters,"oel|0.833333333333333");
				push(@variantletters,"ool|0.166666666666667");
				push(@variantletters,"doel|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "oep") {
				push(@variantletters,"oep|0.666666666666667");
				push(@variantletters,"oet|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "oer") {
				push(@variantletters,"oert|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "oes") {
				push(@variantletters,"oe|0.0714285714285714");
				push(@variantletters,"oes|0.928571428571429");
				push(@variantletters,"oens|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "oet") {
				push(@variantletters,"oed|0.0803571428571429");
				push(@variantletters,"oet|0.919642857142857");
				$i=$i+2;
			}
			elsif ($threeletters eq "oev") {
				push(@variantletters,"hoev|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ofe") {
				push(@variantletters,"ve|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "oft") {
				push(@variantletters,"ofd|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ogt") {
				push(@variantletters,"ocht|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ohe") {
				push(@variantletters,"one|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "oie") {
				push(@variantletters,"oi|0.166666666666667");
				push(@variantletters,"oie|0.833333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "oij") {
				push(@variantletters,"oi|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "oik") {
				push(@variantletters,"ok|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ols") {
				push(@variantletters,"fels|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "olv") {
				push(@variantletters,"oiev|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "omd") {
				push(@variantletters,"omd|0.75");
				push(@variantletters,"ond|0.25");
				$i=$i+2;
			}
			elsif ($threeletters eq "ome") {
				push(@variantletters,"om|0.03125");
				push(@variantletters,"ome|0.96875");
				$i=$i+2;
			}
			elsif ($threeletters eq "omm") {
				push(@variantletters,"om|0.5");
				push(@variantletters,"omm|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "omt") {
				push(@variantletters,"om|0.0909090909090909");
				push(@variantletters,"omt|0.909090909090909");
				push(@variantletters,"komt|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "omu") {
				push(@variantletters,"ome|1");
				push(@variantletters,"omen|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "one") {
				push(@variantletters,"onne|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ont") {
				push(@variantletters,"omt|0.333333333333333");
				push(@variantletters,"ont|0.666666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "onz") {
				push(@variantletters,"ons|0.2");
				push(@variantletters,"onz|0.8");
				push(@variantletters,"onze|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "oob") {
				push(@variantletters,"ob|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "oof") {
				push(@variantletters,"oof|0.75");
				push(@variantletters,"ov|0.25");
				$i=$i+2;
			}
			elsif ($threeletters eq "ooi") {
				push(@variantletters,"ooie|0.5");
				push(@variantletters,"ooit|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "ool") {
				push(@variantletters,"ooi|0.0294117647058824");
				push(@variantletters,"ool|0.970588235294118");
				push(@variantletters,"ooie|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "oom") {
				push(@variantletters,"om|0.555555555555556");
				push(@variantletters,"oom|0.444444444444444");
				$i=$i+2;
			}
			elsif ($threeletters eq "oor") {
				push(@variantletters,"oo|0.0114942528735632");
				push(@variantletters,"oor|0.988505747126437");
				$i=$i+2;
			}
			elsif ($threeletters eq "oot") {
				push(@variantletters,"odi|0.2");
				push(@variantletters,"oot|0.6");
				push(@variantletters,"ot|0.2");
				$i=$i+2;
			}
			elsif ($threeletters eq "ord") {
				push(@variantletters,"oord|0.5");
				push(@variantletters,"ordt|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "ore") {
				push(@variantletters,"ord|0.2");
				push(@variantletters,"ore|0.8");
				push(@variantletters,"orge|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "org") {
				push(@variantletters,"orge|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ori") {
				push(@variantletters,"ori|0.904761904761905");
				push(@variantletters,"orr|0.0952380952380952");
				$i=$i+2;
			}
			elsif ($threeletters eq "orr") {
				push(@variantletters,"or|0.142857142857143");
				push(@variantletters,"orr|0.857142857142857");
				$i=$i+2;
			}
			elsif ($threeletters eq "ort") {
				push(@variantletters,"ord|0.4");
				push(@variantletters,"ort|0.6");
				push(@variantletters,"ordt|0.666666666666667");
				push(@variantletters,"ort|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "ory") {
				push(@variantletters,"orry|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ost") {
				push(@variantletters,"on|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ote") {
				push(@variantletters,"di|0.2");
				push(@variantletters,"ote|0.6");
				push(@variantletters,"te|0.2");
				$i=$i+2;
			}
			elsif ($threeletters eq "ouw") {
				push(@variantletters,"ou|0.411764705882353");
				push(@variantletters,"ouw|0.588235294117647");
				$i=$i+2;
			}
			elsif ($threeletters eq "owe") {
				push(@variantletters,"we|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "paa") {
				push(@variantletters,"pa|0.2");
				push(@variantletters,"paa|0.8");
				$i=$i+2;
			}
			elsif ($threeletters eq "pan") {
				push(@variantletters,"pann|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "paz") {
				push(@variantletters,"paa|1");
				push(@variantletters,"paas|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "pee") {
				push(@variantletters,"pe|0.0909090909090909");
				push(@variantletters,"pee|0.909090909090909");
				$i=$i+2;
			}
			elsif ($threeletters eq "pit") {
				push(@variantletters,"pi|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "pje") {
				push(@variantletters,"tje|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ple") {
				push(@variantletters,"pel|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "poo") {
				push(@variantletters,"po|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ppi") {
				push(@variantletters,"ppig|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "pra") {
				push(@variantletters,"pr|0.033333333333333");
				push(@variantletters,"pra|0.933333333333333");
				push(@variantletters,"praa|0.033333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "pre") {
				push(@variantletters,"pr|0.210526315789474");
				push(@variantletters,"pre|0.789473684210526");
				$i=$i+2;
			}
			elsif ($threeletters eq "pri") {
				push(@variantletters,"pre|0.25");
				push(@variantletters,"pri|0.75");
				$i=$i+2;
			}
			elsif ($threeletters eq "raa") {
				push(@variantletters,"ra|0.0178571428571429");
				push(@variantletters,"raa|0.982142857142857");
				$i=$i+2;
			}
			elsif ($threeletters eq "rar") {
				push(@variantletters,"raar|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ras") {
				push(@variantletters,"rras|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "rda") {
				push(@variantletters,"rd|0.0625");
				push(@variantletters,"rda|0.9375");
				$i=$i+2;
			}
			elsif ($threeletters eq "rdg") {
				push(@variantletters,"rdag|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "rdj") {
				push(@variantletters,"rtj|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ree") {
				push(@variantletters,"re|0.454545454545455");
				push(@variantletters,"ree|0.545454545454545");
				push(@variantletters,"eree|0.5");
				push(@variantletters,"ree|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "reg") {
				push(@variantletters,"reg|0.909090909090909");
				push(@variantletters,"rug|0.0909090909090909");
				push(@variantletters,"reeg|0.5");
				push(@variantletters,"rijg|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "rel") {
				push(@variantletters,"reld|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ren") {
				push(@variantletters,"rd|0.0227272727272727");
				push(@variantletters,"ren|0.977272727272727");
				push(@variantletters,"eren|0.5");
				push(@variantletters,"rgen|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "reo") {
				push(@variantletters,"ro|1");
				push(@variantletters,"roe|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "reu") {
				push(@variantletters,"ru|1");
				push(@variantletters,"eru|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "rge") {
				push(@variantletters,"rgen|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "rgn") {
				push(@variantletters,"rgen|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ric") {
				push(@variantletters,"eric|0.666666666666667");
				push(@variantletters,"rich|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "rie") {
				push(@variantletters,"rie|0.982142857142857");
				push(@variantletters,"rry|0.0178571428571429");
				$i=$i+2;
			}
			elsif ($threeletters eq "rij") {
				push(@variantletters,"re|0.0555555555555556");
				push(@variantletters,"rij|0.944444444444444");
				push(@variantletters,"rij|0.333333333333333");
				push(@variantletters,"rijd|0.666666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "ris") {
				push(@variantletters,"rec|0.0131578947368421");
				push(@variantletters,"ris|0.986842105263158");
				$i=$i+2;
			}
			elsif ($threeletters eq "rit") {
				push(@variantletters,"riet|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "riu") {
				push(@variantletters,"rui|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "riy") {
				push(@variantletters,"rry|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "rje") {
				push(@variantletters,"rtje|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "rle") {
				push(@variantletters,"rl|0.333333333333333");
				push(@variantletters,"rle|0.666666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "rlg") {
				push(@variantletters,"rleg|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "rme") {
				push(@variantletters,"erme|0.5");
				push(@variantletters,"rme|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "roc") {
				push(@variantletters,"rok|1");
				push(@variantletters,"rokk|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "roo") {
				push(@variantletters,"ro|0.142857142857143");
				push(@variantletters,"roo|0.857142857142857");
				$i=$i+2;
			}
			elsif ($threeletters eq "rrd") {
				push(@variantletters,"rd|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "rst") {
				push(@variantletters,"erst|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "rug") {
				push(@variantletters,"erug|0.8");
				push(@variantletters,"rug|0.2");
				$i=$i+2;
			}
			elsif ($threeletters eq "ruo") {
				push(@variantletters,"rou|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "rya") {
				push(@variantletters,"rja|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ryf") {
				push(@variantletters,"rijf|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ryk") {
				push(@variantletters,"rijk|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "saa") {
				push(@variantletters,"sla|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "sac") {
				push(@variantletters,"zac|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "sal") {
				push(@variantletters,"sal|0.8");
				push(@variantletters,"zal|0.2");
				$i=$i+2;
			}
			elsif ($threeletters eq "sam") {
				push(@variantletters,"sa|0.0476190476190476");
				push(@variantletters,"sam|0.952380952380952");
				$i=$i+2;
			}
			elsif ($threeletters eq "sch") {
				push(@variantletters,"sch|0.25");
				push(@variantletters,"schr|0.125");
				push(@variantletters,"ssch|0.625");
				$i=$i+2;
			}
			elsif ($threeletters eq "sda") {
				push(@variantletters,"nsda|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "seb") {
				push(@variantletters,"sub|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "seg") {
				push(@variantletters,"zeg|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "sex") {
				push(@variantletters,"sek|1");
				push(@variantletters,"seks|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "sga") {
				push(@variantletters,"scha|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "sha") {
				push(@variantletters,"scha|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "shi") {
				push(@variantletters,"schi|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "sie") {
				push(@variantletters,"cie|0.0769230769230769");
				push(@variantletters,"ie|0.153846153846154");
				push(@variantletters,"sie|0.538461538461538");
				push(@variantletters,"tie|0.230769230769231");
				push(@variantletters,"ntie|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "sje") {
				push(@variantletters,"sje|0.666666666666667");
				push(@variantletters,"stje|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "sla") {
				push(@variantletters,"sl|0.1");
				push(@variantletters,"sla|0.9");
				$i=$i+2;
			}
			elsif ($threeletters eq "sme") {
				push(@variantletters,"sm|0.25");
				push(@variantletters,"sme|0.75");
				$i=$i+2;
			}
			elsif ($threeletters eq "snd") {
				push(@variantletters,"sd|1");
				push(@variantletters,"nsd|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "sor") {
				push(@variantletters,"so|0.5");				
				push(@variantletters,"sorr|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "spe") {
				push(@variantletters,"sp|0.05");
				push(@variantletters,"spe|0.95");
				$i=$i+2;
			}
			elsif ($threeletters eq "spl") {
				push(@variantletters,"spel|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ssh") {
				push(@variantletters,"ssch|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "str") {
				push(@variantletters,"ster|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "stu") {
				push(@variantletters,"st|0.0666666666666667");
				push(@variantletters,"stu|0.933333333333333");
				push(@variantletters,"stu|0.666666666666667");
				push(@variantletters,"stuu|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "taf") {
				push(@variantletters,"tof|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "tee") {
				push(@variantletters,"te|0.5");
				push(@variantletters,"tee|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "teg") {
				push(@variantletters,"ig|0.111111111111111");
				push(@variantletters,"teg|0.777777777777778");
				push(@variantletters,"tig|0.111111111111111");
				$i=$i+2;
			}
			elsif ($threeletters eq "tek") {
				push(@variantletters,"tk|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ten") {
				push(@variantletters,"t|0.0113636363636364");
				push(@variantletters,"ten|0.988636363636364");
				push(@variantletters,"eten|0.333333333333333");
				push(@variantletters,"tten|0.666666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "tes") {
				push(@variantletters,"tis|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "tog") {
				push(@variantletters,"toc|1");
				push(@variantletters,"toch|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "too") {
				push(@variantletters,"oo|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "tre") {
				push(@variantletters,"ter|0.5");
				push(@variantletters,"tere|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "tri") {
				push(@variantletters,"trui|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "tru") {
				push(@variantletters,"teru|0.8");
				push(@variantletters,"trou|0.2");
				$i=$i+2;
			}
			elsif ($threeletters eq "tsc") {
				push(@variantletters,"dsc|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "tsi") {
				push(@variantletters,"ti|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "tta") {
				push(@variantletters,"ta|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "tte") {
				push(@variantletters,"t|0.0909090909090909");
				push(@variantletters,"tte|0.909090909090909");
				push(@variantletters,"t|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "tui") {
				push(@variantletters,"tui|0.8");
				push(@variantletters,"ui|0.2");
				push(@variantletters,"uit|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "tur") {
				push(@variantletters,"ter|0.0526315789473684");
				push(@variantletters,"tur|0.947368421052632");
				push(@variantletters,"stur|0.333333333333333");
				push(@variantletters,"tuur|0.666666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "tuu") {
				push(@variantletters,"tu|0.1");
				push(@variantletters,"tuu|0.9");
				$i=$i+2;
			}
			elsif ($threeletters eq "uda") {
				push(@variantletters,"eda|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "uek") {
				push(@variantletters,"uk|1");
				push(@variantletters,"euk|0.5");
				push(@variantletters,"uke|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "ufe") {
				push(@variantletters,"uffe|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "uid") {
				push(@variantletters,"uitd|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "uil") {
				push(@variantletters,"uitl|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "uke") {
				push(@variantletters,"uke|0.888888888888889");
				push(@variantletters,"ukk|0.111111111111111");
				push(@variantletters,"ukki|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "uki") {
				push(@variantletters,"ukki|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "uli") {
				push(@variantletters,"ulli|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ume") {
				push(@variantletters,"umme|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "uow") {
				push(@variantletters,"uw|1");
				push(@variantletters,"ouw|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ure") {
				push(@variantletters,"eru|0.0625");
				push(@variantletters,"ure|0.9375");
				push(@variantletters,"uren|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "urf") {
				push(@variantletters,"urft|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "urt") {
				push(@variantletters,"urd|0.818181818181818");
				push(@variantletters,"urt|0.181818181818182");
				push(@variantletters,"uurd|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "usc") {
				push(@variantletters,"issc|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ute") {
				push(@variantletters,"te|0.0526315789473684");
				push(@variantletters,"ute|0.947368421052632");
				$i=$i+2;
			}
			elsif ($threeletters eq "uuk") {
				push(@variantletters,"euk|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "uur") {
				push(@variantletters,"ur|0.08");
				push(@variantletters,"uur|0.92");
				$i=$i+2;
			}
			elsif ($threeletters eq "vaa") {
				push(@variantletters,"va|0.333333333333333");
				push(@variantletters,"vaa|0.666666666666667");
				push(@variantletters,"evaa|0.25");
				push(@variantletters,"vraa|0.75");
				$i=$i+2;
			}
			elsif ($threeletters eq "val") {
				push(@variantletters,"vall|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "van") {
				push(@variantletters,"van|0.988636363636364");
				$i=$i+2;
			}
			elsif ($threeletters eq "ven") {
				push(@variantletters,"ft|0.0416666666666667");
				push(@variantletters,"ven|0.958333333333333");
				push(@variantletters,"even|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "ver") {
				push(@variantletters,"ver|0.8");
				push(@variantletters,"verr|0.2");
				$i=$i+2;
			}
			elsif ($threeletters eq "vie") {
				push(@variantletters,"vie|0.75");
				push(@variantletters,"vin|0.25");
				$i=$i+2;
			}
			elsif ($threeletters eq "vin") {
				push(@variantletters,"vind|0.75");
				push(@variantletters,"vrie|0.25");
				$i=$i+2;
			}
			elsif ($threeletters eq "vji") {
				push(@variantletters,"vri|1");
				push(@variantletters,"vrij|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "vlo") {
				push(@variantletters,"vo|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "vor") {
				push(@variantletters,"voor|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "vrs") {
				push(@variantletters,"vers|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "waa") {
				push(@variantletters,"waa|0.962962962962963");
				push(@variantletters,"wan|0.037037037037037");
				$i=$i+2;
			}
			elsif ($threeletters eq "wak") {
				push(@variantletters,"wakk|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "wan") {
				push(@variantletters,"wann|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "war") {
				push(@variantletters,"waar|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "wee") {
				push(@variantletters,"we|0.0181818181818182");
				push(@variantletters,"wee|0.981818181818182");
				$i=$i+2;
			}
			elsif ($threeletters eq "wej") {
				push(@variantletters,"wj|1");
				push(@variantletters,"uwj|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "wel") {
				push(@variantletters,"wel|0.975609756097561");
				push(@variantletters,"wil|0.024390243902439");
				$i=$i+2;
			}
			elsif ($threeletters eq "wes") {
				push(@variantletters,"wees|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "wet") {
				push(@variantletters,"wat|0.2");
				push(@variantletters,"wet|0.8");
				$i=$i+2;
			}
			elsif ($threeletters eq "wie") {
				push(@variantletters,"wi|0.07");
				push(@variantletters,"wee|0.07");
				push(@variantletters,"wie|0.857142857142857");
				$i=$i+2;
			}
			elsif ($threeletters eq "wii") {
				push(@variantletters,"wii|0.5");
				push(@variantletters,"won|0.5");
				push(@variantletters,"won|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "wik") {
				push(@variantletters,"wiek|0.5");
				push(@variantletters,"week|0.5");
				$i=$i+2;
			}
			elsif ($threeletters eq "wil") {
				push(@variantletters,"wi|0.0285714285714286");
				push(@variantletters,"wil|0.971428571428571");
				$i=$i+2;
			}
			elsif ($threeletters eq "wis") {
				push(@variantletters,"is|1");
				push(@variantletters,"is'|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "wja") {
				push(@variantletters,"uwja|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "wji") {
				push(@variantletters,"wij|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "woe") {
				push(@variantletters,"woen|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "won") {
				push(@variantletters,"wonn|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "wor") {
				push(@variantletters,"woor|0.25");
				push(@variantletters,"word|0.75");
				$i=$i+2;
			}
			elsif ($threeletters eq "wto") {
				push(@variantletters,"wo|1");
				push(@variantletters,"two|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "wwa") {
				push(@variantletters,"wa|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "yij") {
				push(@variantletters,"jij|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "yon") {
				push(@variantletters,"ion|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "xus") {
				push(@variantletters,"dus|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "you") {
				push(@variantletters,"jou|0.2");
				push(@variantletters,"you|0.8");
				$i=$i+2;
			}
			elsif ($threeletters eq "zee") {
				push(@variantletters,"ze|0.25");
				push(@variantletters,"zee|0.75");
				$i=$i+2;
			}
			elsif ($threeletters eq "zeg") {
				push(@variantletters,"zegg|0.833333333333333");
				push(@variantletters,"zegt|0.166666666666667");
				$i=$i+2;
			}
			elsif ($threeletters eq "zei") {
				push(@variantletters,"asei|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "zet") {
				push(@variantletters,"zet|0.666666666666667");
				push(@variantletters,"zit|0.333333333333333");
				push(@variantletters,"zett|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "zic") {
				push(@variantletters,"zic|0.666666666666667");
				push(@variantletters,"zig|0.333333333333333");
				$i=$i+2;
			}
			elsif ($threeletters eq "zie") {
				push(@variantletters,"zi|0.0169491525423729");
				push(@variantletters,"zie|0.983050847457627");
				push(@variantletters,"zie|0.75");
				push(@variantletters,"ziet|0.25");
				$i=$i+2;
			}
			elsif ($threeletters eq "zij") {
				push(@variantletters,"zei|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "zit") {
				push(@variantletters,"zi|0.125");
				push(@variantletters,"zit|0.875");
				push(@variantletters,"zitt|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "zji") {
				push(@variantletters,"zijn|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "zoh") {
				push(@variantletters,"zon|1");
				$i=$i+2;
			}
			elsif ($threeletters eq "zoo") {
				push(@variantletters,"zo|1");
				$i=$i+2;
			}
			elsif ($twoletters eq "aa") {
				push(@variantletters,"a|0.0355731225296443");
				push(@variantletters,"aa|0.934782608695652");
				$i++;;
			}
			elsif ($twoletters eq "ad") {
				push(@variantletters,"ad|0.944444444444444");
				push(@variantletters,"al|0.0555555555555556");
				$i++;;
			}
			elsif ($twoletters eq "ae") {
				push(@variantletters,"ae|0.5");
				push(@variantletters,"aa|0.5");
				$i++;;
			}
			elsif ($twoletters eq "af") {
				push(@variantletters,"af|0.928571428571429");
				push(@variantletters,"of|0.0714285714285714");
				$i++;;
			}
			elsif ($twoletters eq "ag") {
				push(@variantletters,"ag|0.996296296296296");
				$i++;;
			}
			elsif ($twoletters eq "ak") {
				push(@variantletters,"ak|0.929577464788732");
				push(@variantletters,"akk|0.0422535211267606");
				push(@variantletters,"ank|0.028169014084507");
				push(@variantletters,"ank|1");
				$i++;;
			}
			elsif ($twoletters eq "al") {
				push(@variantletters,"a|0.0246913580246914");
				push(@variantletters,"al|0.901234567901235");
				push(@variantletters,"all|0.0699588477366255");
				push(@variantletters,"alle|1");
				$i++;;
			}
			elsif ($twoletters eq "am") {
				push(@variantletters,"a|0.0103092783505155");
				push(@variantletters,"am|0.989690721649485");
				$i++;;
			}
			elsif ($twoletters eq "an") {
				push(@variantletters,"an|0.970260223048327");
				$i++;;
			}
			elsif ($twoletters eq "ap") {
				push(@variantletters,"ap|0.972222222222222");
				push(@variantletters,"app|0.0277777777777778");
				push(@variantletters,"eb|0.0277777777777778");
				$i++;;
			}
			elsif ($twoletters eq "ar") {
				push(@variantletters,"aar|0.0206185567010309");
				push(@variantletters,"ar|0.962199312714777");
				$i++;;
			}
			elsif ($twoletters eq "as") {
				push(@variantletters,"a's|0.032258064516129");
				push(@variantletters,"an|0.010752688172043");
				push(@variantletters,"ant|0.010752688172043");
				push(@variantletters,"as|0.935483870967742");
				push(@variantletters,"rts|0.010752688172043");
				$i++;;
			}
			elsif ($twoletters eq "at") {
				push(@variantletters,"at|0.981481481481482");
				$i++;;
			}
			elsif ($twoletters eq "au") {
				push(@variantletters,"au|0.692307692307692");
				push(@variantletters,"hou|0.0769230769230769");
				push(@variantletters,"ou|0.230769230769231");
				$i++;;
			}
			elsif ($twoletters eq "av") {
				push(@variantletters,"§av|1");
				$i++;;
			}
			elsif ($twoletters eq "az") {
				push(@variantletters,"aa|0.333333333333333");
				push(@variantletters,"aas|0.333333333333333");
				push(@variantletters,"az|0.333333333333333");
				$i++;;
			}
			elsif ($twoletters eq "ba") {
				push(@variantletters,"ba|0.863636363636364");
				push(@variantletters,"be|0.0454545454545455");
				push(@variantletters,"bea|0.0454545454545455");
				push(@variantletters,"da|0.0454545454545455");
				$i++;;
			}
			elsif ($twoletters eq "bb") {
				push(@variantletters,"b|0.105263157894737");
				push(@variantletters,"bb|0.894736842105263");
				$i++;;
			}
			elsif ($twoletters eq "be") {
				push(@variantletters,"be|0.980769230769231");
				$i++;;
			}
			elsif ($twoletters eq "bg") {
				push(@variantletters,"beg|1");
				$i++;;
			}
			elsif ($twoletters eq "bi") {
				push(@variantletters,"bi|0.976190476190476");
				push(@variantletters,"bui|0.0238095238095238");
				$i++;;
			}
			elsif ($twoletters eq "bj") {
				push(@variantletters,"bij|1");
				$i++;;
			}
			elsif ($twoletters eq "bo") {
				push(@variantletters,"bedo|1");
				$i++;;
			}
			elsif ($twoletters eq "br") {
				push(@variantletters,"ber|0.0625");
				push(@variantletters,"br|0.9375");
				$i++;;
			}
			elsif ($twoletters eq "bt") {
				push(@variantletters,"b|0.2");
				push(@variantletters,"bt|0.8");
				$i++;;
			}
			elsif ($twoletters eq "by") {
				push(@variantletters,"by|0.857142857142857");
				push(@variantletters,"y|0.142857142857143");
				$i++;;
			}
			elsif ($twoletters eq "ca") {
				push(@variantletters,"ca|0.944444444444444");
				push(@variantletters,"Ã§a|0.0555555555555556");
				push(@variantletters,"Ã§a|1");
				$i++;;
			}
			elsif ($twoletters eq "ce") {
				push(@variantletters,"ce|0.933333333333333");
				push(@variantletters,"tje|0.0666666666666667");
				$i++;;
			}
			elsif ($twoletters eq "ch") {
				push(@variantletters,"ch|0.976470588235294");
				push(@variantletters,"ssch|1");
				$i++;;
			}
			elsif ($twoletters eq "co") {
				push(@variantletters,"co|0.956521739130435");
				push(@variantletters,"kko|0.0434782608695652");
				$i++;;
			}
			elsif ($twoletters eq "ct") {
				push(@variantletters,"cht|0.5");
				push(@variantletters,"ct|0.5");
				$i++;;
			}
			elsif ($twoletters eq "da") {
				push(@variantletters,"da|0.933940774487471");
				push(@variantletters,"dat|0.0318906605922551");
				push(@variantletters,"daar|1");
				$i++;;
			}
			elsif ($twoletters eq "de") {
				push(@variantletters,"be|0.022140221402214");
				push(@variantletters,"de|0.922509225092251");
				push(@variantletters,"doe|0.022140221402214");
				push(@variantletters,"te|0.011070110701107");
				push(@variantletters,"doe|1");
				$i++;;
			}
			elsif ($twoletters eq "dg") {
				push(@variantletters,"dag|1");
				$i++;;
			}
			elsif ($twoletters eq "di") {
				push(@variantletters,"di|0.974683544303797");
				push(@variantletters,"dik|0.0126582278481013");
				push(@variantletters,"din|0.0126582278481013");
				$i++;;
			}
			elsif ($twoletters eq "dj") {
				push(@variantletters,"dj|0.818181818181818");
				push(@variantletters,"tj|0.181818181818182");
				$i++;;
			}
			elsif ($twoletters eq "dl") {
				push(@variantletters,"ll|1");
				$i++;;
			}
			elsif ($twoletters eq "do") {
				push(@variantletters,"do|0.981481481481482");
				push(@variantletters,"tdo|0.0185185185185185");
				$i++;;
			}
			elsif ($twoletters eq "dr") {
				push(@variantletters,"der|0.0588235294117647");
				push(@variantletters,"dr|0.941176470588235");
				$i++;;
			}
			elsif ($twoletters eq "dt") {
				push(@variantletters,"d|0.2");
				push(@variantletters,"dt|0.6");
				push(@variantletters,"t|0.2");
				$i++;;
			}
			elsif ($twoletters eq "du") {
				push(@variantletters,"do|0.05");
				push(@variantletters,"doe|0.05");
				push(@variantletters,"du|0.85");
				push(@variantletters,"tu|0.05");
				push(@variantletters,"tuw|1");
				$i++;;
			}
			elsif ($twoletters eq "dw") {
				push(@variantletters,"tw|1");
				$i++;;
			}
			elsif ($twoletters eq "ea") {
				push(@variantletters,"a|0.125");
				push(@variantletters,"ea|0.875");
				$i++;;
			}
			elsif ($twoletters eq "eb") {
				push(@variantletters,"e|0.010989010989011");
				push(@variantletters,"eb|0.901098901098901");
				push(@variantletters,"ebb|0.010989010989011");
				push(@variantletters,"ee|0.010989010989011");
				push(@variantletters,"eef|0.010989010989011");
				push(@variantletters,"en|0.010989010989011");
				push(@variantletters,"ub|0.043956043956044");
				push(@variantletters,"eeft|1");
				$i++;;
			}
			elsif ($twoletters eq "ec") {
				push(@variantletters,"ec|0.875");
				push(@variantletters,"et|0.0625");
				push(@variantletters,"etj|0.0625");
				$i++;;
			}
			elsif ($twoletters eq "ed") {
				push(@variantletters,"ed|0.931506849315068");
				push(@variantletters,"et|0.0410958904109589");
				$i++;;
			}
			elsif ($twoletters eq "ee") {
				push(@variantletters,"e|0.045045045045045");
				push(@variantletters,"ee|0.941441441441441");
				$i++;;
			}
			elsif ($twoletters eq "ef") {
				push(@variantletters,"e|0.0153846153846154");
				push(@variantletters,"ef|0.984615384615385");
				$i++;;
			}
			elsif ($twoletters eq "eg") {
				push(@variantletters,"ag|0.0119047619047619");
				push(@variantletters,"ec|0.0119047619047619");
				push(@variantletters,"ech|0.0119047619047619");
				push(@variantletters,"eeg|0.0119047619047619");
				push(@variantletters,"eg|0.80952380952381");
				push(@variantletters,"ege|0.0119047619047619");
				push(@variantletters,"egg|0.0595238095238095");
				push(@variantletters,"egt|0.0119047619047619");
				push(@variantletters,"g|0.0119047619047619");
				push(@variantletters,"ig|0.0119047619047619");
				push(@variantletters,"ijg|0.0119047619047619");
				push(@variantletters,"kig|0.0119047619047619");
				push(@variantletters,"ug|0.0119047619047619");
				$i++;;
			}
			elsif ($twoletters eq "eh") {
				push(@variantletters,"eh|0.9");
				push(@variantletters,"en|0.1");
				$i++;;
			}
			elsif ($twoletters eq "ei") {
				push(@variantletters,"ei|0.95");
				push(@variantletters,"ey|0.025");
				push(@variantletters,"sei|0.025");
				$i++;;
			}
			elsif ($twoletters eq "ej") {
				push(@variantletters,"ei|0.2");
				push(@variantletters,"ej|0.4");
				push(@variantletters,"ey|0.2");
				push(@variantletters,"j|0.2");
				$i++;;
			}
			elsif ($twoletters eq "ek") {
				push(@variantletters,"e|0.0117647058823529");
				push(@variantletters,"ek|0.917647058823529");
				push(@variantletters,"enk|0.0235294117647059");
				push(@variantletters,"k|0.0235294117647059");
				push(@variantletters,"ke|0.0117647058823529");
				push(@variantletters,"nk|0.0117647058823529");
				$i++;;
			}
			elsif ($twoletters eq "el") {
				push(@variantletters,"el|0.969798657718121");
				push(@variantletters,"elij|1");
				$i++;;
			}
			elsif ($twoletters eq "em") {
				push(@variantletters,"em|0.986111111111111");
				push(@variantletters,"en|0.0138888888888889");
				push(@variantletters,"etm|1");
				$i++;;
			}
			elsif ($twoletters eq "en") {
				push(@variantletters,"en|0.978835978835979");
				$i++;;
			}
			elsif ($twoletters eq "eo") {
				push(@variantletters,"e|0.466666666666667");
				push(@variantletters,"o|0.0666666666666667");
				push(@variantletters,"oe|0.466666666666667");
				$i++;;
			}
			elsif ($twoletters eq "ep") {
				push(@variantletters,"eb|0.5");
				push(@variantletters,"ebt|0.0625");
				push(@variantletters,"ep|0.375");
				push(@variantletters,"et|0.03125");
				push(@variantletters,"pp|0.03125");
				$i++;;
			}
			elsif ($twoletters eq "er") {
				push(@variantletters,"er|0.989333333333333");
				push(@variantletters,"meer|1");
				$i++;;
			}
			elsif ($twoletters eq "es") {
				push(@variantletters,"es|0.951557093425606");
				push(@variantletters,"est|0.0103806228373702");
				push(@variantletters,"iss|0.0103806228373702");
				push(@variantletters,"eest|1");
				$i++;;
			}
			elsif ($twoletters eq "et") {
				push(@variantletters,"ed|0.0143540669856459");
				push(@variantletters,"et|0.971291866028708");
				$i++;;
			}
			elsif ($twoletters eq "eu") {
				push(@variantletters,"eu|0.984375");
				push(@variantletters,"u|0.015625");
				$i++;;
			}
			elsif ($twoletters eq "ev") {
				push(@variantletters,"ev|0.990825688073395");
				$i++;;
			}
			elsif ($twoletters eq "ew") {
				push(@variantletters,"euw|0.0869565217391304");
				push(@variantletters,"ew|0.91304347826087");
				push(@variantletters,"ewe|1");
				$i++;;
			}
			elsif ($twoletters eq "ex") {
				push(@variantletters,"ek|0.333333333333333");
				push(@variantletters,"eks|0.333333333333333");
				push(@variantletters,"ex|0.333333333333333");
				$i++;;
			}
			elsif ($twoletters eq "fd") {
				push(@variantletters,"efd|0.0526315789473684");
				push(@variantletters,"fd|0.947368421052632");
				$i++;;
			}
			elsif ($twoletters eq "fe") {
				push(@variantletters,"e|0.0526315789473684");
				push(@variantletters,"fe|0.894736842105263");
				push(@variantletters,"fee|0.0263157894736842");
				push(@variantletters,"ffe|0.0263157894736842");
				$i++;;
			}
			elsif ($twoletters eq "fo") {
				push(@variantletters,"fe|0.0714285714285714");
				push(@variantletters,"ff|0.0714285714285714");
				push(@variantletters,"ffe|0.0714285714285714");
				push(@variantletters,"fo|0.785714285714286");
				$i++;;
			}
			elsif ($twoletters eq "ft") {
				push(@variantletters,"fd|0.125");
				push(@variantletters,"ft|0.875");
				$i++;;
			}
			elsif ($twoletters eq "fv") {
				push(@variantletters,"v|1");
				$i++;;
			}
			elsif ($twoletters eq "ga") {
				push(@variantletters,"cha|0.0150375939849624");
				push(@variantletters,"g|0.0451127819548872");
				push(@variantletters,"ga|0.932330827067669");
				$i++;;
			}
			elsif ($twoletters eq "gd") {
				push(@variantletters,"egd|0.25");
				push(@variantletters,"gd|0.5");
				push(@variantletters,"ged|0.25");
				$i++;;
			}
			elsif ($twoletters eq "ge") {
				push(@variantletters,"g|0.0136518771331058");
				push(@variantletters,"ge|0.95221843003413");
				push(@variantletters,"gge|0.0170648464163823");
				$i++;;
			}
			elsif ($twoletters eq "gk") {
				push(@variantletters,"gek|0.5");
				push(@variantletters,"gk|0.5");
				$i++;;
			}
			elsif ($twoletters eq "gl") {
				push(@variantletters,"gel|0.0645161290322581");
				push(@variantletters,"gl|0.935483870967742");
				$i++;;
			}
			elsif ($twoletters eq "gn") {
				push(@variantletters,"gen|1");
				$i++;;
			}
			elsif ($twoletters eq "gr") {
				push(@variantletters,"gr|0.973509933774834");
				push(@variantletters,"gro|0.0198675496688742");
				push(@variantletters,"groe|1");
				$i++;;
			}
			elsif ($twoletters eq "gt") {
				push(@variantletters,"cht|0.111111111111111");
				push(@variantletters,"gd|0.111111111111111");
				push(@variantletters,"gt|0.777777777777778");
				$i++;;
			}
			elsif ($twoletters eq "gu") {
				push(@variantletters,"ge|0.5");
				push(@variantletters,"gen|0.25");
				push(@variantletters,"gu|0.125");
				push(@variantletters,"he|0.125");
				push(@variantletters,"gend|1");
				$i++;;
			}
			elsif ($twoletters eq "gv") {
				push(@variantletters,"gev|1");
				$i++;;
			}
			elsif ($twoletters eq "ha") {
				push(@variantletters,"ha|0.915841584158416");
				push(@variantletters,"hal|0.0445544554455446");
				$i++;;
			}
			elsif ($twoletters eq "he") {
				push(@variantletters,"ge|0.0153846153846154");
				push(@variantletters,"he|0.964102564102564");
				$i++;;
			}
			elsif ($twoletters eq "hi") {
				push(@variantletters,"chi|0.0285714285714286");
				push(@variantletters,"hi|0.914285714285714");
				push(@variantletters,"hie|0.0285714285714286");
				push(@variantletters,"hri|0.0285714285714286");
				push(@variantletters,"chie|1");
				$i++;;
			}
			elsif ($twoletters eq "hj") {
				push(@variantletters,"h|1");
				$i++;;
			}
			elsif ($twoletters eq "ho") {
				push(@variantletters,"go|0.013986013986014");
				push(@variantletters,"ho|0.979020979020979");
				$i++;;
			}
			elsif ($twoletters eq "hu") {
				push(@variantletters,"he|0.318181818181818");
				push(@variantletters,"het|0.0454545454545455");
				push(@variantletters,"hu|0.636363636363636");
				push(@variantletters,"het|1");
				$i++;;
			}
			elsif ($twoletters eq "hw") {
				push(@variantletters,"nw|1");
				$i++;;
			}
			elsif ($twoletters eq "hy") {
				push(@variantletters,"hi|0.5");
				push(@variantletters,"hij|0.5");
				$i++;;
			}
			elsif ($twoletters eq "ic") {
				push(@variantletters,"ic|0.941176470588235");
				push(@variantletters,"ich|0.0294117647058824");
				push(@variantletters,"ig|0.0294117647058824");
				push(@variantletters,"issc|1");
				$i++;;
			}
			elsif ($twoletters eq "id") {
				push(@variantletters,"id|0.842105263157895");
				push(@variantletters,"ijd|0.0526315789473684");
				push(@variantletters,"it|0.0526315789473684");
				push(@variantletters,"itd|0.0526315789473684");
				$i++;;
			}
			elsif ($twoletters eq "ie") {
				push(@variantletters,"ie|0.963302752293578");
				push(@variantletters,"iet|0.0128440366972477");
				push(@variantletters,"y|0.0128440366972477");
				$i++;;
			}
			elsif ($twoletters eq "if") {
				push(@variantletters,"ief|0.2");
				push(@variantletters,"if|0.7");
				push(@variantletters,"ip|0.1");
				$i++;;
			}
			elsif ($twoletters eq "ii") {
				push(@variantletters,"ii|0.333333333333333");
				push(@variantletters,"on|0.333333333333333");
				$i++;;
			}
			elsif ($twoletters eq "ij") {
				push(@variantletters,"ij|0.960093896713615");
				push(@variantletters,"ijn|0.0164319248826291");
				$i++;;
			}
			elsif ($twoletters eq "ik") {
				push(@variantletters,"ik|0.991525423728814");
				$i++;;
			}
			elsif ($twoletters eq "il") {
				push(@variantletters,"i|0.0103092783505155");
				push(@variantletters,"ik|0.0103092783505155");
				push(@variantletters,"il|0.969072164948454");
				push(@variantletters,"itl|0.0103092783505155");
				$i++;;
			}
			elsif ($twoletters eq "im") {
				push(@variantletters,"em|0.0204081632653061");
				push(@variantletters,"im|0.979591836734694");
				$i++;;
			}
			elsif ($twoletters eq "in") {
				push(@variantletters,"in|0.952173913043478");
				push(@variantletters,"ind|0.0130434782608696");
				$i++;;
			}
			elsif ($twoletters eq "is") {
				push(@variantletters,"is|0.974921630094044");
				push(@variantletters,"is'|0.0125391849529781");
				push(@variantletters,"eens|1");
				$i++;;
			}
			elsif ($twoletters eq "it") {
				push(@variantletters,"i|0.0384615384615385");
				push(@variantletters,"id|0.0192307692307692");
				push(@variantletters,"iet|0.0384615384615385");
				push(@variantletters,"it|0.884615384615385");
				push(@variantletters,"itt|0.0192307692307692");
				push(@variantletters,"itte|1");
				$i++;;
			}
			elsif ($twoletters eq "iu") {
				push(@variantletters,"i|0.333333333333333");
				push(@variantletters,"ie|0.166666666666667");
				push(@variantletters,"iet|0.166666666666667");
				push(@variantletters,"ui|0.333333333333333");
				push(@variantletters,"iet|1");
				$i++;;
			}
			elsif ($twoletters eq "iy") {
				push(@variantletters,"ij|0.5");
				push(@variantletters,"ry|0.5");
				$i++;;
			}
			elsif ($twoletters eq "ja") {
				push(@variantletters,"j|0.024390243902439");
				push(@variantletters,"ja|0.951219512195122");
				push(@variantletters,"jo|0.024390243902439");
				$i++;;
			}
			elsif ($twoletters eq "jd") {
				push(@variantletters,"j|0.0769230769230769");
				push(@variantletters,"jd|0.846153846153846");
				push(@variantletters,"jt|0.0769230769230769");
				$i++;;
			}
			elsif ($twoletters eq "je") {
				push(@variantletters,"je|0.978155339805825");
				$i++;;
			}
			elsif ($twoletters eq "jf") {
				push(@variantletters,"j|0.142857142857143");
				push(@variantletters,"jf|0.857142857142857");
				$i++;;
			}
			elsif ($twoletters eq "ji") {
				push(@variantletters,"ij|0.0380952380952381");
				push(@variantletters,"j|0.0380952380952381");
				push(@variantletters,"ji|0.838095238095238");
				push(@variantletters,"jij|0.0285714285714286");
				$i++;;
			}
			elsif ($twoletters eq "jm") {
				push(@variantletters,"jme|1");
				$i++;;
			}
			elsif ($twoletters eq "jn") {
				push(@variantletters,"jn|0.99009900990099");
				$i++;;
			}
			elsif ($twoletters eq "jo") {
				push(@variantletters,"je|0.0114942528735632");
				push(@variantletters,"jo|0.977011494252874");
				push(@variantletters,"ko|0.0114942528735632");
				$i++;;
			}
			elsif ($twoletters eq "jt") {
				push(@variantletters,"jd|0.272727272727273");
				push(@variantletters,"jt|0.636363636363636");
				push(@variantletters,"t|0.0909090909090909");
				$i++;;
			}
			elsif ($twoletters eq "ju") {
				push(@variantletters,"ju|0.986111111111111");
				$i++;;
			}
			elsif ($twoletters eq "jv") {
				push(@variantletters,"jf|0.166666666666667");
				push(@variantletters,"jv|0.666666666666667");
				push(@variantletters,"v|0.166666666666667");
				$i++;;
			}
			elsif ($twoletters eq "ka") {
				push(@variantletters,"ca|0.0198019801980198");
				push(@variantletters,"ka|0.96039603960396");
				push(@variantletters,"ke|0.0198019801980198");
				$i++;;
			}
			elsif ($twoletters eq "ke") {
				push(@variantletters,"eke|0.0106382978723404");
				push(@variantletters,"ke|0.936170212765957");
				push(@variantletters,"ken|0.0106382978723404");
				push(@variantletters,"kke|0.0212765957446809");
				push(@variantletters,"ijke|1");
				$i++;;
			}
			elsif ($twoletters eq "kg") {
				push(@variantletters,"kig|1");
				push(@variantletters,"kkig|1");
				$i++;;
			}
			elsif ($twoletters eq "ki") {
				push(@variantletters,"ik|0.0140845070422535");
				push(@variantletters,"k|0.0140845070422535");
				push(@variantletters,"ki|0.929577464788732");
				push(@variantletters,"kie|0.0140845070422535");
				push(@variantletters,"kig|0.0140845070422535");
				push(@variantletters,"kki|0.0140845070422535");
				$i++;;
			}
			elsif ($twoletters eq "kj") {
				push(@variantletters,"nkj|1");
				$i++;;
			}
			elsif ($twoletters eq "kl") {
				push(@variantletters,"kl|0.961538461538462");
				push(@variantletters,"kle|0.0384615384615385");
				$i++;;
			}
			elsif ($twoletters eq "ko") {
				push(@variantletters,"k|0.0403225806451613");
				push(@variantletters,"ko|0.935483870967742");
				$i++;;
			}
			elsif ($twoletters eq "kr") {
				push(@variantletters,"kr|0.975903614457831");
				push(@variantletters,"kre|0.0120481927710843");
				push(@variantletters,"nkr|0.0120481927710843");
				$i++;;
			}
			elsif ($twoletters eq "ku") {
				push(@variantletters,"nku|1");
				$i++;;
			}
			elsif ($twoletters eq "kw") {
				push(@variantletters,"ikw|1");
				$i++;;
			}
			elsif ($twoletters eq "kz") {
				push(@variantletters,"ka|0.5");
				push(@variantletters,"kan|0.5");
				push(@variantletters,"kant|1");
				$i++;;
			}
			elsif ($twoletters eq "la") {
				push(@variantletters,"l|0.0123456790123457");
				push(@variantletters,"la|0.987654320987654");
				$i++;;
			}
			elsif ($twoletters eq "le") {
				push(@variantletters,"l|0.0180995475113122");
				push(@variantletters,"le|0.927601809954751");
				push(@variantletters,"lle|0.0271493212669683");
				$i++;;
			}
			elsif ($twoletters eq "lg") {
				push(@variantletters,"leg|0.142857142857143");
				push(@variantletters,"lg|0.857142857142857");
				$i++;;
			}
			elsif ($twoletters eq "li") {
				push(@variantletters,"li|0.974619289340102");
				push(@variantletters,"lie|0.0101522842639594");
				$i++;;
			}
			elsif ($twoletters eq "lj") {
				push(@variantletters,"k|0.333333333333333");
				push(@variantletters,"lj|0.333333333333333");
				push(@variantletters,"ltj|0.333333333333333");
				$i++;;
			}
			elsif ($twoletters eq "lk") {
				push(@variantletters,"lijk|1");
				$i++;;
			}
			elsif ($twoletters eq "ll") {
				push(@variantletters,"l|0.033112582781457");
				push(@variantletters,"ll|0.960264900662252");
				$i++;;
			}
			elsif ($twoletters eq "lo") {
				push(@variantletters,"l|0.0114942528735632");
				push(@variantletters,"llo|0.103448275862069");
				push(@variantletters,"lo|0.873563218390805");
				push(@variantletters,"o|0.0114942528735632");
				$i++;;
			}
			elsif ($twoletters eq "lp") {
				push(@variantletters,"lp|0.8");
				push(@variantletters,"p|0.1");
				push(@variantletters,"pe|0.1");
				push(@variantletters,"pen|1");
				$i++;;
			}
			elsif ($twoletters eq "ls") {
				push(@variantletters,"els|0.0212765957446809");
				push(@variantletters,"les|0.0638297872340425");
				push(@variantletters,"ls|0.914893617021277");
				push(@variantletters,"lles|1");
				$i++;;
			}
			elsif ($twoletters eq "lt") {
				push(@variantletters,"ld|0.0344827586206897");
				push(@variantletters,"lt|0.896551724137931");
				push(@variantletters,"t|0.0689655172413793");
				$i++;;
			}
			elsif ($twoletters eq "lu") {
				push(@variantletters,"elu|0.0344827586206897");
				push(@variantletters,"le|0.0689655172413793");
				push(@variantletters,"leu|0.0689655172413793");
				push(@variantletters,"lu|0.758620689655172");
				push(@variantletters,"luk|0.0689655172413793");
				push(@variantletters,"eluk|0.5");
				push(@variantletters,"leuk|0.5");
				$i++;;
			}
			elsif ($twoletters eq "lv") {
				push(@variantletters,"iev|0.2");
				push(@variantletters,"lv|0.8");
				$i++;;
			}
			elsif ($twoletters eq "ma") {
				push(@variantletters,"ma|0.995934959349594");
				push(@variantletters,"maar|1");
				$i++;;
			}
			elsif ($twoletters eq "md") {
				push(@variantletters,"md|0.75");
				push(@variantletters,"nd|0.25");
				$i++;;
			}
			elsif ($twoletters eq "me") {
				push(@variantletters,"me|0.95114006514658");
				push(@variantletters,"mi|0.0162866449511401");
				push(@variantletters,"tme|1");
				$i++;;
			}
			elsif ($twoletters eq "mi") {
				push(@variantletters,"mi|0.974358974358974");
				push(@variantletters,"mis|0.0102564102564103");
				push(@variantletters,"mij|0.0102564102564103");
				push(@variantletters,"chmi|0.5");
				push(@variantletters,"miss|0.5");
				$i++;;
			}
			elsif ($twoletters eq "mj") {
				push(@variantletters,"mij|0.666666666666667");
				push(@variantletters,"mj|0.333333333333333");
				$i++;;
			}
			elsif ($twoletters eq "mm") {
				push(@variantletters,"m|0.0740740740740741");
				push(@variantletters,"mm|0.925925925925926");
				$i++;;
			}
			elsif ($twoletters eq "ms") {
				push(@variantletters,"mis|0.1");
				push(@variantletters,"ms|0.9");
				$i++;;
			}
			elsif ($twoletters eq "mt") {
				push(@variantletters,"m|0.0769230769230769");
				push(@variantletters,"mt|0.923076923076923");
				$i++;;
			}
			elsif ($twoletters eq "mu") {
				push(@variantletters,"me|0.235294117647059");
				push(@variantletters,"men|0.235294117647059");
				push(@variantletters,"mi|0.0588235294117647");
				push(@variantletters,"mis|0.0588235294117647");
				push(@variantletters,"mo|0.0588235294117647");
				push(@variantletters,"moe|0.0588235294117647");
				push(@variantletters,"mu|0.294117647058824");
				$i++;;
			}
			elsif ($twoletters eq "my") {
				push(@variantletters,"mi|0.666666666666667");
				push(@variantletters,"mij|0.333333333333333");
				$i++;;
			}
			elsif ($twoletters eq "n.") {
				push(@variantletters,"n|1");
				$i++;;
			}
			elsif ($twoletters eq "na") {
				push(@variantletters,"na|0.986486486486487");
				$i++;;
			}
			elsif ($twoletters eq "nd") {
				push(@variantletters,"nd|0.96319018404908");
				push(@variantletters,"nt|0.0184049079754601");
				$i++;;
			}
			elsif ($twoletters eq "ne") {
				push(@variantletters,"n|0.0341880341880342");
				push(@variantletters,"ne|0.897435897435897");
				push(@variantletters,"nne|0.0427350427350427");
				$i++;;
			}
			elsif ($twoletters eq "ng") {
				push(@variantletters,"g|0.0217391304347826");
				push(@variantletters,"ng|0.956521739130435");
				push(@variantletters,"nge|0.0217391304347826");
				$i++;;
			}
			elsif ($twoletters eq "ni") {
				push(@variantletters,"ni|0.972093023255814");
				push(@variantletters,"nie|0.013953488372093");
				push(@variantletters,"niet|0.75");
				push(@variantletters,"nnee|0.25");
				$i++;;
			}
			elsif ($twoletters eq "nk") {
				push(@variantletters,"k|0.04");
				push(@variantletters,"nk|0.96");
				$i++;;
			}
			elsif ($twoletters eq "nn") {
				push(@variantletters,"an|0.025");
				push(@variantletters,"en|0.025");
				push(@variantletters,"n|0.025");
				push(@variantletters,"nn|0.925");
				$i++;;
			}
			elsif ($twoletters eq "ns") {
				push(@variantletters,"n|0.0240963855421687");
				push(@variantletters,"ns|0.927710843373494");
				push(@variantletters,"nt|0.0481927710843374");
				$i++;;
			}
			elsif ($twoletters eq "nt") {
				push(@variantletters,"n|0.018348623853211");
				push(@variantletters,"nd|0.073394495412844");
				push(@variantletters,"nt|0.899082568807339");
				$i++;;
			}
			elsif ($twoletters eq "nu") {
				push(@variantletters,"n|0.0317460317460317");
				push(@variantletters,"nu|0.936507936507937");
				push(@variantletters,"num|0.0317460317460317");
				$i++;;
			}
			elsif ($twoletters eq "nw") {
				push(@variantletters,"ntw|1");
				$i++;;
			}
			elsif ($twoletters eq "nz") {
				push(@variantletters,"ns|0.142857142857143");
				push(@variantletters,"nz|0.571428571428571");
				push(@variantletters,"nze|0.285714285714286");
				$i++;;
			}
			elsif ($twoletters eq "oc") {
				push(@variantletters,"oc|0.857142857142857");
				push(@variantletters,"ok|0.0714285714285714");
				push(@variantletters,"okk|0.0714285714285714");
				$i++;;
			}
			elsif ($twoletters eq "oe") {
				push(@variantletters,"oe|0.971794871794872");
				push(@variantletters,"edoe|1");
				$i++;;
			}
			elsif ($twoletters eq "of") {
				push(@variantletters,"of|0.984848484848485");
				push(@variantletters,"v|0.0151515151515152");
				$i++;;
			}
			elsif ($twoletters eq "og") {
				push(@variantletters,"oc|0.137254901960784");
				push(@variantletters,"och|0.137254901960784");
				push(@variantletters,"og|0.725490196078431");
				$i++;;
			}
			elsif ($twoletters eq "oh") {
				push(@variantletters,"oh|0.928571428571429");
				push(@variantletters,"on|0.0714285714285714");
				$i++;;
			}
			elsif ($twoletters eq "oi") {
				push(@variantletters,"o|0.0256410256410256");
				push(@variantletters,"oi|0.923076923076923");
				push(@variantletters,"oie|0.0256410256410256");
				push(@variantletters,"oit|0.0256410256410256");
				$i++;;
			}
			elsif ($twoletters eq "ok") {
				push(@variantletters,"ok|0.982300884955752");
				push(@variantletters,"ook|0.0176991150442478");
				$i++;;
			}
			elsif ($twoletters eq "ol") {
				push(@variantletters,"el|0.0158730158730159");
				push(@variantletters,"fel|0.0158730158730159");
				push(@variantletters,"oi|0.0158730158730159");
				push(@variantletters,"oie|0.0158730158730159");
				push(@variantletters,"ol|0.936507936507937");
				$i++;;
			}
			elsif ($twoletters eq "om") {
				push(@variantletters,"om|0.981927710843373");
				$i++;;
			}
			elsif ($twoletters eq "on") {
				push(@variantletters,"n|0.0681818181818182");
				push(@variantletters,"om|0.0113636363636364");
				push(@variantletters,"on|0.909090909090909");
				push(@variantletters,"onn|0.0113636363636364");
				$i++;;
			}
			elsif ($twoletters eq "oo") {
				push(@variantletters,"o|0.0452830188679245");
				push(@variantletters,"oo|0.947169811320755");
				$i++;;
			}
			elsif ($twoletters eq "or") {
				push(@variantletters,"oor|0.0166666666666667");
				push(@variantletters,"or|0.95");
				push(@variantletters,"ord|0.0166666666666667");
				push(@variantletters,"oor|1");
				$i++;;
			}
			elsif ($twoletters eq "os") {
				push(@variantletters,"on|0.0454545454545455");
				push(@variantletters,"os|0.954545454545455");
				$i++;;
			}
			elsif ($twoletters eq "ot") {
				push(@variantletters,"di|0.0188679245283019");
				push(@variantletters,"ot|0.962264150943396");
				push(@variantletters,"t|0.0188679245283019");
				$i++;;
			}
			elsif ($twoletters eq "ou") {
				push(@variantletters,"ou|0.954022988505747");
				push(@variantletters,"ouw|0.0459770114942529");
				$i++;;
			}
			elsif ($twoletters eq "ow") {
				push(@variantletters,"ow|0.666666666666667");
				push(@variantletters,"w|0.333333333333333");
				$i++;;
			}
			elsif ($twoletters eq "pa") {
				push(@variantletters,"p|0.0363636363636364");
				push(@variantletters,"pa|0.927272727272727");
				push(@variantletters,"pan|0.0363636363636364");
				$i++;;
			}
			elsif ($twoletters eq "pe") {
				push(@variantletters,"p|0.0204081632653061");
				push(@variantletters,"pp|0.0204081632653061");
				push(@variantletters,"pe|0.979591836734694");
				$i++;;
			}
			elsif ($twoletters eq "pi") {
				push(@variantletters,"pi|0.941176470588235");
				push(@variantletters,"pig|0.0588235294117647");
				$i++;;
			}
			elsif ($twoletters eq "pj") {
				push(@variantletters,"tj|1");
				$i++;;
			}
			elsif ($twoletters eq "pl") {
				push(@variantletters,"pel|0.0625");
				push(@variantletters,"pl|0.9375");
				$i++;;
			}
			elsif ($twoletters eq "po") {
				push(@variantletters,"p|0.0769230769230769");
				push(@variantletters,"po|0.923076923076923");
				$i++;;
			}
			elsif ($twoletters eq "ra") {
				push(@variantletters,"ra|0.969512195121951");
				push(@variantletters,"rouw|1");
				$i++;;
			}
			elsif ($twoletters eq "rd") {
				push(@variantletters,"rd|0.933333333333333");
				push(@variantletters,"rda|0.0166666666666667");
				push(@variantletters,"rdt|0.0166666666666667");
				push(@variantletters,"rt|0.0333333333333333");
				$i++;;
			}
			elsif ($twoletters eq "re") {
				push(@variantletters,"ere|0.0175438596491228");
				push(@variantletters,"r|0.0614035087719298");
				push(@variantletters,"re|0.842105263157895");
				$i++;;
			}
			elsif ($twoletters eq "rf") {
				push(@variantletters,"rf|0.666666666666667");
				push(@variantletters,"rft|0.333333333333333");
				$i++;;
			}
			elsif ($twoletters eq "rg") {
				push(@variantletters,"rg|0.979166666666667");
				push(@variantletters,"rge|0.0208333333333333");
				$i++;;
			}
			elsif ($twoletters eq "ri") {
				push(@variantletters,"ri|0.961165048543689");
				$i++;;
			}
			elsif ($twoletters eq "rj") {
				push(@variantletters,"rj|0.833333333333333");
				push(@variantletters,"rtj|0.166666666666667");
				$i++;;
			}
			elsif ($twoletters eq "rl") {
				push(@variantletters,"rl|0.941176470588235");
				push(@variantletters,"rle|0.0588235294117647");
				$i++;;
			}
			elsif ($twoletters eq "rm") {
				push(@variantletters,"erm|0.111111111111111");
				push(@variantletters,"rm|0.888888888888889");
				$i++;;
			}
			elsif ($twoletters eq "ro") {
				push(@variantletters,"ro|0.986206896551724");
				$i++;;
			}
			elsif ($twoletters eq "rr") {
				push(@variantletters,"r|0.0769230769230769");
				push(@variantletters,"rr|0.923076923076923");
				$i++;;
			}
			elsif ($twoletters eq "rs") {
				push(@variantletters,"ers|0.0454545454545455");
				push(@variantletters,"rs|0.954545454545455");
				$i++;;
			}
			elsif ($twoletters eq "rt") {
				push(@variantletters,"rd|0.128205128205128");
				push(@variantletters,"rdt|0.0170940170940171");
				push(@variantletters,"rt|0.846153846153846");
				push(@variantletters,"roet|1");
				$i++;;
			}
			elsif ($twoletters eq "ru") {
				push(@variantletters,"eru|0.114285714285714");
				push(@variantletters,"rou|0.0285714285714286");
				push(@variantletters,"ru|0.828571428571429");
				push(@variantletters,"rug|0.0285714285714286");
				$i++;;
			}
			elsif ($twoletters eq "ry") {
				push(@variantletters,"r|0.0666666666666667");
				push(@variantletters,"ri|0.133333333333333");
				push(@variantletters,"rij|0.133333333333333");
				push(@variantletters,"rj|0.0666666666666667");
				push(@variantletters,"rry|0.0666666666666667");
				push(@variantletters,"ry|0.533333333333333");
				$i++;;
			}
			elsif ($twoletters eq "sa") {
				push(@variantletters,"sa|0.934782608695652");
				push(@variantletters,"sl|0.0217391304347826");
				push(@variantletters,"za|0.0434782608695652");
				$i++;;
			}
			elsif ($twoletters eq "sc") {
				push(@variantletters,"sc|0.946236559139785");
				push(@variantletters,"ssc|0.0537634408602151");
				$i++;;
			}
			elsif ($twoletters eq "sd") {
				push(@variantletters,"nsd|0.1");
				push(@variantletters,"sd|0.9");
				$i++;;
			}
			elsif ($twoletters eq "se") {
				push(@variantletters,"se|0.921875");
				push(@variantletters,"su|0.0625");
				push(@variantletters,"ze|0.015625");
				$i++;;
			}
			elsif ($twoletters eq "sg") {
				push(@variantletters,"sc|0.4");
				push(@variantletters,"sch|0.4");
				push(@variantletters,"sg|0.2");
				$i++;;
			}
			elsif ($twoletters eq "sh") {
				push(@variantletters,"sch|0.285714285714286");
				push(@variantletters,"sh|0.714285714285714");
				$i++;;
			}
			elsif ($twoletters eq "si") {
				push(@variantletters,"ci|0.037037037037037");
				push(@variantletters,"i|0.0740740740740741");
				push(@variantletters,"nti|0.037037037037037");
				push(@variantletters,"si|0.666666666666667");
				push(@variantletters,"ti|0.148148148148148");
				push(@variantletters,"tie|0.037037037037037");
				$i++;;
			}
			elsif ($twoletters eq "sj") {
				push(@variantletters,"sj|0.933333333333333");
				push(@variantletters,"stj|0.0666666666666667");
				$i++;;
			}
			elsif ($twoletters eq "sm") {
				push(@variantletters,"schm|1");
				$i++;;
			}
			elsif ($twoletters eq "sn") {
				push(@variantletters,"n|0.0476190476190476");
				push(@variantletters,"ns|0.0952380952380952");
				push(@variantletters,"s|0.0476190476190476");
				push(@variantletters,"sn|0.80952380952381");
				$i++;;
			}
			elsif ($twoletters eq "so") {
				push(@variantletters,"so|0.964285714285714");
				push(@variantletters,"sor|0.0357142857142857");
				$i++;;
			}
			elsif ($twoletters eq "sp") {
				push(@variantletters,"sp|0.976190476190476");
				push(@variantletters,"spe|0.0238095238095238");
				$i++;;
			}
			elsif ($twoletters eq "ss") {
				push(@variantletters,"iss|0.0232558139534884");
				push(@variantletters,"ss|0.930232558139535");
				push(@variantletters,"ssc|0.0465116279069767");
				push(@variantletters,"issc|0.5");
				push(@variantletters,"ssch|0.5");
				$i++;;
			}
			elsif ($twoletters eq "sw") {
				push(@variantletters,"sw|0.5");
				push(@variantletters,"zw|0.5");
				$i++;;
			}
			elsif ($twoletters eq "st") {
				push(@variantletters,"s't|0.0161943319838057");
				push(@variantletters,"st|0.963562753036437");
				push(@variantletters,"stu|1");
				$i++;;
			}
			elsif ($twoletters eq "ta") {
				push(@variantletters,"ta|0.972972972972973");
				push(@variantletters,"to|0.027027027027027");
				$i++;;
			}
			elsif ($twoletters eq "te") {
				push(@variantletters,"t|0.0247933884297521");
				push(@variantletters,"te|0.933884297520661");
				push(@variantletters,"'ti|1");
				$i++;;
			}
			elsif ($twoletters eq "tg") {
				push(@variantletters,"t|0.333333333333333");
				push(@variantletters,"tg|0.666666666666667");
				$i++;;
			}
			elsif ($twoletters eq "ti") {
				push(@variantletters,"'ti|1");
				$i++;;
			}
			elsif ($twoletters eq "tj") {
				push(@variantletters,"tj|0.985074626865672");
				push(@variantletters,"etje|0.333333333333333");
				push(@variantletters,"oetj|0.333333333333333");
				push(@variantletters,"tjes|0.333333333333333");
				$i++;;
			}
			elsif ($twoletters eq "tn") {
				push(@variantletters,"ten|0.666666666666667");
				push(@variantletters,"tn|0.333333333333333");
				$i++;;
			}
			elsif ($twoletters eq "to") {
				push(@variantletters,"o|0.0103092783505155");
				push(@variantletters,"to|0.989690721649485");
				$i++;;
			}
			elsif ($twoletters eq "tr") {
				push(@variantletters,"ter|0.181818181818182");
				push(@variantletters,"tr|0.757575757575758");
				push(@variantletters,"tro|0.0303030303030303");
				push(@variantletters,"tru|0.0303030303030303");
				$i++;;
			}
			elsif ($twoletters eq "ts") {
				push(@variantletters,"ds|0.0285714285714286");
				push(@variantletters,"ets|0.0285714285714286");
				push(@variantletters,"t|0.0571428571428571");
				push(@variantletters,"ts|0.885714285714286");
				$i++;;
			}
			elsif ($twoletters eq "tt") {
				push(@variantletters,"t|0.153846153846154");
				push(@variantletters,"tt|0.846153846153846");
				$i++;;
			}
			elsif ($twoletters eq "tu") {
				push(@variantletters,"stu|0.0192307692307692");
				push(@variantletters,"t|0.0384615384615385");
				push(@variantletters,"te|0.0192307692307692");
				push(@variantletters,"tu|0.865384615384615");
				push(@variantletters,"tuu|0.0384615384615385");
				push(@variantletters,"u|0.0192307692307692");
				$i++;;
			}
			elsif ($twoletters eq "ud") {
				push(@variantletters,"ed|0.2");
				push(@variantletters,"oud|0.2");
				push(@variantletters,"ud|0.6");
				push(@variantletters,"etd|1");
				$i++;;
			}
			elsif ($twoletters eq "ue") {
				push(@variantletters,"eu|0.2");
				push(@variantletters,"u|0.2");
				push(@variantletters,"ue|0.4");
				push(@variantletters,"uke|0.2");
				push(@variantletters,"euke|1");
				$i++;;
			}
			elsif ($twoletters eq "uf") {
				push(@variantletters,"uf|0.991228070175439");
				$i++;;
			}
			elsif ($twoletters eq "ui") {
				push(@variantletters,"ui|0.957446808510638");
				push(@variantletters,"uit|0.0425531914893617");
				$i++;;
			}
			elsif ($twoletters eq "uk") {
				push(@variantletters,"uk|0.968253968253968");
				push(@variantletters,"ukk|0.0317460317460317");
				push(@variantletters,"ukki|1");
				$i++;;
			}
			elsif ($twoletters eq "ul") {
				push(@variantletters,"ul|0.976190476190476");
				push(@variantletters,"ull|0.0238095238095238");
				$i++;;
			}
			elsif ($twoletters eq "um") {
				push(@variantletters,"um|0.8");
				push(@variantletters,"umm|0.2");
				$i++;;
			}
			elsif ($twoletters eq "un") {
				push(@variantletters,"een|0.0909090909090909");
				push(@variantletters,"un|0.909090909090909");
				$i++;;
			}
			elsif ($twoletters eq "uo") {
				push(@variantletters,"ou|0.5");
				push(@variantletters,"u|0.5");
				$i++;;
			}
			elsif ($twoletters eq "ur") {
				push(@variantletters,"er|0.0149253731343284");
				push(@variantletters,"ur|0.955223880597015");
				push(@variantletters,"uur|0.0298507462686567");
				$i++;;
			}
			elsif ($twoletters eq "us") {
				push(@variantletters,"iss|0.0158730158730159");
				push(@variantletters,"us|0.984126984126984");
				$i++;;
			}
			elsif ($twoletters eq "ut") {
				push(@variantletters,"et|0.205882352941176");
				push(@variantletters,"oet|0.0294117647058824");
				push(@variantletters,"t|0.0294117647058824");
				push(@variantletters,"ut|0.735294117647059");
				$i++;;
			}
			elsif ($twoletters eq "uu") {
				push(@variantletters,"eu|0.0645161290322581");
				push(@variantletters,"u|0.193548387096774");
				push(@variantletters,"uu|0.741935483870968");
				$i++;;
			}
			elsif ($twoletters eq "uw") {
				push(@variantletters,"u|0.194444444444444");
				push(@variantletters,"uw|0.75");
				push(@variantletters,"uwe|0.0277777777777778");
				push(@variantletters,"uwt|0.0277777777777778");
				$i++;;
			}
			elsif ($twoletters eq "va") {
				push(@variantletters,"va|0.955752212389381");
				push(@variantletters,"vra|0.0132743362831858");
				push(@variantletters,"eval|1");
				$i++;;
			}
			elsif ($twoletters eq "ve") {
				push(@variantletters,"ve|0.982758620689655");
				$i++;;
			}
			elsif ($twoletters eq "vi") {
				push(@variantletters,"vi|0.98");
				push(@variantletters,"vri|0.02");
				$i++;;
			}
			elsif ($twoletters eq "vj") {
				push(@variantletters,"vr|1");
				$i++;;
			}
			elsif ($twoletters eq "vl") {
				push(@variantletters,"v|0.5");
				push(@variantletters,"vl|0.5");
				$i++;;
			}
			elsif ($twoletters eq "vo") {
				push(@variantletters,"vo|0.979166666666667");
				push(@variantletters,"voo|0.0208333333333333");
				$i++;;
			}
			elsif ($twoletters eq "vr") {
				push(@variantletters,"ver|0.0188679245283019");
				push(@variantletters,"vr|0.981132075471698");
				$i++;;
			}
			elsif ($twoletters eq "vt") {
				push(@variantletters,"ft|0.5");
				push(@variantletters,"vt|0.5");
				$i++;;
			}
			elsif ($twoletters eq "wa") {
				push(@variantletters,"wa|0.899497487437186");
				push(@variantletters,"waa|0.0251256281407035");
				push(@variantletters,"wak|0.0150753768844221");
				push(@variantletters,"wan|0.0100502512562814");
				push(@variantletters,"wat|0.050251256281407");
				push(@variantletters,"wat|1");
				$i++;;
			}
			elsif ($twoletters eq "we") {
				push(@variantletters,"we|0.97029702970297");
				push(@variantletters,"wee|1");
				$i++;;
			}
			elsif ($twoletters eq "wi") {
				push(@variantletters,"i|0.0289855072463768");
				push(@variantletters,"wi|0.927536231884058");
				push(@variantletters,"wie|0.0144927536231884");
				push(@variantletters,"wo|0.0289855072463768");
				$i++;;
			}
			elsif ($twoletters eq "wj") {
				push(@variantletters,"uwj|0.2");
				push(@variantletters,"wij|0.2");
				push(@variantletters,"wj|0.6");
				$i++;;
			}
			elsif ($twoletters eq "wo") {
				push(@variantletters,"wo|0.925925925925926");
				push(@variantletters,"won|0.037037037037037");
				push(@variantletters,"woo|0.037037037037037");
				$i++;;
			}
			elsif ($twoletters eq "wt") {
				push(@variantletters,"tw|0.333333333333333");
				push(@variantletters,"w|0.333333333333333");
				push(@variantletters,"wt|0.333333333333333");
				$i++;;
			}
			elsif ($twoletters eq "ww") {
				push(@variantletters,"w|1");
				$i++;;
			}
			elsif ($twoletters eq "ya") {
				push(@variantletters,"ja|0.25");
				push(@variantletters,"ya|0.75");
				$i++;;
			}
			elsif ($twoletters eq "ye") {
				push(@variantletters,"je|0.866666666666667");
				push(@variantletters,"ye|0.133333333333333");
				$i++;;
			}
			elsif ($twoletters eq "yf") {
				push(@variantletters,"ijf|1");
				$i++;;
			}
			elsif ($twoletters eq "yi") {
				push(@variantletters,"ji|0.333333333333333");
				push(@variantletters,"yi|0.666666666666667");
				$i++;;
			}
			elsif ($twoletters eq "yk") {
				push(@variantletters,"ijk|1");
				$i++;;
			}
			elsif ($twoletters eq "yo") {
				push(@variantletters,"io|0.181818181818182");
				push(@variantletters,"jo|0.0909090909090909");
				push(@variantletters,"yo|0.727272727272727");
				$i++;;
			}
			elsif ($twoletters eq "ze") {
				push(@variantletters,"ase|0.012987012987013");
				push(@variantletters,"z|0.012987012987013");
				push(@variantletters,"ze|0.87012987012987");
				push(@variantletters,"zeg|0.0649350649350649");
				push(@variantletters,"zen|0.012987012987013");
				push(@variantletters,"zet|0.012987012987013");
				push(@variantletters,"zi|0.012987012987013");
				push(@variantletters,"zen|1");
				$i++;;
			}
			elsif ($twoletters eq "zi") {
				push(@variantletters,"zi|0.981981981981982");
				push(@variantletters,"anti|1");
				$i++;;
			}
			elsif ($twoletters eq "zj") {
				push(@variantletters,"zij|1");
				$i++;;
			}
			elsif ($twoletters eq "zo") {
				push(@variantletters,"z|0.075");
				push(@variantletters,"zo|0.925");
				$i++;;
			}
			elsif ($oneletters[$i] eq "a") {
				push(@variantletters,"a|0.958831341301461");
			}
			elsif ($oneletters[$i] eq "b") {
				push(@variantletters,"b|0.965092402464066");
				push(@variantletters,"be|0.0102669404517454");
			}
			elsif ($oneletters[$i] eq "c") {
				push(@variantletters,"c|0.962686567164179");
			}
			elsif ($oneletters[$i] eq "d") {
				push(@variantletters,"d|0.96085409252669");
				push(@variantletters,"t|0.0151245551601423");
				push(@variantletters,"tdo|1");
			}
			elsif ($oneletters[$i] eq "e") {
				push(@variantletters,"e|0.970531587057011");
				push(@variantletters,"mee|1");
			}
			elsif ($oneletters[$i] eq "f") {
				push(@variantletters,"f|0.97275204359673");
			}
			elsif ($oneletters[$i] eq "g") {
				push(@variantletters,"g|0.962705984388552");
			}
			elsif ($oneletters[$i] eq "h") {
				push(@variantletters,"h|0.982415005861665");
			}
			elsif ($oneletters[$i] eq "i") {
				push(@variantletters,"i|0.966287571080422");
				push(@variantletters,"neer|0.5");
				push(@variantletters,"ntie|0.5");
			}
			elsif ($oneletters[$i] eq "j") {
				push(@variantletters,"j|0.974358974358974");
				push(@variantletters,"i|0.025641026");
			}
			elsif ($oneletters[$i] eq "k") {
				push(@variantletters,"k|0.979381443298969");
			}
			elsif ($oneletters[$i] eq "l") {
				push(@variantletters,"l|0.960515713134569");
				push(@variantletters,"ll|0.0145044319097502");
			}
			elsif ($oneletters[$i] eq "m") {
				push(@variantletters,"m|0.984182776801406");
			}
			elsif ($oneletters[$i] eq "n") {
				push(@variantletters,"n|0.982778415614237");
			}
			elsif ($oneletters[$i] eq "o") {
				push(@variantletters,"|0.0105988341282459");
				push(@variantletters,"o|0.978802331743508");
			}
			elsif ($oneletters[$i] eq "p") {
				push(@variantletters,"b|0.0419753086419753");
				push(@variantletters,"p|0.94320987654321");
			}
			elsif ($oneletters[$i] eq "r") {
				push(@variantletters,"r|0.975862068965517");
				push(@variantletters,"eerr|0.5");
				push(@variantletters,"roet|0.5");
			}
			elsif ($oneletters[$i] eq "s") {
				push(@variantletters,"s|0.956397426733381");
				push(@variantletters,"schi|1");
			}
			elsif ($oneletters[$i] eq "t") {
				push(@variantletters,"d|0.0218978102189781");
				push(@variantletters,"t|0.951511991657977");
				push(@variantletters,"tten|1");
			}
			elsif ($oneletters[$i] eq "u") {
				push(@variantletters,"e|0.0252100840336134");
				push(@variantletters,"u|0.899159663865546");
				push(@variantletters,"uw|0.0252100840336134");
				push(@variantletters,"ende|0.666666666666667");
				push(@variantletters,"etm|0.333333333333333");
			}
			elsif ($oneletters[$i] eq "v") {
				push(@variantletters,"v|0.97708674304419");
			}
			elsif ($oneletters[$i] eq "w") {
				push(@variantletters,"|0.018796992481203");
				push(@variantletters,"w|0.954887218045113");
			}
			elsif ($oneletters[$i] eq "x") {
				push(@variantletters,"d|0.0161290322580645");
				push(@variantletters,"k|0.0161290322580645");
				push(@variantletters,"ks|0.0161290322580645");
				push(@variantletters,"x|0.967741935483871");
			}
			elsif ($oneletters[$i] eq "y") {
				push(@variantletters,"i|0.0466666666666667");
				push(@variantletters,"ij|0.0333333333333333");
				push(@variantletters,"j|0.12");
				push(@variantletters,"y|0.793333333333333");
			}
			elsif ($oneletters[$i] eq "z") {
				push(@variantletters,"z|0.965397923875433");
				push(@variantletters,"ze|0.0103806228373702");
			}
		        else{
				push(@variantletters,$oneletters[$i].$nopenalty);
		        }
	    push(@allvariantletters,[@variantletters]);
	    }
	    my $pattern = join "", map "{$_}", map join( ",", @$_ ), @allvariantletters; 
	    push(@wordvariants,glob $pattern);
	    my %wordvarianthash=();
	    foreach my $wordvariant (@wordvariants){
		    my @all_nums=$wordvariant=~/(\d+\.\d+)/g; 
		    $wordvariant =~ s/(\d+(\.\d+)*)//g;
		    $wordvariant =~ s/\|//g;
		    my $counter=1;
		    foreach $num(@all_nums){
			$counter=$counter*$num;
		    }
		    $wordvarianthash{$wordvariant}=$counter;
	    }
	    foreach my $key (keys %wordvarianthash) {
		$frequency=$main::lexicon{$key};
		if ((($main::SPELLCHECKLEX{$key}) ||
			($main::SPELLCHECKLEX{lc($key)}) ||
			($key=~/^[\.\?\!\,\:\;\'\d]+$/)) && ($frequency > $main::frequencyretainvariant)) {
				push(@retrievedwords,$key);
		}
	    }
	}
    }
    return @retrievedwords;
}
