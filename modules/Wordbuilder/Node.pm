#---------------------------------------------------
package Node;
#---------------------------------------------------

# this package contains the object constructors and accessors
# for the nodes in the tree

#----------------------------------------------------
# constructor of the Node class
#----------------------------------------------------
sub new {
    my $pkg=shift;
    my ($word,$tag,$rf,$headfreq,$modfreq,$prob,$diffmods,$parts)=@_;
    $r_node=bless {
	"word"      => $word,
	"tag"       => $tag,
	"rf"        => $rf,
	"modfreq"   => $modfreq,
	"headfreq"  => $headfreq,
	"prob"      => $prob,
	"diffmods"  => $diffmods,
	"parts"     => $parts
	},$pkg;
    return $r_node;
}

# loading of Node.pm needs to return 1
1;
	    
#---------------------------------------------------
# accessors for the Node class
#---------------------------------------------------
sub get_word {
    my $pkg=shift;
    $pkg->{word};
}

sub get_tag {
    my $pkg=shift;
    $pkg->{tag};
}

sub get_rf {
    my $pkg=shift;
    $pkg->{rf};
}

sub get_modfreq {
    my $pkg=shift;
    $pkg->{modfreq};
}

sub get_headfreq {
    my $pkg=shift;
    $pkg->{headfreq};
}

sub get_prob {
    my $pkg=shift;
    $pkg->{prob};
}

sub get_diffmods {
    my $pkg=shift;
    $pkg->{diffmods};
}

sub get_parts {
    my $pkg=shift;
    $pkg->{parts};
}

sub get_pos {
    my $pkg=shift;
    my $tag=$pkg->{tag};
    ($pos)=$tag=~/^(.{1,3})\(/;
    $pos;
}

sub get_features {
    my $pkg=shift;
    my $tag=$pkg->{tag};
    ($feat)=$tag=~/^.{1,3}\((.*)\)$/;
    $feat;
}

sub set_cgn {
    my $pkg=shift;
    my $cgn=shift;
    $pkg->{"cgn"}=$cgn;
    return $pkg;
}


sub get_cgn {
    my $pkg=shift;
   $pkg->{cgn};
}
