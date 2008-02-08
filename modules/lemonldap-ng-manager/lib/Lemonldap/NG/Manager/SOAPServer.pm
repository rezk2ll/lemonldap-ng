package Lemonldap::NG::Manager::SOAPServer;

use strict;
use SOAP::Transport::HTTP;
use Lemonldap::NG::Manager::Conf;
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
        $self->{config} = Lemonldap::NG::Manager::Conf->new( $self->{configStorage} );
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

Lemonldap::NG::Manager::SOAPServer - Perl extension written to access to
Lemonldap::NG Web-SSO configuration or sessions via SOAP.

=head1 SYNOPSIS

=head2 Server side

  use Lemonldap::NG::Manager::SOAPServer;
  Lemonldap::NG::Manager::SOAPServer->start(
              configStorage => {
                      type    => "File",
                      dirName => "/usr/share/doc/lemonldap-ng/examples/conf/"
              },
              # 2 types are available :
              #   * 'config' for configuration access
              #   * 'sessions' for sessions access
              type          => 'sessions',
              # For 'sessions' type, you can choose exported functions (get
              # only by default):
              AuthorizedFunctions => 'new get set',
  );

=head2 Client side

See L<Lemonldap::NG::Manager::Conf::SOAP> for documentation on client side
configuration access.

See L<Lemonldap::NG::Manager::Apache::Session::SOAP> for documentation on client side
sessions access.

=head3 Configuration access

=head4 Area protection

  package My::Package;
  use Lemonldap::NG::Handler::SharedConf;
  @ISA = qw(Lemonldap::NG::Handler::SharedConf);
  
  __PACKAGE__->init ( {
      localStorage        => "Cache::FileCache",
      localStorageOptions => {
                'namespace'          => 'MyNamespace',
                'default_expires_in' => 600,
      },
      configStorage       => {
                type  => 'SOAP',
                proxy => 'http://manager.example.com/soapserver.pl',
                # If soapserver is protected by HTTP Basic:
                User     => 'http-user',
                Password => 'pass',
      },
      https               => 0,
  } );

=head4 Authentication portal

  use Lemonldap::NG::Portal::SharedConf;
  
  my $portal = Lemonldap::NG::Portal::SharedConf->new ( {
          configStorage => {
                  type    => 'SOAP',
                  proxy   => 'http://localhost/devel/test.pl',
                  # If soapserver is protected by HTTP Basic:
                  User     => 'http-user',
                  Password => 'pass',
          }
  });
  # Next as usual...
  if($portal->process()) {
    ...

=head4 Manager

  use Lemonldap::NG::Manager;
  
  my $m=new Lemonldap::NG::Manager(
       {
           configStorage=>{
                  type  => 'SOAP',
                  proxy => 'http://localhost/devel/test.pl'
                  # If soapserver is protected by HTTP Basic:
                  User     => 'http-user',
                  Password => 'pass',
           },
            dhtmlXTreeImageLocation=> "/imgs/",
        }
  ) or die "Unable to start";
  
  $m->doall();

=head3 Sessions access

  Use simply Lemonldap::NG::Manager::Apache::Session::SOAP in the 'Apache session
  module'parameter (instead of Apache::Session::MySQL or
  Apache::Session::File).

=head1 DESCRIPTION

Lemonldap::NG::Manager::Conf provides a simple interface to access to
Lemonldap::NG Web-SSO configuration. It is used by L<Lemonldap::NG::Handler>,
L<Lemonldap::NG::Portal> and L<Lemonldap::NG::Manager>.

Lemonldap::NG::Manager::SOAPServer provides a SOAP proxy system that can be
used to access

=head2 SUBROUTINES

=over

=item * B<start>: main subroutine. It starts SOAP CGI system. You have to set
C<configStorage> to the real configuration storage system. See L<Synopsys> for
examples. 

=item * B<process>: alias for start.

=item * B<new> (constructor): (called by C<start>). See code if you want to
overload this package.

=back

=head2 SECURITY

Since Lemonldap::NG::Manager::SOAPServer act as a CGI, you can protect
configuration access by any of the HTTP protection mecanisms.
See L<Lemonldap::NG::Manager::Conf::SOAP> for the security in the client
side.

In "session" mode, you can control what functions can be used by SOAP. By
default, only "get" can be used: it means that only handlers can work with it.
Use "AuthorizedFunctions" parameter to grant other functions.

=head1 SEE ALSO

L<Lemonldap::NG::Manager>, L<Lemonldap::NG::Manager::Conf::SOAP>,
L<Lemonldap::NG::Handler>, L<Lemonldap::NG::Portal>,
http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation

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
