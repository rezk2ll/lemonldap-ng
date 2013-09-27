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
use Cache::FileCache;

our $VERSION = '1.2.0';
our $initDone;

BEGIN {
    eval {
        require threads::shared;
        threads::shared::share($initDone);
    };
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

    my $ua = LWP::UserAgent->new();

    # 1. If no openid element has been detected
    my $openid = $self->param('openid.mode');
    return PE_FIRSTACCESS
      unless ( $self->param('google_go') or $openid );

    # 2. Check Google responses
    if ($openid) {
        my $check_url = 'https://www.google.com/accounts/o8/ud' . '?' . join(
            '&',
            map {
                my $val = $self->param($_);
                $val = 'check_authentication' if $_ eq 'openid.mode';
                sprintf '%s=%s', uri_escape_utf8($_), uri_escape_utf8($val);
            } $self->param()
        );
        use URI::Escape;
        use LWP::UserAgent;

        # TODO : catch errors here
        my $response =
          LWP::UserAgent->new()->get( $check_url, Accept => 'text/plain' );
        my %tmp =
          map { my ( $key, $value ) = split /:/, $_, 2; $key => $value }
          split /\n/, $response->decoded_content;
        return PE_OK if ( $tmp{is_valid} eq 'true' );

        # TODO: look for returned errors
        return PE_BADCREDENTIALS;
    }

    # 3. Check if an OpenID url has been submitted
    else {
        my $check_url =
            'https://www.google.com/accounts/o8/ud'
          . '?openid.mode=checkid_setup'
          . '&openid.ns=http://specs.openid.net/auth/2.0'
          . '&openid.claimed_id=http://specs.openid.net/auth/2.0/identifier_select'
          . '&openid.identity=http://specs.openid.net/auth/2.0/identifier_select'
          . '&openid.return_to='
          . $self->{portal} . '?'
          . ( $self->{_url} ? "url=$self->{_url}&" : '' )
          . (
            $self->param( $self->{authChoiceParam} )
            ? "&"
              . $self->{authChoiceParam} . "="
              . $self->param( $self->{authChoiceParam} )
            : ''
          );

# TODO: Add Google AX extension. Here is OpenID SREG example
# If UserDB uses OpenID, add "OpenID Simple Registration Extension"
# compatible fields
#if ( $self->get_module('user') eq 'OpenID' ) {
#    my ( @r, @o );
#    while ( my ( $v, $k ) = each %{ $self->{exportedVars} } ) {
#        if ( $k =~ /^(?:(?:(?:full|nick)nam|languag|postcod|timezon)e|country|gender|email|dob)$/
#          )
#        {
#            if   ( $v =~ s/^!// ) { push @r, $k }
#            else                  { push @o, $k }
#        }
#        else {
#            $self->lmLog( "Unknown \"OpenID Simple Registration Extension\" field name: $k",
#                'warn'
#            );
#        }
#    }
#    my @tmp;
#    push @tmp, 'openid.sreg.required' => join( ',', @r ) if (@r);
#    push @tmp, 'openid.sreg.optional' => join( ',', @o ) if (@o);
#    OpenID::util::push_url_arg( \$check_url, @tmp ) if (@tmp);
#}
        print $self->redirect($check_url);
        $self->quit();
    }
    PE_OK;
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
    return "openidform";
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::AuthOpenID - Perl extension for building Lemonldap::NG
compatible portals with OpenID authentication.

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::SharedConf;
  my $portal = new Lemonldap::NG::Portal::Simple(
         configStorage     => {...}, # See Lemonldap::NG::Portal
         authentication    => 'OpenID',
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
OpenID authentication mechanism.

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


