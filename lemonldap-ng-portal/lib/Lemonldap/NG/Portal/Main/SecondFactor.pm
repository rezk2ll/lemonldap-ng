package Lemonldap::NG::Portal::Main::SecondFactor;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_NOTOKEN
  PE_TOKENEXPIRED
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INTERFACE

sub afterDatas { '_run' }

# INITIALIZATION

has ott => (
    is      => 'rw',
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->{conf}->{formTimeout} );
        return $ott;
    }
);

has rule => ( is => 'rw' );

has prefix => ( is => 'rw' );

sub init {
    my ($self) = @_;
    $self->addUnauthRoute( $self->prefix . '2fcheck', '_verify', ['POST'] );
    my $rule = $self->conf->{ $self->prefix . '2fActivation' };
    $rule = $self->p->HANDLER->substitute($rule);
    unless ( $rule = $self->p->HANDLER->buildSub($rule) ) {
        $self->error( 'External 2F rule error: '
              . $self->p->HANDLER->tsv->{jail}->error );
        return 0;
    }
    $self->rule($rule);
    1;
}

sub _run {
    my ( $self, $req ) = @_;
    return PE_OK unless ( $self->rule->( $req->sessionInfo ) );
    $self->userLogger->info( 'Second factor required ('
          . $self->prefix
          . ') for '
          . $req->sessionInfo->{ $self->conf->{whatToTrace} } );
    $req->sessionInfo->{_2fRealSession} = $req->id;
    my $token = $self->ott->createToken( $req->sessionInfo );
    $req->id(0);
    $self->p->rebuildCookies($req);
    my $res = $self->run( $req, $token );
    delete $req->{authResult} if($res);
    return $res;
}

sub _verify {
    my ( $self, $req ) = @_;

    # Check token
    my $token;
    unless ( $token = $req->param('token') ) {
        $self->userLogger->error( $self->prefix . ' 2F access without token' );
        return $self->p->do( $req, [ sub { PE_NOTOKEN } ] );
    }

    my $session;
    unless ( $session = $self->ott->getToken($token) ) {
        $self->userLogger->info('Token expired');
        return $self->p->do( $req, [ sub { PE_TOKENEXPIRED } ] );
    }

    # Launch second factor verification
    my $res = $self->verify( $req, $session );

    # Case error
    if ($res) {
        return $self->p->do( $req, [ sub { $res } ] );
    }

    # Else restore session
    $req->sessionInfo($session);
    $req->id( delete $req->sessionInfo->{_2fRealSession} );
    $self->p->rebuildCookies($req);
    $req->mustRedirect(1);
    $self->userLogger->notice( $self->prefix
          . '2F verification for '
          . $req->sessionInfo->{ $self->conf->{whatToTrace} } );
    if ( my $l = $self->conf->{ $self->prefix . '2fAuthnLevel' } ) {
        $self->p->updateSession( $req, { authenticationLevel => $l } );
    }
    return $self->p->do( $req, [ sub { PE_OK } ] );
}

1;
