##@file
# Notification system for Lemonldap::NG portal

##@class
# Notification system for Lemonldap::NG portal
package Lemonldap::NG::Portal::Notification;

use strict;
use utf8;
use Lemonldap::NG::Portal::SharedConf;
use XML::LibXML;
use XML::LibXSLT;
use CGI::Cookie;
use MIME::Base64;

our $VERSION = '0.01';
our ( $msg, $stylesheet, $parser, $self );

BEGIN {
    my $xslt = XML::LibXSLT->new();
    $parser = XML::LibXML->new();
    my $style_doc = $parser->parse_string(
        q#<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <xsl:output method="html"
             encoding="UTF-8"/>
 <xsl:param name="start"/>
 <xsl:template match="/root/notification">
  <xsl:variable name="level" select="position()"/>
  <xsl:element name="input">
   <xsl:attribute name="type">hidden</xsl:attribute>
     <xsl:attribute name="name">reference<xsl:value-of select="$start"/>x<xsl:value-of select="$level"/></xsl:attribute>
   <xsl:attribute name="value"><xsl:value-of select="@reference"/></xsl:attribute>
  </xsl:element>
  <xsl:for-each select="text">
  <p class="notifText"><xsl:value-of select="."/></p>
  </xsl:for-each>
  <xsl:for-each select="check">
   <xsl:variable name="sublevel" select="position()"/>
   <p class="notifCheck">
    <xsl:element name="input">
     <xsl:attribute name="type">checkbox</xsl:attribute>
     <xsl:attribute name="name">check<xsl:value-of select="$start"/>x<xsl:value-of select="$level"/>x<xsl:value-of select="$sublevel"/></xsl:attribute>
     <xsl:attribute name="id">check<xsl:value-of select="$start"/>x<xsl:value-of select="$level"/>x<xsl:value-of select="$sublevel"/></xsl:attribute>
    </xsl:element>
    <xsl:value-of select="."/>
   </p>
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
#
    );
    $stylesheet = $xslt->parse_stylesheet($style_doc);
}

## @cmethod Lemonldap::NG::Portal::Notification new(Lemonldap::NG::Common::Conf storage)
# Constructor.
# @param storage Lemonldap::NG::Common::Conf object
# @return Lemonldap::NG::Portal::Notification object
sub new {
    my ( $class, $storage ) = @_;
    $self = bless {}, $class;
    (%$self) = (%$storage);
    $self->{type} = "Lemonldap::NG::Common::Conf::$self->{type}"
      unless $self->{type} =~ /^Lemonldap::/;
    if ( $self->{type} eq 'Lemonldap::NG::Common::Conf::DBI' ) {
        $self->{dbiTable} = $self->{table};
    }
    elsif ( $self->{type} eq 'Lemonldap::NG::Common::Conf::File' ) {
        $self->{dirName} =~ s/\/conf\/?$//;
        $self->{dirName} .= "/$self->{table}";
    }
    else {
        my $tmp = $self->{type};
        $tmp =~ s/.*:://;
        $msg = "Error : $self->{type} is not supported for notifications !";
        return 0;
    }
    eval "require $self->{type}";
    if ($@) {
        $msg = "Error: Unknown package $self->{type}";
        return 0;
    }
    unless ( $self->prereq ) {
        $msg = $Lemonldap::NG::Common::Conf::msg;
        return 0;
    }
    return $self;
}

## @method string getNotification(Lemonldap::NG::Portal portal)
# Check if notification(s) are available for the connected user.
# If it is, encrypt cookies and generate HTML form content.
# @param $portal Lemonldap::NG::Portal object that call
# @return HTML fragment containing form content
sub getNotification {
    my ( $self, $portal ) = @_;
    my ( @notifs, $form );
    my $tmp = $self->{type};
    $tmp =~ s/.*:://;
    $tmp = "get" . $tmp;
    my $uid = $portal->{notificationField} || $portal->{whatToTrace} || 'uid';
    $uid =~ s/\$//g;
    $uid = $portal->{sessionInfo}->{$uid};
    my $n = $self->$tmp($uid);
    return 0 unless ($n);
    @notifs = map { $n->{$_} } sort keys %$n;
    my $i = 0;

    foreach my $notif (@notifs) {
        $i++;
        eval {
            my $xml = $parser->parse_string($notif);
            my $results = $stylesheet->transform( $xml, start => $i );
            $form .= $stylesheet->output_string($results);
        };
        if ($@) {
            print STDERR
              "Bad XML file: a notification for $uid was not done ($@)\n";
            return 0;
        }
    }

    # Now a notification has to be done. Replace cookies by hidden fields
    my $i = 0;
    while ( $tmp = shift @{ $portal->{cookie} } ) {
        $i++;
        my $t = $portal->{cipher}->encrypt( $tmp->value );
        unless ( defined($t) ) {
            print STDERR
"Notification for $uid was not done : $Lemonldap::NG::Common::Crypto::msg\n";
            return 0;
        }
        $tmp->value($t);
        $form .= qq{<input type="hidden" id="cookie$i" name="cookie$i" value="}
          . $tmp->as_string . '" />';
    }
    $form .=
        '<input type="hidden" name="type" value="notification"/>'
      . '<input type="hidden" name="url" value="'
      . $portal->param('url') . '" />';
    return $form;
}

## @method boolean checkNotification(Lemonldap::NG::Portal portal)
# Check if notifications have been displayed and accepted.
# @param $portal Lemonldap::NG::Portal object that call
# @return true if all checkboxes have been checked
sub checkNotification {
    my ( $self, $portal ) = @_;
    my ( $refs, $checks );

    # First, rebuild environment (cookies,...)
    foreach ( $portal->param() ) {
        if (/^cookie/) {
            my @tmp   = split /(?:=|;\s+)/, $portal->param($_);
            my %tmp   = @tmp;
            my $value = $portal->{cipher}->decrypt( $tmp[1] );
            unless ( defined($value) ) {
                print STDERR "$Lemonldap::NG::Common::Crypto::msg\n";
                return 0;
            }
            push @{ $portal->{cookie} },
              $portal->cookie(
                -name   => $tmp[0],
                -value  => $value,
                -domain => $tmp{domain},
                -path   => "/",
                -secure => ( grep( /^secure$/, @tmp ) ? 1 : 0 ),
                @_,
              );
            if ( $tmp[0] eq $portal->{cookieName} ) {
                my $tmp = $portal->{existingSession};
                $portal->{existingSession} = sub { 0 };
                $portal->controlExistingSession($value);
                $portal->{existingSession} = $tmp;
            }
        }
        elsif (s/^reference//) {
            $refs->{$_} = $portal->param("reference$_");
        }
        elsif ( s/^check// and /^(\d+x\d+)x(\d+)$/ ) {
            push @{ $checks->{$1} }, $2;
        }
    }
    $portal->controlExistingSession() unless ( $portal->{sessionInfo} );
    unless ( $portal->{sessionInfo} ) {
        print STDERR "Invalid session\n";
        return 0;
    }
    my $result = 1;
    foreach my $ref ( keys %$refs ) {
        my $uid =
             $portal->{notificationField}
          || $portal->{whatToTrace}
          || 'uid';
        $uid =~ s/\$//g;
        $uid = $portal->{sessionInfo}->{$uid};
        my $get = $self->{type};
        $get =~ s/.*:://;
        my $delete = "delete$get";
        $get = "get$get";
        my $files = $self->$get( $uid, $refs->{$ref} );

        unless ($files) {
            print STDERR "Can find notification $refs->{$ref} for $uid\n";
            next;
        }
        foreach my $file ( keys %$files ) {
            my $xml;
            eval { $xml = $parser->parse_string( $files->{$file} ) };
            if ($@) {
                print STDERR "Bad XML notification for $uid";
                next;
            }
            foreach my $notif (
                $xml->documentElement->getElementsByTagName('notification') )
            {
                my $reference  = $notif->getAttribute('reference');
                my @tmp        = $notif->getElementsByTagName('check');
                my $checkCount = @tmp;
                if ( $checkCount == 0
                    or
                    ( $checks->{$ref} and $checkCount == @{ $checks->{$ref} } )
                  )
                {
                    if ( $self->$delete($file) ) {
                        print STDERR
                          "$uid has accepted notification $refs->{$ref}\n";
                    }
                    else {
                        print STDERR
"Unable to delete notification $refs->{$ref} for $uid\n";
                    }
                }
                else {
                    print STDERR
                      "$uid has not accepted notification $refs->{$ref}\n";
                    $result = 0;
                }
            }
        }
    }
    return $result;
}

## @method int newNotification(string xml)
# Check XML datas and insert new notifications.
# @param $xml XML string containing notification
# @return number of notifications done
sub newNotification {
    my ( $class, $xml ) = @_;
    eval { $xml = $parser->parse_string($xml); };
    if ($@) {
        die "Unable to read XML file : $@\n";
    }
    my @notifs;
    my ( $version, $encoding ) = ( $xml->version(), $xml->encoding() );
    foreach
      my $notif ( $xml->documentElement->getElementsByTagName('notification') )
    {
        my @datas = ();
        foreach (qw(date uid reference)) {
            my $tmp;
            unless ( $tmp = $notif->getAttribute($_) ) {
                die "Attribute $_ is missing\n";
            }
            push @datas, $tmp;
        }
        my $result = XML::LibXML::Document->new( $version, $encoding );
        my $root = XML::LibXML::Element->new('root');
        $root->appendChild($notif);
        $result->setDocumentElement($root);
        push @notifs, [ @datas, $result ];
    }
    my $tmp = $self->{type};
    $tmp =~ s/.*:://;
    $tmp = "newNotif" . $tmp;
    my $count;
    foreach (@notifs) {
        $count++;
        my ( $r, $err ) = $self->$tmp(@$_);
        die "Error in notification $_->[2] for $_->[1] : $err" unless ($r);
    }
    return $count;
}

## @method protected array getFile(string uid,string ref)
# In file context, returns notifications corresponding to the user $uid.
# If $ref is set, returns only notification corresponding to this reference.
# @param $uid UID
# @param $ref Notification reference
# @return Array of XML strings
sub getFile {
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
            print STDERR "Unable to read notification $self->{dirName}/$_\n";
            next;
        }
        my $ind = 0;
        $files->{$file} = join( '', <F> );
    }
    return $files;
}

sub deleteFile {
    my ( $self, $file ) = @_;
    my $new = ( $file =~ /(.*?)(?:\.xml)$/ )[0] . '.done';
    return rename( $self->{dirName} . "/$file", $self->{dirName} . "/$new" );
}

sub newNotifFile {
    my ( $class, $date, $uid, $ref, $xml ) = @_;
    $date =~ s/-//g;
    return ( 0, "Bad date" ) unless ( $date =~ /^\d{8}/ );
    my $filename =
        $self->{dirName}
      . "/${date}_${uid}_"
      . encode_base64( $ref, '' ) . ".xml";
    return ( 0, 'This notification still exists' ) if ( -e $filename );
    my $old = ( $filename =~ /(.*?)(?:\.xml)$/ )[0] . '.done';
    return ( 0, 'This notification has been done' ) if ( -e $filename );
    open my $F, ">$filename" or return ( 0, "Unable to create $filename ($!)" );
    binmode($F);
    $xml->toFH($F);
    return ( 0, "Unable to close $filename ($!)" ) unless ( close $F );
    return 1;
}

sub prereq {
    no strict 'refs';
    return &{ $_[0]->{type} . '::prereq' }(@_);
}

1;

__END__

=head1 NAME

Lemonldap::NG::Portal::Notification - Provides notification messages system.

=head1 SYNOPSIS

    use Lemonldap::NG::Portal;

=head1 DESCRIPTION

Lemonldap::NG::Portal::Notification.

=head1 SEE ALSO

L<Lemonldap::NG::Portal>,

=head1 AUTHOR

Xavier Guimard E<lt>x.guimard@free.frE<gt>

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://forge.objectweb.org/tracker/?group_id=274>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005-2007 by Xavier Guimard E<lt>x.guimard@free.frE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut


