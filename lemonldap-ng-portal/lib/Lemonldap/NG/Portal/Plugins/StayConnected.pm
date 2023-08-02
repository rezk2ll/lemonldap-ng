# Plugin to enable "stay connected on this device" feature

package Lemonldap::NG::Portal::Plugins::StayConnected;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
);

our $VERSION = '2.17.0';

extends qw(
  Lemonldap::NG::Portal::Main::Plugin
);

# INTERFACE

use constant beforeAuth => 'check';

# INITIALIZATION
sub init {
    my ($self) = @_;
    return 1;
}

# Check for:
#  - persistent connection cookie
#  - valid session
#  - uniq id is kept
# Then delete authentication methods from "steps" array.
sub check {
    my ( $self, $req ) = @_;
    if ( my $uid = $req->data->{_trustedUser} ) {
        return $self->skipAuthentication($req);
    }
    return PE_OK;
}

# Remove authentication steps from the login flow
sub skipAuthentication {
    my ( $self, $req ) = @_;
    my $uid = $req->data->{_trustedUser};
    $req->user($uid);
    $req->sessionInfo->{_stayConnectedSession} =
      $req->data->{_stayConnectedSession};
    my @steps =
      grep { ref $_ or $_ !~ /^(?:extractFormInfo|authenticate)$/ }
      @{ $req->steps };
    $req->steps( \@steps );
    $self->userLogger->notice("$uid connected by StayConnected cookie");
    return PE_OK;
}

1;
