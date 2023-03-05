Stay connected plugin
=====================

This plugin enables persistent connection. It allows us to connect
automatically from the same browser.

Configuration
-------------

Just enable it in the manager (section “plugins”).

-  **Parameters**:

   -  **Activation**: rule to enable/disable this plugin
   -  **Do not check fingerprint**: enable/disable browser fingerprint checking
   -  **Expiration time**: persistent session connection and cookie timeout
   -  **Cookie name**: persistent connection cookie name
   -  **One session per user**: allow only one persistent connection per user
      New persistent connections will disable the old ones. This option requires :doc:`Indexing the _session_uid field <browseablesessionbackend>`.

.. tip::

    By example, you can allow users from 192.168.0.0/16 private network to register a fingerprint:

    - Rule: ``$env->{REMOTE_ADDR} =~ /^192\.168\./``
