use Test::More tests => 2;
BEGIN { use_ok('Lemonldap::NG::Manager::_i18n') }

ok ( &compare ( "en", "fr" ) );

sub compare {
    my ( $l1, $l2 ) = @_;
    $r1 = &{"Lemonldap::NG::Manager::_i18n::" . $l1};
    $r2 = &{"Lemonldap::NG::Manager::_i18n::" . $l2};
    my $r = 1;
    foreach ( keys %$r1 ) {
        unless( $r2->{$_} ) {
            print STDERR "$_ is present in $l1 but miss in $l2";
            $r=0;
        }
    }
    foreach ( keys %$r2 ) {
        unless( $r1->{$_} ) {
            print STDERR "$_ is present in $l2 but miss in $l1";
            $r=0;
        }
    }
    return $r;
}
