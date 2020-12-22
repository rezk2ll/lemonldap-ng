use Test::More;
use strict;
use JSON;
use IO::String;

require 't/test-lib.pm';

my $res;
my $maintests = 34;

my $userdb = tempdb();

SKIP: {
    eval { require DBI; require DBD::SQLite; };
    if ($@) {
        skip 'DBD::SQLite not found', $maintests;
    }
    my $res;
    my $json;
    my $request;
    my $dbh = DBI->connect("dbi:SQLite:dbname=$userdb");
    $dbh->do(
'CREATE TABLE users (user text,password text,name text, type text, guy text)'
    );
    $dbh->do(
        "INSERT INTO users VALUES ('dwho','dwho','Doctor who', 'serie', 'good')"
    );
    $dbh->do(
"INSERT INTO users VALUES ('rtyler','rtyler','Rose Tyler', 'serie', 'good')"
    );
    $dbh->do(
        "INSERT INTO users VALUES ('davros','davros','Davros', 'serie', 'bad')"
    );
    $dbh->do(
"INSERT INTO users VALUES ('msmith','msmith','Mr Smith', 'serie', 'good')"
    );
    $dbh->do(
        "INSERT INTO users VALUES ('spoke','spoke','Mr Spoke', 'movie', 'good')"
    );
    my $client = LLNG::Manager::Test->new( {
            ini => {
                logLevel              => 'error',
                useSafeJail           => 1,
                authentication        => 'DBI',
                userDB                => 'Same',
                dbiAuthChain          => "dbi:SQLite:dbname=$userdb",
                dbiAuthUser           => '',
                dbiAuthPassword       => '',
                dbiAuthTable          => 'users',
                dbiAuthLoginCol       => 'user',
                dbiAuthPasswordCol    => 'password',
                dbiAuthPasswordHash   => '',
                dbiDynamicHashEnabled => 0,
                passwordDB            => 'DBI',
                requireToken          => 1,
                findUser              => 1,
                impersonationRule     => 1,
                findUserSearchingAttributes =>
                  { user => 'Login', guy => 'Kind' },
                findUserExcludingAttributes => { type => 'movie' },
            }
        }
    );

    ## Simple access
    ok( $res = $client->_get( '/', accept => 'text/html' ), 'Get Portal', );
    my ( $host, $url, $query ) =
      expectForm( $res, '#', undef, 'user', 'password', 'spoofId', 'token' );

    $request = 'user=dwho';
    ok(
        $res = $client->_post(
            '/finduser', IO::String->new($request),
            accept => 'text/html',
            length => length($request)
        ),
        'Post FindFuser request'
    );
    ( $host, $url, $query ) =
      expectForm( $res, '#', undef, 'user', 'password', 'spoofId', 'token' );
    ok( $res->[2]->[0] =~ m%value="dwho"%, 'value="dwho"' )
      or explain( $res->[2]->[0], 'value="dwho"' );
    ok( $res->[2]->[0] =~ m%autocomplete="off"%, 'autocomplete="off"' )
      or explain( $res->[2]->[0], 'autocomplete="off"' );
    ok( $res->[2]->[0] =~ m%<span trspan="searchAccount">Search an account</span>%, 'Search an account' )
      or explain( $res->[2]->[0], 'Search an account' );
    ok(
        $res->[2]->[0] =~
m%<input id="findUserguy" name="guy" type="text" autocomplete="off" class="form-control" placeholder="Kind" />%,
        'id="findUserguy"'
    ) or explain( $res->[2]->[0], 'id="findUserguy"' );
    ok(
        $res->[2]->[0] =~
m%<input id="findUseruser" name="user" type="text" autocomplete="off" class="form-control" placeholder="Login" />%,
        'id="findUseruser"'
    ) or explain( $res->[2]->[0], 'id="findUseruser"' );

    $request = 'user=dwho';
    ok(
        $res = $client->_post(
            '/finduser', IO::String->new($request),
            accept => 'application/json',
            length => length($request)
        ),
        'Post FindFuser request'
    );
    ok( $json = eval { from_json( $res->[2]->[0] ) }, 'Response is JSON' )
      or print STDERR "$@\n" . Dumper($res);
    ok( $json->{user} eq 'dwho', ' Good user' )
      or explain( $json, 'user => dwho' );

    $request = 'user=dwo';
    ok(
        $res = $client->_post(
            '/finduser', IO::String->new($request),
            accept => 'application/json',
            length => length($request)
        ),
        'Post FindFuser request no result'
    );
    ok( $json = eval { from_json( $res->[2]->[0] ) }, 'Response is JSON' )
      or print STDERR "$@\n" . Dumper($res);
    ok( $json->{user} eq '', ' No user' )
      or explain( $json, "user => ''" );

    $request = 'guy=bad';
    ok(
        $res = $client->_post(
            '/finduser', IO::String->new($request),
            accept => 'application/json',
            length => length($request)
        ),
        'Post FindFuser request one result'
    );
    ok( $json = eval { from_json( $res->[2]->[0] ) }, 'Response is JSON' )
      or print STDERR "$@\n" . Dumper($res);
    ok( $json->{user} eq 'davros', ' Good user' )
      or explain( $json, "user => 'davros'" );

    $request = 'guy=good&type=serie';
    ok(
        $res = $client->_post(
            '/finduser', IO::String->new($request),
            accept => 'application/json',
            length => length($request)
        ),
        'Post FindFuser request multi results'
    );
    ok( $json = eval { from_json( $res->[2]->[0] ) }, 'Response is JSON' )
      or print STDERR "$@\n" . Dumper($res);
    ok( $json->{user} =~ /^(dwho|rtyler|msmith)$/, " Good user ($1)" )
      or explain( $json, "user => $1" );

    $request = 'arg=good';
    ok(
        $res = $client->_post(
            '/finduser', IO::String->new($request),
            accept => 'application/json',
            length => length($request)
        ),
        'Post FindFuser request with bad arg'
    );
    ok( $json = eval { from_json( $res->[2]->[0] ) }, 'Response is JSON' )
      or print STDERR "$@\n" . Dumper($res);
    ok( $json->{result} == 1, ' Good result' )
      or explain( $json, 'result => 1' );
    ok( $json->{user} eq '', ' No user' )
      or explain( $json, 'user => ?' );

    $request = 'guy=good&user=msmith';
    ok(
        $res = $client->_post(
            '/finduser', IO::String->new($request),
            accept => 'application/json',
            length => length($request)
        ),
        'Post FindFuser request with two args'
    );
    ok( $json = eval { from_json( $res->[2]->[0] ) }, 'Response is JSON' )
      or print STDERR "$@\n" . Dumper($res);
    ok( $json->{user} eq 'msmith', ' Good user' )
      or explain( $json, 'user => msmith' );

    $request = 'guy=bad&user=msmith';
    ok(
        $res = $client->_post(
            '/finduser', IO::String->new($request),
            accept => 'application/json',
            length => length($request)
        ),
        'Post FindFuser request with wrong args'
    );
    ok( $json = eval { from_json( $res->[2]->[0] ) }, 'Response is JSON' )
      or print STDERR "$@\n" . Dumper($res);
    ok( $json->{result} == 1, ' Good result' )
      or explain( $json, 'result => 1' );
    ok( $json->{user} eq '', ' No user' )
      or explain( $json, 'user => ?' );

    $request = 'user=spoke&type=good';
    ok(
        $res = $client->_post(
            '/finduser', IO::String->new($request),
            accept => 'application/json',
            length => length($request)
        ),
        'Post FindFuser request with excluding result'
    );
    ok( $json = eval { from_json( $res->[2]->[0] ) }, 'Response is JSON' )
      or print STDERR "$@\n" . Dumper($res);
    ok( $json->{result} == 1, ' Good result' )
      or explain( $json, 'result => 1' );
    ok( $json->{user} eq '', ' No user' )
      or explain( $json, 'user => ?' );
}
count($maintests);
done_testing( count() );
