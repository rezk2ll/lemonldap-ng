package Lemonldap::NG::Handler::Lib::ServiceToken;

use strict;

our $VERSION = '2.0.0';

sub fetchId {
    my($class) = @_;
    my $token = $class->header_in('X-Llng-Token');
    return $class->Lemonldap::NG::Handler::Main::fetchId() unless($token);
    $class->logger->debug('Found token header');
    my $s $class->tsv->{cipher}->decrypt($s);
    my($t,$_session_id,@vhosts) = split /:/, $s;
    unless(@vhosts) {
        $class->userLogger->error('Bad token');
        return 0;
    }
    unless($t <= time and $t > time -15) {
        $class->userLogger->warn('Expired token');
        return 0;
    }
    return $_session_id;
}

1;
