use warnings;
use Test::More;
use strict;
use IO::String;
use File::Copy;
use HTTP::Request::Common;
use utf8;

use Lemonldap::NG::Portal::Main::Constants;

BEGIN {
    eval {
        require 't/test-lib.pm';
        require 't/smtp.pm';
    };
}

my ( $res, $user );
my $maintests = 12;

SKIP: {
    eval
'require Email::Sender::Simple; use GD::SecurityImage; use Image::Magick; use Net::SSLeay;
use DateTime::Format::RFC3339;';
    if ($@) {
        skip 'Missing dependencies ' . $@, $maintests;

    }

    my $client = LLNG::Manager::Test->new( {
            ini => {
                logLevel              => 'error',
                useSafeJail           => 1,
                portalDisplayRegister => 1,
                authentication        => 'SSL',
                userDB                => 'Demo',
                passwordDB            => 'Demo',
                registerDB            => 'Custom',
                customRegister        => '::Register::Demo',
                customResetCertByMail => '::CertificateResetByMail::Demo',
                captcha_mail_enabled  => 0,
                portalDisplayCertificateResetByMail        => 1,
                certificateResetByMailCeaAttribute         => 'description',
                certificateResetByMailCertificateAttribute =>
                  'userCertificate;binary',
                certificateResetByMailURL => 'http://other.example.com/certif',
                certificateValidityDelay  => 30
            }
        }
    );

    # Test form
    # ------------------------
    ok( $res = $client->_get( '/certificateReset', accept => 'text/html' ),
        'Reset form', );
    my ( $host, $url, $query ) = expectForm( $res, '#', undef, 'mail' );

    $query = 'mail=dwho%40badwolf.org';

    # Post email
    ok(
        $res = $client->_post(
            '/certificateReset', IO::String->new($query),
            length => length($query),
            accept => 'text/html'
        ),
        'Post mail'
    );

    ok( mail() =~ m#http://other\.example\.com/certif\?(.*)#,
        'Found link in mail' )
      or explain( mail(), 'Found link in mail 1' );

    my $querymail = $query = $1;

    ok(
        $res = $client->_get(
            '/certificateReset',
            query  => $query,
            accept => 'text/html'
        ),
        'Post mail token received by mail'
    );

    # print STDERR Dumper($res);

    ( $host, $url, $query ) = expectForm( $res, '#', undef, 'token' );
    ok( $res->[2]->[0] =~ /certif/s, ' Ask for a new certificate file' );

    #print STDERR Dumper($query);
    my %inputs   = split /=/, ( grep /^token=.+/, split /&/, $query )[0];
    my %querytab = split /[=&]/, $querymail;

    # Create the certificate  file
    my $cert = "-----BEGIN CERTIFICATE-----
MIIDdzCCAl+gAwIBAgIJAKGx8siw7lkRMA0GCSqGSIb3DQEBCwUAMFExCzAJBgNV
BAYTAkZSMQ8wDQYDVQQIDAZGcmFuY2UxDjAMBgNVBAcMBVBBcmlzMREwDwYDVQQK
DAhMaW5hZ29yYTEOMAwGA1UECwwFTElOSUQwIBcNMTkwNzA0MTcyNjI4WhgPMjEx
OTA2MTAxNzI2MjhaMFExCzAJBgNVBAYTAkZSMQ8wDQYDVQQIDAZGcmFuY2UxDjAM
BgNVBAcMBVBBcmlzMREwDwYDVQQKDAhMaW5hZ29yYTEOMAwGA1UECwwFTElOSUQw
ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC3iyeNE2vpURgdY7xwxS16
xUJANPuMSrCfy1E/xpCtbP02zK0B11DkT81AnTHgvsWYuiubR1P3Phhh+JLsLRho
Grzu9xjaiKXQ+kT1cAiq6skZljphykXBfKUb73W9CPntHL/zl3XyIfu+dWyCGbqa
jHw0Llomi8JqU/XKB6XAYumsV3QzFMM7ECm5HeV3BxfIBwoIOwfwINDUrAGS3h4k
WH/iiqwG7uSuADupSfdmOrvE7rYZupPas4YATX1m5hmON++9pRRFVEoNeOV1qyGY
G7swH1uoO2hAgwKIw0vinft/pJLqe3qhrJwNCIZFHaDEx/PRERFeeEH9/6HSz5kt
AgMBAAGjUDBOMB0GA1UdDgQWBBTFv6pQT/9IBWEAGhILGCcweVfHmTAfBgNVHSME
GDAWgBTFv6pQT/9IBWEAGhILGCcweVfHmTAMBgNVHRMEBTADAQH/MA0GCSqGSIb3
DQEBCwUAA4IBAQBFYneMW5etMnsA3/PdvOqx/ijBF98aKlB4U4IKZpdDRAcsstdL
BSsHRQbHXtb9VdlDWvUnNg5DmjsA8DkOXKXGPGM9ncu9tQi9EoInbOJTMaEsIr2j
zrLj6PHTvazy+6Au+R/9N5u3WQtq/Z2xoN/+bbQ1dyjXgQmBZFizHP32l5AdgBDT
jF7xMHxJ6Jxz9lkI+d9v0TzpxTStsaC+pbDfoouNc2deZkv84YTIrD0EPSHFDH5d
u5i9b+lrWZeCtpVEPzSYpnBwGfepbZAzfVRKJm7wZPCe7KxqMGXQLVBkD8oN7vA1
lkRrWfQftwmLyNIu3HfSgXlgAZS30ymfbzBU
-----END CERTIFICATE-----";

    my $req = POST(
        "",
        Content_Type => 'form-data',
        Content      => [
            'skin'  => 'bootstrap',
            'url'   => '',
            'token' => $inputs{'token'},
            certif  => [
                undef, "user.pem",
                Content               => $cert,
                'content-disposition' =>
                  'form-data; name="certif"; filename="user.pem"',
                'content-type' => 'application/x-x509-ca-cert'
            ]
        ]
    );
    my $body = $req->content;

    $res = $client->_post(
        '/certificateReset', $body,
        type   => join( "; ", $req->content_type ),
        query  => $querymail,
        cookie => "llnglanguage=fr",
        accept => 'text/html'
    );

    like(
        mail(),
        qr/Votre certificat a bien été réinitialisé!/,
        'Certificate has been reset'
    );

    # Test invalid certificate

    # Test form
    # ------------------------
    ok( $res = $client->_get( '/certificateReset', accept => 'text/html' ),
        'Reset form', );
    ( $host, $url, $query ) = expectForm( $res, '#', undef, 'mail' );

    $query = 'mail=dwho%40badwolf.org';

    # Post email
    ok(
        $res = $client->_post(
            '/certificateReset', IO::String->new($query),
            length => length($query),
            accept => 'text/html'
        ),
        'Post mail'
    );
    ok( mail() =~ m#http://other\.example\.com/certif\?(.*)#,
        'Found link in mail' )
      or explain( mail(), 'Found link in mail 2' );
    $querymail = $query = $1;
    ok(
        $res = $client->_get(
            '/certificateReset',
            query  => $query,
            accept => 'text/html'
        ),
        'Post mail token received by mail'
    );

    # print STDERR Dumper($res);

    ( $host, $url, $query ) = expectForm( $res, '#', undef, 'token' );
    ok( $res->[2]->[0] =~ /certif/s, ' Ask for a new certificate file' );

    #print STDERR Dumper($query);
    %inputs   = split /=/, ( grep /^token=.+/, split /&/, $query )[0];
    %querytab = split( /[=&]/, $querymail );

    # Create the certificate  file
    $cert = "INVALID CERTIFICATE";

    $req = POST(
        "",
        Content_Type => 'form-data',
        Content      => [
            'skin'  => 'bootstrap',
            'url'   => '',
            'token' => $inputs{'token'},
            certif  => [
                undef, "user.pem",
                Content               => $cert,
                'content-disposition' =>
                  'form-data; name="certif"; filename="user.pem"',
                'content-type' => 'application/x-x509-ca-cert'
            ]
        ]
    );
    $body = $req->content;

    $res = $client->_post(
        '/certificateReset', $body,
        type   => join( "; ", $req->content_type ),
        query  => $querymail,
        cookie => "llnglanguage=fr",
        accept => 'text/html'
    );

    my $trmsg = $res->[2]->[0];               # get html response
    my @trmsg = split( /\n/, $trmsg );        # split into lines
    @trmsg = grep( /trmsg="/, @trmsg ); # only get line corresponding to message
    $trmsg = $trmsg[0];                 # get the first one only
    $trmsg =~ s/.*trmsg="([0-9]+)".*/$1/g;    # get error code number
    ok( $trmsg == PE_RESETCERTIFICATE_INVALID, 'Invalid certificate' );
}

count($maintests);
done_testing( count() );
