package Lemonldap::NG::Manager::Conf::DBI;

use strict;
use DBI;
use Storable qw(freeze thaw);
use MIME::Base64;
use Lemonldap::NG::Manager::Conf::Constants;

our $VERSION = 0.13;

sub prereq {
    my $self = shift;
    unless ( $self->{dbiChain} ) {
        print STDERR 'No dbiChain found';
        return 0;
    }
    print STDERR __PACKAGE__ . 'Warning: "dbiUser" parameter is not set'
      unless ( $self->{dbiUser} );
    $self->{dbiTable} ||= "lmConfig";
    1;
}

sub available {
    my $self = shift;
    my $sth =
      $self->dbh->prepare(
        "SELECT cfgNum from " . $self->{dbiTable} . " order by cfgNum" );
    $sth->execute();
    my @conf;
    while ( my @row = $sth->fetchrow_array ) {
        push @conf, $row[0];
    }
    return @conf;
}

sub lastCfg {
    my $self = shift;
    my @row =
      $self->dbh->selectrow_array( "SELECT max(cfgNum) from " . $self->{dbiTable} );
    return $row[0];
}

sub dbh {
    my $self = shift;
    $self->{dbiTable} ||= "lmconfig";
    return $self->{dbh} ||= DBI->connect_cached(
        $self->{dbiChain}, $self->{dbiUser},
        $self->{dbiPassword}, { RaiseError => 1 }
    );
}

sub lock {
    my $self = shift;
    my $sth = $self->dbh->prepare_cached(q{SELECT GET_LOCK(?, 5)}, {}, 1);
    $sth->execute('lmconf');
    my @row = $sth->fetchrow_array;
    return $row[0] || 0;
}

sub isLocked {
    my $self = shift;
    my $sth = $self->dbh->prepare_cached(q{SELECT IS_FREE_LOCK(?)}, {}, 1);
    $sth->execute('lmconf');
    my @row = $sth->fetchrow_array;
    return $row[0] ? 0 : 1;
}

sub unlock {
    my $self = shift;
    my $sth = $self->dbh->prepare_cached(q{SELECT RELEASE_LOCK(?)}, {}, 1);
    $sth->execute('lmconf');
    my @row = $sth->fetchrow_array;
    return $row[0] || 0;
}

sub store {
    my ( $self, $fields ) = @_;
    my $tmp =
      $self->dbh->do( "insert into "
          . $self->{dbiTable} . " ("
          . join( ",", keys(%$fields) )
          . ") values ("
          . join( ",", values(%$fields) )
          . ")" );
    unless ($tmp) {
        $self->logError;
        return UNKNOWN_ERROR;
    }
    unless( $self->unlock ) {
        $self->logError;
        return UNKNOWN_ERROR;
    }
    return $fields->{cfgNum};
}

sub load {
    my ( $self, $cfgNum, $fields ) = @_;
    $fields = $fields ? join( ",", @$fields ) : '*';
    my $row =
      $self->dbh->selectrow_hashref(
        "SELECT $fields from " . $self->{dbiTable} . " WHERE cfgNum=$cfgNum" );
    unless ($row) {
        $self->logError;
        return 0;
    }
    return $row;
}

sub logError {
    my $self = shift;
    print STDERR "Database error: " . $self->dbh->errstr . "\n";
}

1;
__END__
