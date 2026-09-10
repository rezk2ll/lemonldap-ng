package t::Placeholders;

use strict;

sub replace {
    my ( $class, $conf, $variable ) = @_;
    die "no such secret\n" if ( $variable eq 'die' );
    return undef           if ( $variable eq 'undef' );
    return { a => 'b' }    if ( $variable eq 'hash' );
    return "value-$variable";
}

1;
