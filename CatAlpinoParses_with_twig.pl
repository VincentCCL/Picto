####### CatAlpinoParses_with_twig.pl ##########

# By Tom Vanallemeersch for the SCATE project
# tallem@ccl.kuleuven.be

#---------------------------------------

# Argument: <directory>
# <directory> contains files with a single Alpino XML parse
# Creates treebank in <directory>.xml

#---------------------------------------

use strict;
use XML::Twig;

my ($dir)=@ARGV;

my $outfile=$dir.'.xml';

my $twig=XML::Twig->new(pretty_print => 'indented',
			twig_handlers => { alpino_ds => \&add_parse});

open(OUT,">:utf8",$outfile) || die ("Can't open $outfile\n");
my $outtwig=XML::Twig->new(pretty_print => 'indented');
my $treebank=XML::Twig::Elt->new('treebank');
$outtwig->set_root($treebank);
$outtwig->set_encoding('UTF-8');
foreach my $file (sort <$dir/*.xml>) {
    $twig->parsefile($file);
}
$outtwig->flush(\*OUT);
close(OUT);
    
sub add_parse {
    my ($p,$parse)=@_;
    my $parsecopy=$parse->copy;
    $parsecopy->paste('last_child',$treebank);
    $parsecopy->flush(\*OUT);
    $parse->purge;
}
