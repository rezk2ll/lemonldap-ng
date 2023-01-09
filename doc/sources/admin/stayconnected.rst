Stay connected plugin
=====================

This plugin enables persistent connection. It allows us to connect
automatically from the same browser.

Configuration
-------------

Just enable it in the manager (section “plugins”).

-  **Parameters**:

   -  **Activation**: Rule to enable/disable this plugin
   -  **Do not check fingerprint**: Enable/Disable browser fingerprint checking
   -  **Expiration time**: Persistent session connection and cookie timeout
   -  **Cookie name**: Persistent connection cookie name
   -  **One session per user**: Allow only one persistent connection per user.
      New persistent connections will disable the old ones. This option requires :doc:`Indexing the _session_uid field <browseablesessionbackend>`.

.. tip::

    By example, you can allow users from 192.168.0.0/16 private network to register a fingerprinting:

    - Rule: ``$env->{REMOTE_ADDR} =~ /^192\.168\./``
