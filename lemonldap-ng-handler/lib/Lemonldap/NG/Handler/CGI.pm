# Auto-protected CGI mechanism
package Lemonldap::NG::Handler::CGI;

use strict;

use Lemonldap::NG::Common::CGI;
use Lemonldap::NG::Handler::Main;
use base qw(Lemonldap::NG::Common::CGI Lemonldap::NG::Handler::Main);

our $VERSION = '2.0.0';

## @cmethod Lemonldap::NG::Handler::CGI new(hashRef args)
# Constructor.
# @param $args configuration parameters
# @return new object
sub new {
    my ( $class, $args ) = @_;
    my $self = $class->SUPER::new() or $class->abort("Unable to build CGI");
    Lemonldap::NG::Handler::Main->init($args);
    Lemonldap::NG::Handler::Main->checkConf($self);

    # Get access control rule
    my $rule = $self->{protection}
      || Lemonldap::NG::Handler::Main->localConfig->{protection};
    $rule =~ s/^rule\s*:?\s*//;
    return $self if ( $rule eq "none" );
    $rule =
      $rule eq "authenticate" ? "accept" : $rule eq "manager" ? "" : $rule;
    my $request = {};
    my $res     = $self->run($rule);

    if ( $res == 403 ) {
        $self->abort( 'Forbidden',
            "You don't have rights to access this page" );
    }
    elsif ($res) {
        print $self->header( -status => $res, @{ $request->{respHeaders} } );
        $self->quit;
    }
    else {
        return $self;
    }
}

## @method hashRef user()
# @return hash of user datas
sub user {
    return Lemonldap::NG::Handler::Main->datas;
}

## @method boolean group(string group)
# @param $group name of the Lemonldap::NG group to test
# @return boolean : true if user is in this group
sub group {
    my ( $self, $group ) = @_;
    return ( Lemonldap::NG::Handler::Main->datas->{groups} =~ /\b$group\b/ );
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Handler::CGI - Perl extension for using Lemonldap::NG
authentication in Perl CGI without using Lemonldap::NG::Handler -
DEPRECATED

=head1 SYNOPSIS

  use Lemonldap::NG::Handler::CGI;
  my $cgi = Lemonldap::NG::Handler::CGI->new ( {} );
  
  # See CGI(3) for more about writing HTML pages
  print $cgi->header;
  print $cgi->start_html;
  
  # Since authentication phase, you can use user attributes and macros
  my $name = $cgi->user->{cn};
  
  # Instead of using "$cgi->user->{groups} =~ /\badmin\b/", you can use
  if( $cgi->group('admin') ) {
    # special html code for admins
  }
  else {
    # another HTML code
  }

=head1 DESCRIPTION

Lemonldap::NG::Handler provides the protection part of Lemonldap::NG web-SSO
system. It can be used with any system used with Apache (PHP or JSP pages for
example). If you need to protect only few Perl CGI, you can use this library
instead.

Warning, this module must not be used in a Lemonldap::NG::Handler protected
area because it hides Lemonldap::NG cookies. 

This package has been deprecated in favor of FastCGI/PSGI files.

=head1 SEE ALSO

L<http://lemonldap-ng.org/>, L<Lemonldap::NG::Handler::PSGI>,
L<Lemonldap::NG::Handler::PSGI::Router>, L<Lemonldap::NG::Handler::PSGI::Server>,
L<Lemonldap::NG::Handler::PSGI::Try>

=head1 AUTHORS

=over

=item LemonLDAP::NG team L<http://lemonldap-ng.org/team>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

See COPYING file for details.

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
