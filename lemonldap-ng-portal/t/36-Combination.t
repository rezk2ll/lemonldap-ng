use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;
my $mainTests = 0;
my $client;

eval { unlink 't/userdb.db' };

SKIP: {
    eval { require DBI; require DBD::SQLite; };
    if ($@) {
        skip 'DBD::SQLite not found', $mainTests;
    }
    my $dbh = DBI->connect("dbi:SQLite:dbname=t/userdb.db");
    $dbh->do('CREATE TABLE users (user text,password text,name text)');
    $dbh->do("INSERT INTO users VALUES ('test1','test1','Test user 1')");

    $client = iniCmb('[Dm] or [DB]');
    my $res = try('dwho');
    expectCookie($res);

    $res = try('test1');
    expectCookie($res);
}
count($mainTests);
clean_sessions();
eval { unlink 't/userdb.db' };
done_testing( count() );

sub try {
    my $user = shift;
    my $s    = "user=$user&password=$user";
    my $res;
    ok(
        $res = $client->_post( '/', IO::String->new($s), length => length($s) ),
        "Test $user"
    );
    count(1);
    return $res;
}

sub iniCmb {
    my $expr = shift;
    my $res;
    return LLNG::Manager::Test->new(
        {
            ini => {
                logLevel       => 'debug',
                useSafeJail    => 1,
                authentication => 'Combination',
                userDB         => 'Same',

                combination => $expr,
                combModules => [
                    {
                        for  => 0,
                        name => 'DB',
                        type => 'DBI',
                    },
                    {
                        for  => 0,
                        name => 'Dm',
                        type => 'Demo',
                    },
                ],

                dbiAuthChain        => 'dbi:SQLite:dbname=t/userdb.db',
                dbiAuthUser         => '',
                dbiAuthPassword     => '',
                dbiAuthTable        => 'users',
                dbiAuthLoginCol     => 'user',
                dbiAuthPasswordCol  => 'password',
                dbiAuthPasswordHash => '',
                dbiExportedVars     => {},
                demoExportedVars    => {},
            }
        }
    );
}
