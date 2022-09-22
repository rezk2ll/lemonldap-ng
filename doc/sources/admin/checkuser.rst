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
      ALL users and attributes.
   -  **Hidden attributes**: Session attributes not displayed except for unrestricted users
   -  **Attributes used for searching sessions**: User's attributes used
      for searching sessions in backend if ``whatToTrace`` fails. Useful
      to look for sessions by mail or givenName. Let it blank to search
      by ``whatToTrace`` only
   -  **Hidden headers**: Sent headers whose value is masked except for unrestricted users.
      Key is a VirtualHost name and value represents a space-separated headers list.
      A blank value obfuscates ALL relative VirtualHost sent headers.
      Note that just valued hearders are masked.

-  **Display**:

   -  **Computed sessions**: Rule to define which users can display a
      computed session if no SSO session is found
   -  **Persistent session data**: Rule to define which users can display
      persistent session data
   -  **Normalized headers**: Rule to define which users can see headers name sent by
      the web server (see RFC3875)
   -  **Empty headers**: Rule to define which users can display ALL headers
      sent by LemonLDAP::NG including empty ones
   -  **Empty values**: Rule to define which users can display empty values
   -  **Hidden attributes**: Rule to define which users can display hidden attributes
   -  **History**: Rule to define which users can display logins history

.. note::

    By example:

    \* test1.example.com => ``Auth-User mail``
    Just 'Auth-User' and 'mail' headers are masked if valued.

    \* test2.example.com => '' ALL valued headers are masked.

    Unrestricted users can see the masked headers.


.. note::

    By example:

    \* Search attributes => ``mail, uid, givenName``

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
