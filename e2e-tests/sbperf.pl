#!/usr/bin/perl

use strict;
use DBI;
use JSON qw(from_json to_json);
use Time::HiRes;
use LWP::UserAgent;
use Redis;

system 'make stop_web_server';

Redis->new->flushall;

my $tests = {

    (
        $ENV{LLNGTESTLDAP}
        ? (
            LDAP => {
                cmd => 'cd lemonldap-ng-portal;perl t/test-ldap.pm;cd -',
                globalStorage        => 'Apache::Session::Browseable::LDAP',
                globalStorageOptions => {
                    ldapServer       => 'ldap://localhost:19389',
                    ldapBindDN       => 'cn=admin,dc=example,dc=com',
                    ldapBindPassword => 'admin',
                    ldapConfBase     => 'ou=sessions,dc=example,dc=com',
                    Index            => '_whatToTrace _session_kind'
                },
            }
          )
        : ()
    ),
    Redis => {
        globalStorage        => 'Apache::Session::Browseable::Redis',
        globalStorageOptions => {},
    },
    BRedis => {
        globalStorage        => 'Apache::Session::Browseable::Redis',
        globalStorageOptions => {
            Index => '_whatToTrace _session_kind'
        },
    },
    Postgres => {
        globalStorage        => 'Apache::Session::Browseable::Postgres',
        globalStorageOptions => {
            DataSource => 'dbi:Pg:host=127.0.0.1;database=sessions',
            UserName   => 'sso',
            Password   => 'sso',
            Commit     => 1,
        },
        pg => [
            'DROP TABLE IF EXISTS sessions',
            'DROP INDEX IF EXISTS uid1',
            'DROP INDEX IF EXISTS _s1',
'CREATE TABLE sessions (id varchar(64) not null primary key, a_session text)',
        ],
    },
    UPostgres => {
        globalStorage        => 'Apache::Session::Browseable::Postgres',
        globalStorageOptions => {
            DataSource => 'dbi:Pg:host=127.0.0.1;database=sessions',
            UserName   => 'sso',
            Password   => 'sso',
            Commit     => 1,
        },
        pg => [
            'DROP TABLE IF EXISTS sessions',
            'DROP INDEX IF EXISTS uid1',
            'DROP INDEX IF EXISTS _s1',
'CREATE UNLOGGED TABLE sessions (id varchar(64) not null primary key, a_session text)',
        ],
    },
    BPostgres => {
        globalStorage        => 'Apache::Session::Browseable::Postgres',
        globalStorageOptions => {
            DataSource => 'dbi:Pg:host=127.0.0.1;database=sessions',
            UserName   => 'sso',
            Password   => 'sso',
            Commit     => 1,
            Index      => '_whatToTrace _session_kind'
        },
        pg => [
            'DROP TABLE IF EXISTS sessions',
            'DROP INDEX IF EXISTS uid1',
            'DROP INDEX IF EXISTS _s1',
'CREATE UNLOGGED TABLE sessions (id varchar(64) not null primary key, a_session text, _whatToTrace text, _session_kind text)',
            'CREATE INDEX uid1 ON sessions (_whatToTrace)',
            'CREATE INDEX _s1 ON sessions (_session_kind)',
        ],
    },
    PgHstore => {
        globalStorage        => 'Apache::Session::Browseable::PgHstore',
        globalStorageOptions => {
            DataSource => 'dbi:Pg:host=127.0.0.1;database=sessions',
            UserName   => 'sso',
            Password   => 'sso',
            Commit     => 1,
        },
        pg => [
            'DROP TABLE IF EXISTS sessions',
            'DROP INDEX IF EXISTS uid1',
            'DROP INDEX IF EXISTS _s1',
'CREATE UNLOGGED TABLE sessions (id varchar(64) not null primary key, a_session hstore)',
        ],
    },

    PgJSON => {
        globalStorage        => 'Apache::Session::Browseable::PgJSON',
        globalStorageOptions => {
            DataSource => 'dbi:Pg:host=127.0.0.1;database=sessions',
            UserName   => 'sso',
            Password   => 'sso',
            Commit     => 1,
        },
        pg => [
            'DROP TABLE IF EXISTS sessions',
            'DROP INDEX IF EXISTS uid1',
            'DROP INDEX IF EXISTS _s1',
'CREATE UNLOGGED TABLE sessions (id varchar(64) not null primary key, a_session json)',
        ],
    },
};

my $times = {};

foreach my $name ( keys %$tests ) {
    my $opts = $tests->{$name}->{globalStorageOptions};
    if ( my $cmd = delete $tests->{$name}->{cmd} ) {
        system $cmd;
    }
    if ( my $cmd = delete $tests->{$name}->{pg} ) {
        my $dbh = DBI->connect( $opts->{DataSource}, $opts->{UserName},
            $opts->{Password}, { RaiseError => 1, AutoCommit => 1 } );
        foreach (@$cmd) {
            print STDERR "$_\n";
            $dbh->do($_);
        }
        $dbh->disconnect;
    }
    system 'make start_web_server';
    print STDERR "Removing manager protection\n";
    system
q(perl -i -pe 's/protection\s*=\s*manager/protection=none/' e2e-tests/conf/lemonldap-ng.ini);
    print STDERR "Read conf\n";
    open F, 'e2e-tests/conf/lmConf-1.json' or die;
    my $conf = join '', <F>;
    close F;
    $conf = from_json($conf);

    foreach my $k ( keys %{ $tests->{$name} } ) {
        $conf->{$k} = $tests->{$name}->{$k};
    }
    print STDERR "Write conf\n";
    open F, '>e2e-tests/conf/lmConf-1.json' or die;
    print F to_json($conf);
    close F;

    #system 'cat e2e-tests/conf/lmConf-1.json';
    sleep(1);
    system 'make reload_web_server';

    my $t = Time::HiRes::time();
    system './e2e-tests/populate.pl';
    $times->{$name}->{insert} = Time::HiRes::time() - $t;

    my $ua = LWP::UserAgent->new;
    $ua->get('http://manager.example.com:19876/sessions.html');
    $t = Time::HiRes::time();
    my $res = $ua->get(
'http://manager.example.com:19876/manager.fcgi/sessions/global?groupBy=substr(_whatToTrace,1)'
    );
    $times->{$name}->{read} = Time::HiRes::time() - $t;
    $res = from_json( $res->content );
    my $letter = $res->{values}->[0]->{value};
    $t   = Time::HiRes::time();
    $res = $ua->get(
'http://manager.example.com:19876/manager.fcgi/sessions/global?_whatToTrace='
          . $letter
          . '*&groupBy=_whatToTrace' );
    $times->{$name}->{getLetter} = Time::HiRes::time() - $t;
    $res = from_json( $res->content );
    my $user = $res->{values}->[0]->{value};
    $t   = Time::HiRes::time();
    $res = $ua->get(
'http://manager.example.com:19876/manager.fcgi/sessions/global?_whatToTrace='
          . $user );
    $times->{$name}->{getUid} = Time::HiRes::time() - $t;
    $res = from_json( $res->content );
    my $id = $res->{values}->[0]->{session};
    $t   = Time::HiRes::time();
    $res = $ua->get(
        'http://manager.example.com:19876/manager.fcgi/sessions/global/'
          . $id );
    $times->{$name}->{getSession} = Time::HiRes::time() - $t;
    $res = from_json( $res->content );
    system 'make stop_web_server';
}

if ( $ENV{LLNGTESTLDAP} ) {
    if ( open F, 'lemonldap-ng-portal/t/testslapd/slapd.pid' ) {
        my $pid = join '', <F>;
        system "kill $pid";
    }
    system 'rm -rf lemonldap-ng-portal/t/testslapd/slapd.d';
    system 'rm -rf lemonldap-ng-portal/t/testslapd/data';
    system 'rm -rf lemonldap-ng-portal/t/testslapd/slapd-test.ldif';
}

#use Data::Dumper;
#print Dumper($times);

print <<EOT;
+-----------+-----------------------+-----------------------------+
|           |         Main use      |       Session explorer      |
|  Backend  | Insert 1000 |  Get 1  |Parse all| 1 letter|  1 user |
+-----------+-----------------------+-----------------------------+
EOT
foreach my $type ( keys %$times ) {
    printf "|%10s |%11.5f  | %.5f | %.5f | %.5f | %.5f |\n", $type,
      map { $times->{$type}->{$_} } qw(insert getSession read getLetter getUid);
}
print "+-----------+-----------------------+-----------------------------+\n";
