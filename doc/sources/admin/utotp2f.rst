U2F-or-TOTP 2nd Factor Authentication
=====================================

This module enables both :doc:`U2F<u2f>` and :doc:`TOTP<totp2f>`
Authentication *(like Gitlab)*. Therefore, users can use their TOTP
instead if they don't have their U2F device.

Difference between enabled both U2F and TOTP is that only one page is
displayed instead of displaying first a choice menu.

Configuration
-------------

In the manager (second factors), you just have to enable it:

-  **Activation**: set it to "on". Note that you should not enable
   :doc:`U2F<u2f>` and :doc:`TOTP<totp2f>` separately *(except for
   self-registration: see below)*
-  **Authentication level**: you can overwrite here auth level for
   registered users. Leave it blank keeps auth level provided by first
   authentication module (By default: 2 for user/password based
   modules). It is recommended to set an higher value here if you want
   to give access to apps just for enrolled users.
-  **Label** (Optional): label that should be displayed to the user on
   the choice screen
-  **Logo** (Optional): logo file *(in static/<skin> directory)*


.. tip::

    Every other parameters of :doc:`U2F<u2f>` and
    :doc:`TOTP<totp2f>` can be set in the corresponding 2F modules except
    that you should not enable them.


.. attention::

    If you want to give a different level for U2F or TOTP,
    leave this parameter blank and set U2F and TOTP "authentication level"
    in corresponding modules.

Self-registration
~~~~~~~~~~~~~~~~~

This module has no self-registration. You have to use U2F and TOTP self
registration modules. Example: suppose you want to allow U2F
registration only if a TOTP secret is registered:

-  TOTP self-registration => enabled
-  U2F self-registration => ``$_2fDevices =~ /"type":\s*"TOTP"/s``

Automatically, U2F registration will be hidden for unregistered TOTP
users and displayed then.
