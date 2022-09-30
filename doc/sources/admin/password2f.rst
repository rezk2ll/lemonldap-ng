Password as Second Factor
=========================

This module allows users to self-register a password that will be asked after
the initial login process. The password is not stored in a UserDB backend
(LDAP, SQL...) but in the persistent session instead, where it can be managed
through the same 2FA management tools as all other second factors.


.. warning::

   Using this module only makes sense if the first authentication factor is NOT
   knowledge-based.

Configuration
-------------

Password encryption
~~~~~~~~~~~~~~~~~~~

Passwords are stored in encrypted form, by default, the key used for encryption
is the global one, set in

*General Parameters* » *Advanced Parameters* » *Security* » *Key*

However, if you store your configuration and persistent sessions in the same
database, this defeats the point of encryption entirely.

It is recommended to set the password encryption key in ``/etc/lemonldap-ng/lemonldap-ng.ini`` instead::

    [all]
    password2fKey=changeme

.. _configuration-password2f:

Configuration
~~~~~~~~~~~~~

All parameters are configured in "General Parameters » Second factors »
Password".

-  **Activation**: Set to ``On`` to activate this module, or use a
   specific rule to select which users may use this type of second
   factor
-  **Self registration**: set it to "on" if users are authorized to
   register a password as their second factor
-  **Authentication level** (Optional): if you want to overwrite the
   value sent by your authentication module, you can define here the new
   authentication level. Example: 5
-  **Label** (Optional): label that should be displayed to the user on
   the choice screen
-  **Logo** (Optional): logo file *(in static/<skin> directory)*
-  **Allow users to remove password**: If enabled, users can unregister
   password
-  **Lifetime** (Optional): Unlimited by default. Set a Time To Live in seconds.
   TTL is checked at each login process if set. If TTL is expired, the second
   factor is removed.

