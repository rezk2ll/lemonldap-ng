use Test::More;
use JSON;
use Data::Dumper;
use MIME::Base64;
use LWP::UserAgent;

BEGIN {
    require 't/test-psgi-lib.pm';
}

init('Lemonldap::NG::Handler::Server');

my $res;

# Authorizated query
ok( $res = $client->_get( '/', undef, 'test3.example.com', "lemonldap=$sessionId", VHOSTTYPE => 'DevOps' ),
    'Authentified query' );
ok( $res->[0] == 200, 'Code is 200' ) or explain( $res->[0], 200 );

count(2);

done_testing( count() );

clean();

# Redefine LWP methods for tests
no warnings 'redefine';

sub LWP::UserAgent::request {
    my ( $self, $req ) = @_;
    my $httpResp;
    my $s = '{
  "rules": {
    "default": "accept"
  },
  "headers": {
    "User": "$uid"
  }
}';
    $httpResp = HTTP::Response->new( 200, 'OK' );
    $httpResp->header( 'Content-Type', 'application/json' );
    $httpResp->header( 'Content-Length', length($s) );
    $httpResp->content($s);
    return $httpResp;
}
