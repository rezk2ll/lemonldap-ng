package Lemonldap::NG::Portal::Plugins::IdSpoofing;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw( PE_OK PE_BADCREDENTIALS );

our $VERSION = '2.0.3';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

use constant endAuth => 'run';

sub hAttr {
    $_[0]->{conf}->{idSpoofingHiddenAttributes} . ' '
        . $_[0]->{conf}->{hiddenAttributes};
}

sub init {1}

# RUNNING METHOD

sub run {
    my ( $self, $req ) = @_;
    my $spoofId = $req->param('spoofId') || '';
    return PE_OK unless $spoofId;

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
    $spoofSession = { %$spoofSession, %$realSession };

    # Main session
    #$self->p->updatePersistentSession( $req, $spoofSession ); #?????

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

            #'setPersistentSessionInfo', 'setLocalGroups'
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
