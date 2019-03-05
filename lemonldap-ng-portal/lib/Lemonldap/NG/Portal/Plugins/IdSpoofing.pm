package Lemonldap::NG::Portal::Plugins::IdSpoofing;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants
    qw( PE_OK PE_BADCREDENTIALS PE_IDSPOOFING_SERVICE_NOT_ALLOWED );

our $VERSION = '2.0.3';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

use constant endAuth => 'run';

has rule => ( is => 'rw', default => sub {1} );

sub hAttr {
    $_[0]->{conf}->{idSpoofingHiddenAttributes} . ' '
        . $_[0]->{conf}->{hiddenAttributes};
}

sub init {
    my ($self) = @_;

    # Parse activation rule
    my $hd = $self->p->HANDLER;
    $self->logger->debug(
        "IdSpoofing rule -> " . $self->conf->{idSpoofingRule} );
    my $rule
        = $hd->buildSub( $hd->substitute( $self->conf->{idSpoofingRule} ) );
    unless ($rule) {
        $self->error( "Bad IdSpoofing rule -> " . $hd->tsv->{jail}->error );
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
        $self->userLogger->error('IdSpoofing service not authorized');
        return PE_IDSPOOFING_SERVICE_NOT_ALLOWED;
    }

    # Fill spoof session
    my ( $realSession, $spoofSession ) = ( {}, {} );
    $self->logger->debug("Spoofing Id: $spoofId...");
    my $spk = '';
    foreach my $k ( keys %{ $req->{sessionInfo} } ) {
        if ( $self->{conf}->{idSpoofingSkipEmptyValues} ) {
            next unless defined $req->{sessionInfo}->{$k};
        }
        $spk = "$self->{conf}->{idSpoofingPrefix}$k";
        unless ( $self->hAttr =~ /\b$k\b/ ) {
            $realSession->{$spk} = $req->{sessionInfo}->{$k};
            $self->logger->debug("-> Store $k in realSession key: $spk");
        }
    }
    $req->{user} = $spoofId;
    $spoofSession = $self->_userDatas($req);

    # Merging SSO groups and hGroups & Dedup
    if ( $self->{conf}->{idSpoofingMergeSSOgroups} ) {
        $self->userLogger->warn("MERGING SSO groups and hGroups...");
        my $spg       = "$self->{conf}->{idSpoofingPrefix}groups";
        my $sphg      = "$self->{conf}->{idSpoofingPrefix}hGroups";
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
                      'IdSpoofing requested for an unvalid user ('
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
