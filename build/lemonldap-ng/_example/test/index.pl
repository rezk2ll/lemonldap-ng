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
my $manager_url = "http://manager.__DNSDOMAIN__";
my $portal_url = "http://auth.__DNSDOMAIN__";

# CSS
my $css = <<EOT;
body{
background:$color;
font-family:sans-serif;
font-size:11pt;
padding:0 5%;
margin:0;
}
#content{
background:#fff;
padding:10px;
}
#menu{
text-align:center;
margin-top:30px;
}
a{
text-decoration:none;
font-weight:bold;
}
h1{
font-size:16pt;
text-align:center;
margin:5px 100px;
border:2px solid $color;
}
h2{
border-bottom:2px solid $color;
}
p.note{
border:1px solid #ccc;
padding:5px;
background:#eee;
}
table{
border:1px solid #ccc;
border-collapse:collapse;
margin:5px 0;
width:100%;
font-size:small;
}
tr{
border:1px dotted #ccc;
}
tr:hover{
background:#eee;
}
th{
background:#eee;
}
td, th{
padding:3px 5px;
}
td.emphase{
background-color:#eee;
font-weight:bold;
}
EOT

# Read headers
my %headers;
foreach(sort keys %ENV) {
    if($_ =~ /^HTTP_/) {
        ($a=$_) =~ s/^HTTP_//i;
        $a = join '-', map {ucfirst(lc)} split '_',$a;
        $headers->{$a} = $_;
    }
}

# Display page
print $cgi->header(-charset => 'utf-8');
print $cgi->start_html( -title => "$name",
                        -style => { -code => $css } );

print "<div id=\"content\">\n";

print "<h1>$name</h1>\n";

print "<div id=\"menu\"><a href=\"$portal_url\">Portal</a> - <a href=\"/logout\">Logout</a></div>\n";

print "<h2>Main informations</h2>\n";
print "<ul>\n";
print "<li>Authentication status: SUCCESS</li>\n";
print "<li>Connected user: <ul>\n";
print "<li><tt>\$ENV{HTTP_AUTH_USER}</tt>: $ENV{HTTP_AUTH_USER}</li>\n";
print "<li><tt>\$ENV{REMOTE_USER}</tt>: $ENV{REMOTE_USER}</li>\n";
print "</ul></li>\n";
print "</ul>\n";
print "<p class=\"note\">Be carefull, the <tt>\$ENV{REMOTE_USER}</tt> is set only if your script is 
in the same server than Lemonldap::NG Handler (<tt>\$whatToTrace</tt> parameter). If you use
it on a reverse-proxy, <tt>\$ENV{REMOTE_USER}</tt> is not set.</p>\n";

print "<h2>HTTP headers</h2>\n";
print "<p>To know who is connected in your applications, you can read HTTP headers:</p>\n";
print "<table>\n";
print "<tr><th>Header</th><th>Perl CGI</th><th>PHP script</th><th>Value</th></tr>\n";
foreach(sort keys %$headers) {
    next if $_ =~ /(Accept|Cache|User-Agent|Connection|Keep-Alive)/i;
    $style = $_ eq 'Auth-User' ? 'class="emphase"' : '';
    print "<tr>
    <td $style>$_</td>
    <td $style><tt>\$ENV{$headers->{$_}}</tt></td>
    <td $style><tt>\$_SERVER{$headers->{$_}}</tt></td>
    <td $style><ul>";
    foreach( split( /;/, $ENV{$headers->{$_}} ) ) {
        print "<li>$_</li>";
    }
    print "</ul></td>
    </tr>\n";
}
print "</table>\n";
print "<p class=\"note\">Note that Lemonldap::NG cookie is hidden. So that application developpers can
not spoof sessions.</p>\n";
print "<p class=\"note\">You can access to any information (IP address or LDAP attribute) by customizing
exported headers with the <a href=\"$manager_url\">Lemonldap::NG Management interface</a></p>\n";

print "<h2>Environment for Perl CGI</h2>\n";
print "<table>\n";
print "<tr><th>Environment variable</th><th>Value</th></tr>\n";
foreach(sort keys %ENV) {
    my $tmp = $ENV{$_};
    $tmp =~ s/&/&amp;/g;
    $tmp =~ s/>/&gt;/g;
    $tmp =~ s/</&lt;/g;
    print "<tr><td>$_</td><td>=&gt; $tmp</td></tr>\n";
}
print "</table>\n";
print "</div>\n";
print $cgi->end_html;

