#----------------------------------
package Leaf_object;
#----------------------------------
1;

sub new {
    my $pkg=shift;
    $r_SL=bless {
	},$pkg;
    return $r_SL;
}

sub token {
    my ($pkg)=shift;
    my $token=shift;
    if (defined($token)) {
	$pkg->{token}=$token;
    }
    else {
	$pkg->{token};
    }
}

sub lemma {
    my ($pkg)=shift;
    my $lemma=shift;
    if (defined($lemma)) {
	$pkg->{lemma}=$lemma;
    }
    else {
	$pkg->{lemma};
    }
}

sub tag {
    my ($pkg)=shift;
    my $tag=shift;
    if (defined($tag)) {
	$pkg->{tag}=$tag;
    }
    else {
	$pkg->{tag};
    }
}

sub weight {
    my ($pkg)=shift;
    my $weight=shift;
    if (defined($weight)) {
	$pkg->{weight}=$weight;
    }
    else {
	$pkg->{weight};
    }
}

sub position {
    my ($pkg)=shift;
    my $position=shift;
    if (defined($position)) {
	$pkg->{position}=$position;
    }
    else {
	$pkg->{position};
    }
}

sub link {
    my ($pkg)=shift;
    my $link=shift;
    if (defined($link)) {
	$pkg->{link}=$link;
    }
    else {
	$pkg->{link};
    }
}
