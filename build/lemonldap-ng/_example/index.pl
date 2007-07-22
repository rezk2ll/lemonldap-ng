#!/usr/bin/perl

use CGI;

my $cgi=CGI->new;

print $cgi->header;
print $cgi->start_html( 'Page protected by Lemonldap::NG' );
my($headers, $env)=({},{});
use Data::Dumper;
print "<pre>";
foreach(sort keys %ENV) {
    if($_ =~ /^HTTP_/) {
        ($a=$_) =~ s/^HTTP_//i;
        #$a =~ s/_/ /g;
        #$a = ucfirst(lc($a));
        #$a =~ s/ /-/g;
        $a = join '-', map {ucfirst(lc)} split '_',$a;
        $headers->{$a} = $_;
    }
    else {
        $env->{$_} = $ENV{$_};
    }
}
print "</pre>";
print qq#<h1>Authentication succeed</h1>
<a href="/logout">logout</a>
<p>Authenticated user : $ENV{HTTP_AUTH_USER}</p>
<p>To know who is connected in your applications, you can read HTTP headers :</p>
<table border="1" style="font-size: small;">\n
<tr><th>Header</th><th>Perl CGI</th><th>PHP script</th><th>Value</th></tr>
#;
foreach(sort keys %$headers) {
    $style = $_ eq 'Auth-User' ? 'style="background-color: #FFEEEE;font-weight: bold;"' : '';
    print "<tr>
    <td $style>$_</td>
    <td $style>\$ENV{$headers->{$_}}</td>
    <td $style>\$_SERVER{$headers->{$_}}</td>
    <td $style> $ENV{$headers->{$_}}</td>
    </tr>\n"
}
print '</table>
<p>Note that Lemonldap::NG cookie is hidden. So that application developpers can
not spoof sessions.</p>
<p>You can access to any information (IP address or LDAP attribute) by customizing
exported headers with the
<a href="http://manager.example.com/">Lemonldap::NG Management interface</a></p>
<hr />';

print qq#<h2>Environment for Perl CGI :</h2>
<p>Be carefull, the \$ENV{REMOTE_USER} is set only if your script is in the
same server than Lemonldap::NG handler (\$whatToTrace parameter). If you use
it on a reverse-proxy, \$ENV{REMOTE_USER} is not set.</p>
<table border="0" style="font-size: small;">\n#;
foreach(sort keys %ENV) {
    my $tmp = $ENV{$_};
    $tmp =~ s/&/&amp;/g;
    $tmp =~ s/>/&gt;/g;
    $tmp =~ s/</&lt;/g;
    print "<tr><td>$_</td><td>=&gt; $tmp</td></tr>\n";
}
print '</table>';
print $cgi->end_html;

