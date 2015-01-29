#!/usr/bin/perl -w

# Simple OpenID Connect client

use strict;
use JSON;
use LWP::UserAgent;
use MIME::Base64;
use URI::Escape;
use CGI;
use Data::Dumper;

#==============================================================================
# Configuration
#==============================================================================
my $client_id         = "lemonldap";
my $client_secret     = "secret";
my $portal_url        = "http://auth.example.com";
my $authorization_uri = "$portal_url/oauth2/authorize";
my $token_uri         = "$portal_url/oauth2/token";

#==============================================================================
# CSS
#==============================================================================
my $css = <<EOT;
html,body{
  height:100%;
  background:#ddd;
}
#content{
  padding:20px;
}
EOT

#==============================================================================
# Main
#==============================================================================
my $ua           = new LWP::UserAgent;
my $cgi          = new CGI;
my $redirect_uri = $cgi->url . "?openidconnectcallback=1";

# Start HTTP response
print $cgi->header();

print "<!DOCTYPE html>\n";
print
  "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n";
print "<head>\n";
print "<title>OpenID Connect sample client</title>\n";
print
  "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n";
print
  "<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\" />\n";
print "<meta http-equiv=\"cache-control\" content=\"no-cache\" />\n";
print
"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n";
print
"<link href=\"$portal_url/skins/bootstrap/css/bootstrap.css\" rel=\"stylesheet\">\n";
print
"<link href=\"$portal_url/skins/bootstrap/css/bootstrap-theme.css\" rel=\"stylesheet\">\n";
print "<style>\n";
print "$css\n";
print "</style>\n";
print
"<script type=\"text/javascript\" src=\"/skins/common/js/jquery-1.10.2.js\"></script>\n";
print
"<script type=\"text/javascript\" src=\"/skins/common/js/jquery-ui-1.10.3.custom.js\"></script>\n";
print "<script src=\"$portal_url/skins/bootstrap/js/bootstrap.js\"></script>\n";
print "</head>\n";
print "<body>\n";

print "<div id=\"content\" class=\"container\">\n";
print "<div class=\"panel panel-info panel-body\">\n";

print "<div class=\"page-header\">\n";
print "<h1 class=\"text-center\">OpenID Connect sample client</h1>\n";
print "</div>\n";

# Check callback
my $callback = $cgi->param("openidconnectcallback");

unless ($callback) {

    # AuthN Request
    my $response_type = uri_escape("code");
    my $scope         = uri_escape("openid profile email");
    $client_id    = uri_escape($client_id);
    $redirect_uri = uri_escape($redirect_uri);
    my $state = uri_escape("ABCDEFGHIJKLMNOPQRSTUVWXXZ");

    my $redirect_url = $authorization_uri
      . "?response_type=$response_type&client_id=$client_id&scope=$scope&redirect_uri=$redirect_uri&state=$state";

    print
"<h3 class=\"text-center\">Login on <a href=\"$authorization_uri\">$authorization_uri</a></h3>\n";
    print "<div class=\"text-center\">\n";
    print
"<a href=\"$redirect_url\" class=\"btn btn-info\" role=\"button\">Authorization flow</a>\n";
    print "</div>\n";
}
else {

    print "<h2 class=\"text-center\">Callback received</h2>";

    print "<div class=\"panel panel-info\">\n";
    print "<div class=\"panel-heading\">\n";
    print
"<h2 class=\"panel-title text-center\">OpenID Connect callback received</h2>\n";
    print "</div>\n";
    print "<div class=\"panel-body\">\n";
    print "<pre><code>"
      . $cgi->url( -path_info => 1, -query => 1 )
      . "</code></pre>\n";
    print "</div>\n";
    print "</div>\n";

    # AuthN Response
    my $state = $cgi->param("state");
    my $code  = $cgi->param("code");

    # Check state
    unless ( $state eq "ABCDEFGHIJKLMNOPQRSTUVWXXZ" ) {
        print "<div class=\"alert alert-danger\">";
        print "<p>OpenIDConnect callback state $state is invalid</p>";
        print "</div>";
        print
"<div class=\"text-center\"><a class=\"btn btn-info\" role=\"button\" href=\""
          . $cgi->url
          . "\">Home</a></div>\n";
        print "</div>";
        print "</div>";
        print $cgi->end_html();
        exit 0;
    }

    my $grant_type = "authorization_code";

    my %form;
    $form{"code"}          = $code;
    $form{"client_id"}     = $client_id;
    $form{"client_secret"} = $client_secret;
    $form{"redirect_uri"}  = $redirect_uri;
    $form{"grant_type"}    = $grant_type;

    my $response = $ua->post( $token_uri, \%form,
        "Content-Type" => 'application/x-www-form-urlencoded' );

    if ( $response->is_error ) {
        print "<div class=\"alert alert-danger\">";
        print "<p>Bad authorization response: " . $response->message . "</p>";
        print "<p>$response->content</p>";
        print "</div>";
        print
"<div class=\"text-center\"><a class=\"btn btn-info\" role=\"button\" href=\""
          . $cgi->url
          . "\">Home</a></div>\n";
        print "</div>";
        print "</div>";
        print $cgi->end_html();
        exit 0;
    }

    # Get access_token and id_token
    my $content = $response->decoded_content;

    my $json;
    eval { $json = decode_json $content; };

    if ($@) {
        print "<div class=\"alert alert-danger\">";
        print "<p>Wrong JSON content</p>";
        print "</div>";
        print
"<div class=\"text-center\"><a class=\"btn btn-info\" role=\"button\" href=\""
          . $cgi->url
          . "\">Home</a></div>\n";
        print "</div>";
        print "</div>";
        print $cgi->end_html();
        exit 0;
    }

    if ( $json->{error} ) {
        print "<div class=\"alert alert-danger\">";
        print "<p>Error in token response:" . $json->{error} . "</p>";
        print "</div>";
        print
"<div class=\"text-center\"><a class=\"btn btn-info\" role=\"button\" href=\""
          . $cgi->url
          . "\">Home</a></div>\n";
        print "</div>";
        print "</div>";
        print $cgi->end_html();
        exit 0;
    }

    my $access_token = $json->{access_token};
    my $id_token     = $json->{id_token};

    print "<div class=\"panel panel-info\">\n";
    print "<div class=\"panel-heading\">\n";
    print "<h2 class=\"panel-title text-center\">Tokens</h2>\n";
    print "</div>\n";
    print "<div class=\"panel-body\">\n";
    print "<pre>Access token: <code>$access_token</code></pre>";
    print "<pre>ID token: <code>$id_token</code></pre>";
    print "</div>\n";
    print "</div>\n";

    # Get ID token content
    my ( $id_token_header, $id_token_payload, $id_token_signature ) =
      split( /\./, $id_token );

    # TODO check signature

    my $id_token_payload_hash = decode_json( decode_base64($id_token_payload) );

    print "<div class=\"panel panel-info\">\n";
    print "<div class=\"panel-heading\">\n";
    print "<h2 class=\"panel-title text-center\">ID Token content</h2>\n";
    print "</div>\n";
    print "<div class=\"panel-body\">\n";
    print "<pre>" . Dumper($id_token_payload_hash) . "</pre>";
    print "</div>\n";
    print "</div>\n";

    print
"<div class=\"text-center\"><a class=\"btn btn-info\" role=\"button\" href=\""
      . $cgi->url
      . "\">Home</a></div>\n";

}

print "</div>\n";
print "</div>\n";

print $cgi->end_html();
exit 0;
