use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;
my $mainTests = 0;

eval { unlink 't/userdb.db' };

SKIP: {
    eval { require DBI; require DBD::SQLite; };
    if ($@) {
        skip 'DBD::SQLite not found', $mainTests;
    }
    my $dbh = DBI->connect("dbi:SQLite:dbname=t/userdb.db");
    $dbh->do('CREATE TABLE users (user text,password text,name text)');
    $dbh->do("INSERT INTO users VALUES ('test','test','Test user')");

    my $client = LLNG::Manager::Test->new(
        {
            ini => {
                logLevel       => 'debug',
                useSafeJail    => 1,
                authentication => 'Combination',
                userDB         => 'Same',

                combination => '[DBI] or [Demo]',
                combModules => [
                    {
                        for => 0,
                        name => 'DBI',
                        type => 'DBI',
                    },
                    {
                        for => 0,
                        name => 'Demo',
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
                dbiExportedVars => {},
            }
        }
    );
}
count($mainTests);
eval { unlink 't/userdb.db' };
done_testing( count() );
