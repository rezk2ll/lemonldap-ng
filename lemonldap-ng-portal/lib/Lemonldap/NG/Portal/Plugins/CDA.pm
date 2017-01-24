package Lemonldap::NG::Portal::Plugins::CDA;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Common::Module';

# INTERFACE

sub afterDatas {
    return 'changeUrldc';
}

# RUNNING METHOD

sub changeUrldc {
    my ( $self, $req ) = @_;
    my $urldc = $req->{urldc};
    if (    $req->id
        and $urldc !~ m#^https?://[^/]*$self->{conf}->{domain}(:\d+)?/#oi
        and $self->p->isTrustedUrl($urldc) )
    {
        my $ssl = $urldc =~ /^https/;
        $self->lmLog( 'CDA request', 'debug' );

        # Create CDA session
        if ( my $cdaSession = $self->getApacheSession( undef, kind => "CDA" ) )
        {
            my $cdaInfos = { '_utime' => time };
            if ( $self->{conf}->{securedCookie} < 2 or $ssl ) {
                $cdaInfos->{cookie_value} = $req->id;
                $cdaInfos->{cookie_name}  = $self->{conf}->{cookieName};
            }
            else {
                $cdaInfos->{cookie_value} =
                  $req->{sessionInfo}->{_httpSession};
                $cdaInfos->{cookie_name} = $self->{conf}->{cookieName} . "http";
            }

            $self->updateSession( $cdaInfos, $cdaSession->id );

            $req->{urldc} .=
                ( $urldc =~ /\?/ ? '&' : '?' )
              . $self->{conf}->{cookieName} . "cda="
              . $cdaSession->id;

            $self->lmLog( "CDA redirection to " . $req->{urldc}, 'debug' );
        }
        else {
            $self->lmLog( "Unable to create CDA session", 'error' );
            return PE_APACHESESSIONERROR;
        }
    }
    PE_OK;
}

1;
