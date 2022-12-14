use MIME::Base64;

use Test::More;
use strict;
use IO::String;
use DBI;
use Digest::SHA;

# Hook SHA512 function into all new DBI connections
{
    my $old_connect = \&DBI::connect;
    *DBI::connect = sub {
        my $connection = $old_connect->(@_) or return;

        $connection->sqlite_create_function(
            'sha256', 1,
            sub {
                my $p = shift;
                return
                  unpack( 'H*',
                    Digest::SHA->new(256)->add( pack( 'H*', $p ) )->digest );
            }
        );
        $connection->sqlite_create_function(
            'sha512', 1,
            sub {
                my $p = shift;
                return
                  unpack( 'H*',
                    Digest::SHA->new(512)->add( pack( 'H*', $p ) )->digest );
            }
        );

        return $connection;
    }
}

require 't/test-lib.pm';

my $res;
my $maintests = 6;

my $userdb = tempdb();

SKIP: {
    eval
'require DBD::SQLite; use Digest::SHA; use Lemonldap::NG::Portal::Lib::DBI';
    if ($@) {
        skip 'DBI/DBD::SQLite not found', $maintests;
    }

    my $dbh = DBI->connect("dbi:SQLite:dbname=$userdb");

    $dbh->do('CREATE TABLE users (user text,password text,name text)');

    # password secret1
    $dbh->do("INSERT INTO users VALUES ('dwho','secret1','Doctor who')");

    # password secret2
    $dbh->do(
"INSERT INTO users VALUES ('rtyler','{sha256}NSJNDTRl106FX41poTbnnHROo1pnXTOTNgoyfL9jWaI=','Rose Tyler')"
    );

    # password secret3
    $dbh->do(
"INSERT INTO users VALUES ('jsmith','{ssha512}wr0zU/I6f7U4bVoeOlJnNFbhF0a9np59LUeNnhokohVI/wiNzt8Y4JujfOfNQiGuiVgY+xrYggfmgpke6KdjxKS7W0GR1ZCe','John Smith')"
    );
    my $client = LLNG::Manager::Test->new( {
            ini => {
                logLevel                         => 'error',
                useSafeJail                      => 1,
                authentication                   => 'DBI',
                userDB                           => 'Same',
                dbiAuthChain                     => "dbi:SQLite:dbname=$userdb",
                dbiAuthUser                      => '',
                dbiAuthPassword                  => '',
                dbiAuthTable                     => 'users',
                dbiAuthLoginCol                  => 'user',
                dbiAuthPasswordCol               => 'password',
                dbiAuthPasswordHash              => '',
                dbiDynamicHashEnabled            => 1,
                dbiDynamicHashValidSchemes       => 'sha sha256 sha512',
                dbiDynamicHashValidSaltedSchemes => 'ssha ssha256 ssha512',
                dbiDynamicHashNewPasswordScheme  => 'ssha256',
                passwordDB                       => 'DBI',
                portalRequireOldPassword         => 1,
            }
        }
    );

    # Try to authenticate against plaintext password
    ok(
        $res = $client->_post(
            '/', IO::String->new('user=dwho&password=secret1'),
            length => 26
        ),
        'Authentication against plaintext password'
    );
    expectOK($res);
    my $id = expectCookie($res);
    $client->logout($id);

    # Try to authenticate against static hashed password
    ok(
        $res = $client->_post(
            '/', IO::String->new('user=rtyler&password=secret2'),
            length => 28
        ),
        'Authentication against static SHA-256 hashed password'
    );
    expectOK($res);
    $id = expectCookie($res);
    $client->logout($id);

    # Try to authenticate against salted password
    ok(
        $res = $client->_post(
            '/', IO::String->new('user=jsmith&password=secret3'),
            length => 28
        ),
        'Authentication against salted SHA-512 password'
    );
    expectOK($res);
    $id = expectCookie($res);

    # Try to modify password
    ok(
        $res = $client->_post(
            '/',
            IO::String->new(
'oldpassword=secret3&newpassword=secret4&confirmpassword=secret4'
            ),
            cookie => "lemonldap=$id",
            accept => 'application/json',
            length => 63
        ),
        'Change password'
    );
    expectOK($res);
    $client->logout($id);

    # Try to authenticate against new salted password
    ok(
        $res = $client->_post(
            '/', IO::String->new('user=jsmith&password=secret4'),
            length => 28
        ),
        'Authentication against newly-modified password'
    );
    expectOK($res);
    $id = expectCookie($res);

# Verify that password is hashed with correct scheme (dbiDynamicHashNewPasswordScheme)
    my $sth = $dbh->prepare("SELECT password FROM users WHERE user='jsmith';");
    $sth->execute();
    my $row = $sth->fetchrow_array;
    ok( $row =~ /^{ssha256}/,
        'Verify that password is hashed with correct scheme' );

    clean_sessions();
}
count($maintests);
done_testing( count() );
