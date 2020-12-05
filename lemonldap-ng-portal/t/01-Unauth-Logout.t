use Test::More;
use strict;

require 't/test-lib.pm';

my $res;
my $client = LLNG::Manager::Test->new(
    { ini => { logLevel => 'debug', useSafeJail => 1 } } );

# Test normal first access
ok(
    $res = $client->_get(
        '/',
        query  => 'logout',
        accept => 'text/html'
    ),
    'Get logout page'
);
ok( $res->[2]->[0] =~ m%<span id="languages"></span>%, ' Language icons found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ m%<div class="message message-positive alert"><span trmsg="47">%, ' PE_LOGOUT_OK' )
  or print STDERR Dumper( $res->[2]->[0] );
expectCookie($res);
count(3);

#print STDERR Dumper($res);

clean_sessions();

done_testing( count() );
