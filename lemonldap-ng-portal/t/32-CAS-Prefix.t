use warnings;
use lib 'inc';
use Test::More;
use strict;
use IO::String;
use LWP::UserAgent;
use LWP::Protocol::PSGI;
use MIME::Base64;

BEGIN {
    require 't/test-lib.pm';
    require 't/cas-lib.pm';
}

my $debug = 'error';
my ( $issuer, $res );

eval { require XML::Simple };
plan skip_all => "Missing dependencies: $@" if ($@);

subtest "Test CAS service matching without strict mode" => sub {

    # Login
    ok( $issuer = issuer(), 'Issuer portal' );
    my $id = $issuer->login("dwho");

    ok( $issuer->casGetTicket( $id, 'http://auth.sp.com/srv1/index.php' ),
        "Service 1 is matched by URI" );
    expectPortalError( $issuer->casLogin( $id, 'http://auth.sp.com/srv0' ),
        84, "Service is matched by hostname to denied catch-all" );
    ok( $issuer->casGetTicket( $id, 'http://auth.other.com/srv2' ),
        "Service 2 is matched by hostname" );
    ok(
        $issuer->casGetTicket( $id, 'http://auth.sp.com/srv4/index.php' ),
        "Service defined with multiple URLs is matched by URI"
    );
};

subtest "Test CAS service matching with strict mode" => sub {
    ok( $issuer = issuer(1), 'Issuer portal' );
    my $id = $issuer->login("dwho");

    ok( $issuer->casGetTicket( $id, 'http://auth.sp.com/srv1/index.php' ),
        "Service 1 is matched by URI" );
    expectPortalError( $issuer->casLogin( $id, 'http://auth.sp.com/srv0' ),
        84, "Service non-existing suffix matched by shorter URI" );
    expectPortalError( $issuer->casLogin( $id, 'http://auth.other.com/srv2' ),
        107, "Service is not matched by hostname" );
    ok(
        $issuer->casGetTicket( $id, 'http://auth.sp.com/srv4/index.php' ),
        "Service defined with multiple URLs is matched by URI"
    );
};

subtest "Unit test matchFull method" => sub {
    my $cas = $issuer->p->loadedModules->{'Lemonldap::NG::Portal::Issuer::CAS'};
    my @matchFull = (
        [ "http://test.com/xxx",    "http://test.com/xxx",     1 ],
        [ "http://test.com/xxx",    "http://test.com/xxx/yyy", 1 ],
        [ "http://test.com/xxx",    "http://test.com/xxxyyy",  1 ],
        [ "http://test.com:80/xxx", "http://test.com/xxx",     1 ],
        [ "http://test.com/xxx",    "http://test.comm/xxx",    0 ],
        [ "http://test.com/xxx",    "http://test.com/yyy",     0 ],
        [ "https://test.com/xxx",   "http://test.com/xxx",     0 ],
        [ "http://test.com/xxx",    "https://test.com/xxx",    0 ],
        [ "http://test.com/xxx",    "https://test.com/xxx",    0 ],
        [ "http://test.com",        "http://test.com/xxx",     1 ],
        [ "http://test.com",        "http://test.com",         1 ],
        [ "http://test.com",        "http://test.comm",        0 ],
        [ "urn:test",               "urn:test",                1 ],
        [ "urn:test",               "urn:test2",               0 ],
        [ "urn:test2",              "urn:test",                0 ],
    );

    for (@matchFull) {
        is(
            $cas->matchFull(
                URI->new( $_->[0] )->canonical,
                URI->new( $_->[1] )->canonical,
              )
              || 0,
            $_->[2],
            "Trying to match service URI "
              . $_->[1]
              . " against candidate "
              . $_->[0]
        );
    }
};

subtest "Unit test matchHost method" => sub {
    my $cas = $issuer->p->loadedModules->{'Lemonldap::NG::Portal::Issuer::CAS'};
    my @matchHost = (
        [ "http://test.com/xxx",     "http://test.com/yyy",     1 ],
        [ "https://test.com/xxx",    "http://test.com/yyy",     1 ],
        [ "http://test.com/xxx",     "https://test.com/yyy",    1 ],
        [ "http://test.com:80/xxx",  "http://test.com/xxx",     1 ],
        [ "http://test.com/xxx",     "http://test2.com/yyy",    0 ],
        [ "http://test.com/xxx",     "http://www.test.com/yyy", 0 ],
        [ "http://test.com/xxx",     "http://test.com.fr/yyy",  0 ],
        [ "http://www.test.com/xxx", "http://test.com/yyy",     0 ],
        [ "urn:test",                "urn:test",                1 ],
        [ "urn:test",                "urn:test2",               0 ],
        [ "urn:test2",               "urn:test",                0 ],
    );

    for (@matchHost) {
        is(
            $cas->matchHost(
                URI->new( $_->[0] )->canonical,
                URI->new( $_->[1] )->canonical,
              )
              || 0,
            $_->[2],
            "Trying to match service URI "
              . $_->[1]
              . " against candidate "
              . $_->[0]
        );
    }
};

clean_sessions();
done_testing();

sub issuer {
    my ($strict) = @_;
    return LLNG::Manager::Test->new( {
            ini => {
                logLevel              => $debug,
                domain                => 'idp.com',
                portal                => 'http://auth.idp.com',
                authentication        => 'Demo',
                userDB                => 'Same',
                issuerDBCASActivation => 1,
                casAttr               => 'uid',
                casStrictMatching     => $strict,
                casAppMetaDataOptions => {
                    sp1 => {
                        casAppMetaDataOptionsService =>
                          'https://auth.other.com/xxxyz',
                        casAppMetaDataOptionsRule => "1",
                    },
                    sp2 => {
                        casAppMetaDataOptionsService => 'http://auth.sp.com/',
                        casAppMetaDataOptionsRule    => "0",
                    },
                    sp3 => {
                        casAppMetaDataOptionsService =>
                          'http://auth.sp.com/srv1/',
                        casAppMetaDataOptionsRule => "1",
                    },
                    sp4 => {
                        casAppMetaDataOptionsService =>
                          'http://auth.sp.com/srv2/',
                        casAppMetaDataOptionsRule => "0",
                    },
                    sp5 => {
                        casAppMetaDataOptionsService =>
'http://auth.sp.com/srv3/ http://auth.sp.com/srv4/ http://auth.sp.com/srv5/',
                        casAppMetaDataOptionsRule => "1",
                    },
                },
                casAccessControlPolicy => 'error',
                multiValuesSeparator   => ';',
            }
        }
    );
}
