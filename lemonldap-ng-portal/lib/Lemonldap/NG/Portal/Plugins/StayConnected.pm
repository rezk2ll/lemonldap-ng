# Plugin to enable "stay connected on this device" feature

package Lemonldap::NG::Portal::Plugins::StayConnected;

use 5.16.0;
use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_SENDRESPONSE
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INTERFACE

use constant afterDatas => 'newDevice';

use constant beforeAuth => 'check';

# INITIALIZATION

has ott => (
    is      => 'rw',
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->conf->{formTimeout} );
        return $ott;
    }
);

sub init {
    my ($self) = @_;
    $self->addAuthRoute( registerbrowser => 'storeBrowser', ['POST'] );

}

# RUNNING METHODS

sub newDevice {
    my ( $self, $req ) = @_;

    if ( $req->param('stayconnected') ) {
        my $token = $self->ott->createToken(
            {
                name => $req->sessionInfo->{ $self->conf->{whatToTrace} }
            }
        );
        print STDERR Data::Dumper::Dumper($token);
        use Data::Dumper;
        $req->response(
            $self->p->sendHtml(
                $req,
                '../common/registerBrowser',
                params => {
                    URL   => $req->urldc,
                    TOKEN => $token,
                }
            )
        );
        return PE_SENDRESPONSE;
    }
    return PE_OK;
}

sub storeBrowser {
    my ( $self, $req ) = @_;
    $req->urldc( $req->param('url') );
    $req->mustRedirect(1);
    if ( my $token = $req->param('token') ) {
        if ( my $tmp = $self->ott->getToken($token) ) {
            my $uid = $req->userData->{ $self->conf->{whatToTrace} };
            if ( $tmp->{name} eq $uid ) {
                if ( my $fg = $req->param('fg') ) {
                    my $ps = Lemonldap::NG::Common::Session->new(
                        storageModule => $self->conf->{persistentStorage},
                        storageModuleOptions =>
                          $self->conf->{persistentStorageOptions},
                        kind => "Persistent",
                        info => {
                            _session_uid    => $uid,
                            _connectedSince => time,
                            dataKeep        => $req->datas->{dataToKeep},
                        },
                    );
                    $req->addCookie(
                        $self->p->cookie(
                            name    => 'llngconnexion',
                            value   => $ps->id,
                            expires => '+1M',
                        )
                    );
                }
                else {
                    $self->logger->warn("Browser hasn't return fingerprint");
                }
            }
            else {
                $self->userLogger->error(
                    "StayConnected: mismatch UID: $tmp->{name} / $uid");
            }
        }
        else {
            $self->userLogger->error("StayConnected call with expired token");
        }
    }
    else {
        $self->userLogger->error('StayConnected call without token');
    }

    # Deliver cookie llngbrowser
    return $self->p->do( $req, [ sub { PE_OK } ] );
}

sub check {
    my ( $self, $req ) = @_;
    if ( my $cid = $req->cookies->{llngconnexion} ) {
        my $ps = Lemonldap::NG::Common::Session->new(
            storageModule        => $self->conf->{persistentStorage},
            storageModuleOptions => $self->conf->{persistentStorageOptions},
            kind                 => "Persistent",
            id                   => $cid,
        );
        # TODO: verify fingerprint
        if ( $ps and my $uid = $ps->data->{uid} ) {
            $req->user($uid);
            if ( $ps->data->{dataKeep} ) {
                $req->data( $ps->data->{dataKeep} ) :;
            }
            my @steps =
              grep { !ref $_ or $_ !~ /^(?:extractFormInfo|authenticate)$/ }
              @{ $req->steps };
            $req->steps( \@steps );
            $self->userLogger->notice("$uid connected by StayConnected cookie");
            return PE_OK;
        }
    }
    return PE_OK;
}

1;
