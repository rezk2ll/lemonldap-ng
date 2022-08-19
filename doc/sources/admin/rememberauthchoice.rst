Remember auth choice plugin
===========================

This plugin enables automatic authentication, based upon the last user authentication choice.

For this plugin to work, you have to configure a set of :doc:`authentication modules<authchoice>`.

If you have multiple SAML, OIDC or CAS issuers, you should define a dedicated choice for each of these issuers, and set the corresponding URL to ``/?idp=youridp``.

Configuration
-------------

Once enabled (section "General Parameters > Plugins"), you can set these parameters.

-  **Parameters**:

   -  **Activation**: Rule to enable/disable this plugin
   -  **Cookie name**: Name of the cookie storing the authentication choice
   -  **Cookie lifetime**: Duration of the cookie (seconds) storing the authentication choice
   -  **Check by default**: Is the checkbox "Remember my choice" checked by default?
   -  **Timer before automatic authentication**: Timer before automatic authentication happens, if user has previously authorized the storage of authentication choice in a cookie

.. tip::

    For instance, you may allow users from 192.168.0.0/16 private network to have the "Remember authentication choice" checkbox:
    
    - Rule: ``$env->{REMOTE_ADDR} =~ /^192\.168\./``
