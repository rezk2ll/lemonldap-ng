# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Manager.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use Test::More;

BEGIN {
    use_ok('DBI');
    use_ok('Lemonldap::NG::Common::Conf');
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $h;
@ARGV = ("help=groups");
unlink 't/lmConf.sql';
my $count = 2;

eval { require DBD::SQLite };
unless ($@) {
    require DBI;
    my $dbh = DBI->connect( "dbi:SQLite:dbname=t/lmConf.sql", '', '', {AutoCommit=>1} );
    $dbh->{sqlite_unicode} = 1;
    ok(
        $dbh->do(
' CREATE TABLE lmConfig ( cfgNum int not null primary key, data longblob)'
        ),
        'Database created'
    );
    undef $dbh;
    $count++;

    ok(
        $h = new Lemonldap::NG::Common::Conf(
            {
                type        => 'CDBI',
                dbiChain    => "DBI:SQLite:dbname=t/lmConf.sql",
                dbiUser     => '',
                dbiPassword => '',
            }
        ),
        'CDBI object'
    );

    ok( $h->can('_dbh'), 'Driver is build' );

    $count += 2;

    my @test = (

        #  simple ascii
        { cfgNum => 1, test => 'ascii' },

        #  utf-8
        { cfgNum => 2, test => 'Русский' },

        #  compatible utf8/latin-1 char but with different codes
        { cfgNum => 3, test => 'éà' }
    );

    for ( my $i = 0 ; $i < @test ; $i++ ) {
        ok( $h->store( $test[$i] ) == $i+1, "Test $i is stored" )
          or print STDERR "$Lemonldap::NG::Common::Conf::msg $!";
        $count++;
        my $cfg;
        ok( $cfg = $h->load($i+1), "Test $i can be read" )
          or print STDERR $Lemonldap::NG::Common::Conf::msg;
        ok( $cfg->{test} eq $test[$i]->{test}, "Test $i is restored" );
        $count += 2;
    }
}

unlink 't/lmConf.sql';

done_testing($count);

