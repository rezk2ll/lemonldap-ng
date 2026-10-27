use warnings;
use Test::More;
use strict;
use utf8;
use IO::String;
use Net::LDAP::LDIF;

require 't/test-lib.pm';

my $res;

SKIP: {
    skip 'No AD server given' unless ( $ENV{ADSERVER} );

    my $client = LLNG::Manager::Test->new( {
            ini => {
                logLevel        => 'error',
                useSafeJail     => 1,
                authentication  => 'AD',
                userDB          => 'Same',
                passwordDB      => 'AD',
                LDAPFilter      => $ENV{ADFILTER} || '(cn=$user)',
                ldapServer      => $ENV{ADSERVER},
                ldapBase        => $ENV{ADBASE},
                managerDn       => $ENV{MANAGERDN}       || '',
                managerPassword => $ENV{MANAGERPASSWORD} || '',
            }
        }
    );
    my $postString = 'user='
      . ( $ENV{ADACCOUNT} || 'dwho' )
      . '&password='
      . ( $ENV{ADPWD} || 'dwho' );

    # Try yo authenticate
    # -------------------
    ok(
        $res = $client->_post(
            '/', IO::String->new($postString),
            length => length($postString)
        ),
        'Auth query'
    );
    expectOK($res);
    my $id = expectCookie($res);
    $client->logout($id);

    clean_sessions();
}

subtest "Test special attribute processing" => sub {
    my $client = LLNG::Manager::Test->new( {
            ini => {
                logLevel         => 'error',
                useSafeJail      => 1,
                authentication   => 'AD',
                userDB           => 'Same',
                passwordDB       => 'AD',
                ldapExportedVars => {
                    'objectGuid' => 'objectGuid',
                    'logonHours' => 'logonHours',
                    uid          => 'samaccountname',
                },
                LDAPFilter      => $ENV{ADFILTER} || '(cn=$user)',
                ldapServer      => $ENV{ADSERVER},
                ldapBase        => $ENV{ADBASE},
                managerDn       => $ENV{MANAGERDN}       || '',
                managerPassword => $ENV{MANAGERPASSWORD} || '',
            }
        }
    );

    my $module =
      $client->p->loadedModules->{'Lemonldap::NG::Portal::UserDB::AD'};

    my $req = Lemonldap::NG::Portal::Main::Request->new(
        { PATH_INFO => "", REQUEST_URI => "/" } );

    my $ldap = bless( {}, 'Lemonldap::NG::Portal::Lib::Net::LDAP' );
    $module->ldap($ldap);

    my $ldif = <<'LDIF';
dn: samaccountname=jlemon,ou=People,dc=example,dc=com
objectClass: inetOrgPerson
cn:: Sm9obiDwn42L
mail: john.doe@example.com
samaccountname: jlemon
logonHours:: AAAAwP8DwP8DwP8DwP8DwP8DAAAA
objectGUID:: uCofjcERrEW+O85PYnZ1BA==
LDIF

    my $fh          = IO::String->new($ldif);
    my $ldif_parser = Net::LDAP::LDIF->new( $fh, 'r', raw => $module->raw )
      or die "Cannot parse LDIF";

    $req->data->{ldapentry} = $ldif_parser->read_entry()
      or die "Cannot read entry";
    $module->setSessionInfo($req);
    is(
        $req->sessionInfo->{'logonHours'},
        '00000003ffc003ffc003ffc003ffc003ffc0000000',
        "logonHours correctly parsed"
    );
    is(
        $req->sessionInfo->{'objectGuid'},
        '8d1f2ab8-11c1-45ac-be3b-ce4f62767504',
        "objectGuid correctly parsed"
    );
    is( $req->sessionInfo->{'cn'}, "John \x{1f34b}", "Correct UTF-8 handling" );

};

done_testing();
