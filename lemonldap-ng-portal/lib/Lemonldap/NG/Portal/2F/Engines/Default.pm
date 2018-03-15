package Lemonldap::NG::Portal::2F::Engines::Default;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_ERROR
  PE_NOTOKEN
  PE_OK
  PE_SENDRESPONSE
  PE_TOKENEXPIRED
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

has sfModules => ( is => 'rw', default => sub { [] } );

has sfRModules => ( is => 'rw', default => sub { [] } );

has ott => (
    is      => 'rw',
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->{conf}->{formTimeout} );
        return $ott;
    }
);

sub init {
    my ($self) = @_;

    # Set default 2F list
    $self->conf->{available2F}                 ||= 'TOTP,U2F,REST,Ext2F';
    $self->conf->{available2FSelfRegistration} ||= 'TOTP,U2F';

    # Load 2F modules
    for my $i ( 0 .. 1 ) {
        foreach (
            split /,\s*/,
            $self->conf->{ $i ? 'available2FSelfRegistration' : 'available2F' }
          )
        {
            my $prefix = lc($_);
            $prefix =~ s/2f$//i;

            # Activation parameter
            my $ap = $prefix . ( $i ? '2fSelfRegistration' : '2fActivation' );
            $self->logger->debug("Checking $ap");

            # Unless $rule, skip loading
            if ( $self->conf->{$ap} ) {
                $self->logger->debug("Trying to load $_ 2F");
                my $m =
                  $self->p->loadPlugin( $i ? "::2F::Register::$_" : "::2F::$_" )
                  or return 0;

                # Rule and prefix may be modified by 2F module, reread them
                my $rule = $self->conf->{$ap};
                $prefix = $m->prefix;

                # Compile rule
                $rule = $self->p->HANDLER->substitute($rule);
                unless ( $rule = $self->p->HANDLER->buildSub($rule) ) {
                    $self->error( 'External 2F rule error: '
                          . $self->p->HANDLER->tsv->{jail}->error );
                    return 0;
                }

                # Store module
                push @{ $self->{ $i ? 'sfRModules' : 'sfModules' } },
                  { p => $prefix, m => $m, r => $rule };
            }
            else {
                $self->logger->debug(' -> not enabled');
            }
        }
    }

    # Enable REST request only if more than 1 2F module is enabled
    if ( @{ $self->{sfModules} } > 1 ) {
        $self->addUnauthRoute( '2fchoice' => 'choice',   ['POST'] );
        $self->addUnauthRoute( '2fchoice' => 'redirect', ['GET'] );
    }

    # Enable 2F registration URL only if a least 1 registration module
    # is enabled
    if ( @{ $self->{sfRModules} } ) {

        # Registration base
        $self->addAuthRoute( '2fregisters' => 'displayRegister', ['GET'] );
        $self->addAuthRoute( '2fregisters' => 'register',        ['POST'] );
    }

    return 1;
}

# RUNNING METHODS

# run is called at each authentication, just after sesionInfo populate
sub run {
    my ( $self, $req ) = @_;

    # Skip 2F unless a module has been registered
    return PE_OK unless ( @{ $self->sfModules } );

    # Search for authorizated modules for this user
    my @am;
    foreach my $m ( @{ $self->sfModules } ) {
        $self->logger->debug(
            'Looking if ' . $m->{m}->prefix . '2F is available' );
        if ( $m->{r}->( $req, $req->sessionInfo ) ) {
            $self->logger->debug(' -> OK');
            push @am, $m->{m};
        }
    }

    # If no 2F modules are authorizated, skipping 2F
    # Note that a rule may forbid access after (GrantSession plugin)
    return PE_OK unless (@am);

    $self->userLogger->info( 'Second factor required for '
          . $req->sessionInfo->{ $self->conf->{whatToTrace} } );

    # Store user data in a token
    $req->sessionInfo->{_2fRealSession} = $req->id;
    $req->sessionInfo->{_2fUrldc}       = $req->urldc;
    my $token = $self->ott->createToken( $req->sessionInfo );
    delete $req->{authResult};

    # If only one 2F is authorizated, display it
    unless ($#am) {
        my $res = $am[0]->run( $req, $token );
        $req->authResult($res);
        return $res;
    }

    # More than 1 2F has been found, display choice
    $self->logger->debug("Prepare 2F choice");
    my $tpl = $self->p->sendHtml(
        $req,
        '2fchoice',
        params => {
            SKIN    => $self->conf->{portalSkin},
            TOKEN   => $token,
            MODULES => [ map { { CODE => $_->prefix, LOGO => $_->logo } } @am ],
        }
    );
    $req->response($tpl);
    return PE_SENDRESPONSE;

    # TODO:
    # - 2fchoice.tpl
    # - choice() which launch choosenModule->run($req,$token)
    # - add logos for 2F modules
}

sub choice {
    my ( $self, $req ) = @_;
    my $token;

    # Restore session
    unless ( $token = $req->param('token') ) {
        $self->userLogger->error( $self->prefix . ' 2F access without token' );
        $req->mustRedirect(1);
        return $self->p->do( $req, [ sub { PE_NOTOKEN } ] );
    }

    my $session;
    unless ( $session = $self->ott->getToken($token) ) {
        $self->userLogger->info('Token expired');
        return $self->p->do( $req, [ sub { PE_TOKENEXPIRED } ] );
    }

    $req->sessionInfo($session);

    # New token
    $token = $self->ott->createToken($session);

    my $ch = $req->param('sf');
    foreach my $m ( @{ $self->sfModules } ) {
        if ( $m->{m}->prefix eq $ch ) {
            my $res = $m->{m}->run( $req, $token );
            $req->authResult($res);
            return $self->p->do(
                $req,
                [
                    sub { $res }, 'controlUrl',
                    'buildCookie', @{ $self->p->afterDatas },
                ]
            );
        }
    }
    $self->userLogger->error('Bd 2F choice');
    return $self->p->lmError( $req, 500 );
}

sub _redirect {
    my ( $self, $req ) = @_;
    my $arg = $req->env->{QUERY_STRING};
    return [
        302, [ Location => $self->conf->{portal} . ( $arg ? "?$arg" : '' ) ], []
    ];
}

sub displayRegister {
    my ( $self, $req, $tpl ) = @_;

    # After verifying rule:
    #  - display template if $tpl
    #  - else display choice template
    if ($tpl) {
        my ($m) = grep { $_->{m}->prefix eq $tpl } @{ $self->sfRModules };
        unless ($m) {
            return $self->p->sendError( $req, 'Unexistent register module',
                400 );
        }
        unless ( $m->{r}->( $req, $req->userData ) ) {
            return $self->p->sendError( $req, 'Registration unauthorizated',
                403 );
        }
        return $self->p->sendHtml( $req, $m->{m}->template );
    }

    # If only one 2F is available, redirect to it
    my @am;
    foreach my $m ( @{ $self->sfRModules } ) {
        $self->logger->debug(
            'Looking if ' . $m->{m}->prefix . '2F register is available' );
        if ( $m->{r}->( $req, $req->userData ) ) {
            push @am, '/2fregisters/' . $m->{m}->prefix;
        }
    }
    if ( @am == 1 ) {
        return [ 302, [ Location => $self->conf->{portal} . $am[0] ], [] ];
    }
    return $self->p->sendHtml( $req, '2fregisters' );
}

# Check rule and display
sub register {
    my ( $self, $req, $tpl, @args ) = @_;

    # After verifying rule:
    #   - call register run method if $tpl
    #   - else give JSON list of available registers for this user
    if ($tpl) {
        my ($m) = grep { $_->{m}->prefix eq $tpl } @{ $self->sfRModules };
        unless ($m) {
            return $self->p->sendError( $req, 'Unexistent register module',
                400 );
        }
        unless ( $m->{r}->( $req, $req->userData ) ) {
            $self->userLogger->error("$tpl 2F registration refused");
            return $self->p->sendError( $req, 'Registration refused', 403 );
        }
        return $m->{m}->run( $req, @args );
    }
    my @am;
    foreach my $m ( @{ $self->sfRModules } ) {
        $self->logger->debug(
            'Looking if ' . $m->{m}->prefix . '2F register is available' );
        if ( $m->{r}->( $req, $req->userData ) ) {
            $self->logger->debug(' -> OK');
            my $name = $m->{m}->prefix;
            push @am,
              {
                name => $name,
                logo => $m->{m}->logo,
                url  => "/2fregisters/$name"
              };
        }
    }
    return $self->p->sendJSONresponse( $req, \@am );
}

1;
