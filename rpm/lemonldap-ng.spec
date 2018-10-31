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
%global real_version 2.0.0
%global cpan_version 2.0.0
%global cpan_common_version  %{cpan_version}
%global cpan_handler_version %{cpan_version}
%global cpan_manager_version %{cpan_version}
%global cpan_portal_version  %{cpan_version}

%global lm_prefix %{_prefix}
%global lm_sharedir %{_datadir}/lemonldap-ng
%global lm_examplesdir %{lm_sharedir}/examples
%global lm_vardir %{_localstatedir}/lib/lemonldap-ng
%global lm_confdir %{_sysconfdir}/lemonldap-ng
%global lm_storagefile %{lm_confdir}/lemonldap-ng.ini

# Apache configuration directory
%if 0%{?rhel}%{?fedora}
%global apache_confdir %{_sysconfdir}/httpd/conf.d
%else
%global apache_confdir %{_sysconfdir}/apache2/conf.d
%endif

# Apache User and Group
%if 0%{?rhel}%{?fedora}
%global lm_apacheuser apache
%global lm_apachegroup apache
%else
%global lm_apacheuser wwwrun
%global lm_apachegroup www
%endif

# Apache version
%if 0%{?rhel} >= 7
%global apache_version 2.4
%else
%global apache_version 2
%endif

%global lm_dnsdomain example.com

#==============================================================================
# Main package
#==============================================================================
Name:           lemonldap-ng
Version:        %{real_version}
Release:        1%{?dist}
Summary:        LemonLDAP-NG WebSSO
License:        GPLv2+
URL:            http://lemonldap-ng.org
Source0:        https://release.ow2.org/lemonldap/%{name}-%{version}.tar.gz
BuildArch:      noarch

BuildRequires:  perl(Apache::Session)
BuildRequires:  perl(Authen::Captcha)
BuildRequires:  perl(Cache::Cache)
BuildRequires:  perl(Class::Inspector)
BuildRequires:  perl(Clone)
BuildRequires:  perl(Config::IniFiles)
BuildRequires:  perl(Convert::Base32)
BuildRequires:  perl(Convert::PEM)
BuildRequires:  perl(Crypt::OpenSSL::Bignum)
BuildRequires:  perl(Crypt::OpenSSL::RSA)
BuildRequires:  perl(Crypt::OpenSSL::X509)
BuildRequires:  perl(Crypt::Rijndael)
BuildRequires:  perl(Digest::SHA)
BuildRequires:  perl(Email::Date::Format)
BuildRequires:  perl(Email::Sender)
BuildRequires:  perl(Env)
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildRequires:  perl(HTML::Template)
BuildRequires:  perl(IO::String)
BuildRequires:  perl(JSON)
BuildRequires:  perl(MIME::Entity)
BuildRequires:  perl(Mouse)
BuildRequires:  perl(Net::LDAP)
BuildRequires:  perl(Plack)
BuildRequires:  perl(Regexp::Assemble)
BuildRequires:  perl(Regexp::Common)
# https://bugzilla.redhat.com/show_bug.cgi?id=1644266
#BuildRequires:  perl(Sentry::Raven)
BuildRequires:  perl(SOAP::Lite)
BuildRequires:  perl(String::Random)
BuildRequires:  perl(Test::MockObject)
BuildRequires:  perl(Test::Pod) >= 1.00
BuildRequires:  perl(Unicode::String)
BuildRequires:  perl(XML::LibXSLT)
BuildRequires:  perl(XML::Simple)
BuildRequires:  systemd

Requires: lemonldap-ng-conf = %{real_version}-%{release}
Requires: lemonldap-ng-doc = %{real_version}-%{release}
Requires: lemonldap-ng-handler = %{real_version}-%{release}
Requires: lemonldap-ng-manager = %{real_version}-%{release}
Requires: lemonldap-ng-portal = %{real_version}-%{release}
Requires: lemonldap-ng-test = %{real_version}-%{release}

# Setup requires filtering
%if 0%{?rhel} == 6
%filter_from_requires /perl(lasso/d; /perl(Net::OpenID/d; /perl(Web::ID/d; /perl(XML::LibXML/d; /perl(XML::LibXSLT/d; /perl(Convert::Base32/d; /perl(Sentry::Raven/d;
%filter_setup
%endif

%if 0%{?fedora} || 0%{?rhel} >= 7
%{?perl_default_filter}
%global __requires_exclude perl\\(lasso|perl\\(Net::OpenID|perl\\(Web::ID|perl\\(XML::LibXML|perl\\(XML::LibXSLT|perl\\(Convert::Base32|perl\\(Sentry::Raven
%endif


%description
LemonLdap::NG is a modular Web-SSO based on Apache::Session modules. It
simplifies the build of a protected area with a few changes in the
application. It manages both authentication and authorization and provides
headers for accounting. 
So you can have a full AAA protection for your web space as described below.

#==============================================================================
# Conf
#==============================================================================
%package conf
Summary:        LemonLDAP-NG configuration
Requires:       perl(Apache::Session)
Requires:       perl(IO::String)
Requires:       perl(Lemonldap::NG::Common) = %{cpan_common_version}
Requires:       perl(mod_perl2)
%if 0%{?rhel}%{?fedora}
Requires(post):  httpd
%else
Requires(post):  apache2
%endif

#==============================================================================
# Configuration
#==============================================================================
%description conf
This package contains the main storage configuration.
Requires:       perl(Apache::Session)
Requires:       perl(IO::String)
Requires:       perl(Lemonldap::NG::Common) = %{cpan_common_version}
Requires:       perl(mod_perl2)
%if 0%{?rhel}%{?fedora}
Requires(post):  httpd
%else
Requires(post):  apache2
%endif

#==============================================================================
# Documentation
#==============================================================================
%package doc
Summary:        LemonLDAP-NG documentation
Requires:       lemonldap-ng-conf = %{real_version}-%{release}

%description doc
This package contains html documentation.

#==============================================================================
# Handler
#==============================================================================
%package handler
Summary:        LemonLDAP-NG handler
%if 0%{?rhel}%{?fedora}
Requires:       crontabs
%endif
Requires:       lemonldap-ng-conf = %{real_version}-%{release}
Requires:       perl(Lemonldap::NG::Handler) = %{cpan_handler_version}

%description handler
This package deploys the Apache Handler.

#==============================================================================
# Manager
#==============================================================================
%package manager
Summary:        LemonLDAP-NG administration interface
Requires:       lemonldap-ng-conf = %{real_version}-%{release}
Requires:       perl(Lemonldap::NG::Manager) = %{cpan_manager_version}

%description manager
This package deploys the administration interface and sessions explorer.

#==============================================================================
# Portal
#==============================================================================
%package portal
Summary:        LemonLDAP-NG authentication portal
%if 0%{?rhel}%{?fedora}
Requires:       crontabs
%endif
Requires:       lemonldap-ng-conf = %{real_version}-%{release}
Requires:       perl(Lemonldap::NG::Portal) = %{cpan_portal_version}

%description portal
This package deploys the authentication portal.

#==============================================================================
# Test
#==============================================================================
%package test
Summary:        LemonLDAP-NG test applications
Requires:       lemonldap-ng-conf = %{real_version}-%{release}

%description test
This package deploys small test applications.

#==============================================================================
# FastCGI Server
#==============================================================================
%package fastcgi-server
Summary:        LemonLDAP-NG FastCGI Server
Requires:       lemonldap-ng-conf = %{real_version}-%{release}
%if 0%{?rhel}%{?fedora}
Requires:       mod_fcgid
%else
Requires:       apache2-mod_fcgid
%endif
Requires:       perl(FCGI::ProcManager)

%description fastcgi-server
This package deploys files needed to start a FastCGI server.

#==============================================================================
# UWSGI Application
#==============================================================================
%package uwsgi-app
Summary:        LemonLDAP-NG UWSGI Application
Requires:       uwsgi-plugin-psgi

%description uwsgi-app
LemonLDAP::NG uWSGI server provides a replacement to LemonLDAP::NG FastCGI
server, using uWSGI instead of Plack FCGI.

#==============================================================================
# CPAN modules - Common
#==============================================================================
%package -n perl-Lemonldap-NG-Common
Summary:        LemonLDAP-NG Common Modules
Version:        %{cpan_common_version}

%description -n perl-Lemonldap-NG-Common
This package installs the configuration libraries used by other LemonLDAP::NG
modules.

#==============================================================================
# CPAN modules - Handler
#==============================================================================
%package -n perl-Lemonldap-NG-Handler
Summary:        LemonLDAP-NG Handler Modules
Version:        %{cpan_handler_version}

%description -n perl-Lemonldap-NG-Handler
This package installs the Apache module part (handler) used to protect web
areas.

#==============================================================================
# CPAN modules -  Manager
#==============================================================================
%package -n perl-Lemonldap-NG-Manager
Summary:        LemonLDAP-NG Manager Modules
Version:        %{cpan_manager_version}

%description -n perl-Lemonldap-NG-Manager
This package installs the administration interface (manager).

#==============================================================================
# CPAN modules - Portal
#==============================================================================
%package -n perl-Lemonldap-NG-Portal
Summary:        LemonLDAP-NG Portal Modules
Version:        %{cpan_portal_version}

%description -n perl-Lemonldap-NG-Portal
This package installs the authentication portal.

#==============================================================================
# Source preparation
#==============================================================================
%prep
%setup -n %{name}-%{real_version} -q


#==============================================================================
# Building
#==============================================================================
%build
%{__make} %{?_smp_mflags} configure \
    STORAGECONFFILE=%{lm_storagefile} \
    PERLOPTIONS="INSTALLDIRS=vendor"
%{__make} %{?_smp_mflags}

#==============================================================================
# Installation
#============================================================================
%install
%{__make} %{?_smp_mflags} install \
    DESTDIR=%{buildroot} \
    PREFIX=%{lm_prefix} \
    BINDIR=%{lm_sharedir}/bin \
    SBINDIR=%{lm_sharedir}/sbin \
    FASTCGISOCKDIR=%{_rundir}/llng-fastcgi-server \
    DOCUMENTROOT=%{lm_vardir} \
    EXAMPLESDIR=%{lm_examplesdir} \
    HANDLERDIR=%{lm_vardir}/handler \
    MANAGERDIR=%{lm_sharedir}/manager \
    STORAGECONFFILE=%{lm_storagefile} \
    TOOLSDIR=%{lm_sharedir}/ressources \
    CONFDIR=%{lm_confdir} \
    CRONDIR=%{_sysconfdir}/cron.d \
    DATADIR=%{lm_vardir} \
    INITDIR=%{_sysconfdir}/init.d \
    ETCDEFAULTDIR=%{_sysconfdir}/default \
    DNSDOMAIN=%{lm_dnsdomain} \
    APACHEVERSION=%{apache_version} \
    UWSGIYAMLDIR=%{_sysconfdir}/uwsgi/apps-available \
    LLNGAPPDIR=%{lm_sharedir}/llng-server \
    PROD=yes

# Remove some unwanted files
find %{buildroot} -name .packlist -exec rm -f {} \;
find %{buildroot} -name perllocal.pod -exec rm -f {} \;
find %{buildroot} -name *.bak -exec rm -f {} \;

# Install files for FastCGI Server
mkdir -p %{buildroot}%{_unitdir}
install -m644 fastcgi-server/systemd/llng-fastcgi-server.service \
    %{buildroot}%{_unitdir}
sed -i 's:__FASTCGISOCKDIR__:%{_rundir}/llng-fastcgi-server:' \
    %{buildroot}%{_unitdir}/llng-fastcgi-server.service
sed -i 's:__SBINDIR__:%{lm_sharedir}/sbin:' \
    %{buildroot}%{_unitdir}/llng-fastcgi-server.service
rm -f %{buildroot}%{_sysconfdir}/init.d/llng-fastcgi-server

mkdir -p %{buildroot}%{_tmpfilesdir}
install -m644 fastcgi-server/systemd/llng-fastcgi-server.tmpfile \
    %{buildroot}%{_tmpfilesdir}/llng-fastcgi-server.conf
sed -i 's:__FASTCGISOCKDIR__:%{_rundir}/llng-fastcgi-server:' \
    %{buildroot}%{_tmpfilesdir}/llng-fastcgi-server.conf
sed -i 's:__USER__:%{lm_apacheuser}:' \
    %{buildroot}%{_tmpfilesdir}/llng-fastcgi-server.conf
sed -i 's:__GROUP__:%{lm_apachegroup}:' \
    %{buildroot}%{_tmpfilesdir}/llng-fastcgi-server.conf

# UWSGI Application
mkdir -p %{buildroot}%{_sysconfdir}/uwsgi/apps-available
mkdir -p %{buildroot}%{lm_sharedir}/llng-server

# Set apache user in some files (see Makefile)
# Note: we do not use the APACHEUSER and APACHEGROUP in make install
# because it launches a 'chown', which is not permitted if RPM is not
# built as root
sed -i 's/nobody/%{lm_apacheuser}/' %{buildroot}%{_sysconfdir}/cron.d/*
sed -i 's/nobody/%{lm_apacheuser}/' \
    %{buildroot}%{lm_sharedir}/bin/lmConfigEditor
sed -i 's/nobody/%{lm_apacheuser}/g' \
    %{buildroot}%{lm_sharedir}/bin/lemonldap-ng-cli
sed -i 's/nobody/%{lm_apacheuser}/g' \
    %{buildroot}%{_sysconfdir}/default/llng-fastcgi-server

# Set UNIX rights
mkdir -p %{buildroot}%{lm_vardir}/sessions/lock
mkdir -p %{buildroot}%{lm_vardir}/psessions/lock
chmod 750 %{buildroot}%{lm_vardir}/conf
chmod 640 %{buildroot}%{lm_vardir}/conf/*
chmod 640 %{buildroot}%{lm_storagefile}
chmod 770 %{buildroot}%{lm_vardir}/sessions
chmod 770 %{buildroot}%{lm_vardir}/sessions/lock
chmod 770 %{buildroot}%{lm_vardir}/psessions
chmod 770 %{buildroot}%{lm_vardir}/psessions/lock
chmod 770 %{buildroot}%{lm_vardir}/notifications
chmod 770 %{buildroot}%{lm_vardir}/captcha
chmod 775 %{buildroot}%{lm_sharedir}/sbin/llng-fastcgi-server

# Touch for ghost
mkdir -p %buildroot%{apache_confdir}
touch %buildroot%{apache_confdir}/z-lemonldap-ng-handler.conf
touch %buildroot%{apache_confdir}/z-lemonldap-ng-manager.conf
touch %buildroot%{apache_confdir}/z-lemonldap-ng-portal.conf
touch %buildroot%{apache_confdir}/z-lemonldap-ng-test.conf

#==============================================================================
# Run test
#==============================================================================
%check
sed -i 's:^dirName.*:dirName = %{buildroot}%{lm_vardir}/conf:' \
    %{buildroot}%{lm_storagefile}
%{__make} %{?_smp_mflags} test \
    LLNG_DEFAULTCONFFILE=%{buildroot}%{lm_storagefile}
sed -i 's:^dirName.*:dirName = %{lm_vardir}/conf:' \
    %{buildroot}%{lm_storagefile}

#==============================================================================
# Post Installation
#==============================================================================
%post conf
# Create symlink in Apache configuration
# We use "z-lemonldap-ng-*" so that Apache read the files after "perl.conf"
if [ ! -e %{apache_confdir}/z-lemonldap-ng-handler.conf ] ; then
    ln -s %{lm_confdir}/handler-apache%{apache_version}.conf \
        %{apache_confdir}/z-lemonldap-ng-handler.conf || :
fi
if [ ! -e %{apache_confdir}/z-lemonldap-ng-manager.conf ] ; then
    ln -s %{lm_confdir}/manager-apache%{apache_version}.conf \
        %{apache_confdir}/z-lemonldap-ng-manager.conf || :
fi
if [ ! -e %{apache_confdir}/z-lemonldap-ng-portal.conf ] ; then
    ln -s %{lm_confdir}/portal-apache%{apache_version}.conf \
        %{apache_confdir}/z-lemonldap-ng-portal.conf || :
fi
if [ ! -e %{apache_confdir}/z-lemonldap-ng-test.conf ] ; then
    ln -s %{lm_confdir}/test-apache%{apache_version}.conf \
        %{apache_confdir}/z-lemonldap-ng-test.conf || :
fi
# Upgrade from previous version
# See http://lemonldap-ng.org/documentation/1.0/upgrade
if [ $1 -gt 1 ] ; then
    if [ -e %{lm_confdir}/storage.conf \
         -o -e %{lm_confdir}/apply.conf \
         -o -e %{lm_confdir}/apps-list.xml ] ; then
        # Run migration script
        %{lm_sharedir}/bin/lmMigrateConfFiles2ini 2>&1 > /dev/null || :
        # Fix ownership
        chgrp %{lm_apachegroup} %{lm_storagefile} || :
    fi
fi
# Set editor alternatives if it does not exist
update-alternatives --display editor > /dev/null 2>&1
if [ $? -ne 0 ] ; then
        update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
fi

#==============================================================================
# Pre uninstallation
#==============================================================================
%preun conf
# Package removal
if [ $1 -eq 0 ] ; then
    # Remove symlink in Apache configuration
    rm -f %{apache_confdir}/z-lemonldap-ng-handler.conf 2>&1 > /dev/null || :
    rm -f %{apache_confdir}/z-lemonldap-ng-manager.conf 2>&1 > /dev/null || :
    rm -f %{apache_confdir}/z-lemonldap-ng-portal.conf 2>&1 > /dev/null  || :
    rm -f %{apache_confdir}/z-lemonldap-ng-test.conf 2>&1 > /dev/null  || :
fi
# Upgrade from previous version
if [ $1 -eq 1 ] ; then
    # Remove old symlink in Apache configuration
    rm -f %{apache_confdir}/z-lemonldap-ng.conf 2>&1 > /dev/null || :
fi


%files
%doc changelog INSTALL README.md AUTHORS CONTRIBUTING.md
%license COPYING GPL

%files conf
%dir %{lm_confdir}
%config %{lm_confdir}/for_etc_hosts
%config(noreplace) %{lm_confdir}/handler-apache%{apache_version}.conf
%config(noreplace) %{lm_confdir}/manager-apache%{apache_version}.conf
%config(noreplace) %{lm_confdir}/portal-apache%{apache_version}.conf
%config(noreplace) %{lm_confdir}/test-apache%{apache_version}.conf
%config(noreplace) %{lm_confdir}/handler-nginx.conf
%config(noreplace) %{lm_confdir}/manager-nginx.conf
%config(noreplace) %{lm_confdir}/nginx-lmlog.conf
%config(noreplace) %{lm_confdir}/nginx-lua-headers.conf
%config(noreplace) %{lm_confdir}/portal-nginx.conf
%config(noreplace) %{lm_confdir}/test-nginx.conf
%ghost %{apache_confdir}/z-lemonldap-ng-handler.conf
%ghost %{apache_confdir}/z-lemonldap-ng-manager.conf
%ghost %{apache_confdir}/z-lemonldap-ng-portal.conf
%ghost %{apache_confdir}/z-lemonldap-ng-test.conf
%dir %{lm_vardir}
%dir %{lm_sharedir}
%dir %{lm_sharedir}/bin
%{lm_sharedir}/bin/convertConfig
%{_mandir}/man1/convertConfig*
%{lm_sharedir}/bin/importMetadata
%{lm_sharedir}/bin/lmMigrateConfFiles2ini
%{lm_sharedir}/bin/rotateOidcKeys
%dir %{lm_examplesdir}
%dir %{lm_sharedir}/ressources
%{lm_sharedir}/ressources/*
%defattr(-,root,%{lm_apachegroup},-)
%config(noreplace) %{lm_storagefile}
%defattr(750,%{lm_apacheuser},%{lm_apachegroup},-)
%dir %{lm_vardir}/conf
%dir %{lm_vardir}/sessions
%dir %{lm_vardir}/sessions/lock
%dir %{lm_vardir}/psessions
%dir %{lm_vardir}/psessions/lock
%dir %{lm_vardir}/notifications
%defattr(640,%{lm_apacheuser},%{lm_apachegroup},-)
%config(noreplace) %{lm_vardir}/conf/lmConf-1.json

%files doc
%doc %{lm_vardir}/doc
%doc changelog INSTALL README.md AUTHORS CONTRIBUTING.md
%license COPYING GPL

%files handler
%{lm_sharedir}/bin/purgeLocalCache
%{_sysconfdir}/cron.d/lemonldap-ng-handler
%{lm_vardir}/handler
%{lm_examplesdir}/handler
%{lm_sharedir}/llng-server/llng-server.psgi

%files manager
%{lm_sharedir}/manager
%{lm_examplesdir}/manager
%{lm_sharedir}/bin/lmConfigEditor
%{lm_sharedir}/bin/lemonldap-ng-cli
%{_mandir}/man1/lemonldap-ng-cli*

%files portal
%{lm_vardir}/portal
%{lm_sharedir}/bin/purgeCentralCache
%{_sysconfdir}/cron.d/lemonldap-ng-portal
%{lm_examplesdir}/portal
%defattr(750,%{lm_apacheuser},%{lm_apachegroup},-)
%dir %{lm_vardir}/captcha

%files test
%{lm_vardir}/test

%files fastcgi-server
%{lm_sharedir}/sbin/llng-fastcgi-server
%config(noreplace) %{_sysconfdir}/default/llng-fastcgi-server
%{_unitdir}/llng-fastcgi-server.service
%{_tmpfilesdir}/llng-fastcgi-server.conf
%defattr(755,%{lm_apacheuser},%{lm_apachegroup},-)
%dir %{_rundir}/llng-fastcgi-server
%{lm_sharedir}/examples/llngapp.psgi

%files uwsgi-app
%{_sysconfdir}/uwsgi/apps-available/llng-server.yaml

%files -n perl-Lemonldap-NG-Common
%{_mandir}/man3/Lemonldap::NG::Common*.3pm.*
%{perl_vendorlib}/Lemonldap/NG/Common.pm
%{perl_vendorlib}/Lemonldap/NG/Common/
%{perl_vendorlib}/auto/Lemonldap/NG/Common/

%files -n perl-Lemonldap-NG-Handler
%{_mandir}/man3/Lemonldap::NG::Handler*.3pm.*
%{_mandir}/man3/Plack::Middleware::Auth::LemonldapNG.3pm.*
%{perl_vendorlib}/Lemonldap/NG/Handler.pm
%{perl_vendorlib}/Lemonldap/NG/Handler/
%{perl_vendorlib}/auto/Lemonldap/NG/Handler/
%{perl_vendorlib}/Plack/Middleware/Auth/LemonldapNG.pm

%files -n perl-Lemonldap-NG-Manager
%{_mandir}/man3/Lemonldap::NG::Manager*.3pm.*
%{perl_vendorlib}/Lemonldap/NG/Manager.pm
%{perl_vendorlib}/Lemonldap/NG/Manager/

%files -n perl-Lemonldap-NG-Portal
%{_mandir}/man3/Lemonldap::NG::Portal*.3pm.*
%{perl_vendorlib}/Lemonldap/NG/Portal.pm
%{perl_vendorlib}/Lemonldap/NG/Portal/

#==============================================================================
# Changelog
#==============================================================================
%changelog
* Fri Nov 30 2018 Clement Oudot <clem.oudot@gmail.com> - 2.0.0-1
- Update to 2.0.0

* Fri Jul 20 2018 Clement Oudot <clem.oudot@gmail.com> - 2.0.0~beta1-1
- First beta version for 2.0.0

* Fri Jan 26 2018 Clement Oudot <clem.oudot@gmail.com> - 2.0.0~alpha3-1
- Third alpha version for 2.0.0

* Tue Jan 23 2018 Clement Oudot <clem.oudot@gmail.com> - 1.9.15-1
- Update to 1.9.15

* Fri Nov 24 2017 Clement Oudot <clem.oudot@gmail.com> - 1.9.14-1
- Update to 1.9.14

* Fri Sep 29 2017 Clement Oudot <clem.oudot@gmail.com> - 1.9.13-1
- Update to 1.9.13

* Thu Sep 14 2017 Clement Oudot <clem.oudot@gmail.com> - 2.0.0~alpha2-1
- Second alpha version for 2.0.0

* Tue Sep 12 2017 Clement Oudot <clem.oudot@gmail.com> - 1.9.12-1
- Update to 1.9.12

* Fri Sep 01 2017 Clement Oudot <clem.oudot@gmail.com> - 1.9.11-1
- Update to 1.9.11

* Mon Jul 10 2017 Clement Oudot <clem.oudot@gmail.com> - 2.0.0~alpha1-1
- First alpha version for 2.0.0

* Fri May 19 2017 Clement Oudot <clem.oudot@gmail.com> - 1.9.10-1
- Update to 1.9.10

* Thu Mar 16 2017 Clement Oudot <clem.oudot@gmail.com> - 1.9.9-1
- Update to 1.9.9

* Thu Mar 02 2017 Clement Oudot <clem.oudot@gmail.com> - 1.9.8-1
- Update to 1.9.8

* Mon Dec 12 2016 Clement Oudot <clem.oudot@gmail.com> - 1.9.7-1
- Update to 1.9.7

* Fri Oct 14 2016 Clement Oudot <clem.oudot@gmail.com> - 1.9.6-1
- Update to 1.9.6

* Mon Oct 10 2016 Clement Oudot <clem.oudot@gmail.com> - 1.4.11-1
- Update to 1.4.11

* Wed Jul 13 2016 Clement Oudot <clem.oudot@gmail.com> - 1.9.5-1
- Update to 1.9.5

* Wed Jul 13 2016 Clement Oudot <clem.oudot@gmail.com> - 1.4.10-1
- Update to 1.4.10

* Tue Jun 14 2016 Clement Oudot <clem.oudot@gmail.com> - 1.9.4-1
- Update to 1.9.4

* Tue Jun 07 2016 Clement Oudot <clem.oudot@gmail.com> - 1.9.3-1
- Update to 1.9.3

* Fri Jun 03 2016 Clement Oudot <clem.oudot@gmail.com> - 1.4.9-1
- Update to 1.4.9

* Sun May 01 2016 Clement Oudot <clem.oudot@gmail.com> - 1.9.2-1
- Update to 1.9.2

* Wed Apr 27 2016 Clement Oudot <clem.oudot@gmail.com> - 1.4.8-1
- Update to 1.4.8

* Thu Mar 31 2016 Clement Oudot <clem.oudot@gmail.com> - 1.9.1-1
- Update to 1.9.1

* Thu Mar 17 2016 Clement Oudot <clem.oudot@gmail.com> - 1.4.7-1
- Update to 1.4.7

* Wed Mar 02 2016 Clement Oudot <clem.oudot@gmail.com> - 1.9.0-1
- Update to 1.9.0

* Mon Sep 28 2015 Clement Oudot <clem.oudot@gmail.com> - 1.4.6-1
- Update to 1.4.6

* Mon May 11 2015 Clement Oudot <clem.oudot@gmail.com> - 1.4.5-1
- Update to 1.4.5

* Wed Apr 15 2015 Clement Oudot <clem.oudot@gmail.com> - 1.4.4-1
- Update to 1.4.4

* Thu Dec 18 2014 Clement Oudot <clem.oudot@gmail.com> - 1.4.3-1
- Update to 1.4.3
- Support for CentOS 7

* Fri Oct 31 2014 Clement Oudot <clem.oudot@gmail.com> - 1.4.2-1
- Update to 1.4.2

* Fri Jul 25 2014 Clement Oudot <clem.oudot@gmail.com> - 1.4.1-1
- Update to 1.4.1

* Fri Apr 18 2014 Clement Oudot <clem.oudot@gmail.com> - 1.4.0-1
- Update to 1.4.0

* Fri Mar 07 2014 Clement Oudot <clem.oudot@gmail.com> - 1.3.3-1
- Update to 1.3.3

* Thu Jan 23 2014 Clement Oudot <clem.oudot@gmail.com> - 1.3.2-1
- Update to 1.3.2

* Mon Nov 11 2013 Clement Oudot <clem.oudot@gmail.com> - 1.3.1-1
- Update to 1.3.1

* Sat Nov 2 2013 Clement Oudot <clem.oudot@gmail.com> - 1.3.0-1
- Update to 1.3.0

* Mon Aug 26 2013 Clement Oudot <clem.oudot@gmail.com> - 1.2.5-1
- Update to 1.2.5

* Tue Apr 23 2013 Clement Oudot <clem.oudot@gmail.com> - 1.2.4-1
- Update to 1.2.4

* Fri Feb 08 2013 Clement Oudot <clem.oudot@gmail.com> - 1.2.3-1
- Update to 1.2.3

* Mon Sep 17 2012 Clement Oudot <clem.oudot@gmail.com> - 1.2.2-1
- Update to 1.2.2

* Thu Jul 05 2012 Clement Oudot <clem.oudot@gmail.com> - 1.2.1-1
- Update to 1.2.1

* Sun Jun 17 2012 Clement Oudot <clem.oudot@gmail.com> - 1.2.0-1
- Update to 1.2.0

* Fri Oct 07 2011 Clement Oudot <clem.oudot@gmail.com> - 1.1.2-1
- Update to 1.1.2

* Fri Jul 29 2011 Clement Oudot <clem.oudot@gmail.com> - 1.1.1-1
- Update to 1.1.1

* Fri Jul 08 2011 Clement Oudot <clem.oudot@gmail.com> - 1.1.0-1
- Update to 1.1.0

* Thu Jun 30 2011 Clement Oudot <clem.oudot@gmail.com> - 1.0.6-1
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

* Fri Jan 9 2009 Clement Oudot <coudot@linagora.com> - 0.9.3.2-1
- Updated to release 0.9.3.2.
- Use internal version number for perl modules (compatibility with RPMforge packages)
- Merge with existing .spec file from RPMforge.
- Use the same directories as the Debian package.
- Create a symlink in Apache confguration.
- Create specific portal/manager/handler/conf packages independent from CPAN packages

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
