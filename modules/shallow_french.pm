####### shallow_french.pm ########

# By Magali Norré, Leen Sevens and Vincent Vandeghinste
# magali.norre@uclouvain.be, leen@ccl.kuleuven.be and vincent@ccl.kuleuven.be
# Date: 26.01.2021

#---------------------------------------
# functions taken over from object.pm to remove all language dependent info
#---------------------------------------

$VERSION="2.1"; # 17.03.2022 Added lookupMedicalParaphrase and findNamedEntities_medicine functions
#$VERSION="2.0"; # 04.03.2022 Changes in findCompound + added compressWords and generateTimePicto functions
#$VERSION="1.1"; # 01.09.2021 Added findCompound and findNamedEntities_cityPerso functions
#$VERSION="1.0"; # 02.12.2020 French version based on spanish.pm (VERSION="1.1")

1;

#---------------------------------------

use utf8; #!#
use Data::Dumper; #!#
binmode(STDIN,":encoding(UTF-8)"); #!#
binmode(STDOUT,":encoding(UTF-8)"); #!#

## LOCATIONS OF TAGGER: FINDS POS TAG AND LEMMA 
$taggerlocation="$Bin/TreeTagger/cmd"; # Path of the TreeTagger application http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/

#---------------------------------------

## SPELL CHECKING INPUT WORDS

# LFREQUENCY DATABASE: UNIVERSITY OF LEEDS http://corpus.leeds.ac.uk/frqc/internet-es-forms.num
#tie %SPELLCHECKLEX,"DB_File","$Bin/../data/SpanishTokenFreq.db";
#tie %lexicon,"DB_File","$Bin/../data/SpanishTokenFreq.db";

# Firstnames lexicon
#tie %FIRSTNAMES,"DB_File","$Bin/../data/LemmaDBNames.db"; # http://www.quietaffiliate.com/free-first-name-and-last-name-databases-csv-and-sql

$maxlengthwordinspellcheck=30;

#---------------------------------------
package message;
#---------------------------------------

sub taglemmatize {
    # If $nospellcheck contains 'nospellcheck' spellchecking is skipped
    # If $nospellcheck contains 'sclera' the sclera dictionary is also checked before spellchecking
    my ($pkg,$nospellcheck)=@_;
	my $log=$pkg->{logfile}; #!#
	print $log "\n\nShallow Linguistic Analysis\n-------------------------------\n" if $log; #!#
    $pkg->addFullStop;
    #$pkg->lookupMedicalParaphrase; #!# v2.1
    $pkg->findCompound; #!# v1 / v2
    $pkg->compressWords; #!# v2
    $pkg->findNamedEntities_medicine; #!# v2.1
    $pkg->tokenize;
    #unless ($nospellcheck eq 'nospellcheck') {
    #$pkg->spellCheck($nospellcheck);
    #}
    $pkg->tag;
    $pkg->findNamedEntities_cityPerso; #!# v1
    $pkg->generateTimePicto; #!# v2
    $pkg->detectSentences;
}

sub findCompound { #!#
    my ($pkg)=@_;
    my $words=$pkg->{text};
    #my $words=lc($words);

    #!# Hard-coded array (can be extended with more terms)
    #words (compounds) without synset of v1 table
    my @composes=("le nôtre", "coca cola", "cochon d'inde", "cochons d'inde", "bande dessinée", "bandes dessinées", "bouteille d'eau", "bouteilles d'eau", "à côté", "au-dessous de", "en dessous", "à l'intérieur", "en haut", "au dessus", "à l'extérieur", "pour toujours", "tout le monde", "comment ça va", "comment vas-tu", "comment allez-vous", "choux de bruxelles"); # beta/sclera
    if ($pkg->{target} eq 'beta'){
        push(@composes, "quelque chose", "petit ami", "petite amie", "en dehors", "numéro de téléphone", "numéro de tel", "sac à main", "en colère", "carte de voeux", "carte de vœux", "un autre", "en avant", "vers l'avant", "marchand ambulant", "carte de crédit", "carte de paiement", "pompe à essence", "ça va", "comment ça va","faire le plein", "père noël", "n'importe qui");
    }
    elsif ($pkg->{target} eq 'sclera'){
        push(@composes, "carte et boussole", "regarder à gauche", "peu de", "mordre la lèvre", "lèvre mordue", "téléphone portable", "sapin de noël", "faire la fête", "composer un numéro de téléphone", "sac à main", "feu de camp", "acteur de théâtre", "centre de jour", "pas bien", "pas bon", "arche de noé", "la mecque", "étoile de david", "fête de la reine", "bouquet de fleurs", "fête des mères", "fête des pères", "une heure", "deux heures", "trois heures", "quatre heures", "cinq heures", "six heures", "sept heures", "huit heures", "neuf heures", "dix heures", "onze heures", "nourrir la gerbille", "nourrir le degu", "nourriture pour poules", "nourriture pour oies", "jeu de ballon", "jouer au loup", "fête de l'école", "faire pipi", "épingle à cheveux", "épi de blé", "baguette magique", "baguette magique", "laser game", "poche de stomie", "aller en voiture", "lunette de soleil", "jeu de dames");
    }
    elsif ($pkg->{target} eq 'arasaac'){
        @composes=("haricots verts", "terrain de football", "langue de belle-mère", "château de sable", "sceau de peinture", "jour du pilier", "festivités du pilier", "se noyer", "cabochard berrugon", "cabocharde forana", "cabochard forano", "cabochard morico", "cabochard pilara", "cabochard robaculeros", "grosses têtes", "macédoine de légumes", "fer à cheveux", "au revoir", "à tout à l'heure", "stade de football", "se baisser", "maman ours", "je ne veux pas", "ne pas vouloir", "petit ours", "papa ours", "boucles d'or", "livres de jeux, sport et loisir", "caddie de supermarché", "aux alentours de", "travaux manuels", "arts plastiques", "cette histoire es finie", "cette histoire est finie", "pays basque", "la rioja", "communauté de madrid", "mies de pain", "piscine à boules", "programme de bricolage", "pays valencien", "il était un fois", "haricot vert", "nez de clown", "couleur café", "cube de rubik", "carte graphique", "je n'ai pas la parole", "qu'est-ce que c'est ?", "qui c'est?", "qui est-elle?", "bien que", "jeu du mouchoir", "parce que", "visite scolaire", "communauté éducative", "comment ça va ?", "ça va?", "bon appétit!", "service d'occupation", "service d'insertion professionnelle", "le mien", "à moi", "les miens", "la nôtre", "oncle de noël", "tronc de noël", "qui sont-ils?", "ciudad real", "accommodement raisonnable", "dulcinée du toboso", "sancho panza", "centre de récupération", "unité d'emploi, d'égalité, de coopération et de communication", "livret de famille", "poche à douille", "jour et nuit", "dire au revoir", "le chat botté", "hansel et gretel", "jeux paralympiques", "grande canarie", "roue de psychomotricité", "porte de palmas", "chaussure en caoutchouc", "se baigner", "une heure pile", "une heure", "maison de la culture", "en sueur", "où est-il ?", "moniteur de prévention", "salle des professeurs", "carte conceptuelle", "coup de coude", "lutte canarienne", "combat de bâton", "bataille de bâton", "landais et chrétien", "pelote valencienne", "excès de vitesse", "pyramide d'éveil", "jeu d'encastrement", "jeu des statues", "il y a");
        my @arrayoftemporalexpressions=("à quelle heure");
        push(@composes, @arrayoftemporalexpressions);
    }
    my %composes_dic = ();
    foreach my $compose (@composes) { 
        my $compose_underscore = $compose; 
        $compose_underscore=~s/\s+/_/g;
        $composes_dic{$compose}=$compose_underscore; 
    }
    my $regex='(?<!\p{Letter})('.join('|',@composes).')(?!\p{Letter})'; 
    $words=~s/$regex/$composes_dic{$1}/ge;

    $words=~s/^E(tes|tre)\b/Ê$1/;
    #$words=~s/(êtes|étiez)-vous/vous/gi;
    $words=~s/(est)?-ce( que)?//gi;

    $words=~s/(l|j|qu)\'/$1e /gi; # elision / m' -> me t' -> tu s' -> se/si (not in Vaschalde 2018)
    
    if ($words =~ /^(?!.*(d'ailleurs|d'accord|aujourd'hui|d'abord|d'ordinaire)).*/) {
        $words=~s/d\'//gi; # v1 /d\'/de /
    }

    $words=~s/s\'il( |-)(te|vous)( |-)pla(î|i)t/svp/gi; #!# v2
    $words=~s/c\'//gi;
    #$words=~s/ça/cela /gi;
    $words=~s/y a( |-)t( |-)il//gi; # v1: /y a-t-il/il_y_a/
    #$words=~s/-(je|tu|nous|vous|ils|elles|le|la|les)/ $1/gi; # question with pronoun
    #$words=~s/-?t?-(il|elle|on)/ $1/gi;
    $words=~s/vous a( |-)t( |-)on/personne vous/gi;
    $words=~s/(-t-)(il|elle|on|ils|elles)//gi;

    if ($words =~ /\b(ne |n\')(.+)\b(pas|plus|ni|point|rien|guère)\b/i) { # negation
        $words=~s/\b(ne |n\')//gi;
        $words=~s/\b(plus rien|guère plus|plus|ni|point|rien|guère)\b/pas/gi;
    }

    $pkg->{text}=$words;
}

sub compressWords { #!#
    my ($pkg)=@_;
    my $words=$pkg->{text};

    $words=~s/pouvez-vous me (montrer) avec le doigt/$1/gi;
    $words=~s/\b(avez|pouvez)-(vous)\b/$2/gi; # auxiliaries
    #$words=~s/(êtes|étiez)-vous/vous $1/gi;
    $words=~s/\b(a|ont|eu|eue|été|avoir)\b//gi; # past tenses
    $words=~s/(.+)-(tu|vous)/$2 $1/gi; # inversion (questions)
    $words=~s/\b(m|s|t)e\b //gi; # reflexive verbs
    $words=~s/((n|v)ous) (n|v)ous /$1 /gi; # reflexive verbs
    $words=~s/je vais vous demander de (vous )?/vous /gi; # imperative structure
    $words=~s/il ne faut pas/vous devez pas /gi;
    $words=~s/il faut (vous)?/vous devez /gi;
    $words=~s/je vais (m'|vous)/je vais /gi; # future

    my @arrayofwordstodelete;
    my @arrayofconjunctionsprepositions=("à", "au", "dans", "de", "du", "en", "ou");
    my @arrayofarticlespronuns=("auquel", "auxquels", "auxquelles", "ça", "ce", "ces", "cela", "celui-ci", "celui-là", "celle-ci", "celle-là", "ceux-ci", "ceux-là", "celles-ci", "celles-là", "cet", "cette", "des", "le", "la", "les", "mon", "ma", "mes", "me", "notre", "nôtre", "nôtres", "nos", "que", "quel", "quelle", "quels", "quelles", "qui", "son", "sa", "ses", "ton", "ta", "tes", "un", "une", "votre", "vôtre", "vôtres", "vos");
    my @arrayofcontentwords=("confirmée", "trouble", "troubles", "maximale", "cas", "pour ce cas", "quelque chose");
    push(@arrayofwordstodelete, @arrayofconjunctionsprepositions);
    push(@arrayofwordstodelete, @arrayofarticlespronuns);
    push(@arrayofwordstodelete, @arrayofcontentwords);
    my $regex='(?<!\p{Letter})('.join('|',@arrayofwordstodelete).')(?!\p{Letter})';
    $words=~s/\b$regex\b//gi;

    $pkg->{text}=$words;
}

sub findNamedEntities_medicine { #!#
    my ($pkg)=@_;
    my $words=$pkg->{text};
    my @arrayofmedicines=("aspirine", "Paracétamol", "Dafalgan", "Codafalgan", "Temesta", "Irfen", "Pénicilline", "Augmentin", "Zinat", "Ciproxine", "Zythromax", "Flagyl", "Vancocin", "Furadantine", "Monuril", "Zofran", "Primpéran", "Motilium", "Prepulsid", "Ponstan", "Voltaren", "Celebrex", "Toradol", "Bioflorin", "Pérentérol", "Movicol", "Prontolax", "Sirop figue", "Zadiar", "Tramal", "Ibuprofène", "Efient", "Plavix", "Brilique", "Clexane", "Arixtra", "Sintrom", "Marcoumar", "Xarelto", "Eliquis", "Pradaxa", "Beloc", "Indéral", "Aténolol", "Rénitec", "Aldactone", "Inspra", "Atacand", "Adalat", "Triptans", "Naramig", "Menamig", "Imigran", "Relpax", "Maxalt", "Zomig", "Almogran", "Saroten", "Notrilen", "Remeron", "Efexor", "Aspegic", "Inderal", "Béta-Adalat", "Isoptine", "Topamax", "Dépakine", "Orfiril", "Tégrétol");
    my $regex='(?<!\p{Letter})('.join('|',@arrayofmedicines).')(?!\p{Letter})';
    $words=~s/\b$regex\b/médicaments/gi;
    $pkg->{text}=$words;
}

sub tag {
    my ($pkg)=@_;
    my $stamp=time.$main::sessionid;
#     my $log=$pkg->{logfile};
#     print $log "\nPart of Speech Tagging\n" if $log;
    open (TMP,">:utf8","$main::tempfilelocation/$stamp");
    my $words=$pkg->{words};
    foreach (@$words) {
        $token=$_->{token};
        print TMP "$token\n";
    }
    close TMP;
    `$main::taggerlocation/tree-tagger-french < $main::tempfilelocation/$stamp > $main::tempfilelocation/$stamp.tmp`; #!#
#     print $log "$systemcommand\n" if $log;
    #`$systemcommand`;
    unlink "$main::tempfilelocation/$stamp" or print $log "\nCannot delete $main::tempfilelocation/$stamp.tmp\n" if $log;
    open (TMP,"<:utf8","$main::tempfilelocation/$stamp.tmp"); #!#
    my @words;
    while (<TMP>) {
    	chomp;
	    ($tok,$tag,$lem)=split(/\t/,$_);
	    if (defined($tok)) {
        @lem=split(/\|/,$lem); #!#
# 	    print $log "\t$tok\t$tag\n" if $log;
	        $word=word->new(logfile,$pkg->{logfile},
			    target,$pkg->{target},
			    token,$tok,
			    tag,$tag,
			    lemma,$lem[0], #!#
			    wordnetdb,$pkg->{wordnetdb});
	    push(@words,$word);
	   }
    }
    unlink "$main::tempfilelocation/$stamp.tmp" or print $log "\nCannot delete $main::tempfilelocation/$stamp.tmp\n" if $log;
    $pkg->{words}=[@words];
#     print $log "--------------\n" if $log;
}

sub findNamedEntities_cityPerso { #!#
	my ($pkg)=@_;
	my $word=$pkg->{words};
	my @verblocation=("aller","venir","partir","déménager","emménager", "habiter", "vivre", "voyager", "promener", "se déplacer", "se rendre", "revenir", "naître");
	my $j;
	while ($j <= $#$word) {
		if (@$word[$j]->{tag}=~/NAM/) {
			my $initial = substr @$word[$j]->{token}, 0, 1;
				if (@$word[$j-1]->{token} eq 'à' || @$word[$j-1]->{token} eq 'de') {
					if (grep {/@$word[$j-2]->{lemma}/} @verblocation) {
						@$word[$j]->{token}=~s/@$word[$j]->{token}/ville\_$initial/g; # replace the word by a picto (e.g. ville_A in arasaac) to integrate into dictionary
					}
				}
				else {
					@$word[$j]->{token}=~s/@$word[$j]->{token}/perso\_$initial/g;
				}
		}
		$j++;
	}
	$pkg->{words}=$word;
}

sub generateTimePicto { #!# bug: why 2 calls to TreeTagger?
	my ($pkg)=@_;
    my $words=$pkg->{text};
	my $word=$pkg->{words};
    my @verbpast=("avoir"); #!# todo (replace 'eu/avez/êtes' + (...) + VER:infi), simple delete or replace by a specific picto (e.g. 'passé' 9839)
    if ($words =~ /\b(déjà)\b/i) {
        $words=~s/\bdéjà\b //gi;
        $words="past_picto ".$words;
        $timepicto=word->new(wordnetdb,$pkg->{wordnetdb},
            logfile,$pkg->{logfile},
            token,"past_picto",
            lemma,"past_picto",
            tag,"NOM",
            target,$main::targetlanguage);
        splice @$word, 0, 0, $timepicto; # todo: delete 'déjà' picto object?
    }
	my @verbfuture=("aller");
	my $j;
	while ($j <= $#$word) {
		if (@$word[$j]->{tag}=~/VER:infi/ && grep {/@$word[$j-1]->{lemma}/} @verbfuture) { #!# bug: just an 'infi' verb -> future
    			@$word[$j-1]->{token}=~s/@$word[$j-1]->{token}//g;
                @$word[$j-1]->{lemma}=~s/@$word[$j-1]->{lemma}//g;
                $words="future_picto ".$words;
                $timepicto=word->new(wordnetdb,$pkg->{wordnetdb},
                    logfile,$pkg->{logfile},
	                token,"future_picto",
	                lemma,"future_picto",
            		tag,"NOM",
                    target,$main::targetlanguage);
                splice @$word, 0, 0, $timepicto;
			}
		$j++;
	}
    $words=~s/\s+/ /gi;
    $pkg->{text}=$words;
	$pkg->{words}=$word;
}

#!# Medical terms
# See also: Koptient A., Grabar N. (2020). Large Rated Lexicon for the Simplification of Medical Texts, HEALTHINFO 2020, 18-22 October 2020, Porto, Portugal.
sub lookupMedicalParaphrase {
    my ($pkg)=@_;
    my $words=$pkg->{text};
    $words=~s/\./ ./gi; #$words=~s/\.//gi;
    #my ($pkg,$toklemtag)=@_; # if after treetagger
    my $db;
    unless ($db=$pkg->{wordnetdb}) {
            $pkg->openWordnet;
            $db=$pkg->{wordnetdb};
    }
    #my ($tok,$lem,$tag)=@$toklemtag;
    my ($sql);
    $sql="select column_name from information_schema.columns where table_name='paraphrase_dictionary' and column_name='term';";
    my $urlresult=$pkg->{wordnetdb}->lookup($sql);
    my $retrieve_columns;
    if (defined($urlresult->[0]->[0])) {
        $retrieve_columns="paraphrase"; #if ($pkg->{target} eq 'arasaac'); #!#
    }
#=pod
    my @words = split( /\s+/, $words ); #unigrams
#=pod
    my $length = @words;
    my @bi = (); # bigrams
    for ( my $i = 0 ; $i < $length - 1 ; $i++) {
        push(@bi, $words[$i] . ' ' . $words[$i+1]);
    }
    my @tri = (); # trigrams
    for ( my $i = 0 ; $i < $length - 2 ; $i++) {
        push(@tri, $words[$i] . ' ' . $words[$i+1] . ' ' . $words[$i+2]);
    }
    @words = (@words, @bi, @tri);
#=cut
    my @wheres = ();
    foreach my $w (@words) { 
        $w = $pkg->{wordnetdb}->quote($w); 
        push @wheres, "term=" . $w; 
    }
    my $where = join( ' or ', @wheres );
    $sql = "select $retrieve_columns from paraphrase_dictionary where $where;"; # only unigrams, (bigrams and trigrams)
#=cut
    #$sql="select $retrieve_columns from paraphrase_dictionary where term='$words';"; # all words in input
    my $results=$pkg->{wordnetdb}->lookup($sql);
    print $words, "\n";
    print $results->[0]->[0], "\n";
    $words=~s/$words/$results->[0]->[0]/gi; # replace medical term with its paraphrase
    $pkg->{text}=$words;
    print $pkg->{text};
}

#---------------------------------------
package sentence;
#---------------------------------------

sub adaptPolarity { 
    # If a negative word is found we look for the head of this word and 
    # Put it in the feature polarity
    # And remove the negative word from the word list
    my ($pkg,$negwordindex)=@_;
    my $log=$pkg->{logfile};
    my $words=$pkg->{words};
    my ($head,$windowsize,$hypothesis);
    my $negword=$words->[$negwordindex];
    if (($negword->{tag} eq 'ADV') && #!# 'NEG'
	($negword->{lemma} eq 'pas')) { # || ($negword->{lemma} eq 'plus') #!# 'no'
	# LOOKING FOR THE HEAD OF 'NOT'
	my $maxwindowsize=3; ## PARAMETER
	until ($head) {
	    $windowsize++;
	    if ($windowsize>$maxwindowsize) {
		last;
	    }
	    $hypothesis=$words->[$negwordindex+$windowsize];
	    if ($hypothesis->{tag}=~/VER:cond|VER:futu|VER:impe|VER:impf|VER:infi|VER:pper|VER:ppre|VER:pres|VER:simp|VER:subi|VER:subp|ADJ|PRO:DEM|ADV|NUM/) { #!# Spanish: VCLIger|VCLIinf|VCLIfin|VEadj|VEfin|VEger|VEinf|VHadj|VHfin|VHger|VHinf|VLadj|VLfin|VLger|VLinf|VMadj|VMfin|VMger|VMinf|VSadj|VSfin|VSger|VSinf|ADJ|DM|ADV|CARD
		$head=$hypothesis
	    }
	    else {
		$hypothesis=$words->[$negwordindex-$windowsize];
		if ($hypothesis->{tag}=~/VER:cond|VER:futu|VER:impe|VER:impf|VER:infi|VER:pper|VER:ppre|VER:pres|VER:simp|VER:subi|VER:subp|ADJ|PRO:DEM|ADV|NUM/) { #!# Spanish: VCLIger|VCLIinf|VCLIfin|VEadj|VEfin|VEger|VEinf|VHadj|VHfin|VHger|VHinf|VLadj|VLfin|VLger|VLinf|VMadj|VMfin|VMger|VMinf|VSadj|VSfin|VSger|VSinf|ADJ|DM|ADV|CARD
		    $head=$hypothesis
		}
	    }
	}
    }
    if ($head) {
	# Remove negative word
	splice(@$words,$negwordindex,1);
	# Adapt polarity of word
	my $headtoken=$head->{token};
	print $log "Negative word 'not' detected and removed\n";
	print $log "Polarity of '$headtoken' adapted\n";
	$head->{polarity}=$negword;
	return 1;
    }
    return undef;
}

#---------------------------------------
package word;
#---------------------------------------
use DB_File; # From CPAN

sub isNegative {
    my ($pkg)=@_;
    if (($pkg->{lemma} eq 'pas') && # || ($negword->{lemma} eq 'plus')) && #!# 'no'
	($pkg->{tag} eq 'ADV')) { #!# 'NEG'
	return 1;
    } 
    else {
	return undef;
    }
}

sub getNegativeWord {
    my ($pkg)=@_;
    my $negword=word->new(logfile,$pkg->{logfile},
			  lemma,'pas', #!# 'no'
			  tag,'ADV', #!# 'NEG'
			  token,'pas'); #!# 'no'
    return $negword;
}

sub spellCheck {
    # If Sclera is defined, this indicates that the word should
    # Also be looked up in the Sclera lexicon -> if it occurs, no spellcheck!	
    my ($pkg)=@_;
    my $picto=$pkg->{target};
    my $word=$pkg->{token};
    my $lcword=lc($word);
    my $log=$pkg->{logfile};
    
    if (length($word)<$main::maxlengthwordinspellcheck) {
	#unless (($main::SPELLCHECKLEX{$word}) ||
	#	($main::SPELLCHECKLEX{lc($word)}) ||
	 unless(($word=~/^[\.\?\!\,\:\;\'\d]+$/) ||
                ($word=$pkg->existsindictionary) ||
	        ($lcword=$pkg->existsindictionary) ||
         	($main::FIRSTNAMES{$word}) ||
		($main::FIRSTNAMES{ucfirst($word)})) {
	    unless (($picto) &&
		    ($pkg->lookupPictoDictionary ||
		    ($pkg->addLexUnits))) {
		$alternatives=$pkg->findSpellingAlternatives;
		if ($bestcorrection=findMostFrequent($alternatives)) {
		    $pkg->{token}=$bestcorrection;
		}
	    }
	}
    }	
}

sub existsindictionary {
    my ($pkg)=@_;
    my $sql="select number from spellcheck where word='$pkg->{token}';";
    my $db=DBI::db->new($cornetto::database,
			    $cornetto::host,
			    $cornetto::port,
			    $cornetto::user,
			    $cornetto::pwd);
    $pkg->{wordnetdb}=$db;
    my $results=$pkg->{wordnetdb}->lookup($sql);
    if (my $number=$results->[0]->[0]) {
	return 1;
    }
    else{
	return undef;
    }
}

sub findMostFrequent {
    my ($alternatives)=@_;
    my $maxfreq=0;
    my $best;
    foreach (@$alternatives) {
	my $sql="select frequency from spellcheck where word='$_';";
        my $db=DBI::db->new($cornetto::database,
			    $cornetto::host,
			    $cornetto::port,
			    $cornetto::user,
			    $cornetto::pwd);
        $pkg->{wordnetdb}=$db;
	my $results=$pkg->{wordnetdb}->lookup($sql);
        if ($results->[0]->[0] > $maxfreq) {
	 #if ($main::lexicon{$_} > $maxfreq) {
	  #  $best=$_;
	  #  $maxfreq=$main::lexicon{$_};
	     $best=$_ ;
	     $maxfreq=$results->[0]->[0];
	}
    }
    return $best;
}
sub findOneDeletion {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my $target=$pkg->{target};
    my @orig=split(//,$token);
    my (@onedeletions);
    my @letters=@orig;
    my ($word,$ucfirst);
    for (my $i=0;$i<@letters;$i++) {
	splice(@letters,$i,1);
	$word=join("",@letters);
	if (($main::SPELLCHECKLEX{$word}) ||
	    ($main::FIRSTNAMES{$word})) {
	    push(@onedeletions,$word);
	}
	elsif (($ucfirst=ucfirst($word)) &&
	       ($main::FIRSTNAMES{$ucfirst})) {
	    push(@onedeletions,$ucfirst);
	}
	else {
	    $hypothesis=word->new('token',$word,
				  wordnetdb,$pkg->{wordnetdb},
				  target,$target,
				  logfile,$pkg->{logfile});
	    if ($hypothesis->addLexUnits) {
		push(@onedeletions,$word);
	    }
	}
	@letters=@orig;
    }
    return [@onedeletions];
}

sub findOneInsertion {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my $target=$pkg->{target};
    my @orig=split(//,$token);
    my @inserts=qw(a b c d e f g h i j k l m n o p q r s t u v w x y z â ê î ä ë ï ö ü à è ò ù é œ ç); #!# â ê î œ added
#   push(@inserts,map uc,@inserts);
    my (@oneinsertions);
    my @letters=@orig;
    my ($newtoken,$ucfirst);
    for (my $i=0;$i<@letters;$i++) {
	foreach (@inserts) {
	    unless ($_ eq $letters[$i]) {
		splice(@letters,$i,0,$_);
		$newtoken=join("",@letters);
		if (($main::SPELLCHECKLEX{$newtoken}) ||
		    ($main::FIRSTNAMES{$word})) {
		    push(@oneinsertions,$newtoken);
		}
		elsif (($ucfirst=ucfirst($newtoken)) &&
		       ($main::FIRSTNAMES{$ucfirst})) {
		    push(@oneinsertions,$ucfirst);
		}
		else {
		    $hypothesis=word->new('token',$newtoken,
					  wordnetdb,$pkg->{wordnetdb},
					  target,$target,
					  logfile,$pkg->{logfile});
		    if ($hypothesis->addLexUnits) {
			push(@oneinsertions,$newtoken);
		    }
		}
	    }
	    @letters=@orig;
	}
    }
    return [@oneinsertions];
}

sub findOneSubstitution {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my @origs=split(//,$token);
    my @inserts=qw(a b c d e f g h i j k l m n o p q r s t u v w x y z â ê î ä ë ï ö ü à è ò ù é í á ó ú ñ œ ç); #!# â ê î œ added
 #  push(@inserts,map uc,@inserts);
    my (@oneinsertions);
    @letters=@origs;
    my ($newtoken,$ucfirst);
    for (my $i=0;$i<@letters;$i++) {
	foreach (@inserts) {
	    unless ($_ eq $letters[$i]) {
		splice(@letters,$i,1,$_);
		$newtoken=join("",@letters);
		if (($main::SPELLCHECKLEX{$newtoken})||
		    ($main::FIRSTNAMES{$newtoken})) {
		    push(@oneinsertions,$newtoken);
		}
		elsif (($ucfirst=ucfirst($newtoken)) &&
		       ($main::FIRSTNAMES{$ucfirst})) {
		    push(@oneinsertions,$ucfirst);
		}
		else {
		    $hypothesis=word->new('token',$newtoken,
					  wordnetdb,$pkg->{wordnetdb},
					  target,$target,
					  logfile,$pkg->{logfile});
		    if ($hypothesis->addLexUnits) {
			push(@oneinsertions,$newtoken);
		    }
		}
	    }
	    @letters=@origs;
	}				
    }
    return [@oneinsertions];
}

sub endOfSentence {
    my ($pkg)=@_;
    if (($pkg->{tag}) &&
	($pkg->{tag} eq 'SENT') && #!# 'LET()' for punctuation
	($pkg->{token}=~/[\.]/)) { #!# [\.!\?]
	return 1;
    }	
    elsif ($pkg->{token}=~/[\.]/) { #!# [\.!\?]
	return 1;
    }
    else {
	return undef;
    }
}

sub lemmatize {
    my ($pkg)=@_;
    my $tok=$pkg->{token};
    my $tok=lc($tok);
    my $tag=$pkg->{tag};
    if (my $lemma=$main::LEMMAS{"$tok\t$tag"}) {
	$pkg->{lemma}=$lemma;
    }
    else {
	$pkg->lemmatize_rules;
    }
    if ($pkg->{lemma} eq '_') {
	$pkg->{lemma}=$tok;
    }
}

sub lemmatize_rules {
    my ($pkg)=@_;
    my $token=$pkg->{token};
    my $tag=$pkg->{tag};
    my $lemma;
    $pkg->{lemma}=$lemma;
}
