##@file
# All configuration attributes

##@class
# All configuration attributes

package Lemonldap::NG::Common::Conf::Attributes;

use Mouse;

our $VERSION = 1.4.0;

has 'domain' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'example.com',
    documentation => 'DNS domain',
);

has 'key' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return join( '', map { chr( int( rand(94) ) + 33 ) } ( 1 .. 16 ) );
    },
    documentation => 'Secret key',
);

has 'globalStorage' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Apache::Session::File',
    documentation => 'Session backend module',
);

has 'globalStorageOptions' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return { Directory => "/tmp" };
    },
    documentation => 'Session backend module options',
);

has 'portal' => (
    is            => 'rw',
    default       => 'http://auth.example.com',
    documentation => 'Portal URL',
);

no Mouse;

1;
