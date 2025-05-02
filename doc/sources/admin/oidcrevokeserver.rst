OIDC Token-revoke server
========================

This plugin add an API to permit to revoke OIDC tokens from the session
explorer.

Configuration
-------------
To enable Web Cron:
Go in Manager, ``General Parameters`` » ``Plugins`` » ``OIDC Token-revoke server``.
You must set a shared secret.

Usage
-----

Session-Explorer automatically uses it when enabled. You can also use it to revoke
an ``access_token`` or a ``refresh_token`` if the ``revocation_endpoint`` isn't
usable in your case. Launch a ``POST`` request on ``/oidcRevokeToken`` with a
``Authorization: Bearer <secret>`` header and using the following parameters:

============== =========== ==============================================================
Parameter      Need        Value
============== =========== ==============================================================
``token``      required    token to revoke
``token_hint`` recommended type of token to revoke: ``refresh_token`` or ``access_token``
============== =========== ==============================================================
