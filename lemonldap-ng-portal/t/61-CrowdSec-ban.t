use warnings;
use Test::More;
use POSIX 'strftime';
use strict;
use JSON;
use LWP::UserAgent;
use LWP::Protocol::PSGI;

BEGIN {
    require 't/test-lib.pm';
}

my $ban = 0;

my $res;

LWP::Protocol::PSGI->register(
    sub {
        my $req = Lemonldap::NG::Portal::Main::Request->new(@_);
        if ( $req->path_info eq '/v1/watchers/login' ) {
            my $json;
            subtest 'Request to login', sub {
                ok( $json = $req->jsonBodyToObj,    'Content is JSON' );
                ok( $json->{machine_id} eq 'llng',  'Good machine_id' );
                ok( $json->{password} eq 'llngpwd', 'Good machine password' );
            };
            return [
                200,
                [],
                [
                    to_json( {
                            expire => strftime( "%Y-%m-%dT%H:%M:%SZ", gmtime ),
                            token  => 'aaabbb',
                        }
                    )
                ]
            ];
        }
        elsif ( $req->path_info eq '/v1/alerts' ) {
            subtest 'Request to push alert', sub {
                ok( $req->header('Authorization') eq 'Bearer aaabbb',
                    'Authentified request' );
            };
            $ban++;
            return [ 200, [], [] ];
        }
        fail('Unknown request');
        return [ 500, [], [$res] ];
    }
);

my $client = LLNG::Manager::Test->new( {
        ini => {
            logLevel          => 'error',
            authentication    => 'Demo',
            userDB            => 'Same',
            crowdsec          => 1,
            crowdsecMachineId => 'llng',
            crowdsecPassword  => 'llngpwd',
        }
    }
);

my $crowdsec =
  $client->p->loadedModules->{'Lemonldap::NG::Portal::Plugins::CrowdSec'};

ok( $crowdsec->ban( '1.2.3.4', 'Test ban' ), 'Call to ban()' );
ok( $ban == 1,                               'Ban received' );

clean_sessions();

done_testing();
