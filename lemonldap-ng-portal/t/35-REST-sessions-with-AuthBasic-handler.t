use lib 'inc';
use strict;
use IO::String;
use JSON;
use Test::More;

our $debug = 'debug';
my ( $p, $res, $spId );
$| = 1;

require 't/auth-basic.pm';

require "t/test-lib.pm";

ok( $p = issuer(), 'Issuer portal' );
count(1);

# BEGIN TESTS
ok( $res = handler( req => [ GET => 'http://test2.example.com/' ] ),
    'Simple request to handler' );
ok( getHeader( $res, 'WWW-Authenticate' ) eq 'Basic realm="LemonLDAP::NG"',
    'Get WWW-Authenticate header' );
count(2);

ok(
    $res = handler(
        req => [
            GET => 'http://test2.example.com/',
            [ 'Authorization' => 'Basic ZHdobzpkd2hv' ]
        ],
        sub => sub {
            my ($res) = @_;
            subtest 'Portal request' => sub {
                plan tests => 3;
                ok( $res->[0] eq 'POST', 'Get POST request' );
                my ( $url, $query ) = split /\?/, $res->[1];
                ok(
                    $res = $p->_post(
                        $url, IO::String->new( $res->[3] ),
                        length => length( $res->[3] ),
                        query  => $query,
                    ),
                    'Push request to portal'
                );
                ok( $res->[0] == 200, 'Response is 200' );
                return $res;
            };
            count(1);
            return $res;
        },
    ),
    'AuthBasic request'
);
count(1);

ok(
    $res = handler(
        req => [
            GET => 'http://test2.example.com/',
            [ 'Authorization' => 'Basic ZHdobzpkd2hv' ]
        ],
        sub => sub {
            fail "Cache didn't work";
            return [ 500, [], [] ];
        },
    ),
    'New AuthBasic request'
);
count(1);
expectOK($res);

end_handler();
clean_sessions();
done_testing( count() );

sub issuer {
    return LLNG::Manager::Test->new( {
            ini => {
                logLevel          => $debug,
                templatesDir      => 'site/htdocs/static',
                domain            => 'idp.com',
                portal            => 'http://auth.idp.com',
                authentication    => 'Demo',
                userDB            => 'Same',
                restSessionServer => 1,
            }
        }
    );
}
