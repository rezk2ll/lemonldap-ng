# Test for https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2493

use strict;
use Data::Dumper;
use IO::String;
use JSON qw(from_json);
use Test::More;

my $count     = 0;
my $file      = 't/conf.db';
my $maintests = 1;
my ( $res, $client );
eval { unlink $file };

sub count {
    my $c = shift;
    $count += $c if ($c);
    return $count;
}

SKIP: {
    eval { require DBI; require DBD::SQLite; };
    if ($@) {
        skip 'DBD::SQLite not found', $maintests;
    }

    my $dbh = DBI->connect("dbi:SQLite:dbname=$file");
    $dbh->do('CREATE TABLE lmConfig (cfgNum int, data text)')
      or die $DBI::errstr;
    {
        local $/ = undef;
        open my $f, '<', 't/conf/lmConf-1.json';
        my $content = <$f>;
        close $f;
        my $sth = $dbh->prepare('INSERT INTO lmConfig VALUES(1,?)')
          or die $DBI::errstr;
        $sth->execute($content) or die $DBI::errstr;
    }

    use_ok('Lemonldap::NG::Manager::Cli::Lib');
    ok(
        $client = Lemonldap::NG::Manager::Cli::Lib->new(
            iniFile => 't/lemonldap-ng-DBI-conf.ini'
        ),
        'Client object'
    );
    count(1);

    use_ok('Lemonldap::NG::Manager::Cli');
    count(1);

    my @args = (qw(-yes 1 -force 1 set ldapSetPassword 0));
    $ENV{LLNG_DEFAULTCONFFILE} = 't/lemonldap-ng-DBI-conf.ini';
    Lemonldap::NG::Manager::Cli->run(@args);
    my $res  = $dbh->selectall_arrayref('SELECT * FROM lmConfig');
    my $conf = from_json( $res->[0]->[1] );
    ok( (
            defined( $conf->{ldapSetPassword} )
              and $conf->{ldapSetPassword} == 0
        ),
        'Key inserted'
    );
    count(1);
}

eval { unlink $file };
done_testing( count($maintests) );
