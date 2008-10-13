Name:           lemonldap-ng
Version:        0.9.2
Release:        1%{?dist}
Summary:        Lemonldap-ng Web SSO module

Group:          Applications/System 
License:        GPL 
URL:            http://wiki.lemonldap.objectweb.org 
Source0:        http://download.forge.objectweb.org/lemonldap/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:      noarch 
BuildRequires:  perl

Requires: perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires: perl-Apache-Session, perl-LDAP, perl-Email-MIME-Encodings, perl-CGI-Session,
Requires:  perl-libwww-perl, perl-DBI, perl-Cache-Cache, perl-XML-Simple, perl-SOAP-Lite, perl-HTML-Template

%description
Lemonldap::NG is a modular Web-SSO based on Apache::Session modules. It simplifies the build of a protected area with a few changes in the application. It manages both authentication and authorization and provides headers for accounting. So you can have a full AAA protection for your web space as described below.

%prep
%setup -q

%build
make %{?_smp_mflags}
make test

%install
rm -rf $RPM_BUILD_ROOT
make install

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc

%changelog
* Tue Oct 7 2008 David Hannequin <david.hannequin@linagora.com> 
- initial RPM
