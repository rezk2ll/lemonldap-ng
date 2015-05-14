package Lemonldap::NG::Manager::Notifications;

use 5.10.0;
use Mouse;

use Lemonldap::NG::Common::Conf::Constants;
use Lemonldap::NG::Common::PSGI::Constants;
use Lemonldap::NG::Manager::Constants;
use Lemonldap::NG::Common::Notification;

use feature 'state';

extends 'Lemonldap::NG::Manager::Lib';

our $VERSION = '2.0.0';

has _notifAccess => ( is => 'rw' );

#############################
# I. INITIALIZATION METHODS #
#############################

use constant defaultRoute => 'notifications.html';

sub addRoutes {
    my $self = shift;

    return unless ( $self->notifAccess );
    $self->{multiValuesSeparator} ||= '; ';

    # HTML template
    $self->addRoute( 'notifications.html', undef, ['GET'] )

      # READ
      ->addRoute(
        'notifications' =>
          { actives => 'activeNotifications', done => 'doneNotifications' },
        ['GET']
      )

      # Create new notification
      ->addRoute(
        'notifications' => { actives => 'newNotification' },
        ['POST']
      )

      # Update a notification (mark as done)
      ->addRoute(
        notifications =>
          { actives => { ':notificationId' => 'updateNotification' } },
        ['PUT']
      )

      # Delete a notification
      ->addRoute(
        notifications =>
          { done => { ':notificationId' => 'deleteDoneNotification' } },
        ['DELETE']
      );

}

sub notifAccess {
    my $self = shift;
    return $self->_notifAccess if ( $self->_notifAccess );

    # 1. Get notificationStorage or build it using globalStorage
    my $conf = $self->_confAcc->getConf()
      or die($Lemonldap::NG::Common::Conf::msg);
    my $args;

    # TODO: refresh system
    $self->{$_} //= $conf->{$_}
      foreach (
        qw/portal notification notificationStorage notificationStorageOptions/);

    unless ( $self->{notification} ) {
        $self->addRoute( notifications => 'notEnabled' );
        return 0;
    }

    # TODO: old parameters (with table)
    unless ( $self->{notificationStorage} ) {
        $self->routerAbort( notifications =>
              'notificationStorage is not defined in configuration' );
        return 0;
    }
    $args->{type} = $self->{notificationStorage};
    foreach ( keys %{ $self->{notificationStorageOptions} } ) {
        $args->{$_} = $self->{notificationStorageOptions}->{$_};
    }

    # Get the type
    $args->{type} =~ s/.*:://;
    $args->{type} =~ s/(CBDI|RDBI)/DBI/;    # CDBI/RDBI are DBI

    # If type not File or DBI, abort
    unless ( $args->{type} =~ /^(File|DBI|LDAP)$/ ) {
        $self->routerAbort( notifications =>
              "Only File, DBI or LDAP supported for Notifications" );
        return 0;
    }

    # Force table name
    $args->{p} = $self;
    unless (
        $self->_notifAccess( Lemonldap::NG::Common::Notification->new($args) ) )
    {
        $self->routerAbort(
            notifications => $Lemonldap::NG::Common::Notification::msg );
        return 0;
    }
    return $self->_notifAccess();
}

#######################
# II. DISPLAY METHODS #
#######################

sub notEnabled {
    my ( $self, $req ) = splice @_;
    return $self->sendError( $req,
        'Notifications are not enabled in your configuration', 400 );
}

sub activeNotifications {
    my ( $self, $req, $notif ) = splice @_;
    return $self->notifications( $req, $notif, 'actives' );
}

sub doneNotifications {
    my ( $self, $req, $notif ) = splice @_;
    return $self->notifications( $req, $notif, 'done' );
}

sub notifications {
    my ( $self, $req, $notif, $type ) = splice @_;
    my $sub = { actives => 'getAll', done => 'getDone' }->{$type}
      or die "Unknown type $type";

    # Case 1: a notification is required
    return $self->notification( $req, $notif, $type ) if ($notif);

    # Case 2: list
    my $params = $req->params();
    my ( $notifs, $res );

    $notifs = $self->notifAccess->$sub();

    # Restrict to wanted values
    if (
        my %filters =
        map { /^(?:(?:group|order)By)$/ ? () : ( $_ => $params->{$_} ); }
        keys %$params
      )
    {
        while ( my ( $field, $value ) = each %filters ) {
            $value =~ s/\*/\.\*/g;
            $value = qr/$value/;
            foreach my $k ( keys %$notifs ) {
                delete $notifs->{$k}
                  unless ( $notifs->{$k}->{$field} =~ $value );
            }
        }
    }

    if ( my $groupBy = $req->params('groupBy') ) {
        my ( $length, $start, $r ) = ( 0, 0 );
        if ( $groupBy =~ /^substr\((\w+)(?:,(\d+)(?:,(\d+))?)?\)$/ ) {
            ( $groupBy, $length, $start ) = ( $1, $2, $3 );
            $start ||= 0;
            $length = 1 if ( $length < 1 );
        }
        foreach my $k ( keys %$notifs ) {
            my $s =
              $length
              ? substr( $notifs->{$k}->{$groupBy}, $start, $length )
              : $notifs->{$k}->{$groupBy};
            $r->{$s}++;
        }
        my $count = 0;
        $res = [
            map { $count += $r->{$_}; { value => $_, count => $r->{$_} } }
            sort keys %$r
        ];
        return $self->sendJSONresponse(
            $req,
            {
                result => 1,
                count  => $count,
                values => $res,
            }
        );
    }
    else {
        my @r = map {
            my $r = { notification => $_ };
            foreach my $k (qw(uid date condition)) {
                $r->{$k} = $notifs->{$_}->{$k};
            }
            $r->{reference} = $notifs->{$_}->{ref};
            $r;
        } keys %$notifs;

        if ( my $orderBy = $req->params('orderBy') ) {
            my @fields = split /,/, $orderBy;
            while ( my $f = pop @fields ) {
                @r = sort { $a->{$f} cmp $b->{$f} } @r;
            }
        }
        return $self->sendJSONresponse( $req,
            { result => 1, count => scalar(@r), values => \@r } );
    }
}

sub notification {
    my ( $self, $req, $id, $type ) = splice @_;

    if ( $type eq 'actives' ) {
        my ( $uid, $ref ) = ( $id =~ /([^_]+?)_(.+)/ );
        my $n = $self->notifAccess->_get( $uid, $ref );
        unless ($n) {
            $self->lmLog( "Notification $ref not found for user $uid",
                'notice' );
            return $self->sendJSONresponse(
                $req,
                {
                    result => 0,
                    error  => "Notification $ref not found for user $uid"
                }
            );
        }
        return $self->sendJSONresponse( $req,
            { result => 1, count => 1, notifications => [ values $n ] } );
    }
    else {
        return $self->sendJSONresponse( $req,
            { result => 1, count => 1, done => $id } );
    }
}

sub newNotification {
    my ( $self, $req, @other ) = splice @_;
    return $self->sendError( $req,
        'There is no subkey for "newNotification"', 400 )
      if (@other);

    my $json = $req->jsonBodyToObj;
    unless ( defined($json) ) {
        return $self->sendError( $req, undef, 400 );
    }

    foreach my $r (qw(uid date reference xml)) {
        return $self->sendError( $req, "Missing $r", 400 )
          unless ( $json->{$r} );
    }

    unless ( $json->{date} =~ /^\d{4}-\d{2}-\d{2}$/ ) {
        return $self->sendError( $req, "Malformed date", 400 );
    }
    my $newNotif = qq#<?xml version='1.0' encoding='UTF-8' standalone='no'?>
<root><notification #
      . join(
        ' ',
        map {
            if ( my $t = $json->{$_} ) { $t =~ s/"/'/g; qq#$_="$t"# }
            else                       { () }
        } (qw(uid date reference condition))
      ) . ">$json->{xml}</notification></root>";

    unless ( eval { $self->notifAccess->newNotification($newNotif) } ) {
        $self->lmLog(
"Notification not created: $@$Lemonldap::NG::Common::Notification::msg",
            'error'
        );
        return $self->sendError( $req, "Notification not created", 400 );
    }
    else {
        return $self->sendJSONresponse( $req, { result => 1 } );
    }
}

sub updateNotification {
    my ( $self, $req ) = splice @_;

    my $json = $req->jsonBodyToObj;
    unless ( defined($json) ) {
        return $self->sendError( $req, undef, 400 );
    }

    # For now, only "mark as done" is proposed
    unless ( $json->{done} ) {
        return $self->sendError( $req, 'Only "done=1" is accepted for now',
            400 );
    }
    my $id = $req->params('notificationId') or die;
    my ( $uid, $ref ) = ( $id =~ /([^_]+?)_(.+)/ );
    my ( $n, $res );
    unless ( $n = $self->notifAccess->_get( $uid, $ref ) ) {
        $self->lmLog( "Notification $ref not found for user $uid", 'notice' );
        return $self->sendError( $req,
            "Notification $ref not found for user $uid" );
    }

    # Delete notifications
    my $status = 1;
    foreach ( keys %$n ) {
        $status = 0 unless ( $self->notifAccess->_delete($_) );
    }

    unless ($status) {
        $self->lmLog( "Notification $ref for user $uid not deleted", 'error' );
        return $self->sendError( $req,
            "Notification $ref for user $uid not deleted" );
    }

    else {
        $self->lmLog( "Notification $ref deleted for user $uid", 'info' );
        return $self->sendJSONresponse( $req, { result => 1 } );
    }
}

sub deleteDoneNotification {
    my ( $self, $req ) = splice @_;
    my $res;

    # Purge notification
    my $id = $req->params('notificationId') or die;
    unless ( $self->notifAccess->purge($id) ) {
        $self->lmLog(
            "Notification $id not purged ($Lemonldap::NG::Common::Conf::msg)",
            'warn' );
        return $self->sendError( $req,
            "Notification $id not purged ($Lemonldap::NG::Common::Conf::msg)",
            400 );
    }

    $self->lmLog( "Notification $id purged", 'info' );
    return $self->sendJSONresponse( $req, { result => 1 } );
}

1;

