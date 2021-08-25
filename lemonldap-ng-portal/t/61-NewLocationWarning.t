use Test::More;
use strict;
use IO::String;

BEGIN {
    eval {
        require 't/test-lib.pm';
        require 't/smtp.pm';
    };
}

my $res;
my $maintests = 16;

SKIP: {
    eval 'require Email::Sender::Simple;';
    if ($@) {
        skip 'Missing dependencies', $maintests;
    }

    my $client = LLNG::Manager::Test->new( {
            ini => {
                logLevel             => 'error',
                useSafeJail          => 1,
                authentication       => 'Demo',
                userDB               => 'Same',
                passwordDB           => 'Demo',
                captcha_mail_enabled => 0,
                portalMainLogo       => 'common/logos/logo_llng_old.png',
                newLocationWarning   => 1,
                loginHistoryEnabled  => 1
            }
        }
    );

    ## Simple access
    ok( $res = $client->_get( '/', accept => 'text/html' ), 'Get Portal', );
    my ( $host, $url, $query ) =
      expectForm( $res, '#', undef, 'user', 'password' );

    ## Authentication #1 with IP #1 (Test 1)
    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=dwho'),
            length => 23,
            accept => 'text/html',
        ),
        'First auth query'
    );
    my $id = expectCookie($res);
    $client->logout($id);

    ## Authentication #2 with IP #1 (Test 2)
    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=dwho'),
            length => 23,
            accept => 'text/html',
        ),
        'Second auth query'
    );
    $id = expectCookie($res);
    expectRedirection( $res, 'http://auth.example.com/' );
    $client->logout($id);

    ## Authentication #3 with IP #2 (Test 3)
    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=dwho'),
            length => 23,
            accept => 'text/html',
            ip     => '127.0.0.2',
        ),
        'Third auth query'
    );
    $id = expectCookie($res);
    expectRedirection( $res, 'http://auth.example.com/' );
    $client->logout($id);
    like(
        mail(),
qr#<h3><span>Your account was signed in to from a new location\.</span></h3></br>
#, ' Mail sent (Good password)'
    );

    ## Authentication #4 with IP #1 wrong password (Test 4)
    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=ohwd'),
            length => 23,
            accept => 'text/html',
        ),
        'Fourth auth query'
    );
    ok( $res->[2]->[0] =~ /<span trmsg="5"><\/span>/, ' Bad credential' )
      or print STDERR Dumper( $res->[2]->[0] );

    ## Authentication #5 with IP #2 (Test 5)
    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=ohwd'),
            length => 23,
            accept => 'text/html',
            ip     => '127.0.0.3',
        ),
        'Fifth auth query'
    );
    ok( $res->[2]->[0] =~ /<span trmsg="5"><\/span>/, ' Bad credential' )
      or print STDERR Dumper( $res->[2]->[0] );
    like(
        subject(),
        qr#\[LemonLDAP::NG\] Sign-in from a new location#,
        ' Subject found'
    );
    like(
        mail(),
qr#<h3><span>Your account was signed in to from a new location\.</span></h3></br>#,
        ' Mail sent (Wrong password)'
    );
    like(
        mail(),
        qr#<span>Host</span> <b>auth.example.com</b>#,
        ' Host found in mail body'
    );
    like(
        mail(),
        qr#<span>Date</span> <b>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}</b>#,
        ' Date found in mail body'
    );
    like(
        mail(),
qr#<span>UA</span> <b>Mozilla/5\.0 \(VAX-4000; rv:36\.0\) Gecko/20350101 Firefox</b></br>#,
        ' UserAgent found in mail body'
    );

    ## Authentication #5 with IP #2 (Test 5)
    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=ohwd'),
            length => 23,
            accept => 'text/html',
            ip     => '127.0.0.1',
        ),
        'Fifth auth query'
    );
    ok( $res->[2]->[0] =~ /<span trmsg="5"><\/span>/, ' Bad credential' )
      or print STDERR Dumper( $res->[2]->[0] );
}

count($maintests);
clean_sessions();
done_testing( count() );
