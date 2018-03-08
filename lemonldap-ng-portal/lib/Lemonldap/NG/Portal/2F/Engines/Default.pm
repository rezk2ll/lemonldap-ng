package Lemonldap::NG::Portal::2F::Engines::Default;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

has sfModules => ( is => 'rw', default => sub { [] } );

has sfRModules => ( is => 'rw', default => sub { [] } );

sub init {
    my ($self) = @_;

    # Set default 2F list
    $self->conf->{available2F}                 ||= 'TOTP,U2F,REST,Ext2F';
    $self->conf->{available2FSelfRegistration} ||= 'TOTP,U2F';

    # Load 2F modules
    for my $i ( 0 .. 1 ) {
        foreach (
            split /,\s+/,
            $self->conf->{ $i ? 'available2FSelfRegistration' : 'available2F' }
          )
        {
            my $prefix = lc($_);
            $prefix =~ s/2f$//i;

            # Activation parameter
            my $ap = $prefix. ( $i ? '2fSelfRegistration' : '2fActivation' );

            # Unless $rule, skip loading
            if ($self->conf->{$ap}) {
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
                  { m => $m, r => $rule };
            }
        }
    }

    return 1;
}

# RUNNING METHODS

# run is called at each authentication, just after sesionInfo populate
sub run {
    my($self,$req)=@_;

    # Skip 2F unless a module has been registered
    return PE_OK unless(@{$self->sfModules});

    # Search for authorizated modules for this user
    my @am;
    foreach my $m (@{$self->sfModules}) {
        $self->logger->debug('Looking if '.$m->{m}->prefix.'2F is available');
        if($m->{r}->( $req, $req->sessionInfo ) ) {
            $self->logger->debug(' -> OK');
            push @am,$m->{m};
        }
    }

    # If no 2F modules are authorizated, skipping 2F
    # Note that a rule may forbid access after (GrantSession plugin)
    return PE_OK unless(@am);

    # If only one 2F is authorizated, display it
    $self->userLogger->info( 'Second factor required for '
          . $req->sessionInfo->{ $self->conf->{whatToTrace} } );
    $req->sessionInfo->{_2fRealSession} = $req->id;
    $req->sessionInfo->{_2fUrldc}       = $req->urldc;
    my $token = $self->ott->createToken( $req->sessionInfo );
    unless($#am) {
        my $res = $am[0]->run($req, $token);
        delete $req->{authResult} if ($res);
        return $res;
    }

    # More than 1 2F has been found, display choice
    # TODO
    return PE_OK
}

1;
