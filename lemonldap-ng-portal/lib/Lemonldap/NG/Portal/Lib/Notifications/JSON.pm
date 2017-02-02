package Lemonldap::NG::Portal::Lib::Notifications::JSON;

use strict;
use Mouse;
use JSON qw(from_json);

our $VERSION = '2.0.0';

no warnings 'redefine';

# Lemonldap::NG::Portal::Main::Plugin provides addAuthRoute() and
# addUnauthRoute() methods in addition of Lemonldap::NG::Common::Module.
extends 'Lemonldap::NG::Portal::Main::Plugin';

# PROPERTIES

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
        my $json = from_json($file);
        my $j    = 0;                  #Notifications count
        my @res;
        $json = [$json] unless ( ref $json eq 'ARRAY' );
      LOOP: foreach my $notif ( @{$json} ) {

            # Get the reference
            my $reference = $notif->{reference};

            $self->lmLog( "Get reference $reference", 'debug' );

            # Check it in session
            if ( exists $req->{sessionInfo}->{"notification_$reference"} ) {

                # The notification was already accepted
                $self->lmLog( "Notification $reference was already accepted",
                    'debug' );
                next LOOP;
            }
            push @res, $notif;
            $j++;
        }

        # Go to next file if no notification found
        next unless $j;
        $i++;
        $form .= $self->toForm(@res);
    }

    # Stop here if nothing to display
    return 0 unless $i;

    # Cipher cookie
    $req->id( $self->p->HANDLER->tsv->{cipher}->encrypt( $req->id ) );

    # Returns HTML fragment
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
            my $json       = from_json($file);
            $json = [$json] unless ( ref $json eq 'ARRAY' );

            # Get pending notifications and verify that they have been accepted
            foreach my $notif (@$json) {
                my $reference = $notif->{reference};

                # Check if this pending notification has been seen
                if ( my $refId = $refs->{$reference} ) {

                    # Verity that checkboxes have been checked
                    if ( $notif->{check} ) {
                        if ( my $toCheckCount = @{ $notif->{check} } ) {
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

sub toForm {
    my ( $self, @notifs ) = @_;
    my $i = 0;
    @notifs = map {
        $i++;
        if ( $_->{check} ) {
            my $j = 0;
            $_->{check} =
              [ map { $j++; { id => '1x' . $i . 'x' . $j, value => $_ } }
                  @{ $_->{check} } ];
        }
        $_->{id} = "1x$i";
        $_;
    } @notifs;
    require HTML::Template;
    my $file =
        $self->conf->{templateDir} . '/'
      . $self->conf->{portalSkin}
      . '/notifinclude.tpl';
    $file = $self->conf->{templateDir} . '/common/notifinclude.tpl'
      unless ( -e $file );
    my $tpl = HTML::Template->new(
        filename               => $file,
        die_on_bad_params      => 0,
        die_on_missing_include => 1,
        cache                  => 1,
        global_vars            => 0,
    );
    $tpl->param( notifications => \@notifs );
    return $tpl->output;
}

1;
