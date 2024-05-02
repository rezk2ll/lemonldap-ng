Installation on Red Hat/CentOS
==============================


.. attention::

    LemonLDAP::NG requires at least Red Hat/CentOS 7

List of pacakges
----------------

LemonLDAP::NG provides packages for RHEL (and derivatives) 7/8/9:

- ``lemonldap-ng``: metapackage, contains no file but dependencies on other
  packages
- ``lemonldap-ng-doc``: HTML documentation and project docs
  (README, etc.)
- ``lemonldap-ng-test``: sample CGI test page
- ``lemonldap-ng-common``: configuration and common files
- ``lemonldap-ng-handler``: Handler common libraries
- ``lemonldap-ng-manager``: Manager files
- ``lemonldap-ng-portal``: Portal files
- ``lemonldap-ng-fastcgi-server``: FastCGI server needed to use Nginx
- ``lemonldap-ng-uwsgi-app``: Uwsgi application
- ``lemonldap-ng-selinux``: SELinux policy
- ``perl-Lemonldap-NG-SSOaaS-Apache-Client``: SSOaaS client module


Prerequisites
-------------

LemonLDAP::NG has dependencies which are not in base RHEL repositories.

You need to enable `EPEL repositories <https://docs.fedoraproject.org/en-US/epel/#Quickstart>`__ before installing.

On RHEL8 and derivatives, you also also need to enable the PowerTools repository in ``/etc/yum.repos.d``.

On OracleLinux, the corresponding repo is called Oracle Linux 8 CodeReady Builder.

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

You may also need some extras packages for SAML, available here:

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

Official Fedora packages
~~~~~~~~~~~~~~~~~~~~~~~~

Packages are available in EPEL, so you can choose to install them directly from here.

Manual download
~~~~~~~~~~~~~~~

RPMs are available on the `Download page <https://lemonldap-ng.org/download.html>`__.

Package GPG signature
---------------------

For EL7
~~~~~~~

Get the legacy `RPM signing key <https://lemonldap-ng.org/_media/rpm-gpg-key-ow2>`__ onto your LemonLDAP::NG server:

::

   curl https://lemonldap-ng.org/_media/rpm-gpg-key-ow2 > /etc/pki/rpm-gpg/RPM-GPG-KEY-OW2


For EL8 and higher
~~~~~~~~~~~~~~~~~~

Install the `GPG Security key <https://lemonldap-ng.org/security/GPG-KEY-LLNG-SECURITY.asc>`__ on your LemonLDAP::NG server:

::

   curl https://lemonldap-ng.org/security/GPG-KEY-LLNG-SECURITY.asc > /etc/pki/rpm-gpg/RPM-GPG-KEY-OW2


Install packages
----------------

With YUM
~~~~~~~~

If the packages are stored in a yum repository:

.. code-block:: shell

   yum install lemonldap-ng

   # If you use SELinux
   yum install lemonldap-ng lemonldap-ng-selinux

You can also use yum on local RPMs file:

::

   yum localinstall lemonldap-ng-* perl-Lemonldap-NG-*

With RPM
~~~~~~~~

You have then to install all the downloaded packages:

::

   yum install lemonldap-ng-* perl-Lemonldap-NG-*


.. tip::

    You can choose to install only one component by choosing the
    package ``lemonldap-ng-portal``, ``lemonldap-ng-handler`` or
    ``lemonldap-ng-manager``.

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

If you upgraded LemonLDAP::NG, check all :doc:`upgrade notes<upgrade>`.

DNS
~~~

Configure your DNS server to resolve names with your server IP:

-  ``auth.<your domain>``: main portal, must be public
-  ``manager.<your domain>``: manager, only for adminsitrators
-  ``test1.<your domain>``, ``test2.<your domain>``: sample applications

Follow the :ref:`next steps<start-configuration>`

File location
-------------

-  Configuration is in ``/etc/lemonldap-ng``
-  LemonLDAP::NG configuration (edited by the Manager) is in
   ``/var/lib/lemonldap-ng/conf/``
-  All Perl modules are in the ``/usr/share/perl5/vendor_perl`` directory
-  All Perl scripts/pages are in ``/var/lib/lemonldap-ng/``
-  All static content (examples, CSS, images, etc.) is in
   ``/usr/share/lemonldap-ng/``
- Administration scripts are in ``/usr/libexec/lemonldap-ng/bin``

