##@file
# OpenID authentication backend file

##@class
# OpenID authentication backend class.
# The form must return a openIdUrl field
package Lemonldap::NG::Portal::AuthTwitter;

use strict;
use Lemonldap::NG::Portal::Simple;
use Net::Twitter;

our $VERSION = '0.1';

## @apmethod int authInit()
# @return Lemonldap::NG::Portal constant
sub authInit {
    my $self = shift;
    unless ( $self->{twitterKey} and $self->{twitterSecret} ) {
        $self->abort( 'Bad configuration',
            'twitterKey and twitterSecret parameters are required' );
    }
    PE_OK;
}

## @apmethod int extractFormInfo()
# Read username return by Twitter;
# @return Lemonldap::NG::Portal constant
sub extractFormInfo {
    my $self = shift;
    $self->{twitter} = Net::Twitter->new(
        traits          => [qw/API::REST OAuth/],
        consumer_key    => $self->{twitterKey},
        consumer_secret => $self->{twitterSecret},
        clientname      => $self->{twitterAppName} || 'Lemonldap::NG'
    );
    unless ( $self->param('twitterback') ) {
        $self->lmLog( 'Redirection to Twitter', 'debug' );
        my $url;
        # TODO : store url=...
        eval { $url = $self->{twitter}->get_authorization_url( callback => "$self->{portal}?twitterback=1" ); };
        if ($@) {
            if ( $@ =~ /\b401\b/ ) {
                $self->abort('Twitter application undeclared');
            }
            $self->lmLog( "Net::Twitter error: $@", 'error' );
            return PE_ERROR;
        }
        # TODO: store token key and secret somewhere !
        $self->redirect($url);
        $self->quit();
        die;
    }
    my $request_token = $self->param('oauth_token');
    my $verifier      = $self->param('oauth_verifier');
    unless($request_token and $verifier) {
        $self->lmLog('Twitter Oauth protocol error','error');
        return PE_ERROR;
    }
    print STDERR "COUCOU $verifier\n";
    $self->{twitter}->_request_request_token
    (
        $self->{sessionInfo}->{_access_token},
        $self->{sessionInfo}->{_access_token_secret}
        consumer_key    => $self->{twitterKey},
        consumer_secret => $self->{twitterSecret},
    ) = $self->{twitter}->request_access_token( token => $self->{twitterKey}, token_secret => $verifier, verifier => $verifier );
    print STDERR "COUCOU\n";

    my $status = eval { $self->{twitter}->user_timeline( { count => 1 } ) };
    if ($@) {
        if ( $@ =~ /\b401\b/ ) {
            $self->userError('Twitter authentication refused');
            return PE_BADCREDENTIALS;
        }
        $self->lmLog( "Net::Twitter error: $@", 'error' );
    }
    $self->{user}        = $status->[0]->{user}->{screen_name};
    $self->{twitterUser} = $status->[0]->{user};
    $self->lmLog( "Good Twitter authentication for $self->{user}", 'debug' );
    $self->{mustRedirect} = 1;
    PE_OK;
}

## @apmethod int setAuthSessionInfo()
# Store user.
# @return Lemonldap::NG::Portal constant
sub setAuthSessionInfo {
    my $self = shift;

    # TODO: set this to UserDBTwitter
    foreach (qw(screen_name location lang name url)) {
        $self->{sessionInfo}->{$_} = $self->{twitterUser}->{$_};
    }
    PE_OK;
}

## @apmethod int authenticate()
# Does nothing.
# @return Lemonldap::NG::Portal constant
sub authenticate {
    PE_OK;
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::OpenID - Perl extension for building Lemonldap::NG
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
http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation

=head1 AUTHOR

Thomas Chemineau, E<lt>thomas.chemineau@linagora.comE<gt>,
Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://forge.objectweb.org/tracker/?group_id=274>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Xavier Guimard E<lt>x.guimard@free.frE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut


