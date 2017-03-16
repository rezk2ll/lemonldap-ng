# Main running methods file
package Lemonldap::NG::Handler::Main::Run;

our $VERSION = '2.0.0';

package Lemonldap::NG::Handler::Main;

use strict;

#use AutoLoader 'AUTOLOAD';
use MIME::Base64;
use URI::Escape;
use Lemonldap::NG::Common::Session;

# Methods that must be overloaded

sub handler {
    die "Must be overloaded" unless ($#_);
    my ($res) = $_[0]->run( $_[1] );
    return $res;
}

sub logout {
    my $class;
    $class = $#_ ? shift : __PACKAGE__;
    $class->newRequest( $_[0] );
    return $class->unlog();
}

sub status {
    my $class;
    $class = $#_ ? shift : __PACKAGE__;
    $class->newRequest( $_[0] );
    return $class->getStatus();
}

# Public methods

# Return Handler::Lib::Status output
sub getStatus {
    my ($class) = @_;
    $class->logger->debug("Request for status");
    my $statusPipe = $class->tsv->{statusPipe};
    my $statusOut  = $class->tsv->{statusOut};
    return $class->abort("$class: status page can not be displayed")
      unless ( $statusPipe and $statusOut );
    print $statusPipe "STATUS"
      . ( $class->args ? " " . $class->args : '' ) . "\n";
    my $buf;

    while (<$statusOut>) {
        last if (/^END$/);
        $buf .= $_;
    }
    $class->set_header_out( ( "Content-Type" => "text/html; charset=UTF-8" ) );
    $class->print($buf);
    return $class->OK;
}

# Method that must be called by base packages (Handler::ApacheMP2,...) to get
# type of handler to call (Main, AuthBasic,...)
sub checkType {
    my ( $class, $req ) = @_;

    $class->newRequest($req);
    if ( time() - $class->lastCheck > $class->checkTime ) {
        die("$class: No configuration found")
          unless ( $class->checkConf );
    }
    my $vhost = $class->resolveAlias;
    return ( defined $class->tsv->{type}->{$vhost} )
      ? $class->tsv->{type}->{$vhost}
      : 'Main';
}

## @rmethod int run
# Check configuration and launch Lemonldap::NG::Handler::Main::run().
# Each $checkTime, the Apache child verify if its configuration is the same
# as the configuration stored in the local storage.
# @param $rule optional Perl expression to grant access
# @return Apache constant

sub run {
    my ( $class, $req, $rule, $protection ) = @_;
    my ( $id, $session );

    return $class->DECLINED unless ( $class->is_initial_req );

    # Direct return if maintenance mode is active
    if ( $class->checkMaintenanceMode ) {

        if ( $class->tsv->{useRedirectOnError} ) {
            $class->logger->debug("Go to portal with maintenance error code");
            return $class->goToError( '/', $class->MAINTENANCE );
        }
        else {
            $class->logger->debug("Return maintenance error code");
            return $class->MAINTENANCE;
        }
    }

    # Cross domain authentication
    my $uri = $class->unparsed_uri;

    $uri = $class->uri_with_args;
    my ($cond);
    ( $cond, $protection ) = $class->conditionSub($rule) if ($rule);
    $protection = $class->isUnprotected($uri) || 0
      unless ( defined $protection );

    if ( $protection == $class->SKIP ) {
        $class->logger->debug("Access control skipped");
        $class->updateStatus('SKIP');
        $class->hideCookie;
        $class->cleanHeaders;
        return $class->OK;
    }

    # Try to recover cookie and user session
    if (    $id = $class->fetchId
        and $session = $class->retrieveSession($id) )
    {

        # AUTHENTICATION done

        # Local macros
        my $kc = keys %{$session};    # in order to detect new local macro

        # ACCOUNTING (1. Inform web server)
        $class->set_user( $session->{ $class->tsv->{whatToTrace} } );

        # AUTHORIZATION
        return ( $class->forbidden($session), $session )
          unless ( $class->grant( $session, $uri, $cond ) );
        $class->updateStatus( 'OK', $session->{ $class->tsv->{whatToTrace} } );

        # ACCOUNTING (2. Inform remote application)
        $class->sendHeaders($session);

        # Store local macros
        if ( keys %$session > $kc ) {
            $class->logger->debug("Update local cache");
            $class->session->update( $session, { updateCache => 2 } );
        }

        # Hide Lemonldap::NG cookie
        $class->hideCookie;

        # Log access granted
        $class->logger->debug( "User "
              . $session->{ $class->tsv->{whatToTrace} }
              . " was granted to access to $uri" );

        #  Catch POST rules
        $class->postOutputFilter( $session, $uri );
        $class->postInputFilter( $session, $uri );

        return ( $class->OK, $session );
    }

    elsif ( $protection == $class->UNPROTECT ) {

        # Ignore unprotected URIs
        $class->logger->debug("No valid session but unprotected access");
        $class->updateStatus('UNPROTECT');
        $class->hideCookie;
        $class->cleanHeaders;
        return $class->OK;
    }

    else {

        # Redirect user to the portal
        $class->logger->info("No cookie found")
          unless ($id);

        # if the cookie was fetched, a log is sent by retrieveSession()
        $class->updateStatus( $id ? 'EXPIRED' : 'REDIRECT' );
        return $class->goToPortal( $class->unparsed_uri );
    }
}

## @rmethod protected int unlog()
# Call localUnlog() then goToPortal() to unlog the current user.
# @return Constant value returned by goToPortal()
sub unlog {
    my $class = shift;
    $class->localUnlog(@_);
    $class->updateStatus('LOGOUT');
    return $class->goToPortal( '/', 'logout=1' );
}

# INTERNAL METHODS

## @rmethod protected void updateStatus(string action,string user,string url)
# Inform the status process of the result of the request if it is available
# @param action string Result of access control (as $class->OK, $class->SKIP, LOGOUT...)
# @param optional user string Username to log, if undefined defaults to remote IP
# @param optional url string URL to log, if undefined defaults to request URI
sub updateStatus {
    my ( $class, $action, $user, $url ) = @_;
    my $statusPipe = $class->tsv->{statusPipe} or return;
    $user ||= $class->remote_ip;
    $url  ||= $class->uri_with_args;
    eval {
        print $statusPipe "$user => " . $class->hostname . "$url $action\n";
    };
}

## @rmethod void lmLog(string msg, string level)
# Wrapper for Apache log system
# @param $msg message to log
# @param $level string (emerg|alert|crit|error|warn|notice|info|debug)
sub lmLog {
    my ( $class, $msg, $level ) = @_;
    return $class->logger->$level($msg);
}

## @rmethod protected boolean checkMaintenanceMode
# Check if we are in maintenance mode
# @return true if maintenance mode
sub checkMaintenanceMode {
    my $class = shift;
    my $vhost = $class->resolveAlias;
    my $_maintenance =
      ( defined $class->tsv->{maintenance}->{$vhost} )
      ? $class->tsv->{maintenance}->{$vhost}
      : $class->tsv->{maintenance}->{_};

    if ($_maintenance) {
        $class->logger->debug("Maintenance mode activated");
        return 1;
    }
    return 0;
}

## @rmethod boolean grant(string uri, string cond)
# Grant or refuse client using compiled regexp and functions
# @param $uri URI
# @param $cond optional Function granting access
# @return True if the user is granted to access to the current URL
sub grant {
    my ( $class, $session, $uri, $cond, $vhost ) = @_;
    return $cond->($session) if ($cond);

    $vhost ||= $class->resolveAlias;
    for (
        my $i = 0 ;
        $i < ( $class->tsv->{locationCount}->{$vhost} || 0 ) ;
        $i++
      )
    {
        if ( $uri =~ $class->tsv->{locationRegexp}->{$vhost}->[$i] ) {
            $class->logger->debug( 'Regexp "'
                  . $class->tsv->{locationConditionText}->{$vhost}->[$i]
                  . '" match' );
            return $class->tsv->{locationCondition}->{$vhost}->[$i]->($session);
        }
    }
    unless ( $class->tsv->{defaultCondition}->{$vhost} ) {
        $class->logger->warn(
            "User rejected because VirtualHost \"$vhost\" has no configuration"
        );
        return 0;
    }
    $class->logger->debug("$vhost: Apply default rule");
    return $class->tsv->{defaultCondition}->{$vhost}->($session);
}

## @rmethod protected int forbidden(string uri)
# Used to reject non authorized requests.
# Inform the status processus and call logForbidden().
# @param $uri URI
# @return Constant $class->FORBIDDEN
sub forbidden {
    my ( $class, $session, $vhost ) = @_;
    my $uri = $class->unparsed_uri;
    $vhost ||= $class->resolveAlias;

    if ( $session->{_logout} ) {
        $class->updateStatus( 'LOGOUT',
            $session->{ $class->tsv->{whatToTrace} } );
        my $u = $session->{_logout};
        $class->localUnlog;
        return $class->goToPortal( $u, 'logout=1' );
    }

    # Log forbidding
    $class->userLogger->notice( "User "
          . $session->{ $class->tsv->{whatToTrace} }
          . " was forbidden to access to $vhost$uri" );
    $class->updateStatus( 'REJECT', $session->{ $class->tsv->{whatToTrace} } );

    # Redirect or Forbidden?
    if ( $class->tsv->{useRedirectOnForbidden} ) {
        $class->logger->debug("Use redirect for forbidden access");
        return $class->goToError( $uri, 403 );
    }
    else {
        $class->logger->debug("Return forbidden access");
        return $class->FORBIDDEN;
    }
}

## @rmethod protected void hideCookie()
# Hide Lemonldap::NG cookie to the protected application.
sub hideCookie {
    my $class = shift;
    $class->logger->debug("removing cookie");
    my $cookie = $class->header_in('Cookie');
    my $cn     = $class->tsv->{cookieName};
    $cookie =~ s/$cn(http)?=[^,;]*[,;\s]*//og;
    if ($cookie) {
        $class->set_header_in( 'Cookie' => $cookie );
    }
    else {
        $class->unset_header_in('Cookie');
    }
}

## @rmethod protected string encodeUrl(string url)
# Encode URl in the format used by Lemonldap::NG::Portal for redirections.
# @return Base64 encoded string
sub encodeUrl {
    my ( $class, $url ) = @_;
    $url = $class->_buildUrl($url) if ( $url !~ m#^https?://# );
    return encode_base64( $url, '' );
}

## @rmethod protected int goToPortal(string url, string arg)
# Redirect non-authenticated users to the portal by setting "Location:" header.
# @param $url Url requested
# @param $arg optionnal GET parameters
# @return Constant $class->REDIRECT
sub goToPortal {
    my ( $class, $url, $arg ) = @_;
    my ( $ret, $msg );
    my $urlc_init = $class->encodeUrl($url);
    $class->logger->debug(
        "Redirect " . $class->remote_ip . " to portal (url was $url)" );
    $class->set_header_out( 'Location' => $class->tsv->{portal}->()
          . "?url=$urlc_init"
          . ( $arg ? "&$arg" : "" ) );
    return $class->REDIRECT;
}

sub goToError {
    my ( $class, $url, $code ) = @_;
    my $urlc_init = $class->encodeUrl($url);
    $class->logger->debug(
        "Redirect " . $class->remote_ip . " to lmError (url was $url)" );
    $class->set_header_out( 'Location' => $class->tsv->{portal}->()
          . "/lmerror/$code"
          . "?url=$urlc_init" );
    return $class->REDIRECT;
}

## @rmethod protected fetchId()
# Get user cookies and search for Lemonldap::NG cookie.
# @return Value of the cookie if found, 0 else
sub fetchId {
    my $class             = shift;
    my $t                 = $class->header_in('Cookie') or return 0;
    my $vhost             = $class->resolveAlias;
    my $lookForHttpCookie = (
        $class->tsv->{securedCookie} =~ /^(2|3)$/
          and !( defined( $class->tsv->{https}->{$vhost} ) )
        ? $class->tsv->{https}->{$vhost}
        : $class->tsv->{https}->{_}
    );
    my $cn = $class->tsv->{cookieName};
    my $value =
      $lookForHttpCookie
      ? ( $t =~ /${cn}http=([^,; ]+)/o ? $1 : 0 )
      : ( $t =~ /$cn=([^,; ]+)/o ? $1 : 0 );

    if ( $value && $lookForHttpCookie && $class->tsv->{securedCookie} == 3 ) {
        $value = $class->tsv->{cipher}->decryptHex( $value, "http" );
    }
    elsif ( $value =~ s/^c:// ) {
        $value = $class->tsv->{cipher}->decrypt($value);
        unless ( $value =~ s/^(.*)? (.*)$/$1/ and $2 eq $vhost ) {
            $class->userLogger->error(
                "Bad CDA cookie: available for $2 instead od $vhost");
            return undef;
        }
    }
    return $value;
}

## @rmethod protected boolean retrieveSession(id)
# Tries to retrieve the session whose index is id
# @return true if the session was found, false else
sub retrieveSession {
    my ( $class, $id ) = @_;
    my $now = time();

    # 1. Search if the user was the same as previous (very efficient in
    # persistent connection).
    if (    defined $class->datas->{_session_id}
        and $id eq $class->datas->{_session_id}
        and ( $now - $class->datasUpdate < 60 ) )
    {
        $class->logger->debug("Get session $id from Handler internal cache");
        return $class->datas;
    }

    # 2. Get the session from cache or backend
    my $session = $class->session(
        Lemonldap::NG::Common::Session->new(
            {
                storageModule        => $class->tsv->{sessionStorageModule},
                storageModuleOptions => $class->tsv->{sessionStorageOptions},
                cacheModule          => $class->tsv->{sessionCacheModule},
                cacheModuleOptions   => $class->tsv->{sessionCacheOptions},
                id                   => $id,
                kind                 => "SSO",
            }
        )
    );

    unless ( $session->error ) {

        $class->datas( $session->data );

        $class->logger->debug("Get session $id");

        # Verify that session is valid
        if (
            $now - $session->data->{_utime} > $class->tsv->{timeout}
            or (    $class->tsv->{timeoutActivity}
                and $session->data->{_lastSeen}
                and $now - $session->data->{_lastSeen} >
                $class->tsv->{timeoutActivity} )
          )
        {
            $class->logger->info("Session $id expired");

            # Clean cached data
            $class->datas( {} );
            return 0;
        }

        # Update the session to notify activity, if necessary
        if (
            $class->tsv->{timeoutActivity}
            and ( $now - $session->data->{_lastSeen} >
                $class->tsv->{timeoutActivityInterval} )
          )
        {
            $class->session->update( { '_lastSeen' => $now } );

            if ( $session->error ) {
                $class->logger->error("Cannot update session $id");
                $class->logger->error( $class->session->error );
            }
            else {
                $class->logger->debug("Update _lastSeen with $now");
            }
        }

        $class->datasUpdate($now);
        return $session->data;
    }
    else {
        $class->logger->info("Session $id can't be retrieved");
        $class->logger->info( $session->error );

        return 0;
    }
}

## @cmethod private string _buildUrl(string s)
# Transform /<s> into http(s?)://<host>:<port>/s
# @param $s path
# @return URL
sub _buildUrl {
    my ( $class, $s ) = @_;
    my $vhost  = $class->hostname;
    my $_https = (
        defined( $class->tsv->{https}->{$vhost} )
        ? $class->tsv->{https}->{$vhost}
        : $class->tsv->{https}->{_}
    );
    my $portString =
         $class->tsv->{port}->{$vhost}
      || $class->tsv->{port}->{_}
      || $class->get_server_port;
    $portString = (
             ( $_https  && $portString == 443 )
          or ( !$_https && $portString == 80 )
    ) ? '' : ":$portString";
    my $url = "http" . ( $_https ? "s" : "" ) . "://$vhost$portString$s";
    $class->logger->debug("Build URL $url");
    return $url;
}

## @rmethod protected int isUnprotected()
# @param $uri URI
# @return 0 if URI is protected,
# $class->UNPROTECT if it is unprotected by "unprotect",
# SKIP if is is unprotected by "skip"
sub isUnprotected {
    my ( $class, $uri ) = @_;
    my $vhost = $class->resolveAlias;
    for (
        my $i = 0 ;
        $i < ( $class->tsv->{locationCount}->{$vhost} || 0 ) ;
        $i++
      )
    {
        if ( $uri =~ $class->tsv->{locationRegexp}->{$vhost}->[$i] ) {
            return $class->tsv->{locationProtection}->{$vhost}->[$i];
        }
    }
    return $class->tsv->{defaultProtection}->{$vhost};
}

## @rmethod void sendHeaders()
# Launch function compiled by forgeHeadersInit() for the current virtual host
sub sendHeaders {
    my ( $class, $session ) = @_;
    my $vhost = $class->resolveAlias;
    if ( defined $class->tsv->{forgeHeaders}->{$vhost} ) {

        # Log headers in debug mode
        my %headers = $class->tsv->{forgeHeaders}->{$vhost}->($session);
        foreach my $h ( sort keys %headers ) {
            if ( defined( my $v = $headers{$h} ) ) {
                $class->logger->debug("Send header $h with value $v");
            }
            else {
                $class->logger->debug("Send header $h with empty value");
            }
        }
        $class->set_header_in(%headers);
    }
}

## @rmethod void cleanHeaders()
# Unset HTTP headers, when sendHeaders is skipped
sub cleanHeaders {
    my $class = shift;
    my $vhost = $class->resolveAlias;
    if ( defined( $class->tsv->{headerList}->{$vhost} ) ) {
        $class->unset_header_in( @{ $class->tsv->{headerList}->{$vhost} } );
    }
}

## @rmethod string resolveAlias
# returns vhost whose current hostname is an alias
sub resolveAlias {
    my $class = shift;
    my $vhost = $class->hostname;
    return $class->tsv->{vhostAlias}->{$vhost} || $vhost;
}

#__END__

## @rmethod int abort(string msg)
# Logs message and exit or redirect to the portal if "useRedirectOnError" is
# set to true.
# @param $msg Message to log
# @return Constant ($class->REDIRECT, $class->SERVER_ERROR)
sub abort {
    my ( $class, $msg ) = @_;

    # If abort is called without a valid request, fall to die
    eval {
        my $uri = $class->unparsed_uri;

        $class->logger->error($msg);

        # Redirect or die
        if ( $class->tsv->{useRedirectOnError} ) {
            $class->logger->debug("Use redirect for error");
            return $class->goToError( $uri, 500 );
        }
        else {
            return $class->SERVER_ERROR;
        }
    };
    die $msg if ($@);
}

## @rmethod protected void localUnlog()
# Delete current user from local cache entry.
sub localUnlog {
    my ( $class, $id ) = @_;
    $class->logger->debug('Local handler logout');
    if ( $id //= $class->fetchId ) {

        # Delete thread datas
        if (    $class->datas->{_session_id}
            and $id eq $class->datas->{_session_id} )
        {
            $class->datas( {} );
        }

        # Delete local cache
        if (    $class->tsv->{refLocalStorage}
            and $class->tsv->{refLocalStorage}->get($id) )
        {
            $class->tsv->{refLocalStorage}->remove($id);
        }
    }
}

## @rmethod protected postOutputFilter(string uri)
# Add a javascript to html page in order to fill html form with fake data
# @param uri URI to catch
sub postOutputFilter {
    my ( $class, $session, $uri ) = @_;
    my $vhost = $class->resolveAlias;

    if ( defined( $class->tsv->{outputPostData}->{$vhost}->{$uri} ) ) {
        $class->logger->debug("Filling a html form with fake data");

        $class->unset_header_in("Accept-Encoding");
        my %postdata =
          $class->tsv->{outputPostData}->{$vhost}->{$uri}->($session);
        my $formParams = $class->tsv->{postFormParams}->{$vhost}->{$uri};
        my $js = $class->postJavascript( \%postdata, $formParams );
        $class->addToHtmlHead($js);
    }
}

## @rmethod protected postInputFilter(string uri)
# Replace request body with form datas defined in configuration
# @param uri URI to catch
sub postInputFilter {
    my ( $class, $session, $uri ) = @_;
    my $vhost = $class->resolveAlias;

    if ( defined( $class->tsv->{inputPostData}->{$vhost}->{$uri} ) ) {
        $class->logger->debug("Replacing fake data with real form data");

        my %data = $class->tsv->{inputPostData}->{$vhost}->{$uri}->($session);
        foreach ( keys %data ) {
            $data{$_} = uri_escape( $data{$_} );
        }
        $class->setPostParams( \%data );
    }
}

## @rmethod protected postJavascript(hashref data)
# build a javascript to fill a html form with fake data
# @param data hashref containing input => value
sub postJavascript {
    my ( $class, $data, $formParams ) = @_;

    my $form = $formParams->{formSelector} || "form";

    my $filler;
    foreach my $name ( keys %$data ) {
        use bytes;
        my $value = "x" x bytes::length( $data->{$name} );
        $filler .=
"form.find('input[name=$name], select[name=$name], textarea[name=$name]').val('$value')\n";
    }

    my $submitter =
        $formParams->{buttonSelector} eq "none" ? ""
      : $formParams->{buttonSelector}
      ? "form.find('$formParams->{buttonSelector}').click();\n"
      : "form.submit();\n";

    my $jqueryUrl = $formParams->{jqueryUrl} || "";
    $jqueryUrl = &{ $class->tsv->{portal} } . "skins/common/js/jquery-1.10.2.js"
      if ( $jqueryUrl eq "default" );
    $jqueryUrl = "<script type='text/javascript' src='$jqueryUrl'></script>\n"
      if ($jqueryUrl);

    return
        $jqueryUrl
      . "<script type='text/javascript'>\n"
      . "/* script added by Lemonldap::NG */\n"
      . "jQuery(window).on('load', function() {\n"
      . "var form = jQuery('$form');\n"
      . "form.attr('autocomplete', 'off');\n"
      . $filler
      . $submitter . "})\n"
      . "</script>\n";
}

1;
