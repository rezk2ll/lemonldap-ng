package Lemonldap::NG::Handler::Lib::ServiceToken;

use strict;

our $VERSION = '2.0.0';

sub fetchId {
    my ( $class, $req ) = @_;
    my $token = $req->{env}->{HTTP_X_LLNG_TOKEN};
    return $class->Lemonldap::NG::Handler::Main::fetchId($req) unless ($token);
    $class->logger->debug('Found token header');
    my $s = $class->tsv->{cipher}->decrypt($token);
    my ( $t, $_session_id, @vhosts ) = split /:/, $s;
    unless (@vhosts) {
        $class->userLogger->error('Bad token');
        return 0;
    }
    unless ( $t <= time and $t > time - 30 ) {
        $class->userLogger->warn('Expired token');
        return 0;
    }
    my $vh = $class->resolveAlias($req);
    unless ( grep { $_ eq $vh } @vhosts ) {
        $class->userLogger->error(
            "$vh not authorizated in token (" . join( ', ', @vhosts ) . ')' );
        return 0;
    }
    return $_session_id;
}

1;
