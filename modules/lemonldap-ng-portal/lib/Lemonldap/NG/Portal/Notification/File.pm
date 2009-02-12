## @file
# File storage methods for notifications

## @class
# File storage methods for notifications
package Lemonldap::NG::Portal::Notification::File;

use strict;

use MIME::Base64;

## @method boolean prereq()
# Check if parameters are set and if storage directory exists.
# @return true if all is OK
sub prereq {
    my $self = shift;
    unless ( $self->{dirName} ) {
        $Lemonldap::NG::Portal::Notification::msg =
          '"dirName" is required in "File" configuration type !';
        return 0;
    }
    if ( $self->{table} ) {
        $self->{dirName} =~ s/\/conf\/?$//;
        $self->{dirName} .= "/$self->{table}";
    }
    unless ( -d $self->{dirName} ) {
        $Lemonldap::NG::Portal::Notification::msg =
          "Directory \"$self->{dirName}\" does not exist !";
        return 0;
    }
    1;
}

## @method hashref get(string uid,string ref)
# In file context, returns notifications corresponding to the user $uid.
# If $ref is set, returns only notification corresponding to this reference.
# @param $uid UID
# @param $ref Notification reference
# @return hashref where keys are filenames and values are XML strings
sub get {
    my ( $self, $uid, $ref ) = @_;
    return () unless ($uid);
    opendir D, $self->{dirName};
    my @notif;
    unless ($ref) {
        @notif = grep /^\d{8}_${uid}_\S*\.xml$/, readdir(D);
    }
    else {
        my $tmp = encode_base64( $ref, '' );
        @notif = grep /^\d{8}_${uid}_$tmp.xml$/, readdir(D);
    }
    close D;
    my $files;
    foreach my $file (@notif) {
        unless ( open F, $self->{dirName} . "/$file" ) {
            $self->lmLog( "Unable to read notification $self->{dirName}/$_",
                'error' );
            next;
        }
        $files->{$file} = join( '', <F> );
    }
    return $files;
}

## @method boolean delete(string myref)
# Mark a notification as done.
# @param $file identifier returned by get
sub delete {
    my ( $self, $file ) = @_;
    my $new = ( $file =~ /(.*?)(?:\.xml)$/ )[0] . '.done';
    return rename( $self->{dirName} . "/$file", $self->{dirName} . "/$new" );
}

## @method boolean newNotif(string date, string uid, string ref, string xml)
# Insert a new notification
# @param date Date
# @param uid UID
# @param ref Reference of the notification
# @param xml XML notification
# @return true if succeed
sub newNotif {
    my ( $self, $date, $uid, $ref, $xml ) = @_;
    $date =~ s/-//g;
    return ( 0, "Bad date" ) unless ( $date =~ /^\d{8}/ );
    my $filename =
        $self->{dirName}
      . "/${date}_${uid}_"
      . encode_base64( $ref, '' ) . ".xml";
    return ( 0, 'This notification still exists' ) if ( -e $filename );
    my $old = ( $filename =~ /(.*?)(?:\.xml)$/ )[0] . '.done';
    return ( 0, 'This notification has been done' ) if ( -e $old );
    open my $F, ">$filename" or return ( 0, "Unable to create $filename ($!)" );
    binmode($F);
    $xml->toFH($F);
    return ( 0, "Unable to close $filename ($!)" ) unless ( close $F );
    return 1;
}

1;

