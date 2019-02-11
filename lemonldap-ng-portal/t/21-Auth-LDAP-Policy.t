use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

use lib 't/lib';

my $res;

SKIP: {
    skip 'LLNGTESTLDAP is not set' unless ( $ENV{LLNGTESTLDAP} );
    require 't/test-ldap.pm';

    my $client = LLNG::Manager::Test->new(
        {
            ini => {
                logLevel                      => 'error',
                useSafeJail                   => 1,
                authentication                => 'LDAP',
                portal                        => 'http://auth.example.com/',
                userDB                        => 'Same',
                passwordDB                    => 'LDAP',
                portalRequireOldPassword      => 1,
                ldapServer                    => 'ldap://127.0.0.1:19389/',
                ldapBase                      => 'ou=users,dc=example,dc=com',
                managerDn                     => 'cn=admin,dc=example,dc=com',
                managerPassword               => 'admin',
                ldapAllowResetExpiredPassword => 1,
                ldapPpolicyControl            => 1,
            }
        }
    );
    use Lemonldap::NG::Portal::Main::Constants 'PE_PP_CHANGE_AFTER_RESET',
      'PE_PP_PASSWORD_EXPIRED', 'PE_PASSWORD_OK';
    foreach my $tpl (
        [ 'reset',  PE_PP_CHANGE_AFTER_RESET ],
        [ 'expire', PE_PP_PASSWORD_EXPIRED ]
      )
    {
        my $user       = $tpl->[0];
        my $code       = $tpl->[1];
        my $postString = "user=$user&password=$user";

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
        my $match = 'trmsg="' . $code . '"';
        ok( $res->[2]->[0] =~ /$match/, 'Password is expired' );
        count(2);

        #open F, '>../e2e-tests/conf/portal/result.html' or die $!;
        #print F $res->[2]->[0];
        #close F;
        my ( $host, $url, $query ) =
          expectForm( $res, '#', undef, 'user', 'oldpassword', 'newpassword',
            'confirmpassword' );
        ok( $query =~ /user=$user/, "User is $user" )
          or explain( $query, "user=$user" );
        count(1);
        $query =~ s/(oldpassword)=/$1=$user/g;
        $query =~ s/((?:confirm|new)password)=/$1=newp/g;
        ok(
            $res = $client->_post(
                '/', IO::String->new($query),
                length => length($query),
                accept => 'text/html',
            ),
            'Post new password'
        );
        my $match = 'trmsg="' . PE_PASSWORD_OK . '"';
        ok( $res->[2]->[0] =~ /$match/, 'Password is changed' );
        count(2);

        $postString = "user=$user&password=newp";
        ok(
            $res = $client->_post(
                '/', IO::String->new($postString),
                length => length($postString),
            ),
            'Auth query'
        );
        count(1);
        expectCookie($res) or print STDERR Dumper($res);
    }
}
clean_sessions();
stopLdapServer() if $ENV{LLNGTESTLDAP};
done_testing( count() );
