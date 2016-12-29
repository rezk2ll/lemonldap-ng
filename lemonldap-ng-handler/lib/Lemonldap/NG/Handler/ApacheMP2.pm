package Lemonldap::NG::Handler::ApacheMP2;

use strict;
use AutoLoader 'AUTOLOAD';
use Apache2::RequestUtil;
use Apache2::RequestRec;
use Apache2::Log;
use Apache2::ServerUtil;
use Apache2::Connection;
use Apache2::RequestIO;
use Apache2::Const;
use Apache2::Filter;
use APR::Table;
use Apache2::Const -compile =>
  qw(FORBIDDEN HTTP_UNAUTHORIZED REDIRECT OK DECLINED DONE SERVER_ERROR AUTH_REQUIRED HTTP_SERVICE_UNAVAILABLE);
use Lemonldap::NG::Handler::Main;

use constant FORBIDDEN         => Apache2::Const::FORBIDDEN;
use constant HTTP_UNAUTHORIZED => Apache2::Const::HTTP_UNAUTHORIZED;
use constant REDIRECT          => Apache2::Const::REDIRECT;
use constant OK                => Apache2::Const::OK;
use constant DECLINED          => Apache2::Const::DECLINED;
use constant DONE              => Apache2::Const::DONE;
use constant SERVER_ERROR      => Apache2::Const::SERVER_ERROR;
use constant AUTH_REQUIRED     => Apache2::Const::AUTH_REQUIRED;
use constant MAINTENANCE       => Apache2::Const::HTTP_SERVICE_UNAVAILABLE;
use constant BUFF_LEN          => 8192;

eval { require threads::shared; };
print STDERR
  "You probably would have better perfs by enabling threads::shared\n"
  if ($@);

our @ISA = qw(Lemonldap::NG::Handler::Main);

our $VERSION = '2.0.0';

our $request;    # Apache2::RequestRec object for current request

# PUBLIC METHODS

sub handler {
    my $class;
    $class = $#_ ? shift : __PACKAGE__;
    my ($res) = $class->run(@_);
    return $res;
}

## @rmethod protected int redirectFilter(string url, Apache2::Filter f)
# Launch the current HTTP request then redirects the user to $url.
# Used by logout_app and logout_app_sso targets
# @param $url URL to redirect the user
# @param $f Current Apache2::Filter object
# @return Constant $class->OK
sub redirectFilter {
    my $class = shift;
    my $url   = shift;
    my $f     = shift;
    unless ( $f->ctx ) {

        # Here, we can use Apache2 functions instead of set_header_out
        # since this function is used only with Apache2.
        $f->r->status( $class->REDIRECT );
        $f->r->status_line("303 See Other");
        $f->r->headers_out->unset('Location');
        $f->r->err_headers_out->set( 'Location' => $url );
        $f->ctx(1);
    }
    while ( $f->read( my $buffer, 1024 ) ) {
    }
    $class->updateStatus( $f->r, '$class->REDIRECT',
        $class->datas->{ $class->tsv->{whatToTrace} }, 'filter' );
    return $class->OK;
}

__PACKAGE__->init();

# INTERNAL METHODS

## @method void thread_share(string $variable)
# try to share $variable between threads
# note: eval is needed,
# else it fails to compile if threads::shared is not loaded
# @param $variable the name of the variable to share
sub thread_share {
    my ( $class, $variable ) = @_;
    eval "threads::shared::share(\$variable);";
}

## @method void setServerSignature(string sign)
# modifies web server signature
# @param $sign String to add to server signature
sub setServerSignature {
    my ( $class, $sign ) = @_;
    eval {
        Apache2::ServerUtil->server->push_handlers(
            PerlPostConfigHandler => sub {
                my ( $c, $l, $t, $s ) = @_;
                $s->add_version_component($sign);
            }
        );
    };
}

sub newRequest {
    my ( $class, $r ) = @_;
    $request = $r;
}

## @method void _lmLog(string $msg, string $level)
# logs message $msg to Apache logs with loglevel $level
# @param $msg string message to log
# @param $level string loglevel
sub _lmLog {
    my ( $class, $msg, $level ) = @_;

    # TODO: remove the useless tag 'ApacheMP2.pm(70):' in debug logs
    Apache2::ServerRec->log->$level($msg);
}

## @method void set_user(string user)
# sets remote_user
# @param user string username
sub set_user {
    my ( $class, $user ) = @_;
    $request->user($user);
}

## @method string header_in(string header)
# returns request header value
# @param header string request header
# @return request header value
sub header_in {
    my ( $class, $header ) = @_;
    $header ||= $class;    # to use header_in as a method or as a function
    return $request->headers_in->{$header};
}

## @method void set_header_in(hash headers)
# sets or modifies request headers
# @param headers hash containing header names => header value
sub set_header_in {
    my ( $class, %headers ) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $request->headers_in->set( $h => $v );
    }
}

## @method void unset_header_in(array headers)
# removes request headers
# This function looks a bit heavy: it is to ensure that if a request
# header 'Auth-User' is removed, 'Auth_User' be removed also
# @param headers array with header names to remove
sub unset_header_in {
    my ( $class, @headers ) = @_;
    foreach my $h1 (@headers) {
        $h1 = lc $h1;
        $h1 =~ s/-/_/g;
        $request->headers_in->do(
            sub {
                my $h  = shift;
                my $h2 = lc $h;
                $h2 =~ s/-/_/g;
                $request->headers_in->unset($h) if ( $h1 eq $h2 );
                return 1;
            }
        );
    }
}

## @method void set_header_out(hash headers)
# sets response headers
# @param headers hash containing header names => header value
sub set_header_out {
    my ( $class, %headers ) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $request->err_headers_out->set( $h => $v );
    }
}

## @method string hostname()
# returns host, as set by full URI or Host header
# @return host string Host value
sub hostname {
    my $class = shift;
    return $request->hostname;
}

## @method string remote_ip
# returns client IP address
# @return IP_Addr string client IP
sub remote_ip {
    my $class     = shift;
    my $remote_ip = (
          $request->connection->can('remote_ip')
        ? $request->connection->remote_ip
        : $request->connection->client_ip
    );
    return $remote_ip;
}

## @method boolean is_initial_req
# returns true unless the current request is a subrequest
# @return is_initial_req boolean
sub is_initial_req {
    my $class = shift;
    return $request->is_initial_req;
}

## @method string args(string args)
# gets the query string
# @return args string Query string
sub args {
    my $class = shift;
    return $request->args();
}

## @method string uri
# returns the path portion of the URI, normalized, i.e. :
# * URL decoded (characters encoded as %XX are decoded,
#   except ? in order not to merge path and query string)
# * references to relative path components "." and ".." are resolved
# * two or more adjacent slashes are merged into a single slash
# @return path portion of the URI, normalized
sub uri {
    my $class = shift;
    my $uri   = $request->uri;
    $uri =~ s#//+#/#g;
    $uri =~ s#\?#%3F#g;
    return $uri;
}

## @method string uri_with_args
# returns the URI, with arguments and with path portion normalized
# @return URI with normalized path portion
sub uri_with_args {
    my $class = shift;
    return uri . ( $request->args ? "?" . $request->args : "" );
}

## @method string unparsed_uri
# returns the full original request URI, with arguments
# @return full original request URI, with arguments
sub unparsed_uri {
    my $class = shift;
    return $request->unparsed_uri;
}

## @method string get_server_port
# returns the port the server is receiving the current request on
# @return port string server port
sub get_server_port {
    my $class = shift;
    return $request->get_server_port;
}

## @method string method
# returns the port the server is receiving the current request on
# @return port string server port
sub method {
    my $class = shift;
    return $request->method;
}

## @method void print(string data)
# write data in HTTP response body
# @param data Text to add in response body
sub print {
    my ( $class, $data ) = @_;
    $request->print($data);
}

1;

__END__

## @method void addToHtmlHead(string data)
# add data at end of html head
# @param data Text to add in html head
sub addToHtmlHead {
    use APR::Bucket  ();
    use APR::Brigade ();
    my ( $class, $data ) = @_;
    $request->add_output_filter(
        sub {
            my $f   = shift;
            my $bb  = shift;
            my $ctx = $f->ctx;

            #unless ($ctx) {
            #    $f->r->headers_out->unset('Content-Length');
            #}
            my $done = 0;
            my $buffer = $ctx->{data} ? $ctx->{data} : '';
            my ( $bdata, $seen_eos ) = flatten_bb($bb);
            unless ($done) {
                $done = 1
                  if ( $bdata =~ s/(<\/head>)/$data$1/si
                    or $bdata =~ s/(<body>)/$1$data/si );
            }
            $buffer .= $bdata if ($bdata);
            if ($seen_eos) {
                my $len = length $buffer;
                $f->r->headers_out->set( 'Content-Length', $len );
                $f->print($buffer) if ($buffer);
            }
            else {
                $ctx->{data} = $buffer;
                $f->ctx($ctx);
            }
            return OK;
        }
    );
}

sub flatten_bb {
    my ($bb) = shift;

    my $seen_eos = 0;

    my @data;
    for ( my $b = $bb->first ; $b ; $b = $bb->next($b) ) {
        $seen_eos++, last if $b->is_eos;
        $b->read( my $bdata );
        push @data, $bdata;
    }
    return ( join( '', @data ), $seen_eos );
}

## @method void setPostParams(hashref $params)
# add or modify parameters in POST request body
# @param $params hashref containing name => value
sub setPostParams {
    my ( $class, $params ) = @_;
    $request->add_input_filter(
        sub {
            my $f = shift;
            my $buffer;

            # Filter only POST request body
            if ( $f->r->method eq "POST" ) {
                my $body;
                while ( $f->read($buffer) ) { $body .= $buffer; }
                while ( my ( $name, $value ) = each(%$params) ) {
                    $body =~ s/((^|&))$name=[^\&]*/$1$name=$value/
                      or $body .= "&$name=$value";
                }
                $body =~ s/^&//;
                $f->print($body);
            }
            else {
                $f->print($buffer) while ( $f->read($buffer) );
            }
            return OK;
        }
    );
}

=pod

=encoding utf8

=head1 NAME

Lemonldap::NG::Handler - The Apache protection module part of
Lemonldap::NG Web-SSO system.

=head1 SYNOPSIS

=head2 Configure Apache

Call Handler in /apache-dir/conf/httpd.conf:

  # Load your package
  PerlRequire /My/File
  # TOTAL PROTECTION
  PerlHeaderParserHandler Lemonldap::NG::Handler::DefaultHandler
  # OR SELECTED AREA
  <Location /protected-area>
    PerlHeaderParserHandler Lemonldap::NG::Handler::DefaultHandler
  </Location>

The configuration is loaded only at Apache start. Create an URI to force
configuration reload, so you don't need to restart Apache at each change:

  # /apache-dir/conf/httpd.conf
  <Location /location/that/I/ve/choosed>
    Order deny,allow
    Deny from all
    Allow from my.manager.com
    PerlHeaderParserHandler Lemonldap::NG::Handler::DefaultHandler->refresh
  </Location>
  
To display the status page, add something like this :

  <Location /status>
    Order deny,allow
    Allow from 10.1.1.0/24
    Deny from all
    PerlHeaderParserHandler Lemonldap::NG::Handler::DefaultHandler->status
  </Location>

=head1 DESCRIPTION

Lemonldap::NG is a modular Web-SSO based on Apache::Session modules. It
simplifies the build of a protected area with a few changes in the application.

It manages both authentication and authorization and provides headers for
accounting. So you can have a full AAA protection for your web space as
described below.

The Apache module part works both with Apache 1.3.x and 2.x ie mod_perl 1 and 2
but B<not with mod_perl 1.99>.

=head2 Authentication, Authorization, Accounting

=head3 B<Authentication>

If a user isn't authenticated and attempts to connect to an area protected by a
Lemonldap::NG compatible handler, he is redirected to a portal. The portal
authenticates user with a ldap bind by default, but you can also use another
authentication sheme like using x509 user certificates (see
L<Lemonldap::NG::Portal::AuthSSL> for more).

Lemonldap::NG use session cookies generated by L<Apache::Session> so as secure
as a 128-bit random cookie. You may use the C<securedCookie> options of
L<Lemonldap::NG::Portal> to avoid session hijacking.

You have to manage life of sessions by yourself since Lemonldap::NG knows
nothing about the L<Apache::Session> module you've choosed, but it's very easy
using a simple cron script because L<Lemonldap::NG::Portal> stores the start
time in the C<_utime> field.
By default, a session stay 10 minutes in the local storage, so in the worth
case, a user is authorized 10 minutes after he lost his rights.

=head3 B<Authorization>

Authorization is controlled only by handlers because the portal knows nothing
about the way the user will choose. When configuring your Web-SSO, you have to:

=over

=item * choose the ldap attributes you want to use to manage accounting and
authorization (see C<exportedHeaders> parameter in L<Lemonldap::NG::Portal>
documentation).

=item * create Perl expressions to define user groups (using ldap attributes)

=item * create an array foreach virtual host associating URI regular
expressions and Perl expressions to use to grant access.

=back

=head4 Example (See L<Lemonldap::NG::Manager> to see how configuration is
stored)

Exported variables (values will be stored in session database by
L<Lemonldap::NG::Portal>):

  exportedVars => {
      cn            => "cn",
      departmentUID => "departmentUID",
      login         => "uid",
  },

User groups (values will be stored in session database by
L<Lemonldap::NG::Portal>):

  groups => {
      group1 => '{ $departmentUID eq "unit1" or $login = "xavier.guimard" }',
      ...
  },

Area protection:

  locationRules => {
      www1.domain.com => {
          '^/protected/.*$' => '$groups =~ /\bgroup1\b/',
          default           => 'accept',
      },
      www2.domain.com => {
          '^/site/.*$' => '$uid eq "xavier.guimard" or $groups =~ /\bgroup2\b/',
          '^/(js|css)' => 'accept',
          default      => 'deny',
      },
  },

=head4 Performance

You can use Perl expressions as complicated as you want and you can use all
the exported LDAP attributes (and create your own attributes: with 'macros'
mechanism. See L<Lemonldap::NG::Manager>) in groups evaluations, area
protections or custom HTTP headers (you just have to call them with a "$").

You have to be careful when choosing your expressions:

=over

=item * C<groups> and C<macros> are evaluated each time a user is redirected to
the portal,

=item * C<locationRules> and C<exportedheaders> are evaluated for each request
on a protected area.

=back

It is also recommended to use the C<groups> mechanism to avoid having to
evaluate a long expression at each HTTP request:

  locationRules => {
      www1.domain.com => {
          '^/protected/.*$' => '$groups =~ /\bgroup1\b/',
      },
  },

You can also use LDAP filters, or Perl expression or mixed expressions in
C<groups> parameter. Perl expressions has to be enclosed with C<{}>:

=over

=item * C<group1 =E<gt> '(|(uid=xavier.guimard)(ou=unit1))'>

=item * C<group1 =E<gt> '{$uid eq "xavier.guimard" or $ou eq "unit1"}'>

=item * C<group1 =E<gt> '(|(uid=xavier.guimard){$ou eq "unit1"})'>

=back

It is also recommended to use Perl expressions to avoid requiring the LDAP
server more than 2 times per authentication.

=head3 B<Accounting>

=head4 I<Logging portal access>

L<Lemonldap::NG::Portal> doesn't log anything by default, but it's easy to overload
C<log> method for normal portal access or using C<error> method to know what
was wrong if C<process> method has failed.

=head4 I<Logging application access>

Because an handler knows nothing about the protected application, it can't do
more than logging URL. As Apache does this fine, L<Lemonldap::NG::Handler>
gives it the name to used in logs. The C<whatToTrace> parameters indicates
which variable Apache has to use (C<$uid> by default).

The real accounting has to be done by the application itself which knows the
result of SQL transaction for example.

Lemonldap::NG can export HTTP headers either using a proxy or protecting
directly the application. By default, the C<Auth-User> field is used but you
can change it using the C<exportedHeaders> parameters (stored in the
configuration database). This parameters contains an associative array per
virtual host:

=over

=item * B<keys> are the names of the chosen headers

=item * B<values> are Perl expressions where you can use user datas stored in
the global store by calling them C<$E<lt>varnameE<gt>>.

=back

Example:

  exportedHeaders => {
      www1.domain.com => {
          'Auth-User' => '$uid',
          'Unit'      => '$ou',
      },
      www2.domain.com => {
          'Authorization' => '"Basic ".encode_base64($employeeNumber.":dummy","")',
          'Remote-IP'     => '$ip',
      },
  }

=head2 Session storage systems

Lemonldap::NG use 3 levels of cache for authenticated users:

=over

=item * an Apache::Session::* module choosed with the C<globalStorage>
parameter (completed with C<globalStorageOptions>) and used by
L<lemonldap::NG::Portal> to store authenticated user parameters,

=item * a L<Cache::Cache> module choosed with the C<localSessionStorage> parameter
(completed with C<localSessionStorageOptions>) and used to share authenticated users
between Apache's threads or processus and of course between virtual hosts,

=item * Lemonldap::NG::Handler variables: if the same user use the same thread
or processus a second time, no request are needed to grant or refuse access.
This is very efficient with HTTP/1.1 Keep-Alive system.

=back

So the number of request to the central storage is limited to 1 per active
user each 10 minutes.

Lemonldap::NG is very fast, but you can increase performance using a
L<Cache::Cache> module that does not use disk access.

=head2 Logout system

Lemonldap::NG provides a single logout system: you can use it by adding a link
to the portal with "logout=1" parameter in the portal (See
L<Lemonldap::NG::Portal>) and/or by configuring handler to intercept some URL
(See Sinopsys). The logout system:

=over

=item * delete session in the global session storage,

=item * replace Lemonldap::NG cookie by '',

=item * delete handler caches only if logout action was started from a
protected application and only in the current Apache server. So in other
servers, session is still in cache for 10 minutes maximum if the user was
connected on it in the last 10 minutes.

=back

You can also configure rules in the Manager interface to intercept logout URL.
See L<Lemonldap::NG::Manager> and L<Lemonldap::NG::Handler> for more.

=head1 USING LEMONLDAP::NG::HANDLER FOR DEVELOPMENT

Lemonldap::NG::Handler provides different modules:

=over

=item * L<Lemonldap::NG::Handler::CGI>: if you have only a few Perl CGI to
protect, you can use this module in your CGI instead of protecting it under
L<Lemonldap::NG::Handler::ApacheMP2>.

=item * L<Lemonldap::NG::Handler::Proxy>: this module isn't used to manage
security but is written to create a reverse-proxy without using mod_proxy. In
some case, mod_proxy does not manage correctly some redirections, that is why
this module still exists.

=back

All those modules are compatible both with Apache and mod_perl version 1 and 2,
but NOT with mod_perl 1.99. If you use Linux distributions like Debian Sarge
who provide mod_perl 1.99 for Apache2, you have to use Apache-1.3 or to
download a mod_perl2 backport.

=head1 SEE ALSO

L<Lemonldap::NG::Handler::DefaultHandler>,
L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Manager>,
L<http://lemonldap-ng.org/>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2005-2012 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Copyright (C) 2012-2015 by François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Copyright (C) 2006-2012 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

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
