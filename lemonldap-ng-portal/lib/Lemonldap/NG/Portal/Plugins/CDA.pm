package Lemonldap::NG::Portal::Plugins::CDA;

use strict;
use Mouse;

extends 'Lemonldap::NG::Portal::Main::Module';

sub afterDatas {
    return 'changeUrldc';
}

sub changeUrldc {
    my ( $self, $req ) = @_;
    my $urldc = $req->datas->{urldc};
    if (    $req->id
        and $urldc !~ m#^https?://[^/]*$self->{conf}->{domain}(:\d+)?/#oi
        and $self->p->isTrustedUrl($urldc) )
    {
        my $ssl = $urldc =~ /^https/;
        $self->lmLog( 'CDA request', 'debug' );
        $req->datas->{urldc} .= ( $urldc =~ /\?/ ? '&' : '?' )
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
