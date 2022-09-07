Check state plugin
==================

This plugin can be used to check if portal instance is ready. This can
be a health check to request keep-alive service to force a fail-over on
the backup-node.

Configuration
-------------
To enable Check state:
Go in Manager, ``General Parameters`` » ``Plugins`` » ``State Check``.
You must also set a shared secret.

Usage
-----

When enabled, ``/checkstate`` URL path is handled by this plugin.
GET parameters:

============= ======== ============================================================
GET Parameter Need     Value
============= ======== ============================================================
``secret``    required Same value as the shared secret given to the manager
``user``      optional If set (with password), a login/logout process will be tried
``password``  optional
============= ======== ============================================================

Response
--------

The plugin will respond to the HTTP request with:

* HTTP code 500 if something went wrong
* HTTP code 200 and the following JSON content if something went right

.. code:: json

    {"result":1,"version":"2.0.14"}

.. versionadded:: 2.0.14
   The *version* key is returned



Example
~~~~~~~

-  Basic availability check:
   ``https://auth.example.com/checkstate?secret=qwerty``
-  Try to log a user in:
   ``https://auth.example.com/checkstate?secret=qwerty&user=dwho&password=dwho``
