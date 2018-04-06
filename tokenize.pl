#!/usr/bin/perl

####### tokenize.pl ##########

# By Tom Vanallemeersch
# tallem@ccl.kuleuven.be

#---------------------------------------

my ($infile,$outfile)=@ARGV;

open(IN,"<:utf8",$infile);
open(OUT,">:utf8",$outfile);

while (<IN>) {
    chomp;
    print OUT &tokenize($_)."\n";
}
close(IN);
close(OUT);

sub tokenize {
    my ($sentence)=@_;
    $sentence=~s/([\.\?\!\(\)\[\]:;\,\"\'])/ $1 /g;
    $sentence=~s/  / /g;
    return $sentence;
}
