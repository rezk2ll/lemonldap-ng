package Lemonldap::NG::Manager::Conf;

use strict;
use Storable qw(thaw freeze);
use MIME::Base64;

our $VERSION = 0.1;
our @ISA;
my $mdone = 0;

sub new {
    my $class = shift;
    my $args;
    if ( ref( $_[0] ) ) {
        $args = $_[0];
    }
    else {
        %$args = @_;
    }
    $args ||= {};
    my $self = bless $args, $class;
    unless($mdone) {
        unless($self->{type}) {
	    print STDERR "configStorage: type is not defined\n";
	    return 0;
        }
        $self->{type} = "Lemonldap::NG::Manager::Conf::$self->{type}" unless $self->{type} =~ /^Lemonldap/;
        eval "require $self->{type}";
        die ($@) if($@);
        push @ISA, $self->{type};
        return 0 unless $self->prereq;
	$mdone++;
    }
    return $self;
}

sub saveConf {
    my($self,$conf) = @_;
    my $fields;
    while(my($k,$v) = each(%$conf)) {
	if(ref($v)) {
	    $fields->{$k} = "'" . encode_base64( freeze( $v ) ) . "'";
	    $fields->{$k} =~ s/[\r\n]//g;
	}
	elsif($v =~ /^\d+/) {
	    $fields->{$k} = "$v";
	}
	else {
	    $fields->{$k} = "'$v'";
	}
    }
    $fields->{cfgNum} = $self->lastCfg+1;
    return $self->store($fields);
}

sub getConf {
    my($self, $args) = @_;
    $args->{cfgNum} ||= $self->lastCfg;
    return undef unless $args->{cfgNum};
    my $fields = $self->load($args->{cfgNum}, $args->{fields});
    my $conf;
    while(my($k,$v) = each(%$fields)) {
	my $tmp;
	eval "\$tmp = thaw(decode_base64($v))";
	if($@ or not($tmp)) {
	    $v =~ s/^'(.*)'$/$1/;
	    $conf->{$k} = $v;
	}
	else {
	    $conf->{$k} = $tmp;
	}
    }
    return $conf;
}

1;
__END__
