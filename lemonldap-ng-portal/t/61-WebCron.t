use warnings;
use Test::More;
use strict;
use IO::String;
use Time::Fake;

BEGIN {
    require 't/test-lib.pm';
}

my $client;
ok( (
        $client = LLNG::Manager::Test->new( {
                ini => {
                    authentication => 'Demo',
                    userDB         => 'Same',
                    timeout        => 59,
                    webCronSecret  => 'secret',
                }
            }
        )
    ),
    'Able to load WebCron'
);

ok( $client->login('dwho') );
Time::Fake->offset('+1m');
ok( $client->login('dwho') );

ok( &sessionNumber == 2, 'Two sessions in db' );
my $res = $client->_post( '/webcron/purge', IO::String->new('secret=secret'), length => 13, );
expectOK($res);
ok( &sessionNumber == 1, 'One sessions in db' );

sub sessionNumber {
    my $r = 0;
    opendir D, $client->p->conf->{globalStorageOptions}->{Directory};
    while ( my $f = readdir D ) {
        next unless $f =~ /^[0-9a-f]{64}$/;
        $r++;
    }
    close D;
    return $r;
}

clean_sessions();
done_testing();
