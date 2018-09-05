use Test::More;
use strict;
use IO::String;
use Data::Dumper;

require 't/test-lib.pm';
my $maintests = 3;

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel             => 'error',
            ext2fActivation      => 1,
            ext2FSendCommand     => 't/sendOTP.pl -uid $uid',
            ext2FValidateCommand => 't/vrfyOTP.pl -uid $uid -code $code',
        }
    }
);
my $res;

# Try to authenticate
# -------------------
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23,
        accept => 'text/html',
    ),
    'Auth query'
);
my ( $host, $url, $query ) = expectForm( $res, undef, '/ext2fcheck', 'token' );

ok(
    $res->[2]->[0] =~
qr%<input name="code" value="" class="form-control" id="extcode" trplaceholder="code">%,
    'Found EXTCODE input'
) or print STDERR Dumper( $res->[2]->[0] );

$query =~ s/code=/code=123456/;
ok(
    $res = $client->_post(
        '/ext2fcheck',
        IO::String->new($query),
        length => length($query),
    ),
    'Post code'
);
my $id = expectCookie($res);
$client->logout($id);

count($maintests);

clean_sessions();

done_testing( count() );

