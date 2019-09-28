use Test::More;

BEGIN {
    require 't/test-psgi-lib.pm';
}

my $maintests = 4;

SKIP: {
    eval { require Cache::Memcached; };
    if ($@) {
        skip 'Cache::Memcached not found', $maintests;
    }
    eval { require Apache::Session::Generate::MD5; };
    if ($@) {
        skip 'Apache::Session::Generate::MD5 not found', $maintests;
    }
    init(
        'Lemonldap::NG::Handler::Server',
        {
            logLevel        => 'error',
            secureTokenUrls => ['/secured'],
            vhostOptions    => {
                'test1.example.com' => {
                    vhostHttps           => 0,
                    vhostPort            => 80,
                    vhostMaintenance     => 0,
                    vhostServiceTokenTTL => -1,
                },
            },
            exportedHeaders => {
                'test1.example.com' => {
                    'Auth-User' => '$uid',
                },
            }
        }
    );

    ok(
        $res = $client->_get(
            '/secured',          undef,
            'test1.example.com', "lemonldap=$sessionId",
            VHOSTTYPE => 'SecureToken',
        ),
        'Auth query'
    );
    ok( $res->[0] == 200, 'Code is 200' ) or explain( $res->[0], 200 );

    # Check headers
    %h = @{ $res->[1] };
    ok( $h{'Auth-Token'} =~ m%[0-9a-f]{32}%, 'Header "Auth-Token" found' )
      or explain( \%h, 'Auth-Token => "md5 value"' );
    ok( $h{'Auth-User'} eq 'dwho', 'Header Auth-User is set to "dwho"' )
      or explain( \%h, 'Auth-User => "dwho"' );
    count(4);
}

done_testing( count() );
clean();
