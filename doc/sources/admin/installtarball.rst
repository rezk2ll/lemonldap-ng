Installation from the tarball
=============================

Get the tarball
---------------

Get the tarball from `download page <https://lemonldap-ng.org/download.html>`__. You can also find
on this page the SVN tarball if you want to test latest features.


.. attention::

    The content of the SVN tarball is not the same as the
    official tarball. Please see the next chapter to learn how build an
    official tarball from SVN files.

Build the tarball from SVN
--------------------------

Either checkout or export the `SVN
repository <http://forge.ow2.org/plugins/scmsvn/index.php?group_id=274>`__,
or extract the SVN tarball to get the SVN files on your disk.

Then go to trunk directory:

::

   cd trunk

And run the "dist" target:

::

   make dist

The generated tarball is in the current directory.

Extraction
----------

Just run the tar command:

::

   tar zxvf lemonldap-ng-*.tar.gz

Installation
------------

First check and install the :doc:`prerequisites<prereq>`.

For full install:

::

   cd lemonldap-ng-*
   make configure
   make
   make test
   sudo make install PROD=yes


.. note::

    ``PROD=yes`` makes web interface use minified versions of CSS and
    JS files.

You can modify location of default storage configuration file in
configure target:

::

   make configure STORAGECONFFILE=/etc/lemonldap-ng/lemonldap-ng.ini

You can choose other Makefile targets:

-  Perl libraries install :

   -  install_libs (all Perl libraries)
   -  install_portal_libs
   -  install_manager_libs
   -  install_handler_libs

-  Binaries install :

   -  install_bin (/usr/local/lemonldap-ng/bin)

-  FastCGI server install (required for Nginx)

   -  install_fastcgi_server (/usr/local/lemonldap-ng/sbin)

-  Web sites install :

   -  install_site (all sites including install_doc_site)
   -  install_portal_site (/usr/local/lemonldap-ng/htdocs/portal)
   -  install_manager_site (/usr/local/lemonldap-ng/htdocs/manager)
   -  install_handler_site (/usr/local/lemonldap-ng/handler)

-  Documentation install :

   -  install_doc_site (/usr/local/lemonldap-ng/htdocs/doc)
   -  install_examples_site (/usr/local/lemonldap-ng/examples)

You can also pass parameters to the make install command, with this
syntax:

::

   sudo make install PARAM=VALUE PARAM=VALUE ...

Available parameters are:

-  **ERASECONFIG**: set to 0 if you want to keep your configuration
   files (default: 1)
-  **DESTDIR**: only for packaging, install the product in a jailroot
   (default: "")
-  **PREFIX**: installation directory (default: /usr/local)
-  **CRONDIR**: Cronfile directory (default:
   $PREFIX/etc/lemonldap-ng/cron.d)
-  **APACHEUSER**: user running Apache
-  **APACHEGROUP**: group running Apache
-  **DNSDOMAIN**: Main DNS domain (default: example.com)
-  **APACHEVERSION**: Apache major version (default: 2)
-  **VHOSTLISTEN**: how listen parameter is configured for virtual hosts
   in Apache (default: \*:80)
-  **PROD**: use minified JS and CSS files
-  **USEDEBIANLIBS**: use Debian packaged JS and CSS files (**Note
   that this options isn't yet usable**  since Debian provides a too
   old AngularJS for now: LLNG manager needs at least version 1.4.0)
-  **USEEXTERNALLIBS**: use files from public CDN
-  **STORAGECONFFILE**: *make configure* target only. Location of default
   storage configuration file (default:
   /usr/local/lemonldap-ng/etc/lemonldap-ng.ini)


.. tip::

    For Debian/Ubuntu with Apache2, you can use:

    ::

       make debian-install-for-apache
       make ubuntu-install-for-apache

    And with Nginx:

    ::

       make debian-install-for-nginx
       make ubuntu-install-for-nginx

    See also :doc:`Debian/Ubuntu installation documentation<installdeb>`.


Install cron jobs
-----------------

LL::NG use cron jobs (or systemd timers) to:

-  purge old sessions
-  clean Handler cache

To install them on system:

::

   sudo ln -s /usr/local/lemonldap-ng/etc/cron.d/* /etc/cron.d/

or install .timers files in systemd directory (/lib/systemd/system)

DNS
---

Configure your DNS server to resolve names with your server IP:

-  auth.<your domain>: main portal, must be public
-  manager.<your domain>: manager, only for adminsitrators
-  test1.<your domain>, test2.<your domain>: sample applications

Follow the :ref:`next steps<start-configuration>`.
