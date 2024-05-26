package Lemonldap::NG::Common::MessageBroker::Pg;

use strict;
use DBI;
use JSON;

our $VERSION = '2.20.0';

sub new {
    my $args = $_[1]->{messageBrokerOptions};
    unless ($args
        and $args->{dbiChain}
        and $args->{dbiUser}
        and $args->{dbiPassword} )
    {
        print STDERR "MISSING OPTIONS FOR PG PUB/SUB\n";
        return undef;
    }
    my $self = bless { %{$args} }, shift;
    return $self;
}

sub publish {
    my ($self, $channel, $msg ) = @_;
    die 'Not a hash msg' unless ref $msg eq 'HASH';
    my $j = eval { JSON::to_json($msg) };
    $j =~ s/'/''/g;
    die "MessageBroker publish only hashes! $@" if $@;
    $self->_dbh->do("NOTIFY $channel, '$j'");
}

sub subscribe {
    my ( $self, $channel ) = @_;
    $self->{messages}{$channel} = [];
    $self->_dbh->do("LISTEN $channel");
}

sub checkNextMessage {
    my ( $self, $channel, $delay ) = @_;
    return undef
      unless $self->{messages}{$channel};
    if ( my $notify = $self->_dbh->pg_notifies ) {
        my ($name, $pid, $payload) = @$notify;
        $payload = eval { JSON::from_json($payload) };
        if ($@) {
            print STDERR "Bad message from Pg: $@";
        }
        else {
            push @{ $self->{messages}{$name} }, $payload;
        }
    }
    return shift( @{ $self->{messages}{$channel} } )
      if @{ $self->{messages}{$channel} };
}

sub getNextMessage {
    my ( $self, $channel ) = @_;
    return undef unless $self->{messages}{$channel};

    # Infinite loop until one message is seen
    my $res;
    while ( not($res = $self->checkNextMessage($channel))){
        sleep 1;
    }
}

sub _dbh {
    my ($self) = @_;
    return $self->{_dbh} if ( $self->{_dbh} and $self->{_dbh}->ping );
    $self->{_dbh} = DBI->connect_cached( $self->{dbiChain}, $self->{dbiUser},
        $self->{dbiPassword}, { RaiseError => 1, AutoCommit => 1, } );
}

1;
