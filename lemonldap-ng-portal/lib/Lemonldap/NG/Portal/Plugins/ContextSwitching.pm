package Lemonldap::NG::Portal::Plugins::ContextSwitching;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants
  qw( PE_OK PE_BADCREDENTIALS PE_IMPERSONATION_SERVICE_NOT_ALLOWED PE_MALFORMEDUSER );

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

    # Display form
    my $params = {
        PORTAL    => $self->conf->{portal},
        MAIN_LOGO => $self->conf->{portalMainLogo},
        LANGS     => $self->conf->{showLanguages},
        MSG       => 'contextSwitching',
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
    my $spoofId = $req->param('spoofId') || '';    # Impersonation required ?

    # Check activation rule
    unless ( $self->rule->( $req, $req->userData ) ) {
        $self->userLogger->error('Context switching service not authorized');
        $spoofId = '';
        $statut  = PE_IMPERSONATION_SERVICE_NOT_ALLOWED;
    }

    if ($spoofId) {
        $self->logger->debug("Spoof Id: $spoofId");
        unless ( $spoofId =~ /$self->{conf}->{userControl}/o ) {
            $self->userLogger->error('Malformed spoofed Id');
            $self->logger->debug(
                "Context switching tried with spoofed Id: $spoofId");
            $statut  = PE_MALFORMEDUSER;
        }
    }
    else {
        $self->logger->debug("No context switching required");
        $req->mustRedirect(1);
    }

    return $self->p->do( $req, [ sub { $statut } ] ) if $statut;

    # Fill spoof session
    my ( $realSession, $spoofSession ) = ( {}, {} );
    $self->logger->debug("Rename real attributes...");
    my $spk = '';
    foreach my $k ( keys %{ $req->{userData} } ) {

        # if ( $self->{conf}->{impersonationSkipEmptyValues} ) {
        #     next unless defined $req->{userData}->{$k};
        # }
        $spk = "$self->{conf}->{impersonationPrefix}$k";
        unless ( $self->hAttr =~ /\b$k\b/
            || $k =~ /^(?:_imp|token|_type)\w*\b/ )
        {
            $realSession->{$spk} = $req->{userData}->{$k};
            $self->logger->debug("-> Store $k in realSession key: $spk");
        }
        $self->logger->debug("Delete $k");
        delete $req->{userData}->{$k};
    }

    $spoofSession = $self->_userData( $req, $spoofId, $realSession );
    if ( $req->error ) {
        if ( $req->error == PE_BADCREDENTIALS ) {
            $statut = PE_BADCREDENTIALS;
        }
        else {
            $statut = $req->error;
        }
    }

    # Update spoof session
    $self->logger->debug("Populating spoof session...");
    foreach (qw (_auth _userDB _session_id)) {
        $self->logger->debug("Processing $_...");
        $spk = "$self->{conf}->{impersonationPrefix}$_";
        $spoofSession->{$_} = $realSession->{$spk};
    }

    # Merging SSO Groups and hGroups & dedup
    $spoofSession->{groups}  ||= '';
    $spoofSession->{hGroups} ||= {};

    #if ( $self->{conf}->{impersonationMergeSSOgroups} ) {
    $self->userLogger->warn("MERGING SSO groups and hGroups...");
    my $spg       = "$self->{conf}->{impersonationPrefix}groups";
    my $sphg      = "$self->{conf}->{impersonationPrefix}hGroups";
    my $separator = $self->{conf}->{multiValuesSeparator};

    ## GROUPS
    my @spoofGrps = split /\Q$separator/, $spoofSession->{groups};
    my @realGrps  = split /\Q$separator/, $realSession->{$spg};

    ## hGROUPS
    $realSession->{$sphg} ||= {};

    # Merge specified groups/hGroups only
    # unless ( $self->{conf}->{impersonationMergeSSOgroups} eq 1 ) {
    #     my %SSOgroups = map { $_, 1 } split /\Q$separator/,
    #       $self->{conf}->{impersonationMergeSSOgroups};

    #     $self->logger->debug("Filtering specified groups/hGroups...");
    #     @realGrps = grep { exists $SSOgroups{$_} } @realGrps;
    #     my %intersct =
    #       map {
    #         $realSession->{$sphg}->{$_}
    #           ? ( $_, $realSession->{$sphg}->{$_} )
    #           : ()
    #       } keys %SSOgroups;
    #     $realSession->{$sphg} = \%intersct;
    # }

    $self->logger->debug("Processing groups...");
    @spoofGrps = ( @spoofGrps, @realGrps );
    my %hash = map { $_, 1 } @spoofGrps;
    $spoofSession->{groups} = join $separator, sort keys %hash;

    $self->logger->debug("Processing hGroups...");
    $spoofSession->{hGroups} =
      { %{ $spoofSession->{hGroups} }, %{ $realSession->{$sphg} } };

    # }

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
                    'Impersonation requested for an unvalid user ('
                  . $req->{user}
                  . ")" );
        }
        $self->logger->debug("Process returned error: $error");
        $req->error($error);
        $raz = 1;
    }

    # Check identity rule if Impersonation required
    if ( $realId ne $spoofId ) {
        unless ( $self->idRule->( $req, $req->sessionInfo ) ) {
            $self->userLogger->warn(
                    'Impersonation requested for an unvalid user ('
                  . $req->{user}
                  . ")" );
            $self->logger->debug('Identity not authorized');
            $raz = 1;
        }
    }

    # Same real and spoof session - Compute Macros and Groups
    if ($raz) {
        $req->{sessionInfo} = {};
        $req->{sessionInfo} = {%$realSession};
        $req->{user}        = $realId;
        $req->steps( [
                'getUser',   'setSessionInfo',
                'setMacros', 'setGroups',
                'setLocalGroups'
            ]
        );
        $self->logger->debug('Spoof session equal real session');
        $req->error(PE_BADCREDENTIALS);
        if ( my $error = $self->p->process($req) ) {
            $self->logger->debug("Process returned error: $error");
            $req->error($error);
        }
    }
    return $req->{sessionInfo};
}

sub displaySwitchContext {
    my ( $self, $req ) = @_;
    return 2
      if $req->userData->{"$self->{conf}->{impersonationPrefix}_session_id"};
    return $self->rule->( $req, $req->userData );
}

1;
