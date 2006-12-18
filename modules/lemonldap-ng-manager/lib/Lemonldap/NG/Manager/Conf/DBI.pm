package Lemonldap::NG::Manager::Conf::DBI;

use strict;
use DBI;
use Storable qw(freeze thaw);
use MIME::Base64;

our $VERSION = 0.1;

sub prereq {
    my $self = shift;
    unless($self->{dbiChain}) {
	print STDERR 'No dbiChain found';
	return 0;
    }
    print STDERR __PACKAGE__ . 'Warning: "dbiUser" parameter is not set' unless($self->{dbiUser});
    $self->{dbiTable} ||= "lmConfig";
    1;
}

sub available {
    my $self = shift;
    $self->_connect;
    my $sth = $self->{dbh}->prepare( "SELECT cfgNum from " . $self->{dbiTable} . " order by cfgNum" );
    $sth->execute();
    my @conf;
    while(my @row = $sth->fetchrow_array) {
	push @conf, $row[0];
    }
    return @conf;
}

sub lastCfg {
    my $self = shift;
    my @row  = $self->{dbh}->selectrow_array( "SELECT max(cfgNum) from " . $self->{dbiTable} );
    return $row[0];
}

sub _connect {
    my $self=shift;
    $self->{dbh}  = DBI->connect_cached(
        $self->{dbiChain}, $self->{dbiUser},
        $self->{dbiPassword}, { RaiseError => 1 }
    );
    $self->{dbiTable} ||= "lmconfig";
}

sub store {
    my($self,$fields) = @_;
    $self->_connect;
    my $tmp = $self->{dbh}->do( "insert into " . $self->{dbiTable} . " (" . join( ",", keys(%$fields) ) . ") values (" . join( ",", values(%$fields) ) . ")" );
    unless($tmp) {
	print STDERR "Database error: ".$self->{dbh}->errstr."\n";
	return 0;
    }
    return $fields->{cfgNum};
}

sub load {
    my($self,$cfgNum,$fields) = @_;
    $self->_connect;
    $fields = join(/,/, @$fields) || '*';
    my $row = $self->{dbh}->selectrow_hashref( "SELECT $fields from " . $self->{dbiTable} . " WHERE cfgNum=$cfgNum" );
    unless($row) {
	print STDERR "Database error: ".$self->{dbh}->errstr."\n";
    }
    return $row;
}

1;
__END__
