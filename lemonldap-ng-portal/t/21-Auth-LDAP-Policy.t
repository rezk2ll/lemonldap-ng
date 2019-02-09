use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

use lib 't/lib';

my $res;
my $maintests = 3;

SKIP: {
    skip 'LLNGTESTLDAP is not set', $maintests unless ( $ENV{LLNGTESTLDAP} );
    require 't/test-ldap.pm';

    my $client = LLNG::Manager::Test->new( {
            ini => {
                logLevel                      => 'error',
                useSafeJail                   => 1,
                authentication                => 'LDAPPolicy',
                portal                        => 'http://auth.example.com/',
                userDB                        => 'LDAP',
                passwordDB                    => 'LDAP',
                portalRequireOldPassword      => 1,
                ldapServer                    => 'ldap://127.0.0.1:19389/',
                ldapBase                      => 'ou=users,dc=example,dc=com',
                managerDn                     => 'cn=admin,dc=example,dc=com',
                managerPassword               => 'admin',
                ldapAllowResetExpiredPassword => 1,
            }
        }
    );
    my $postString = 'user='
      . ( $ENV{LDAPACCOUNT} || 'dwho' )
      . '&password='
      . ( $ENV{LDAPPWD} || 'dwho' );

    # Try yo authenticate
    # -------------------
    ok(
        $res = $client->_post(
            '/', IO::String->new($postString),
            length => length($postString),
            accept => 'text/html',
        ),
        'Auth query'
    );
    my $match = 'trmsg="'
      . &Lemonldap::NG::Portal::Main::Constants::PE_PP_PASSWORD_EXPIRED . '"';
    ok( $res->[2]->[0] =~ /$match/, 'Password is expired' );

    #open F, '>../e2e-tests/conf/portal/result.html' or die $!;
    #print F $res->[2]->[0];
    #close F;
    my ( $host, $url, $query ) =
      expectForm( $res, '#', undef, 'user', 'oldpassword', 'newpassword',
        'confirmpassword' );
    ok( $query =~ /user=dwho/, 'User is dwho' )
      or explain( $query, 'user=dwho' );
    count(1);
    $query =~ s/(oldpassword)=/$1=dwho/g;
    $query =~ s/((?:confirm|new)password)=/$1=newp/g;
    ok(
        $res = $client->_post(
            '/', IO::String->new($query),
            length => length($query),
            accept => 'text/html',
        ),
        'Post new password'
    );
    $match = 'trmsg="'
      . &Lemonldap::NG::Portal::Main::Constants::PE_PP_PASSWORD_TOO_SHORT . '"';
    ok( $res->[2]->[0] =~ /$match/, 'Password is too short' );
    count(1);

    open F, '>../e2e-tests/conf/portal/result.html' or die $!;
    print F $res->[2]->[0];
    close F;
    ( $host, $url, $query ) =
      expectForm( $res, '#', undef, 'user', 'oldpassword', 'newpassword',
        'confirmpassword' );
    ok( $query =~ /user=dwho/, 'User is dwho' )
      or explain( $query, 'user=dwho' );
    count(1);
    $query =~ s/(oldpassword)=/$1=dwho/g;
    $query =~ s/((?:confirm|new)password)=/$1=newpassword/g;
    ok(
        $res = $client->_post(
            '/', IO::String->new($query),
            length => length($query),
            accept => 'text/html',
        ),
        'Post new password'
    );
    count(1);

    #print STDERR Dumper($res);
    my $id = expectCookie($res);
    expectRedirection( $res, 'http://auth.example.com/' );
    $client->logout($id);
}
clean_sessions();
count($maintests);
stopLdapServer() if $ENV{LLNGTESTLDAP};
done_testing( count() );
