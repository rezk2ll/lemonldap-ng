package Lemonldap::NG::Handler::Main::PostForm;

use strict;

# For importing MP function, $tsv->{transform},
# $tsv->{safe}, $tsv->{useSafeJail}, $tsv->{customFunctions}
use Lemonldap::NG::Handler::Main qw( :apache :tsv );
use Lemonldap::NG::Handler::Main::Logger;
use Lemonldap::NG::Handler::Main::Jail;

our $VERSION = '1.4.0';

BEGIN {

    if ( MP() == 1 ) {
        require Apache;
        require Apache::Log;
        require Apache::Constants;
        Apache::Constants->import(':common');
        Apache::Constants->import(':response');
    }

}

## @rmethod protected transformUri(string uri)
# Transform URI to replay POST forms
# @param uri URI to catch
# @return Apache2::Const
sub transformUri {
    my ( $class, $apacheRequest, $uri ) = splice @_;
    my $vhost = Lemonldap::NG::Handler::API->hostname($apacheRequest);

    if ( defined( $tsv->{transform}->{$vhost}->{$uri} ) ) {
        return &{ $tsv->{transform}->{$vhost}->{$uri} }($apacheRequest);
    }

    OK;
}

## @imethod protected buildPostForm(string url, int count)
# Build form that will be posted by client
# Fill an input hidden with fake value to
# reach the size of initial request
# @param url Target of POST
# @param count Fake input size
# @return Apache2::Const::OK
sub buildPostForm {
    my ( $class, $apacheRequest, $url, $count ) = @_;
    $count ||= 1000;
    $apacheRequest->handler("perl-script");
    $apacheRequest->add_config( ["SetHandler perl-script"] );
    $apacheRequest->set_handlers(
        'PerlResponseHandler' => sub {
            my $r = shift;
            $r->content_type('text/html; charset=UTF-8');
            $r->print(
qq{<html><body onload="document.getElementById('f').submit()"><form id="f" method="post" action="$url" style="visibility:hidden"><input type=hidden name="a" value="}
                  . sprintf( "%0" . $count . "d", 1 )
                  . qq{"/><input type="submit" value="Ok"/></form></body></html>}
            );
            OK;
        }
    );
    OK;
}

## @rmethod protected int postFilter(hashref data, Apache2::Filter f)
# POST data
# @param $data Data to POST
# @param $f Current Apache2::Filter object
# @return Apache2::Const::OK
sub postFilter {
    my $class = shift;
    my $data  = shift;
    my $f     = shift;
    my $l;

    unless ( $f->ctx ) {
        $f->ctx(1);

        # Create the transformed form data
        my $u = URI->new('http:');

        my $jail = Lemonldap::NG::Handler::Main::Jail->new(
            'safe'            => $tsv->{safe},
            'useSafeJail'     => $tsv->{useSafeJail},
            'customFunctions' => $tsv->{customFunctions}
        );
        $tsv->{safe} = $jail->build_safe();

        $u->query_form( { $tsv->{safe}->reval($data) } );
        my $s = $u->query();

        # Eat all fake data sent by client
        $l = $f->r->headers_in->{'Content-Length'};
        while ( $f->read( my $b, $l ) ) { }

        # Send to application real data
        $f->r->headers_in->set( 'Content-Length' => length($s) );
        $f->r->headers_in->set(
            'Content-Type' => 'application/x-www-form-urlencoded' );
        $f->print($s);

        Lemonldap::NG::Handler::Main::Logger->lmLog( "Send POST data $s",
            'debug' );

        # Mark this filter as done
        $f->seen_eos(1);
    }
    return OK;
}

1;
