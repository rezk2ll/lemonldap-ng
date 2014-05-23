package Lemonldap::NG::Handler::API;

use Exporter 'import';

BEGIN {
    my $mp = $ENV{MOD_PERL_API_VERSION};
    my $mode =
        $mp && $mp >= 2    ? "ApacheMP2" :
        $mp                ? "ApacheMP1" :
        $main::{'nginx::'} ? "Nginx"     :
                             "CGI";
    eval "use base Lemonldap::NG::Handler::API::$mode";
}

1;
