#!/usr/bin/env perl -I pl/lib

use Test::More;
use JSON;
use Data::Dumper;
use MIME::Base64

  require 't/test-psgi-lib.pm';

init('Lemonldap::NG::Handler::PSGI');

my $res;

ok( $res = $client->_get('/'), 'Get http://test1.example.com/' );
ok( ref($res) eq 'ARRAY', 'Response is an array' ) or explain( $res, 'array' );
ok( $res->[0] == 302, 'Code is 302' ) or explain( $res->[0], 302 );
my %h = @{ $res->[1] };
ok(
    $h{Location} eq 'http://auth.example.com/?url='
      . encode_base64( 'http://test1.example.com/', '' ),
    'Redirection points to portal'
  )
  or explain(
    \%h,
    'Location => http://auth.example.com/?url='
      . encode_base64( 'http://test1.example.com/', '' )
  );

count(4);

done_testing( count() );
