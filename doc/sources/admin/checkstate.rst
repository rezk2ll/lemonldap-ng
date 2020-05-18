Check state plugin
==================

This plugin can be used to check if portal instance is ready. This can
be a health check to request keep-alive service to force a fail-over on
the backup-node.

Configuration
-------------

Just enable it in the manager (\**General Parameters* » *Plugins* »
*State Check*). You must also set a shared secret.

Usage
-----

When enabled, ``/checkstate`` URL path is handled by this plugin. GET
parameters:

============= ======== ============================================================
GET Parameter Need     Value
============= ======== ============================================================
``secret``    required Same value as the shared secret given to the manager
``user``      optional If set (with password), a login/logout process will be tried
``password``  optional
============= ======== ============================================================

Example
~~~~~~~

-  Basic availability check:
   ``https://auth.example.com/checkstate?secret=qwerty``
-  Try to log a user in:
   ``https://auth.example.com/checkstate?secret=qwerty&user=dwho&password=dwho``
