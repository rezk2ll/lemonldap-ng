OAuth2 Handler
==============

|image0|

Presentation
------------

This Handler is able to check an OAuth2 access token to retrieve the
user real session and protect a virtual host like a standard Handler
(access control and HTTP headers transmission).

This requires to get an OAuth2 access token through LL::NG Portal (OpenID
Connect server). This access token can then be used in the
``Authorization`` header to authenticate to the Web Service / API
protected by the OAuth2 Handler.

|image1|


.. tip::

    In the above schema, the OpenID Connect process is simplified.
    How the front application receives the Access Token depends on the
    requested flow (Authorization code, Implicit or Hybrid). In all cases,
    the application will have an Access Token and will be able to use it to
    request a Web Service.

Example:

::

   curl -H "Authorization: Bearer de853461341e88e9def8fcb9db2a81c4" https://oauth2.example.com/api/test | json_pp

.. code-block:: javascript

   {
       check: true,
       user: "dwho"
   }

Additional variables
--------------------

The OAuth2 handler defines a few extra variables that you can use in
:doc:`rules and headers<writingrulesand_headers>`.

* ``$_clientId``: client ID of the application which requested the Access Token
* ``$_clientConfKey``: configuration key of the application which requested the
  Access Token
* ``$_oidc_grant_type`` (since *2.0.14*): the grant type used to generate the Access Token. If
  Refresh Tokens are used, this is the grant type of the first emitted Access
  Token. Possible values: ``authorizationcode``, ``implicit``, ``hybrid``,
  ``clientcredentials``, ``password``
* ``$_scope``: list of space-separated scopes granted by the Access Token

For example, to grant access to access tokens containing the ``write`` scope,
use ::

   $_scope =~ /(?<!\S)write(?!\S)/


Configuration
-------------

Protect you virtual host like any other virtual host with the standard
Handler.

Define access rules and headers. Then in ``Options`` > ``Type``, choose
``OAuth2``.

Reference
---------

:rfc:`6750`

.. |image0| image:: /documentation/oauth-retina-preview.jpg
   :class: align-center
.. |image1| image:: /documentation/oauth2_handler.png
   :class: align-center

