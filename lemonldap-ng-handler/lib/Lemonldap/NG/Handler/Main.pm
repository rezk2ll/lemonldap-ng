## @file
# Base file for Lemonldap::NG handlers

## @class
# Base class for Lemonldap::NG handlers.
# All methods in handler are class methods: in ModPerl environment, handlers
# are always launched without object created.
#
# The main method is run() who is called by Apache for each requests (using
# handler() wrapper).
#
# The main initialization subroutine is init() who launch localInit() and
# globalInit().
package Lemonldap::NG::Handler::Main;

#use strict;

use MIME::Base64;
use Exporter 'import';

#use AutoLoader 'AUTOLOAD';
use Lemonldap::NG::Common::Crypto;
use Lemonldap::NG::Common::Session;
require POSIX;
use CGI::Util 'expires';
use constant UNPROTECT        => 1;
use constant SKIP             => 2;
use constant MAINTENANCE_CODE => 503;

#inherits Cache::Cache
#inherits Apache::Session
#link Lemonldap::NG::Common::Apache::Session::SOAP protected globalStorage

our $VERSION = '1.4.0';
our ( %EXPORT_TAGS, @EXPORT_OK, @EXPORT );

# my @threadSharedVar = qw(
#     cda                                          cipher
#     cookieExpiration       cookieName            customFunctions
#     defaultCondition       defaultProtection     forgeHeaders
#     globalStorage          globalStorageOptions  headerList
#     httpOnly               https                 key
#     localStorage           localStorageOptions   locationCondition
#     locationConditionText  locationCount         locationProtection
#     locationRegexp         maintenance           port
#     refLocalStorage        safe                  securedCookie
#     statusOut              statusPipe            timeoutActivity
#     transform              useRedirectOnError    useRedirectOnForbidden
#     useSafeJail            whatToTrace
# );
#
# non thread shared vars
# $datas
# $datasUpdate

# Shared variables
our ( $datas, $datasUpdate, $tsv );

##########################################
# COMPATIBILITY WITH APACHE AND APACHE 2 #
##########################################

BEGIN {

    # globalStorage and locationRules are set for Manager compatibility only
    %EXPORT_TAGS = (
        globalStorage  => [qw(  )],
        locationRules  => [qw( )],
        jailSharedVars => [qw( $datas )],
        tsv            => [qw( $tsv )],
        import         => [qw( import @EXPORT_OK @EXPORT %EXPORT_TAGS )],
        post           => [qw(postFilter)],
    );
    push( @EXPORT_OK, @{ $EXPORT_TAGS{$_} } ) foreach ( keys %EXPORT_TAGS );
    $EXPORT_TAGS{all} = \@EXPORT_OK;

    # For importing MP(), required modules, and constants
    use Lemonldap::NG::Handler::API qw(:httpCodes);
    Lemonldap::NG::Handler::API->thread_share($tsv);
}

use Lemonldap::NG::Handler::Initialization::LocalInit;
use Lemonldap::NG::Handler::Initialization::GlobalInit;
use Lemonldap::NG::Handler::Main::Jail;
use Lemonldap::NG::Handler::Main::Headers;
use Lemonldap::NG::Handler::Main::PostForm;
use Lemonldap::NG::Handler::Main::Logger;

sub handler ($$) : method {
    shift->run(@_);
}

sub logout ($$) : method {
    shift->unlog(@_);
}

## @rmethod protected void updateStatus(string user,string url,string action)
# Inform the status process of the result of the request if it is available
# @param request Apache2::RequestRec current request
# @param action string Result of access control (as OK, SKIP, LOGOUT...)
# @param optional user string Username to log, if undefined defaults to remote IP
# @param optional url string URL to log, if undefined defaults to request URI
sub updateStatus {
    my ( $class, $r, $action, $user, $url ) = @_;
    $user ||= Lemonldap::NG::Handler::API->remote_ip($r);
    $url  ||= Lemonldap::NG::Handler::API->uri_with_args($r);
    eval {
            print { $tsv->{statusPipe} } "$user => "
          . Lemonldap::NG::Handler::API->hostname($r)
          . "$url $action\n"
          if ( $tsv->{statusPipe} );
    };
}

## @rmethod protected int forbidden(string uri)
# Used to reject non authorized requests.
# Inform the status processus and call logForbidden().
# @param $r current request
# @param $uri URI
# @return Apache2::Const::REDIRECT or Apache2::Const::FORBIDDEN
sub forbidden {
    my ( $class, $r ) = splice @_;
    my $uri = Lemonldap::NG::Handler::API->unparsed_uri($r);

    if ( $datas->{_logout} ) {
        $class->updateStatus( $r, 'LOGOUT', $datas->{ $tsv->{whatToTrace} } );
        my $u = $datas->{_logout};
        $class->localUnlog;
        return $class->goToPortal( $r, $u, 'logout=1' );
    }

    # Log forbidding
    Lemonldap::NG::Handler::Main::Logger->lmLog(
        "User "
          . $datas->{ $tsv->{whatToTrace} }
          . " was forbidden to access to $uri",
        "notice", $r
    );
    $class->updateStatus( $r, 'REJECT', $datas->{ $tsv->{whatToTrace} } );

    # Redirect or Forbidden?
    if ( $tsv->{useRedirectOnForbidden} ) {
        Lemonldap::NG::Handler::Main::Logger->lmLog(
            "Use redirect for forbidden access",
            'debug', $r );
        return $class->goToPortal( $r, $uri, 'lmError=403' );
    }
    else {
        Lemonldap::NG::Handler::Main::Logger->lmLog( "Return forbidden access",
            'debug', $r );
        return FORBIDDEN;
    }
}

## @rmethod protected void hideCookie()
# Hide Lemonldap::NG cookie to the protected application.
# @param $r current request
sub hideCookie {
    my ( $class, $r ) = @_;
    Lemonldap::NG::Handler::Main::Logger->lmLog( "removing cookie",
        'debug', $r );
    my $cookie = Lemonldap::NG::Handler::API->header_in( $r, 'Cookie' );
    $cookie =~ s/$tsv->{cookieName}(http)?=[^,;]*[,;\s]*//og;
    if ($cookie) {
        Lemonldap::NG::Handler::API->set_header_in( $r, 'Cookie' => $cookie );
    }
    else {
        Lemonldap::NG::Handler::API->unset_header_in( $r, 'Cookie' );
    }
}

## @rmethod protected string encodeUrl(string url)
# Encode URl in the format used by Lemonldap::NG::Portal for redirections.
# @return Base64 encoded string
sub encodeUrl {
    my ( $class, $r, $url ) = splice @_;
    $url = $class->_buildUrl( $r, $url ) if ( $url !~ m#^https?://# );
    return encode_base64( $url, '' );
}

## @rmethod protected int goToPortal(string url, string arg)
# Redirect non-authenticated users to the portal by setting "Location:" header.
# @param $r current request
# @param $url Url requested
# @param $arg optionnal GET parameters
# @return Apache2::Const::REDIRECT
sub goToPortal {
    my ( $class, $r, $url, $arg ) = splice @_;
    Lemonldap::NG::Handler::Main::Logger->lmLog(
        "Redirect "
          . Lemonldap::NG::Handler::API->remote_ip($r)
          . " to portal (url was $url)",
        'debug', $r
    );
    my $urlc_init = $class->encodeUrl( $r, $url );
    Lemonldap::NG::Handler::API->set_header_out( $r,
            'Location' => $class->portal()
          . "?url=$urlc_init"
          . ( $arg ? "&$arg" : "" ) );
    return REDIRECT;
}

## @rmethod protected $ fetchId()
# Get user cookies and search for Lemonldap::NG cookie.
# @param $r current request
# @return Value of the cookie if found, 0 else
sub fetchId {
    my ( $class, $r ) = @_;
    my $t = Lemonldap::NG::Handler::API->header_in( $r, 'Cookie' );
    my $vhost = Lemonldap::NG::Handler::API->hostname($r);
    my $lookForHttpCookie = $tsv->{securedCookie} =~ /^(2|3)$/
      && !(
        defined( $tsv->{https}->{$vhost} )
        ? $tsv->{https}->{$vhost}
        : $tsv->{https}->{_}
      );
    my $value =
      $lookForHttpCookie
      ? ( $t =~ /$tsv->{cookieName}http=([^,; ]+)/o ? $1 : 0 )
      : ( $t =~ /$tsv->{cookieName}=([^,; ]+)/o ? $1 : 0 );

    $value = $tsv->{cipher}->decryptHex( $value, "http" )
      if ( $value && $lookForHttpCookie && $tsv->{securedCookie} == 3 );
    return $value;
}

## @rmethod protected boolean retrieveSession(id)
# Tries to retrieve the session whose index is id
# @return true if the session was found, false else
sub retrieveSession {
    my ( $class, $id, $r ) = @_;

    # 1. Search if the user was the same as previous (very efficient in
    # persistent connection).
    return 1
      if (  defined $datas->{_session_id}
        and $id eq $datas->{_session_id}
        and ( time() - $datasUpdate < 60 ) );

    # 2. Get the session from cache or backend
    my $apacheSession = Lemonldap::NG::Common::Session->new(
        {
            storageModule        => $tsv->{globalStorage},
            storageModuleOptions => $tsv->{globalStorageOptions},
            cacheModule          => $tsv->{localSessionStorage},
            cacheModuleOptions   => $tsv->{localSessionStorageOptions},
            id                   => $id,
            kind                 => "SSO",
        }
    );

    if ( $datas = $apacheSession->data ) {

        # Update the session to notify activity, if necessary
        $apacheSession->update( { '_lastSeen' => time } )
          if ( $tsv->{timeoutActivity} );

        $datasUpdate = time();
        return 1;
    }
    else {
        Lemonldap::NG::Handler::Main::Logger->lmLog(
            "Session $id can't be retrieved",
            'info', $r );
        return 0;
    }
}

# MAIN SUBROUTINE called by Apache (using PerlHeaderParserHandler option)

## @rmethod int run(Apache2::RequestRec r)
# Main method used to control access.
# Calls :
# - fetchId()
# - retrieveSession()
# - lmSetApacheUser()
# - grant()
# - forbidden() if user is rejected
# - sendHeaders() if user is granted
# - hideCookie()
# - updateStatus()
# @param $r Current request
# @return Apache2::Const value (OK, FORBIDDEN, REDIRECT or SERVER_ERROR)
sub run ($$) {
    my ( $class, $r ) = splice @_;
    return DECLINED
      unless ( Lemonldap::NG::Handler::API->is_initial_req($r) );

    # Direct return if maintenance mode is active
    if ( $class->checkMaintenanceMode($r) ) {

        if ( $tsv->{useRedirectOnError} ) {
            Lemonldap::NG::Handler::Main::Logger->lmLog(
                "Got to portal with maintenance error code",
                'debug', $r );
            return $class->goToPortal( $r, '/', 'lmError=' . MAINTENANCE_CODE );
        }
        else {
            Lemonldap::NG::Handler::Main::Logger->lmLog(
                "Return maintenance error code",
                'debug', $r );
            return MAINTENANCE_CODE;
        }
    }

    # Cross domain authentication
    my $uri = Lemonldap::NG::Handler::API->unparsed_uri($r);
    if (    $tsv->{cda}
        and $uri =~ s/[\?&;]($tsv->{cookieName}(http)?=\w+)$//oi )
    {
        my $str = $1;
        Lemonldap::NG::Handler::Main::Logger->lmLog( 'CDA request', 'debug',
            $r );
        my $redirectUrl = $class->_buildUrl( $r, $uri );
        my $redirectHttps = ( $redirectUrl =~ m/^https/ );
        Lemonldap::NG::Handler::API->set_err_header_out(
            $r,
            'Location'   => $redirectUrl,
            'Set-Cookie' => "$str; path=/"
              . ( $redirectHttps   ? "; secure"   : "" )
              . ( $tsv->{httpOnly} ? "; HttpOnly" : "" )
              . (
                $tsv->{cookieExpiration}
                ? "; expires=" . expires( $tsv->{cookieExpiration}, 'cookie' )
                : ""
              )
        );
        return REDIRECT;
    }

    $uri = Lemonldap::NG::Handler::API->uri_with_args($r);
    my $protection = $class->isUnprotected( $r, $uri );

    if ( $protection == SKIP ) {
        Lemonldap::NG::Handler::Main::Logger->lmLog( "Access control skipped",
            'debug', $r );
        $class->updateStatus( $r, 'SKIP' );
        $class->hideCookie($r);
        Lemonldap::NG::Handler::Main::Headers->cleanHeaders( $r,
            $tsv->{forgeHeaders}, $tsv->{headerList} );
        return OK;
    }

    my $id;

    # Try to recover cookie and user session
    if (    $id = $class->fetchId($r)
        and $class->retrieveSession( $id, $r ) )
    {

        # AUTHENTICATION done

        # Local macros
        my $kc = keys %$datas;    # in order to detect new local macro

        # ACCOUNTING (1. Inform Apache)
        Lemonldap::NG::Handler::API->set_user( $r,
            $datas->{ $tsv->{whatToTrace} } );

        # AUTHORIZATION
        return $class->forbidden($r)
          unless ( $class->grant( $r, $uri ) );
        $class->updateStatus( $r, 'OK', $datas->{ $tsv->{whatToTrace} } );

        # ACCOUNTING (2. Inform remote application)
        Lemonldap::NG::Handler::Main::Headers->sendHeaders( $r,
            $tsv->{forgeHeaders} );

        # Store local macros
        if ( keys %$datas > $kc and $class->initLocalStorage ) {
            Lemonldap::NG::Handler::Main::Logger->lmLog( "Update local cache",
                'debug', $r );
            $tsv->{refLocalStorage}->set( $id, $datas );
        }

        # Hide Lemonldap::NG cookie
        $class->hideCookie($r);

        # Log access granted
        Lemonldap::NG::Handler::Main::Logger->lmLog(
            "User "
              . $datas->{ $tsv->{whatToTrace} }
              . " was granted to access to $uri",
            'debug', $r
        );

        #  Catch POST rules
        Lemonldap::NG::Handler::Main::PostForm->transformUri( $r, $uri );

        return OK;
    }

    elsif ( $protection == UNPROTECT ) {

        # Ignore unprotected URIs
        Lemonldap::NG::Handler::Main::Logger->lmLog(
            "No valid session but unprotected access",
            'debug', $r );
        $class->updateStatus( $r, 'UNPROTECT' );
        $class->hideCookie($r);
        Lemonldap::NG::Handler::Main::Headers->cleanHeaders( $r,
            $tsv->{forgeHeaders}, $tsv->{headerList} );
        return OK;
    }

    else {

        # Redirect user to the portal
        Lemonldap::NG::Handler::Main::Logger->lmLog( "No cookie found",
            'info', $r )
          unless ($id);

        # if the cookie was fetched, a log is sent by retrieveSession()
        $class->updateStatus( $r, $id ? 'EXPIRED' : 'REDIRECT' );
        return $class->goToPortal( $r,
            Lemonldap::NG::Handler::API->unparsed_uri($r) );
    }
}

## @rmethod protected boolean checkMaintenanceMode
# Check if we are in maintenance mode
# @param $r current request
# @return true if maintenance mode
sub checkMaintenanceMode {
    my ( $class, $r ) = @_;
    my $vhost = Lemonldap::NG::Handler::API->hostname($r);
    my $_maintenance =
      ( defined $tsv->{maintenance}->{$vhost} )
      ? $tsv->{maintenance}->{$vhost}
      : $tsv->{maintenance}->{_};

    if ($_maintenance) {
        Lemonldap::NG::Handler::Main::Logger->lmLog(
            "Maintenance mode activated",
            'debug', $r );
        return 1;
    }

    return 0;
}

## @rmethod int abort(string mess)
# Logs message and exit or redirect to the portal if "useRedirectOnError" is
# set to true.
# @param $r current request
# @param $msg Message to log
# @return Apache2::Const::REDIRECT or Apache2::Const::SERVER_ERROR
sub abort {
    my ( $class, $r, $msg ) = splice @_;

    # If abort is called without a valid request, fall to die
    eval {
        my $uri = Lemonldap::NG::Handler::API->unparsed_uri($r);

        Lemonldap::NG::Handler::Main::Logger->lmLog( $msg, 'error', $r );

        # Redirect or die
        if ( $tsv->{useRedirectOnError} ) {
            Lemonldap::NG::Handler::Main::Logger->lmLog(
                "Use redirect for error",
                'debug', $r );
            return $class->goToPortal( $r, $uri, 'lmError=500' );
        }
        else {
            return SERVER_ERROR;
        }
    };
    die $msg if ($@);
}

sub initLocalStorage {
    my $class = shift;
    return 1 if ($tsv->{refLocalStorage});
    return 0 unless ($tsv->{localStorage});

    eval "use $tsv->{localStorage}";
    die("Unable to load $self->{localStorage}: $@") if ($@);
    eval '$tsv->{refLocalStorage} = new '
           . $tsv->{localStorage}
           . '($tsv->{localStorageOptions});';
    die("Unable to init local cache: $@") if ($@);
    return 1;
}

## @imethod void localInit(hashRef args)
# instanciate a LocalInit object with variables:
# localStorage, localStorageOptions, refLocalStorage
# launch localInit method which launch the status processus,
# @param $args reference to the initialization hash
sub localInit($$) {
    my ( $class, $args ) = splice @_;

    my $localinit = Lemonldap::NG::Handler::Initialization::LocalInit->new(
        localStorage        => $tsv->{localStorage},
        localStorageOptions => $tsv->{localStorageOptions},
    );
    (
        @$tsv{
            qw( localStorage localStorageOptions statusPipe statusOut )
          }
    ) = $localinit->localInit($args);

}

## @imethod void globalInit(hashRef args)
# instanciate a GlobalInit object with variables:
# customFunctions, useSafeJail, and safe
# Global initialization process launches :
# - defaultValuesInit()
# - portalInit()
# - locationRulesInit()
# - globalStorageInit()
# - localSessionStorageInit()
# - headerListInit()
# - forgeHeadersInit()
# - postUrlInit()
# @param $args reference to the configuration hash
sub globalInit {
    my $class = shift;

    my $globalinit = Lemonldap::NG::Handler::Initialization::GlobalInit->new(
        customFunctions => $tsv->{customFunctions},
        useSafeJail     => $tsv->{useSafeJail},
        safe            => $tsv->{safe},
    );

    (
        @$tsv{
            qw( cookieName      securedCookie      whatToTrace
              https           port               customFunctions
              timeoutActivity useRedirectOnError useRedirectOnForbidden
              useSafeJail     key                maintenance
              cda             httpOnly           cookieExpiration
              cipher )
          }
      )
      = $globalinit->defaultValuesInit(
        @$tsv{
            qw( cookieName      securedCookie      whatToTrace
              https           port               customFunctions
              timeoutActivity useRedirectOnError useRedirectOnForbidden
              useSafeJail     key                maintenance
              cda             httpOnly           cookieExpiration
              cipher )
          },
        @_
      );

    ( *portal, $tsv->{safe} ) = $globalinit->portalInit( $class, @_ );

    (
        @$tsv{
            qw( locationCount defaultCondition
              defaultProtection locationCondition
              locationProtection locationRegexp
              locationConditionText safe )
          }
      )
      = $globalinit->locationRulesInit(
        $class,
        @$tsv{
            qw( locationCount defaultCondition
              defaultProtection locationCondition
              locationProtection locationRegexp
              locationConditionText )
          },
        @_
      );

    @$tsv{qw( globalStorage globalStorageOptions )} =
      $globalinit->globalStorageInit(
        @$tsv{qw( globalStorage globalStorageOptions )}, @_ );

    @$tsv{qw( localSessionStorage localSessionStorageOptions )} =
      $globalinit->localSessionStorageInit(
        @$tsv{qw( localSessionStorage localSessionStorageOptions )}, @_ );

    $tsv->{headerList} = $globalinit->headerListInit( $tsv->{headerList}, @_ );

    $tsv->{forgeHeaders} =
      $globalinit->forgeHeadersInit( $tsv->{forgeHeaders}, @_ );

    $tsv->{transform} = $globalinit->postUrlInit( $tsv->{transform}, @_ );

}

## @rmethod boolean grant()
# Grant or refuse client using compiled regexp and functions
# @param $r current request
# @param $uri URI
# @return True if the user is granted to access to the current URL
sub grant {
    my ( $class, $r, $uri ) = splice @_;
    my $vhost = Lemonldap::NG::Handler::API->hostname($r);
    for ( my $i = 0 ; $i < $tsv->{locationCount}->{$vhost} ; $i++ ) {
        if ( $uri =~ $tsv->{locationRegexp}->{$vhost}->[$i] ) {
            Lemonldap::NG::Handler::Main::Logger->lmLog(
                'Regexp "'
                  . $tsv->{locationConditionText}->{$vhost}->[$i]
                  . '" match',
                'debug', $r
            );
            return &{ $tsv->{locationCondition}->{$vhost}->[$i] }($r);
        }
    }
    unless ( $tsv->{defaultCondition}->{$vhost} ) {
        Lemonldap::NG::Handler::Main::Logger->lmLog(
            "User rejected because VirtualHost \"$vhost\" has no configuration",
            'warn', $r
        );
        return 0;
    }
    Lemonldap::NG::Handler::Main::Logger->lmLog( "$vhost: Apply default rule",
        'debug', $r );
    return &{ $tsv->{defaultCondition}->{$vhost} }($r);
}

## @cmethod private string _buildUrl(string s)
# Transform /<s> into http(s?)://<host>:<port>/s
# @param $r current request
# @param $s path
# @return URL
sub _buildUrl {
    my ( $class, $r, $s ) = splice @_;
    my $vhost = Lemonldap::NG::Handler::API->hostname($r);
    my $portString =
         $tsv->{port}->{$vhost}
      || $tsv->{port}->{_}
      || Lemonldap::NG::Handler::API->get_server_port($r);
    my $_https = (
        defined( $tsv->{https}->{$vhost} )
        ? $tsv->{https}->{$vhost}
        : $tsv->{https}->{_}
    );
    $portString =
        ( $_https  && $portString == 443 ) ? ''
      : ( !$_https && $portString == 80 )  ? ''
      :                                      ':' . $portString;
    my $url = "http" . ( $_https ? "s" : "" ) . "://$vhost$portString$s";
    Lemonldap::NG::Handler::Main::Logger->lmLog( "Build URL $url", 'debug',
        $r );
    return $url;
}

## @rmethod int unprotect()
# Used to unprotect an area.
# To use it, set "PerlHeaderParserHandler My::Package->unprotect" Apache
# configuration file.
# It replace run() by doing nothing.
# @return Apache2::Const::OK
sub unprotect {
    OK;
}

## @rmethod protected void localUnlog()
# Delete current user from local cache entry.
sub localUnlog {
    my $class = shift;
    if ( my $id = $class->fetchId($r) ) {

        # Delete Apache thread datas
        if ( $id eq $datas->{_session_id} ) {
            $datas = {};
        }

        # Delete Apache local cache
        if ( $tsv->{refLocalStorage} and $tsv->{refLocalStorage}->get($id) ) {
            $tsv->{refLocalStorage}->remove($id);
        }
    }
}

## @rmethod protected int unlog(Apache::RequestRec r)
# Call localUnlog() then goToPortal() to unlog the current user.
# @param $r current request
# @return Apache2::Const value returned by goToPortal()
sub unlog ($$) {
    my ( $class, $r ) = @_;
    $class->localUnlog;
    $class->updateStatus( $r, 'LOGOUT' );
    return $class->goToPortal( $r, '/', 'logout=1' );
}

## @rmethod int status(Apache2::RequestRec $r)
# Get the result from the status process and launch a PerlResponseHandler to
# display it.
# @param $r Current request
# @return Apache2::Const::OK
sub status($$) {
    my ( $class, $r ) = splice @_;
    Lemonldap::NG::Handler::Main::Logger->lmLog( "Request for status",
        'debug', $r );
    return $class->abort( $r, "$class: status page can not be displayed" )
      unless ( $tsv->{statusPipe} and $tsv->{statusOut} );
    $r->handler("perl-script");
    print { $tsv->{statusPipe} } "STATUS"
      . (
        Lemonldap::NG::Handler::API->args($r)
        ? " " . Lemonldap::NG::Handler::API->args($r)
        : ''
      ) . "\n";
    my $buf;
    my $statusOut = $tsv->{statusOut};
    while ($statusOut) {
        last if (/^END$/);
        $buf .= $_;
    }
    Lemonldap::NG::Handler::API->set_header_out( $r,
        ( "Content-Type" => "text/html; charset=UTF-8" ) );
    Lemonldap::NG::Handler::API->print( $buf, $r );
    return OK;
}

## @rmethod protected int redirectFilter(string url, Apache2::Filter f)
# Launch the current HTTP request then redirects the user to $url.
# Used by logout_app and logout_app_sso targets
# @param $url URL to redirect the user
# @param $f Current Apache2::Filter object
# @return Apache2::Const::OK
sub redirectFilter {
    my $class = shift;
    my $url   = shift;
    my $f     = shift;
    unless ( $f->ctx ) {

        # Here, we can use Apache2 functions instead of set_header_out
        # since this function is used only with Apache2.
        $f->r->status(REDIRECT);
        $f->r->status_line("303 See Other");
        $f->r->headers_out->unset('Location');
        $f->r->err_headers_out->set( 'Location' => $url );
        $f->ctx(1);
    }
    while ( $f->read( my $buffer, 1024 ) ) {
    }
    $class->updateStatus( $f->r, 'REDIRECT', $datas->{ $tsv->{whatToTrace} },
        'filter' );
    return OK;
}

## @rmethod protected int isUnprotected()
# @param $r current request
# @param $uri URI
# @return 0 if URI is protected,
# UNPROTECT if it is unprotected by "unprotect",
# SKIP if is is unprotected by "skip"
sub isUnprotected {
    my ( $class, $r, $uri ) = splice @_;
    my $vhost = Lemonldap::NG::Handler::API->hostname($r);
    for ( my $i = 0 ; $i < $tsv->{locationCount}->{$vhost} ; $i++ ) {
        if ( $uri =~ $tsv->{locationRegexp}->{$vhost}->[$i] ) {
            return $tsv->{locationProtection}->{$vhost}->[$i];
        }
    }
    return $tsv->{defaultProtection}->{$vhost};
}

1;
