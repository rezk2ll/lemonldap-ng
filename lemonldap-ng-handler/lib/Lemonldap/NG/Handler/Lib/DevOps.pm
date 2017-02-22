package Lemonldap::NG::Handler::Lib::DevOps;

use strict;
use Lemonldap::NG::Common::UserAgent;
use JSON qw(from_json);

our $VERSION = '2.0.0';

our $_ua;

our $time;

sub ua {
    return $_ua if ($_ua);
    return $_ua = Lemonldap::NG::Common::UserAgent->new( $_[0]->localConfig );
}

sub grant {
    my ( $class, $session, $uri, $cond, $vhost ) = @_;
    $vhost ||= $class->resolveAlias;
    $class->tsv->{lastVhostUpdate} //= {};
    unless ( $class->tsv->{defaultCondition}->{$vhost}
        and ( time() - $class->tsv->{lastVhostUpdate}->{$vhost} < 600 ) )
    {
        $class->loadVhostConfig($vhost);
    }
    return $class->Lemonldap::NG::Handler::Main::grant( $session, $uri, $cond,
        $vhost );
}

sub loadVhostConfig {
    my ( $class, $vhost ) = @_;
    my $json;
    if ( $class->tsv->{useSafeJail} ) {
        my $base = $class->localConfig->{loopBackUrl}
          || "http://127.0.0.1:" . $class->get_server_port;
        my $req = HTTP::Request->new( GET => "$base/rules.json" );
        $req->header( Host => $vhost );
        my $resp = $class->ua->request($req);
        if ( $resp->is_success ) {
            eval { $json = from_json( $resp->content ) };
            if ($@) {
                $class->logger->error(
                    "Bad rules.json for $vhost, skipping ($@)");
            }
        }
    }
    else {
        $class->logger->error(
q"I refuse to compile rules.json when useSafeJail isn't activated! Yes I know, I'm a coward..."
        );
    }
    $json->{rules} ||= { default => 1 };
    $json->{headers} //= { 'Auth-User' => '$uid' };
    $class->locationRulesInit( undef, { $vhost => $json->{rules} } );
    $class->headersInit( undef, { $vhost => $json->{headers} } );
    $class->tsv->{lastVhostUpdate}->{$vhost} = time;
    return;
}

1;
