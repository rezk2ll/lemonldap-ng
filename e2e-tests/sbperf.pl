#!/usr/bin/perl
#
# Session Backend Performance Test
# --------------------------------
#
# This test is used to compare different session backend. To use it, you have
# to:
#  * have a PostgreSQL database running on this host. PostgreSQL DB must have
#    * listen on 127.0.0.1:5432
#    * a database names "sessions"
#    * "hstore" extension enabled is database "sessions":
#        psql# CREATE EXTENSION hstore;
#    * a Pg user named "sso" identified by "sso" password
#    * "sso" user must have right to create tables in database "sessions"
#  * have a Redis server installed on this host listen on 127.0.0.1:6379
#
# If you want to enable LDAP test:
#  * set LLNGTESTLDAP environment variable to 1
#  * if OpenLDAP schemes aren't available in /etc/slapd/schema, set the scheme
#    directory in environment variables:
#      LLNGTESTLDAP_SCHEMA_DIR=/etc/ldap/schema
#  * prepare some coffee or tea
#  * open the window or light a fan
#  * launch the test, run away and come back 5mn later
#
#
# (c) Copyright: 2017, LemonLDAP::NG team
#
#This library is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2, or (at your option)
#any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see L<http://www.gnu.org/licenses/>.

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
            Index => '_whatToTrace _session_kind _utime'
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
            Index      => '_whatToTrace _session_kind _utime'
        },
        pg => [
            'DROP TABLE IF EXISTS sessions',
            'DROP INDEX IF EXISTS uid1',
            'DROP INDEX IF EXISTS _s1',
'CREATE UNLOGGED TABLE sessions (id varchar(64) not null primary key, a_session text, _whatToTrace text, _session_kind text, _utime bigint)',
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

    # Fix timeout to 2h
    $conf->{timeout} = 7200;
    print STDERR "Write conf\n";
    open F, '>e2e-tests/conf/lmConf-1.json' or die;
    print F to_json($conf);
    close F;

    #system 'cat e2e-tests/conf/lmConf-1.json';
    sleep(1);
    system 'make reload_web_server';

    # Insert 1000 sessions
    my $t = Time::HiRes::time();
    system './e2e-tests/populate.pl';
    $times->{$name}->{insert} = Time::HiRes::time() - $t;

    # Initialize manager
    my $ua = LWP::UserAgent->new;
    $ua->get('http://manager.example.com:19876/sessions.html');

    my $tmp = {
        read       => 0,
        getLetter  => 0,
        getUid     => 0,
        getSession => 0,
    };

    # First loop isn't used in averages
    foreach my $i ( 0 .. 10 ) {

        # Test first Session Explorer access
        $t = Time::HiRes::time();
        my $res = $ua->get(
'http://manager.example.com:19876/manager.fcgi/sessions/global?groupBy=substr(_whatToTrace,1)'
        );
        $tmp->{read} += Time::HiRes::time() - $t if ($i);
        $res = from_json( $res->content );

        # Partial "_whatToTrace" search
        my $letter = $res->{values}->[0]->{value};
        $t   = Time::HiRes::time();
        $res = $ua->get(
'http://manager.example.com:19876/manager.fcgi/sessions/global?_whatToTrace='
              . $letter
              . '*&groupBy=_whatToTrace' );
        $tmp->{getLetter} += Time::HiRes::time() - $t if ($i);
        $res = from_json( $res->content );

        # Search for an uid
        my $user = $res->{values}->[$i]->{value};
        $t   = Time::HiRes::time();
        $res = $ua->get(
'http://manager.example.com:19876/manager.fcgi/sessions/global?_whatToTrace='
              . $user );
        $tmp->{getUid} += Time::HiRes::time() - $t if ($i);
        $res = from_json( $res->content );

        # Get a session
        my $id = $res->{values}->[0]->{session};
        $t   = Time::HiRes::time();
        $res = $ua->get(
            'http://manager.example.com:19876/manager.fcgi/sessions/global/'
              . $id );
        $tmp->{getSession} += Time::HiRes::time() - $t if ($i);
        $res = from_json( $res->content );
    }

    # Average
    foreach my $type ( keys %$tmp ) {
        $times->{$name}->{$type} = $tmp->{$type} / 10;
    }

    # Purge half sessions
    $t = Time::HiRes::time();
    system 'LLNG_DEFAULTCONFFILE=e2e-tests/conf/lemonldap-ng.ini '
      . 'perl -Ilemonldap-ng-common/blib/lib '
      . 'lemonldap-ng-portal/site/cron/purgeCentralCache';
    $times->{$name}->{purge} = Time::HiRes::time() - $t;

    # Turn off webserver
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
+-----------+---------------------------------+-----------------------------+
|           |            Main use             |       Session explorer      |
|  Backend  | Insert 1000 |  Get 1  |Purge 500|Parse all| 1 letter|  1 user |
+-----------+---------------------------------+-----------------------------+
EOT
foreach my $type ( keys %$times ) {
    printf "|%10s |%11.5f  | %.5f | %7.4f | %.5f | %.5f | %.5f |\n", $type,
      map { $times->{$type}->{$_} }
      qw(insert getSession purge read getLetter getUid);
}
print
"+-----------+---------------------------------+-----------------------------+\n";
