use warnings;
use Test::More;
use IO::String;
use URI;
use JSON;
use Lemonldap::NG::Portal::Main::Constants ':all';
use strict;

our $id;

BEGIN {
    require 't/test-lib.pm';
    eval "use GSSAPI";
}

SKIP: {
    eval "require GSSAPI";
    if ($@) {
        skip 'GSSAPI not found';
    }
    my $client = LLNG::Manager::Test->new( {
            ini => {
                authentication      => 'Choice',
                restSessionServer   => 1,
                requireToken        => 1,
                userDB              => 'Same',
                krbKeytab           => '/etc/keytab',
                krbByJs             => 1,
                'authChoiceModules' => {
                    '1_Kerberos' => 'Kerberos;Demo;Null;;;{}',
                    '2_Demo'     => 'Demo;Demo;Null;;;{}'
                },
            }
        }
    );
    my ( $res, $pdata );

    ok(
        $res = $client->_get(
            '/', accept => 'text/html'
        ),
        'Try to login'
    );
    expectPortalError( $res, 9, "Prompted to authenticate" );

    ok( !getJsVars($res)->{krbDone}, "Krb not marked as done" );

    my ( $host, $tmp, $query ) =
      expectForm( $res, '#', undef, 'url', 'kerberos', 'ajax_auth_token' );

    # Fail using invalid Kerberos user (#3639)
    $main::id = 'nobody@example.com';
    ok(
        $res = $client->_get(
            '/authkrb',
            accept => 'application/json',
            custom => { HTTP_AUTHORIZATION => 'Negotiate c29tZXRoaW5n' },
        ),
        'AJAX query'
    );

    my $json = expectJSON($res);
    ok( $json->{ajax_auth_token}, "User token was returned" );
    my $ajax_auth_token = $json->{ajax_auth_token};

    $query =~ s/ajax_auth_token=/ajax_auth_token=$ajax_auth_token/;
    $query =~ s/lmAuth=\w+/lmAuth=1_Kerberos/;

    ok(
        $res = $client->_post(
            '/', IO::String->new($query),
            length => length($query),
            accept => 'text/html',
        ),
        'Post form'
    );

    # User "nobody" was not found
    expectPortalError( $res, PE_BADCREDENTIALS );

    expectForm( $res, '#', undef, 'url', 'kerberos', 'ajax_auth_token' );

    ok( getJsVars($res)->{krbDone}, "Krb marked as done" );

    # Succeed using known user
    $main::id = 'dwho@example.com';
    ok(
        $res = $client->_get(
            '/authkrb',
            accept => 'application/json',
            custom => { HTTP_AUTHORIZATION => 'Negotiate c29tZXRoaW5n' },
        ),
        'AJAX query'
    );

    $json = expectJSON($res);
    ok( $json->{ajax_auth_token}, "User token was returned" );
    $ajax_auth_token = $json->{ajax_auth_token};

    $query =~ s/ajax_auth_token=[^&]*/ajax_auth_token=$ajax_auth_token/;
    $query =~ s/lmAuth=[^&]*/lmAuth=1_Kerberos/;

    ok(
        $res = $client->_post(
            '/', IO::String->new($query),
            length => length($query),
            accept => 'text/html',
        ),
        'Post form'
    );

    expectCookie($res);

}

clean_sessions();
done_testing();

# Redefine GSSAPI method for test
no warnings 'redefine';

sub GSSAPI::Context::accept ($$$$$$$$$$) {
    my $a = \@_;
    $a->[4] = bless {}, 'LLNG::GSSR';
    return 1;
}

package LLNG::GSSR;

sub display {
    my $a = \@_;
    $a->[1] = $main::id;
    return 1;
}
