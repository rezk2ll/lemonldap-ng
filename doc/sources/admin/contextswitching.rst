ContextSwitching plugin
=======================

This plugin allows certain users to switch context other user. This may
be useful when providing assistance or when testing privileges. Enter
the uid of the user you'd like to switch context to.

Configuration
-------------

Just enable it in the Manager (section “plugins”) by setting a rule.
ContextSwitching can be allowed or denied for specific users.
Furthermore, specific identities like administrators or anonymous users
can be forbidden to assume.

-  **Parameters**:

   -  **Use rule**: Select which users may use this plugin
   -  **Identities use rule**: Rule to define which identities can be
      assumed. Useful to prevent impersonation of certain sensitive
      identities like CEO, administrators or anonymous/protected users.
   -  **Stop by logout**: Stop context switching by sending a logout
      request.


.. warning:: 

    During context switching authentication process, all
    plugins are disabled. In other words, all entry points like afterData,
    endAuth and so on are skipped. Therefore, second factors or
    notifications by example will not be prompted! 


.. important:: 

    ContextSwitching plugin works only with a userDB
    backend. You can not switch context with federated authentication.


contextSwitchingPrefix is used to store real user's session Id. You can
set this prefix ('switching' by default) by editing ``lemonldap-ng.ini``
in [portal] section:

.. code:: ini

   [portal]
   contextSwitchingPrefix = switching

