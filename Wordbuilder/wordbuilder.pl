#####################################
# Wordbuilder.pl
#
# interactive interface of Wordbuilder.pm
#

use WordbuilderModule;
@input=&get_input;
@results=&wordbuilder(@input);
show_output(@results);

sub get_input {
    print "\n#############################################################";
    print "\nWORDBUILDER Interactive\n\n";
    print "\t\t\tdoor Vincent Vandeghinste\n\n";
    print "#############################################################";
    print "\nInput woorddelen (gescheiden door komma's)? ";
    my $input=<STDIN>;
    chop($input);
    my @input=split(/,/,$input);
    return @input;
}

sub show_output {
    my @node=@_;
    foreach $node (@node) {
    	my $word=$node->get_word();
	my $tag=$node->get_tag();
	my $prob=$node->get_prob();
	print "SAMENSTELLING:   $word\n";
	print "TAG:             $tag\n";
	print "BETROUWBAARHEID: $prob\n";
    }
    unless (@node) {
	print "GEEN SAMENSTELLING GEVONDEN.\n";
    }
}
