use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Lemonldap::NG::Manager',
    VERSION_FROM => 'lib/Lemonldap/NG/Manager.pm',    # finds $VERSION
    PREREQ_PM    => {
        'CGI'                    => 3.08,
        'XML::Simple'            => 0,
        'LWP::UserAgent'         => 0,
        'Lemonldap::NG::Common'  => 0.9,
        'Lemonldap::NG::Handler' => 0.9,
    },    # e.g., Module::Name => 1.1
    (
        $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
          (
            ABSTRACT_FROM =>
              'lib/Lemonldap/NG/Manager.pm',    # retrieve abstract from module
            AUTHOR => 'Xavier Guimard <x.guimard@free.fr>'
          )
        : ()
    ),
);
