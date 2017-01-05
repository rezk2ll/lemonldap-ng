package Lemonldap::NG::Portal::Issuer::OpenID;

use strict;
use JSON;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_BADPARTNER
  PE_CONFIRM
  PE_ERROR
  PE_OK
  PE_OPENID_BADID
  PE_OPENID_EMPTY
  PE_REDIRECT
  PE_SENDRESPONSE
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Issuer';

# INTERFACE

sub beforeAuth { 'forUnauthUser' }

# PROPERTIES

has secret => (
    is      => 'rw',
    default => sub {
        return $_[0]->conf->{openIdIssuerSecret}
          || $_[0]->conf->{cipher}->encrypt(0);
    }
);

has listIsWhite => (
    is      => 'rw',
    default => sub {
        ( $_[0]->conf->{openIdSPList} =~ /^(\d);/ )[0] + 0;
    }
);

has spList => (
    is      => 'rw',
    default => sub {
        Lemonldap::NG::Common::Regexp::reDomainsToHost(
            ( $_[0]->conf->{openIdSPList} =~ /^\d;(.*)$/ )[0] );
    }
);

has openidPortal => (
    is      => 'rw',
    default => sub {
        return $_[0]->conf->{portal} . '/' . $_[0]->path;

        #$openidPortal =~ s#(?<!:)//#/#g;
    }
);

# INITIALIZATION

sub init {
    my ($self) = @_;
    eval { require Lemonldap::NG::Portal::Lib::OpenID::Server };
    if ($@) {
        $self->error("Unable to load Net::OpenID::Server: $@");
        return 0;
    }
    return 1;
}

# RUNNING METHOD

sub forUnauthUser {
    my ( $self, $req ) = @_;
    my $mode = $req->param('openid.mode');
    unless ($mode) {
        $self->lmLog( 'OpenID SP test', 'debug' );
        return PE_OPENID_EMPTY;
    }
    if ( $mode eq 'associate' ) {
        return $self->_openIDResponse(
            $self->openIDServer($req)->_mode_associate() );
    }
    elsif ( $mode eq 'check_authentication' ) {
        return $self->_openIDResponse(
            $self->openIDServer($req)->_mode_check_authentication() );
    }
    return PE_OK;
}

sub run {
    my ( $self, $req ) = @_;
    my $mode = $req->param('openid.mode');

    unless ($mode) {
        $self->lmLog( 'OpenID SP test', 'debug' );
        return PE_OPENID_EMPTY;
    }

    unless ( $mode =~ /^checkid_(?:immediate|setup)/ ) {
        $self->lmLog(
"OpenID error : $mode is not known at this step (issuerForAuthUser)",
            'error'
        );
        return PE_ERROR;
    }
    my @r = $self->openIDServer($req)->_mode_checkid();
    return $self->_openIDResponse(@r);
}

sub logout {
    PE_OK;
}

# INTERNAL METHODS

# Create if not done a new Lemonldap::NG::Portal::Lib::OpenID::Server objet
sub openIDServer {
    my ( $self, $req ) = @_;
    return $req->datas->{_openidserver} if ( $req->datas->{_openidserver} );

    $req->datas->{_openidserver} = Lemonldap::NG::Portal::Lib::OpenID::Server->new(
        server_secret => sub { return $self->secret },
        args          => $req,
        endpoint_url  => $self->openidPortal,
        setup_url     => $self->openidPortal,
        get_user      => sub {
            return $req->{sessionInfo}
              ->{ $self->conf->{openIdAttr} || $self->conf->{whatToTrace} };
        },
        get_identity => sub {
            my ( $u, $identity ) = @_;
            return $identity unless $u;
            return $self->openidPortal . $u;
        },
        is_identity => sub {
            my ( $u, $identity ) = @_;
            return 0 unless ( $u and $identity );
            if ( $u eq ( split '/', $identity )[-1] ) {
                return 1;
            }
            else {
                $self->{_badOpenIdentity} = 1;
                return 0;
            }
        },
        is_trusted => sub {
            my ( $u, $trust_root, $is_identity ) = @_;
            return 0 unless ( $u and $is_identity );
            my $tmp = $trust_root;
            $tmp =~ s#^http://(.*?)/#$1#;
            if ( $tmp =~ $self->spList xor $self->listIsWhite ) {
                $self->lmLog( "$trust_root is forbidden for openID exchange",
                    'warn' );
                $req->datas->{_openIdForbidden} = 1;
                return 0;
            }
            elsif ( $req->{sessionInfo}->{"_openidTrust$trust_root"} ) {
                $self->lmLog( 'OpenID request already trusted', 'debug' );
                return 1;
            }
            elsif ( $req->param("confirm") == 1 ) {
                $self->p->updatePersistentSession(
                    { "_openidTrust$trust_root" => 1 } );
                return 1;
            }
            elsif ( $req->param("confirm") == -1 ) {
                $self->p->updatePersistentSession(
                    { "_openidTrust$trust_root" => 0 } );
                return 0;
            }
            else {
                $self->lmLog( 'OpenID request not trusted', 'debug' );
                $req->datas->{_openIdTrustRequired} = 1;
                return 0;
            }
        },
        extensions => {
            sreg => sub {
                return ( 1, {} ) unless (@_);
                require Lemonldap::NG::Portal::Lib::OpenID::SREG;
                return $self->Lemonldap::NG::Portal::Lib::OpenID::SREG::sregHook($req, @_);
            },
        },
    );
    return $req->datas->{_openidserver};
}

# Manage Lemonldap::NG::Portal::OpenID::Server responses
# @return Lemonldap::NG::Portal error code
sub _openIDResponse {
    my ( $self, $req, $type, $data ) = @_;

    # Redirect
    if ( $type eq 'redirect' ) {
        $self->lmLog( "OpenID redirection to $data", 'debug' );
        $req->{urldc} = $data;
        return PE_REDIRECT;
    }

    # Setup
    elsif ( $type eq 'setup' ) {
        if (   $req->datas->{_openIdTrustRequired}
            or $req->datas->{_openIdTrustExtMsg} )
        {

            # TODO
            $req->info('<h3 trspan="openidExchange,$data->{trust_root}"></h3>');
            $self->info( $req->datas->{_openIdTrustExtMsg} )
              if ( $req->datas->{_openIdTrustExtMsg} );
            $self->lmLog( 'OpenID confirmation', 'debug' );
            return PE_CONFIRM;
        }
        elsif ( $req->datas->{_badOpenIdentity} ) {
            $self->p->userNotice(
"The user $req->{sessionInfo}->{_user} tries to use the id \"$data->{identity}\" on $data->{trust_root}"
            );
            return PE_OPENID_BADID;
        }
        elsif ( $req->datas->{_openIdForbidden} ) {
            return PE_BADPARTNER;
        }

        # User has refused sharing its datas
        else {
            $self->userNotice(
                $req->{sessionInfo}->{ $self->conf->{whatToTrace} }
                  . ' refused to share its OpenIdentity' );
            return PE_OK;
        }
    }
    elsif ($type) {
        $self->lmLog( "OpenID generated page ($type)", 'debug' );
        $req->response( [ 200, [ 'Content-Type' => $type ], [$data] ] );
    }
    else {
        $req->response(
            $self->p->sendError(
                $req,
                'OpenID error ',
                $self->openIDServer($req)->err()
            )
        );
    }
    return PE_SENDRESPONSE;
}
1;
