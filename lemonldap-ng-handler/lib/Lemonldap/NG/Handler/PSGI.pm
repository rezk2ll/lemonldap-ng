package Lemonldap::NG::Handler::PSGI;

use 5.10.0;
use Mouse;
use Lemonldap::NG::Handler::SharedConf qw(:tsv :variables :jailSharedVars);
extends 'Lemonldap::NG::Common::PSGI::Router';

our $VERSION = '1.9.0';

has protection => ( is => 'rw', isa => 'Str' );

around init => sub {
    my ( $method, $self, $args ) = @_;
    eval { Lemonldap::NG::Handler::SharedConf->init($self) };
    if ( $@ and not $self->{protection} eq 'none' ) {
        $self->lmLog( $@, 'error' );
        $self->error($@);
        $self->$method($args);
        return 0;
    }
    unless ( Lemonldap::NG::Handler::SharedConf->checkConf($self)
        or $self->{protection} eq 'none' )
    {
        $self->error(
            "Unable to protect this app ($Lemonldap::NG::Common::Conf::msg)");
        $self->$method($args);
        return 0;
    }
    return $self->$method($args);
};

sub _run {
    my $self = shift;

    # Override _run() only if protection != 'none'
    my $rule = $self->{protection} || $localConfig->{protection};
    if ( $rule ne 'none' ) {
        $rule =
          $rule eq "authenticate" ? "accept" : $rule eq "manager" ? "" : $rule;

        # Handle requests
        # Developers, be careful: Only this part is executed at each request
        return sub {
            my $req = Lemonldap::NG::Common::PSGI::Request->new( $_[0] );
            Lemonldap::NG::Handler::API->newRequest($req);
            my $res = Lemonldap::NG::Handler::SharedConf->run($rule);
            $req->userData($datas) if ($datas);

            if ( $res < 300 ) {
                return $self->router($req);
            }

            # Ajax hook: Ajax requests can not understand 30x responses. This
            #            is not really HTTP compliant but nothing in this
            #            protocol can do this. Our javascripts understand that
            #            they have to prompt user with the URL
            elsif (
                $req->accept =~ m|application/json|
                or (    $req->contentType
                    and $req->contentType =~ m|application/json| )
              )
            {
                if ( $res == 302 or $res == 303 ) {
                    return [
                        401,
                        [ Authorization => $req->{respHeaders}->{Location} ],
                        ['']
                    ];
                }
                else {
                    return [
                        $res, [ 'Content-Type', 'application/json' ],
                        [qq({"error":"$res"})]
                    ];
                }
            }

            # Non Ajax requests may be redirected to portal
            else {
                my %h = $req->{respHeaders} ? %{ $req->{respHeaders} } : ();
                my $s = $tsv->{portal}->() . "?lmError=$res";
                $s =
                    '<html><head><title>Redirection</title></head><body>'
                  . qq{<script type="text/javascript">window.location='$s'</script>}
                  . '<h1>Please wait</h1>'
                  . qq{<p>An error occurs, you're going to be redirected to <a href="$s">$s</a>.</p>}
                  . '</body></html>';
                $h{'Content-Type'}   = 'text/html';
                $h{'Content-Length'} = length $s;
                return [ $res, [%h], [$s] ];
            }
        };
    }

    else {
        eval { Lemonldap::NG::Handler::SharedConf->checkConf() }
          unless (%$tsv);
        $self->lmLog( $@, 'error' ) if ($@);

        # Handle unprotected requests
        return sub {
            $self->router( Lemonldap::NG::Common::PSGI::Request->new( $_[0] ) );
        };
    }
}

## @method hashRef user()
# @return hash of user datas
sub user {
    my ( $self, $req ) = @_;
    return $req->userData || { _whatToTrace => 'anonymous' };
}

## @method string userId()
# @return user identifier to log
sub userId {
    my ( $self, $req ) = @_;
    return $req->userData->{_whatToTrace} || 'anonymous';
}

## @method boolean group(string group)
# @param $group name of the Lemonldap::NG group to test
# @return boolean : true if user is in this group
sub group {
    my ( $self, $req, $group ) = @_;
    return () unless ( $req->userData->{groups} );
    return ( $req->userData->{groups} =~ /\b$group\b/ );
}

## @method PSGI::Response sendError($req,$err,$code)
# Add user di to $err before calling Lemonldap::NG::Common::PSGI::sendError()
# @param $req Lemonldap::NG::Common::PSGI::Request
# @param $err String to push
# @code int HTTP error code (default to 500)
sub sendError {
    my ( $self, $req, $err, $code ) = @_;
    $err ||= $req->error;
    $err = '[' . $self->userId($req) . "] $err";
    return $self->SUPER::sendError( $req, $err, $code );
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Handler::PSGI - Base library for protected REST APIs of
Lemonldap::NG.

=head1 SYNOPSIS

  package My::PSGI;
  
  use base Lemonldap::NG::Handler;
  
  sub init {
    my ($self,$args) = @_;
    $self->protection('manager');
    # See Lemonldap::NG::Common::PSGI for more
    
    # Declare REST routes (could be HTML templates or methods)
    $self->addRoute ( 'index.html', undef, ['GET'] )
         ->addRoute ( books => { ':book' => 'booksMethod' }, ['GET', 'POST'] );
  
    # Default route (ie: PATH_INFO == '/')
    $self->defaultRoute('index.html');
  
    # Return a boolean. If false, then error message has to be stored in
    # $self->error
    return 1;
  }
  
  sub booksMethod {
    my ( $self, $req, @otherPathInfo ) = @_;

    # Will be called only if authorisated
    my $userId = $self->userId;
    my $book = $req->params('book');
    my $method = $req->method;
    ...
    $self->sendJSONresponse(...);
  }

This package could then be called as a CGI, using FastCGI,...

  #!/usr/bin/env perl
  
  use My::PSGI;
  use Plack::Handler::FCGI; # or Plack::Handler::CGI

  Plack::Handler::FCGI->new->run( My::PSGI->run() );

=head1 DESCRIPTION

This package provides base class for Lemonldap::NG protected REST API.

=head1 METHODS

See L<Lemonldap::NG::Common::PSGI> for logging methods, content sending,...

=head2 Accessors

See L<Lemonldap::NG::Common::PSGI::Router> for inherited accessors.

=head3 protection

Level of protection. It can be one of:

=over

=item 'none': no protection

=item 'authenticate': all authenticated users are granted

=item 'manager': access is granted following Lemonldap::NG rules

=back

=head2 Running methods

=head3 user

Returns user session datas. If empty (no protection), returns:

  { _whatToTrace => 'anonymous' }

But if page is protected by server (Auth-Basic,...), it will return:

  { _whatToTrace => $REMOTE_USER }

=head3 UserId

Returns user()->{'_whatToTrace'}.

=head3 group

Returns a list of groups to which user belongs.

=head1 SEE ALSO

L<http://lemonldap-ng.org/>, L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Handler>,
L<Plack>, L<PSGI>, L<Lemonldap::NG::Common::PSGI::Router>,
L<Lemonldap::NG::Common::PSGI::Request>, L<HTML::Template>, 

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

=item Copyright (C) 2015 by Clément Oudot, E<lt>clem.oudot@gmail.comE<gt>

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
