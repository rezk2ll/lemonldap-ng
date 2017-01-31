package Lemonldap::NG::Portal::Lib::Notifications::XML;

use strict;
use Mouse;
use XML::LibXML;
use XML::LibXSLT;

our $VERSION = '2.0.0';

# Lemonldap::NG::Portal::Main::Plugin provides addAuthRoute() and
# addUnauthRoute() methods in addition of Lemonldap::NG::Common::Module.
extends 'Lemonldap::NG::Portal::Main::Plugin';

# PROPERTIES

# XML parser
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
        my $self = $_[0];
        my $xslt = XML::LibXSLT->new();
        my $styleFile =
          ( $self->conf->{notificationXSLTfile}
              and -e $self->conf->{notificationXSLTfile} )
          ? $self->conf->{notificationXSLTfile}
          : $self->conf->{templatesDir} . '/common/notification.xsl';
        die "$styleFile not found" unless ( -e $styleFile );
        return $xslt->parse_stylesheet( $self->parser->parse_file($styleFile) );
    }
);

# Underlying notifications storage object (File, DBI, LDAP,...)
has notifObject => ( is => 'rw' );

# INITIALIZATION

sub init {
    1;
}

# Search for notifications and if any, returns HTML fragment.
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
        my $xml = $self->parser->parse_string($file);
        my $j   = 0;                                    #Notifications count
      LOOP: foreach my $notif (
            eval { $xml->documentElement->getElementsByTagName('notification') }
          )
        {

            # Get the reference
            my $reference = $notif->getAttribute('reference');

            $self->lmLog( "Get reference $reference", 'debug' );

            # Check it in session
            if ( exists $req->{sessionInfo}->{"notification_$reference"} ) {

                # The notification was already accepted
                $self->lmLog( "Notification $reference was already accepted",
                    'debug' );

                # Remove it from XML
                $notif->unbindNode();
                next LOOP;
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
                    next LOOP;
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
    }
    if ($@) {
        $self->lmLog( "Bad XML file: a notification for $uid was not done ($@)",
            'warn' );
        return 0;
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
        return $self->p->do( $req, ['controlUrl'] );
    }
    else {
        # No notifications checked here, this entry point must not be called.
        # Redirecting to portal
        $self->lmLog( 'No notifications checked', 'debug' );
        $req->mustRedirect(1);
        return $self->p->do( $req, [] );
    }
}

*rebuildCookies =
  \&Lemonldap::NG::Portal::Plugins::Notifications::rebuildCookies;

1;
