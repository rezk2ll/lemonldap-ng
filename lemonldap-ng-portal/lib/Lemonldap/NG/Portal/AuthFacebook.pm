##@file
# Facebook authentication backend file

##@class
# Facebook authentication backend class.
package Lemonldap::NG::Portal::AuthFacebook;

use strict;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Common::Regexp;
use LWP::UserAgent;
use URI::Escape;

our $VERSION = '1.3.0';
our $initDone;

BEGIN {
    eval {
        require threads::shared;
        threads::shared::share($initDone);
    };
}

## @method LWP::UserAgent ua()
# @return LWP::UserAgent object
sub ua {
    my $self = shift;
    return $self->{ua} ||= LWP::UserAgent->new();
}

## @method Net::Facebook::Oauth2 fb()
# @return Net::Facebook::Oauth2 object
sub fb {
    my $self = shift;
    return $self->{_fb} if ( $self->{_fb} );

    # Build callback uri
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

    # Build Net::Facebook::Oauth2 object
    $self->{_fb} = Net::Facebook::Oauth2->new(
        application_id     => '316131503062',
        application_secret => 'e3979b1a6fa02f4833505ccc80987ae3',
        callback           => $ret,
    );
    unless ( $self->{_fb} ) {
        $self->abort('Unable to build Net::Facebook::Oauth2 object');
    }
    return $self->{_fb};
}

## @apmethod int authInit()
# @return Lemonldap::NG::Portal constant
sub authInit {
    my $self = shift;
    unless ($initDone) {
        eval { require Net::Facebook::Oauth2; };
        $self->abort( 'Unable to load Net::Facebook::Oauth2', $@ ) if ($@);
    }
    PE_OK;
}

## @apmethod int extractFormInfo()
# Read username return by Facebook authentication system.
# @return Lemonldap::NG::Portal constant
sub extractFormInfo {
    my $self = shift;

# TODO: replace this
#
#   Lemonldap-ng-dev
#   App ID:     **********
#   App Secret:     ************
#
#   Doc : https://developers.facebook.com/tools/explorer
#
#   Other TODO: doc must say that AppID => https://developers.facebook.com/apps
#
#   Datas:
#   http://graph.facebook.com/100000458059472?fields=id,name,first_name,middle_name,last_name,link,username,gender,locale,timezone,email,location,website

    # 1. Check Facebook responses
    if ( my $code = $self->param('code') ) {
        if ( my $access_token = $self->fb()->get_access_token( code => $code ) )
        {
            $self->{sessionInfo}->{_facebookToken} = $access_token;

            # TODO
            $self->{user} = $access_token;
            return PE_OK;
        }
        return PE_BADCREDENTIALS;
    }

    # 2. Else redirect user to Facebook login page:

    # Build Facbook redirection
    my $check_url = $self->fb()->get_authorization_url(
        scope   => [ 'offline_access', 'publish_stream' ],
        display => 'page',
    );
    print $self->redirect($check_url);
    $self->quit();
}

## @apmethod int setAuthSessionInfo()
# Set _user and authenticationLevel.
# @return Lemonldap::NG::Portal constant
sub setAuthSessionInfo {
    my $self = shift;

    $self->{sessionInfo}->{'_user'} = $self->{user};

    $self->{sessionInfo}->{authenticationLevel} = $self->{facebookAuthnLevel}
      || 1;

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
    return "logo";
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::AuthFacebook - Perl extension for building Lemonldap::NG
compatible portals with Facebook authentication.

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::SharedConf;
  my $portal = new Lemonldap::NG::Portal::Simple(
         configStorage     => {...}, # See Lemonldap::NG::Portal
         authentication    => 'Facebook',
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
Facebook authentication mechanism.

See L<Lemonldap::NG::Portal::Simple> for usage and other methods.

=head1 SEE ALSO

L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Portal::Simple>,
L<http://lemonldap-ng.org/>, L<Net::Facebook::Oauth2>
L<https://developers.facebook.com/docs/>

=head1 AUTHOR

=over

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

=item Copyright (C) 2013 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

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

