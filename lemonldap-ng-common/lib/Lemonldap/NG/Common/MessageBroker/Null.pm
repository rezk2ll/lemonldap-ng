package Lemonldap::NG::Common::MessageBroker::Null;

use strict;

sub new {
    return bless {}, shift;
}

sub publish {}
*subscribe = \&publish;
*checkNextMessage = \&publish;

sub getNextMessage {
    die __PACKAGE__ . ' is not a real message broker';
}

1;
