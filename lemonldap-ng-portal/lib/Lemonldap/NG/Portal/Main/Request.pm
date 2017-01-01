package Lemonldap::NG::Portal::Main::Request;

# Developpers, be careful: new() is never called so default values will not be
# taken in account (see Portal::Run::handler()): set default values in init()

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants ':all';

extends 'Lemonldap::NG::Common::PSGI::Request';

# List of methods to call
has steps => ( is => 'rw' );

# Datas shared between methods
has datas => ( is => 'rw' );

# Session datas when created
has id          => ( is => 'rw' );
has sessionInfo => ( is => 'rw' );
has user        => ( is => 'rw' );

# Response cookies (list of strings built by cookie())
has respCookies => ( is => 'rw' );

# Embedded response
has response => ( is => 'rw' );

# Template to display (if not defined, login or menu)
has template => ( is => 'rw' );

# Custom template parameters
has customParameters => ( is => 'rw' );

# Boolean to indicate that response must be a redirection
has mustRedirect => ( is => 'rw' );

# Store URL for redirections
has urldc                  => ( is => 'rw' );
has postUrl                => ( is => 'rw' );
has postFields             => ( is => 'rw' );
has portalHiddenFormValues => ( is => 'rw' );

# Flag that permit to a auth module to return PE_OK without setting $user
has continue => ( is => 'rw' );

# "check logins "flag"
has checkLogins => ( is => 'rw' );

# Boolean to indicate that url isn't Base64 encoded
has urlNotBase64 => ( is => 'rw' );

# Menu error
has menuError => ( is => 'rw' );

# Error type
sub error_type {
    my $req = shift;
    my $code = shift || $req->error;

    # Positive errors
    return "positive"
      if (
        scalar(
            grep { /^$code$/ } (
                PE_REDIRECT,        PE_DONE,
                PE_OK,              PE_PASSWORD_OK,
                PE_MAILOK,          PE_LOGOUT_OK,
                PE_MAILFIRSTACCESS, PE_PASSWORDFIRSTACCESS,
                PE_MAILCONFIRMOK,   PE_REGISTERFIRSTACCESS,
            )
        )
      );

    # Warning errors
    return "warning"
      if (
        scalar(
            grep { /^$code$/ } (
                PE_INFO,                          PE_SESSIONEXPIRED,
                PE_FORMEMPTY,                     PE_FIRSTACCESS,
                PE_PP_GRACE,                      PE_PP_EXP_WARNING,
                PE_NOTIFICATION,                  PE_BADURL,
                PE_CONFIRM,                       PE_MAILFORMEMPTY,
                PE_MAILCONFIRMATION_ALREADY_SENT, PE_PASSWORDFORMEMPTY,
                PE_CAPTCHAEMPTY,                  PE_REGISTERFORMEMPTY,
            )
        )
      );

    # Negative errors (default)
    return "negative";

    #TODO
}

sub init {
    my ($self) = @_;
    $self->{$_} = {} foreach (qw(datas customParameters sessionInfo));
    $self->{$_} = [] foreach (qw(respCookies));
}

sub errorString {
    print STDERR "TODO Request::errorString()\n";
}

sub loginInfo {
    print STDERR "TODO Request::loginInfo()\n";
}

sub info {
    my ( $self, $info ) = @_;
    $self->datas->{_info} .= $info if ( defined $info );
    return $self->datas->{_info};
}

# TODO: oldpassword
1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::Main::Request - HTTP request object used in LLNG
portal methods.

=head1 SYNOPSIS

  # Somewhere in a plugin...
  sub run {
      my ( $self, $req ) = @_;
      # $req is a Lemonldap::NG::Portal::Main::Request object
      ...
  }

=head1 DESCRIPTION

Lemonldap::NG::Portal::Main::Request extends Lemonldap::NG::Common::PSGI::Request
to add all parameters needed to manage portal jobs.

=head1 METHODS

=head2 Accessors

=head3 steps()

Stack of methods to call for this requests. It can be modified to change
authentication process

=head3 datas()

Free hash ref where plugins can store their datas. Using it is a LLNG best
practice

=head3 User information

=head4 id()

Session id (main cookie value).

=head4 sessionInfo()

Hash ref that will be stored in session DB.

=head4 user()

Username given by authentication module, used by userDB module.

=head3 mustRedirect()

Boolean to indicate that response must be a redirection (used for example when
request is a POST).

=head3 urlNotBase64

Boolean to indicate that url isn't Base64 encoded.

=head2 Other methods

=head3 info()

Store info to display in response.

=head3 menuError()

=head3 notification()

see notification plugin.

=head3 errorType()

Returns positive/warning/negative depending on value stored in error property.

=head1 SEE ALSO

L<http://lemonldap-ng.org/>, L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Handler>,
L<Plack>, L<PSGI>, L<Lemonldap::NG::Common::PSGI>,
L<Lemonldap::NG::Common::PSGI::Router>, L<HTML::Template>, 

=head1 AUTHORS

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Thomas Chemineau, E<lt>thomas.chemineau@gmail.comE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2015-2016 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Copyright (C) 2015-2016 by Clément Oudot, E<lt>clem.oudot@gmail.comE<gt>

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
