package Lemonldap::NG::Common::Logger::Std;

my @LEVEL = (qw(error warn notice info debug));

our $done = 0;

sub import {
    no warnings 'redefine';
    my $level = $_[1] || 'info';
    my $show = 1;
    foreach ( @LEVEL ) {
        if($show) {
            eval qq'sub $_ {print STDERR "[$_] \$_[1]\n"}';
        }
        else {
            eval qq'sub $_ {1}';
        }
        $show = 0 if($level eq $_);
    }
    die "unknown level $level" if($show);
}

1;
