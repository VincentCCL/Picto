### Database.pm ###

# By Vincent Vandeghinste
# vincent@ccl.kuleuven.be
# Date: 07.10.2013

#---------------------------------------
$VERSION="1.0"; # Version used in the first release for WAI-NOT
#---------------------------------------

# Contains the methods for connecting to the Postgres database
1;

#---------------------------------------	
package DBI::db;
#---------------------------------------	

use DBI;

sub new {
    my ($pkg,$dbasename,$dbhost,$dbport,$dbuser,$dbpwd)=@_;
    my $dbh;
    unless ($dbh=DBI->connect("DBI:Pg:dbname=$dbasename;host=$dbhost;port=$dbport","$dbuser","$dbpwd")) {
	$log=$pkg->{logfile};
	print $log "Cannot open database $dbasename\n";
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
    my ($dbh,$sql,$log)=@_;
    my $cache;
   # if ($result=$DBCACHE{$sql}) {
    #	return $result;
    #}
    my $statement=$dbh->prepare($sql);
    if ($statement->execute) {
        my $result=$statement->fetchall_arrayref;
        $DBCACHE{$sql}=$result;
        return $result;
    }
    else {
        if ($log) {
            print $log "Error in $sql\n";
        }
        print STDERR "Error in $sql\n";
        return -1;
    }
}
 
