package Lemonldap::NG::Portal::Plugins::OidcOfflineTokens;

use strict;
use Mouse;
use JSON qw(from_json to_json);
use Data::Dumper;
use Time::Local;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_ERROR
  PE_NOTOKEN
  PE_TOKENEXPIRED
  PE_SENDRESPONSE
);

our $VERSION = '2.21.0';

extends qw(Lemonldap::NG::Portal::Main::Plugin
  Lemonldap::NG::Portal::Lib::OtherSessions
);

use constant name => "OidcOfflineTokens";
has rule => (
    is      => "ro",
    lazy    => 1,
    builder => sub { 1 },    # Always return true to always show the tab
);
with 'Lemonldap::NG::Portal::MenuTab';

sub display {
    my ( $self, $req ) = @_;
    my $activeSessions = [];
    my $sessions       = {};

    $self->logger->debug("Reading OidcOfflineTokens");
    my $user = $req->{userData}->{ $self->conf->{whatToTrace} };
    if ($user) {
        $self->logger->debug('Try to retrieve sessions from DB');
        my $moduleOptions = $self->conf->{globalStorageOptions} || {};
        $moduleOptions->{backend} = $self->conf->{globalStorage};
        $self->logger->debug("Looking for \"$user\" sessions...");
        $sessions =
          $self->module->searchOn( $moduleOptions, $self->conf->{whatToTrace},
            $user );

        $self->logger->debug('Build an array ref with sessions info...');
        $self->logger->debug( Dumper($sessions) );
        $self->logger->debug('Skip session(s) with no refresh token...');
        my $other = 0;
        foreach ( keys %$sessions ) {
            unless ( defined( $sessions->{$_}->{_type} )
                && $sessions->{$_}->{_type} eq 'refresh_token' )
            {
                delete $sessions->{$_};
                $other++;
            }
        }
        @$activeSessions =
          map {
            my $epoch;
            my $regex = '^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$';
            if ( $_->{startTime} =~ /$regex/ ) {
                $epoch = timelocal( $6, $5, $4, $3, $2 - 1, $1 );
                $_->{startTime} = $epoch;
            }
            else {
                delete $_->{startTime};
            }
            if ( $_->{updateTime} ) {
                if ( $_->{updateTime} =~ /$regex/ ) {

                    $epoch = timelocal( $6, $5, $4, $3, $2 - 1, $1 );
                    $_->{updateTime} = $epoch;
                }
                else {
                    delete $_->{updateTime};
                }
            }
            $_;
          }
          sort { ( $b->{startTime} // 0 ) <=> ( $a->{startTime} // 0 ) }
          map  { { id => $_, scope => $sessions->{$_}->{scope}, }; }
          keys %$sessions;
    }
    return {
        logo => "wrench",
        name => "OidcOfflineTokens",
        id   => "OidcOfflineTokens",
        html => $self->loadTemplate(
            $req, "oidcOfflineTokens",
            params => { sessions => $activeSessions }
        ),
    };
}

sub init {
    my ( $self, $req, $session ) = @_;
    $self->logger->debug("Starting OIDC Offline Tokens..");

    # [your initialization stuff]

    return 1;
}

# sub mkOidcOfflineTokens {
#     my ( $self, $req,$session ) = @_;

#     if ( defined( $self->conf->{oidcRPMetaDataOptions} )
#         and ref( $self->conf->{oidcRPMetaDataOptions} ) )
#     {
#         # Set default RP displayname
#         foreach my $oidc ( keys %{ $self->conf->{oidcRPMetaDataOptions} } ) {
#             $self->conf->{oidcRPMetaDataOptions}->{$oidc}
#               ->{oidcRPMetaDataOptionsDisplayName} ||= $oidc;
#         }
#     }

#     # Loading existing oidcOfflineTokens
#     $self->logger->debug("Searching OIDC Offline Tokens...");
#     my $_oidcOfflineTokens;
#     $self->logger->debug( Dumper($session) );
#     $self->logger->debug( Dumper($self) );
#     $self->logger->debug( Dumper($req) );

#     if ( exists $session->{_oidcOfflineTokens} ) {
#         $_oidcOfflineTokens = eval {
#             from_json( $session->{_oidcOfflineTokens}, { allow_nonref => 1 } );
#         };
#         if ($@) {
#             $self->logger->error("Corrupted session (_oidcOfflineTokens): $@");
#             return PE_ERROR;
#         }
#     }
#     else {
#         $self->logger->debug("No OIDC Consent found");
#     }
#     my $consents = {};
#     foreach (@$_oidcOfflineTokens) {
#         if ( defined $_->{rp} ) {
#             my $rp = $_->{rp};
#             $self->logger->debug("RP { $rp } Consent found");
#             $consents->{$rp}->{epoch} = $_->{epoch};
#             $consents->{$rp}->{scope} = $_->{scope};
#             $consents->{$rp}->{displayName} =
#               $self->conf->{oidcRPMetaDataOptions}->{$rp}
#               ->{oidcRPMetaDataOptionsDisplayName};
#         }
#     }

#     # Display existing oidcOfflineTokens
#     return $self->loadTemplate(
#         $req,
#         'oidcOfflineTokens',
#         params => {
#             partners => [
#                 map {
#                     {
#                         name        => $_,
#                         epoch       => $consents->{$_}->{epoch},
#                         scope       => $consents->{$_}->{scope},
#                         displayName => $consents->{$_}->{displayName}
#                     }
#                 } ( sort keys %$consents )
#             ],
#             consents => join( ",", keys %$consents ),
#         }
#     );
# }

1;
