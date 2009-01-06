#==============================================================================
# Specification file for LemonLDAP::NG
#
# Install LemonLDAP::NG modules, htdocs and scripts
#==============================================================================

#==============================================================================
# Variables
#==============================================================================
%define perl_vendorlib %(eval "`%{__perl} -V:installvendorlib`"; echo $installvendorlib)
%define perl_vendorarch %(eval "`%{__perl} -V:installvendorarch`"; echo $installvendorarch)

%define real_name lemonldap-ng

%define lm_prefix /usr
%define lm_examplesdir /usr/share/doc/lemonldap-ng/examples
%define lm_sharedir /usr/share/lemonldap-ng
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
Version:        0.9.3.2
Release:        el5.ow2
# Force Epoch to 1 to allow update of old RPMforge packages
Epoch:		1
Summary:        LemonLDAP-NG WebSSO

Group:          Applications/System
License:        Artistic/GPL
URL:            http://lemonldap.ow2.org 
Source0:        http://download.forge.objectweb.org/lemonldap/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root

Packager:	Clement Oudot
Vendor:		OW2

BuildArch:      noarch
BuildRequires:  perl

Requires: perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires: perl(Apache::Session), mod_perl

%description
LemonLDAP::NG is a modular Web-SSO based on Apache::Session modules. It simplifies the build of a protected area with a few changes in the application. It manages both authentication and authorization and provides headers for accounting. So you can have a full AAA protection for your web space as described below.

#==============================================================================
# Documentation
#==============================================================================
%package -n lemonldap-ng-doc
Summary:        LemonLDAP-NG documentation
Group:          Applications/System

%description -n lemonldap-ng-doc
This package contains html documentation.

#==============================================================================
# Conf (Common)
#==============================================================================
%package -n perl-Lemonldap-NG-Conf
Summary:        LemonLDAP-NG Common Modules
Group:          Applications/System

%description -n perl-Lemonldap-NG-Conf
This package installs the configuration libraries used by other LemonLDAP::NG modules.

#==============================================================================
# Handler
#==============================================================================
%package -n perl-Lemonldap-NG-Handler
Summary:        LemonLDAP-NG Handler Modules
Group:          Applications/System

%description -n perl-Lemonldap-NG-Handler
This package installs the Apache module part (handler) used to protect web areas.

#==============================================================================
# Manager
#==============================================================================
%package -n perl-Lemonldap-NG-Manager
Summary:        LemonLDAP-NG Manager Modules
Group:          Applications/System

%description -n perl-Lemonldap-NG-Manager
This package installs the administration interface (manager).

#==============================================================================
# Portal
#==============================================================================
%package -n perl-Lemonldap-NG-Portal
Summary:        LemonLDAP-NG Portal Modules
Group:          Applications/System

%description -n perl-Lemonldap-NG-Portal
This package installs the authentication portal.

#=================================================
# Source preparation
#=================================================
%prep
%setup -q

# Remove unwanted provides/requires
cat << \EOF > %{name}-prov
#!/bin/sh
%{__perl_provides} $* |\
sed -e '/perl(My::Package)/d'
EOF

%define __perl_provides %{_builddir}/%{name}-%{version}/%{name}-prov
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

%define __perl_requires %{_builddir}/%{name}-%{version}/%{name}-req
chmod +x %{__perl_requires}

#=================================================
# Building
#=================================================
%build
%{__make} %{?_smp_mflags} configure STORAGECONFFILE=%{lm_storagefile} PERLOPTIONS="INSTALLDIRS=vendor"
%{__make} %{?_smp_mflags}

#=================================================
# Installation
#=================================================
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
	APACHEUSER=%{lm_apacheuser} \
	APACHEGROUP=%{lm_apachegroup} \
	DNSDOMAIN=%{lm_dnsdomain} \
	LDAPHOST=%{lm_ldaphost} \
	LDAPPORT=%{lm_ldapport} \
	LDAPSUFFIX=%{lm_ldapsuffix}

#=================================================
# Post Installation
#=================================================
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

#=================================================
# Pre uninstallation
#=================================================
%preun
# Remove symlink in Apache configuration
rm -f /etc/httpd/conf.d/z-lemonldap-ng.conf

echo "LemonLDAP::NG uninstallation success - please restart Apache"

#=================================================
# Cleaning
#=================================================
%clean
rm -rf %{buildroot}

#=================================================
# Files
#=================================================
%files
%defattr(-,root,root,-)
%config %{lm_confdir}
%config %{lm_vardir}/conf
%doc %{lm_examplesdir}
%{lm_sharedir}
%{lm_vardir}
%exclude %{lm_vardir}/doc
/etc/cron.d/purgeCentralCache.cron.d
/usr/lib/perl5/5.8.8/i386-linux-thread-multi/perllocal.pod

%files -n lemonldap-ng-doc
%doc %{lm_vardir}/doc

%files -n perl-Lemonldap-NG-Conf
%doc %{_mandir}/man3/Lemonldap::NG::Common*.3pm.gz
%{perl_vendorlib}/Lemonldap/NG/Common.pm
%{perl_vendorlib}/Lemonldap/NG/Common/
%{perl_vendorlib}/i386-linux-thread-multi/auto/Lemonldap/NG/Common/

%files -n perl-Lemonldap-NG-Handler
%doc %{_mandir}/man3/Lemonldap::NG::Handler*.3pm.gz
%{perl_vendorlib}/Lemonldap/NG/Handler.pm
%{perl_vendorlib}/Lemonldap/NG/Handler/
%{perl_vendorlib}/i386-linux-thread-multi/auto/Lemonldap/NG/Handler/

%files -n perl-Lemonldap-NG-Manager
%doc %{_mandir}/man3/Lemonldap::NG::Manager*.3pm.gz
%{perl_vendorlib}/Lemonldap/NG/Manager.pm
%{perl_vendorlib}/Lemonldap/NG/Manager/
%{perl_vendorlib}/i386-linux-thread-multi/auto/Lemonldap/NG/Manager/
%{perl_vendorlib}/auto/Lemonldap/NG/Manager/

%files -n perl-Lemonldap-NG-Portal
%doc %{_mandir}/man3/Lemonldap::NG::Portal*.3pm.gz
%{perl_vendorlib}/Lemonldap/NG/Portal.pm
%{perl_vendorlib}/Lemonldap/NG/Portal/
%{perl_vendorlib}/i386-linux-thread-multi/auto/Lemonldap/NG/Portal/
%{perl_vendorlib}/auto/Lemonldap/NG/Portal/

#=================================================
# Changelog
#=================================================
%changelog
* Mon Jan 5 2009 Clement Oudot <coudot@linagora.com> - 0.9.3.2-el5.ow2
- Updated to release 0.9.3.2.
- Merge with existing .spec file from RPMforge.
- Use the same directories as the Debian package.
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
