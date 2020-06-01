Force Authentication Addon
==========================

forceAuthentication plugin forces users to authenticate again to access
to Portal. Plugin DISABLED by default.

Users can access all protected applications except Portal.

Users have to authenticate again to access to Portal if there last login
is older than 5 seconds by default.

Configuration
-------------

To enabled forceAuthentication plugin :

Go in Manager, ``General Parameters`` » ``Advanced Parameters`` »
``Security`` » ``Force authentication`` and set to ``On``.

To modify last login interval (5 seconds by default) edit
``lemonldap-ng.ini`` in section [portal]:

.. code-block:: ini

   [portal]
   portalForceAuthnInterval = 5

