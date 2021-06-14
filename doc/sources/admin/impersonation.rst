Impersonation plugin
====================

This plugin allows certain users to assume the identity of another user.
A privileged user first logs in with its real account and can then
choose another profile to appear as. This feature can be especially
useful for training/learning or development platforms.


.. attention::

    This plugin should not be used on production instance,
    prefer :doc:`ContextSwitching plugin<contextswitching>`.

Configuration
-------------

Just enable it in the Manager (section “plugins”) by setting a rule.
Impersonation can be allowed or denied for specific users. Furthermore,
specific identities like administrators or anonymous users can be
protected from being impersonated.

-  **Parameters**:

   -  **Use rule**: Rule to allow/deny users to impersonate or define
      which users may use this plugin.
   -  **Identities use rule**: Rule to define which identities can be
      assumed. Useful to prevent impersonation of certain sensitive
      identities like CEO, administrators or anonymous/protected users
   -  **Unrestricted users rule**: Rule to define which users can assume
      ALL users. ``Identities use rule`` is bypassed.
   -  **Hidden attributes**: Attributes not displayed
   -  **Skip empty values**: Do not use empty profile attributes
   -  **Merge spoofed and real SSO groups**: Can be useful for
      administrators to keep higher privileges. "Special rule" field can
      be used to set SSO groups to merge if exist in real session.
      Multivalue ``separator`` is used. By example :
      ``su; admins; anonymous``


.. danger::

    You HAVE TO modify **REMOTE_USER** to log both real AND
    spoofed uid.

    Set a macro like this :

     ``_whatToTrace`` -> ``$real__user ? "$real__user/$_user" : "$_user/$_user"``

    and set ``General Parameters > Logs > REMOTE_USER`` with ``_whatToTrace``



.. attention::

    Both spoofed and real session attributes can be used to
    set access rules, groups or macros.

    By example : ``$real_uid && $real_uid eq 'dwho'`` or ``$real_groups && $real_groups =~ /\bsu\b/``

    Keep in mind that real session is computed first. Afterward, if access
    is granted, impersonated session is computed with real and spoofed
    session attributes if Impersonation is allowed.
    So, ``real_`` attributes are computed by second authentication process.
    To avoid Perl warnings, you have to prefix regex with ``$real_var &&``.



.. attention::

    By example, to prevent impersonation as 'dwho' set
    **Identities use rule** like :

    ``$uid ne 'dwho'``



impersonationPrefix is used to rename user's real profile attributes.
You can set real attributes prefix ('real\_' by default) by editing
``lemonldap-ng.ini`` in section [portal]:

.. code-block:: ini

   [portal]
   impersonationPrefix = real_

