package Lemonldap::NG::Manager::SOAPServer;

use strict;
use SOAP::Transport::HTTP;
use Lemonldap::NG::Manager::Conf;
use UNIVERSAL qw(isa);

our $VERSION = "0.1";

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
    foreach (qw(configStorage)) {
        unless ( $self->{$_} ) {
            die qq/The "$_" parameter is required\n/;
            return ();
        }
    }
    $self->{config} = Lemonldap::NG::Manager::Conf->new( $self->{configStorage} );
    die "Configuration not loaded" unless $self->{config};
    $Lemonldap::NG::Manager::SOAPService::config = $self->{config};
    return $self;
}

# Main process

*process = \&start;

sub start {
    # Object is not needed actually
    # my $self;
    if ( ref( $_[0] ) and isa( $_[0], __PACKAGE__ ) ) {
        # $self = shift;
    }
    else {
        # $self = shift->new(@_);
        shift->new(@_);
    }
    SOAP::Transport::HTTP::CGI->dispatch_to('Lemonldap::NG::Manager::SOAPService')->handle;
}

# Description of SOAP service
package Lemonldap::NG::Manager::SOAPService;

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

1;
__END__

=head1 NAME

Lemonldap::NG::Manager::SOAPServer - Perl extension written to access to
Lemonldap::NG Web-SSO configuration via SOAP.

=head1 SYNOPSIS

=head2 Server side

  use Lemonldap::NG::Manager::SOAPServer;
  Lemonldap::NG::Manager::SOAPServer->start(
                configStorage => {
                        type=>"File",
                        dirName=>"/usr/share/doc/lemonldap-ng/examples/conf/"
                }

=head2 Client side

See L<Lemonldap::NG::Manager::Conf::SOAP> for documentation on client side.

=head3 Area protection

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
      },
      https               => 0,
  } );

=head3 Authentication portal

  use Lemonldap::NG::Portal::SharedConf;
  
  my $portal = Lemonldap::NG::Portal::SharedConf->new ( {
          configStorage => {
                  type    => 'SOAP',
                  proxy   => 'http://localhost/devel/test.pl',
          }
  });
  # Next as usual...
  if($portal->process()) {
    ...

=head3 Manager

  use Lemonldap::NG::Manager;
  
  my $m=new Lemonldap::NG::Manager(
       {
           configStorage=>{
                  type  => 'SOAP',
                  proxy => 'http://localhost/devel/test.pl'
           },
            dhtmlXTreeImageLocation=> "/imgs/",
        }
  ) or die "Unable to start";
  
  $m->doall();

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

=head1 SEE ALSO

L<Lemonldap::NG::Manager>, L<Lemonldap::NG::Manager::Conf::SOAP>,
L<Lemonldap::NG::Handler>, L<Lemonldap::NG::Portal>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
