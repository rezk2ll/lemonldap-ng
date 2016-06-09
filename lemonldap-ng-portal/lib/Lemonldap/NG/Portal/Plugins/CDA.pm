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
        $req->{urldc} .= ( $urldc =~ /\?/ ? '&' : '?' )
          . (
            ( $self->conf->{securedCookie} < 2 or $ssl )
            ? $self->conf->{cookieName} . "=" . $req->id
            : $self->conf->{cookieName} . "http="
              . $req->{sessionInfo}->{_httpSession}
          );
    }
    PE_OK;
}

1;
