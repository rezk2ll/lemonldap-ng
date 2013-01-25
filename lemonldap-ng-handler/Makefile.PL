use 5.008;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME           => 'Lemonldap::NG::Handler',
    VERSION_FROM   => 'lib/Lemonldap/NG/Handler.pm',
    LICENSE        => 'perl',
    PMLIBDIRS      => ['lib'],
    BUILD_REQUIRES => { 'IO::Pipe' => 0, 'Test::MockObject' => 0 },
    PREREQ_PM      => {
        'LWP::UserAgent'                 => 0,
        'Cache::Cache'                   => 0,
        'Lemonldap::NG::Common'          => '1.3.0',
        'CGI'                            => 3.08,
        'URI'                            => 0,
        'Test::Pod'                      => 1.00,
        'SOAP::Lite'                     => 0,
        'Cache::Memcached'               => 0,
        'Digest::HMAC_SHA1'              => 0,
        'Apache::Session::Generate::MD5' => 0,
    },    # e.g., Module::Name => 1.1
    (
        $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
          (
            ABSTRACT_FROM =>
              'lib/Lemonldap/NG/Handler.pm',    # retrieve abstract from module
            AUTHOR => 'Xavier Guimard <x.guimard@free.fr>'
          )
        : ()
    ),
);
