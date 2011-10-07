#==============================================================================
# Specification file for LemonLDAP::NG
#
# Install LemonLDAP::NG modules, htdocs and scripts
# Authority: dries
# Upstream: Xavier Guimard <x,guimard$free,fr>
#==============================================================================

#==============================================================================
# Variables
#==============================================================================

%define perl_vendorlib %(eval "`%{__perl} -V:installvendorlib`"; echo $installvendorlib)
%define perl_vendorarch %(eval "`%{__perl} -V:installvendorarch`"; echo $installvendorarch)

%define real_name lemonldap-ng
%define real_version 1.2.0
%define cpan_common_version  1.2.0
%define cpan_handler_version 1.2.0
%define cpan_manager_version 1.2.0
%define cpan_portal_version  1.2.0

%define lm_prefix /usr
%define lm_sharedir %{_datadir}/lemonldap-ng
%define lm_examplesdir %{lm_sharedir}/examples
%define lm_vardir %{_localstatedir}/lib/lemonldap-ng
%define lm_confdir %{_sysconfdir}/lemonldap-ng
%define lm_storagefile %{lm_confdir}/lemonldap-ng.ini

# Apache configuration directory
%if 0%{?rhl}%{?rhel}%{?fedora}
%define apache_confdir %{_sysconfdir}/httpd/conf.d
%else
%define apache_confdir /etc/apache2/conf.d
%endif

# Apache User and Group
%if 0%{?rhl}%{?rhel}%{?fedora}
%define lm_apacheuser apache
%define lm_apachegroup apache
%else
%define lm_apacheuser wwwrun                                     
%define lm_apachegroup www
%endif

%define lm_dnsdomain example.com
%define lm_ldaphost localhost
%define lm_ldapport 389
%define lm_ldapsuffix dc=example,dc=com

#==============================================================================
# Main package
#==============================================================================
Name:           %{real_name}
Version:        %{real_version}
Release:        1%{?dist}
Summary:        LemonLDAP-NG WebSSO
Group:          Applications/System
License:        GPL+ or Artistic
URL:            http://lemonldap-ng.org

Source0:        http://lemonldap-ng.org/download/%{name}-%{version}.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch

%if 0%{?rhl}%{?rhel}%{?fedora}
BuildRequires:  perl(Regexp::Assemble)
BuildRequires:  perl(Cache::Cache)
BuildRequires:  perl(Apache::Session)
BuildRequires:  perl(Net::LDAP)
BuildRequires:  perl(CGI::Session)
BuildRequires:  perl(Test::Pod) >= 1.00
BuildRequires:  perl(IO::String)
BuildRequires:  perl(MIME::Lite)
BuildRequires:  perl(SOAP::Lite)
BuildRequires:  perl(XML::Simple)
BuildRequires:  perl(XML::LibXSLT)
BuildRequires:  perl(String::Random)
BuildRequires:  perl(Email::Date::Format)
BuildRequires:  perl(Crypt::Rijndael)
BuildRequires:  perl(HTML::Template)
BuildRequires:  perl(JSON)
BuildRequires:  perl(Config::IniFiles)
BuildRequires:  perl(Crypt::OpenSSL::RSA)
BuildRequires:  perl(Crypt::OpenSSL::X509)
BuildRequires:  perl(Class::Inspector)
BuildRequires:  perl(Test::MockObject)
BuildRequires:  perl(Clone)
%else
# SuSE Linux needs rpm packages for perl scripts                                                                                           
BuildRequires:  perl, perl-Regexp-Assemble, perl-Cache-Cache, perl-Apache-Session, perl-Apache-AuthNetLDAP, perl-XML-Simple, perl-XML-LibXML, perl-Crypt-Rijndael, perl-IO-String, perl-HTML-Template, perl-JSON, perl-Config-IniFiles, perl-Crypt-OpenSSL-RSA, perl-Crypt-OpenSSL-X509, perl-Class-Inspector, perl-Test-MockObject, perl-Clone
%endif

%if 0%{?rhl}%{?rhel}%{?fedora}
Requires: perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires: perl(Apache::Session)
Requires: perl(IO::String)
Requires: mod_perl
%else
Requires: cron, apache2, apache2-mod_perl
Requires: perl >= %(eval "`%{__perl} -V:version`"; echo $version)
Requires: perl-Regexp-Assemble, perl-Cache-Cache, perl-Apache-Session, perl-Apache-AuthNetLDAP, perl-XML-Simple, perl-XML-LibXML, perl-Crypt-Rijndael, perl-IO-String
Requires: perl-ldap, perl-MIME-Base64, perl-CGI, perl-CGI-Session, perl-DBI, perl-HTML-Template, perl-SOAP-Lite, perl-IPC-ShareLite, perl-Convert-ASN1, perl-Error
%endif
Requires: lemonldap-ng-conf >= %{real_version}
Requires: lemonldap-ng-doc >= %{real_version}
Requires: lemonldap-ng-handler >= %{real_version}
Requires: lemonldap-ng-manager >= %{real_version}
Requires: lemonldap-ng-portal >= %{real_version}
Requires: lemonldap-ng-test >= %{real_version}
%if 0%{?rhl}%{?rhel}%{?fedora}
Requires: perl(Lemonldap::NG::Common) >= %{cpan_common_version}
Requires: perl(Lemonldap::NG::Handler) >= %{cpan_handler_version}
Requires: perl(Lemonldap::NG::Manager) >= %{cpan_manager_version}
Requires: perl(Lemonldap::NG::Portal) >= %{cpan_portal_version}
%else
Requires: perl-Lemonldap-NG-Common >= %{cpan_common_version}
Requires: perl-Lemonldap-NG-Handler >= %{cpan_handler_version}
Requires: perl-Lemonldap-NG-Manager >= %{cpan_manager_version}
Requires: perl-Lemonldap-NG-Portal >= %{cpan_portal_version}
%endif

%description
LemonLDAP::NG is a modular Web-SSO based on Apache::Session modules. It
simplifies the build of a protected area with a few changes in the
application. It manages both authentication and authorization and provides
headers for accounting. 
So you can have a full AAA protection for your web space as described below.

#==============================================================================
# Conf
#==============================================================================
%package -n lemonldap-ng-conf
Summary:        LemonLDAP-NG configuration
Group:          Applications/System
Requires(post):  httpd

%description -n lemonldap-ng-conf
This package contains the main storage configuration.

#==============================================================================
# Documentation
#==============================================================================
%package -n lemonldap-ng-doc
Summary:        LemonLDAP-NG documentation
Group:          Applications/System

%description -n lemonldap-ng-doc
This package contains html documentation.

#==============================================================================
# Handler
#==============================================================================
%package -n lemonldap-ng-handler
Summary:        LemonLDAP-NG Handler
Group:          Applications/System

%description -n lemonldap-ng-handler
This package deploys the Apache Handler.

#==============================================================================
# Manager
#==============================================================================
%package -n lemonldap-ng-manager
Summary:        LemonLDAP-NG administration interface
Group:          Applications/System

%description -n lemonldap-ng-manager
This package deploys the adminsitration interface and sessions explorer.

#==============================================================================
# Portal
#==============================================================================
%package -n lemonldap-ng-portal
Summary:        LemonLDAP-NG authentication portal
Group:          Applications/System

%description -n lemonldap-ng-portal
This package deploys the authentication portal.

#==============================================================================
# Test
#==============================================================================
%package -n lemonldap-ng-test
Summary:        LemonLDAP-NG test applications
Group:          Applications/System

%description -n lemonldap-ng-test
This package deploys small test applications.

#==============================================================================
# CPAN modules - Common
#==============================================================================
%package -n perl-Lemonldap-NG-Common
Summary:        LemonLDAP-NG Common Modules
Version:        %{cpan_common_version}
Group:          Applications/System

%description -n perl-Lemonldap-NG-Common
This package installs the configuration libraries used by other LemonLDAP::NG modules.

#==============================================================================
# CPAN modules - Handler
#==============================================================================
%package -n perl-Lemonldap-NG-Handler
Summary:        LemonLDAP-NG Handler Modules
Version:        %{cpan_handler_version}
Group:          Applications/System

%description -n perl-Lemonldap-NG-Handler
This package installs the Apache module part (handler) used to protect web areas.

#==============================================================================
# CPAN modules -  Manager
#==============================================================================
%package -n perl-Lemonldap-NG-Manager
Summary:        LemonLDAP-NG Manager Modules
Version:        %{cpan_manager_version}
Group:          Applications/System

%description -n perl-Lemonldap-NG-Manager
This package installs the administration interface (manager).

#==============================================================================
# CPAN modules - Portal
#==============================================================================
%package -n perl-Lemonldap-NG-Portal
Summary:        LemonLDAP-NG Portal Modules
Version:        %{cpan_portal_version}
Group:          Applications/System

%description -n perl-Lemonldap-NG-Portal
This package installs the authentication portal.

#==============================================================================
# Source preparation
#==============================================================================
%prep
%setup -n %{real_name}-%{real_version} -q

# Remove unwanted provides/requires
# We remove Lemonldap::NG requires because the requires are set in the header
cat << \EOF > %{name}-prov
#!/bin/sh
%{__perl_provides} $* |\
sed -e '/perl(My::.*)/d'
EOF

%define __perl_provides %{_builddir}/%{name}-%{real_version}/%{name}-prov
chmod +x %{__perl_provides}


cat << \EOF > %{name}-req
#!/bin/sh
%{__perl_requires} $* |\
sed -e '/perl(lasso)/d' |\
sed -e '/perl(Net::OpenID::Server)/d' |\
sed -e '/perl(AuthCAS)/d'
EOF

%define __perl_requires %{_builddir}/%{name}-%{real_version}/%{name}-req
chmod +x %{__perl_requires}

#==============================================================================
# Building
#==============================================================================
%build
%{__make} %{?_smp_mflags} configure STORAGECONFFILE=%{lm_storagefile} PERLOPTIONS="INSTALLDIRS=vendor"
%{__make} %{?_smp_mflags}

#==============================================================================
# Installation
#==============================================================================
%install
%if 0%{?rhl}%{?rhel}%{?fedora}
rm -rf %{buildroot}
%endif

# Tests
%{__make} %{?_smp_mflags} test
# Install 
%{__make} %{?_smp_mflags} install \
	DESTDIR=%{buildroot} \
	PREFIX=%{lm_prefix} \
	BINDIR=%{lm_sharedir}/bin \
	DOCUMENTROOT=%{lm_vardir} \
	EXAMPLESDIR=%{lm_examplesdir} \
	HANDLERDIR=%{lm_vardir}/handler \
	PORTALSKINSDIR=%{lm_sharedir}/portal-skins \
	MANAGERSKINSDIR=%{lm_sharedir}/manager-skins \
	STORAGECONFFILE=%{lm_storagefile} \
	TOOLSDIR=%{lm_sharedir}/ressources \
	CONFDIR=%{lm_confdir} \
	CRONDIR=%{_sysconfdir}/cron.d \
	DATADIR=%{lm_vardir} \
	DNSDOMAIN=%{lm_dnsdomain} \
	LDAPHOST=%{lm_ldaphost} \
	LDAPPORT=%{lm_ldapport} \
	LDAPSUFFIX=%{lm_ldapsuffix}

# Remove some unwanted files
find $RPM_BUILD_ROOT -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -name perllocal.pod -exec rm -f {} \;
find $RPM_BUILD_ROOT -name *.bak -exec rm -f {} \;

# Set apache user in some files (see Makefile)
# Note: we do not use the APACHEUSER and APACHEGROUP in make install
# because it launches a 'chown', which is not permitted if RPM is not
# built as root
sed -i 's/nobody/%{lm_apacheuser}/' %{buildroot}%{_sysconfdir}/cron.d/*
sed -i 's/nobody/%{lm_apacheuser}/' %{buildroot}%{lm_sharedir}/bin/lmConfigEditor

# Minify Javascript and CSS
./scripts/minifierjs `find %{buildroot} -name '*.js'`
./scripts/minifiercss `find %{buildroot} -name '*.css'`

# Set UNIX rights
mkdir -p %{buildroot}%{lm_vardir}/sessions/lock
chmod 750 %{buildroot}%{lm_vardir}/conf
chmod 640 %{buildroot}%{lm_vardir}/conf/*
chmod 640 %{buildroot}%{lm_storagefile}
chmod 770 %{buildroot}%{lm_vardir}/sessions
chmod 770 %{buildroot}%{lm_vardir}/sessions/lock

# Touch for ghost
mkdir -p $RPM_BUILD_ROOT%{apache_confdir}
touch $RPM_BUILD_ROOT%{apache_confdir}/z-lemonldap-ng-handler.conf
touch $RPM_BUILD_ROOT%{apache_confdir}/z-lemonldap-ng-manager.conf
touch $RPM_BUILD_ROOT%{apache_confdir}/z-lemonldap-ng-portal.conf

#==============================================================================
# Post Installation
#==============================================================================
%post -n lemonldap-ng-conf
# Create symlink in Apache configuration
# We use "z-lemonldap-ng-*" so that Apache read the files after "perl.conf"
if [ ! -e %{apache_confdir}/z-lemonldap-ng-handler.conf ] ; then
	ln -s %{lm_confdir}/handler-apache2.conf %{apache_confdir}/z-lemonldap-ng-handler.conf || :
fi
if [ ! -e %{apache_confdir}/z-lemonldap-ng-manager.conf ] ; then
	ln -s %{lm_confdir}/manager-apache2.conf %{apache_confdir}/z-lemonldap-ng-manager.conf || :
fi
if [ ! -e %{apache_confdir}/z-lemonldap-ng-portal.conf ] ; then
	ln -s %{lm_confdir}/portal-apache2.conf %{apache_confdir}/z-lemonldap-ng-portal.conf || :
fi
# Upgrade from previous version
# See http://lemonldap-ng.org/documentation/1.0/upgrade
if [ $1 -gt 1 ] ; then
	if [ -e %{lm_confdir}/storage.conf -o -e %{lm_confdir}/apply.conf -o -e %{lm_confdir}/apps-list.xml ] ; then
		# Run migration script
		%{lm_sharedir}/bin/lmMigrateConfFiles2ini 2>&1 > /dev/null || :
		# Fix ownership
		chgrp %{lm_apachegroup} %{lm_storagefile} || :
	fi
fi

#==============================================================================
# Pre uninstallation
#==============================================================================
%preun -n lemonldap-ng-conf
# Package removal
if [ $1 -eq 0 ] ; then
	# Remove symlink in Apache configuration
	rm -f %{apache_confdir}/z-lemonldap-ng-handler.conf 2>&1 > /dev/null || :
	rm -f %{apache_confdir}/z-lemonldap-ng-manager.conf 2>&1 > /dev/null || :
	rm -f %{apache_confdir}/z-lemonldap-ng-portal.conf 2>&1 > /dev/null  || :
fi
# Upgrade from previous version
if [ $1 -eq 1 ] ; then
	# Remove old symlink in Apache configuration
	rm -f %{apache_confdir}/z-lemonldap-ng.conf 2&>1 >/dev/null || :
fi

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%doc changelog COPYING INSTALL README

%files -n lemonldap-ng-conf
%defattr(-,root,root,-)
%dir %{lm_confdir}
%config %{lm_confdir}/for_etc_hosts
%config(noreplace) %{lm_confdir}/handler-apache2.conf
%config(noreplace) %{lm_confdir}/manager-apache2.conf
%config(noreplace) %{lm_confdir}/portal-apache2.conf
%ghost %{apache_confdir}/z-lemonldap-ng-handler.conf
%ghost %{apache_confdir}/z-lemonldap-ng-manager.conf
%ghost %{apache_confdir}/z-lemonldap-ng-portal.conf
%dir %{lm_vardir}
%dir %{lm_sharedir}
%dir %{lm_sharedir}/bin
%{lm_sharedir}/bin/convertConfig
%{lm_sharedir}/bin/lmMigrateConfFiles2ini
%dir %{lm_examplesdir}
%dir %{lm_sharedir}/ressources
%{lm_sharedir}/ressources/*
%defattr(-,root,%{lm_apachegroup},-)
%config(noreplace) %{lm_storagefile}
%defattr(750,%{lm_apacheuser},%{lm_apachegroup},-)
%dir %{lm_vardir}/conf
%dir %{lm_vardir}/sessions
%dir %{lm_vardir}/sessions/lock
%defattr(640,%{lm_apacheuser},%{lm_apachegroup},-)
%config(noreplace) %{lm_vardir}/conf/lmConf-1

%files -n lemonldap-ng-doc
%defattr(-,root,root,-)
%doc %{lm_vardir}/doc
%doc changelog COPYING INSTALL README

%files -n lemonldap-ng-handler
%defattr(-,root,root,-)
%{lm_sharedir}/bin/purgeLocalCache
%{_sysconfdir}/cron.d/lemonldap-ng-handler
%{lm_vardir}/handler
%{lm_examplesdir}/handler

%files -n lemonldap-ng-manager
%defattr(-,root,root,-)
%{lm_vardir}/manager
%{lm_sharedir}/bin/lmConfigEditor
%{lm_sharedir}/manager-skins
%{lm_examplesdir}/manager

%files -n lemonldap-ng-portal
%defattr(-,root,root,-)
%{lm_vardir}/portal
%{lm_sharedir}/bin/buildPortalWSDL
%{lm_sharedir}/bin/purgeCentralCache
%{_sysconfdir}/cron.d/lemonldap-ng-portal
%{lm_examplesdir}/portal
%{lm_sharedir}/portal-skins

%files -n lemonldap-ng-test
%defattr(-,root,root,-)
%{lm_vardir}/test

%files -n perl-Lemonldap-NG-Common
%defattr(-,root,root,-)
%doc %{_mandir}/man3/Lemonldap::NG::Common*.3pm.gz
%{perl_vendorlib}/Lemonldap/NG/Common.pm
%{perl_vendorlib}/Lemonldap/NG/Common/
%{perl_vendorlib}/auto/Lemonldap/NG/Common/

%files -n perl-Lemonldap-NG-Handler
%defattr(-,root,root,-)
%doc %{_mandir}/man3/Lemonldap::NG::Handler*.3pm.gz
%{perl_vendorlib}/Lemonldap/NG/Handler.pm
%{perl_vendorlib}/Lemonldap/NG/Handler/
%{perl_vendorlib}/auto/Lemonldap/NG/Handler/

%files -n perl-Lemonldap-NG-Manager
%defattr(-,root,root,-)
%doc %{_mandir}/man3/Lemonldap::NG::Manager*.3pm.gz
%{perl_vendorlib}/Lemonldap/NG/Manager.pm
%{perl_vendorlib}/Lemonldap/NG/Manager/
%{perl_vendorlib}/auto/Lemonldap/NG/Manager/

%files -n perl-Lemonldap-NG-Portal
%defattr(-,root,root,-)
%doc %{_mandir}/man3/Lemonldap::NG::Portal*.3pm.gz
%{perl_vendorlib}/Lemonldap/NG/Portal.pm
%{perl_vendorlib}/Lemonldap/NG/Portal/
%{perl_vendorlib}/auto/Lemonldap/NG/Portal/

#==============================================================================
# Changelog
#==============================================================================
%changelog
* Fri Oct 07 2011 Clement Oudot <clem.oudot@gmail.com> - 1.2.0-1
- Update to 1.2.0
* Fri Oct 07 2011 Clement Oudot <clem.oudot@gmail.com> - 1.1.2-1
- Update to 1.1.2
* Fri Jul 29 2011 Clement Oudot <clem.oudot@gmail.com> - 1.1.1-1
- Update to 1.1.1
* Fri Jul 08 2011 Clement Oudot <clem.oudot@gmail.com> - 1.1.0-1
- Update to 1.1.0
* Mon Jun 30 2011 Clement Oudot <clem.oudot@gmail.com> - 1.0.6-1
- Update to 1.0.6
* Fri Apr 15 2011 Clement Oudot <clem.oudot@gmail.com> - 1.0.5-1
- Update to 1.0.5
* Tue Mar 22 2011 Clement Oudot <clem.oudot@gmail.com> - 1.0.4-1
- Update to 1.0.4
* Mon Mar 07 2011 Clement Oudot <clem.oudot@gmail.com> - 1.0.3-1
- Update to 1.0.3
* Mon Feb 28 2011 Clement Oudot <clem.oudot@gmail.com> - 1.0.2-1
- Update to 1.0.2
* Thu Dec 16 2010 Clement Oudot <clem.oudot@gmail.com> - 1.0.1-1
- Update to 1.0.1
* Fri Nov 26 2010 Clement Oudot <clem.oudot@gmail.com> - 1.0-1
- Update to 1.0
* Wed Jul 21 2010 Nicolas Chauvet <kwizart@gmail.com> - 0.9.4.1-3
- Fix compatibility with perl-LDAP 0.40
- Add BR perl(Auth::CAS)
* Mon Jul 12 2010 Nicolas Chauvet <nchauvet@linagora.com> - 0.9.4.1-2
- Protect lemonldap directories against word readability
* Mon Oct 12 2009 Nicolas Chauvet <nchauvet@linagora.com> - 0.9.4.1-1
- Update to 0.9.4.1
* Thu Sep 24 2009 Nicolas Chauvet <nchauvet@linagora.com> - 0.9.4-2
- Add Missing BuildRequires
- Remove filter for dependencies available in EPEL.
- use %%defattr to define ownership.
* Mon Jul 6 2009 Clement Oudot <coudot@linagora.com> - 0.9.4-1
- Upgrade to release 0.9.4
- Remove cronjob patch (included in 0.9.4)
- Split scriplets into subpackages
- Use conditions to build for other RPM distributions like OpenSuSE (thanks to clauded1)
* Mon Jan 12 2009 Clement Oudot <coudot@linagora.com> - 0.9.3.2-2
- Include cronjob patch
- Delete unwanted files (perllocal.pod, .packlist)
- Follow rpmfusion guidelines
* Thu Jan 9 2009 Clement Oudot <coudot@linagora.com> - 0.9.3.2-1
- Updated to release 0.9.3.2.
- Use internal version number for perl modules (compatibility with RPMforge packages)
- Merge with existing .spec file from RPMforge.
- Use the same directories as the Debian package.
- Create a symlink in Apache confguration.
- Create specific portal/manager/handler/conf packages independant from CPAN packages
* Thu Nov 20 2008 Jean-Christophe Toussaint <jean-christophe.toussaint@ac-nancy-metz.fr> - 0.9.2-1DSI
- Updated to release 0.9.2.
- Using official tar.gz from forge.
* Tue Oct 7 2008 David Hannequin <david.hannequin@linagora.com> 
- New spec file
* Sun Mar 02 2008 Dag Wieers <dag@wieers.com> - 0.85-1
- Updated to release 0.85.
* Tue Nov 13 2007 Dag Wieers <dag@wieers.com> - 0.84-1
- Updated to release 0.84.
* Wed May 02 2007 Dries Verachtert <dries@ulyssis.org> - 0.81-1
- Updated to release 0.81.
* Sun Apr 29 2007 Dries Verachtert <dries@ulyssis.org> - 0.75-1
- Initial package.
