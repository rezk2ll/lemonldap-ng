##@file
# Request manager

##@class Lemonldap::NG::Manager::Request
# Request manager
package Lemonldap::NG::Manager::Request;

use strict;
use Convert::PEM;
use Crypt::OpenSSL::RSA;
use JSON;
use MIME::Base64;
use URI::Escape;

##@method public string request(string request)
# Return the response corresponding to the request
# @param $request A request
# @return String
sub request {
    my ( $self, $rrequest ) = splice @_;
    my $request  = ${$rrequest};
    my $response = undef;

    #
    # GENERATE PRIVATE/PUBLIC KEYS
    #
    if ( $request =~ /generateKeys/i ) {
        my $password = $self->rparam('password');
        $password = $password ? ${$password} : undef;
        $response = $self->generateKeys($password);
    }
    if ( defined $response ) {
        $self->sendJSONResponse($response);
    }
}

##@method public hashref generateKeys(string password)
# Return a hashref containing private and public keys
# @param $password A password to protect the private key
# @return Hashref
sub generateKeys {
    my ( $self, $password ) = splice @_;
    my $rsa  = Crypt::OpenSSL::RSA->generate_key(2048);
    my $keys = undef;
    %$keys = (
        'private' => $rsa->get_private_key_string(),
        'public'  => $rsa->get_public_key_x509_string(),
    );
    if ($password) {
        my $pem = Convert::PEM->new(
            Name => 'RSA PRIVATE KEY',
            ASN  => qq(
                RSAPrivateKey SEQUENCE {
                    version INTEGER,
                    n INTEGER,
                    e INTEGER,
                    d INTEGER,
                    p INTEGER,
                    q INTEGER,
                    dp INTEGER,
                    dq INTEGER,
                    iqmp INTEGER
    }
               )
        );
        my %param = ();
        $param{Content}  = $keys->{private};
        $param{Content}  = $pem->decode(%param);
        $param{Password} = $password;
        $keys->{private} = $pem->encode(%param);
    }
    return $keys;
}

##@method public void sendJSONResponse(string content)
# Write to standard output a complete HTTP response, in JSON format
# @param $content The content to sent
# @return Void
sub sendJSONResponse {
    my ( $self, $content ) = splice @_;
    my $json         = new JSON();
    my $json_content = '';

    # All systems do not have the most recent JSON version.
    # We should take care of version 1 (RedHat 5) and version 2 (Debian 5).
    if ( $JSON::VERSION lt 2 ) {
        local $JSON::UTF8 = 1;
        $json_content = $json->objToJson( [$content] );
        $json_content =~ s/^\[//;
        $json_content =~ s/\]$//;
    }
    else {
        $json = $json->allow_nonref( ['1'] );
        $json = $json->utf8(         ['1'] );
        $json_content = $json->encode($content);
    }
    my $http_content = '{"status":"OK", "content":' . $json_content . '}';
    print $self->header(
        -type           => 'text/html; charset=utf-8',
        -Content_Length => length $http_content
    ) . $http_content;
}

1;
