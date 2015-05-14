# Manager main component
#
# This package contains these parts:
#  - Properties and private methods
#  - Initialization method (launched by Lemonldap::NG::Common::PSGI)
#    that declares routes
#  - Upload methods (launched by Lemonldap::NG::Common::PSGI::Router)
#
# It inherits from Conf.pm to responds to display methods and from
# Sessions.pm to manage sessions
package Lemonldap::NG::Manager;

use 5.10.0;
use Mouse;
our $VERSION = '2.0.0';
use Lemonldap::NG::Common::Conf::Constants;
use Lemonldap::NG::Common::PSGI::Constants;

extends 'Lemonldap::NG::Handler::PSGI', 'Lemonldap::NG::Manager::Lib';

## @method boolean init($args)
# Launch initialization method
#
# @param $args hashref to merge with object
# @return 0 in case of error, 1 else
sub init {
    my ( $self, $args ) = splice @_;
    $args ||= {};

    foreach my $k ( keys %$args ) {
        $self->{$k} = $args->{$k};
    }
    my $conf = $self->confAcc;

    if ( my $localconf = $conf->getLocalConf(MANAGERSECTION) ) {
        $self->{$_} = $args->{$_} // $localconf->{$_}
          foreach ( keys %$localconf );
    }

    return 0 unless ( $self->SUPER::init($args) );

    # TODO: manage errors
    unless ( -r $self->{templateDir} ) {
        $self->error("Unable to read $self->{templateDir}");
        return 0;
    }

    $self->{enabledModules} ||= "conf, sessions, notifications";
    my @links;
    my @enabledModules =
      map { push @links, $_; "Lemonldap::NG::Manager::" . ucfirst($_) }
      split( /[,\s]+/, $self->{enabledModules} );
    extends 'Lemonldap::NG::Handler::PSGI', @enabledModules;
    foreach my $mod (@enabledModules) {
        no strict 'refs';
        &{"${mod}::addRoutes"}($self);
    }

    $self->defaultRoute( $enabledModules[0]->defaultRoute );

    $self->links( [] );
    for ( my $i = 0 ; $i < @links ; $i++ ) {
        push @{ $self->links },
          { target => $enabledModules[$i]->defaultRoute, title => $links[$i] };
    }
    1;
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Manager - Perl extension for managing Lemonldap::NG Web-SSO
system.

=head1 SYNOPSIS

  #!/usr/bin/env plackup -I pl/lib
  
  use Lemonldap::NG::Manager;
  
  # This must be the last instruction ! See PSGI for more
  Lemonldap::NG::Manager->run($opts);

=head1 DESCRIPTION

Lemonldap::NG::Manager provides a web interface to manage Lemonldap::NG Web-SSO
system.

This interface uses L<Plack> to be compatible with CGI, FastCGI,...

=head1 PARAMETERS

You can use a hash ref to override any LemonLDAP::NG parameter. Currently, you
can specify where your lemonldap-ng.ini file is:

  Lemonldap::NG::Manager->run( { confFile => '/path/to/lemonldap-ng.ini' } );

=head1 SEE ALSO

L<Lemonldap::NG::Handler>, L<Lemonldap::NG::Portal>, L<Plack>, L<PSGI>,
L<http://lemonldap-ng.org/>

=head1 AUTHORS

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Thomas Chemineau, E<lt>thomas.chemineau@gmail.comE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2015 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=back

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.

=cut
