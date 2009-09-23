## @file
# Relay authentication module

## @class
# Relay authentication module: It simply call another Lemonldap::NG portal by
# SOAP using credentials
package Lemonldap::NG::Portal::AuthRelay;

use strict;
use Lemonldap::NG::Portal::_Relay;
use Lemonldap::NG::Portal::_WebForm;
use Lemonldap::NG::Portal::Simple;
use base qw(Lemonldap::NG::Portal::_WebForm Lemonldap::NG::Portal::_Relay);

our $VERSION = '0.1';

## @apmethod int authInit()
# Call Lemonldap::NG::Portal::_Relay::relayInit();
# @return Lemonldap::NG::Portal constant
*authInit = *Lemonldap::NG::Portal::_Relay::relayInit;

## @apmethod int authenticate()
# Call Lemonldap::NG::Portal::_Relay::relayQuery()
# @return Lemonldap::NG::Portal constant
*authenticate = *Lemonldap::NG::Portal::_Relay::relayQuery;

## @apmethod int setAuthSessionInfo()
# Call Lemonldap::NG::Portal::_Relay::setSessionInfo()
# @return Lemonldap::NG::Portal constant
*setAuthSessionInfo = *Lemonldap::NG::Portal::_Relay::setSessionInfo;

1;

__END__

=head1 NAME

Lemonldap::NG::Portal::AuthRelay - Authentication module for Lemonldap::NG
that delegates authentication to a remote Lemonldap::NG portal.

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::Simple;
  my $portal = new Lemonldap::NG::Portal::Simple(
         
         # AUTHENTICATION PART
         authentication      => 'Relay', 
    );

=head1 DESCRIPTION

Authentication module for Lemonldap::NG portal that forward credentials to a
remote portal using SOAP.

=head1 SEE ALSO

L<http://lemonldap.objectweb.org/>
L<http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/AuthRelay>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
