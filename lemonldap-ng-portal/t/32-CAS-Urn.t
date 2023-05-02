use warnings;
use lib 'inc';
use Test::More;    # skip_all => 'CAS is in rebuild';
use strict;

BEGIN {
    require 't/test-lib.pm';
    require 't/cas-lib.pm';
}

my $debug = 'error';
my ( $issuer, $res );

ok( $issuer = issuer(), 'Issuer portal' );
count(1);

my $idpId = $issuer->login('french');

# Request to an unknown service is rejected
expectPortalError( $issuer->casLogin( $idpId, 'urn:my:app2' ),
    107, "Unknown CAS service" );

# Get a ticket for CAS application
$issuer->casGetAndValidateTicketSuccess( $idpId, "urn:my:app" );

clean_sessions();
done_testing( count() );

sub issuer {
    return LLNG::Manager::Test->new( {
            ini => {
                logLevel              => $debug,
                domain                => 'idp.com',
                portal                => 'http://auth.idp.com',
                issuerDBCASActivation => 1,
                casAppMetaDataOptions => {
                    sp => {
                        casAppMetaDataOptionsService => 'urn:my:app',
                    },
                },
                casAppMetaDataExportedVars => {
                    sp => {
                        cn   => 'cn',
                        mail => 'mail',
                        uid  => 'uid',
                    },
                },
                casAccessControlPolicy => 'error',
            }
        }
    );
}

