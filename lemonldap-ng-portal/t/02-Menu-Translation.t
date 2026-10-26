use warnings;
use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

# Only categories and applications having a translation key are translated

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            portal          => 'http://auth.example.com/',
            authentication  => 'Demo',
            userDB          => 'Same',
            applicationList => {
                '1translated' => {
                    catname => 'My category',
                    type    => 'category',
                    options => { translation => 'myCat' },
                    app1    => {
                        type    => 'application',
                        options => {
                            name        => 'My app',
                            description => 'My description',
                            tooltip     => 'My tooltip',
                            uri         => 'http://app1.example.com/',
                            display     => 'on',
                            logo        => 'demo.png',
                            translation => 'myApp',
                        },
                    },
                    app2 => {
                        type    => 'application',
                        options => {
                            name        => 'Other app',
                            uri         => 'http://app2.example.com/',
                            display     => 'on',
                            logo        => 'demo.png',
                            translation => 'otherApp',
                        },
                    },
                },
                '2raw' => {
                    catname => 'logout',
                    type    => 'category',
                    options => { translation => 'bad key' },

                    # Key containing "order": must not be taken for a property
                    recorder => {
                        type    => 'application',
                        options => {
                            name        => 'password',
                            description => 'Free text, with comma',
                            uri         => 'http://recorder.example.com/',
                            display     => 'on',
                            logo        => 'demo.png',
                        },
                    },
                },
            },
        }
    }
);

my $s   = 'user=dwho&password=dwho';
my $res = $client->_post(
    '/', IO::String->new($s),
    length => length($s),
    accept => 'text/html',
);
my $id = expectCookie($res);
ok(
    $res = $client->_get(
        '/',
        cookie => "lemonldap=$id",
        accept => 'text/html',
    ),
    'Get menu'
);

sub attrs {
    my ( $xpath, $attr ) = @_;
    return [ map { $_->getAttribute($attr) } getHtmlElement( $res, $xpath ) ];
}

sub texts {
    my ($xpath) = @_;
    return [ map { my $t = $_->textContent; $t =~ s/^\s+|\s+$//g; $t }
          getHtmlElement( $res, $xpath ) ];
}

# Categories
is_deeply(
    attrs(
        '//div[contains(@class,"1translated")]//h4/span[@trspan]', 'trspan'
    ),
    ['myCat'],
    'Category with a key is translated'
);
is_deeply( texts('//div[contains(@class,"1translated")]//h4/span[@trspan]'),
    ['My category'], 'Category name is kept as fallback' );
is_deeply(
    attrs( '//div[contains(@class,"2raw")]//h4/span[@trspan]', 'trspan' ),
    [], 'Category with an invalid key is not translated' );
is_deeply( texts('//div[contains(@class,"2raw")]//h4'),
    ['logout'], 'Category name is displayed as is' );

# Applications: the configured values are used as fallback
is_deeply(
    attrs( '//div[contains(@class,"app1")]//*[@trspan]', 'trspan' ),
    [ 'myApp', 'myApp_desc' ],
    'Name and description of app1 are translated'
);
is_deeply( texts('//div[contains(@class,"app1")]//p[@troptional]'),
    ['My description'], 'Description of app1 is kept as fallback' );
is_deeply( attrs( '//div[contains(@class,"app1")]/a', 'trattribute' ),
    ['title:myApp_tip'], 'Tooltip of app1 is translated' );
is_deeply( attrs( '//div[contains(@class,"app1")]/a', 'title' ),
    ['My tooltip'], 'Tooltip of app1 is kept as fallback' );
is_deeply(
    attrs( '//div[contains(@class,"app2")]//*[@trspan]', 'trspan' ),
    [ 'otherApp', 'otherApp_desc' ],
    'Name and description of app2 are translated'
);
is_deeply( texts('//div[contains(@class,"app2")]//p[@troptional]'),
    [''], 'Description of app2 is empty without translation' );
is_deeply(
    attrs( '//div[contains(@class,"app2")]/a', 'trattribute' ),
    ['title:otherApp_tip|otherApp'],
    'Tooltip of app2 is translated, with the name as fallback'
);
is_deeply( attrs( '//div[contains(@class,"app2")]/a', 'title' ),
    ['Other app'], 'Tooltip of app2 defaults to the name' );
is_deeply(
    attrs(
        '//div[contains(@class,"recorder")]//*[@trspan or @trattribute]',
        'trspan'
    ),
    [],
    'Application without key is not translated'
);
is_deeply( texts('//div[contains(@class,"recorder")]//h5'),
    ['password'], 'Application name is displayed as is' );
is_deeply( texts('//div[contains(@class,"recorder")]//p'),
    ['Free text, with comma'], 'Application description is displayed as is' );

$client->logout($id);
clean_sessions();
done_testing();
