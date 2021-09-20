France Connect
==============

|image0|

Presentation
------------

`France Connect <https://doc.integ01.dev-franceconnect.fr/>`__ is an
authentication platform made by French government.


.. attention::

    It is for the moment only in BETA stage. This
    documentation will explain how to configure LL::NG with the developer
    reserved space.

Register on France Connect
--------------------------

Once :doc:`OpenID Connect service<openidconnectservice>` is configured,
you need to register to France Connect.

Use the following form:
https://doc.integ01.dev-franceconnect.fr/inscription.

You need to provide the callback URLs, for example
https://auth.domain.com/?openidconnectcallback=1.

You will then get a ``client_id`` and a ``client_secret``.

Declare France Connect in your LL::NG server
--------------------------------------------

Go in Manager and create a new OpenID Connect provider. You can call it
``france-connect`` for example.

Click on ``Metadata`` and set manually the metadata of the service,
using `France Connect
endpoints <https://doc.integ01.dev-franceconnect.fr/fournisseur-service>`__.
For example:

.. code-block:: javascript

   {
   "issuer": "https://fcp.integ01.dev-franceconnect.fr",
   "authorization_endpoint": "https://fcp.integ01.dev-franceconnect.fr/api/v1/authorize",
   "token_endpoint": "https://fcp.integ01.dev-franceconnect.fr/api/v1/token",
   "userinfo_endpoint": "https://fcp.integ01.dev-franceconnect.fr/api/v1/userinfo",
   "end_session_endpoint":"https://fcp.integ01.dev-franceconnect.fr/api/v1/logout"
   }

You can skip JWKS data, they are not provided by France Connect. The
security relies on the symmetric key ``client_secret``.

Go in ``Exported attributes`` to choose which attributes from "identité
pivot" you want to collect. See
https://doc.integ01.dev-franceconnect.fr/identite-pivot

Now go in ``Options``:

-  In ``Configuration``, register the ``client_id`` and
   ``client_secret`` given by France Connect
-  In ``Protocol``, adapt the ``scope`` to the exported attributes you
   want. See https://doc.integ01.dev-franceconnect.fr/fs-scopes
-  In ``Display``, you can set the name and the logo

.. |image0| image:: /applications/franceconnect_logo.png
   :class: align-center

