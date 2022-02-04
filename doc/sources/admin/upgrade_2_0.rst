Upgrade from 1.9 to 2.0
=======================


.. attention::

    2.0 is a major release, lot of things have been changed.
    You must read this document before upgrade.

Upgrade order from 1.9.\*
-------------------------

As usual, if you use more than 1 server and don't want to stop SSO
service AND IF YOU HAVE NO INCOMPATIBILITY MENTIONED IN THIS DOCUMENT,
upgrade must be done in the following order:

#. servers with handlers only;
#. portal servers *(all together if your load balancer is stateless
   (user or client IP) and if users use the menu)*;
#. manager server


.. attention::

    You must revalidate your configuration using the
    manager.

Installation
------------


.. attention::

    French documentation is no more available. Only English
    version of this documentation is maintained now.

This release of LL::NG requires these minimal versions of GNU/Linux
distributions:

-  Debian 9 (stretch)
-  Ubuntu 16.04 LTS
-  CentOS 7
-  RHEL 7

For SAML features, we require at least Lasso 2.5 and we recommend Lasso
2.6.

Configuration
-------------

-  **lemonldap-ng.ini** requires some new fields in portal section.
   Update yours using the one given installed by default. New requires
   fields are:

   -  **staticPrefix** *(manager and portal)*: the path to static
      content
   -  **templateDir** *(manager and portal)*: the path to templates
      directory
   -  **languages** *(manager and portal)*: accepted languages

-  Portal skins are now in ``/usr/share/lemonldap-ng/portal/templates``.
   See :ref:`skin customization<portalcustom-skin-customization>` to
   adapt your templates.
-  User module in authentication parameters now provides a "Same as
   authentication" value. You must revalidate it in the manager since
   all special values must be replaced by this *(Multi, Choice, Proxy,
   Slave, SAML, OpenID*,...)*
-  **"Multi" doesn't exist anymore**: it is replaced by
   :doc:`Combination<authcombination>`, a more powerful module.
-  Apache and Nginx configurations must be updated to use FastCGI portal
-  URLs for mail reset and register pages have changed, you must update
   configuration parameters. For example:

::

     mailUrl => 'http://auth.example.com/resetpwd',
     registerUrl => 'http://auth.example.com/register',

-  Option ``trustedProxies`` was removed, you must now configure your
   Web Server to manage ``X-Forwarded-For`` header, see
   :doc:`how to run LL::NG behind a reverse proxy<behindproxyminihowto>`.


.. attention::

    Apache mod_perl has got lot of troubleshooting problems
    since 2.4 version (many segfaults,...), especially when using MPM
    worker or MPM event. That's why LL::NG doesn't use anymore
    ModPerl::Registry: all is now handled by FastCGI (portal and manager),
    except for Apache2 Handler.

    **For Handlers, it is now recommended to migrate to Nginx**, but Apache
    2.4 is still supported with MPM prefork.

Configuration refresh
~~~~~~~~~~~~~~~~~~~~~

Now portal has the same behavior than handlers: it looks to
configuration stored in local cache every 10 minutes. So it has to be
reload like every handler.


.. attention::

    If you want to use reload mechanism on a portal only
    host, you must install a handler in Portal host to be able to refresh
    local cache. Include ``handler-nginx.conf`` or ``handler-apache2.conf``
    for example

LDAP connection
---------------

Now LDAP connections are kept open to improve performances. To allow
that, LL::NG requires an anonymous access to LDAP RootDSE entry to check
connection.

Kerberos or SSL usage
---------------------

-  A new :doc:`Kerberos<authkerberos>` authentication backend has been
   added since 2.0. This module solves many Kerberos integration
   problems *(usage in conjunction with other backends, better error
   display,…)*. However, you can retain the old integration manner
   (using :doc:`Apache authentication module<authapache>`).
-  For :doc:`SSL<authssl>`, a new :doc:`Ajax option<authssl>` can be
   used in the same idea: so SSL can be used in conjunction with other
   backends.

Logs
----

-  **Syslog**: logs are now configured in ``lemonldap-ng.ini`` file
   only. If you use Syslog, you must reconfigure it. See
   :doc:`logs<logs>` for more.
-  **Apache2**: Portal doesn't use anymore Apache2 logger. Logs are
   always written to Apache error.log but Apache "LogLevel" parameter
   has no more effect on it. Portal is now a FastCGI application and
   doesn't use anymore ModPerl. See :doc:`logs<logs>` for more.
-  If you are running behind a proxy, make sure LemonLDAP::NG can
   :doc:`see the original IP address<behindproxyminihowto>`
   of incoming HTTP connections

Security
--------

LLNG portal now embeds the following features:

-  `CSRF <https://en.wikipedia.org/wiki/Cross-site_request_forgery>`__
   protection *(Cross-Site Request Forgery)*: a token is build for each
   form. To disable it, set requireToken to 0 *(portal security
   parameters in the manager)*
-  `Content-Security-Policy <https://en.wikipedia.org/wiki/Content_Security_Policy>`__
   header: portal build dynamically this header. You can modify default
   values in the manager *(Général parameters » Advanced parameters »
   Security » Content-Security-Policy)*

Handlers
--------

-  **Apache only**:

   -  **Apache handler** is now Lemonldap::NG::Handler::ApacheMP2 and
      Menu is now Lemonldap::NG::Handler::ApacheMP2::Menu
   -  because of an Apache behaviour change, PerlHeaderParserHandler
      must no more be used with "reload" URLs *(replaced by
      PerlResponseHandler)*. Any "reload url" that are inside a
      protected vhost must be unprotected in vhost rules *(protection
      has to be done by web server configuration)*.

-  :doc:`CDA<cda>`,
   :doc:`ZimbraPreAuth<applications/zimbra>`,
   :doc:`SecureToken<securetoken>` and
   :doc:`AuthBasic<authbasichandler>` are now
   :doc:`Handler Types<handlerarch>`. So there is no
   more special file to load: you just have to choose "VirtualHost type"
   in the manager/VirtualHosts.
-  :doc:`SSOCookie<ssocookie>`: Since Firefox 60 and
   Chrome 68, "+2d, +5M, 12h and so on..." cookie expiration time
   notation is no more supported. CookieExpiration value is a number of
   seconds until the cookie expires. A zero or negative number will
   expire the cookie immediately.

Rules and headers
-----------------

* hostname() and remote_ip() are no more provided to avoid some name conflicts *replaced by `$ENV{}`)*
* `$ENV{<cgi_variable>}` is now available everywhere: see :doc:`writingrulesand_headers`
* some variable names have changed. See :doc:`variables` document

Opening conditions
------------------

-  Rule and message fields have been swaped. You have to modifiy and
   validate again your access rules.

Supported servers
-----------------

-  Apache-1.3 files are not provided now. You can build them yourself by
   looking at Apache-2 configuration files

Ajax requests
-------------

Before 2.0, an Ajax query launched after session timeout received a 302
code. Now a 401 HTTP code is returned. ``WWW-Authenticate`` header
contains: ``SSO <portal-URL>``

SOAP/REST services
------------------

-  SOAP server activation is now split in 2 parameters
   (configuration/sessions). You must set them else SOAP service will be
   disabled
-  Notifications are now REST/JSON by default. You can force old format
   in the manager. Note that SOAP proxy has changed:
   http://portal/notifications now.
-  If you use "adminSessions" endpoint with "singleSession*" features,
   you must upgrade all portals simultaneously
-  SOAP services can be replaced by new REST services


.. attention::

    \ :doc:`AuthBasic Handler<authbasichandler>` uses now
    REST services instead of SOAP.

CAS
---

CAS authentication module no more use perl CAS client, but our own code.
You can now define several CAS servers in a specific branch in Manager,
like you can define several SAML or OpenID Connect providers.

CAS issuer module has also been improved, you must modify the
configuration of CAS clients to move them from virtual host branch to
CAS client branch.

Developer corner
----------------

APIs
~~~~

Portal has now many REST features and includes an API plugin. See Portal
manpages to learn how to write auth modules, issuers or other features.

Portal overview
~~~~~~~~~~~~~~~

Portal is no more a single CGI object. Since 2.0, It is based on
Plack/PSGI and Mouse modules. Little resume

::

   Portal object
     |
     +-> auth module
     |
     +-> userDB module
     |
     +-> issuer modules
     |
     +-> other plugins (notification,...)

Requests are independent objects based on
Lemonldap::NG::Portal::Main::Request which inherits from
Lemonldap::NG::Common::PSGI::Request which inherits from Plack::Request.
See manpages for more.

Handler
~~~~~~~

Handler libraries have been totally rewritten. If you've made custom
handlers, they must be rewritten, see
:doc:`customhandlers<customhandlers>`.

If you used self protected CGI, you also need to rewrite them, see
:ref:`documentation<selfmadeapplication-perl-auto-protected-cgi>`.
