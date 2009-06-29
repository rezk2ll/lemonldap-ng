package Lemonldap::NG::Manager::SOAPServer;

use strict;

our $VERSION = '0.2';

die 'This module is now obsolete. You have to use the portal as "proxy".
See http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocSOAP';

use SOAP::Transport::HTTP;
use Lemonldap::NG::Common::Conf; #link protected config Configuration hash reference
use UNIVERSAL qw(isa);

our $VERSION = "0.3";

# Initialization

sub new {
    my ( $class, @args ) = @_;
    my $self;
    if ( ref( $args[0] ) ) {
        $self = $args[0];
    }
    else {
        %$self = @args;
    }
    bless $self, $class;
    # Arguments verification
    if( $self->{type} eq 'sessions' ) {
        unless( $self->{realSessionStorage} ) {
            die qq/The "realSessionStorage" parameter is required/;
            return ();
        }
        eval "use " . $self->{realSessionStorage};
        die $@ if($@);
    }
    else {
        unless ( $self->{configStorage} ) {
            die qq/The "configStorage" parameter is required\n/;
            return ();
        }
        $self->{config} = Lemonldap::NG::Common::Conf->new( $self->{configStorage} );
        die "Configuration not loaded" unless $self->{config};
    }
    return $self;
}

sub init {
    my $self = shift;
    if( $self->{type} eq 'sessions' ) {
        $Lemonldap::NG::Manager::SOAPService::Sessions::authorizedFunctions =
          $self->{AuthorizedFunctions} || 'get';
        $Lemonldap::NG::Manager::SOAPService::Sessions::config = $self;
    }
    else {
        $Lemonldap::NG::Manager::SOAPService::Config::config = $self->{config};
    }
}

# Main process

*process = \&start;

sub start {
    my $self;
    if ( ref( $_[0] ) and isa( $_[0], __PACKAGE__ ) ) {
        $self = shift;
    }
    else {
        $self = shift->new(@_);
    }
    $self->init();
    my $service = ($self->{type} eq 'sessions')
                  ? 'Lemonldap::NG::Manager::SOAPService::Sessions'
                  : 'Lemonldap::NG::Manager::SOAPService::Config';
    SOAP::Transport::HTTP::CGI->dispatch_to($service)->handle;
}

# Description of SOAP service
package Lemonldap::NG::Manager::SOAPService::Config;

our $config;

sub available {
    shift;
    my @t = $config->available(@_);
    return \@t;
}

sub lastCfg {
    shift;
    return $config->lastCfg(@_);
}

sub store {
    shift;
    return $config->store(@_);
}

sub load {
    shift;
    return $config->load(@_);
}

package Lemonldap::NG::Manager::SOAPService::Sessions;

our $config;
our $authorizedFunctions = 'get';

sub newsession {
    unless( $authorizedFunctions =~ /\bnew\b/ ) {
        print STDERR "Lemonldap::NG::Manager::SOAPService: 'new' is not authorized. Set 'AuthorizedFunctions' parameter if needed.\n";
        return 0;
    }
    my( $class, $args ) = @_;
    $args ||= {};
    my %h;
    eval {
        tie %h, $config->{realSessionStorage}, undef, $config->{realSessionStorageOptions};
    };
    if ($@) {
        print STDERR "Lemonldap::NG::Manager::SOAPService: $@\n";
        return 0;
    }
    $h{$_} = $args->{$_} foreach ( keys %{ $args } );
    $h{_utime} = time();
    $args->{$_} = $h{$_} foreach ( keys %h );
    untie %h;
    return $args;
}

sub get {
    return 0 unless( $authorizedFunctions =~ /\bget\b/ );
    my( $class, $id ) = @_;
    my %h;
    eval {
        tie %h, $config->{realSessionStorage}, $id, $config->{realSessionStorageOptions};
    };
    if ($@) {
        print STDERR "Lemonldap::NG::Manager::SOAPService: $@\n";
        return 0;
    }
    my $args;
    $args->{$_} = $h{$_} foreach ( keys %h );
    untie %h;
    return $args;
}

sub set {
    return 0 unless( $authorizedFunctions =~ /\bset\b/ );
    my( $class, $id, $args ) = @_;
    my %h;
    eval {
        tie %h, $config->{realSessionStorage}, $id, $config->{realSessionStorageOptions};
    };
    if ($@) {
        print STDERR "Lemonldap::NG::Manager::SOAPService: $@\n";
        return 0;
    }
    $h{$_} = $args->{$_} foreach ( keys %{ $args } );
    untie %h;
    return $args;
}

sub delete {
    return 0 unless( $authorizedFunctions =~ /\bdelete\b/ );
    my( $class, $id ) = @_;
    my %h;
    eval {
        tie %h, $config->{realSessionStorage}, $id, $config->{realSessionStorageOptions};
    };
    if ($@) {
        print STDERR "Lemonldap::NG::Manager::SOAPService: $@\n";
        return 0;
    }
    tied(%h)->delete;
}

1;
__END__

=head1 NAME

Lemonldap::NG::Manager::SOAPServer - Obsolete : now SOAP services are included
in the Lemonldap::NG portal.

=head1 SYNOPSIS

=head1 DESCRIPTION

This module is obsolete. Now, use the portal.

=head1 SEE ALSO

L<Lemonldap::NG::Portal>,

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://forge.objectweb.org/tracker/?group_id=274>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
