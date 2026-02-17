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
my $lastAlertTypeIsBan;
my $lastAlertLogin;
my $lastAlertUri;
my $lastAlertHasDecisions;
my $lastAlertMessage;
my $lastAlertPreviousLogins;
my $lastAlertPreviousUris;
my $lastAlertPreviousCount;
my $lastAlertFirstAlert;
my $lastAlertLastAlert;

# Mock previous alerts for enrichment testing
my @mockPreviousAlerts;

LWP::Protocol::PSGI->register(
    sub {
        my $req = Lemonldap::NG::Portal::Main::Request->new(@_);
        if ( $req->path_info eq '/v1/watchers/login' ) {
            my $obj;
            subtest 'Request to login to Crowdsec server', sub {
                ok( $obj = $req->jsonBodyToObj,    'Content is JSON' );
                ok( $obj->{machine_id} eq 'llng',  'Good machine_id' );
                ok( $obj->{password} eq 'llngpwd', 'Good machine password' );
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
            if ( $req->method eq 'POST' ) {
                subtest 'Request to push alert', sub {
                    ok( $req->header('Authorization') eq 'Bearer aaabbb',
                        'Authentified request' );
                    my $obj;
                    ok( $obj = $req->jsonBodyToObj, 'Content is JSON' );
                    if ($obj) {
                        ok( (
                                      defined $obj->[0]
                                  and defined $obj->[0]->{remediation}
                            ),
                            'Type of alert is '
                              . ( $obj->[0]->{remediation} ? 'ban' : 'alert' )
                        );
                        $lastAlertTypeIsBan = $obj->[0]->{remediation};

                        # Check if decisions are present
                        $lastAlertHasDecisions =
                          ( $obj->[0]->{decisions}
                              and @{ $obj->[0]->{decisions} } ) ? 1 : 0;

                        # Extract message
                        $lastAlertMessage = $obj->[0]->{message};

                        # Extract login and uri and enrichment meta if present
                        $lastAlertLogin          = undef;
                        $lastAlertUri            = undef;
                        $lastAlertPreviousLogins = undef;
                        $lastAlertPreviousUris   = undef;
                        $lastAlertPreviousCount  = undef;
                        $lastAlertFirstAlert     = undef;
                        $lastAlertLastAlert      = undef;

                        if (    $obj->[0]->{events}
                            and $obj->[0]->{events}->[0]
                            and $obj->[0]->{events}->[0]->{meta} )
                        {
                            foreach
                              my $m ( @{ $obj->[0]->{events}->[0]->{meta} } )
                            {
                                $lastAlertLogin = $m->{value}
                                  if $m->{key} eq 'login';
                                $lastAlertUri = $m->{value}
                                  if $m->{key} eq 'uri';
                                $lastAlertPreviousLogins = $m->{value}
                                  if $m->{key} eq 'previous_logins';
                                $lastAlertPreviousUris = $m->{value}
                                  if $m->{key} eq 'previous_uris';
                                $lastAlertPreviousCount = $m->{value}
                                  if $m->{key} eq 'previous_alert_count';
                                $lastAlertFirstAlert = $m->{value}
                                  if $m->{key} eq 'first_alert';
                                $lastAlertLastAlert = $m->{value}
                                  if $m->{key} eq 'last_alert';
                            }
                        }
                    }
                    $ban++;
                };
                return [ 200, [], [] ];
            }
            else {
                subtest 'Request to get alerts list', sub {
                    pass("Ask for alert list");
                };

                # Return mock previous alerts for enrichment
                return [ 200, [], [ to_json( \@mockPreviousAlerts ) ] ];
            }
        }
        elsif ( $req->path_info eq '/v1/decisions' ) {
            return [ 200, [], [''] ];
        }
        fail( 'Unknown request ' . $req->path_info );
        return [ 500, [], [] ];
    }
);

my $client = LLNG::Manager::Test->new( {
        ini => {
            logLevel            => 'error',
            authentication      => 'Demo',
            userDB              => 'Same',
            crowdsecMachineId   => 'llng',
            crowdsecPassword    => 'llngpwd',
            crowdsecAgent       => 1,
            crowdsecFilters     => 't/crowdsec-filters',
            crowdsecMaxFailures => 5,
            crowdsecBlockDelay  => 180,
        }
    }
);

subtest 'Crowdsec ban function', sub {
    my $crowdsec =
      $client->p->loadedModules->{
        'Lemonldap::NG::Portal::Plugins::CrowdSecAgent'};

    ok( $crowdsec->ban( '1.2.3.4', 'Test ban' ), 'Call to ban()' );
    ok( $ban == 1,                               'Ban received' );
    ok( $lastAlertTypeIsBan,                     'Alert type is "ban"' );
    ok( $lastAlertHasDecisions, 'Alert contains decisions array' );
};

subtest 'Report auth failures to Crowdsec', sub {
    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=bad'),
            length => 22,
        ),
        'Bad auth query'
    );
    expectReject($res);
    ok( $ban == 2,                 'Alert received' );
    ok( !$lastAlertTypeIsBan,      'Alert type is "alert"' );
    ok( !$lastAlertHasDecisions,   'Alert has no decisions (simple alert)' );
    ok( $lastAlertLogin eq 'dwho', 'Login "dwho" is in alert metadata' );
};

subtest 'Report unknown user to Crowdsec', sub {
    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=jdoe&password=bad'),
            length => 22,
        ),
        'Bad auth query'
    );
    expectReject($res);
    ok( $ban == 3,                 'Alert received' );
    ok( !$lastAlertTypeIsBan,      'Alert type is "alert"' );
    ok( $lastAlertLogin eq 'jdoe', 'Login "jdoe" is in alert metadata' );
};

our %badUrls = (
    'Filter in a sub-directory named url_1' => '/bb/.htaccess',
    'Filter type re in main directory'      => '/aa/phpmyadmin',
    'Filter type txt in main directory'     => '/config.php',
);
subtest 'Report bad urls to Crowdsec', sub {
    my $prevBan = $ban;
    foreach my $subtest ( sort keys %badUrls ) {
        my $url = $badUrls{$subtest};
        subtest $subtest => sub {
            ok( $res = $client->_get( $url, accept => 'text/html' ),
                "Test bad url $url" );
            ok( $res->[0] == 404, '404 not found' );
            ok( $res->[2]->[0] =~ /Not found/i )
              or explain( $res->[2], 'Not found' );
            ok( $ban == ++$prevBan,    "Bad url detected" );
            ok( $lastAlertUri eq $url, "URI '$url' is in alert metadata" );
        };
    }
};

subtest 'Whitelisted URL should not be blocked', sub {
    my $prevBan = $ban;

    # /allowed-phpmyadmin matches the phpmyadmin regex but is whitelisted
    ok( $res = $client->_get( '/allowed-phpmyadmin', accept => 'text/html' ),
        "Test whitelisted url /allowed-phpmyadmin" );
    ok( $res->[0] == 200, 'Got 200 OK (not blocked)' )
      or explain( $res, 'Expected 200' );
    ok( $ban == $prevBan, 'No alert sent for whitelisted URL' );
};

# Test ban trigger with crowdsecMaxFailures
# crowdsecMaxFailures=5, so we need 4 previous alerts to trigger ban on 5th
subtest 'Ban triggered after max failures', sub {

    # Setup mock previous alerts for IP 127.0.0.1 (4 alerts to trigger ban)
    my $now = time;
    @mockPreviousAlerts = ( {
            source   => { value => '127.0.0.1' },
            scenario => 'llng/badcredentials',
            start_at => strftime( "%Y-%m-%dT%H:%M:%SZ", gmtime( $now - 90 ) ),
            events   => [ {
                    meta => [ { key => 'login', value => 'attacker1' }, ]
                }
            ]
        },
        {
            source   => { value => '127.0.0.1' },
            scenario => 'llng/badcredentials',
            start_at => strftime( "%Y-%m-%dT%H:%M:%SZ", gmtime( $now - 60 ) ),
            events   => [ {
                    meta => [ { key => 'login', value => 'attacker2' }, ]
                }
            ]
        },
        {
            source   => { value => '127.0.0.1' },
            scenario => 'llng/badcredentials',
            start_at => strftime( "%Y-%m-%dT%H:%M:%SZ", gmtime( $now - 45 ) ),
            events   => [ {
                    meta => [ { key => 'login', value => 'attacker3' }, ]
                }
            ]
        },
        {
            source   => { value => '127.0.0.1' },
            scenario => 'llng/badcredentials',
            start_at => strftime( "%Y-%m-%dT%H:%M:%SZ", gmtime( $now - 30 ) ),
            events   => [ {
                    meta => [ { key => 'login', value => 'attacker4' }, ]
                }
            ]
        },
    );

    # This 5th failure should trigger a ban
    ok(
        $res = $client->_post(
            '/', IO::String->new('user=attacker5&password=bad'),
            length => 27,
        ),
        'Bad auth query (5th failure triggers ban)'
    );
    expectReject($res);

    ok( $lastAlertTypeIsBan,    'Alert type is "ban"' );
    ok( $lastAlertHasDecisions, 'Alert contains decisions array' );
    ok( $lastAlertLogin eq 'attacker5',
        'Current login "attacker5" is in metadata' );

    # Clean up mock alerts
    @mockPreviousAlerts = ();
};

# Test urlscan ban trigger
subtest 'URL scan ban triggered after max failures', sub {

    # Setup mock previous alerts for URL scan (4 alerts to trigger ban)
    my $now = time;
    @mockPreviousAlerts = ( {
            source   => { value => '127.0.0.1' },
            scenario => 'llng/urlscan',
            start_at => strftime( "%Y-%m-%dT%H:%M:%SZ", gmtime( $now - 90 ) ),
            events   => [ {
                    meta => [ { key => 'uri', value => '/wp-login.php' }, ]
                }
            ]
        },
        {
            source   => { value => '127.0.0.1' },
            scenario => 'llng/urlscan',
            start_at => strftime( "%Y-%m-%dT%H:%M:%SZ", gmtime( $now - 60 ) ),
            events   => [ {
                    meta => [ { key => 'uri', value => '/admin.php' }, ]
                }
            ]
        },
        {
            source   => { value => '127.0.0.1' },
            scenario => 'llng/urlscan',
            start_at => strftime( "%Y-%m-%dT%H:%M:%SZ", gmtime( $now - 45 ) ),
            events   => [ {
                    meta => [ { key => 'uri', value => '/.env' }, ]
                }
            ]
        },
        {
            source   => { value => '127.0.0.1' },
            scenario => 'llng/urlscan',
            start_at => strftime( "%Y-%m-%dT%H:%M:%SZ", gmtime( $now - 30 ) ),
            events   => [ {
                    meta => [ { key => 'uri', value => '/backup.sql' }, ]
                }
            ]
        },
    );

    # This 5th bad URL should trigger a ban
    ok( $res = $client->_get( '/.htaccess', accept => 'text/html' ),
        'Test bad url /.htaccess (5th triggers ban)' );
    ok( $res->[0] == 404, '404 not found' );

    ok( $lastAlertTypeIsBan,    'Alert type is "ban"' );
    ok( $lastAlertHasDecisions, 'Alert contains decisions array' );
    ok( $lastAlertUri eq '/.htaccess',
        'Current URI "/.htaccess" is in metadata' );

    # Clean up mock alerts
    @mockPreviousAlerts = ();
};

clean_sessions();

done_testing();
