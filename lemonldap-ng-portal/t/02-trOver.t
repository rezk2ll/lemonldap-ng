use warnings;
use Test::More;
use strict;
use IO::String;
use utf8;

require 't/test-lib.pm';

my $portal = LLNG::Manager::Test->new( {
        ini => {
            portal           => 'http://auth.example.com/',
            portalSkin       => 'troverride',
            skinTemplateDir  => 't/templates',
            msg_mymessage    => "Message défini",
            msg_fr_mymessage => "Message traduit",
            msg_es_myother   => "otro mensaje",
        }
    }
);

ok(
    my $res = $portal->_get(
        "/",
        accept => "text/html",
        host   => "auth.example.com"
    )
);

is_deeply(
    getJsVars($res)->{trOver},
    {
        'all' => {
            'mycode'    => 'my code in all languages',
            'mymessage' => 'Message défini',
        },
        'es' => {
            myother => "otro mensaje",
        },
        'fr' => {
            'mycode'    => 'mon code en français',
            'mymessage' => 'Message traduit',
        }
    }
);

clean_sessions();
done_testing();
