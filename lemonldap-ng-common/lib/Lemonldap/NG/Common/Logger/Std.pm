package Lemonldap::NG::Common::Logger::Std;

use strict;
use Encode;

our $VERSION = '2.0.15';

sub new {
    no warnings 'redefine';
    my $level = $_[1]->{logLevel} || 'info';
    my $show  = 1;

    foreach (qw(error warn notice info debug)) {
        if ($show) {
            eval qq'sub $_ {
my \$encoded = encode("UTF-8", \$_[1]);
print STDERR "[".localtime."] [LLNG:\$\$] [$_] \$encoded\n"
}';
        }
        else {
            eval qq'sub $_ {1}';
        }
        $show = 0 if ( $level eq $_ );
    }
    die "Unknown logLevel $level" if $show;

    return bless {}, shift;
}

1;
