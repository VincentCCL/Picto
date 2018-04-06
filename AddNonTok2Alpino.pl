####### AddNonTok2Alpino.pl ##########

# By Tom Vanallemeersch for the SCATE project
# tallem@ccl.kuleuven.be

#---------------------------------------

# Add non-tokenized sentence as comment to parses in treebank
# Example: <treebank> <non-tokenized sentences> <output file>

#---------------------------------------

$version='0.1'; # 2.08.2015

#---------------------------------------

use strict;
use XML::Twig;

my ($treefile,$nontoksents,$outfile)=@ARGV;

my @sents;
my $sentcount;
&read_sents($nontoksents);

open(OUT,">:utf8",$outfile) || die ("Can't open $outfile\n");

my $twig=XML::Twig->new(pretty_print => 'indented',
                        twig_handlers => { alpino_ds => \&add_nontok});

$sentcount=0;
$twig->parsefile($treefile);
$twig->flush(\*OUT);
close(OUT);

sub read_sents{
    my ($file)=@_;
    open(IN,"<:utf8",$file) || die ("Can't open $file\n");
    while (<IN>){
	chomp;
	$sents[$sentcount++]=$_;
    }
    close(IN);
}

sub add_nontok{
    my ($p,$parse)=@_;
    my @children=$parse->children('comments');
    my $comments;
    if (@children) {
	$comments=$children[0];
    } else {
	$comments=XML::Twig::Elt->new('comments');
	$comments->paste('last_child',$parse);
    }
    my $comment=XML::Twig::Elt->new('comment');
    $comment->set_text("non-tokenized: ".$sents[$sentcount++]);
    $comment->paste('last_child',$comments);
    $parse->flush(\*OUT);
}
