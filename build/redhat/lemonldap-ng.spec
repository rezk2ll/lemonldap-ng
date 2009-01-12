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
%define real_version 0.9.3.2

%define lm_prefix /usr
%define lm_sharedir /usr/share/lemonldap-ng
%define lm_examplesdir %{lm_sharedir}/examples
%define lm_vardir /var/lib/lemonldap-ng
%define lm_confdir /etc/lemonldap-ng
%define lm_storagefile %{lm_confdir}/storage.conf

%define lm_apacheuser apache
%define lm_apachegroup apache

%define lm_dnsdomain example.com
%define lm_ldaphost localhost
%define lm_ldapport 389
%define lm_ldapsuffix dc=example,dc=com

#==============================================================================
# Main package
#==============================================================================
Name:           %{real_name}
Version:        %{real_version}
Release:        2%{?dist}
Summary:        LemonLDAP-NG WebSSO
Group:          Applications/System
License:        GPL+ or Artistic
URL:            http://lemonldap.ow2.org 

Source0:        http://download.forge.objectweb.org/lemonldap/%{name}-%{version}.tar.gz
# http://forge.objectweb.org/tracker/index.php?func=detail&aid=312315&group_id=274&atid=350403
Patch0:         lemonldap-ng-cronjob-0.9.3.2.patch

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  perl, perl(Regexp::Assemble), perl(Cache::Cache), perl(Apache::Session), perl(Net::LDAP)

Requires: perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires: perl(Apache::Session), mod_perl
Requires: lemonldap-ng-conf >= %{real_version}
Requires: lemonldap-ng-doc >= %{real_version}
Requires: lemonldap-ng-handler >= %{real_version}
Requires: lemonldap-ng-manager >= %{real_version}
Requires: lemonldap-ng-portal >= %{real_version}
Requires: lemonldap-ng-test >= %{real_version}

%description
LemonLDAP::NG is a modular Web-SSO based on Apache::Session modules. It simplifies the build of a protected area with a few changes in the application. It manages both authentication and authorization and provides headers for accounting. So you can have a full AAA protection for your web space as described below.

#==============================================================================
# Conf
#==============================================================================
%package -n lemonldap-ng-conf
Summary:        LemonLDAP-NG configuration
Group:          Applications/System

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
Version:        0.91
Group:          Applications/System

%description -n perl-Lemonldap-NG-Common
This package installs the configuration libraries used by other LemonLDAP::NG modules.

#==============================================================================
# CPAN modules - Handler
#==============================================================================
%package -n perl-Lemonldap-NG-Handler
Summary:        LemonLDAP-NG Handler Modules
Version:        0.90
Group:          Applications/System

%description -n perl-Lemonldap-NG-Handler
This package installs the Apache module part (handler) used to protect web areas.

#==============================================================================
# CPAN modules -  Manager
#==============================================================================
%package -n perl-Lemonldap-NG-Manager
Summary:        LemonLDAP-NG Manager Modules
Version:        0.87
Group:          Applications/System

%description -n perl-Lemonldap-NG-Manager
This package installs the administration interface (manager).

#==============================================================================
# CPAN modules - Portal
#==============================================================================
%package -n perl-Lemonldap-NG-Portal
Summary:        LemonLDAP-NG Portal Modules
Version:        0.86
Group:          Applications/System

%description -n perl-Lemonldap-NG-Portal
This package installs the authentication portal.

#==============================================================================
# Source preparation
#==============================================================================
%prep
%setup -n %{real_name}-%{real_version} -q
%patch0 -p0

# Remove unwanted provides/requires
# We remove Lemonldap::NG requires because the requires are set in the header
cat << \EOF > %{name}-prov
#!/bin/sh
%{__perl_provides} $* |\
sed -e '/perl(My::Package)/d'
EOF

%define __perl_provides %{_builddir}/%{name}-%{real_version}/%{name}-prov
chmod +x %{__perl_provides}


cat << \EOF > %{name}-req
#!/bin/sh
%{__perl_requires} $* |\
sed -e '/perl(lasso)/d' |\
sed -e '/perl(SOAP::Lite)/d' |\
sed -e '/perl(SOAP::Transport::HTTP)/d' |\
sed -e '/perl(Log::Log4perl)/d' |\
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
rm -rf %{buildroot}
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
	MANAGERDATADIR=%{lm_sharedir}/manager-imgs \
	SESSIONSEXPLORERDATADIR=%{lm_sharedir}/sessions-explorer-imgs \
	STORAGECONFFILE=%{lm_storagefile} \
	TOOLSDIR=%{lm_sharedir}/ressources \
	CONFDIR=%{lm_confdir} \
	CRONDIR=/etc/cron.d \
	DATADIR=%{lm_vardir} \
	DNSDOMAIN=%{lm_dnsdomain} \
	LDAPHOST=%{lm_ldaphost} \
	LDAPPORT=%{lm_ldapport} \
	LDAPSUFFIX=%{lm_ldapsuffix}

# Remove some unwanted files
find $RPM_BUILD_ROOT -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -name perllocal.pod -exec rm -f {} \;

#==============================================================================
# Post Installation
#==============================================================================
%post
# Set UNIX rights
chown -R %{lm_apacheuser}:%{lm_apachegroup} %{lm_vardir}/conf
chmod 750 %{lm_vardir}/conf
chmod 640 %{lm_vardir}/conf/*
chgrp %{lm_apachegroup} %{lm_storagefile}
chmod 640 %{lm_storagefile}
chown -R %{lm_apacheuser}:%{lm_apachegroup} %{lm_vardir}/sessions
chmod 770 %{lm_vardir}/sessions
chmod 770 %{lm_vardir}/sessions/lock
chgrp %{lm_apachegroup} %{lm_confdir}/apply.conf
chmod 640 %{lm_confdir}/apply.conf

# Create symlink in Apache configuration
# We use "z-lemonldap-ng" so that Apache read the file after "perl.conf"
ln -s %{lm_confdir}/apache2.conf /etc/httpd/conf.d/z-lemonldap-ng.conf

echo "LemonLDAP::NG installation success - please restart Apache"

#==============================================================================
# Pre uninstallation
#==============================================================================
%preun
# Remove symlink in Apache configuration
rm -f /etc/httpd/conf.d/z-lemonldap-ng.conf

echo "LemonLDAP::NG uninstallation success - please restart Apache"

#==============================================================================
# Cleaning
#==============================================================================
%clean
rm -rf %{buildroot}

#==============================================================================
# Files
#==============================================================================
%files
%defattr(-,root,root,-)

%files -n lemonldap-ng-conf
%config %{lm_confdir}
%config %{lm_vardir}/conf
%{lm_vardir}/sessions
%{lm_sharedir}/ressources

%files -n lemonldap-ng-doc
%doc %{lm_vardir}/doc
%doc changelog COPYING INSTALL README

%files -n lemonldap-ng-handler
%{lm_vardir}/handler
%{lm_examplesdir}/handler

%files -n lemonldap-ng-manager
%{lm_vardir}/manager
%{lm_sharedir}/bin/lmConfigEditor
%{lm_sharedir}/bin/lmConfig_File2MySQL
%{lm_sharedir}/manager-imgs
%{lm_sharedir}/sessions-explorer-imgs
%{lm_examplesdir}/manager

%files -n lemonldap-ng-portal
%{lm_vardir}/liberty-alliance-sp-portal
%{lm_vardir}/portal
%{lm_sharedir}/bin/purgeCentralCache
/etc/cron.d/lemonldap-ng
%{lm_examplesdir}/portal
%{lm_sharedir}/portal-skins

%files -n lemonldap-ng-test
%{lm_vardir}/test

%files -n perl-Lemonldap-NG-Common
%doc %{_mandir}/man3/Lemonldap::NG::Common*.3pm.gz
%{perl_vendorlib}/Lemonldap/NG/Common.pm
%{perl_vendorlib}/Lemonldap/NG/Common/

%files -n perl-Lemonldap-NG-Handler
%doc %{_mandir}/man3/Lemonldap::NG::Handler*.3pm.gz
%{perl_vendorlib}/Lemonldap/NG/Handler.pm
%{perl_vendorlib}/Lemonldap/NG/Handler/

%files -n perl-Lemonldap-NG-Manager
%doc %{_mandir}/man3/Lemonldap::NG::Manager*.3pm.gz
%{perl_vendorlib}/Lemonldap/NG/Manager.pm
%{perl_vendorlib}/Lemonldap/NG/Manager/
%{perl_vendorlib}/auto/Lemonldap/NG/Manager/

%files -n perl-Lemonldap-NG-Portal
%doc %{_mandir}/man3/Lemonldap::NG::Portal*.3pm.gz
%{perl_vendorlib}/Lemonldap/NG/Portal.pm
%{perl_vendorlib}/Lemonldap/NG/Portal/
%{perl_vendorlib}/auto/Lemonldap/NG/Portal/

#==============================================================================
# Changelog
#==============================================================================
%changelog
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
