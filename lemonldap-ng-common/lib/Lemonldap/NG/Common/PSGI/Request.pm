package Lemonldap::NG::Common::PSGI::Request;

use strict;
use Mouse;
use JSON;
use Plack::Request;
use URI::Escape;

our $VERSION = '2.0.0';

our @ISA = ('Plack::Request');

#       http          ://  server   / path      ? query      # fragment
# m|(?:([^:/?#]+):)?(?://([^/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#(.*))?|;

sub BUILD {
    my ( $self, $env ) = @_;
    foreach ( keys %$env ) {
        $self->{$_} ||= $env->{$_} if (/^(?:HTTP|SSL)_/);
    }
}

sub new {
    my $self = Plack::Request::new(@_);
    my $tmp  = $self->script_name;
    $self->env->{REQUEST_URI} = $self->env->{X_ORIGINAL_URI}
      if ( $self->env->{X_ORIGINAL_URI} );
    $self->env->{PATH_INFO} =~ s|^$tmp|/|;
    $self->env->{PATH_INFO} =~ s|//+|/|g;
    $self->{uri} = uri_unescape( $self->env->{REQUEST_URI} );
    $self->{uri} =~ s|//+|/|g;
    $self->{error}       = 0;
    $self->{respHeaders} = [];
    return $self;
}

sub uri { $_[0]->{uri} }

sub userData {
    my($self,$v)=@_;
    return $_[0]->{userData} = $v if($v);
    return $_[0]->{userData} || { _whatToTrace => $_[0]->user, };
}

sub respHeaders {
    my ( $self, $respHeaders ) = @_;
    $self->{respHeaders} = $respHeaders if ($respHeaders);
    return $self->{respHeaders};
}

sub accept        { $_[0]->env->{HTTP_ACCEPT} }
sub encodings     { $_[0]->env->{HTTP_ACCEPT_ENCODING} }
sub languages     { $_[0]->env->{HTTP_ACCEPT_LANGUAGE} }
sub authorization { $_[0]->env->{HTTP_AUTHORIZATION} }
sub hostname      { $_[0]->env->{HTTP_HOST} }
sub referer       { $_[0]->env->{REFERER} }

sub error {
    my ( $self, $err ) = @_;
    $self->{error} = $err if ($err);
    return $self->{error};
}

sub read_body {
    my $self = shift;
    if ( $self->method eq 'GET' ) { return undef; }
    elsif ( $self->method =~ /^(?:POST|PUT)$/ ) {
        my $body = '';
        if ( $self->env->{'_psgix.buffered'} ) {
            my $length = $self->content_length;
            while ( $length > 0 ) {
                my $buffer;
                $self->body->read( $buffer,
                    ( $length < 8192 ) ? $length : 8192 );
                $length -= length($buffer);
                $body .= $buffer;
            }
        }
        else {
            $self->body->read( $body, $self->content_length, 0 );
        }
        utf8::upgrade($body);
        return $body;
    }
}

*params = \&Plack::Request::param;

sub set_param {
    my ( $self, $k, $v ) = @_;
    $self->param;
    $self->env->{'plack.request.merged'}->{$k} =
      $self->env->{'plack.request.query'}->{$k} = $v;
}

sub wantJSON {
    return 1
      if ( defined $_[0]->accept
        and $_[0]->accept =~ m#(?:application|text)/json# );
    return 0;
}

# JSON parser
sub jsonBodyToObj {
    my $self = shift;
    return $self->{json_body} if ( $self->{json_body} );
    unless ( $self->content_type =~ /application\/json/ ) {
        $self->error('Data is not JSON');
        return undef;
    }
    unless ( $self->body ) {
        $self->error('No data');
        return undef;
    }
    my $j = eval { from_json( $self->read_body ) };
    if ($@) {
        $self->error("$@$!");
        return undef;
    }
    return $self->{json_body} = $j;
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Common::PSGI::Request - HTTP request object for Lemonldap::NG
PSGIs

=head1 SYNOPSIS

  package My::PSGI;
  
  use base Lemonldap::NG::Common::PSGI;
  
  # See Lemonldap::NG::Common::PSGI
  ...
  
  sub handler {
    my ( $self, $req ) = @_;
    # Do something and return a PSGI response
    # NB: $req is a Lemonldap::NG::Common::PSGI::Request object
    if ( $req->accept eq 'text/plain' ) { ... }
    
    return [ 200, [ 'Content-Type' => 'text/plain' ], [ 'Body lines' ] ];
  }

=head1 DESCRIPTION

This package provides HTTP request objects used by Lemonldap::NG PSGIs. It
contains common accessors to work with request

=head1 METHODS

=head2 Accessors

=head3 accept

'Accept' header content.

=head3 encodings

'Accept-Encoding' header content.

=head3 languages

'Accept-Language header content.

=head3 cookies

'Cookie' header content.

=head3 hostname

'Host' header content.

=head3 remote_ip

Client IP address.

=head3 port

Client TCP port.

=head3 method

HTTP method asked by client (GET/POST/PUT/DELETE).

=head3 get_server_port

Server port.

=head3 path

PATH_INFO content which has been subtracted `scriptname`. So it's the relative
path_info for REST calls.

=head3 uri

REQUEST_URI environment variable.

=head3 unparsed_uri

Same as `uri` but without decoding.

=head3 user

REMOTE_USER environment variable. It contains username when a server authentication
is done.

=head3 userData

Hash reference to be used by Lemonldap::NG::Handler::PSGI. If a server authentication
is done, it contains:

  { _whatToTrace => `user()` }

=head3 params

GET parameters.

=head3 body

Content of POST requests

=head3 error

Set if an error occurs

=head3 contentType

Content type of posted datas.

=head3 contentLength

Length of posted datas.

=head3 respHeaders

Used to store response headers. Be careful, it contains an array, not a hash
reference because headers can be multi-valued.

Exemple:

  $req->respHeaders( "Location" => "http://x.y.z/", Etag => "XYZ", );

=head2 Private accessors

=head3 _psgixBuffered

PSGI psgix.input.buffered variable.

=head3 _psgiInput

PSGI psgix.input variable.

=head2 Methods

=head3 parseBody()

Transform JSON or form/url-encoded POST content into GET parameters. Using this
it is possible to manage POST requests like GET requests.

=head3 jsonBodyToObj()

Get the content of a JSON POST request as Perl object.

=head3 wantJSON

Return true if current request ask JSON content (verify that "Accept" header
contains "application/json" or "text/json").

=head1 SEE ALSO

L<http://lemonldap-ng.org/>, L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Handler>,
L<Plack>, L<PSGI>, L<Lemonldap::NG::Common::PSGI>,
L<Lemonldap::NG::Common::PSGI::Router>, L<HTML::Template>, 

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

=item Copyright (C) 2015-2016 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Copyright (C) 2015-2016 by Clément Oudot, E<lt>clem.oudot@gmail.comE<gt>

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
