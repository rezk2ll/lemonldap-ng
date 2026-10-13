use warnings;
use strict;
use Test::More;
use Time::Fake;

require 't/test-lib.pm';

my $res;

sub test {
    my ($client_opts) = @_;

    my $client = LLNG::Manager::Test->new(
        { ini => { portal => 'https://auth.example.com/', %$client_opts } } );
    my $ott;

    subtest "Create ::Lib::StateToken instance" => sub {
        $ott =
          $client->p->loadModule('Lemonldap::NG::Portal::Lib::StateToken');
        $ott->timeout(100);
        ok( $ott, "OTT instance successfully created" );
    };

    subtest "Get valid token and delete it" => sub {
        Time::Fake->offset(1000);
        my $id = $ott->storeState( { x => "1" } );
        ok( $id, "Token successfully created" );

        Time::Fake->offset(1090);
        my $token = $ott->_getToken($id, 1);
        is( $token->{_utime} + $client->p->conf->{timeout},
            1100, "Correct purge time" );
        my $token_data = $ott->getState($id);
        is( $token_data->{x}, 1, "Correct data" );

        $token_data = $ott->getState($id);
        ok( !$token_data, "Token id is no longer valid" );
    };

    subtest "Get expired token" => sub {
        Time::Fake->offset(1000);
        my $id = $ott->storeState( { x => "1" } );
        ok( $id, "Token successfully created" );

        Time::Fake->offset(1110);
        my $token_data = $ott->getState($id);
        ok( !$token_data, "Token id is no longer valid" );
    };

    subtest "Get valid token without deleting it" => sub {
        Time::Fake->offset(1000);
        my $id = $ott->storeState( { x => "1" } );
        ok( $id, "Token successfully created" );

        Time::Fake->offset(1090);
        my $token = $ott->_getToken($id, 1);
        is( $token->{_utime} + $client->p->conf->{timeout},
            1100, "Correct purge time" );
        my $token_data = $ott->getState( $id, 1 );
        is( $token_data->{x}, 1, "Correct data" );

        $token = $ott->_getToken($id, 1);
        is( $token->{_utime} + $client->p->conf->{timeout},
            1100, "Correct purge time" );
        $token_data = $ott->getState( $id, 1 );
        is( $token_data->{x}, 1, "Correct data" );

        Time::Fake->offset(1110);
        $token_data = $ott->getState( $id, 1 );
        ok( !$token_data, "Token id is no longer valid" );
    };

    subtest "Update token" => sub {
        Time::Fake->offset(1000);
        my $id = $ott->storeState( { x => "1" } );
        ok( $id, "Token successfully created" );

        Time::Fake->offset(1090);
        my $token = $ott->_getToken($id, 1);
        is( $token->{_utime} + $client->p->conf->{timeout},
            1100, "Correct purge time" );
        my $token_data = $ott->getState( $id, 1 );
        is( $token_data->{x}, 1, "Correct data" );

        is( $ott->updateState( $id, 'x', 2 ),
            $id, "updateState returns token id" );

        $token = $ott->_getToken($id, 1);
        is( $token->{_utime} + $client->p->conf->{timeout},
            1100, "Correct purge time" );
        $token_data = $ott->getState( $id, 1 );
        is( $token_data->{x}, 2, "Correct data" );

        Time::Fake->offset(1110);
        $token_data = $ott->getState( $id, 1 );
        ok( !$token_data, "Token id is no longer valid" );
    };

    subtest "Update expired token" => sub {
        Time::Fake->offset(1000);
        my $id = $ott->storeState( { x => "1" } );
        ok( $id, "Token successfully created" );

        Time::Fake->offset(1110);
        ok( !$ott->updateState( $id, 'x', 2 ), "updateState returns undef" );

        my $token_data = $ott->getState( $id, 1 );
        ok( !$token_data, "Token id is no longer valid" );
    };
}

subtest "Test cache implementation" => sub {
    test( { tokenUseGlobalStorage => 0 } );
};

subtest "Test session implementation" => sub {
    test( { tokenUseGlobalStorage => 1 } );
};

clean_sessions();

done_testing();
