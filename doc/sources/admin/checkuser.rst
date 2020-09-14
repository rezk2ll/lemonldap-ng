Check user plugin
=================

This plugin allows us to check session attributes, access rights and
transmitted headers for a specific user and URL. This can be useful for
IT Ops, dev teams or administrators to debug or check rules. Plugin
DISABLED by default.

Configuration
-------------

Just enable it in the manager (section “plugins”).

-  **Parameters**:

   -  **Activation**: Enable / Disable this plugin
   -  **Identities use rule**: Rule to define which profiles can be
      displayed (by example: ``!$anonymous``)
   -  **Unrestricted users rule**: Rule to define which users can check
      ALL users. ``Identities use rule`` is bypassed.
   -  **Hidden attributes**: Attributes not displayed
   -  **Attributes used for searching sessions**: User's attributes used
      for searching sessions in backend if ``whatToTrace`` fails. Useful
      to look for sessions by mail or givenName. Let it blank to search
      by ``whatToTrace`` only.
   -  **Display computed sessions**: Rule to define which users can display a
      computed session if no SSO session is found
   -  **Display empty headers**: Rule to define which users can display ALL headers
      appended by LemonLDAP::NG including empty ones
   -  **Display empty values**: Rule to define which users can display ALL attributes
      even empty ones
   -  **Display persistent session data**: Rule to define which users can display
      persistent session data


.. note::

    By examples :

    \* Search attributes => ``mail uid givenName``

    If ``whatToTrace`` fails, sessions are searched by ``mail``, next
    ``uid`` if none session is found and so on...

    \* Display empty headers rule => ``$uid eq "dwho"`` -> Only 'dwho' will
    see empty headers


.. note::

    Keep in mind that Nginx HTTP proxy module gets rid of empty
    headers. If the value of a header field is an empty string then this
    field will not be passed to a proxied server. To avoid misunderstanding,
    it might be useful to not display empty headers.


.. attention::

    Be careful to not display secret attributes.

    checkUser plugin hidden attributes are concatenation of
    ``checkUserHiddenAttributes`` and ``hiddenAttributes``. You just have to
    append checkUser specific attributes.


.. danger::

    This plugin displays ALL user session attributes except
    the hidden ones.

    You have to restrict access to specific users (administrators, DevOps,
    power users and so on...) by setting an access rule like other
    VirtualHosts.

    By example: ``$groups =~ /\bsu\b/``



To modify persistent sessions attributes ('_loginHistory \_2fDevices
notification\_' by default), edit ``lemonldap-ng.ini`` in [portal]
section:

.. code-block:: ini

   [portal]
   persistentSessionAttributes = _loginHistory _2fDevices notification_

Usage
-----

When enabled, ``/checkuser`` URL path is handled by this plugin.


.. attention::

    With federated authentication, checkUser plugin works
    only if a session can be found in backend.
