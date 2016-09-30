# Auth-basic authentication with Lemonldap::NG rights management

# This specific handler is intended to be called directly by Apache

package Lemonldap::NG::Handler::AuthBasic;

use Lemonldap::NG::Handler::ApacheMP2;
use Lemonldap::NG::Handler::Lib::AuthBasic;

@ISA = ('Lemonldap::NG::Handler::ApacheMP2');

our $VERSION = '2.0.0';

# PUBLIC METHODS

sub handler {
    my $class;
    $class = $#_ ? shift : __PACKAGE__;
    my ($res) = $class->run(@_);
    return $res;
}

die unless __PACKAGE__->can('retrieveSession');

__PACKAGE__->init();

*_lmLog             = *Lemonldap::NG::Handler::ApacheMP2::_lmLog;
*args               = *Lemonldap::NG::Handler::ApacheMP2::args;
*get_server_port    = *Lemonldap::NG::Handler::ApacheMP2::get_server_port;
*header_in          = *Lemonldap::NG::Handler::ApacheMP2::header_in;
*hostname           = *Lemonldap::NG::Handler::ApacheMP2::hostname;
*is_initial_req     = *Lemonldap::NG::Handler::ApacheMP2::is_initial_req;
*method             = *Lemonldap::NG::Handler::ApacheMP2::method;
*print              = *Lemonldap::NG::Handler::ApacheMP2::print;
*remote_ip          = *Lemonldap::NG::Handler::ApacheMP2::remote_ip;
*set_header_in      = *Lemonldap::NG::Handler::ApacheMP2::set_header_in;
*set_header_out     = *Lemonldap::NG::Handler::ApacheMP2::set_header_out;
*set_user           = *Lemonldap::NG::Handler::ApacheMP2::set_user;
*setServerSignature = *Lemonldap::NG::Handler::ApacheMP2::setServerSignature;
*unparsed_uri       = *Lemonldap::NG::Handler::ApacheMP2::unparsed_uri;
*unset_header_in    = *Lemonldap::NG::Handler::ApacheMP2::unset_header_in;
*uri                = *Lemonldap::NG::Handler::ApacheMP2::uri;
*uri_with_args      = *Lemonldap::NG::Handler::ApacheMP2::uri_with_args;
*unparsed_uri       = *Lemonldap::NG::Handler::ApacheMP2::unparsed_uri;

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Handler::AuthBasic - Perl extension to be able to authenticate
users by basic web system but to use Lemonldap::NG to control authorizations.

=head1 SYNOPSIS

Create your own package:

  package My::Package;
  use Lemonldap::NG::Handler::AuthBasic;
  
  # IMPORTANT ORDER
  our @ISA = qw (Lemonldap::NG::Handler::AuthBasic);
  
  __PACKAGE__->init ( {
    # Local storage used for sessions and configuration
    localStorage        => "Cache::DBFile",
    localStorageOptions => {...},
    # How to get my configuration
    configStorage       => {
        type                => "DBI",
        dbiChain            => "DBI:mysql:database=lemondb;host=$hostname",
        dbiUser             => "lemonldap",
        dbiPassword         => "password",
    }
    # Uncomment this to activate status module
    # status                => 1,
  } );

Call your package in <apache-directory>/conf/httpd.conf

  PerlRequire MyFile
  PerlHeaderParserHandler My::Package

=head1 DESCRIPTION

This library provides a way to use Lemonldap::NG to manage authorizations
without using Lemonldap::NG for authentications. This can be used in conjunction
with a normal Lemonldap::NG installation but to manage non-browser clients.

=head1 SEE ALSO

L<Lemonldap::NG::Handler(3)>,
L<http://lemonldap-ng.org/>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2008-2010 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Copyright (C) 2012-2013 by François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Copyright (C) 2010-2012 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=back

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.

=cut
