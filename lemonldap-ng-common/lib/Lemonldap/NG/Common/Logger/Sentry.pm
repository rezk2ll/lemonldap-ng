package Lemonldap::NG::Common::Logger::Sentry;

use strict;
use Sentry::Raven;

our $VERSION = '2.0.0';

sub new {
    my $self = bless {}, shift;
    my ($conf) = @_;
    my $show = 1;
    $self->{raven} = Sentry::Raven->new( sentry_dsn => $conf->{ravenDsn} );
    foreach (qw(error warn notice info debug)) {
        my $rl = $_;
        $rl = 'warning' if ( $rl = 'warn' );
        $rl = 'info'    if ( $rl = 'notice' );
        if ($show) {
            eval
qq'sub $_ {\$_[0]->{raven}->capture_message(\$[1],level => "$rl")}';
        }
        else {
            eval qq'sub $_ {1}';
        }
        $show = 0 if ( $level eq $_ );
    }
    die "unknown level $level" if ($show);
    return $self;
}

1;
