package Lemonldap::NG::Common::Notifications::XML;

use strict;
use Mouse;
use XML::LibXML;

# XML parser
has parser => (
    is      => 'rw',
    builder => sub {
        return XML::LibXML->new();
    }
);

# Check XML datas and insert new notifications.
# @param $xml XML string containing notification
# @return number of notifications done
sub newNotification {
    my ( $self, $xml ) = @_;
    eval { $xml = $self->parser->parse_string($xml) };
    if ( my $err = $@ ) {
        eval { $self->lmLog( "Unable to read XML file : $err", 'error' ) };
        return 0;
    }
    my @notifs;
    my ( $version, $encoding ) = ( $xml->version(), $xml->encoding() );
    foreach
      my $notif ( $xml->documentElement->getElementsByTagName('notification') )
    {
        my @datas = ();

        # Mandatory information
        foreach (qw(date uid reference)) {
            my $tmp;
            unless ( $tmp = $notif->getAttribute($_) ) {
                $self->lmLog( "Attribute $_ is missing", 'error' );
                return 0;
            }
            push @datas, $tmp;
        }

        # Other information
        foreach (qw(condition)) {
            my $tmp;
            if ( $tmp = $notif->getAttribute($_) ) {
                push @datas, $tmp;
            }
            else { push @datas, ""; }
        }

        my $result = XML::LibXML::Document->new( $version, $encoding );
        my $root = XML::LibXML::Element->new('root');
        $root->appendChild($notif);
        $result->setDocumentElement($root);
        $result = $result->serialize;
        utf8::encode($result);
        push @notifs, [ @datas, $result ];
    }
    my $count;
    foreach (@notifs) {
        $count++;
        my ( $r, $err ) = $self->newNotif(@$_);
        die "$err" unless ($r);
    }
    return $count;
}

## Delete notifications for the connected user
## @param $uid of the user
## @param $myref notification's reference
## @return number of deleted notifications
sub deleteNotification {
    my ( $self, $uid, $myref ) = @_;
    my @data;

    # Check input parameters
    unless ( $uid and $myref ) {
        $self->lmLog(
            "SOAP service deleteNotification called without all parameters",
            'error' );
        return 0;
    }

    $self->lmLog(
"SOAP service deleteNotification called for uid $uid and reference $myref",
        'debug'
    );

    # Get notifications
    my $user = $self->get($uid);

    # Return 0 if no files were found
    return 0 unless ($user);

    # Counting
    my $count = 0;

    foreach my $ref ( keys %$user ) {
        my $xml = $self->parser->parse_string( $user->{$ref} );

        # Browse notification in file
        foreach my $notif (
            $xml->documentElement->getElementsByTagName('notification') )
        {

            # Get notification's data
            if ( $notif->getAttribute('reference') eq $myref ) {
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
