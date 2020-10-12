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

   -  **Use rule**: Rule to enable or define which users may use this plugin
      (By example: $uid eq 'dwho' && $authenticationLevel > 2).
   -  **Identities use rule**: Rule to define which identities can be
      assumed. Useful to prevent impersonation of certain sensitive
      identities like CEO, administrators or anonymous/protected users.
   -  **Unrestricted users rule**: Rule to define which users can switch
      context of ALL users. ``Identities use rule`` is bypassed.
   -  **Allow 2FA modifications**: This option must be enabled to append,
      verify or delete a second factor during context switching.
   -  **Stop by logout**: Stop context switching by sending a logout
      request.


.. danger::

    During context switching authentication process, all
    plugins are disabled. In other words, all entry points like afterData,
    endAuth and so on are skipped. Therefore, second factors or
    notifications by example will not be prompted and login history is not updated!


.. attention::

    ContextSwitching plugin works only with a userDB
    backend. You can not switch context with federated authentication.


.. attention::

    Used identity, start and end of switching context process are logged!


contextSwitchingPrefix is used to store real user's session Id. You can
set this prefix ('switching' by default) by editing ``lemonldap-ng.ini``
in [portal] section:

.. code-block:: ini

   [portal]
   contextSwitchingPrefix = switching

