Upgrade from 2.0.x to 2.0.y
===========================

Please apply general caution as you would with any software: have
backups and a rollback plan ready!


.. danger::

    If you have
    :doc:`installed LemonLDAP::NG from official RPMs<installrpm>`, you may
    run into bug
    `#1757 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues/1757>`__
    and lose your Apache configuration files while updating from
    LemonLDAP::NG 2.0.0 or 2.0.1 to later versions. Please backup your
    ``/etc/httpd/conf.d/z-lemonldap-ng-*.conf`` files before the
    update.


2.0.9
-----

-  | Bad default value to display OIDC Consents tab has been fixed.
   | The default value is ``$_oidcConsents``

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

