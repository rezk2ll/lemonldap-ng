package Lemonldap::NG::Handler::API;

use Exporter 'import';

our $VERSION = '1.4.0';
our ( %EXPORT_TAGS, @EXPORT_OK, @EXPORT );

BEGIN {
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

    if   ( $ENV{GATEWAY_INTERFACE} ) { eval 'use constant GI => 1;'; }
    else                             { eval 'use constant GI => 0;'; }

}

sub AUTOLOAD {
    my $func = $AUTOLOAD;
    $func =~ s/^.*:://;

    # Launch appropriate specific API function:
    # - Apache (modperl 2),
    # - Apache (modperl1),
    # - Nginx
    my $mode =
        GI                 ? 'CGI'
      : ( MP == 2 )        ? 'ApacheMP2'
      : ( MP == 1 )        ? 'ApacheMP1'
      : $main::{'nginx::'} ? 'Nginx'
      : ( caller(6) and ( caller(6) )[0] eq 'Lemonldap::NG::Handler::PSGI' )
      ? 'PSGI'
      : 'CGI';
    unless ( $INC{"Lemonldap/NG/Handler/API/$mode.pm"} ) {
        eval
"use Lemonldap::NG::Handler::API::$mode (':httpCodes', ':functions');";
        die $@ if ($@);
    }
    return &{"Lemonldap::NG::Handler::API::$mode::$func"}(@_);
}

1;
