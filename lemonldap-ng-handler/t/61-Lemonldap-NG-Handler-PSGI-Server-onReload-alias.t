use Test::More;

require 't/test-psgi-lib.pm';

init('Lemonldap::NG::Handler::Server');

# A callback that modifies $_ must not corrupt @_onReload
my $counter = ReloadCounter->new;
Lemonldap::NG::Handler::Main->onReload( $counter, 'doReload' );
{
    no warnings 'once';
    *ReloadCounter::doReload = sub {
        my ($self) = @_;
        $_ = 1;
        $self->counter( $self->counter + 1 );
    };
}

my $res;
foreach my $i ( 1 .. 2 ) {
    ok( $res = $client->_get('/reload'), "Reload query $i" );
    is( $res->[0],         200, "Reload $i returned 200" );
    is( $counter->counter, $i,  "Reload handler was called $i time(s)" );
    count(3);
}
ok(
    ( grep { ref($_) eq 'ARRAY' } @Lemonldap::NG::Handler::Main::_onReload ) ==
      @Lemonldap::NG::Handler::Main::_onReload,
    '@_onReload not corrupted'
);
count(1);

done_testing( count() );

clean();
