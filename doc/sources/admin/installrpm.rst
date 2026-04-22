Installation on Red Hat/CentOS
==============================


.. attention::

    LemonLDAP::NG requires at least Red Hat/CentOS 8

List of packages
----------------

LemonLDAP::NG provides packages for RHEL (and derivatives) 8/9/10:

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

On most community distributions, this is done with the following command ::

    dnf install epel-release

If you are using the official RHEL build, refer to the above documentation.

In any case, after enabling EPEL, also enable the optional "CodeReady Builder" repository ::

    crb enable

Install from official Fedora packages
-------------------------------------

.. code-block:: shell

   dnf install lemonldap-ng

   # If you use SELinux
   dnf install lemonldap-ng lemonldap-ng-selinux


.. _installrpm-yum-repository:

(alternative) Install from our YUM repository
----------------------------------------------

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

Install the `GPG Security key <https://lemonldap-ng.org/security/GPG-KEY-LLNG-SECURITY.asc>`__ on your LemonLDAP::NG server:

::

   curl https://lemonldap-ng.org/security/GPG-KEY-LLNG-SECURITY.asc > /etc/pki/rpm-gpg/RPM-GPG-KEY-OW2

Then, install the packages


.. code-block:: shell

   dnf install lemonldap-ng

   # If you use SELinux
   dnf install lemonldap-ng lemonldap-ng-selinux

(alternative) Manual download
-----------------------------

RPMs are available on the `Download page <https://lemonldap-ng.org/download.html>`__.

.. code-block:: shell

   dnf install lemonldap-ng-* perl-Lemonldap-NG-*


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

