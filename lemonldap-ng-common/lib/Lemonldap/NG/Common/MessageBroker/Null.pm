package Lemonldap::NG::Common::MessageBroker::Null;

use strict;

sub new {
    return bless {}, shift;
}

sub publish {}
sub subscribe {}
sub checkNextMessage {}
sub getNextMessage {
    die __PACKAGE__ . ' is not a real message broker';
}

1;
