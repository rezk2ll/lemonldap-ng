use Test::More;
use t::TestPsgi;
use Plack::Test;
use HTTP::Request::Common;

subtest "Check logging API" => sub {
    my $args = { logger => 't::TestLogger', userLogger => 't::TestLogger' };
    my $psgi = new_ok( 't::TestPsgi' => [$args] );
    $psgi->init($args);

    my $server = Plack::Test->create( $psgi->run );

    my $res = $server->request( GET "/" );
    is( $res->code, 200, "Returned HTTP code 200" );
    $psgi->logger->contains( "notice", "Request handled by TestPsgi handler" );
    $psgi->userLogger->contains( "info", "User logger trace" );
};

done_testing();
