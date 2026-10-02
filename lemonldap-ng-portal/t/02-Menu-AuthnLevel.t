use warnings;
use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

# Non-regression test for #3735
#
# Applications requiring a higher authentication level than the user's one
# must be displayed in the menu: the user will be prompted to upgrade their
# session when opening them.

sub app {
    my ( $name, %options ) = @_;
    return {
        type    => "application",
        options => { logo => "demo.png", name => $name, %options },
    };
}

my $client = LLNG::Manager::Test->new( {
        ini => {
            portal          => 'http://auth.example.com/',
            authentication  => 'Demo',
            userDB          => 'Same',
            applicationList => {
                "0001-cat" => {
                    catname => "Applications",
                    type    => "category",
                    vhost => app( vhost => uri => 'http://vhost.example.com/' ),
                    location => app(
                        location => uri => 'http://location.example.com/admin'
                    ),
                    denied =>
                      app( denied => uri => 'http://denied.example.com/' ),
                    custom => app(
                        custom  => uri => 'http://custom.example.com/',
                        display => '$authenticationLevel >= 5',
                    ),
                },
            },
            locationRules => {
                'vhost.example.com'    => { default => 'accept' },
                'location.example.com' => {
                    '(?#AuthnLevel=5)^/admin' => 'accept',
                    default                   => 'accept',
                },
                'denied.example.com' => { default => 'deny' },
                'custom.example.com' => { default => 'accept' },
            },
            vhostOptions => {
                'vhost.example.com'  => { vhostAuthnLevel => 5 },
                'denied.example.com' => { vhostAuthnLevel => 5 },
            },
        }
    }
);

my $s   = "user=dwho&password=dwho";
my $res = $client->_post(
    '/', IO::String->new($s),
    length => length($s),
    accept => 'text/html',
);
my $id = expectCookie($res);

ok(
    $res = $client->_get(
        '/',
        cookie => "lemonldap=$id",
        accept => 'text/html',
    ),
    'Get menu'
);
my @hrefs =
  map { $_->getAttribute('href') }
  getHtmlElement( $res, '//div[contains(@class,"application")]//a' );
is_deeply(
    [ sort @hrefs ],
    [ 'http://location.example.com/admin', 'http://vhost.example.com/' ],
    'Applications requiring a higher authentication level are displayed',
) or diag explain \@hrefs;

my $session = getSession($id)->data;
is( $session->{authenticationLevel}, 1, 'Authentication level unchanged' );
ok( !$session->{_upgrade}, 'Session not marked for upgrade' );

clean_sessions();
done_testing();
