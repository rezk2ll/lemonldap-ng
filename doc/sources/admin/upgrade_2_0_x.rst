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

2.0.15
------

New Captcha API
~~~~~~~~~~~~~~~

It is now possible to create your own Captcha modules to replace the one provided by default.

In order for custom Captcha modules to work, you need to modify your custom ``standardform.tpl``, ``mail.tpl`` and ``register.tpl`` template files:

.. code:: diff

    -  <TMPL_IF NAME=CAPTCHA_SRC>
    -    <TMPL_INCLUDE NAME="captcha.tpl">
    +  <TMPL_IF NAME=CAPTCHA_HTML>
    +    <TMPL_VAR NAME=CAPTCHA_HTML>
       </TMPL_IF>

If you are using the default templates from the ``bootstrap`` theme, you don't need to change anything.

Re-send 2FA code
~~~~~~~~~~~~~~~~

The :doc:`mail <mail2f>`, :doc:`external <external2f>` and :doc:`REST <rest2f>` based 2FA types can now re-send the user code if delivery failed for some reason. If you use custom templates, you must update ``ext2fcheck.tpl``

.. code:: diff

    --- a/lemonldap-ng-portal/site/templates/bootstrap/ext2fcheck.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/ext2fcheck.tpl
    @@ -26,6 +26,12 @@
         </button>
       </div>
       <div class="buttons">
    +    <TMPL_IF "RESENDTARGET">
    +    <button type="submit" class="btn btn-primary" formaction="<TMPL_VAR "RESENDTARGET">">
    +      <span class="fa fa-repeat"></span>
    +      <span trspan="resendCode">Re-send code</span>
    +    </button>
    +    </TMPL_IF>
         <a href="<TMPL_VAR NAME="PORTAL_URL">?cancel=1&skin=<TMPL_VAR NAME="SKIN">" class="btn btn-primary" role="button">
           <span class="fa fa-home"></span>
           <span trspan="cancel">Cancel</span>


If you are using the default templates from the ``bootstrap`` theme, you don't need to change anything.

2.0.14
------

Security
~~~~~~~~

* **CVE-2021-40874**: RESTServer pwdConfirm always returns true with Combination + Kerberos (see `issue 2612 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2612>`__)


U2F deprecation in Chrome 98
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Chrome 98 `removed U2F support by default <https://developer.chrome.com/blog/deps-rems-95/#deprecate-u2f-api-cryptotoken>`__. You can enable them back temporarily in ``chrome://flags`` by setting *Enable the U2F Security Key API* to *Enabled* and *Enable a permission prompt for the U2F Security Key API* to *Disabled*

LemonLDAP::NG provides a newer alternative: :doc:`webauthn2f`, which is compatible with U2F security keys. Please read :ref:`migrateu2ftowebauthn` for instructions on how to convert U2F secrets to WebAuthn.

After migration, you will need to disable U2F from the configuration and enable WebAuthn instead, in *General Parameters* » *Second Factors* » *WebAuthn*

Weak encryption used for password-protected SAML keys
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Previous versions of LemonLDAP::NG used a weak encryption algorithm to protect
SAML keys when a password was set during certificate generation.

Run the following command to check if this is your case::

    lemonldap-ng-cli get samlServicePrivateKeySig
    lemonldap-ng-cli get samlServicePrivateKeyEnc

If the output of either command starts with ``BEGIN ENCRYPTED PRIVATE KEY``,
then it probably means you generated your keys using the vulnerable manager
code.

In this case, you can convert your existing keys to a stronger encryption using
the following command ::

    # Extract your existing keys. If samlServicePrivateKeyEnc is empty, you can
    # skip it entirely
    lemonldap-ng-cli get samlServicePrivateKeySig | \
        sed 's/samlServicePrivateKeySig = //' > saml-sig.pem
    lemonldap-ng-cli get samlServicePrivateKeyEnc | \
        sed 's/samlServicePrivateKeyEnc = //' > saml-enc.pem

    # Re-encrypt the private key, using the same passphrase
    openssl pkey -in saml-sig.pem -aes256 -out saml-sig-aes.pem
    openssl pkey -in saml-enc.pem -aes256 -out saml-enc-aes.pem

    #Or, if you are using OpenSSL 3+
    openssl pkey -provider legacy -provider default -in saml-sig.pem \
        -aes256 -out saml-sig-aes.pem
    openssl pkey -provider legacy -provider default -in saml-enc.pem \
        -aes256 -out saml-enc-aes.pem

Then, simply reimport your keys ::

    lemonldap-ng-cli set samlServicePrivateKeySig "$(cat saml-sig-aes.pem)"
    lemonldap-ng-cli set samlServicePrivateKeyEnc "$(cat saml-enc-aes.pem)"

If is recommended to keep the same password as before, if not, adjust the
``samlServicePrivateKeySigPwd`` and ``samlServicePrivateKeyEncPwd`` variables as well.

This operation is transparent and does not require any change to your existing
SAML configuration or SAML applications

LemonLDAP::NG version is returned by the CheckState plugin
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you use the `/checkstate` URL to monitor LemonLDAP::NG, you may notice a slight change in the output format:

*2.0.13* :

```
{"result":1}
```

*2.0.14* :

```
{"result":1,"version":"2.0.14"}
```

Depending on your load balancer or monitoring configuration, this can cause false negatives.

This plugin is disabled by default, and you may use a shared secret to hide this information to regular users and bots, please check the :doc:`checkstate` documentation for more information.

Empty scopes now rejected in OAuth2.0 grants
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Previously, it was possible to be granted an empty scope, or an automatic
``openid`` scope when doing :ref:`OAuth2.0 Password Grant
<resource-owner-password-grant>` or :ref:`Client Credentials Grant
<client-credentials-grant>`.

Starting with *2.0.14*, empty scopes are no longer allowed (:rfc:`6749#section-3.3`).
You need to either add a `scope` parameter to your request, or define a default
scope in your Relying Party's :ref:`Scope Rules <oidcscoperules>`.


Portal templates changes
~~~~~~~~~~~~~~~~~~~~~~~~

If you defined the "Register page URL" or the password "Reset page URL" to an external application, you need to fix the ``standardform.tpl`` template by applying the following patch:

.. code:: diff

    diff --git a/lemonldap-ng-portal/site/templates/bootstrap/standardform.tpl b/lemonldap-ng-portal/site/templates/bootstrap/standardform.tpl
    index 3a6256e59..d5192f0ce 100644
    --- a/lemonldap-ng-portal/site/templates/bootstrap/standardform.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/standardform.tpl
    @@ -48,14 +48,14 @@

     <div class="actions">
       <TMPL_IF NAME="DISPLAY_RESETPASSWORD">
    -  <a class="btn btn-secondary" href="<TMPL_VAR NAME="MAIL_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>">
    +  <a class="btn btn-secondary" href="<TMPL_VAR NAME="MAIL_URL"><TMPL_UNLESS NAME="MAIL_URL_EXTERNAL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF></TMPL_UNLESS>">
         <span class="fa fa-info-circle"></span>
         <span trspan="resetPwd">Reset my password</span>
       </a>
       </TMPL_IF>

       <TMPL_IF NAME="DISPLAY_UPDATECERTIF">
    -     <a class="btn btn-secondary" href="<TMPL_VAR NAME="MAILCERTIF_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>">
    +     <a class="btn btn-secondary" href="<TMPL_VAR NAME="MAILCERTIF_URL"><TMPL_UNLESS NAME="MAILCERTIF_URL_EXTERNAL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF></TMPL_UNLESS>">
             <span class="fa fa-refresh"></span>
             <span trspan="certificateReset">Reset my certificate</span>
          </a>
    @@ -69,7 +69,7 @@
       </TMPL_IF>

       <TMPL_IF NAME="DISPLAY_REGISTER">
    -    <a class="btn btn-secondary" href="<TMPL_VAR NAME="REGISTER_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>">
    +    <a class="btn btn-secondary" href="<TMPL_VAR NAME="REGISTER_URL"><TMPL_UNLESS NAME="REGISTER_URL_EXTERNAL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF></TMPL_UNLESS>">
           <span class="fa fa-plus-circle"></span>
           <span trspan="createAccount">Create an account</span>
         </a>



Manager API
~~~~~~~~~~~

The service parameter set in a request to create or update a CAS application must now be an array, and no more a string.

Changes impacting plugin developpers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* If you are using Custom authentication modules, userDB modules or password
  modules, ``$portal->loadedPlugins`` no longer contains a key with the name of
  your module. You should use ``$portal->_authentication``, ``$portal->_userDB``,
  or ``$portal->_passwordDB`` instead to get your module instance.


2.0.13
------

Portal templates changes
~~~~~~~~~~~~~~~~~~~~~~~~

Some ``autocomplete`` attributes have been added to improve accessibility in the following files: ``checkdevops.tpl``, ``checkuser.tpl``, ``register.tpl``, ``ext2fcheck.tpl``, ``totp2fcheck.tpl``, ``utotp2fcheck.tpl``.


2.0.12
------

Security
~~~~~~~~

* **CVE-2021-35473**: Access token lifetime is not verified with OAuth2 Handler (see `issue 2549 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2549>`__)
* **CVE-2021-35472**: Session cache corruption can lead to authorization bypass or spoofing (see `issue 2539 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2539>`__)
* 2FA bypass with sfOnlyUpgrade and totp2fDisplayExistingSecret (see `issue 2543 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2543>`__)
* Incorrect regexp construction in isTrustedUrl lets attacker steal session on CDA application (see `issue 2535 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2535>`__)
* XSS on register form (see `issue 2495 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2495>`__)
* Wildcard in virtualhost allows being redirected to untrusted domains (see `issue 2477 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2477>`__)

Portal templates changes
~~~~~~~~~~~~~~~~~~~~~~~~

Email templates
^^^^^^^^^^^^^^^

If you customized the HTML email templates, you must update them to use HTML::Template variables (this was changed to fix XSS injections).

In the following files: ``mail_2fcode.tpl`` ``mail_certificateReset.tpl`` ``mail_footer.tpl`` ``mail_password.tpl`` ``mail_register_done.tpl`` ``mail_certificateConfirm.tpl`` ``mail_confirm.tpl`` ``mail_header.tpl`` ``mail_register_confirm.tpl``

Replace the following variables:


.. list-table::
   :header-rows: 1

   * - Old syntax
     - New syntax
   * - ``$code``
     - ``<TMPL_VAR NAME="code" ESCAPE=HTML>``
   * - ``$url``
     - ``<TMPL_VAR NAME="url" ESCAPE=HTML>``
   * - ``$login``
     - ``<TMPL_VAR NAME="login" ESCAPE=HTML>``
   * - ``$password``
     - ``<TMPL_VAR NAME="password" ESCAPE=HTML>``
   * - ``$firstname``
     - ``<TMPL_VAR NAME="firstname" ESCAPE=HTML>``
   * - ``$lastname``
     - ``<TMPL_VAR NAME="lastname" ESCAPE=HTML>``

Replace all other variables such as ``$cn`` by ``<TMPL_VAR NAME="session_cn" ESCAPE=HTML>``.

Login form
^^^^^^^^^^
To benefit from the new feature allowing to show password on login form, adapt ``standardform.tpl`` (see `changes <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/commit/bdeb1e70d98ddc89316b0912d9d5ee6d11d0bee5#fbbcec1fdc36cc042eeaa83274a32ef2231fe977_23_23>`__)

To disable password store in browser when changing password (this was already possible for login form), adapt ``password.tpl`` (see `changes <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/commit/466b6a3241fff5013d27b3dd22982e5e26ed7dfb#0ae060b3d1e289f08f510c268ed72de5dcafe425_36_35>`__)

To fix placeholder display in password field when password store is disabled in browser, adapt ``password.tpl`` (see `changes <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/commit/547d80985290495d33ed72a388e9ddf482980354#fbbcec1fdc36cc042eeaa83274a32ef2231fe977_21_20>`__)

TOTP
^^^^
See also `Simplification of TOTP options`_ below.

FindUser, CheckDevOps templates
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Some changes have been made to include new plugins (FindUser and CheckDevOps), you need to report them only if you have a custom theme and you want to use these plugins

Client Credential sessions missing expiration time
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you started using Client Credential grants in 2.0.11, you may have encountered
`issue 2481 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2481>`__.

Because of this bug, the created sessions may never be purged by the ``purgeCentralCache`` script.

In order to detect these sessions, you can run the following command:

::

   lemonldap-ng-sessions  search --where _session_kind=SSO --select _session_id --select _utime | \
   jq -r  '. | map(select(._utime == null)) | map(._session_id) | join ("\n")'

This will output a list of SSO sessions with no expiration time.

Review them manually using ::

   lemonldap-ng-sessions get <session_id>

You can then remove them with ::

   lemonldap-ng-sessions delete <session_id> <session_id> <etc.>

Brute-force protection plugin may cause duplicate persistent sessions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Because of `bug #2482 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2482>`__ , some users may notice that the persistent session database is filling with duplicate sessions. Some examples include:

* An uppercase version of the regular persistent session (dwho vs DWHO)
* An unqualified version (dwho vs dwho@idp.com)

This bug was fixed in 2.0.12, but administrators are advised to clean up their persistent session database to remove any duplicate persistent sessions remaining after the upgrade.

OpenID Connect check session iframe
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The OIDC check session iframe is not working, it has been removed from OIDC configuration metadata. It should not impact any installation as this feature was already broken.

Simplification of TOTP options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following options have been removed from TOTP configuration:

* Display existing secret (``totp2fDisplayExistingSecret``)
* Change existing secret (``totp2fUserCanChangeKey``)

As a consequence, users who are *not* using the default ``bootstrap`` skin may need to ajust their ``totp2fregister.tpl`` template:

* Move ``#divToHide`` from the ``.col-md-6`` div to the ``.card`` div
* Change::

  <pre id="serialized"></pre>

* to::

  <br/><tt id="secret"></tt>

* Remove the ``#changekey`` button

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
   :rfc:`6750#section-3`.

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

