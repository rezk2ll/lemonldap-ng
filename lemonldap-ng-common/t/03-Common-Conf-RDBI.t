use warnings;

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Manager.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use Test::More tests => 22;
use JSON;
use utf8;

BEGIN {
    use_ok('Lemonldap::NG::Common::Conf');
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $h;
@ARGV = ("help=groups");
unlink 't/rdbiConf.sql';

SKIP: {
    eval { require DBI; require DBD::SQLite::Constants; };
    skip( "DBI not installed", 13 ) if ($@);
    my $skipSQLite = 0;

    ok(
        $h = new Lemonldap::NG::Common::Conf( {
                type        => 'RDBI',
                dbiChain    => "DBI:SQLite:dbname=t/rdbiConf.sql",
                dbiUser     => '',
                dbiPassword => '',
            }
        ),
        'RDBI object'
    );

    ok( $h->can('_dbh'), 'Driver is build' );
    eval { require DBD::SQLite };
    skip( "DBD::SQLite not installed", 11 ) if ($@);
    ok(
        $h->_dbh->do(
"CREATE TABLE lmConfig ( cfgNum int not null, field varchar(255) NOT NULL DEFAULT '', value longblob, PRIMARY KEY (cfgNum,field))"
        ),
        'Test database created'
    );

    my @test = (

        #  simple ascii
        {
            cfgNum               => 1,
            test                 => 'ascii',
            globalStorageOptions => { opt1 => 'ascii' }
        },

        #  utf-8
        {
            cfgNum               => 2,
            test                 => 'Русский',
            globalStorageOptions => { opt1 => 'Русский' }
        },

        #  compatible utf8/latin-1 char but with different codes
        { cfgNum => 3, test => 'éà', globalStorageOptions => { opt1 => 'éà' } }
    );

    my $dbh = DBI->connect(
        'DBI:SQLite:dbname=t/rdbiConf.sql',
        '', '',
        {
            sqlite_unicode => 1,
        }
    );
    for ( my $i = 0 ; $i < @test ; $i++ ) {
        ok( $h->store( $test[$i] ) == $i + 1, "Test $i is stored" )
          or print STDERR "$Lemonldap::NG::Common::Conf::msg $!";
        my $cfg;
        ok( $cfg = $h->load( $i + 1 ), "Test $i can be read" )
          or print STDERR $Lemonldap::NG::Common::Conf::msg;
        ok( $cfg->{test} eq $test[$i]->{test},
            "Test $i is restored from initial Perl value" );
        ok(
            $cfg->{globalStorageOptions}->{opt1} eq
              $test[$i]->{globalStorageOptions}->{opt1},
            "Test $i is restored from initial Perl value"
        );

        # Check data inside sqlite directly
        my @row = $dbh->selectrow_array(
                "select value from lmConfig where cfgNum='$test[$i]->{cfgNum}'"
              . " and field='test'" );
        my $value = $row[0];
        is(
            $value,
            $test[$i]->{test},
            "Value stored in sqlite is correctly encoded"
        );

        my @row2 = $dbh->selectrow_array(
                "select value from lmConfig where cfgNum='$test[$i]->{cfgNum}'"
              . " and field='globalStorageOptions'" );
        my $value2 = from_json( $row2[0] );
        is(
            $value2->{opt1},
            $test[$i]->{globalStorageOptions}->{opt1},
            "Hash value stored in sqlite is correctly encoded"
        );
    }

    unlink 't/rdbiConf.sql';
}

