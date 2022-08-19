Variables
=========

Presentation
------------

Variables can be used in rules and headers. All rules are concerned:

-  Access rule in virtual host
-  SAML IDP preselection
-  Session opening
-  ...

Variables are stored in the user session. We can distinguish several
kind of variables:

-  internal variables, managed by LemonLDAP::NG
-  :doc:`exported variables<exportedvars>` collected from UserDB backend
-  :ref:`macro and groups<macros_and_groups>`

When you know the key of the variable, you just have to prefix it with
the dollar sign to use it, for example to test if ``uid`` variable match
``coudot`` :

::

   $uid eq "coudot"


.. tip::

    You can inspect a user session with the sessions explorer (in
    Manager)

Below are documented internal variables.

Modules
-------

Register what module was used for authentication, user data, password,
...

============= =====================================================================
Key           Description
============= =====================================================================
\_auth        Authentication module
\_userDB      User module
\_passwordDB  Password module
\_2f          Second factor (if 2FA was used)
\_issuerDB    Issuer module (can be multivalued)
\_authChoice  User choice done if :doc:`authentication choice<authchoice>` was used
\_authMulti   Full name of authentication module (with ``#label``) used in Multi
\_userDBMulti Full name of user module (with ``#label``) used in Multi
============= =====================================================================

Connection
----------

Data concerning the first connection to the portal

========== ========================================================================================================================================
Key        Description
========== ========================================================================================================================================
ipAddr     IP of the user (special care must be taken is you run the portal :doc:`behind a reverse proxy<behindproxyminihowto>`)
\_timezone Timezone of the user, set with javascript from standard login form (will be empty if other authentication methods are used)
\_url      URL used before being redirected to the portal (empty if portal was used as entry point)
========== ========================================================================================================================================

Authentication
--------------

Data around the authentication process.

=================== =========================================================================================================
Key                 Description
=================== =========================================================================================================
\_session_id        Session identifier (carried in cookie)
\_user              User found from login process
\_password          Password found from login process (only if :doc:`password store in session<passwordstore>` is configured)
authenticationLevel Authentication level
=================== =========================================================================================================

Dates
-----

================ =====================================
Key              Description
================ =====================================
\_utime          Timestamp of session creation
\_startTime      Date of session creation
\_updateTime     Date of session last modification
\_lastAuthnUTime Timestamp of last authentication time
================ =====================================

SAML
----

Data related to SAML protocol

=================== ================================================
Key                 Description
=================== ================================================
\_idp               Name of IDP used for authentication
\_idpConfKey        Configuration key of IDP used for authentication
\_samlToken         SAML token
\_lassoSessionDump  Lasso session dump
\_lassoIdentityDump Lasso identity dump
=================== ================================================

Notifications
-------------

====================== ===========================================
Key                    Description
====================== ===========================================
\_notification\_\ *id* Date of validation of the notification *id*
====================== ===========================================

Login history
-------------

============== ==================================
Key            Description
============== ==================================
\_loginHistory HASH of login success and failures
============== ==================================

LDAP
----

Only with UserDB LDAP.

==== ==================
Key  Description
==== ==================
\_dn Distinguished name
==== ==================

OpenID
------

================ =============================================
Key              Description
================ =============================================
\_openid\_\ *id* Consent to share attribute *id* through OpenID
================ =============================================

OpenID Connect
--------------

============================ ======================================================================
Key                          Description
============================ ======================================================================
\_oidc_id_token              ID Token
\_oidc_OP                    Configuration key of OP used for authentication
\_oidc_access_token          OAuth2 Access Token used to get UserInfo data
\_oidc_access_token_eol      Timestamp after which the Access Token should no longer be valid
\_oidc_refresh_token         OAuth2 Refresh Token. This should never be transmitted to applications
\_oidc_consent_scope\_\ *rp* Scope for which consent was given for RP *rp*
\_oidc_consent_time\_\ *rp*  Time when consent was given for RP *rp*
============================ ======================================================================

Other
-----

=============== ======================================
Key             Description
=============== ======================================
\_appsListOrder Order of categories in the menu
\_session_kind  Type of session (SSO, Persistent, ...)
=============== ======================================
