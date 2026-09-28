# Configuration metadata (author, date, log) set by API modifications

use warnings;
use Test::More;
use strict;
use JSON;
use IO::String;
require 't/test-lib.pm';

my $client = LLNG::Manager::Test->new;

sub lastConf {
    my ($last) = sort { $b <=> $a }
      map { /lmConf-(\d+)\.json$/ ? $1 : () }
      glob "$main::tmpdir/conf/lmConf-*.json";
    open my $fh, '<', "$main::tmpdir/conf/lmConf-$last.json" or die $!;
    my $conf = from_json( do { local $/; <$fh> } );
    close $fh;
    return $conf;
}

my $before = lastConf();

# Anonymous API client (protection none)
my $j = to_json( {
        confKey      => 'metadatarp',
        clientId     => 'metadataclient',
        redirectUris => ['https://rp.example.com/cb'],
    }
);
my $res = $client->_post( '/api/v1/providers/oidc/rp', '', IO::String->new($j),
    'application/json', length($j) );
is( $res->[0], 201, 'OIDC RP created' ) or diag explain $res->[2];

my $conf = lastConf();
is( $conf->{cfgNum},      $before->{cfgNum} + 1, 'New configuration stored' );
is( $conf->{cfgAuthor},   'anonymous',           'Author is set' );
is( $conf->{cfgAuthorIP}, '127.0.0.1',           'Author IP is set' );
ok( $conf->{cfgDate} >= time - 60, 'Date is updated' );
is( $conf->{cfgVersion}, $Lemonldap::NG::Manager::VERSION, 'Version is set' );
is(
    $conf->{cfgLog},
    '[API] POST /api/v1/providers/oidc/rp (metadatarp)',
    'Log describes the API request'
);

# API client authenticated by the web server (basic auth)
$res = $client->app->( {
        'HTTP_ACCEPT'     => 'application/json, text/plain, */*',
        'SCRIPT_NAME'     => '',
        'SERVER_NAME'     => '127.0.0.1',
        'QUERY_STRING'    => '',
        'PATH_INFO'       => '/api/v1/providers/oidc/rp/metadatarp',
        'REQUEST_METHOD'  => 'DELETE',
        'REQUEST_URI'     => '/api/v1/providers/oidc/rp/metadatarp',
        'SERVER_PORT'     => '8002',
        'SERVER_PROTOCOL' => 'HTTP/1.1',
        'REMOTE_ADDR'     => '10.1.2.3',
        'REMOTE_USER'     => 'apiuser',
        'HTTP_HOST'       => '127.0.0.1:8002',
    }
);
is( $res->[0], 204, 'OIDC RP deleted' ) or diag explain $res->[2];

$conf = lastConf();
is( $conf->{cfgNum},      $before->{cfgNum} + 2, 'New configuration stored' );
is( $conf->{cfgAuthor},   'apiuser',  'Author is the web server user' );
is( $conf->{cfgAuthorIP}, '10.1.2.3', 'Author IP is set' );
is(
    $conf->{cfgLog},
    '[API] DELETE /api/v1/providers/oidc/rp/metadatarp',
    'confKey is not repeated when already in the path'
);

# Clean up generated files, except for "lmConf-1.json"
unlink grep { $_ ne "$main::tmpdir/conf/lmConf-1.json" }
  glob "$main::tmpdir/conf/lmConf-*.json";

done_testing();
