Deploy Apache configuration
===========================


.. note::

    This step should have been already done if you installed LL::NG
    with packages.

Files
-----


.. attention::

    Apache Mod Perl has many issues since 2.4 version with
    MPM worker and MPM event. No problem for portal and manager since they
    are now handled by FastCGI. If you want to use Apache for Handler,
    please switch to MPM prefork, else use Nginx.

With tarball installation, Apache configuration files will be installed
in ``/usr/local/lemonldap-ng/etc/``, else they are in
``/etc/lemonldap-ng``.

You have to include them in Apache main configuration, for example:

.. code-block:: apache

   include /usr/local/lemonldap-ng/etc/portal-apache2.conf
   include /usr/local/lemonldap-ng/etc/handler-apache2.conf
   include /usr/local/lemonldap-ng/etc/manager-apache2.conf
   include /usr/local/lemonldap-ng/etc/test-apache2.conf


.. tip::



    -  You can also use symbolic links in ``conf.d`` or ``sites-available``
       Apache directory.
    -  If you have run the Debian/Ubuntu install command, just use:

    ::

       a2ensite manager-apache2.conf
       a2ensite portal-apache2.conf
       a2ensite handler-apache2.conf
       a2ensite test-apache2.conf



Modules
-------

You will also need to load some Apache modules:

-  mod_rewrite
-  mod_perl
-  mod_alias
-  mod_fcgid
-  mod_headers


.. tip::

    With Debian/Ubuntu:

    ::

       a2enmod fcgid perl alias rewrite headers


