# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Portal-AuthSsl.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 6;
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

# Sample from Google
$p->{OIDCRPJwksData}->{keys}->[0]->{kid} = "3d007677fec656a562826f0191d0f9fcb0e595cf";
$p->{OIDCRPJwksData}->{keys}->[0]->{n} = "3I_zvpLMNY9UY-SoVm60yh3CRB0LK0CdJ7qqF_Fl07LWNrWSudWSv1q-1QQGwQyxjzuD31eOouqp6gsMgJg6kyECUj9i6zUETCePy3kc-CAPUZE4vj-sJGA0qIcIrI54RdsLL6u27TKAkqqdl-XeO0S5fcUb3AaGW8TpmZoioEU=";
$p->{OIDCRPJwksData}->{keys}->[0]->{e} = "AQAB";

# alg: RS256
$jwt ="eyJhbGciOiJSUzI1NiIsImtpZCI6IjNkMDA3Njc3ZmVjNjU2YTU2MjgyNmYwMTkxZDBmOWZjYjBlNTk1Y2YifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwic3ViIjoiMTE1MzYxMjMwMzU3MzA0NzU0ODQ0IiwiYXpwIjoiMjg2MzA1NzI4NjUyLWxjYW5ubWRnMTdxM2VtdDFjYmtqbmZnOTVzZHM4NjJsLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiZW1haWwiOiJjbGVtZW50QG9vZG8ubmV0IiwiYXRfaGFzaCI6ImZRc0FaSHdsUUNPZXctNE84QkFWNWciLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXVkIjoiMjg2MzA1NzI4NjUyLWxjYW5ubWRnMTdxM2VtdDFjYmtqbmZnOTVzZHM4NjJsLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaGQiOiJvb2RvLm5ldCIsImlhdCI6MTQxNjQwNjA0MywiZXhwIjoxNDE2NDA5OTQzfQ.NihX-7P1ogpPCmygD-A-hChIwMg9hJQ_4gzu3zmNEyHnY9rWuwXF6E2K9LF_opMQXWJxkUcI7eyo73L3yk9_51CfQLzD5NbfpR6kyctLBXud9A7wyHzJRBCB_rOU12vU4bMWGajgkGUqOmy-PFnz3akvqVgExbqas0Go4Flg7NI";
ok( $p->verifyJWTSignature($jwt) == 1, 'JWT Signature verification - alg: RS256');
