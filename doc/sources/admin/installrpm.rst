Installation on Red Hat/CentOS
==============================


.. attention::

    LL::NG requires at least Red Hat/CentOS 7

Organization
------------

LemonLDAP::NG provides packages for Red Hat/Centos 7:

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
-  lemonldap-ng-nginx: contains Nginx configuration and dependencies
-  lemonldap-ng-uwsgi-app: contains Uwsgi application
-  lemonldap-ng-selinux: contains the SELinux policy for httpd
-  perl-Lemonldap-NG-Common: CPAN - Shared modules
-  perl-Lemonldap-NG-Handler: CPAN - Handler modules
-  perl-Lemonldap-NG-Manager: CPAN - Manager modules
-  perl-Lemonldap-NG-Portal: CPAN - Portal modules


.. danger::

    The package lemonldap-ng-nginx requires the nginx
    community package. If you use openrestry or Nginx plus, you must ignore
    this dependency. To do this, download the package and install it with:

    ::

       rpm --nodeps -i lemonldap-ng-nginx*.rpm



Get the packages
----------------

.. _installrpm-yum-repository:

YUM repository
~~~~~~~~~~~~~~

You can add this YUM repository to get recent packages:

::

   vi /etc/yum.repos.d/lemonldap-ng.repo

::

   [lemonldap-ng]
   name=LemonLDAP::NG packages
   baseurl=https://lemonldap-ng.org/redhat/stable/$releasever/noarch
   enabled=1
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OW2


.. tip::

    Replace ``stable`` by ``2.0`` to avoid upgrade to next major
    version

You may also need some extras packages, available here:

::

   [lemonldap-ng-extras]
   name=LemonLDAP::NG extra packages
   baseurl=https://lemonldap-ng.org/redhat/extras/$releasever
   enabled=1
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OW2

Run this to update packages cache:

::

   yum update


.. danger::

    You must also install the EPEL repository for non-core
    dependencies. See :ref:`prerequisites and dependencies<prereq-yum>`
    chapter for more. 

Manual download
~~~~~~~~~~~~~~~

RPMs are available on the :doc:`Download page</download>`.

Package GPG signature
---------------------


Get the `RPM signing key <https://lemonldap-ng.org/_media/rpm-gpg-key-ow2>`__ onto your LemonLDAP::NG server:

::

   curl https://lemonldap-ng.org/_media/rpm-gpg-key-ow2 > /etc/pki/rpm-gpg/RPM-GPG-KEY-OW2

Install packages
----------------

With YUM
~~~~~~~~

If the packages are stored in a yum repository:

.. code-block:: shell

   yum install lemonldap-ng

   # If you use SELinux
   yum install lemonldap-ng-selinux

You can also use yum on local RPMs file:

::

   yum localinstall lemonldap-ng-* perl-Lemonldap-NG-*

With RPM
~~~~~~~~

Before installing the packages, install all :doc:`dependencies<prereq>`.

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

Change default DNS domain
~~~~~~~~~~~~~~~~~~~~~~~~~

By default, DNS domain is ``example.com``. You can change it quick with
a sed command. For example, we change it to ``ow2.org``:

.. code-block:: shell

   sed -i 's/example\.com/ow2.org/g' /etc/lemonldap-ng/* /var/lib/lemonldap-ng/conf/lmConf-1.json /etc/nginx/conf.d/* /etc/httpd/conf.d/*

Upgrade
~~~~~~~

If you upgraded LL::NG, check all :doc:`upgrade notes<upgrade>`.

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
-  Install all build dependencies (see BuildRequires in
   lemonldap-ng.spec)
-  Put LemonLDAP::NG tarball in %_topdir/SOURCES
-  Edit ~/.rpmmacros and set your build parameters:

::

   %_topdir /home/user/build
   %dist .el7
   %rhel 7

-  Go to %_topdir
-  Build:

::

   rpmbuild -ta SOURCES/lemonldap-ng-VERSION.tar.gz


