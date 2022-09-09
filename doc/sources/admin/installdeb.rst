Installation on Debian/Ubuntu with packages
===========================================

Organization
------------

LemonLDAP::NG provides these packages:

-  lemonldap-ng: metapackage, contains no file but dependencies on other
   packages
-  lemonldap-ng-doc: contains HTML documentation and project docs
   (README, etc.)
-  lemonldap-ng-fastcgi-server: LL::NG FastCGI server (for Nginx)
-  lemonldap-ng-handler: Handler files
-  liblemonldap-ng-common-perl: configuration and common files
-  liblemonldap-ng-handler-perl: Handler common libraries
-  liblemonldap-ng-manager-perl: Manager files
-  liblemonldap-ng-portal-perl: Portal files
-  liblemonldap-ng-ssoaas-apache-client-perl: SSOaaS client module

Get the packages
----------------

.. _installdeb-official-repository:

Official repository
~~~~~~~~~~~~~~~~~~~

If you run Debian stable, testing or unstable, the packages are directly
installable:

::

   apt-get install lemonldap-ng


.. tip::

    Packages from `Debian
    repository <http://packages.debian.org/search?keywords=lemonldap-ng>`__
    may not be up to date but are **security-maintained** by `Debian
    Security Team <https://security-team.debian.org/>`__ for "stable"
    release and `LTS team <https://www.debian.org/lts/>`__ for "oldstable"
    release. Then if you don't need some new features or aren't concerned by
    a bug fixed earlier, **this is a good choice**. You can also use `Debian
    backports <https://backports.debian.org/>`__ or "testing"/"unstable"
    packages, team maintained.
    `Here is the list of Debian versions <https://lemonldap-ng.org/documentation/#packaged_versions>`__.


.. danger::

    LLNG Ubuntu packages are not in the "universe" but in the
    "multiverse". This means they are not security-maintained. If you use
    them, you should follow our security advisories on
    lemonldap-ng-users@ow2.org.

.. _installdeb-llng-repository:

LL::NG repository
~~~~~~~~~~~~~~~~~

You can add this repository to have recent packages.

First, make sure your system can install packages from HTTPS
repositories:

::

   apt install apt-transport-https

You will need to trust the `DEB signing key <https://lemonldap-ng.org/_media/rpm-gpg-key-ow2>`__ :

::

   wget -O - https://lemonldap-ng.org/_media/rpm-gpg-key-ow2 | apt-key add -

Then, add the official LL::NG repository

::

   vi /etc/apt/sources.list.d/lemonldap-ng.list

::

   # LemonLDAP::NG repository
   deb     https://lemonldap-ng.org/deb 2.0 main


.. tip::

    -  Use the ``stable`` repository to get packages from current major
       version
    -  Use the ``oldstable`` repository to get packages from previous major
       version
    -  Use the ``testing`` repository to get packages from next major
       version
    -  Use the ``2.0`` repository to stay on this major version and avoid
       upgrade to next major version


Finally update your APT cache:

::

   apt update

Manual download
~~~~~~~~~~~~~~~

Packages are available on the `Download page <https://lemonldap-ng.org/download.html>`__.

Install packages
----------------


.. attention::

    By default packages will require Nginx. If you want to
    use Apache2, install it first with mod_perl:

    ::

       apt install apache2 libapache2-mod-perl2 libapache2-mod-fcgid



With apt
~~~~~~~~

::

   apt install lemonldap-ng

With dpkg
~~~~~~~~~

Before installing the packages, install :doc:`dependencies<prereq>`.

Then:

::

   dpkg -i liblemonldap-ng-* lemonldap-ng*

First configuration steps
-------------------------

Change default DNS domain
~~~~~~~~~~~~~~~~~~~~~~~~~

By default, DNS domain is ``example.com``. You can change it quick with
a sed command. For example, we change it to ``ow2.org``:

.. code-block:: shell

   sed -i 's/example\.com/ow2.org/g' /etc/lemonldap-ng/* /var/lib/lemonldap-ng/conf/lmConf-1.json

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
-  All Perl modules are in the VENDOR perl directory (/usr/share/perl5/)
-  All Perl scripts/pages are in /var/lib/lemonldap-ng/
-  All lemonldap-ng tools are in /usr/share/lemonldap-ng/bin/
-  All static content (examples, CSS, images, etc.) is in
   /usr/share/lemonldap-ng/
-  Apache configuration files are in /etc/lemonldap-ng and linked in
   /etc/apache2/sites-available and /etc/nginx/sites-available

Build your packages
-------------------

You can also get the `LemonLDAP::NG source <https://lemonldap-ng.org/download.html>`__ and make
the package yourself:

::

   tar xzf lemonldap-ng-*.tar.gz
   cd lemonldap-ng-*
   make debian-packages
