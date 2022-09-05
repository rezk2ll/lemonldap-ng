use Test::More;
use IO::String;
use strict;

require 't/test-lib.pm';

my $res;

subtest 'Legacy AJAX SSL Auth' => sub {
    my $client = LLNG::Manager::Test->new( {
            ini => {
                logLevel       => 'error',
                useSafeJail    => 1,
                authentication => 'SSL',
                userDB         => 'Null',
                SSLVar         => 'SSL_CLIENT_S_DN_Custom',
                sslByAjax      => 1,
                sslHost        => 'https://authssl.example.com:19876'
            }
        }
    );

    ok(
        $res = $client->_get(
            '/',
            query  => 'url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==',
            accept => 'text/html'
        ),
        'Get Menu'
    );
    my $pdata = 'lemonldappdata=' . expectCookie( $res, 'lemonldappdata' );

    ok(
        $res->[2]->[0] =~
m%<script type="application/init">\s*\{"sslHost":"https://authssl.example.com:19876"\}\s*</script>%s,
        ' SSL AJAX URL found'
    ) or print STDERR Dumper( $res->[2]->[0] );
    ok( $res->[2]->[0] =~ qr%<img src="/static/common/modules/SSL.png"%,
        'Found 5_ssl Logo' )
      or print STDERR Dumper( $res->[2]->[0] );
    ok( $res->[2]->[0] =~ /ssl\.(?:min\.)?js/, 'Get ssl javascript' )
      or print STDERR Dumper( $res->[2]->[0] );
    count(4);

    my ( $host, $url, $query ) = expectForm( $res, '#', undef, 'nossl' );

    # AJAX request
    ok(
        $res = $client->_get(
            '/',
            cookie => $pdata,
            accept => 'application/json',
            custom => { SSL_CLIENT_S_DN_Custom => 'dwho' }
        ),
        'Auth query'
    );
    my $json = expectJSON($res);
    is( $json->{result}, 1, "Correct result" );
    is( $json->{error},  0, "No error" );

    my $id = expectCookie($res);
    $pdata = expectCookie( $res, 'lemonldappdata' );
    ok( $pdata eq '', 'pdata is empty' );
    count(2);

    ok(
        $res = $client->_post(
            '/', IO::String->new($query),
            length => length($query),
            accept => 'text/html',
            cookie => "lemonldap=$id",
        ),
        'Post form'
    );
    expectRedirection( $res, 'http://test1.example.com/' );
};

subtest 'Regular SSL Auth' => sub {
    &Lemonldap::NG::Handler::Main::cfgNum( 0, 0 );
    my $client = LLNG::Manager::Test->new( {
            ini => {
                logLevel       => 'error',
                useSafeJail    => 1,
                authentication => 'SSL',
                userDB         => 'Null',
            }
        }
    );

    my $res;
    ok(
        $res =
          $client->_get( '/', custom => { SSL_CLIENT_S_DN_Email => 'dwho' } ),
        'Auth query'
    );

    expectOK($res);
    expectCookie($res);
    count(1);
};

done_testing();
