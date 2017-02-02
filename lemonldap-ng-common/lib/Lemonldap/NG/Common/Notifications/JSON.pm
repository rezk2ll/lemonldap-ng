package Lemonldap::NG::Common::Notifications::JSON;

use strict;
use Mouse;
use JSON qw(from_json to_json);

sub newNotification {
    my ( $self, $jsonString ) = @_;
    my $json;
    eval { $json = from_json($jsonString) };
    if ( my $err = $@ ) {
        eval { $self->lmLog( "Unable to decode JSON file: $err", 'error' ) };
        return 0;
    }
    my @notifs;
    $json = [$json] unless ( ref($json) eq 'ARRAY' );
    foreach my $notif (@$json) {
        my @datas;

        # Mandatory information
        foreach (qw(date uid reference)) {
            my $tmp;
            unless ( $tmp = $notif->{$_} ) {
                $self->lmLog( "Attribute $_ is missing", 'error' );
                return 0;
            }
            push @datas, $tmp;
        }
        push @datas, ( $notif->{condition} // '' );
        push @notifs, [ @datas, $jsonString ];
    }
    my $count;
    foreach (@notifs) {
        $count++;
        my ( $r, $err ) = $self->newNotif(@$_);
        die "$err" unless ($r);
    }
    return $count;
}

sub deleteNotification {
    my ( $self, $uid, $myref ) = @_;
    my @data;

    # Check input parameters
    unless ( $uid and $myref ) {
        $self->lmLog(
            'REST service "delete notification" called without all parameters',
            'error'
        );
        return 0;
    }

    $self->lmLog(
"REST service deleteNotification called for uid $uid and reference $myref",
        'debug'
    );

    # Get notifications
    my $user = $self->get($uid);

    # Return 0 if no files were found
    return 0 unless ($user);

    # Counting
    my $count = 0;

    foreach my $ref ( keys %$user ) {
        my $json = from_json( $user->{$ref} );

        # Browse notification in file
        foreach my $notif (@$json) {

            # Get notification's data
            if ( $notif->{reference} eq $myref ) {
                push @data, $ref;
            }

            # Delete the notification (really)
            foreach (@data) {
                if ( $self->purge( $_, 1 ) ) {
                    $self->lmLog( "Notification $_ was removed.", 'debug' );
                    $count++;
                }
            }
        }
    }
    return $count;
}

1;
