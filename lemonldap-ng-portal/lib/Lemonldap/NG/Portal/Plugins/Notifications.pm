package Lemonldap::NG::Portal::Plugins::Notifications;

use strict;
use Mouse;
use XML::LibXML;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

has notifObject => ( is => 'rw' );

has parser => (
    is      => 'rw',
    builder => sub {
        return XML::LibXML->new();
    }
);

# Two entry points for notifications:
#  * a new route "/reference" for checking accepted notifications
#    (sub getNotifBack). It launch then autoRedirect() with "mustRedirect"
#    set to 1 because underlying handler has not seen user as authenticated
#    so datas are not set;
#  * a process step inserted after authentication process:
#    checkForNotifications that cipher cookies

sub init {
    my ($self) = @_;
    $self->addUnauthRoute( 'reference' => 'getNotifBack', ['POST'] );
    $self->addAuthRoute( 'reference' => 'getNotifBack', ['POST'] );

    # Use configuration options
    my $type = $self->conf->{notificationStorage};
    unless ($type) {
        $self->error('notificationStorage is not defined, aborting');
        return 0;
    }
    eval "require Lemonldap::NG::Common::Notification::$type";
    if ($@) {
        $self->error($@);
        return 0;
    }

    # TODO: use conf database?

    unless (
        eval {
            $self->notifObject(
                "Lemonldap::NG::Common::Notification::$type"->new(
                    $self->conf->{notificationStorageOptions}
                )
            );
        }
      )
    {
        $self->error($@);
        return 0;
    }
    1;
}

sub afterDatas { 'checkForNotifications' }

sub checkForNotifications {
    my ( $self, $req ) = @_;

    # Look for pending notifications in database

    # If found, store them and cipher cookies
    PE_OK;
}

sub getNotifBack {
    my ( $self, $req, $name ) = @_;

    # Look if al notifications have been accepted. If not, redirects to
    # portal
    #TODO

    # Else restore args and launch autoredirect
    # TODO
    $self->p->do( $req, [] );
}

1;
