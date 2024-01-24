use warnings;
use Test::More;
use strict;
use IO::String;
use MIME::Base64;
use URI;
use URI::QueryParam;

require 't/test-lib.pm';

my $res;

my $client = register(
    'client1',
    sub {
        LLNG::Manager::Test->new( {
                ini => {
                    portal => 'https://auth.example.com/',
                }
            }
        );
    }
);

my $client2 = register(
    'client2',
    sub {
        LLNG::Manager::Test->new( {
                ini => {
                    portal => 'https://auth.example2.com/',
                }
            }
        );
    }
);

switch ("client1");
is( Lemonldap::NG::Handler::Main->tsv->{portal}->(),
    'https://auth.example.com/' );
switch ("client2");
is( Lemonldap::NG::Handler::Main->tsv->{portal}->(),
    'https://auth.example2.com/' );
switch ("client1");
is( Lemonldap::NG::Handler::Main->tsv->{portal}->(),
    'https://auth.example.com/' );
switch ("client2");
is( Lemonldap::NG::Handler::Main->tsv->{portal}->(),
    'https://auth.example2.com/' );
count(4);

done_testing( count() );
