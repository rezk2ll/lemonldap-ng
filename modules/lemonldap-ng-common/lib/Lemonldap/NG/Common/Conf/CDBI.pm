package Lemonldap::NG::Common::Conf::CDBI;

use strict;
use DBI;
require Storable;
use Lemonldap::NG::Common::Conf::Constants;    #inherits

our $VERSION = 0.1;

BEGIN {
    *Lemonldap::NG::Common::Conf::_dbh = \&_dbh;
}

sub prereq {
    my $self = shift;
    unless ( $self->{dbiChain} ) {
        $Lemonldap::NG::Common::Conf::msg =
          '"dbiChain" is required in DBI configuration type';
        return 0;
    }
    print STDERR __PACKAGE__ . 'Warning: "dbiUser" parameter is not set'
      unless ( $self->{dbiUser} );
    $self->{dbiTable} ||= "lmConfig";
    1;
}

sub available {
    my $self = shift;
    my $sth  = $self->_dbh->prepare(
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
    my @row  = $self->_dbh->selectrow_array(
        "SELECT max(cfgNum) from " . $self->{dbiTable} );
    return $row[0];
}

sub _dbh {
    my $self = shift;
    $self->{dbiTable} ||= "lmConfig";
    return $self->{_dbh} if ( $self->{_dbh} and $self->{_dbh}->ping );
    return DBI->connect_cached(
        $self->{dbiChain}, $self->{dbiUser},
        $self->{dbiPassword}, { RaiseError => 1 }
    );
}

sub lock {
    my $self = shift;
    my $sth = $self->_dbh->prepare_cached( q{SELECT GET_LOCK(?, 5)}, {}, 1 );
    $sth->execute('lmconf');
    my @row = $sth->fetchrow_array;
    return $row[0] || 0;
}

sub isLocked {
    my $self = shift;
    my $sth = $self->_dbh->prepare_cached( q{SELECT IS_FREE_LOCK(?)}, {}, 1 );
    $sth->execute('lmconf');
    my @row = $sth->fetchrow_array;
    return $row[0] ? 0 : 1;
}

sub unlock {
    my $self = shift;
    my $sth = $self->_dbh->prepare_cached( q{SELECT RELEASE_LOCK(?)}, {}, 1 );
    $sth->execute('lmconf');
    my @row = $sth->fetchrow_array;
    return $row[0] || 0;
}

sub store {
    my ( $self, $fields ) = @_;
    my $c = $fields->{cfgNum};
    $fields = Storable::nfreeze($fields);
    $fields =~ s/'/''/gs;
    my $tmp =
      $self->_dbh->do( "insert into "
          . $self->{dbiTable}
          . " (cfgNum,data) values ($cfgNum,'$fields')" );
    unless ($tmp) {
        $self->logError;
        return UNKNOWN_ERROR;
    }
    unless ( $self->unlock ) {
        $self->logError;
        return UNKNOWN_ERROR;
    }
    eval { $self->_dbh->do("COMMIT"); };
    return $c;
}

sub load {
    my ( $self, $cfgNum, $fields ) = @_;
    $fields = $fields ? join( ",", @$fields ) : '*';
    my $row = $self->_dbh->selectrow_arrayref(
        "SELECT data from " . $self->{dbiTable} . " WHERE cfgNum=$cfgNum" );
    unless ($row) {
        $self->logError;
        return 0;
    }
    my $r;
    eval { $r = Storable::thaw( $row->[1] ); };
    if ($@) {
        $Lemonldap::NG::Common::Conf::msg =
          "Bad stored data in conf database: $@";
        return 0;
    }
    return $r;
}

sub delete {
    my ( $self, $cfgNum ) = @_;
    $self->_dbh->do(
        "DELETE from " . $self->{dbiTable} . " WHERE cfgNum=$cfgNum" );
}

sub logError {
    my $self = shift;
    $Lemonldap::NG::Common::Conf::msg =
      "Database error: " . $self->_dbh->errstr . "\n";
}

1;
__END__
