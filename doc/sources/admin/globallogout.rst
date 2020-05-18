Global logout plugin
====================

This plugin allows a user to log out of all his active sessions.

Configuration
-------------

Just enable it in the Manager (section “plugins”).

-  **Parameters**:

   -  **Activation**: Enable/Disable or set a rule to select which users
      are allowed to close there sessions.
   -  **Auto accept time**: Enable/Disable timer. If timer is disabled,
      all opened sessions will be immediately closed.
   -  **Custom parameter**: Session attribut to display at global logout


.. note::

    To display more than one session attribute, you can create a
    macro like this :

    ``user_USER => "$uid_" . uc $uid``
