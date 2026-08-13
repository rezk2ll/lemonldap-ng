use warnings;
use Test::More;
use strict;
use IO::String;
use JSON qw(from_json);
use LWP::UserAgent;
use LWP::Protocol::PSGI;

BEGIN {
    require 't/test-lib.pm';
}

my $captured_metrics_body;
my $metrics_hits = 0;

LWP::Protocol::PSGI->register(
    sub {
        my $req  = Plack::Request->new(@_);
        my $path = $req->path_info;
        if ( $path =~ m{/v1/usage-metrics} ) {
            $captured_metrics_body = $req->raw_body;
            $metrics_hits++;
            return [
                200, [ 'Content-Type' => 'application/json' ],
                ['{"message":"OK"}']
            ];
        }
        if ( $path =~ m{/v1/decisions} ) {
            my $res = '[{"duration":"1h2m10.462947715s",
  "id":1121,
  "origin":"CAPI",
  "scenario":"crowdsecurity/iptables-scan-multi_ports",
  "scope":"ip",
  "type":"ban",
  "value":"127.0.0.1/32"}]';
            return [ 200, [], [$res] ];
        }
        return [ 404, [], [''] ];
    }
);

my $res;

my $client = LLNG::Manager::Test->new( {
        ini => {
            authentication          => 'Demo',
            userDB                  => 'Same',
            crowdsec                => 1,
            crowdsecKey             => 'aaa',
            crowdsecAction          => 'reject',
            crowdsecMetricsEnabled  => 1,
            crowdsecMetricsInterval => 1,
        }
    }
);

ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23,
    ),
    'Auth query 1'
);
expectReject($res);

ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23,
    ),
    'Auth query 2'
);
expectReject($res);

# Wait so that the time-based flush triggers on the next request
sleep 2;

ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23,
    ),
    'Auth query 3 (should trigger metrics flush)'
);
expectReject($res);

ok( $metrics_hits >= 1,     'usage-metrics endpoint was called' );
ok( $captured_metrics_body, 'metrics body captured' );

my $payload = eval { from_json($captured_metrics_body) };
ok( !$@ && $payload, 'metrics body is valid JSON' )
  or diag("JSON error: $@ ; body: $captured_metrics_body");

my $rc = $payload->{remediation_components}->[0];
ok( $rc, 'remediation_components present' );
is( ref( $rc->{feature_flags} ), 'ARRAY', 'feature_flags is an array' );
ok( $rc->{utc_startup_timestamp} && $rc->{utc_startup_timestamp} > 0,
    'utc_startup_timestamp present' );
ok( ref( $rc->{os} ) eq 'HASH' && defined $rc->{os}->{name},
    'os.name present' );

my $meta = $rc->{metrics}->[0]->{meta};
ok( $meta && $meta->{utc_now_timestamp} > 0,    'utc_now_timestamp present' );
ok( $meta && $meta->{window_size_seconds} >= 1, 'window_size_seconds >= 1' );

my $items = $rc->{metrics}->[0]->{items};
ok( ref($items) eq 'ARRAY' && @$items, 'items array is present and non-empty' );
ok( ( !grep { ( $_->{unit} || '' ) ne 'request' } @$items ),
    'all items have unit=request' );

my ($processed) = grep { $_->{name} eq 'processed' } @$items;
ok( $processed,                             'processed item present' );
ok( $processed && $processed->{value} >= 1, 'processed value >= 1' );

my @drops = grep { $_->{name} eq 'dropped' } @$items;
ok( @drops >= 1, 'at least one dropped item' );

my ($capi_ipv4) = grep {
         $_->{labels}
      && $_->{labels}->{origin} eq 'CAPI'
      && $_->{labels}->{ip_type} eq 'ipv4'
} @drops;
ok( $capi_ipv4, 'dropped item with origin=CAPI, ip_type=ipv4 present' );

clean_sessions();
done_testing();
