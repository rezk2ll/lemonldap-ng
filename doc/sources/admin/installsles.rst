Installation on Suse Linux
==========================


.. attention::

    LL::NG requires at least SLES 12 SP1 or
    equivalent

Organization
------------

LemonLDAP::NG provides packages for SLES:

-  lemonldap-ng: metapackage, contains no file but dependencies on other
   packages
-  lemonldap-ng-doc: contains HTML documentation and project docs
   (README, etc.)
-  lemonldap-ng-conf: contains default configuration (DNS domain:
   example.com)
-  lemonldap-ng-test: contains sample CGI test page
-  lemonldap-ng-handler: contains Apache Handler implementation (agent)
-  lemonldap-ng-manager: contains administration interface and session
   explorer
-  lemonldap-ng-portal: contains authentication portal and menu
-  lemonldap-ng-fastcgi-server: FastCGI server needed to use Nginx
-  perl-Lemonldap-NG-Common: CPAN - Shared modules
-  perl-Lemonldap-NG-Handler: CPAN - Handler modules
-  perl-Lemonldap-NG-Manager: CPAN - Manager modules
-  perl-Lemonldap-NG-Portal: CPAN - Portal modules

Get the packages
----------------

Repositories
~~~~~~~~~~~~

This manual only refers to SLES 12 SP1. Installation may work on other
platforms, with no guarantee.

Different repositories are necessary for LemonLDAP::NG dependencies:

-  Suse official repositories
-  2 repositories on `openSUSE Build
   Service <https://build.opensuse.org/>`__
-  Additional packages available on repository.linagora.org or
   lemonldap-ng.org
-  Suse SDK repository is advised for building packages (yast2 ->
   Software -> Software Repositories -> Add --> Extensions and modules
   from Registration Server)

First, make sure the exploitation system is up to date:

::

   zypper update

You can add the openSUSE Build Service repositories with the following
commands:

::

   zypper addrepo http://download.opensuse.org/distribution/leap/42.1/repo/oss/suse/ leap42
   zypper addrepo http://download.opensuse.org/repositories/devel:languages:perl/SLE_12/devel:languages:perl.repo
   zypper refresh

Accept both signing keys each time.

You can add the additional dependency repository \*and\* the
LemonLDAP::NG repository with either commands:

::

   zypper addrepo http://lemonldap-ng.org/sles12 lemonldap-sles12-repository
   zypper refresh

or

::

   zypper addrepo http://repository.linagora.org/lemonldap-sles12-repository lemonldap-sles12-repository
   zypper refresh


.. tip::

    Only packages on SLES 12 SP1 are tested for now.

Manual download
~~~~~~~~~~~~~~~

RPMs are available on the `Download page <https://lemonldap-ng.org/download.html>`__.

Package GPG signature
---------------------

Install the `RPM signing key <https://lemonldap-ng.org/_media/rpm-gpg-key-ow2>`__ to trust RPMs:

::

   wget https://lemonldap-ng.org/_media/rpm-gpg-key-ow2
   rpm --import rpm-gpg-key-ow2

Install packages
----------------

With ZYPPER
~~~~~~~~~~~

If the packages are stored in a repository:

.. code-block:: shell

   zypper install lemonldap-ng

.. code-block:: shell

   59 new packages to install.
   Total download size: 13.5 MiB. Already cached : 0 B. After operation, 30.7 MiB of supplementary disk space will be used.
   Continue ? [y/n/? print all options] (y):

You can also use zypper on local RPMs file:

::

   zypper install lemonldap-ng-* perl-Lemonldap-NG-*

With RPM
~~~~~~~~

Before installing the packages, install all dependencies: (you need to
get dependencies from previous repositories)

::

   zypper install apache2 apache2-mod_perl apache2-mod_fcgid perl-ldap perl-XML-SAX perl-XML-NamespaceSupport perl-XML-Simple perl-XML-LibXML perl-Config-IniFiles perl-Digest-HMAC perl-Crypt-OpenSSL-RSA perl-Authen-SASL perl-Unicode-String gd perl-Regexp-Assemble perl-Authen-Captcha perl-Cache-Cache perl-Apache-Session perl-CGI-Session perl-IO-String perl-MIME-Lite perl-SOAP-Lite perl-XML-LibXSLT perl-String-Random perl-Email-Date-Format perl-Crypt-Rijndael perl-HTML-Template perl-JSON perl-Crypt-OpenSSL-X509 perl-Crypt-DES perl-Class-Inspector perl-Test-MockObject perl-Clone perl-Net-CIDR-Lite perl-ExtUtils-MakeMaker perl-CGI perl-CGI-Session perl-HTML-Template perl-SOAP-Lite perl-IPC-ShareLite perl-Error perl-HTML-Parser perl-libwww-perl perl-DBI perl-Cache-Memcached perl-Class-ErrorHandler perl-Convert-PEM perl-Crypt-DES_EDE3 perl-Digest-SHA perl-Env perl-Mouse perl-String-CRC32 perl-Plack perl-Regexp-Common perl-Crypt-OpenSSL-Bignum perl-FCGI-ProcManager

You have then to install all the downloaded packages:

::

   rpm -Uvh lemonldap-ng-* perl-Lemonldap-NG-*


.. tip::

    You can choose to install only one component by choosing the
    package ``lemonldap-ng-portal``, ``lemonldap-ng-handler`` or
    ``lemonldap-ng-manager``.

    Install the package ``lemonldap-ng-conf`` on all server which contains
    one of those packages.

First configuration steps
-------------------------

Enable Apache extensions
~~~~~~~~~~~~~~~~~~~~~~~~

These extensions are activated by default on Apache at LemonLDAP
install:

::

   a2enmod perl
   a2enmod headers
   a2enmod mod_fcgid
   a2enmod ssl
   a2enmod rewrite
   a2enmod proxy
   a2enmod proxy_http

If you decide to use SSL, you should also activate the appopriate flag:

::

   sed -i 's/^APACHE_SERVER_FLAGS=.*/APACHE_SERVER_FLAGS="SSL"/' /etc/sysconfig/apache2

Change default DNS domain
~~~~~~~~~~~~~~~~~~~~~~~~~

By default, DNS domain is ``example.com``. You can change it quick with
a sed command. For example, we change it to ``ow2.org``:

.. code-block:: shell

   sed -i 's/example\.com/ow2.org/g' /etc/lemonldap-ng/{*.conf,*.ini,for_etc_hosts} /var/lib/lemonldap-ng/conf/lmConf-1

Check Apache configuration and restart:

.. code-block:: shell

   apachectl configtest
   apachectl restart

DNS
~~~

Configure your DNS server to resolve names with your server IP:

-  auth.<your domain>: main portal, must be public
-  manager.<your domain>: manager, only for adminsitrators
-  test1.<your domain>, test2.<your domain>: sample applications

Follow the :ref:`next steps<start-configuration>`

File location
-------------

-  Configuration is in /etc/lemonldap-ng
-  LemonLDAP::NG configuration (edited by the Manager) is in
   /var/lib/lemonldap-ng/conf/
-  All Perl modules are in the VENDOR perl directory
-  All Perl scripts/pages are in /var/lib/lemonldap-ng/
-  All static content (examples, CSS, images, etc.) is in
   /usr/share/lemonldap-ng/

Build your packages
-------------------

If you need it, you can rebuild RPMs:

-  Install rpm-build package
-  Get the lemonldap source package from repository:

::

   zypper source-install lemonldap-ng
   cd /usr/src/packages/
   ls SPECS/ SOURCES/

-  Install all build dependencies (see BuildRequires in
   lemonldap-ng.spec)
-  Build:

::

   rpmbuild -ba SPECS/lemonldap-ng.spec
