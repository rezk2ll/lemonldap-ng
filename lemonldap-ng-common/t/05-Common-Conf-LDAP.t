use warnings;

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Manager.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 16;
use utf8;

#########################

# Insert your test code below, the Test::More module is used here so read
# its man page ( perldoc Test::More ) for help writing this test script.

SKIP: {
    eval { require Net::LDAP; };
    skip "Net::LDAP is not installed, skipping tests", 16 if ($@);
    skip 'LLNGTESTLDAP is not set', 16 unless ( $ENV{LLNGTESTLDAP} );
    use_ok('Lemonldap::NG::Common::Conf');

    use File::Temp 'tempdir';
    our $tmpDir = tempdir( 'ldapserverXXXXXX', DIR => 't/', CLEANUP => 1 );
    require 't/test-ldap.pm';

    my $h;
    ok(
        $h = new Lemonldap::NG::Common::Conf( {
                type         => 'LDAP',
                ldapServer   => $main::slapd_url,
                ldapConfBase => 'ou=sessions,dc=example,dc=com',

                #ldapBindDN       => 'cn=lemonldapng,ou=dsa,dc=example,dc=com',
                ldapBindPassword => 'lemonldapng',
                ldapClientCert   => 'cert',
                ldapClientKey    => 'key',
            }
        ),
        "New object"
    ) or print STDERR "Error reported: " . $Lemonldap::NG::Common::Conf::msg;

    ok( ref($h) and $h->can('getLdapConnection'), 'Get LDAP' );

    my @test = (

        #  simple ascii
        { cfgNum => 1, test => 'ascii' },

        #  utf-8
        { cfgNum => 2, test => 'Русский' },

        #  compatible utf8/latin-1 char but with different codes
        { cfgNum => 3, test => 'éà' }
    );

    my $ldap = Net::LDAP->new( $main::slapd_url, raw => qr/(?i:;binary)/ );
    my $mesg = $ldap->bind( 'cn=lemonldapng,ou=dsa,dc=example,dc=com',
        password => 'lemonldapng' );
    is( $mesg->code, 0, "Connection to LDAP succeeded" );

    for ( my $i = 0 ; $i < @test ; $i++ ) {
        ok( $h->store( $test[$i] ) == $i + 1, "Test $i is stored" )
          or print STDERR "$Lemonldap::NG::Common::Conf::msg $!";
        my $cfg;
        ok( $cfg = $h->load( $i + 1 ), "Test $i can be read" )
          or print STDERR $Lemonldap::NG::Common::Conf::msg;
        is(
            $cfg->{test},
            $test[$i]->{test},
            "Test $i is restored from initial Perl value"
        );

        # Get binary data from sqlite directly
        $srch = $ldap->search(
            base   => "ou=sessions,dc=example,dc=com",
            filter => "cn=lmConf-$test[$i]->{cfgNum}"
        );
        my @values  = $srch->entry(0)->get_value("description");
        my ($value) = grep /^{test}/, @values;
        $value =~ s/^{test}//g;
        is(
            $value,
            $test[$i]->{test},
            "Value stored in LDAP is correctly encoded"
        );
    }
}
