package Lemonldap::NG::Common::Logger::Dispatch;

use strict;

our $VERSION = '2.0.0';

sub new {
    no warnings 'redefine';
    my $self = bless {}, shift;
    my ($conf) = @_;
    my %bck;
    my $last;
    my $show = 1;
    unless ( $conf->{logDispatchError} ) {
        die 'At least, logDispatchError must be defined in conf';
    }
    foreach my $l (qw(error warn notice info debug)) {
        if ($show) {
            $last = $conf->{ "logDispatch" . ucfirst($l) } || $last;
            unless ( $bck{$last} ) {
                eval "require $last";
                die $@ if ($@);
                $bck{$last} = $last->new(@_);
            }
            my $obj = $bck{$last};
            eval "sub $l {
                shift;
                return \$obj->$l(\@_);
            }";
        }
        else {
            eval qq'sub $l {1}';
        }
        $show = 0 if ( $conf->{logLevel} eq $l );

    }
    die "unknown level $conf->{logLevel}" if ($show);
    return $self;
}

1;
