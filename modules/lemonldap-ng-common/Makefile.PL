use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Lemonldap::NG::Common',
    VERSION_FROM      => 'lib/Lemonldap/NG/Common.pm', # finds $VERSION
    PREREQ_PM         => {
        'DBI'            => 0,
        'Storable'       => 0,
        }, # e.g., Module::Name => 1.1
    EXE_FILES         => [
        'scripts/lmConfig_File2MySQL',
        ],
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Lemonldap/NG/Common.pm', # retrieve abstract from module
       AUTHOR         => 'guimard <guimard@>') : ()),
);
