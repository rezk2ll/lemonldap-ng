# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Portal-AuthSsl.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 5;
BEGIN { use_ok('Lemonldap::NG::Portal::Simple') }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

$ENV{"REQUEST_METHOD"} = 'GET';
my $p;
ok(
    $p = Lemonldap::NG::Portal::Simple->new(
        {
            globalStorage  => 'Apache::Session::File',
            domain         => 'example.com',
            authentication => 'OpenIDConnect',
            userDB         => 'OpenIDConnect',
            passwordDB     => 'Null',
            registerDB     => 'Null',
        }
    )
);

## JWT Signature verification
# Samples from http://jwt.io

$p->{OIDCRPClientSecret} = "secret";
my $jwt;

# alg: none
$jwt = "eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzdWIiOjEyMzQ1Njc4OTAsIm5hbWUiOiJKb2huIERvZSIsImFkbWluIjp0cnVlfQ.";
ok( $p->verifyJWTSignature($jwt) == 1, 'JWT Signature verification - alg: none');

# alg: HS256
$jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEyMzQ1Njc4OTAsIm5hbWUiOiJKb2huIERvZSIsImFkbWluIjp0cnVlfQ.eoaDVGTClRdfxUZXiPs3f8FmJDkDE_VCQFXqKxpLsts";
ok( $p->verifyJWTSignature($jwt) == 1, 'JWT Signature verification - alg: HS256');

# alg: HS512
$jwt = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEyMzQ1Njc4OTAsIm5hbWUiOiJKb2huIERvZSIsImFkbWluIjp0cnVlfQ.fSCfxDB4cFVvzd6IqiNTuItTYiv-tAp5u5XplJWRDBGNF1rgGn1gyYK9LuHobWWpwqCzI7pEHDlyrbNHaQJmqg";
ok( $p->verifyJWTSignature($jwt) == 1, 'JWT Signature verification - alg: HS512');

