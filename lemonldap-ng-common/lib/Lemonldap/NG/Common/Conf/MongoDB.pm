package Lemonldap::NG::Common::Conf::MongoDB;

use 5.010;
use strict;
use MIME::Base64;

our $VERSION = '1.9.0';
our $initDone;

sub prereq {
    my $self = shift;
    unless ($initDone) {
        eval "use MongoDB";
        if ($@) {
            $Lemonldap::NG::Common::Conf::msg .= "Unable to load MongoDB: $@\n";
            return 0;
        }
        $self->{dbName}         ||= 'llConfDB';
        $self->{collectionName} ||= 'configuration';
        $initDone++;
    }
    1;
}

sub Lemonldap::NG::Common::Conf::_mongoDB {
    my $self = shift;
    return $self->{_mongoDB} if ( $self->{_mongoDB} );
    my $conn_args = {};
    foreach my $w (
        qw(host auth_mechanism auth_mechanism_properties connect_timeout_ms db_name port ssl username password)
      )
    {
        $conn_args->{$w} = $self->{$w} if ( defined $self->{$w} );
    }
    return $self->{_mongoDB} =
      MongoDB::MongoClient->new($conn_args)->get_database( $self->{dbName} );
}

sub Lemonldap::NG::Common::Conf::_mongoColl {
    my $self = shift;
    return $self->{_coll} if ( $self->{_coll} );
    return $self->{_coll} =
      $self->_mongoDB->get_collection( $self->{collectionName} );
}

sub Lemonldap::NG::Common::Conf::run_command {
    my $self = shift;
    $self->_mongoDB->run_command(@_);
}

sub available {
    my $self = shift;
    my $c    = $self->_mongoColl or return 0;
    my $res  = $self->run_command(
        [ distinct => $self->{collectionName}, key => '_id' ] );
    unless ( ref($res) ) {
        $Lemonldap::NG::Common::Conf::msg .= $res;
        return ();
    }
    return sort { $a <=> $b } @{ $res->{values} } if ( $res->{ok} );
    return ();
}

sub lastCfg {
    my $self  = shift;
    my @avail = $self->available;
    return $avail[$#avail];
}
sub lock     { 1 }
sub isLocked { 0 }
sub unlock   { 1 }

sub store {
    my ( $self, $fields ) = @_;
    my $conf = {};
    while ( my ( $k, $v ) = each(%$fields) ) {
        if ( ref($v) eq 'HASH' ) {
            foreach my $sk ( keys %$v ) {
                my $sk2 = encode_base64($sk);
                $conf->{$k}->{$sk2} = $v->{$sk};
            }
        }
        else {
            $conf->{$k} = $v;
        }
    }
    $conf->{_id} = $fields->{cfgNum};
    my $res = eval { $self->_mongoColl->insert($conf) };
    if ($@) {
        $Lemonldap::NG::Common::Conf::msg .= "Unable to store conf: $@\n";
        return 0;
    }
    return $res;
}

sub load {
    my ( $self, $cfgNum, $fields ) = @_;
    my $res = $self->_mongoColl->find_one( { _id => $cfgNum } );
    my $conf;
    while ( my ( $k, $v ) = each(%$res) ) {
        if ( ref($v) eq 'HASH' ) {
            foreach my $sk ( keys %$v ) {
                my $sk2 = decode_base64($sk);
                $conf->{$k}->{$sk2} = $v->{$sk};
            }
        }
        else {
            $conf->{$k} = $v;
        }
    }
    $res = undef;
    return $conf;
}

sub delete {
    my ( $self, $cfgNum ) = @_;
    die "cfgNum required" unless ($cfgNum);
    $self->_mongoColl->remove( { _id => $cfgNum } );
}

1;
