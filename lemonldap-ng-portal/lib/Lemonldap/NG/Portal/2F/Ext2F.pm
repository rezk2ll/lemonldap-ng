package Lemonldap::NG::Portal::2F::Ext2F;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_NOTOKEN
  PE_TOKENEXPIRED
  PE_ERROR
  PE_BADOTP
  PE_FORMEMPTY
  PE_SENDRESPONSE
);

our $VERSION = '2.0.10';

extends 'Lemonldap::NG::Portal::Main::SecondFactor';

# INITIALIZATION

has prefix => ( is => 'rw', default => 'ext' );

has resend_interval => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        $_[0]->{conf}->{ext2fResendInterval} || 0;
    }
);

has random => ( is => 'rw' );

sub init {
    my ($self) = @_;

    $self->addUnauthRoute(
        $self->prefix . '2fresend' => '_resend',
        ['POST']
    );

    $self->addAuthRoute(
        $self->prefix . '2fresend' => '_resend',
        ['POST']
    );

    unless ( $self->conf->{ext2fCodeActivation} ) {
        foreach (qw(ext2FSendCommand ext2FValidateCommand)) {
            unless ( $self->conf->{$_} ) {
                $self->error("Missing $_ parameter, aborting");
                return 0;
            }
        }
        $self->prefix( $self->conf->{sfPrefix} )
          if ( $self->conf->{sfPrefix} );
        return $self->SUPER::init();
    }
    if ( $self->conf->{ext2fCodeActivation} ) {
        unless ( $self->conf->{ext2FSendCommand} ) {
            $self->error("Missing 'ext2FSendCommand' parameter, aborting");
            return 0;
        }
        $self->random( Lemonldap::NG::Common::Crypto::srandom() );
        $self->prefix( $self->conf->{sfPrefix} )
          if ( $self->conf->{sfPrefix} );
        return $self->SUPER::init();
    }
    return 0;
}

# RUNNING METHODS

sub run {
    my ( $self, $req, $token ) = @_;

    # Generate Code to send
    my $code;
    if ( $self->conf->{ext2fCodeActivation} ) {
        $code = $self->random->randregex( $self->conf->{ext2fCodeActivation} );
        $self->logger->debug("Generated ext2f code : $code");
        $self->ott->updateToken( $token, __ext2fcode => $code );
    }

    return PE_ERROR unless $self->sendCode( $req, $req->sessionInfo, $code );

    $self->logger->debug("Prepare external 2F verification");
    my $tmp = $self->sendCodeForm( $req, TOKEN => $token );

    $req->response($tmp);
    return PE_SENDRESPONSE;
}

sub sendCodeForm {
    my ( $self, $req, %params ) = @_;

    my $checkLogins = $req->param('checkLogins');
    $self->logger->debug("Ext2F: checkLogins set") if $checkLogins;

    my $stayconnected = $req->param('stayconnected');
    $self->logger->debug("Ext2F: stayconnected set") if $stayconnected;

    # Prepare form
    my $tmp = $self->p->sendHtml(
        $req,
        'ext2fcheck',
        params => {
            MAIN_LOGO => $self->conf->{portalMainLogo},
            SKIN      => $self->p->getSkin($req),
            PREFIX    => $self->prefix,
            (
                $self->resend_interval
                ? ( RESENDTARGET => '/'
                      . $self->prefix
                      . '2fresend?skin='
                      . $self->p->getSkin($req) )
                : ()
            ),
            TARGET => '/'
              . $self->prefix
              . '2fcheck?skin='
              . $self->p->getSkin($req),
            CHECKLOGINS   => $checkLogins,
            STAYCONNECTED => $stayconnected,
            %params,
        }
    );
}

sub _resend {
    my ( $self, $req ) = @_;

    # Check token
    my $token;
    unless ( $token = $req->param('token') ) {
        $self->userLogger->error( $self->prefix . ' 2F access without token' );
        eval { $self->setSecurity($req) };
        $req->mustRedirect(1);
        return $self->p->do( $req, [ sub { PE_NOTOKEN } ] );
    }

    my $session;

    # Do not invalidate the token while getting it
    unless ( $session = $self->ott->getToken( $token, 1 ) ) {
        $self->userLogger->info('Token expired');
        $self->setSecurity($req);
        return $self->p->do( $req, [ sub { PE_TOKENEXPIRED } ] );
    }

    my $code = $session->{__ext2fcode};

    my $legend;

    # Timer
    my $lastretry =
      $session->{__lastRetry} || $session->{tokenSessionStartTimestamp} || time;
    if ( $self->resend_interval
        and ( $lastretry + $self->resend_interval < time ) )
    {

        # Resend code and update last retry
        return PE_ERROR unless $self->sendCode( $req, $session, $code );
        $self->ott->updateToken( $token, __lastRetry => time );
    }
    else {
        $legend = "resendTooSoon";
    }

    return $self->sendCodeForm( $req, TOKEN => $token, LEGEND => $legend );
}

sub verify {
    my ( $self, $req, $session ) = @_;
    my $usercode;
    unless ( $usercode = $req->param('code') ) {
        $self->userLogger->error('External 2F: no code found');
        return PE_FORMEMPTY;
    }

    if ( $self->conf->{ext2fCodeActivation} ) {
        return $self->verify_internal( $req, $session, $usercode );
    }
    else {
        return $self->verify_external( $req, $session, $usercode );
    }
}

sub verify_external {
    my ( $self, $req, $session, $code ) = @_;

    # Prepare command and launch it
    $self->logger->debug( 'Launching "Validate" external 2F command -> '
          . $self->conf->{ext2FValidateCommand} );
    $self->logger->debug(" code -> $code");
    if ( my $c =
        $self->launch( $session, $self->conf->{ext2FValidateCommand}, $code ) )
    {
        $self->userLogger->warn( 'Second factor failed for '
              . $session->{ $self->conf->{whatToTrace} } );
        $self->logger->error("External verify command failed (code $c)");
        return PE_BADOTP;
    }
    return PE_OK;
}

sub verify_internal {
    my ( $self, $req, $session, $code ) = @_;

    my $savedcode = $session->{__ext2fcode};
    unless ($savedcode) {
        $self->logger->error(
            'Unable to find generated 2F code in token session');
        return PE_ERROR;
    }

    $self->logger->debug("Verifying Ext 2F code: $code VS $savedcode");
    if ( $code eq $savedcode ) {
        return PE_OK;
    }
    else {
        $self->userLogger->warn( 'Second factor failed for '
              . $session->{ $self->conf->{whatToTrace} } );
        return PE_BADOTP;
    }
}

sub sendCode {
    my ( $self, $req, $sessionInfo, $code ) = @_;

    # Prepare command and launch it
    $self->logger->debug( 'Launching "Send" external 2F command -> '
          . $self->conf->{ext2FSendCommand} );
    if ( my $c =
        $self->launch( $sessionInfo, $self->conf->{ext2FSendCommand}, $code ) )
    {
        $self->logger->error("External send command failed (code $c)");
        return 0;
    }
    return 1;
}

# system() is used with an array to avoid shell injection
sub launch {
    my ( $self, $session, $command, $code ) = @_;
    my @args;
    foreach ( split( /\s+/, $command ) ) {
        if ( defined $code ) {
            s#\$code\b#$code#g;
        }
        s#\$(\w+)#$session->{$1} // ''#ge;
        push @args, $_;
    }
    $self->logger->debug( "Executing command: " . join( " ", @args ) );
    return system @args;
}

1;

