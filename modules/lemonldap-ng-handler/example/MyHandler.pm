package My::Package;
use Lemonldap::NG::Handler::SharedConf::File;
@ISA = qw(Lemonldap::NG::Handler::SharedConf::File);

__PACKAGE__->init ( {
    localStorage        => "Cache::FileCache",
    localStorageOptions => {
              'namespace'          => 'MyNamespace',
              'default_expires_in' => 600,
    },

    configStorage       => {
              type                 => 'File',
              dirName              => '__DIR__',
    },

    https               => 0,
} );

