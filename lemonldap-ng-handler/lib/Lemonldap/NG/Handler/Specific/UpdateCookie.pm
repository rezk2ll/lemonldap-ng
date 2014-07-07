## @file
# Lemonldap::NG special handler

## @class
# Lemonldap::NG special handler

# This specific handler is intended to be called directly by Apache

package Lemonldap::NG::Handler::Specific::UpdateCookie;

use strict;
use Lemonldap::NG::Handler::SharedConf qw(:all);
use Lemonldap::NG::Handler::API qw(:httpCodes);
use base qw(Lemonldap::NG::Handler::SharedConf);
use Lemonldap::NG::Handler::Main::Logger;
use Lemonldap::NG::Handler::Main;

our $VERSION = '1.4.0';

## @rmethod protected boolean retrieveSession(id)
# Tries to retrieve the session whose index is id
# @return true if the session was found, false else
sub retrieveSession {
    my ( $class, $id ) = @_;
    my $res = $class->SUPER::retrieveSession($id);

    my $utime = $class->fetchUTime;
    if ( $res && $Lemonldap::NG::Handler::Main::datas->{_utime} < $utime ) {
        $Lemonldap::NG::Handler::Main::session->remove( {updateCache => 2} );
        $Lemonldap::NG::Handler::Main::datasUpdate = 0;
        $res = $class->SUPER::retrieveSession($id);
        if ( $Lemonldap::NG::Handler::Main::datas->{_utime} < $utime ) {
            Lemonldap::NG::Handler::Main::Logger->lmLog(
                "Session $id datas too old: dated as utime="
              . $Lemonldap::NG::Handler::Main::datas->{_utime}
              . ", but requested with utime > $utime",
            'warn' );
        }
    }

    return $res;
}


## @rmethod protected $ fetchUTime()
# Get user cookies and search for Lemonldap::NG update cookie.
# @param $r current request
# @return Value of the cookie if found, 0 else
sub fetchUTime {
    my $t = Lemonldap::NG::Handler::API->header_in('Cookie');
    my $c = $tsv->{cookieName} . 'update';
    return ( $t =~ /$c=([^,; ]+)/o ) ? $1 : 0;
}

__PACKAGE__->init( {} );

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Handler::UpdateCookie - Perl extension to manage update
cookie sent by client, to reload session in local cache.

=head1 SYNOPSIS

  package My::Package;
  use Lemonldap::NG::Handler::UpdateCookie;
  @ISA = qw(Lemonldap::NG::Handler::SharedConf);

  __PACKAGE__->init ( {
    # See Lemonldap::NG::Handler for more
    # Local storage used for sessions and configuration
  } );

=head1 DESCRIPTION

Lemonldap::NG::Handler::UpdateCookie is a special Lemonldap::NG:: handler that
allow a session to be removed from local cache of the current handler, if an
update cookie is sent by the user and if session is older than the timestamp.

The update cookie should be name "lemonldapupdate" and only contains a simple
timestamp.

=head2 EXPORT

See L<Lemonldap::NG::Handler>

=head1 SEE ALSO

L<Lemonldap::NG::Handler>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

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

=item Copyright (C) 2010 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Copyright (C) 2010, 2012 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item Copyright (C) 2010 by Thomas Chemineau, E<lt>thomas.chemineau@gmail.comE<gt>

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
