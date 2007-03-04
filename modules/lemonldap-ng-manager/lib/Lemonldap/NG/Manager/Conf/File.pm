package Lemonldap::NG::Manager::Conf::File;

use strict;
use Lemonldap::NG::Manager::Conf::Constants;

our $VERSION = 0.12;

sub prereq {
    my $self = shift;
    unless ( $self->{dirName} ) {
        print STDERR "No directory specified (dirName) !";
        return 0;
    }
    unless ( -d $self->{dirName} ) {
        print STDERR "Directory \"$self->{dirName}\" does not exist !";
        return 0;
    }
    1;
}

sub available {
    my $self = shift;
    opendir D, $self->{dirName};
    my @conf = readdir(D);
    close D;
    @conf = sort { $a <=> $b } map { /lmConf-(\d+)/ ? $1 : () } @conf;
    return @conf;
}

sub lastCfg {
    my $self  = shift;
    my @avail = $self->available;
    return $avail[$#avail];
}

# TODO: LOCK

sub lock {
    return 1;
}

sub isLocked {
    return 0;
}

sub unlock {
    return 1;
}

sub store {
    my ( $self, $fields ) = @_;
    unless( open FILE, '>' . $self->{dirName} . "/lmConf-" . $fields->{cfgNum} ) {
        print STDERR "Open file failed: $!";
        $self->unlock;
        return UNKNOWN_ERROR;
    }
    while ( my ( $k, $v ) = each(%$fields) ) {
        print FILE "$k\n\t$v\n\n";
    }
    close FILE;
    $self->unlock;
    return $fields->{cfgNum};
}

sub load {
    my ( $self, $cfgNum, $fields ) = @_;
    my $f;
    local $/ = "";
    open FILE, $self->{dirName} . "/lmConf-$cfgNum";
    while (<FILE>) {
        my ( $k, $v ) = split /\n\s+/;
        chomp $k;
        $v =~ s/\n*$//;
        if ($fields) {
            $f->{$k} = $v if ( grep { $_ eq $k } @$fields );
        }
        else {
            $f->{$k} = $v;
        }
    }
    close FILE;
    return $f;
}

__END__
