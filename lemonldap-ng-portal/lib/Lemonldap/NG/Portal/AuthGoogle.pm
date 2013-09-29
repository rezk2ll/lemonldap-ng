##@file
# Google authentication backend file

##@class
# Google authentication backend class.
# The form must return a google_go field
package Lemonldap::NG::Portal::AuthGoogle;

use strict;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Common::Regexp;
use LWP::UserAgent;
use URI::Escape;
use Cache::FileCache;

use constant AXSPECURL      => 'http://openid.net/srv/ax/1.0';
use constant GOOGLEENDPOINT => 'https://www.google.com/accounts/o8/id';

our $VERSION = '1.3.0';
our $initDone;
our $googleEndPoint;

BEGIN {
    eval {
        require threads::shared;
        threads::shared::share($initDone);
        threads::shared::share($googleEndPoint);
    };
}

## @method string googleEndPoint()
# Return the Google OpenID endpoint given by
# https://www.google.com/accounts/o8/id
# @return string
sub googleEndPoint {
    my $self = shift;

    # Get the Google OpenID endpoint
    unless ($googleEndPoint) {
        my $response =
          $self->ua()->get( GOOGLEENDPOINT, Accept => 'application/xrds+xml' );
        if ( $response->is_success ) {

            # Dirty XML parse
            # (searching for <URI>https://www.google.com/accounts/o8/ud</URI>)
            my $tmp = $response->decoded_content;
            if ( $tmp =~ m#<URI.*?>(\S+)</URI>#i ) {
                $googleEndPoint = $1;
            }
            else {
                $self->lmLog( 'Here is the Google response: '
                      . $response->decoded_content );
                $self->abort('Can\'t find endpoint in Googe response');
            }
        }
        else {
            $self->abort('Can\'t access to Google endpoint');
        }
    }
    return $googleEndPoint;
}

## @method LWP::UserAgent ua()
# @return LWP::UserAgent object
sub ua {
    my $self = shift;
    return $self->{ua} ||= LWP::UserAgent->new();
}

## @method boolean checkGoogleSession()
# Search for claimed_id in persistent sessions DB.
# @return true if sessions was recovered
sub checkGoogleSession {
    my $self = shift;

    # Now User is authenticated, check for datas returned
    ( $self->{_AXNS} ) = map {
            ( /^openid\.ns\.(.*)/ and $self->param($_) eq AXSPECURL )
          ? ($1)
          : ()
    } $self->param();

    my $id = $self->_md5hash( $self->param('openid.claimed_id') );
    my $h  = $self->getPersistentSession($id);
    unless ( $self->{_AXNS} ) {
        if ($h) {
            $self->{user} = $h->{email};
            while ( my ( $k, $v ) = each %$h ) {
                $self->{googleSessionInfo}->{$k} = $v;
            }
        }
    }
    else {
        $self->{user} = $self->param("openid.$self->{_AXNS}.value.email");
        unless ($h) {
            $h = {};
            my %opts = %{ $self->{persistentStorageOptions} };
            $opts{setId} = $id;
            eval { tie %$h, $self->{persistentStorage}, undef, \%opts; };
            if ($@) {
                $self->abort(
"Unable to create persistent session required to use Google backend: $@"
                );
            }
            else {
                $self->lmLog(
                    "Persistent session $h->{_session_id} created to store "
                      . $self->{user}
                      . ' Google shared datas',
                    'debug'
                );
            }
        }
        foreach my $k ( $self->param() ) {
            if ( $k =~ /^openid\.$self->{_AXNS}\.value\.(\w+)$/ ) {
                $self->{googleSessionInfo}->{$1} = $h->{$1} = $self->param($k);
            }
        }
        untie %$h;
    }
    return $self->{user};
}

## @apmethod int authInit()
# @return Lemonldap::NG::Portal constant
sub authInit {
    PE_OK;
}

## @apmethod int extractFormInfo()
# Read username return by Google authentication system.
# @return Lemonldap::NG::Portal constant
sub extractFormInfo {
    my $self = shift;

    # 1. If no openid element has been detected
    my $openid = $self->param('openid.mode');
    my $ax     = '';

    # TODO: direct access to Google page
    return PE_FIRSTACCESS
      unless ( $self->param('google_go') or $openid );

    # 2. Check Google responses
    if ($openid) {
        my $check_url = $self->googleEndPoint() . "?" . join(
            '&',
            map {
                my $val = $self->param($_);
                $val = 'check_authentication' if $_ eq 'openid.mode';
                sprintf '%s=%s', uri_escape_utf8($_), uri_escape_utf8($val);
            } $self->param()
        );

        my $response = $self->ua()->get( $check_url, Accept => 'text/plain' );
        unless ( $response->is_success ) {
            $self->abort('Can\'t verify Google authentication');
        }
        else {
            my %tmp =
              map { my ( $key, $value ) = split /:/, $_, 2; $key => $value }
              split /\n/, $response->decoded_content;
            unless ( $tmp{is_valid} eq 'true' ) {
                return PE_BADCREDENTIALS;
            }

            # Datas are missing, prepare to launch a new request with
            # AX request
            unless ( $self->checkGoogleSession() ) {
                $ax =
                    '&openid.ns.ax='
                  . AXSPECURL
                  . '&openid.ax.mode=fetch_request'
                  . '&openid.ax.type.email=http://axschema.org/contact/email'
                  . '&openid.ax.required=email';
                if ( $self->get_module('user') eq 'Google' ) {
                    my $u;
                    while ( my ( $v, $k ) = each %{ $self->{exportedVars} } ) {
                        next if ( $k eq 'email' );
                        if ( $k =~
                            /^(?:(?:la(?:nguag|stnam)|firstnam)e|country)$/ )
                        {
                            $ax .= ",$k";
                            $u  .= "&openid.ax.type.$k="
                              . {
                                country =>
                                  "http://axschema.org/contact/country/home",
                                firstname =>
                                  "http://axschema.org/namePerson/first",
                                lastname =>
                                  "http://axschema.org/namePerson/last",
                                language => "http://axschema.org/pref/language"
                              }->{$k};
                        }
                        else {
                            $self->lmLog(
                                "Field name: $k is not exported by Google",
                                'warn' );
                        }
                    }
                    $ax .= $u;
                }
            }
            else {
                return PE_OK;
            }
        }
    }

    # 3. Redirect user to Google login page
    my $check_url =
        $self->googleEndPoint()
      . '?openid.mode=checkid_setup'
      . '&openid.ns=http://specs.openid.net/auth/2.0'
      . '&openid.claimed_id=http://specs.openid.net/auth/2.0/identifier_select'
      . '&openid.identity=http://specs.openid.net/auth/2.0/identifier_select'
      . $ax;
    my $sep = '?';
    my $ret = $self->{portal};
    foreach my $v (
        [ $self->{_url},                            "url" ],
        [ $self->param( $self->{authChoiceParam} ), $self->{authChoiceParam} ]
      )
    {
        if ( $v->[0] ) {
            $ret .= "$sep$v->[1]=$v->[0]";
            $sep = '&';
        }
    }
    $check_url .= '&openid.return_to=' . uri_escape_utf8($ret);
    print $self->redirect($check_url);
    $self->quit();
}

## @apmethod int setAuthSessionInfo()
# Set _user and authenticationLevel.
# @return Lemonldap::NG::Portal constant
sub setAuthSessionInfo {
    my $self = shift;

    $self->{sessionInfo}->{'_user'} = $self->{user};

    $self->{sessionInfo}->{authenticationLevel} = $self->{googleAuthnLevel};

    PE_OK;
}

## @apmethod int authenticate()
# Does nothing.
# @return Lemonldap::NG::Portal constant
sub authenticate {
    PE_OK;
}

## @apmethod int authFinish()
# Does nothing.
# @return Lemonldap::NG::Portal constant
sub authFinish {
    PE_OK;
}

## @apmethod int authLogout()
# Does nothing
# @return Lemonldap::NG::Portal constant
sub authLogout {
    PE_OK;
}

## @apmethod boolean authForce()
# Does nothing
# @return result
sub authForce {
    return 0;
}

## @method string getDisplayType
# @return display type
sub getDisplayType {
    return "googleform";
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::AuthGoogle - Perl extension for building Lemonldap::NG
compatible portals with Google authentication.

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::SharedConf;
  my $portal = new Lemonldap::NG::Portal::Simple(
         configStorage     => {...}, # See Lemonldap::NG::Portal
         authentication    => 'Google',
    );

  if($portal->process()) {
    # Write here the menu with CGI methods. This page is displayed ONLY IF
    # the user was not redirected here.
    print $portal->header('text/html; charset=utf8'); # DON'T FORGET THIS (see CGI(3))
    print "...";
  }
  else {
    # If the user enters here, IT MEANS THAT CAS REDIRECTION DOES NOT WORK
    print $portal->header('text/html; charset=utf8'); # DON'T FORGET THIS (see CGI(3))
    print "<html><body><h1>Unable to work</h1>";
    print "This server isn't well configured. Contact your administrator.";
    print "</body></html>";
  }

=head1 DESCRIPTION

This library just overload few methods of Lemonldap::NG::Portal::Simple to use
Google authentication mechanism.

See L<Lemonldap::NG::Portal::Simple> for usage and other methods.

=head1 SEE ALSO

L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Portal::Simple>,
L<http://lemonldap-ng.org/>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

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

=item Copyright (C) 2010 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Copyright (C) 2010, 2012 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

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


