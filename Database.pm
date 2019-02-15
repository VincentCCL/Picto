####### Database.pm ##########

# By Vincent Vandeghinste
# vincent@ccl.kuleuven.be
# Date: 07.10.2013

#---------------------------------------

$VERSION="1.0"; # Version used in the first release for WAI-NOT

#---------------------------------------


# Contains the methods for connecting to the Postgres database
print $log "Database.pm loaded\n" if $log;
1;
#---------------------------------------	
package DBI::db;
#---------------------------------------	

use DBI;

sub new {
    my ($pkg,$dbasename,$dbhost,$dbport,$dbuser,$dbpwd)=@_;
    unless ($dbasename=~/./ and $dbhost=~/./ and $dbport=~/./ and $dbpwd=~/./) {
      $log=$pkg->{logfile};
      print $log "Database settings not properly defined in GenericFunctions.pm\n" if $log;
      print STDERR "Database settings not properly defined in GenericFunctions.pm\n";
      die;
    }
    my $dbh;
    unless ($dbh=DBI->connect("DBI:Pg:dbname=$dbasename;host=$dbhost;port=$dbport","$dbuser","$dbpwd")) {
	die $DBI::errstr;
    }
    return $dbh;
}

sub close {
    my ($dbh)=@_;
    $dbh->disconnect;
}
 
sub execute {
    my ($dbh,$sql)=@_;
    my $statement=$dbh->prepare($sql);
    if ($statement->execute) {
        return 1;
    }
    else {
        return 0;
    }
}
 
sub lookup {
    my ($dbh,$sql)=@_;
    my $cache;
    if ($result=$DBCACHE{$sql}) {
    	return $result;
    }
    my $statement=$dbh->prepare($sql);
    if ($statement->execute) {
        my $result=$statement->fetchall_arrayref;
        $DBCACHE{$sql}=$result;
        return $result;
    }
    else {
        print STDERR "Error in $sql\n";
        return -1;
    }
}
 
