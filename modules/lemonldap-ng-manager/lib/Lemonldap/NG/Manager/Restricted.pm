package Lemonldap::NG::Manager::Restricted;

use strict;

use Lemonldap::NG::Manager;
use Lemonldap::NG::Manager::Conf::Constants;

our @ISA=qw(Lemonldap::NG::Manager);
our $VERSION = "0.01";

sub new {
    my ( $class, $args ) = @_;
    my $self = $class->SUPER::new($args);
    unless( $self->{read} ) {
        print STDERR qq#Warning, "read" parameter is not set, nothing will be displayed\n#;
    }
    return $self;
}

sub buildTree {
    my $self = shift;
    my $tree = $self->SUPER::buildTree();
    # TODO: purge tree
    delete $tree->{item}->{item}->{groups};
    delete $tree->{item}->{item}->{generalParameters};
    return $tree;
}

# TODO: restrict upload
sub upload {
    UNKNOWN_ERROR;
}

1;
__END__
=head1 NAME

Lemonldap::NG::Manager::Restricted - Experimental restricted version of
Lemonldap::NG::Manager

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
      }
    ) or die "Unable to start, see Apache logs";
  $h->doall();

=head1 DESCRIPTION

This module is in development. It will be usable to restrict access to
configuration for example only to a single virtual host.

=head1 SEE ALSO

L<Lemonldap::NG::Manager>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.
