package t::OidcClientHookPlugin;

use Mouse;
extends 'Lemonldap::NG::Portal::Main::Plugin';

use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

our $authzCallbackHookCalled = '';

use constant hook => {
    oidcGotAuthenticationResponse => 'gotAuthzCallback',
};

sub gotAuthzCallback {
    my ( $self, $req, $callback_params ) = @_;

    # Mark that the hook was called
    $authzCallbackHookCalled = 1;

    return PE_OK;
}

1;
