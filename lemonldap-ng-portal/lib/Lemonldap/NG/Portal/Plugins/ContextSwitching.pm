package Lemonldap::NG::Portal::Plugins::ContextSwitching;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants
  qw( PE_OK PE_REDIRECT PE_BADCREDENTIALS PE_IMPERSONATION_SERVICE_NOT_ALLOWED PE_MALFORMEDUSER );

our $VERSION = '2.0.6';

extends
  qw(Lemonldap::NG::Portal::Main::Plugin Lemonldap::NG::Portal::Lib::_tokenRule);

# INITIALIZATION

has rule   => ( is => 'rw', default => sub { 1 } );
has idRule => ( is => 'rw', default => sub { 1 } );

sub hAttr {
    $_[0]->{conf}->{contextSwitchingHiddenAttributes} . ' '
      . $_[0]->{conf}->{hiddenAttributes};
}

has ott => (
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
    $self->addAuthRoute( switchcontext => 'run',     ['POST'] );
    $self->addAuthRoute( switchcontext => 'display', ['GET'] );

    # Parse activation rule
    $self->logger->debug(
        'ContextSwitching rule -> ' . $self->conf->{contextSwitchingRule} );
    my $rule =
      $hd->buildSub( $hd->substitute( $self->conf->{contextSwitchingRule} ) );
    unless ($rule) {
        $self->error(
            'Bad contextSwitching rule -> ' . $hd->tsv->{jail}->error );
        return 0;
    }
    $self->rule($rule);

    # Parse identity rule
    $self->logger->debug( "ContextSwitching identities rule -> "
          . $self->conf->{contextSwitchingIdRule} );
    $rule =
      $hd->buildSub( $hd->substitute( $self->conf->{contextSwitchingIdRule} ) );
    unless ($rule) {
        $self->error( "Bad contextSwitching identities rule -> "
              . $hd->tsv->{jail}->error );
        return 0;
    }
    $self->idRule($rule);
    
    return 1;
}

# RUNNING METHOD

sub display {
    my ( $self, $req ) = @_;

    # Check access rules
    unless ( $self->rule->( $req, $req->userData )
        || $req->userData->{"$self->{conf}->{impersonationPrefix}_session_id"} )
    {
        $self->userLogger->error('Context switching service not authorized');
        return $self->p->do( $req,
            [ sub { PE_IMPERSONATION_SERVICE_NOT_ALLOWED } ] );
    }

    if ( $req->userData->{"$self->{conf}->{impersonationPrefix}_session_id"} ) {
        $self->p->updateSession( $req, $self->stopImpersonation($req) );
        return $self->p->do( $req, [ sub { PE_REDIRECT } ] );
    }

    # Display form
    my $params = {
        PORTAL    => $self->conf->{portal},
        MAIN_LOGO => $self->conf->{portalMainLogo},
        LANGS     => $self->conf->{showLanguages},
        MSG       => 'contextSwitching1',
        ALERTE    => 'alert-danger',
        LOGIN     => '',
        SPOOFID   => $self->conf->{contextSwitchingRule},
        TOKEN     => (
              $self->ottRule->( $req, {} )
            ? $self->ott->createToken()
            : ''
        )
    };

    return $self->p->sendHtml( $req, 'contextSwitching', params => $params, );
}

sub run {
    my ( $self, $req ) = @_;
    my $statut = PE_OK;

    if ( $req->userData->{"$self->{conf}->{impersonationPrefix}_session_id"} ) {
        $self->p->updateSession( $req, $self->stopImpersonation($req) );
        return $self->p->do( $req, [ sub { PE_REDIRECT } ] );
    }

    my $spoofId = $req->param('spoofId') || '';    # Impersonation required ?

    # Check activation rule
    unless ( $self->rule->( $req, $req->userData ) ) {
        $self->userLogger->error('Context switching service not authorized');
        $spoofId = '';
        return $self->p->do( $req,
            [ sub { PE_IMPERSONATION_SERVICE_NOT_ALLOWED } ] );
    }

    if ( $spoofId && $spoofId ne $req->{user} ) {
        $self->logger->debug("Spoof Id: $spoofId");
        unless ( $spoofId =~ /$self->{conf}->{userControl}/o ) {
            $self->userLogger->error('Malformed spoofed Id');
            $self->logger->debug(
                "Context switching tried with spoofed Id: $spoofId");
            return $self->p->do( $req, [ sub { PE_MALFORMEDUSER } ] );
        }
    }
    else {
        $self->logger->debug("No context switching required");
        $req->urldc( $self->conf->{portal} );
        return $self->p->do( $req, [ sub { PE_OK } ] );
    }

    # Fill spoof session
    my ( $realSession, $spoofSession ) = ( {}, {} );
    $self->logger->debug("Rename real attributes...");
    my $spk = '';
    foreach ( keys %{ $req->{userData} } ) {
        $spk = "$self->{conf}->{impersonationPrefix}$_";
        $realSession->{$spk} = $req->{userData}->{$_};
        $self->logger->debug("-> Store $_ in realSession key: $spk");
        $self->logger->debug("Delete $_");
        delete $req->{userData}->{$_};
    }

    $spoofSession = $self->_userData( $req, $spoofId, $realSession );
    $self->logger->debug(
        "..............." . Data::Dumper::Dumper($spoofSession) );
    if ( $req->error ) {
        if ( $req->error == PE_BADCREDENTIALS ) {
            $statut = PE_MALFORMEDUSER;
        }
        else {
            $statut = $req->error;
        }
    }

    # Update spoof session
    unless ($statut) {
        $self->logger->debug("Populating spoof session...");
        foreach (qw (_auth _userDB _session_id)) {
            $self->logger->debug("Processing $_...");
            $spk = "$self->{conf}->{impersonationPrefix}$_";
            $spoofSession->{$_} = $realSession->{$spk};
        }
    }

    # Main session
    $self->p->updateSession( $req, $spoofSession );
    return $self->p->do( $req, [ sub { $statut } ] );
}

sub _userData {
    my ( $self, $req, $spoofId, $realSession ) = @_;
    my $realId = $req->{user};
    $req->{user} = $spoofId;
    my $raz = 0;

    # Compute Macros and Groups with real and spoof sessions
    $req->{sessionInfo} = {%$realSession};

    # Search user in database
    $req->steps( [
            'getUser',   'setSessionInfo',
            'setMacros', 'setGroups',
            'setLocalGroups'
        ]
    );
    if ( my $error = $self->p->process($req) ) {
        if ( $error == PE_BADCREDENTIALS ) {
            $self->userLogger->warn(
                    'ContextSwitching requested for an unvalid user ('
                  . $req->{user}
                  . ")" );
        }
        $self->logger->debug("Process returned error: $error");
        $req->error($error);
        $raz = 1;
    }

    # Check identity rule if Impersonation required
    unless ( $self->idRule->( $req, $req->sessionInfo ) ) {
        $self->userLogger->warn(
                'ContextSwitching requested for an unvalid user ('
              . $req->{user}
              . ")" );
        $self->logger->debug('Identity not authorized');
        $req->error(PE_MALFORMEDUSER);
        $raz = 1;
    }

    return $raz ? $self->abortImpersonation($req) : $req->{sessionInfo};
}

sub displaySwitchContext {
    my ( $self, $req ) = @_;
    return 2
      if $req->userData->{"$self->{conf}->{impersonationPrefix}_session_id"};
    return $self->rule->( $req, $req->userData );
}

sub stopImpersonation {
    my ( $self, $req ) = @_;
    $self->logger->debug("stopImpersonation required");
    $req->{user} = $req->{userData}->{real__user};
    my $realSession = {};
    foreach ( keys %{ $req->{userData} } ) {
        if (/^$self->{conf}->{impersonationPrefix}/) {
            my $key = $_;
            $key =~ s/^$self->{conf}->{impersonationPrefix}//;
            $realSession->{$key} = $req->{userData}->{$_};
            $self->logger->debug("Rename userData keys -> $_");
            delete $req->{userData}->{$_};
        }
    }
    $req->urldc( $self->conf->{portal} );
    return $realSession;
}

sub abortImpersonation {
    my ( $self, $req ) = @_;
    $self->logger->debug("abortImpersonation required");
    $req->{user} = $req->{sessionInfo}->{real__user};
    my $realSession = {};
    foreach ( keys %{ $req->{sessionInfo} } ) {
        if (/^$self->{conf}->{impersonationPrefix}/) {
            my $key = $_;
            $key =~ s/^$self->{conf}->{impersonationPrefix}//;
            $realSession->{$key} = $req->{sessionInfo}->{$_};
            $self->logger->debug("Rename sessionInfo keys -> $_");
            delete $req->{sessionInfo}->{$_};
        }
    }
    $req->urldc( $self->conf->{portal} );
    $req->{userData} = { $realSession };
    return $realSession;
}

1;
