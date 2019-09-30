package Lemonldap::NG::Portal::Plugins::DecryptValue;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_TOKENEXPIRED
  PE_NOTOKEN
  PE_DECRYPTVALUE_SERVICE_NOT_ALLOWED
);

our $VERSION = '2.0.7';

extends qw(
  Lemonldap::NG::Portal::Main::Plugin
  Lemonldap::NG::Portal::Lib::_tokenRule
);

# INITIALIZATION
has rule => ( is => 'rw', default => sub { 0 } );
has ott  => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->{conf}->{formTimeout} );
        return $ott;
    }
);

sub init {
    my ($self) = @_;
    my $hd = $self->p->HANDLER;
    $self->addAuthRoute( decryptvalue => 'run', ['POST'] )
      ->addAuthRouteWithRedirect( decryptvalue => 'display', ['GET'] );

    # Parse activation rule
    $self->logger->debug(
        'DecryptValue rule -> ' . $self->conf->{decryptValueRule} );
    my $rule =
      $hd->buildSub( $hd->substitute( $self->conf->{decryptValueRule} ) );
    unless ($rule) {
        $self->error( 'Bad decryptValue rule -> ' . $hd->tsv->{jail}->error );
        return 0;
    }
    $self->rule($rule);

    return 1;
}

# RUNNING METHOD
sub display {
    my ( $self, $req ) = @_;

    # Check access rules
    unless ( $self->rule->( $req, $req->userData ) ) {
        $self->userLogger->warn('decryptValue service NOT authorized');
        return $self->p->do( $req,
            [ sub { PE_DECRYPTVALUE_SERVICE_NOT_ALLOWED } ] );
    }

    # Display form
    my $params = {
        PORTAL    => $self->conf->{portal},
        MAIN_LOGO => $self->conf->{portalMainLogo},
        SKIN      => $self->p->getSkin($req),
        LANGS     => $self->conf->{showLanguages},
        MSG       => 'decryptCipheredValue',
        ALERTE    => 'alert-warning',
        TOKEN     => (
              $self->ottRule->( $req, {} )
            ? $self->ott->createToken()
            : ''
        )
    };
    return $self->sendJSONresponse( $req, $params ) if ( $req->wantJSON );

    # Display form
    return $self->p->sendHtml( $req, 'decryptvalue', params => $params );
}

sub run {
    my ( $self, $req ) = @_;
    my $msg = '';

    # Check access rules
    unless ( $self->rule->( $req, $req->userData ) ) {
        $self->userLogger->warn('decryptValue service NOT authorized');
        return $self->p->do( $req,
            [ sub { PE_DECRYPTVALUE_SERVICE_NOT_ALLOWED } ] );
    }

    # Check token
    if ( $self->ottRule->( $req, {} ) ) {
        my $token = $req->param('token');
        unless ($token) {
            $self->userLogger->warn('decryptValue try without token');
            $msg   = PE_NOTOKEN;
            $token = $self->ott->createToken();
        }

        unless ( $self->ott->getToken($token) ) {
            $self->userLogger->warn('decryptValue try with expired/bad token');
            $msg   = PE_TOKENEXPIRED;
            $token = $self->ott->createToken();
        }

        my $params = {
            PORTAL    => $self->conf->{portal},
            MAIN_LOGO => $self->conf->{portalMainLogo},
            SKIN      => $self->p->getSkin($req),
            LANGS     => $self->conf->{showLanguages},
            MSG       => "PE$msg",
            ALERTE    => 'alert-warning',
            TOKEN     => $token,
        };
        return $self->p->sendJSONresponse( $req, $params )
          if ( $req->wantJSON );
        return $self->p->sendHtml( $req, 'decryptvalue', params => $params )
          if $msg;
    }

    my $cipheredValue = $req->param('cipheredValue') || '';
    my $decryptedValue =
      $self->p->HANDLER->tsv->{cipher}->decrypt($cipheredValue)
      if $cipheredValue;

    $self->logger->debug("decryptValue try with : $cipheredValue");
    $self->logger->debug("Decrypted value = $decryptedValue") if $decryptedValue;

    # Display form
    my $params = {
        PORTAL    => $self->conf->{portal},
        MAIN_LOGO => $self->conf->{portalMainLogo},
        SKIN      => $self->p->getSkin($req),
        LANGS     => $self->conf->{showLanguages},
        MSG       => 'decryptCipheredValue',
        DECRYPTED => (
            $decryptedValue ? $decryptedValue
            : 'notAnEncryptedValue'
        ),
        DALERTE => (
            $decryptedValue ? 'alert-info'
            : 'alert-danger'
        ),
        ALERTE => 'alert-warning',
        TOKEN  => (
            $self->ottRule->( $req, {} ) ? $self->ott->createToken()
            : ''
        )
    };
    return $self->p->sendJSONresponse( $req, $params ) if ( $req->wantJSON );

    # Display form
    return $self->p->sendHtml( $req, 'decryptvalue', params => $params );
}

1;
