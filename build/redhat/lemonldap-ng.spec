Name:           lemonldap-ng
Version:        0.9.3
Release:        1.el5.ow2
Summary:        LemonLDAP-NG WebSSO

Group:          Applications/System 
License:        GPL
URL:            http://wiki.lemonldap.objectweb.org 
Source0:        http://download.forge.objectweb.org/lemonldap/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root

Packager:	David Hannequin, Clement Oudot
Vendor:		OW2

BuildArch:      noarch 
BuildRequires:  perl

Requires: perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires: perl-Apache-Session, perl-LDAP, perl-Email-MIME-Encodings, perl-CGI-Session
Requires: perl-libwww-perl, perl-DBI, perl-Cache-Cache, perl-XML-Simple, perl-SOAP-Lite, perl-HTML-Template

%description
LemonLDAP::NG is a modular Web-SSO based on Apache::Session modules. It simplifies the build of a protected area with a few changes in the application. It manages both authentication and authorization and provides headers for accounting. So you can have a full AAA protection for your web space as described below.

%prep
%setup -q

%build
make %{?_smp_mflags}
make test

%install
rm -rf %{buildroot}
make install DESTDIR=%{buildroot}
# Set EXAMPLEROOT to BuildRoot and REALROOT to /
sed -i 's#^EXAMPLEROOT=.*#EXAMPLEROOT=%{buildroot}/#' Makefile
sed -i 's#^REALROOT=.*#REALROOT=/#' Makefile
# Install example
make example
# Set UNIX rights
make postconf_unixrights
# TODO : symlink apache config in /etc/httpd/conf.d

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc /var/lib/lemonldap-ng/docs
%doc /usr/share/man/
%config /etc/lemonldap-ng
/var/lib/lemonldap-ng/portal
/var/lib/lemonldap-ng/manager
/var/lib/lemonldap-ng/handler
/var/lib/lemonldap-ng/sessions
/var/lib/lemonldap-ng/liberty-alliance-sp-portal
/var/lib/lemonldap-ng/test
/usr/bin/lmConfig_File2MySQL
/usr/lib/perl5/

%changelog
* Tue Oct 14 2008 Clement Oudot <coudot@linagora.com> 
- Use v0.9.3
- Install example
* Tue Oct 7 2008 David Hannequin <david.hannequin@linagora.com> 
- initial RPM
