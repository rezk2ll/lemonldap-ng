package Lemonldap::NG::Portal::Plugins::External2F;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_BADCREDENTIALS
  PE_ERROR
  PE_FORMEMPTY
  PE_NOTOKEN
  PE_OK
  PE_SENDRESPONSE
  PE_TOKENEXPIRED
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INTERFACE

sub afterDatas { 'run' }

# INITIALIZATION

has ott => (
    is      => 'rw',
    default => sub {
        my $ott;
        if ( $_[0]->{conf}->{requireToken} ) {
            $ott =
              $_[0]->{p}
              ->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
            $ott->timeout( $_[0]->{conf}->{formTimeout} );
        }
        return $ott;
    }
);

sub init {
    my ($self) = @_;
    $self->addUnauthRoute( ext2fcheck => 'verify', ['POST'] );
    foreach (qw(ext2FSendCommand ext2FValidateCommand)) {
        unless ( $self->conf->{$_} ) {
            $self->error("Missing $_ parameter, aborting");
            return 0;
        }
    }
    1;
}

sub run {
    my ( $self, $req ) = @_;

    # Prepare command and launch it
    my $cmd = $self->conf->{ext2FSendCommand};
    $cmd =~ s#\$(\w+)#$req->{sessionInfo}->{$1} // ''#ge;
    my $err = `$cmd 2>&1 1>/dev/null`;
    $self->logger->error($err) if ( length $err );
    if ($?) {
        return $self->p->do( $req, [ sub { PE_ERROR } ] );
    }

    # Prepare form
    $req->sessionInfo->{_ext2fRealSession} = $req->id;
    my $token = $self->ott->createToken( $req->sessionInfo );
    $req->id(0);
    $self->p->rebuildCookies($req);
    my $tmp = $self->p->sendHtml(
        $req,
        'ext2fcheck',
        params => {
            SKIN  => $self->conf->{portalSkin},
            TOKEN => $token
        }
    );
    $self->logger->debug( 'Prepare U2F verification for '
          . $req->sessionInfo->{ $self->conf->{whatToTrace} } );

    $req->response($tmp);
    delete $req->{authResult};
    return PE_SENDRESPONSE;
}

sub verify {
    my ( $self, $req ) = @_;

    # Check token
    my $token;
    unless ( $token = $req->param('token') ) {
        $self->userLogger->error('External 2F access without token');
        return $self->p->do( $req, [ sub { PE_NOTOKEN } ] );
    }
    my $code;
    unless ( $code = $req->param('code') ) {
        $self->userLogger->error('External 2F: no code');
        return $self->p->do( $req, [ sub { PE_FORMEMPTY } ] );
    }
    my $session;
    unless ( $session = $self->ott->getToken($token) ) {
        $self->userLogger->info('Token expired');
        return $self->p->do( $req, [ sub { PE_TOKENEXPIRED } ] );
    }

    # Prepare command and launch it
    my $cmd = $self->conf->{ext2FValidateCommand};
    $cmd =~ s#\$code\b#$code#g;
    $cmd =~ s#\$(\w+)#$session->{$1} // ''#ge;
    my $err = `$cmd 2>&1 1>/dev/null`;
    $self->userLogger->error($err) if ( length $err );
    if ($?) {
        return $self->p->do( $req, [ sub { PE_BADCREDENTIALS } ] );
    }
    $req->sessionInfo($session);
    $req->id( delete $req->sessionInfo->{_ext2fRealSession} );
    $self->p->rebuildCookies($req);
    $req->mustRedirect(1);
    $self->userLogger->notice( 'External verification for '
          . $req->sessionInfo->{ $self->conf->{whatToTrace} } );
    if ( my $l = $self->conf->{ext2fAuthnLevel} ) {
        $self->p->updateSession( $req, { authenticationLevel => $l } );
    }
    return $self->p->do( $req, [ sub { PE_OK } ] );
}

1;
