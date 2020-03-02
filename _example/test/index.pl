#!/usr/bin/perl

#================================================
# LemonLDAP::NG default test page
# Display headers and environment
#================================================

# Init CGI
use CGI;
my $cgi = CGI->new;

# GET parameters
my $name = $cgi->param("name") || "LemonLDAP::NG sample protected application";
my $color = $cgi->param("color") || "#ddd";

# Local parameters
my $host = $ENV{HTTP_HOST};
my ( $domain, $port ) = ( $host =~ /\w+\.([^:]+)(:\d+)?/ );
my $protocol    = ( $ENV{HTTPS} =~ /^on$/i ) ? "https" : "http";
my $portal_url  = "$protocol://auth.$domain$port";
my $manager_url = "$protocol://manager.$domain$port";

# CSS
my $css = <<EOT;
html,body{
  height:100%;
  background:$color;
}
#content{
  padding:20px;
}
EOT

# Read headers
my %headers;
foreach ( sort keys %ENV ) {
    if ( $_ =~ /^HTTP_/ ) {
        ( $a = $_ ) =~ s/^HTTP_//i;
        $a = join '-', map { ucfirst(lc) } split '_', $a;
        $headers->{$a} = $_;
    }
}

# Display page
print $cgi->header( -charset => 'utf-8' );

print "<!DOCTYPE html>\n";
print qq{<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">\n};
print "<head>\n";
print qq{<meta charset="utf-8">\n};
print "<title>$name</title>\n";
print
  "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n";
print
  "<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\" />\n";
print "<meta http-equiv=\"cache-control\" content=\"no-cache\" />\n";
print
"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n";
print
"<link href=\"$portal_url/static/bwr/bootstrap/dist/css/bootstrap.css\" rel=\"stylesheet\">\n";
print
"<link href=\"$portal_url/static/bwr/bootstrap/dist/css/bootstrap-theme.css\" rel=\"stylesheet\">\n";
print "<style>\n";
print "$css\n";
print "</style>\n";
print
"<script type=\"text/javascript\" src=\"$portal_url/static/bwr/jquery/dist/jquery.js\"></script>\n";
print
"<script type=\"text/javascript\" src=\"$portal_url/static/bwr/jquery-ui/jquery-ui.js\"></script>\n";
print
"<script src=\"$portal_url/static/bwr/bootstrap/dist/js/bootstrap.js\"></script>\n";
print "</head>\n";
print "<body>\n";

print "<div id=\"content\" class=\"container\">\n";
print "<div class=\"card border-info\">\n";

print "<div class=\"card-header text-white bg-info mb-3\">\n";
print "<h1 class=\"text-center\">$name</h1>\n";
print "</div>\n";

print "<div class=\"card-body\">\n";

print "<div class=\"card border-info mb-3\">\n";
print "<div class=\"card-header text-white bg-info\">\n";
print "<h2 class=\"card-title text-center\">Main information</h2>\n";
print "</div>\n";
print "<div class=\"card-body\">\n";
print "<ul class=\"list-unstyled\">\n";
print
"<li><strong>Authentication status:</strong> <span class=\"badge badge-success\">Success</span></li>\n";
print "<li>Connected user: <ul>\n";
print "<li><tt>\$ENV{HTTP_AUTH_USER}</tt>: $ENV{HTTP_AUTH_USER}</li>\n";
print "<li><tt>\$ENV{REMOTE_USER}</tt>: $ENV{REMOTE_USER}</li>\n";
print "</ul><li>Groups: <ul>\n";
for my $grp (split /; /, $ENV{HTTP_AUTH_GROUPS}) {
print "<li>$grp</li>\n";
}
print "</ul></li>\n";
print "</ul>\n";
print
"<div class=\"alert alert-warning\">Be carefull, the <tt>\$ENV{REMOTE_USER}</tt> is set only if your script is in the same server than LemonLDAP::NG Handler (<tt>\$whatToTrace</tt> parameter). If you use it behind a reverse-proxy or in another server than Apache, <tt>REMOTE_USER</tt> is not set. See <a href=\"$manager_url/doc/pages/documentation/current/header_remote_user_conversion.html\">this documentation page</a> to know how to convert an HTTP header into an environment variable.</div>\n";
print "</div>\n";
print "</div>\n";

print "<div class=\"card border-info mb-3\">\n";
print "<div class=\"card-header text-white bg-info\">\n";
print "<h2 class=\"card-title text-center\">HTTP headers</h2>\n";
print "</div>\n";
print "<div class=\"card-body\">\n";
print
"<p>To know who is connected in your applications, you can read HTTP headers:</p>\n";
print "<div class=\"table-responsive\">\n";
print "<table class=\"table table-striped table-hover\">\n";
print
"<thead><tr><th>Header</th><th>CGI environment variable</th><th>PHP script</th><th>Value</th></tr></thead><tbody>\n";

foreach ( sort keys %$headers ) {
    next if $_ =~ /(Accept|Cache|User-Agent|Connection|Keep-Alive)/i;
    print qq{<tr>
    <td id="h-$_">$_</td>
    <td><tt>$headers->{$_}</tt></td>
    <td><tt>\$_SERVER{$headers->{$_}}</tt></td>
    <td id="v-$_">};
    print $ENV{ $headers->{$_} } // "☒",;
    print "</td></tr>\n";
}
print "</tbody></table>\n";
print "</div><p></p>\n";
print
"<div class=\"alert alert-warning\">Note that LemonLDAP::NG cookie is hidden. So that application developers can not spoof sessions.</div>\n";
print
"<div class=\"alert alert-info\">You can access to any information (IP address or LDAP attribute) by customizing exported headers with the <a href=\"$manager_url\">LemonLDAP::NG Management interface</a>.</div>\n";
print "</div>\n";
print "</div>\n";

print "<div class=\"card border-info mb-3\">\n";
print "<div class=\"card-header text-white bg-info\">\n";
print "<h2 class=\"card-title text-center\">Scripts parameters</h2>\n";
print "</div>\n";
print "<div class=\"card-body\">\n";
print "<p>Find here all GET or POST parameters sent to this page:</p>\n";
print "<div class=\"table-responsive\">\n";
print "<table class=\"table table-striped table-hover\">\n";
print "<thead><tr><th>Parameter</th><th>Value</th></tr></thead><tbody>\n";

foreach ( sort $cgi->param() ) {
    my $tmp = $cgi->param($_);
    print
qq{<tr><td>$_</td><td><big>☞</big> <span id="field_$_">$tmp</span></td></tr>\n};
}
print "</tbody></table>\n";
print "</div>\n";
print
"<div class=\"alert alert-info\">POST parameters can be forged by LemonLDAP::NG to <a href=\"$manager_url/doc/pages/documentation/current/formreplay.html\">autosubmit forms</a>.</div>\n";
print "</div>\n";
print "</div>\n";

print "<div class=\"card border-info mb-3\">\n";
print "<div class=\"card-header text-white bg-info\">\n";
print "<h2 class=\"card-title text-center\">Environment for Perl CGI</h2>\n";
print "</div>\n";
print "<div class=\"card-body\">\n";
print "<div class=\"table-responsive\">\n";
print "<table class=\"table table-striped table-hover\">\n";
print
"<thead><tr><th>Environment variable</th><th>Value</th></tr></thead><tbody>\n";

foreach ( sort keys %ENV ) {
    my $tmp = $ENV{$_};
    $tmp =~ s/&/&amp;/g;
    $tmp =~ s/>/&gt;/g;
    $tmp =~ s/</&lt;/g;
    print "<tr><td>$_</td><td><big>☞</big> $tmp</td></tr>\n";
}
print "</tbody></table>\n";
print "</div>\n";
print "</div>\n";
print "</div>\n";

print "</div>\n";
print "</div>\n";
print "</div>\n";

print $cgi->end_html;

