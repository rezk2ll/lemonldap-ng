package Lemonldap::NG::Manager::Restricted;

use strict;

use Lemonldap::NG::Manager;
use Lemonldap::NG::Manager::Conf::Constants;

our @ISA     = qw(Lemonldap::NG::Manager);
our $VERSION = "0.1";

sub new {
    my ( $class, $args ) = @_;
    my $self = $class->SUPER::new($args);
    unless ( $self->{read} ) {
        print STDERR
          qq#Warning, "read" parameter is not set, nothing will be displayed\n#;
    }
    return $self;
}

sub buildTree {
    my $self = shift;
    my $tree = $self->SUPER::buildTree();

    # Display only VirtualHosts
    delete $tree->{item}->{item}->{groups};
    delete $tree->{item}->{item}->{generalParameters};
    my $vh = $tree->{item}->{item}->{virtualHosts}->{item};

    # Display only authorized virtual hosts
    foreach my $k ( keys %$vh ) {
        unless ( grep { $_ eq $k } @{ $self->{read} } ) {
            delete $vh->{$k};
            next;
        }

        # and suppress write possibilities
        unless ( grep { $_ eq $k } @{ $self->{write} } ) {
            foreach ( @{ $vh->{$k}->{userdata} } ) {
                $_->{content} = 'none' if ( $_->{name} eq 'modif' );
            }
            foreach my $type ( keys( %{ $vh->{$k}->{item} } ) ) {
                foreach my $i ( keys( %{ $vh->{$k}->{item}->{$type}->{item} } ) ) {
                    foreach ( @{ $vh->{$k}->{item}->{$type}->{item}->{$i}->{userdata} } ) {
                        $_->{content} = 'ro' if ( $_->{name} eq 'modif' );
                    }
                }
            }
        }
    }
    return $tree;
}

sub upload {
    my $self = shift;
    print STDERR "1\n";
    return UPLOAD_DENIED unless ( @{ $self->{write} } );

    # Convert new config
    my $newConfig = $self->tree2conf(@_);

    # Load current config
    my $config = $self->config->getConf();

    # Compare new and old config
    return CONFIG_WAS_CHANGED
      unless ( $config->{cfgNum} == $newConfig->{cfgNum} );

    # Merge config
    foreach my $vh ( @{ $self->{write} } ) {
        if ( $newConfig->{locationRules}->{$vh} ) {
            $config->{locationRules}->{$vh} =
              $newConfig->{locationRules}->{$vh};
            delete $newConfig->{locationRules}->{$vh};
        }
        if ( $newConfig->{exportedHeaders}->{$vh} ) {
            $config->{exportedHeaders}->{$vh} =
              $newConfig->{exportedHeaders}->{$vh};
            delete $newConfig->{exportedHeaders}->{$vh};
        }
    }

    # return UPLOAD_DENIED
    #   if ( %{ $newConfig->{exportedHeaders} }
    #     or %{ $newConfig->{locationRules} } );

    # and save config
    return $self->config->saveConf($config);
}

1;
__END__

=head1 NAME

Lemonldap::NG::Manager::Restricted - Restricted version of
Lemonldap::NG::Manager to show only parts of protected virtual hosts.

=head1 SYNOPSIS

  use Lemonldap::NG::Manager::Restrited;
  my $h=new Lemonldap::NG::Manager::Restricted (
      {
        configStorage=>{
            type=>'File',
            dirName=>"/tmp/",
        },
        dhtmlXTreeImageLocation=> "/devel/img/",
        # uncomment this only if lemonldap-ng-manager.js is not in the same
        # directory than your script.
        # jsFile => /path/to/lemonldap-ng-manager.js,
        read => [ 'test.example.com', 'test2.example.com' ],
        write => [ 'test.example.com' ],
      }
    ) or die "Unable to start, see Apache logs";
  $h->doall();

=head1 DESCRIPTION

This module can be used to give access to a part of the Lemonldap::NG Web-SSO
configuration. You can use it to simply show or give write access to some of
the protected vortual hosts.

=head2 PARAMETERS

Lemonldap::NG::Manager::Restricted works like L<Lemonldap::NG::Manager> but
uses 2 new parameters in the constructor:

=over

=item * read : an array reference to the list of authorized virtual host to
display,

=item * write : an array reference to the list of virtual hosts that can been
updated.

=back

=head1 SEE ALSO

L<Lemonldap::NG::Manager>,
http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.
