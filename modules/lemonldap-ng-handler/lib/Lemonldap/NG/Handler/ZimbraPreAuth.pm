##@file
# Zimbra preauthentication

##@class
# Zimbra preauthentication
#
# It will build Zimbra preauth URL
package Lemonldap::NG::Handler::ZimbraPreAuth;

use strict;
use Lemonldap::NG::Handler::SharedConf qw(:all);
our @ISA = qw(Lemonldap::NG::Handler::SharedConf);
use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);

our $VERSION = '0.1';

# @method run()
# Overload main run method
# return Apache error code
sub run {
    my $class = shift;
    my $r     = $_[0];
    my $ret   = $class->SUPER::run(@_);

    # Continue only if user is authorized
    return $ret unless $ret eq OK;

    # Get configuration parameters
    my $ZimbraPreAuthKey = $r->dir_config('ZimbraPreAuthKey');
    my $ZimbraAccountKey = $r->dir_config('ZimbraAccountKey') || "uid";
    my $ZimbraBy         = $r->dir_config('ZimbraBy') || "id";
    my $ZimbraUrl        = $r->dir_config('ZimbraUrl');

    unless ( $ZimbraPreAuthKey and $ZimbraUrl ) {
        $class->lmLog( "No preauth key or URL configured", 'error' );
        return SERVER_ERROR;
    }

    # Other values
    my $ZimbraAccount   = $datas->{$ZimbraAccountKey};
    my $ZimbraExpires   = 0;
    my $ZimbraTimestamp = gmtime() * 1000;

    # Compute preauth value
    my $ZimbraComputedValue =
      hmac_sha1_hex( "$ZimbraAccount|$ZimbraBy|$ZimbraExpires|$ZimbraTimestamp",
        $ZimbraPreAuthKey );

    # Build PreAuth URL
    my $zimbra_url;
    $zimbra_url .= $ZimbraUrl;
    $zimbra_url .= '?account=' . $ZimbraAccount;
    $zimbra_url .= '&by=' . $ZimbraBy;
    $zimbra_url .= '&expires=' . $ZimbraExpires;
    $zimbra_url .= '&preauth=' . $ZimbraComputedValue;

    $class->lmLog( "Build Zimbra URL $zimbra_url", 'debug' );

    # Header location
    lmSetHeaderOut( $r, 'Location' => $zimbra_url );

    # Return REDIRECT
    return REDIRECT;
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Handler::ZimbraPreAuth - Perl extension to generate Zimbra preauth URL
for users authenticated by Lemonldap::NG

=head1 SYNOPSIS

  package My::Zimbra;
  use Lemonldap::NG::Handler::ZimbraPreAuth;
  @ISA = qw(Lemonldap::NG::Handler::ZimbraPreAuth);

  __PACKAGE__->init ( {
    # See Lemonldap::NG::Handler for more
  } );
  1;

=head1 DESCRIPTION

Edit you Zimbra vhost configuration like this to catch a specific SSO URL

<VirtualHost *>
	ServerName zimbra.example.com

	# Default Handler
	PerlRequire __HANDLERDIR__/MyHandler.pm
	PerlHeaderParserHandler My::Zimbra

	# Load Zimbra Handler
	PerlRequire __HANDLERDIR__/MyHandlerZimbra.pm

	# Zimbra SSO URL
	<Location /zimbrasso>

		PerlSetVar ZimbraPreAuthKey XXXX
		PerlSetVar ZimbraAccountKey uid
		PerlSetVar ZimbraBy id
		PerlSetVar ZimbraUrl /service/preauth

		PerlHeaderParserHandler My::Zimbra

	</Location>

</VirtualHost>

=head2 EXPORT

See L<Lemonldap::NG::Handler>

=head1 SEE ALSO

L<Lemonldap::NG::Handler>

=head1 AUTHOR

Clement Oudot, E<lt>clement@oodo.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 201O by Clement Oudot

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
