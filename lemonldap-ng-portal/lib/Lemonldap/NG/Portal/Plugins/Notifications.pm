# Notifications plugin.
#
# Two entry points for notifications:
#  * a new route "/notifback" for checking accepted notifications
#    (sub getNotifBack). It launch then autoRedirect() with "mustRedirect"
#    set to 1 because underlying handler has not seen user as authenticated
#    so datas are not set;
#  * a callback inserted in process steps after authentication process,
#    This callback launches checkForNotifications to get notification and
#    cipher LemonLDAP::NG cookies.

package Lemonldap::NG::Portal::Plugins::Notifications;

use strict;
use Mouse;
use XML::LibXSLT;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_NOTIFICATION);

our $VERSION = '2.0.0';

# Lemonldap::NG::Portal::Main::Plugin provides addAuthRoute() and
# addUnauthRoute() methods in addition of Lemonldap::NG::Common::Module.
extends 'Lemonldap::NG::Portal::Main::Plugin';

# PROPERTIES

sub parser {
    return $_[0]->notifObject->parser;
}

# XSLT document
has stylesheet => (
    is      => 'rw',
    lazy    => 1,
    builder => sub {
        my $self      = $_[0];
        my $xslt      = XML::LibXSLT->new();
        my $styleFile = (
            (
                $self->conf->{notificationXSLTfile}
                  and -e $self->conf->{notificationXSLTfile}
            )
            ? $self->conf->{notificationXSLTfile}
            : $self->conf->{templatesDir} . '/common/notification.xsl'
        );
        die "$styleFile not found" unless ( -e $styleFile );
        return $xslt->parse_stylesheet( $self->parser->parse_file($styleFile) );
    }
);

# Underlying notifications storage object (File, DBI, LDAP,...)
has notifObject => ( is => 'rw' );

# INTERFACE

# Declare additional process steps
sub afterDatas { 'checkNotifDuringAuth' }

# For now, notifications are done only during authentication process
#sub forAuthUser { 'checkNotifForAuthUser' }

# INITIALIZATION

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
    $type = "Lemonldap::NG::Common::Notifications::$type";
    eval "require $type";
    if ($@) {
        $self->error(
            "Unable to load Lemonldap::NG::Common::Notifications::$type: $@");
        return 0;
    }

    # TODO: use conf database?

    my $prms = {
        %{ $self->conf->{notificationStorageOptions} },
        p    => $self->p,
        conf => $self->p->conf
    };
    unless ( eval { $self->notifObject( $type->new($prms) ); } ) {
        $self->error($@);
        return 0;
    }
    1;
}

#sub checkNotifForAuthUser {
#    my ( $self, $req ) = @_;
#    if ( my $notif = $self->checkForNotifications($req) ) {
#
#        # Cipher cookies
#        return PE_NOTIFICATION;
#    }
#    else {
#        return PE_OK;
#    }
#}

# RUNNING METHODS

sub checkNotifDuringAuth {
    my ( $self, $req ) = @_;
    if ( $req->{datas}->{notification} = $self->checkForNotifications($req) ) {
        $self->rebuildCookies($req);

        # Restore and cipher cookies
        return PE_NOTIFICATION;
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
    my $uid = $req->sessionInfo->{ $self->notifObject->notifField };
    my ( $notifs, $forUser ) = $self->notifObject->getNotifications($uid);
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
    $req->id( $self->p->HANDLER->tsv->{cipher}->encrypt( $req->id ) );
    return $form;
}

sub getNotifBack {
    my ( $self, $req, $name ) = @_;

    # Look if all notifications have been accepted. If not, redirects to
    # portal

    # Search for Lemonldap::NG cookie (ciphered)
    my $id;
    unless ( $id = $req->cookies->{ $self->{conf}->{cookieName} } ) {
        return $self->p->sendError( $req, 'No cookie found', 401 );
    }
    $id = $self->p->HANDLER->tsv->{cipher}->decrypt($id)
      or return $self->sendError( $req, 'Unable to decrypt', 500 );

    # Verify that session exists
    $req->userData( $self->p->HANDLER->retrieveSession($id) )
      or return $self->sendError( $req, 'Unknown session', 401 );

    # Restore datas
    $self->p->importHandlerDatas($req);
    my $uid = $req->sessionInfo->{ $self->notifObject->notifField };

    my ( $notifs, $forUser ) = $self->notifObject->getNotifications($uid);
    if ($notifs) {

        # Get accepted notifications
        my ( $refs, $checks ) = ( {}, {} );
        my $prms = $req->parameters;
        foreach ( keys %$prms ) {
            my $v = $prms->{$_};
            if (s/^reference//) {
                $refs->{$v} = $_;
            }
            elsif ( s/^check// and /^(\d+x\d+)x(\d+)$/ and $v eq 'accepted' ) {
                push @{ $checks->{$1} }, $2;
            }
        }

        my $result = 1;
        foreach my $fileName ( keys %$notifs ) {
            my $file       = $notifs->{$fileName};
            my $fileResult = 1;
            my $xml        = $self->parser->parse_string($file);

            # Get pending notifications and verify that they have been accepted
            foreach my $notif (
                $xml->documentElement->getElementsByTagName('notification') )
            {
                my $reference = $notif->getAttribute('reference');

                # Check if this pending notification has been seen
                if ( my $refId = $refs->{$reference} ) {

                    # Verity that checkboxes have been checked
                    my @toCheck = $notif->getElementsByTagName('check');
                    if ( my $toCheckCount = @toCheck ) {
                        unless ($checks->{$refId}
                            and $toCheckCount == @{ $checks->{$refId} } )
                        {
                            $self->p->userNotice(
                                "$uid has not accepted notification $reference"
                            );
                            $result = $fileResult = 0;
                            next;
                        }
                    }
                }
                else {
                    # Current pending notification has not been found in
                    # request
                    $result = $fileResult = 0;
                    $self->lmLog(
                        'Current pending notification has not been found',
                        'debug' );
                    next;
                }

                # Register acceptation
                $self->p->userNotice(
                    "$uid has accepted notification $reference");
                $self->p->updatePersistentSession( $req,
                    { "notification_$reference" => time() } );
                $self->lmLog(
                    "Notification $reference registered in persistent session",
                    'debug'
                );
            }

        # Notifications accepted for this file, delete it unless it's a wildcard
            if ( $fileResult and exists $forUser->{$fileName} ) {
                $self->lmLog( "Notification file deleted", 'debug' );
                $self->notifObject->delete($fileName);
            }
        }
        unless ($result) {

            # One pending notification has been found and not accepted,
            # restart process to display pending notifications
            # TODO: is it a good idea to launch all 'afterDatas' subs ?
            $self->lmLog(
                'Pending notification has been found and not accepted',
                'debug' );
            return $self->p->do( $req, $self->p->afterDatas );
        }

        # All pending notifications have been accepted, restore cookies and
        # launch 'controlUrl' to restore "urldc" using do()
        $self->lmLog( 'All pending notifications have been accepted', 'debug' );
        $self->rebuildCookies($req);
        $self->p->do( $req, ['controlUrl'] );
    }
    else {
        # No notifications checked here, this entry point must not be called.
        # Redirecting to portal
        $self->lmLog( 'No notifications checked', 'debug' );
        $req->mustRedirect(1);
        $self->p->do( $req, [] );
    }
}

sub rebuildCookies {
    my ( $self, $req ) = @_;
    my @tmp;
    for ( my $i = 0 ; $i < @{ $req->{respHeaders} } ; $i += 2 ) {
        push @tmp, $req->respHeaders->[0], $req->respHeaders->[1]
          unless ( $req->respHeaders->[0] eq 'Set-Cookie' );
    }
    $req->{respHeaders} = \@tmp;
    $self->p->buildCookie($req);
}

1;
