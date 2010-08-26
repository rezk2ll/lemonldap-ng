# CAS sample client
use strict;
use CGI;
use AuthCAS;

my $cas_url    = 'https://auth.example.com/cas';

my $cas = new AuthCAS( casUrl => $cas_url );
my $cgi = new CGI;

my $login_url = $cas->getServerLoginURL( $cgi->url() );

print $cgi->header();
print $cgi->start_html('CAS sample client');

my $ticket = $cgi->param('ticket');

unless ($ticket) {
    print $cgi->h1("Click below to use CAS");
    print $cgi->h2("<a href=\"$login_url\">CAS LOGIN</a>");
}
else {
    print $cgi->h1("CAS login done");
    print $cgi->h2("Received ticket: $ticket");
    my $user = $cas->validateST( $cgi->url(), $ticket );
    if ($user) {
        print $cgi->h2("Authenticated user: $user");
    }
    else {
        print $cgi->h2("Error: ".&AuthCAS::get_errors());
    }
}

print $cgi->end_html();

exit;
