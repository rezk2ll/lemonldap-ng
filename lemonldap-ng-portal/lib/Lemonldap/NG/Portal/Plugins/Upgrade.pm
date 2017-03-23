package Lemonldap::NG::Portal::Plugins::Upgrade;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_CONFIRM PE_OK);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

sub init {
    my ($self) = @_;
    $self->addAuthRoute(upgradesession => 'ask', ['GET']);
    $self->addAuthRoute(upgradesession => 'confirm', ['POST']);
}

# RUNNING METHOD

sub ask {
    my ( $self, $req ) = @_;
    if($req->param('upgrading') ) {
        # verify token
        return $self->confirm($req);
    }

    # Display form
}

sub confirm {
    my ( $self, $req ) = @_;
    my $ok;
    if($req->param('upgrading') ) {
        # verify token and set $ok to 1
    }
    if ( $ok or $req->param('confirm') == 1 ) {
        $self->p->setHiddenFormValue(); # Insert token
        return $self->p->login($req);
    }
    else {
        # Go to portal
    }
}

1;
