use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Lemonldap::NG::Manager',
    VERSION_FROM      => 'lib/Lemonldap/NG/Manager.pm', # finds $VERSION
    PREREQ_PM         => {
    		DBI         => 0,
		CGI         => 3.08,
		Storable    => 0,
		XML::Simple => 0
    		}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Lemonldap/NG/Manager.pm', # retrieve abstract from module
       AUTHOR         => 'Najette <najette@>') : ()),
);
