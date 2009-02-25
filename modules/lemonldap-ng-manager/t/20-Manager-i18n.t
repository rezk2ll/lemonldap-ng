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
}

use Test::More tests => ( keys(%lang) + 4 );

use_ok('Lemonldap::NG::Manager');

my $win = 0;
$win++ unless ( -e '/dev/null' );

if ($win) {
    open STDOUT, '>test_stdout.txt';
}
else {
    open STDOUT, '>/dev/null';
}

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
ok(
    $h = new Lemonldap::NG::Manager(
        {
            configStorage => {
                type    => 'File',
                dirName => ".",
            },
            dhtmlXTreeImageLocation => "/imgs/",
            jsFile                  => 'example/lemonldap-ng-manager.js',
        }
    ),
    'New manager object'
);
ok( $h->main(),       "HTML code" );
ok( $h->print_help(), "Help page" );
ok( $h->buildTree(),  "XML tree" );

unlink('test_stdout.txt') if ($win);

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
