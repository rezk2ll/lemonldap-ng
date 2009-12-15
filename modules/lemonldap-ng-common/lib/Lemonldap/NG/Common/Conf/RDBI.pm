package Lemonldap::NG::Common::Conf::RDBI;

use strict;
use DBI;
use Lemonldap::NG::Common::Conf::Constants;    #inherits
use Lemonldap::NG::Common::Conf::Serializer;

our $VERSION = 0.17;

BEGIN {
    *Lemonldap::NG::Common::Conf::dbh = \&dbh;
}

sub prereq {
    my $self = shift;
    unless ( $self->{dbiChain} ) {
        $Lemonldap::NG::Common::Conf::msg =
          '"dbiChain" is required in RDBI configuration type';
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
      $self->dbh->prepare( "SELECT DISTINCT cfgNum from "
          . $self->{dbiTable}
          . " order by cfgNum" );
    $sth->execute();
    my @conf;
    while ( my @row = $sth->fetchrow_array ) {
        push @conf, $row[0];
    }
    return @conf;
}

sub lastCfg {
    my $self = shift;
    my @row  = $self->dbh->selectrow_array(
        "SELECT max(cfgNum) from " . $self->{dbiTable} );
    return $row[0];
}

sub dbh {
    my $self = shift;
    $self->{dbiTable} ||= "lmConfig";
    return $self->{dbh} if ( $self->{dbh} and $self->{dbh}->ping );
    return DBI->connect_cached(
        $self->{dbiChain}, $self->{dbiUser},
        $self->{dbiPassword}, { RaiseError => 1 }
    );
}

sub lock {
    my $self = shift;
    my $sth = $self->dbh->prepare_cached( q{SELECT GET_LOCK(?, 5)}, {}, 1 );
    $sth->execute('lmconfrdbi');
    my @row = $sth->fetchrow_array;
    return $row[0] || 0;
}

sub isLocked {
    my $self = shift;
    my $sth = $self->dbh->prepare_cached( q{SELECT IS_FREE_LOCK(?)}, {}, 1 );
    $sth->execute('lmconfrdbi');
    my @row = $sth->fetchrow_array;
    return $row[0] ? 0 : 1;
}

sub unlock {
    my $self = shift;
    my $sth = $self->dbh->prepare_cached( q{SELECT RELEASE_LOCK(?)}, {}, 1 );
    $sth->execute('lmconfrdbi');
    my @row = $sth->fetchrow_array;
    return $row[0] || 0;
}

sub store {
    my ( $self, $fields ) = @_;
    $self->{noQuotes} = 1;
    $fields = $self->serialize($fields);
    my $errors = 0;
    eval { $self->dbh->do('BEGIN'); };
    while ( my ( $k, $v ) = each %$fields ) {
        unless (
            $self->dbh->do(
                    "insert into "
                  . $self->{dbiTable}
                  . " (cfgNum,field,value) values ("
                  . join( ',', $fields->{cfgNum}, "'$k'", "'$v'" ) . ')'
            )
          )
        {
            $self->logError;
            $errors++;
            last;
        }
    }
    eval { $errors ? $self->dbh->do("ROLLBACK") : $self->dbh->do("COMMIT"); };
    unless ( $self->unlock ) {
        $self->logError;
    }
    return $errors ? UNKNOWN_ERROR : $fields->{cfgNum};
}

sub load {
    my ( $self, $cfgNum, $fields ) = @_;
    $fields = $fields ? join( ",", @$fields ) : '*';
    my $sth =
      $self->dbh->prepare( "SELECT cfgNum,field,value from "
          . $self->{dbiTable}
          . " WHERE cfgNum=$cfgNum" );
    $sth->execute();
    my ( $res, @row );
    while ( @row = $sth->fetchrow_array ) {
        $res->{ $row[1] } = $row[2];
    }
    unless($res) {
        $Lemonldap::NG::Common::Conf::msg .= "No configuration $cfgNum found";
        return 0;
    }
    $res->{cfgNum} = $cfgNum;
    return $self->unserialize($res);
}

sub delete {
    my ( $self, $cfgNum ) = @_;
    $self->dbh->do(
        "DELETE from " . $self->{dbiTable} . " WHERE cfgNum=$cfgNum" );
}

sub logError {
    my $self = shift;
    $Lemonldap::NG::Common::Conf::msg .=
      "Database error: " . $self->dbh->errstr . "\n";
}

1;
__END__

