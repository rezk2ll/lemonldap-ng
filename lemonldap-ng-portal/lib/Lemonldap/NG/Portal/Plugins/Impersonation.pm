package Lemonldap::NG::Portal::Plugins::Impersonation;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants
    qw( PE_OK PE_BADCREDENTIALS PE_IMPERSONATION_SERVICE_NOT_ALLOWED );

our $VERSION = '2.0.3';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

use constant endAuth => 'run';

has rule => ( is => 'rw', default => sub {1} );

sub hAttr {
    $_[0]->{conf}->{impersonationHiddenAttributes} . ' '
        . $_[0]->{conf}->{hiddenAttributes};
}

sub init {
    my ($self) = @_;

    # Parse activation rule
    my $hd = $self->p->HANDLER;
    $self->logger->debug(
        "impersonation rule -> " . $self->conf->{impersonationRule} );
    my $rule
        = $hd->buildSub( $hd->substitute( $self->conf->{impersonationRule} ) );
    unless ($rule) {
        $self->error( "Bad impersonation rule -> " . $hd->tsv->{jail}->error );
        return 0;
    }
    $self->{rule} = $rule;
    return 1;
}

# RUNNING METHOD

sub run {
    my ( $self, $req ) = @_;
    my $spoofId = $req->param('spoofId') || '';

    # Skip if no submitted SpoofId
    return PE_OK unless $spoofId;

    # Check activation rule
    unless ( $self->rule->( $req, $req->sessionInfo ) ) {
        $self->userLogger->error('Impersonation service not authorized');
        return PE_IMPERSONATION_SERVICE_NOT_ALLOWED;
    }

    # Fill spoof session
    my ( $realSession, $spoofSession ) = ( {}, {} );
    $self->logger->debug("Spoofing Id: $spoofId...");
    my $spk = '';
    foreach my $k ( keys %{ $req->{sessionInfo} } ) {
        if ( $self->{conf}->{impersonationSkipEmptyValues} ) {
            next unless defined $req->{sessionInfo}->{$k};
        }
        $spk = "$self->{conf}->{impersonationPrefix}$k";
        unless ( $self->hAttr =~ /\b$k\b/ ) {
            $realSession->{$spk} = $req->{sessionInfo}->{$k};
            $self->logger->debug("-> Store $k in realSession key: $spk");
        }
    }
    $req->{user} = $spoofId;
    $spoofSession = $self->_userDatas($req);

    # Merging SSO groups and hGroups & Dedup
    if ( $self->{conf}->{impersonationMergeSSOgroups} ) {
        $self->userLogger->warn("MERGING SSO groups and hGroups...");
        my $spg       = "$self->{conf}->{impersonationPrefix}groups";
        my $sphg      = "$self->{conf}->{impersonationPrefix}hGroups";
        my $separator = $self->{conf}->{multiValuesSeparator};
        if (    $spoofSession->{groups}
            and $realSession->{$spg} )
        {
            $self->logger->debug("Processing groups...");
            my @spoofGrps = split /\Q$separator/, $spoofSession->{groups};
            my @realGrps  = split /\Q$separator/, $realSession->{$spg};
            @spoofGrps = ( @spoofGrps, @realGrps );
            my %hash = map { $_, 1 } @spoofGrps;
            $spoofSession->{groups} = join $separator, sort keys %hash;

            $self->logger->debug("Processing hGroups...");
            $spoofSession->{hGroups} = { %{ $spoofSession->{hGroups} },
                %{ $realSession->{$sphg} } };
        }
    }

    # Create spoofed session
    $spoofSession = { %$spoofSession, %$realSession };

    # Main session
    $self->p->updateSession( $req, $spoofSession );
    return PE_OK;
}

sub _userDatas {
    my ( $self, $req ) = @_;
    $req->{sessionInfo} = {};

    # Search user in database
    $req->steps(
        [   'getUser',   'setSessionInfo',
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
        return $req->error($error);
    }
    $self->logger->debug("Populating spoofed session...");
    return $req->{sessionInfo};
}

1;
