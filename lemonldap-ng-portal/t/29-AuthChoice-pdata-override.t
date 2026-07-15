use warnings;
use Test::More;
use IO::String;
use strict;

BEGIN {
    require 't/test-lib.pm';
    eval "use GSSAPI";
}

# A module returning PE_SENDRESPONSE (here Kerberos answering 401 Negotiate
# with krbByJs=0) leaves _choice in pdata: Auth::Choice only deletes it when
# the module returns a positive error. That leftover must not override the
# choice explicitly submitted by the user, otherwise the failed module is
# retried forever and no other choice can be used.

my $maintests = 6;

SKIP: {
    eval { require GSSAPI };
    if ($@) {
        skip 'GSSAPI not found', $maintests;
    }

    my $keytab = tempdb();

    my $client = LLNG::Manager::Test->new( {
            ini => {
                logLevel          => 'error',
                authentication    => 'Choice',
                userDB            => 'Same',
                krbKeytab         => $keytab,
                krbByJs           => 0,
                authChoiceParam   => 'lmAuth',
                authChoiceModules => {
                    'kerb' => 'Kerberos;Demo;Demo;;;{}',
                    'demo' => 'Demo;Demo;Demo;;;{}',
                },
            }
        }
    );

    my $res;

    ok( $res = $client->_get( '/', accept => 'text/html' ), 'Get portal' );
    expectOK($res);

    # Choose Kerberos: it has no ticket, answers 401 and returns
    # PE_SENDRESPONSE, leaving _choice in pdata
    my $query = 'user=&password=&lmAuth=kerb';
    ok(
        $res = $client->_post(
            '/', IO::String->new($query),
            length => length($query),
            accept => 'text/html',
        ),
        'Post Kerberos choice'
    );
    is( $res->[0], 401, 'Kerberos initiates negotiation' );

    my $pdata = getCookies($res)->{lemonldappdata};
    ok( $pdata, 'pdata cookie is set' );

    # Give up on Kerberos and use the other choice instead
    $query = 'user=dwho&password=dwho&lmAuth=demo';
    ok(
        $res = $client->_post(
            '/',
            IO::String->new($query),
            length => length($query),
            accept => 'text/html',
            cookie => "lemonldappdata=$pdata",
        ),
        'Post Demo choice with Kerberos left in pdata'
    );

    my $id = expectCookie($res);
    ok( $id, 'Submitted choice wins over the one left in pdata' );

    $client->logout($id);
}

count($maintests);
done_testing( count() );
