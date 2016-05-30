# Notifications plugin.
#
# Three entry points for notifications:
#  * a new route "/notifback" for checking accepted notifications
#    (sub getNotifBack). It launch then autoRedirect() with "mustRedirect"
#    set to 1 because underlying handler has not seen user as authenticated
#    so datas are not set;
#  * two callbacks inserted in process steps:
#    - one inserted after authentication process,
#    - one for authenticated users,
#    These callbacks launch checkForNotifications to get notification and
#    cipher LemonLDAP::NG cookies if any found.

package Lemonldap::NG::Portal::Plugins::Notifications;

use strict;
use Mouse;
use XML::LibXML;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_NOTIFICATION);

our $VERSION = '2.0.0';

# Lemonldap::NG::Portal::Main::Plugin provides addAuthRoute() and
# addUnauthRoute() methods in addition of Lemonldap::NG::Portal::Main::Module.
extends 'Lemonldap::NG::Portal::Main::Plugin';

# XML parser. TODO: replace this by JSON
has parser => (
    is      => 'rw',
    builder => sub {
        return XML::LibXML->new();
    }
);

# XSLT document
has stylesheet => (
    is      => 'rw',
    lazy    => 1,
    builder => sub {
        my $self      = $_[0];
        my $xslt      = XML::LibXSLT->new();
        my $styleFile = (
            -e $self->conf->{notificationXSLTfile}
            ? $self->conf->{notificationXSLTfile}
            : $self->conf->{templatesDir} . '/skins/common/notification.xsl'
        );
        return $xslt->parse_stylesheet( $self->parser($styleFile) );
    }
);

# Underlying notifications storage object (File, DBI, LDAP,...)
has notifObject => ( is => 'rw' );

has notifField => (
    is      => 'rw',
    builder => sub {
        my $uid =
             $_[0]->conf->{notificationField}
          || $_[0]->conf->{whatToTrace}
          || 'uid';
        $uid =~ s/^\$//;
        return $uid;
    }
);

# Declare additional process steps
sub afterDatas { 'checkNotifDuringAuth' }

sub forAuthUser { 'checkNotifForAuthUser' }

# Plugin initialization
sub init {
    my ($self) = @_;

    # Declare new route
    $self->addUnauthRoute( 'notifback' => 'getNotifBack', ['POST'] );
    $self->addAuthRoute( 'notifback' => 'getNotifBack', ['POST'] );

    # Search for configuration options
    my $type = $self->conf->{notificationStorage};
    unless ($type) {
        $self->error('notificationStorage is not defined, aborting');
        return 0;
    }

    # Initialize notifications storage object
    $type = "Lemonldap::NG::Common::Notification::$type";
    eval "require $type";
    if ($@) {
        $self->error($@);
        return 0;
    }

    # TODO: use conf database?

    unless (
        eval {
            $self->notifObject(
                $type->new( $self->conf->{notificationStorageOptions} ) );
        }
      )
    {
        $self->error($@);
        return 0;
    }
    1;
}

sub checkNotifDuringAuth {
    my ( $self, $req ) = @_;
    if ( my $notif = $self->checkForNotifications($req) ) {

        # Cipher cookies
    }
    else {
        return PE_OK;
    }
}

sub checkNotifForAuthUser {
    my ( $self, $req ) = @_;
    if ( my $notif = $self->checkForNotifications($req) ) {

        # Restore and cipher cookies
    }
    else {
        return PE_OK;
    }
}

# Search for notifications and if any, returns HTML fragment.
# TODO: replace this by JSON+Ajax
sub checkForNotifications {
    my ( $self, $req ) = @_;

    # Look for pending notifications in database
    my $uid = $req->sessionInfo->{ $self->notifField };
    my $notifs $$self->getNotifications($uid);
    my $form;
    return 0 unless ($notifs);

    # Transform notifications
    my $i = 0;    #Files count
    foreach my $file ( values %$notifs ) {
        eval {
            my $xml = $self->parser->parse_string($file);
            my $j   = 0;                                    #Notifications count
            foreach my $notif (
                $xml->documentElement->getElementsByTagName('notification') )
            {

                # Get the reference
                my $reference = $notif->getAttribute('reference');

                $self->lmLog( "Get reference $reference", 'debug' );

                # Check it in session
                if ( exists $req->{sessionInfo}->{"notification_$reference"} ) {

                    # The notification was already accepted
                    $self->lmLog(
                        "Notification $reference was already accepted",
                        'debug' );

                    # Remove it from XML
                    $notif->unbindNode();
                    next;
                }

                # Check condition if any
                my $condition = $notif->getAttribute('condition');

                if ($condition) {

                    $self->lmLog( "Get condition $condition", 'debug' );

                    unless ( $self->p->HANDLER->safe->reval($condition) ) {
                        $self->lmLog( "Notification condition not accepted",
                            'debug' );

                        # Remove it from XML
                        $notif->unbindNode();
                        next;

                    }
                }

                $j++;
            }

            # Go to next file if no notification found
            next unless $j;
            $i++;

            # Transform XML into HTML
            my $results = $self->stylesheet->transform( $xml, start => $i );
            $form .= $self->stylesheet->output_string($results);
        };
        if ($@) {
            $self->lmLog(
                "Bad XML file: a notification for $uid was not done ($@)",
                'warn' );
            return 0;
        }
    }

    # Stop here if nothing to display
    return 0 unless $i;

    # Returns HTML fragment
    return $form;
}

sub getNotifBack {
    my ( $self, $req, $name ) = @_;

    # Look if all notifications have been accepted. If not, redirects to
    # portal

    # Search for Lemonldap::NG cookie (ciphered)
    my $id;
    if (    $id = $req->cookies
        and $id =~ s/$self->{conf}->{cookieName}=([^,; ]+)/$1/o )
    {
        return $self->p->sendError( 'No cookie found', 401 );
    }
    $id = $self->p->conf->decrypt($id)
      or return $self->sendError( 'Unable to decrypt', 500 );

    # Verify that session exists
    $self->p->HANDLER->retrieveSession($id)
      or return $self->sendError( 'Unknown session', 401 );

    # Restore datas
    $self->p->importHandlerDatas($req);
    my $uid = $req->sessionInfo->{ $self->notifField };

    if (
        my $notifs = $self->getNotifications($uid){

            #TODO

            # Get accepted notifications
            $req->parseBody;
              my ( $refs, $checks );
              my $prms = $req->params;
              foreach ( keys %$prms ) {
                my $v = $prms ($_);
                if (s/^reference//) {
                    $refs->{$_} = $v;
                }
                elsif ( s/^check// and /^(\d+x\d+)x(\d+)$/ ) {
                    push @{ $checks->{$1} }, $2;
                }
            }
        }

        # Else uncipher cookie, restore args and launch autoredirect
        # TODO
        $self->p->do( $req, [] );
    }

    sub getNotifications {
        my ( $self, $uid ) = @_;
        my $forUser = $self->notifObject->get($uid);
        my $forAll =
          $self->notifObject->get( $self->conf->{notificationWildcard} );
        if ( $forUser and $forAll ) {
            return { %$forUser, %$forAll };
        }
        else {
            return ( $forUser ? $forUser : $forAll );
        }
    }

    1;
