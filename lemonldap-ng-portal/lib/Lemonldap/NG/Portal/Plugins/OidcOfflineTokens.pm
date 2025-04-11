package Lemonldap::NG::Portal::Plugins::OidcOfflineTokens;

use strict;
use Mouse;
<<<<<<< HEAD
use Date::Parse;
use JSON qw(from_json to_json);
use Lemonldap::NG::Common::Session;
use Lemonldap::NG::Common::Session::REST;
=======
use JSON qw(from_json to_json);
use Data::Dumper;
>>>>>>> e1d3c04ea ([+] First draft for portal management of offline sessions)
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
<<<<<<< HEAD
    builder => sub { $_[0]->conf->{portalDisplayOfflineTokens} },
=======
    builder => sub { 1 },    # Always return true to always show the tab
>>>>>>> e1d3c04ea ([+] First draft for portal management of offline sessions)
);
with 'Lemonldap::NG::Portal::MenuTab';

sub display {
    my ( $self, $req ) = @_;
    my $activeSessions = [];
    my $sessions       = {};
<<<<<<< HEAD
    my $regex          = qr/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/;

    $self->logger->debug("Reading OidcOfflineTokens");
    my $user = $req->{userData}->{ $self->conf->{whatToTrace} };

    if ($user) {
        $self->logger->debug('Try to retrieve sessions from DB');
        my $moduleOptions;
        if ( $self->conf->{oidcStorage} ) {
            $moduleOptions = $self->conf->{oidcStorageOptions};
            $moduleOptions->{backend} = $self->conf->{oidcStorage};
        }
        else {
            $moduleOptions = $self->conf->{globalStorageOptions};
            $moduleOptions->{backend} = $self->conf->{globalStorage};
        }

=======

    $self->logger->debug("Reading OidcOfflineTokens");
    my $user = $req->{userData}->{ $self->conf->{whatToTrace} };
    if ($user) {
        $self->logger->debug('Try to retrieve sessions from DB');
        my $moduleOptions = $self->conf->{globalStorageOptions} || {};
        $moduleOptions->{backend} = $self->conf->{globalStorage};
>>>>>>> e1d3c04ea ([+] First draft for portal management of offline sessions)
        $self->logger->debug("Looking for \"$user\" sessions...");
        $sessions =
          $self->module->searchOn( $moduleOptions, $self->conf->{whatToTrace},
            $user );

<<<<<<< HEAD
        my $other = 0;
        foreach ( keys %$sessions ) {
            unless ( defined( $sessions->{$_}->{_type} )
                && $sessions->{$_}->{_type} eq 'refresh_token'
                && $sessions->{$_}->{_session_kind} eq 'OIDCI' )
=======
        $self->logger->debug('Build an array ref with sessions info...');
        $self->logger->debug( Dumper($sessions) );
        $self->logger->debug('Skip session(s) with no refresh token...');
        my $other = 0;
        foreach ( keys %$sessions ) {
            unless ( defined( $sessions->{$_}->{_type} )
                && $sessions->{$_}->{_type} eq 'refresh_token' )
>>>>>>> e1d3c04ea ([+] First draft for portal management of offline sessions)
            {
                delete $sessions->{$_};
                $other++;
            }
        }
<<<<<<< HEAD
        @$activeSessions = map {
            my $epoch;
            my $regex = '^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$';

            if ( $sessions->{$_}->{_updateTime} ) {
                if ( my ( $y, $mo, $d, $h, $mi, $s ) =
                    $sessions->{$_}->{_updateTime} =~ /$regex/ )
                {
                    $epoch = timelocal( $s, $mi, $h, $d, $mo - 1, $y );
                    $sessions->{$_}->{_updateTime} = $epoch;
                }
                else {
                    delete $sessions->{$_}->{_updateTime};
                }
            }

            {
                id        => $sessions->{$_}->{client_id},
                epoch     => $sessions->{$_}->{_updateTime},
                sessionid => $_
            }
        } keys %$sessions;
    }
    return {
        logo => "wrench",
        name => "oidcOfflineTokens",
        id   => "oidcOfflineTokens",
        html => $self->loadTemplate(
            $req,
            "oidcOfflineTokens",
            params => {
                sessions => to_json($activeSessions),
                js       =>
                  "$self->{p}->{staticPrefix}/common/js/oidcOfflineTokens.js"
            }
=======
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
>>>>>>> e1d3c04ea ([+] First draft for portal management of offline sessions)
        ),
    };
}

sub init {
    my ( $self, $req, $session ) = @_;
<<<<<<< HEAD

    $self->addAuthRoute( myoffline => { ':key' => 'delOffline' }, ['DELETE'] );
=======
    $self->logger->debug("Starting OIDC Offline Tokens..");

    # [your initialization stuff]
>>>>>>> e1d3c04ea ([+] First draft for portal management of offline sessions)

    return 1;
}

<<<<<<< HEAD
sub delOffline {
    my ( $self, $req ) = @_;
    my $id = $req->param('key');
    return $self->p->sendError( $req, 'ID is required', 400 ) unless ($id);
    my $mod;
    if ( $self->conf->{oidcStorage} ) {
        $mod = {
            module  => $self->conf->{oidcStorage},
            options => $self->conf->{oidcStorageOptions}
        };
    }
    else {
        $mod = {
            module  => $self->conf->{globalStorage},
            options => $self->conf->{globalStorageOptions}
        };

    }
    $mod->{kind} = 'OIDCI';

    # Get session
    # The hashed store is used if explicitly asked and if session type is
    # SSO or OIDC
    my $session = $self->Lemonldap::NG::Common::Session::REST::getApacheSession(
        $mod, $id,
        hashStore => 0,
    ) or return $self->p->sendError( $req, 'Session Id does not exist', 400 );

    # Delete it
    unless ( $req->userData->{ $self->conf->{whatToTrace} } eq
        $session->data->{ $self->conf->{whatToTrace} } )
    {
        return $self->sendError( $req, "Not authorized" );
    }
    $self->logger->debug("REST request to delete session $id");
    $session->remove;    #TODO : Call BackChannelLogout if needed
    return $self->p->sendJSONresponse( $req, { result => 1 } );
}
=======
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
>>>>>>> e1d3c04ea ([+] First draft for portal management of offline sessions)

1;
