Upgrade from 2.0.x to 2.0.y
===========================


Please apply general caution as you would with any software: have
backups and a rollback plan ready!

Known issues
-------------

Upgrading from 2.0.0 or 2.0.1 to later versions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you have :doc:`installed LemonLDAP::NG from official RPMs<installrpm>`, you
may run into bug `#1757
<https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues/1757>`__ and lose your
Apache configuration files while updating from LemonLDAP::NG 2.0.0 or 2.0.1 to
later versions. Please backup your ``/etc/httpd/conf.d/z-lemonldap-ng-*.conf``
files before the update.


.. Adjust for every new version that has known, unreleased bugs

Known regressions in the latest released version
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

None

2.0.11
------

Portal templates changes
~~~~~~~~~~~~~~~~~~~~~~~~

If you created your own skin and modified some template files, you may need to update them.
No change is required if you are using the default ``bootstrap`` theme.

A new plugin has been introduced, in beta version: :doc:`FindUser <finduser>`. It requires a modification of ``login.tpl`` to include ``finduser.tpl``.

2.0.10
------

Security
~~~~~~~~

A vulnerability affecting LemonLDAP::NG installations has been found out when ALL following criteria apply:

* Your handler server uses Nginx
* Your virtual host configuration contains per-URL ``skip`` or ``unprotect`` access rule

In this situation, you have to update your LUA configuration file like ``/etc/nginx/nginx-lua-headers.conf``. See also `issue 2434 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2434>`__.

Other minor security fixes:

* It is now possible to hide sessions identifier in Manager (parameter ``displaySessionId``). See also `issue 2350 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2350>`__.
* Second factor management by end user now requires safer conditions. See also `issue 2332 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2332>`__, `issue 2337 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2337>`__ and `issue 2338 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2338>`__.

Main changes
~~~~~~~~~~~~

- New dependency: IO::Socket::Timeout
- TOTP check tolerates forward AND backward clock drift (totp2fRange)
- Avoid assignment in expressions option is disabled by default
- RHEL/CentOS SELinux users should install the new ``lemonldap-ng-selinux`` package to fix `an issue with the new default cache directory <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2401>`__
- If you use :doc:`applications/mattermost` with OpenID Connect, you need to set the ``id`` claim type to *Integer*
- BruteForceProtection plugin now prevents authentication on backend if an account is locked
- In the Manager API, postLogoutRedirectUri is now `returned and consumed as an array <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2347>`__
- We fixed a bug that caused SAML sessions to be created and never deleted, you should check your session databases for sessions that have ``"_session_kind": "ISAML"`` but no ``_utime``. You can safely delete SAML sessions with no ``_utime`` during the upgrade.

Portal templates changes
~~~~~~~~~~~~~~~~~~~~~~~~

If you created your own skin and modified some template files, you may need to update them, see below if they have been modified.

No change is required if you are using the default ``bootstrap`` theme.

2FA manager
^^^^^^^^^^^

In ``2fregisters.tpl`` you need to add the ``remove2f`` class to the button that triggers second factor removal:

.. code-block:: diff

   - <span device='<TMPL_VAR NAME="type">' epoch='<TMPL_VAR NAME="epoch">' class="btn btn-danger" role="button">
   + <span device='<TMPL_VAR NAME="type">' epoch='<TMPL_VAR NAME="epoch">' class="btn btn-danger remove2f" role="button">

Or, better yet, integrate the changes in ``2fregisters.tpl`` and ``skin.min.js`` into your custom theme to benefit from the `new 2F removal confirmation dialog <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2438>`__

Checkboxes
^^^^^^^^^^

A CSS change has been done in ``styles.css`` to avoid checkbox labels overflow. See `issue 2301 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2301>`__.

The ``form-check-input`` class is missing in ``register.tpl`` and ``notifinclude.tpl``. See `issue 2374 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2374>`__.

Password checker
^^^^^^^^^^^^^^^^

Input id values have been modified in ``mail.tpl`` to work with password checker. See `issue 2355 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2355>`__.

Tables caption
^^^^^^^^^^^^^^

Tables captions have been added in ``sessionArray.tpl``. See `issue 2356 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2356>`__.

Stay connected
^^^^^^^^^^^^^^

A small change is required in ``checklogins.tpl`` for `issue 2365 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2365>`__.

Other changes needed in ``2fchoice.tpl``, ``ext2check.tpl``, ``totp2fcheck.tpl``, ``u2fcheck.tpl`` and ``utotp2fcheck.tpl`` for `issue 2366 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2366>`__.

Mails
^^^^^

The HTML ``alt`` attribute has been added on ``img`` in all ``mail_*.tpl``. See `issue 2422 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2422>`__.

2.0.9
-----

-  Bad default value to display OIDC Consents tab has been fixed.
   The default value is now:  ``$_oidcConsents && $_oidcConsents =~ /\w+/``
-  Some user log messages have been modified, check :doc:`logs documentation <logs>`
   (see also `#2244 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues/2244>`__)
-  SAML SOAP calls are now using ``text/xml`` instead of ``application/xml`` as the MIME Content Type, as required by `the SOAP standard <https://www.w3.org/TR/2000/NOTE-SOAP-20000508/#_Toc478383526>`__
-  Incremental lock times values can now be set in BruteForceProtection plugin through Manager.
   It MUST be a list of comma separated values. Default values are ``5, 15, 60, 300, 600``
-  This version is not compatible with :doc:`applications/mattermost`

Cookie issues with Chrome
~~~~~~~~~~~~~~~~~~~~~~~~~

This release fixes several issues related to the change in SameSite cookie
policy for Google Chrome users. The new default value of the SameSite
configuration parameter will set SameSite to ``Lax`` unless you are using SAML,
in which case it will be set to ``None``.

This means that from now on, any LemonLDAP::NG installation using SAML must be
served over HTTPS, as SameSite ``None`` value requires the ``Secure`` flag in cookie.

Change in default cache directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The default config/session cache directory has been moved from ``/tmp`` to
``/var/cache/lemonldap-ng`` in order to avoid `issues with cache purges
<https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2254>`__  when using
Systemd. This change is only applied to new installations.  If your
installation is experiencing cache purge issues, you need to manually change
your existing ``localSessionStorageOptions/cache_root`` parameter from ``/tmp``
to ``/var/cache/lemonldap-ng``. Be sure to create this directory on your
file system before modifying your configuration.

If you are using SELinux, you also need to run the following commands ::

   semanage fcontext --add -t httpd_cache_t -f a '/var/cache/lemonldap-ng(/.*)?'
   restorecon -R /var/cache/lemonldap-ng/

Required changes in NGINX handler rules (CVE-2020-24660)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We discovered a vulnerability that affects LemonLDAP::NG installations when ALL of the following criteria apply:

* You are using the :doc:`LemonLDAP::NG Handler<configvhost>` to protect applications
* Your handler server uses Nginx
* Your virtual host configuration contains per-URL access rules based on
  regular expressions in addition to the built-in *default* access rule.

.. note::

   You are safe from this vulnerability if your virtualhost only uses a regexp-based rule to trigger logout

If you are in this situation, you need to modify *all* your handler-protected
virtualhosts by making the following change:

* Replace ``fastcgi_param X_ORIGINAL_URI $request_uri`` by ``fastcgi_param X_ORIGINAL_URI $original_uri`` if you are using FastCGI
* Replace ``uwsgi_param X_ORIGINAL_URI $request_uri`` by ``uwsgi_param X_ORIGINAL_URI $original_uri`` if you are using uWSGI
* Right after ``auth_request /lmauth;``, add the following line ::

   set $original_uri $uri$is_args$args;

You can check the :doc:`configvhost` page for more information

LDAP certificate validation (CVE-2020-16093)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LDAP server certificates were previously not verified by default when using secure transports (LDAPS or TLS), see `CVE-2020-16093 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2250>`__. Starting from this release, certificate validation is now enabled by default, including on existing installations.

If you have configured your CA certificates incorrectly, LemonLDAP::NG will now start complaining about invalid certificates. You may temporarily disable it again with the following command ::

   /your/path/to/lemonldap-ng-cli set ldapVerify none

If you use LDAP as a configuration storage, and want to temporarily disable certificate validation, you must make the following addition to `/etc/lemonldap-ng/lemonldap-ng.ini` ::

   [configuration]
   ...
   ldapVerify = none

If you use LDAP as a session backend, you are strongly encouraged to also upgrade corresponding ``Apache::Session`` modules (``Apache::Session::LDAP`` or ``Apache::Session::Browseable``). After this upgrade, if you want to temporarily disable certificate validation, you can add the following parameter to the list of Apache::Session module options:

* key: ``ldapVerify``
* value: ``none``

Please note that it is HIGHLY recommended to set certificate validation to `require` when contacting LDAP servers over a secure transport to avoid man-in-the-middle attacks.

2.0.8
-----

-  New dependency: Perl module Time::Fake is now required to run unit
   test and build packages, but should not be mandatory to run the
   software.
-  Nginx configuration: some changes are required to allow IPv6, see
   `#2152 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues/2152>`__
-  Option ``singleSessionUserByIP`` was removed, see
   `#2159 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues/2159>`__
-  A memory leak was found in perl-fcgi with Perl < 5.18, a workaround
   is possible with Apache and llng-fastcgi-server, see
   `#1314 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues/1314>`__

   -  With Apache: set ``FcgidMaxRequestsPerProcess 500`` in portal
      virtual host
   -  With llng-fastcgi-server: set ``PM_MAX_REQUESTS=500`` in
      llng-fastcgi-server service configuration

-  Cookie ``SameSite`` value: to avoid problems with recent browsers,
   SAML POST binding, LLNG cookies are now tagged as
   "**SameSite=None**". You can change this value using manager,
   "**SameSite=Lax**" is best for installations without federations.
   **Important note**: if you're using an unsecured connection *(http://
   instead of https://)*, "SameSite=None" will be ignored by browsers
   and users that already have a valid session might be prompted to
   login again.
-  OAuth2.0 Handler: a VHost protected by the OAuth2.0 handler will now
   return a 401 when called without an Access Token, instead of
   redirecting to the portal, as specified by
   `RFC6750 <https://tools.ietf.org/html/rfc6750>`__

-  If you encounter the following issue:

::

   AH01630: client denied by server configuration: /usr/share/lemonldap-ng/manager/api/api.fcgi

when trying to access the portal. It probably comes from incorrect
Apache configuration. Remove the (optional and disabled by default)
manager API config:

::

   rm /etc/httpd/conf.d/z-lemonldap-ng-api.conf && systemctl reload httpd

2.0.7
-----

-  Security:

   -  `#2040 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues/2040>`__:
      Configuration of a redirection URI for an OpenID Connect Relying
      Party is now mandatory, as defined in the specifications. If you
      save your configuration, you will have an error if some of your RP
      don't have a redirect URI configured.
   -  `#1943 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues/1943>`__
      /
      `CVE-2019-19791 <https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-19791>`__:
      along with the patch provided in 2.0.7 in
      ``Lemonldap/NG/Common/PSGI/Request.pm``, Apache rewrite rule must
      be updated to avoid an unprotected access to REST services:

::

   portal-apache2.conf

.. code-block:: apache

       RewriteCond "%{REQUEST_URI}" "!^/(?:(?:static|javascript|favicon).*|.*\.fcgi(?:/.*)?)$"
       RewriteRule "^/(.+)$" "/index.fcgi/$1" [PT]

::

   manager-apache2.conf

.. code-block:: apache

       RewriteCond "%{REQUEST_URI}" "!^/(?:static|doc|lib|javascript|favicon).*"
       RewriteRule "^/(.+)$" "/manager.fcgi/$1" [PT]

-  Other:

   -  Option ``checkTime`` was enabled by default in
      ``lemonldap-ng.ini``, this let the portal check the configuration
      immediately instead of waiting for configuration cache expiration.
      You can keep this option enabled unless you need strong
      :doc:`performances<performances>`.

-  Removed parameters:

   -  ``samlIdPResolveCookie``

2.0.6
-----

-  Option was added to display generate password box in
   :doc:`password reset by mail plugin<resetpassword>`. If you use this
   feature, you must enable this option, which is disabled by default.
-  If you use the default \_whatToTrace macro and a case insensitive
   authentication backend, then a user can generate several persistent
   sessions for the same login (see `issue
   1869 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues/1869>`__).
   This can lead to a security bug if you enabled 2FA, which rely on
   data stored in the persistent session. To fix this, either choose a
   unique attribute for \_whatToTrace, either force lower case in your
   macro:

.. code-block:: perl

   $_auth eq 'SAML' ? lc($_user.'@'.$_idpConfKey) : $_auth eq 'OpenIDConnect' ? lc($_user.'@'.$_oidc_OP) : lc($_user)

-  On CentOS 7 / RHEL 7, a system upgrade breaks ImageMagick, which is
   used to display captchas (see
   `#1951 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues/1951>`__).
   To fix this, you can run the following commands:

::

   yum install -y urw-base35-fonts-legacy
   sed 's,/usr/share/fonts/default/Type1/,/usr/share/X11/fonts/urw-fonts/,g' -i /etc/ImageMagick/type-ghostscript.xml

2.0.5
-----

-  The Text::Unidecode perl module becomes a requirement *(it will be
   automatically installed if you upgrade from from the deb or RPM
   repositories)*
-  CAS logout starts validating the service= parameter, but only if you
   use the CAS Access control policy. The URL sent in the service=
   parameter will be checked against
   :ref:`known CAS applications<idpcas-configuring-cas-applications>`,
   Virtual Hosts, and
   :ref:`trusted domains<security-configure-security-settings>`. Add
   your target domain to trusted domains if you suddenly start having
   "Invalid URL" messages on logout
-  Improvements in cryptographic functions: to take advantage of them,
   **you must change the encryption key** of LemonLDAP::NG (see
   :ref:`CLI example<cli-examples-encryption-key>`).
-  Debian packaging: FastCGI / uWsgi servers require llng-lmlog.conf and
   llng-lua-headers.conf. Those configuration files are now provided by
   lemonldap-ng-handler package and installed in /etc/nginx/snippets
   directory.

