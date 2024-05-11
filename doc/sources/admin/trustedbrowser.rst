Trusted browser plugin
=======================

This plugin lets you remember your web browser after a successful login. This trusted browser can then 
be used to skip the entire authentication, or just bypass second factors.

Configuration
-------------

-  **Parameters**:

   -  **Activation condition**: Enable the plugin for all users or only under certain conditions
   -  **Authentication bypass**: Skip authentication completely if the user has a trusted browser (*not recommended*)
   -  **Do not check fingerprint**: enable/disable browser fingerprint checking
   -  **Expiration time**: how long browsers are remembered
   -  **Cookie name**: trusted browser cookie name
   -  **One trusted browser per user**: allow only one trusted browser per user
      New trusted browsers will disable the old ones. This option requires :doc:`Indexing the _session_uid field <browseablesessionbackend>`.


Rules examples
--------------

* Only allow members of a certain group to remember their browsers ::

    inGroup('trusted_users')

* Only allow registering a trusted browser from a certain network ::

    inSubnet('10.0.0.0/8', '192.168.0.0/16')

* Only allow remembering the web browser if the authentication was strong enough ::

    $authenticationLevel >= 4

Using trusted browsers to bypass 2FA
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can use the ``$_trustedBrowser`` session variable in 2FA rules, for example, as a TOTP activation rule ::

    has2f("TOTP") and !$_trustedBrowser

means that TOTP will not be asked for trusted browsers
