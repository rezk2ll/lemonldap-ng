package Lemonldap::NG::Handler::API;

use Exporter 'import';

our $VERSION = '1.4.0';
our ( %EXPORT_TAGS, @EXPORT_OK, @EXPORT );

# export of MP() (kept for compatibility till MP is completely vanished)
%EXPORT_TAGS = (
    httpCodes => [
        qw( MP OK REDIRECT FORBIDDEN DONE DECLINED SERVER_ERROR AUTH_REQUIRED MAINTENANCE )
    ],
    functions => [
        qw( &hostname &remote_ip &uri &uri_with_args
          &unparsed_uri &args &method &header_in )
    ]
);
push( @EXPORT_OK, @{ $EXPORT_TAGS{$_} } ) foreach ( keys %EXPORT_TAGS );
$EXPORT_TAGS{all} = \@EXPORT_OK;

# definition of MP() (kept for compatibility till MP is completely vanished)
if ( exists $ENV{MOD_PERL} ) {
    if ( $ENV{MOD_PERL_API_VERSION} and $ENV{MOD_PERL_API_VERSION} >= 2 ) {
        eval 'use constant MP => 2;';
    }
    else {
        eval 'use constant MP => 1;';
    }
}
else {
    eval 'use constant MP => 0;';
}

# Load appropriate specific API module :
# - Apache (modperl 2),
# - Apache (modperl1),
# - Nginx
my $gi = $ENV{GATEWAY_INTERFACE};
my $mp = $ENV{MOD_PERL_API_VERSION};
my $mode =
    $gi && $gi =~ /^CGI/ ? "CGI"
  : $mp && $mp >= 2      ? "ApacheMP2"
  : $mp                ? "ApacheMP1"
  : $main::{'nginx::'} ? "Nginx"
  :                      "CGI";

# Load API functions and constants
eval "use Lemonldap::NG::Handler::API::$mode (':httpCodes', ':functions');
      use base Lemonldap::NG::Handler::API::$mode;";

die $@ if($@);
1;
