package Lemonldap::NG::Handler::API;

use Exporter 'import';

our $VERSION = '1.4.0';

our %EXPORT_TAGS;

our @EXPORT_OK;

our @EXPORT;


# sharedConf variables
our $cfgNum     = 0;
our $lastReload = 0;
our $reloadTime;
our $lmConf;
our $localConfig;

# Main variables
our $tsv;



BEGIN {

    # export of MP() (kept for compatibility till MP is completely vanished)
    %EXPORT_TAGS = (
        webserverCodes => [
            qw( MP OK REDIRECT FORBIDDEN DONE DECLINED SERVER_ERROR )
        ],
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
    my $mp = $ENV{MOD_PERL_API_VERSION};
    my $mode =
        $mp && $mp >= 2    ? "ApacheMP2"
      : $mp                ? "ApacheMP1"
      : $main::{'nginx::'} ? "Nginx"
      :                      "CGI";
    # Load constants and make inheritance
    eval "use Lemonldap::NG::Handler::API::$mode ':webserverCodes';
          use base Lemonldap::NG::Handler::API::$mode;";


}




1;
