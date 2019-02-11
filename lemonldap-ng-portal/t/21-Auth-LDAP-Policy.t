use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

use lib 't/lib';

my $res;
my $maintests = 16;

SKIP: {
    skip( 'LLNGTESTLDAP is not set', $maintests ) unless ( $ENV{LLNGTESTLDAP} );
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
      'PE_PP_PASSWORD_EXPIRED', 'PE_PASSWORD_OK', 'PE_PP_ACCOUNT_LOCKED';
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
        ok( $res->[2]->[0] =~ /$match/, "Code is $code" );

        #open F, '>../e2e-tests/conf/portal/result.html' or die $!;
        #print F $res->[2]->[0];
        #close F;
        my ( $host, $url, $query ) =
          expectForm( $res, '#', undef, 'user', 'oldpassword', 'newpassword',
            'confirmpassword' );
        ok( $query =~ /user=$user/, "User is $user" )
          or explain( $query, "user=$user" );
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
        $match = 'trmsg="' . PE_PASSWORD_OK . '"';
        ok( $res->[2]->[0] =~ /$match/, 'Password is changed' );

        $postString = "user=$user&password=newp";
        ok(
            $res = $client->_post(
                '/', IO::String->new($postString),
                length => length($postString),
            ),
            'Auth query'
        );
        expectCookie($res) or print STDERR Dumper($res);
    }
    my $user       = 'lock';
    my $code       = PE_PP_ACCOUNT_LOCKED;
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
    ok( $res->[2]->[0] =~ /$match/, 'Account is locked' );

    # Try to change anyway
    my $query =
      'user=lock&oldpassword=lock&newpassword=newp&confirmpassword=newp';
    ok(
        $res = $client->_post(
            '/', IO::String->new($query),
            length => length($query),
            accept => 'text/html',
        ),
        'Post new password'
    );
    $match = 'trmsg="' . PE_PASSWORD_OK . '"';
    ok( $res->[2]->[0] !~ /$match/s, 'Password is not changed' );

    #print STDERR Dumper($res);
}
count($maintests);
clean_sessions();
stopLdapServer() if $ENV{LLNGTESTLDAP};
done_testing( count() );
