# Self TOTP registration
package Lemonldap::NG::Portal::2F::Register::TOTP;

use strict;
use Mouse;
use JSON qw(from_json to_json);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin', 'Lemonldap::NG::Common::TOTP';

# INITIALIZATION

has prefix => ( is => 'rw', default => 'totp' );

has template => ( is => 'ro', default => 'totp2fregister' );

has logo => ( is => 'rw', default => 'totp.png' );

has ott => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->conf->{formTimeout} );
        return $ott;
    }
);

sub init {
    return 1;
}

sub run {
    my ( $self, $req, $action ) = @_;
    my $user = $req->userData->{ $self->conf->{whatToTrace} };
    unless ($user) {
        return $self->p->sendError( $req,
            'No ' . $self->conf->{whatToTrace} . ' found in user data', 500 );
    }

    # Verification that user has a valid TOTP app
    if ( $action eq 'verify' ) {

        # Get form token
        my $token = $req->param('token');
        unless ($token) {
            $self->userLogger->warn(
                "TOTP registration: register try without token for $user");
            return $self->p->sendError( $req, 'Go away', 400 );
        }

        # Verify that token exists in DB (note that "keep" flag is set to
        # permit more than 1 try during token life
        unless ( $token = $self->ott->getToken( $token, 1 ) ) {
            $self->userLogger->notice(
                "TOTP registration: token expired for $user");
            return $self->p->sendError( $req, 'PE82', 400 );
        }

        # Token is valid, so we have the master key proposed
        # ($token->{_totp2fSecret})

        # Now check TOTP code to verify that user has a valid TOTP app
        my $code     = $req->param('code');
        my $TOTPName = $req->param('TOTPName');

        unless ($code) {
            $self->logger->userInfo('TOTP registration: empty validation form');
            return $self->p->sendError( $req, 'missingCode', 200 );
        }

        #unless ( $code and $TOTPName ) {
        #$self->logger->userInfo(
        #'TOTP registration: empty code or name in validation form');
        #return $self->p->sendError( $req, 'missingCode', 200 );
        #}
        my $r = $self->verifyCode(
            $self->conf->{totp2fInterval},
            $self->conf->{totp2fRange},
            $self->conf->{totp2fDigits},
            $token->{_totp2fSecret}, $code
        );
        if ( $r == -1 ) {
            return $self->p->sendError( 'serverError', 500 );
        }

        # Invalid try is returned with a 200 code. Javascript will read error
        # and propose to retry
        elsif ( $r == 0 ) {
            $self->userLogger->notice(
                "TOTP registration: invalid TOTP for $user");
            return $self->p->sendError( $req, 'badCode', 200 );
        }
        $self->logger->debug('TOTP code verified');

        # Now code is verified, let's store the master key in persistent data
        $self->p->updatePersistentSession( $req,
            { _totp2fSecret => $token->{_totp2fSecret} } );

        my $list2FDevices = eval {
            $self->logger->debug("Looking for 2F Devices ...");
            from_json( $req->userData->{list2FDevices}, { allow_nonref => 1 } );
        };
        unless ($list2FDevices) {
            $self->logger->debug("No 2F Device found");
            $list2FDevices = [];
        }
        push @{$list2FDevices},
          {
            type    => 'TOTP',
            name    => $TOTPName,
            _secret => $token->{_totp2fSecret},
            epoch   => time()
          };

        #$self->logger->debug(
        #"Append 2F Device : { type => 'totp', name => $TOTPName }");
        $self->p->updatePersistentSession( $req,
            { list2FDevices => to_json($list2FDevices) } );

        $self->userLogger->notice('TOTP registration succeed');
        return [ 200, [ 'Content-Type' => 'application/json' ],
            ['{"result":1}'] ];
    }

    # Get or generate master key
    elsif ( $action eq 'getkey' ) {
        my $nk = 0;
        my $secret;
        if ( ( $req->param('newkey') and $self->conf->{totp2fUserCanChangeKey} )
            or not $req->userData->{_totp2fSecret} )
        {
            $secret = $self->newSecret;
            $nk     = 1;
        }
        elsif ( $req->param('newkey') ) {
            return $self->p->sendError( $req, 'notAutorizated', 200 );
        }
        elsif ( $self->conf->{totp2fDisplayExistingSecret} ) {
            $secret = $req->userData->{_totp2fSecret};
        }
        else {
            return $self->p->sendError( $req, 'totpExistingKey', 200 );
        }

        # Secret is stored in a token: we choose to not accept secret returned
        # by Ajax request to avoid some attacks
        my $token = $self->ott->createToken(
            {
                _totp2fSecret => $secret,
            }
        );

        my $issuer;
        unless ( $issuer = $self->conf->{totp2fIssuer} ) {
            $issuer = $self->conf->{portal};
            $issuer =~ s#^https?://([^/:]+).*$#$1#;
        }

        # QR-code will be generated by a javascript, here we just send data
        return $self->p->sendJSONresponse(
            $req,
            {
                secret   => $secret,
                token    => $token,
                portal   => $issuer,
                user     => $user,
                newkey   => $nk,
                digits   => $self->conf->{totp2fDigits},
                interval => $self->conf->{totp2fInterval}
            }
        );
    }
    
    if ( $self->conf->{totp2fUserCanChangeKey} ) {
		return $self->p->sendError( $req, 'notAutorizated', 200 );
	}

    # Get or generate master key
    if ( $action eq 'unregister' ) {
            $self->p->updatePersistentSession( $req, { _totp2fSecret => '' } );
            $self->userLogger->notice('TOTP unregistration succeed');
            return [
                200, [ 'Content-Type' => 'application/json' ],
                ['{"result":1}']
            ];
     }

    elsif ( $action eq 'delete' ) {
        my $epoch = $req->param('epoch');

        my $list2FDevices = eval {
            $self->logger->debug("Loading 2F Devices ...");

            # Read existing 2FDevices
            from_json( $req->userData->{list2FDevices}, { allow_nonref => 1 } );
        };

        my @keep = ();
        while (@$list2FDevices) {
            my $element = shift @$list2FDevices;
            $self->logger->debug("Looking for 2F Device to delete ...");
            push @keep, $element unless ( $element->{epoch} eq $epoch );
        }

        $self->logger->debug(
            "Delete 2F Device : { type => 'TOTP', epoch => $epoch }");
        $self->p->updatePersistentSession( $req,
            { list2FDevices => to_json( \@keep ) } );
        $self->userLogger->notice('TOTP deletion succeed');
        return [ 200, [ 'Content-Type' => 'application/json' ],
            ['{"result":1}'] ];

    }

}

1;
