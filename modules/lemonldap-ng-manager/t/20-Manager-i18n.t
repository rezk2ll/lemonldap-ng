# Lemonldap::NG::Manager translation test
#
# Here, we test :
#   1) each keyword is translated in each language
#   2) display functions in english language

BEGIN {
    our %lang = (
        en => 'English',
        fr => 'French',
    );
    require Test::More;
    Test::More->import( tests => ( scalar keys(%lang) ) );
}

use_ok('Lemonldap::NG::Manager::_i18n');

foreach ( keys %lang ) {
    ok( &compare( "en", $_ ),
        "Compare English and $lang{$_} translation coverage" )
      unless ( $_ eq 'en' );
}

$ENV{SCRIPT_NAME}          = "__SCRIPTNAME__";
$ENV{SCRIPT_FILENAME}      = $0;
$ENV{HTTP_ACCEPT_LANGUAGE} = 'en';
my $h;
@ARGV = ("help=groups");

sub compare {
    my ( $l1, $l2 ) = @_;
    $r1 = &{ "Lemonldap::NG::Manager::_i18n::" . $l1 };
    $r2 = &{ "Lemonldap::NG::Manager::_i18n::" . $l2 };
    my $r = 1;
    foreach ( keys %$r1 ) {
        unless ( $r2->{$_} ) {
            print STDERR "$_ is present in $l1 but miss in $l2";
            $r = 0;
        }
    }
    foreach ( keys %$r2 ) {
        unless ( $r1->{$_} ) {
            print STDERR "$_ is present in $l2 but miss in $l1";
            $r = 0;
        }
    }
    return $r;
}
