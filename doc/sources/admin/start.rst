Documentation for LemonLDAP::NG 2.0
===================================

.. image:: logos/logo_llng_600px.png
   :alt: LL::NG logo
   :align: center
   :target: https://www.lemonldap-ng.org

.. toctree::
   
   Documentation index<documentation>

.. toctree::
   :caption: Getting started
   :hidden:

   index_presentation
   index_installation

.. toctree::
   :caption: Configuration
   :hidden:

   index_firststeps
   index_portal
   index_handler
   index_databases

.. toctree::
   :caption: Application protection
   :hidden:

   writingrulesand_headers
   variables
   selfmadeapplication
   formreplay
   customhandlers
   webserviceprotection
   websocketapplications
   applications/authbasic
   applications


.. toctree::
   :caption: Advanced topics
   :hidden:

   index_advanced
   index_minihowtos
   index_exploitation
   index_dev


Presentation
------------

-  :doc:`Presentation<presentation>`
-  :doc:`Main features<features>`
-  :doc:`Quick start tutorial<quickstart>`
-  :doc:`Choose a platform<platformsoverview>`

Installation
------------

Before installation
~~~~~~~~~~~~~~~~~~~

|image0|

-  :doc:`Prerequisites and dependencies<prereq>`
-  :doc:`Upgrade notes<upgrade>`

.. _installation-1:

Installation
~~~~~~~~~~~~

|image1|

-  :doc:`Installation from the tarball<installtarball>`
-  :doc:`Installation on Debian/Ubuntu with packages<installdeb>`
-  :doc:`Installation on RHEL/CentOS with packages<installrpm>`
-  :doc:`Installation on Suse Linux Enterprise Server with packages<installsles>`
-  :doc:`Run in LemonLDAP::NG in Docker<docker>`
-  :doc:`Node.js handler<nodehandler>` |new|

After installation
~~~~~~~~~~~~~~~~~~

|image3|

-  :doc:`Deploy Nginx configuration<confignginx>` *(recommended
   configuration)*
-  :doc:`Deploy Apache configuration<configapache>`
-  :doc:`Deploy LemonLDAP::NG on Plack servers family<configplack>`
   *(Twiggy, Starman, Corona,...)* |new|


.. _start-configuration:

Configuration
-------------

First steps
~~~~~~~~~~~

|image5|

-  :doc:`Configuration overview<configlocation>`
-  :doc:`Configure Single Sign On cookie and portal URL<ssocookie>`
-  :doc:`Parameter redirections<redirections>`
-  :doc:`Set exported variables<exportedvars>`
-  :doc:`Manage virtual hosts<configvhost>`
-  :doc:`Configure sessions specificities<sessions>`

Portal
~~~~~~

|image6|

-  :doc:`Presentation<portal>`
-  :doc:`Portal customization<portalcustom>`
-  :doc:`Portal menu<portalmenu>`
-  :doc:`REST/SOAP servers<portalservers>`
-  :doc:`Captcha<captcha>`
-  :doc:`Public pages<public_pages>`


.. _start-authentication-users-and-password-databases:

Authentication, users and password databases
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

|image7|

==================================================================== =============================================== ======== ========
Official Backends                                                    Authentication                                  Users    Password
==================================================================== =============================================== ======== ========
:doc:`Active Directory<authad>`                                      ✔                                               ✔        ✔
:doc:`Apache (Basic, NTLM, OTP, ...)<authapache>`                    ✔
:doc:`CAS<authcas>`                                                  ✔                                               |new|
:doc:`SQL Databases<authdbi>`                                        ✔                                               ✔        ✔
:doc:`Demonstration<authdemo>`                                       ✔                                               ✔        ✔
:doc:`Facebook<authfacebook>`                                        ✔                                               ✔
:doc:`GitHub<authgithub>` |new|  [1]_                                ✔
:doc:`GPG<authgpg>` |new|  [2]_                                      ✔
:doc:`Kerberos<authkerberos>` |new|                                  ✔
:doc:`LDAP<authldap>`                                                ✔                                               ✔        ✔
:doc:`LinkedIn<authlinkedin>`                                        ✔
:doc:`Null<authnull>`                                                ✔                                               ✔        ✔
:doc:`OpenID Connect<authopenidconnect>`                             ✔                                               ✔
:doc:`PAM<authpam>` |new|                                            ✔
:doc:`Proxy LL::NG<authproxy>`                                       ✔                                               ✔
:doc:`Radius<authradius>`                                            ✔
:doc:`REST<authrest>` |new|                                          ✔                                               ✔        ✔
:doc:`SAML 2.0 / Shibboleth<authsaml>`                               ✔                                               ✔
:doc:`Slave<authslave>`                                              ✔                                               ✔
:doc:`SSL<authssl>`                                                  ✔
:doc:`Twitter<authtwitter>`                                          ✔
:doc:`WebID<authwebid>`                                              ✔                                               ✔
:doc:`Yubico OTP<authyubikey>` |deprecated|                          *Replaced by* :doc:`yubikey2f`
:doc:`Custom modules<authcustom>` |new|                              ✔                                               ✔        ✔
==================================================================== =============================================== ======== ========

==================================================================== ================================================= ======== =========================
Combo Backends                                                       Authentication                                    Users    Password
==================================================================== ================================================= ======== =========================
:doc:`Choice by users<authchoice>`                                   ✔                                                 ✔        ✔
:doc:`Combination of auth schemes<authcombination>` |new|            ✔                                                 ✔        ✔ (since *2.0.10*)
:doc:`Multiple backends stack<authmulti>` |deprecated|               *Replaced by* :doc:`Combination<authcombination>`
==================================================================== ================================================= ======== =========================

==================================================================== =============================================== ======== ========
Obsolete Backends                                                    Authentication                                  Users    Password
==================================================================== =============================================== ======== ========
:doc:`OpenID<authopenid>`                                            ✔                                               ✔
:doc:`Remote LL::NG<authremote>`                                     ✔                                               ✔
==================================================================== =============================================== ======== ========

==================================================================== ============== =================
Second factor (:doc:`documentation<secondfactor>`)                   Authentication Self-registration
==================================================================== ============== =================
:doc:`TOTP<totp2f>` *(Google Authenticator,...)* |new|               ✔              ✔
:doc:`WebAuthn<webauthn2f>` |new|                                    ✔              ✔
:doc:`E-mail Second Factor<mail2f>` |new|                            ✔              [18]_
:doc:`Yubico OTP<yubikey2f>` |new|                                   ✔              ✔
:doc:`External Second Factor<external2f>` *(OTP, SMS,...)* |new|     ✔              [18]_
:doc:`REST Second Factor<rest2f>` |new|                              ✔              [18]_
:doc:`Radius Second Factor<radius2f>` |new|  [3]_                    ✔
:doc:`Password as second factor<password2f>` |new| [4]_              ✔              ✔
:doc:`TOTP-or-U2F<utotp2f>` |deprecated|                             ✔              ✔
:doc:`U2F<u2f>` |deprecated|                                         ✔              ✔
==================================================================== ============== =================

.. versionadded:: 2.0.6
    See :doc:`Additional second factors<sfextra>` for configuring several multiple
    REST, external or e-mail based second factors with different parameters


==================================================================== ==============
Auth addons                                                          Authentication
==================================================================== ==============
:doc:`Auto Signin<autosignin>` |new|                                 ✔
==================================================================== ==============


.. _start-identity-provider:

Identity provider
^^^^^^^^^^^^^^^^^


.. tip::



    -  All identity provider protocols can be used simultaneously
    -  LemonLDAP::NG can be used as a
       :doc:`proxy between those protocols<federationproxy>`



|image26|

===================================================================== ================ =================
Protocol                                                              Service Provider Identity Provider
===================================================================== ================ =================
:doc:`CAS 1.0 / 2.0 / 3.0<idpcas>`                                    ✔                ✔
:doc:`SAML 2.0 / Shibboleth<idpsaml>`                                 ✔                ✔
:doc:`OpenID 2.0<idpopenid>` *(obsolete)*                             ✔                ✔
:doc:`OpenID Connect<idpopenidconnect>`                               ✔                ✔
:doc:`Get parameters provider<issuerdbget>` *(for poor applications)*                  ✔
===================================================================== ================ =================


.. tip::

    * Issuers timeout : Delay for issuers to submit their authentication requests
    * To avoid a bad/expired token and lose redirection to the SP protected
      application after authentication if IdP URLs are served by different load
      balancers, you can force Issuer tokens to be stored into Global Storage
      by editing ``lemonldap-ng.ini`` in section [portal]:

    .. code:: ini

       [portal]
       forceGlobalStorageIssuerOTT = 1


Attacks and Protection
^^^^^^^^^^^^^^^^^^^^^^


.. tip::

    To learn or find out more about security, go to
    :doc:`Security<security>` documentation

|image27|

====================================================== =============== ============================
Attack                                                 LLNG protection System Integrator protection
====================================================== =============== ============================
:doc:`Brute Force<bruteforceprotection>`               ✔               ✔
:ref:`Page Content<security-portal>`                   ✔
:ref:`CSRF<security-portal>`                           ✔
Deny of Service                                                        ✔
:ref:`Invisible iFrame<portalcustom-other-parameters>` ✔               ✔
Man-in-the-Middle                                                      ✔
Software Exploit                                                       ✔
:ref:`SSO by-passing<security-reverseproxies>`                         ✔
:doc:`XSS<safejail>`                                   ✔
====================================================== =============== ============================

Plugins
^^^^^^^

|image28|

==================================================================== ============================================================================================================================================
Name                                                                 Description
==================================================================== ============================================================================================================================================
:doc:`Auto Signin<autosignin>` |new|                                 Auto Signin Addon
:doc:`Brute Force protection<bruteforceprotection>` |new|            User must wait to log in after some failed login attempts
:doc:`CDA<cda>`                                                      Cross Domain Authentication
:doc:`Check DevOps<checkdevops>` [5]_ |new|                          Check DevOps handler file plugin
:doc:`Check state<checkstate>` |new|                                 Check state plugin (test page)
:doc:`Check user<checkuser>`  [6]_ |new|                             Check access rights, transmitted headers and session attibutes for a specific user and URL
:doc:`Configuration viewer<viewer>` |new|                            Edit WebSSO configuration in Read Only mode
:doc:`Context switching<contextswitching>`  [7]_\ |new|              Switch context other users
:doc:`CrowdSec<crowdsec>`  [8]_\ |new|                               CrowdSec bouncer
:doc:`Custom<plugincustom>`                                          Write a custom plugin
:doc:`Decrypt value<decryptvalue>`  [9]_\                            Decrypt ciphered values
:doc:`Display login history<loginhistory>`                           Display Success/Fails logins
:doc:`Force Authentication<forcereauthn>`                            Force authentication to access to Portal
:doc:`Global Logout<globallogout>`  [10]_                            Suggest to close all opened sessions at logout
:doc:`Grant Sessions<grantsession>`                                  Rules to apply before allowing a user to open a session
:doc:`Impersonation<impersonation>`  [11]_\ |new|                    Allow users to use another identity
:doc:`Find user<finduser>`  [12]_\ |new|                             Search for user account
:doc:`NewLocationWarning<newlocationwarning>`  [13]_\ |beta|         Send an email when user sign in from a new location 
:doc:`Notifications system<notifications>`                           Display a message during log in process 
:doc:`Portal Status<status>`                                         Experimental portal status page
:doc:`Public pages<public_pages>`                                    Enable public pages system
:doc:`Refresh session API<refreshsessionapi>`  [14]_                 Plugin that provides an API to refresh a user session
:doc:`Reset password by mail<resetpassword>`                         Send a mail to reset its password
:doc:`Reset certificate by mail<resetcertificate>`  [15]_\ |new|     Allow users to reset their certificate
:doc:`REST services<restservices>` |new|                             REST server for :doc:`Proxy<authproxy>`
:doc:`SOAP services<soapservices>` |deprecated|                      SOAP server for :doc:`Proxy<authproxy>`
:doc:`Stay connected<stayconnected>` |new|                           Enable persistent connection on same browser
:doc:`Remember auth choice<rememberauthchoice>` |new|                Remember user last authentication choice
Upgrade session |new|                                                This plugin explains to an already authenticated user that a higher authentication level is required to access the URL instead of reject him
==================================================================== ============================================================================================================================================

Handlers
~~~~~~~~

|image41|

Handlers are software control agents to be installed on your web servers
*(Nginx, Apache, PSGI like Plack based servers or Node.js)*.

==================================================================== ========== ============================================================= =========================================== ================================================================================== =============================================== ======================================================================================================================
Handler type                                                         Apache     LLNG FastCGI/uWSGI server (Nginx, or :doc:`SSOaaS<ssoaas>`)   `Plack servers <https://plackperl.org>`__   Node.js  ( `express apps <http://expressjs.com/>`__\  or :doc:`SSOaaS<ssoaas>`)    :doc:`Self protected apps<selfmadeapplication>`   Comment
==================================================================== ========== ============================================================= =========================================== ================================================================================== =============================================== ======================================================================================================================
Main *(default handler)*                                             ✔          ✔                                                             ✔                                           :doc:`Partial<nodehandler>` ** [16]_ **                                            ✔
:doc:`AuthBasic<authbasichandler>`                                   ✔          ✔                                                             ✔                                                                                                                              ✔                                               Designed for some server-to-server applications
:doc:`CDA<cda>`                                                      ✔          ✔                                                             ✔                                                                                                                              ✔                                               For Cross Domain Authentication
:doc:`DevOps<devopshandler>`  (:doc:`SSOaaS<ssoaas>`)  |new|         ✔          ✔                                                             ✔                                           ✔                                                                                                                                  Allows application developers to define their own rules and headers inside their applications
:doc:`DevOpsST<devopssthandler>`  (:doc:`SSOaaS<ssoaas>`)  |new|     ✔          ✔                                                             ✔                                           ✔                                                                                                                                  Enables both :doc:`DevOps<devopshandler>` and :doc:`Service Token<servertoserver>`
:doc:`OAuth2<oauth2handler>`  [17]_\ |new|                           ✔          ✔                                                             ✔                                                                                                                              ✔                                               Uses OpenID Connect/OAuth2 access token to check authentication and authorization, can be used to protect Web Services
:doc:`Secure Token<securetoken>`                                     ✔          ✔                                                             ✔                                                                                                                                                                              Designed to secure exchanges between a LLNG reverse-proxy and a remote app
:doc:`Service Token<servertoserver>` |new| *(Server-to-Server)*      ✔          ✔                                                             ✔                                           ✔                                                                                  ✔                                               Designed to permit underlying requests *(API-Based Infrastructure)*
:doc:`Zimbra PreAuth<applications/zimbra>`                           ✔          ✔                                                             ✔
==================================================================== ========== ============================================================= =========================================== ================================================================================== =============================================== ======================================================================================================================

LLNG databases
~~~~~~~~~~~~~~

.. _start-configuration-database:

Configuration database
^^^^^^^^^^^^^^^^^^^^^^

|image46|

LL::NG needs a storage system to store its own configuration (managed by
the manager). Choose one in the following list:

===================================================== ========= ====================================================================
Backend                                               Shareable Comment
===================================================== ========= ====================================================================
:doc:`File (JSON)<fileconfbackend>`                             Not shareable between servers except
                                                                if used in conjunction with :doc:`REST<restconfbackend>`
                                                                or with a shared file system (NFS,...).
                                                                Selected by default during installation.
:doc:`YAML<yamlconfbackend>` |new|                              Same as :doc:`File<fileconfbackend>` but in YAML format
                                                                instead of JSON
:doc:`SQL (CDBI/RDBI)<sqlconfbackend>`                ✔         **Recommended for large-scale systems**. Prefer CDBI.
:doc:`LDAP<ldapconfbackend>`                          ✔
:doc:`MongoDB<mongodbconfbackend>` |deprecated|       ✔
:doc:`SOAP<soapconfbackend>` |deprecated|             ✔         Proxy backend to be used in conjunction with another
                                                                configuration backend. \ **Can be used to secure another backend**
                                                                for remote servers.
:doc:`REST<restconfbackend>` |new|                    ✔         Proxy backend to be used in conjunction with another configuration
                                                                backend. \ **Can be used to secure another backend** for
                                                                remote servers.
:doc:`Local<localconfbackend>` |new|                            Use only lemonldap-ng.ini parameters.
===================================================== ========= ====================================================================


.. tip::

    You can not start with an empty configuration, so read
    :doc:`how to change configuration backend<changeconfbackend>` to convert
    your existing configuration into another one.


.. _start-sessions-database:

Sessions database
^^^^^^^^^^^^^^^^^

|image50|

Sessions are stored using
`Apache::Session <http://search.cpan.org/perldoc?Apache::Session>`__
modules family. All
`Apache::Session <http://search.cpan.org/perldoc?Apache::Session>`__
style modules are usable except for some features.


.. attention::

    If you plan to use LLNG in a large-scale system, take a
    look at :ref:`Performance Test<performance-test>` to choose the right
    backend. A :doc:`Browseable SQL backend<browseablesessionbackend>` is
    generally a good choice.

================================================================ ========= ================================================ ==================================================== ================== =================================================================================================================================================================================================
Backend                                                          Shareable :ref:`Session explorer<session-explorer>`        :ref:`Session restrictions<session-restrictions>`    Session expiration Comment
================================================================ ========= ================================================ ==================================================== ================== =================================================================================================================================================================================================
:doc:`File<filesessionbackend>`                                            ✔                                                ✔                                                    ✔                  Not shareable between servers except if used in conjunction with :doc:`REST session backend<restsessionbackend>` or with a shared file system (NFS,...). Selected by default during installation.
:doc:`PgJSON<pgjsonsessionbackend>`                              ✔         ✔                                                ✔                                                    ✔                  **Recommended backend for production installations**
:doc:`Browseable MySQL<browseablemysqlsessionbackend>`           ✔         ✔                                                ✔                                                    ✔                  Recommended for those who prefer MySQL
:doc:`Browseable LDAP<browseableldapsessionbackend>`             ✔         ✔                                                ✔                                                    ✔
:doc:`Redis<redissessionbackend>`                                ✔         ✔                                                ✔                                                    ✔                  The fastest. Must be secured by network access control.
:doc:`MongoDB<mongodbsessionbackend>` |deprecated|               ✔         ✔                                                ✔                                                    ✔                  Must be secured by network access control.
:doc:`SQL<sqlsessionbackend>`                                    ✔         ✔                                                ✔                                                    ✔                  Unoptimized for :doc:`session explorer<features>` and :doc:`single session<features>` features.
:doc:`REST<restsessionbackend>` |new|                            ✔         ✔                                                ✔                                                    ✔                  Proxy backend to be used in conjunction with another session backend.
:doc:`SOAP<soapsessionbackend>`  |deprecated|                    ✔         ✔                                                ✔                                                    ✔                  Proxy backend to be used in conjunction with another session backend.
================================================================ ========= ================================================ ==================================================== ================== =================================================================================================================================================================================================

.. tip::

    You can migrate from one session backend to another using the
    :doc:`session conversion script<changesessionbackend>`. (|new|
    *since 2.0.7*)

Applications protection
-----------------------

|image53|

-  :doc:`Writing rules and headers<writingrulesand_headers>`
-  :doc:`Variables that can be used in rules and headers<variables>`
-  :doc:`Integrate vendor applications<applications>`
-  :doc:`Integrate self-made applications<selfmadeapplication>`
-  :doc:`Form replay<formreplay>`
-  :doc:`Custom Handlers<customhandlers>`
-  :doc:`WebServices / API<webserviceprotection>`
-  :doc:`WebSocket Applications<websocketapplications>`

Well known compatible applications
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


.. note::

    Here is a list of well known applications that are compatible with
    LL::NG. A full list is available on
    :doc:`vendor applications page<applications>`.

|adfs|
|alfresco|
|awx|
|bugzilla|
|dokuwiki|
|drupal|
|fusiondirectory|
|gitlab|
|glpi|
|liferay|
|mediawiki|
|nextcloud|
|simplesamlphp|
|wordpress|
|xwiki|
|zimbra|

Advanced features
-----------------

|image54|

-  :doc:`SMTP server setup<smtp>`
-  :doc:`Notifications system<notifications>`
-  :doc:`Store password in session<passwordstore>`
-  :doc:`Cross Domain Authentication (CDA)<cda>`
-  :doc:`Role Based Access Control (RBAC)<rbac>`
-  :doc:`Use custom functions<customfunctions>`
-  :doc:`Use extended functions<extendedfunctions>`
-  :doc:`Reset password by mail (self service)<resetpassword>`
-  :doc:`Create an account (self service)<register>`
-  :doc:`Forward logout to applications<logoutforward>`
-  :doc:`Secure Token Handler<securetoken>`
-  :doc:`AuthBasic Handler<authbasichandler>`
-  :doc:`SSO as a Service<ssoaas>` *(SSOaaS)* |new|
-  :doc:`Handling server webservice calls<servertoserver>` |new|
-  `LemonLDAP::NG kubernetes
   controller <https://github.com/lemonldap-ng-controller/lemonldap-ng-controller>`__
-  :doc:`Safe jail<safejail>`
-  :doc:`Login history<loginhistory>`
-  :doc:`Fast CGI support<fastcgi>`
-  :doc:`Advanced PSGI usage<psgi>`
-  :doc:`Ignore some manager tests<managertests>`
-  :doc:`See full parameters list<parameterlist>`

Mini howtos
-----------

|image57|

-  :doc:`Command Line Interface (lemonldap-ng-cli) examples<cli_examples>`
-  :doc:`Modify Manager protection<managerprotection>`
-  :doc:`Configuration and sessions in MySQL<mysqlminihowto>`
-  :doc:`Configuration and sessions in LDAP<ldapminihowto>`
-  :doc:`Configuration and sessions access by REST<restminihowto>`
-  :doc:`Integration in Active Directory (LDAP and Kerberos)<activedirectoryminihowto>`
-  :doc:`Create a protocol proxy<federationproxy>` *(SAML to OpenID, CAS
   to SAML ,...)*
-  :doc:`Convert HTTP header into environment variable<header_remote_user_conversion>`
-  :doc:`Connect to Renater Federation<renater>` |new|
-  :doc:`Run LemonLDAP::NG components behind a reverse proxy<behindproxyminihowto>`
-  :doc:`Configure LL::NG to use an outgoing proxy<useoutgoingproxy>`

Exploitation
------------

|image59|

-  :doc:`Performances<performances>`
-  :doc:`Security<security>`
-  :doc:`SELinux<selinux>`
-  :doc:`Handler status page<status>`
-  :doc:`Portal state check<checkstate>` *(health check for fail-over)*
   |new|
-  :doc:`Monitoring<monitoring>`
-  :doc:`Logs settings<logs>`
-  :doc:`Error messages<error>`
-  :doc:`High Availability<highavailability>`

Bug report
----------

See :doc:`How to report a bug</bugreport>`.

Developer corner
----------------

To contribute, see :

-  :doc:`Contribute to project<contribute>`

To develop an handler, see:

-  :doc:`Handler architecture<handlerarch>`
-  :doc:`Custom handlers<customhandlers>`

To develop a portal plugin, see manpages:

-  Lemonldap::NG::Portal
-  Lemonldap::NG::Portal::Auth
-  Lemonldap::NG::Portal::UserDB
-  Lemonldap::NG::Portal::Main::SecondFactor
-  Lemonldap::NG::Portal::Main::Issuer
-  Lemonldap::NG::Portal::Main::Plugin
-  Lemonldap::NG::Portal::Main::Request *(the request object)*

To add a new language:

-  Join us on
   https://www.transifex.com/lemonldapng/lemonldapng/dashboard/
-  translate the 3 files
-  then we will append them in sources.

If you don't want to publish your translation (``XX`` must be replaced
by your language code):

-  Manager: translate
   ``lemonldap-ng-manager/site/htdocs/static/languages/en.json`` in
   ``lemonldap-ng-manager/site/htdocs/static/languages/XX.json`` and
   enable it in "lemonldap-ng.ini" file
-  Portal: translate
   ``lemonldap-ng-portal/site/htdocs/static/languages/en.json`` in
   ``lemonldap-ng-portal/site/htdocs/static/languages/XX.json`` and
   enable it in "lemonldap-ng.ini" file
-  Portal Mails: translate
   ``lemonldap-ng-portal/site/templates/common/mail/en.json`` in
   ``lemonldap-ng-portal/site/templates/common/mail/XX.json``

.. [1]
   :doc:`GitHub authentication<authgithub>` is available with LLNG ≥
   2.0.8

.. [2]
   :doc:`GPG authentication<authgpg>` is available with LLNG ≥ 2.0.2

.. [3]
   :doc:`Radius second factor<radius2f>` is available with LLNG ≥ 2.0.6

.. [4]
   :doc:`Password second factor<password2f>` is available with LLNG ≥ 2.0.16

.. [5]
   :doc:`Check DevOps file plugin<checkdevops>` are available with LLNG ≥
   2.0.12

.. [6]
   :doc:`Check user plugin<checkuser>` is available with LLNG ≥ 2.0.3

.. [7]
   :doc:`Context switching plugin<contextswitching>` is available with
   LLNG ≥ 2.0.6

.. [8]
   :doc:`CrowdSec bouncer <crowdsec>` is available with LLNG ≥ 2.0.12

.. [9]
   :doc:`Decrypt value plugin<decryptvalue>` is available with LLNG ≥
   2.0.7

.. [10]
   :doc:`Global Logout plugin<globallogout>` is available with LLNG ≥
   2.0.7

.. [11]
   :doc:`Impersonation plugin<impersonation>` is available with LLNG ≥
   2.0.3

.. [12]
   :doc:`Find user plugin<finduser>` is available with LLNG ≥
   2.0.11

.. [13]
   :doc:`NewLocationWarning<newlocationwarning>` is available
   with LLNG ≥ 2.0.14

.. [14]
   :doc:`Refresh session API plugin<refreshsessionapi>` is available
   with LLNG ≥ 2.0.7

.. [15]
   :doc:`Reset certificate by mail plugin<resetcertificate>` is
   available with LLNG ≥ 2.0.7

.. [16]
   :doc:`Node.js handler<nodehandler>` has not yet reached the same
   level of functionalities

.. [17]
   :doc:`OAuth2 Handler<oauth2handler>` is available with LLNG ≥ 2.0.4

.. [18]
   When configured as an additional second factor, see :ref:`sfextraregister`

.. |image0| image:: /icons/kthememgr.png
.. |image1| image:: /icons/warehause.png
.. |image3| image:: /icons/clean.png
.. |image5| image:: /icons/lists.png
.. |image6| image:: /icons/colors.png
.. |image7| image:: /icons/gpg.png
.. |image26| image:: /icons/personal.png
.. |image27| image:: /icons/neotux.png
.. |image28| image:: /icons/personal.png
.. |image41| image:: /icons/gpg.png
.. |image46| image:: /icons/utilities.png
.. |image50| image:: /icons/kmultiple.png
.. |image53| image:: /icons/access.png
.. |image54| image:: /icons/neotux.png
.. |image57| image:: /icons/jabber_protocol.png
.. |image59| image:: /icons/xeyes.png

.. |beta| image:: /documentation/beta.png
   :width: 35px
   :alt: beta

.. |new| image:: /documentation/new.png
   :alt: new

.. |deprecated| image:: /documentation/deprecated.png
   :alt: deprecated


.. |adfs| image:: applications/microsoft-adfs.png
   :target: applications/adfs.html
.. |alfresco| image:: applications/alfresco_logo.png
   :target: applications/alfresco.html
.. |awx| image:: applications/logo-awx.png
   :target: applications/awx.html
.. |bugzilla| image:: applications/bugzilla_logo.png
   :target: applications/bugzilla.html
.. |dokuwiki| image:: applications/dokuwiki_logo.png
   :target: applications/dokuwiki.html
.. |drupal| image:: applications/drupal_logo.png
   :target: applications/drupal.html
.. |fusiondirectory| image:: applications/fusiondirectory-logo.jpg
   :target: applications/fusiondirectory.html
.. |gitlab| image:: applications/gitlab_logo.png
   :target: applications/gitlab.html
.. |glpi| image:: applications/glpi_logo.png
   :target: applications/glpi.html
.. |liferay| image:: applications/liferay_logo.png
   :target: applications/liferay.html
.. |mediawiki| image:: applications/mediawiki_logo.png
   :target: applications/mediawiki.html
.. |nextcloud| image:: applications/nextcloud-logo.png
   :target: applications/nextcloud.html
.. |simplesamlphp| image:: applications/simplesamlphp_logo.png
   :target: applications/simplesamlphp.html
.. |wordpress| image:: applications/wordpress_logo.png
   :target: applications/wordpress.html
.. |xwiki| image:: applications/xwiki.png
   :target: applications/xwiki.html
.. |zimbra| image:: applications/zimbra_logo.png
   :target: applications/zimbra.html
