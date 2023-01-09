WebServices / API
=================

Presentation
------------

WebServices and API are mostly requested by an application, and not the
end-user itself. In this case, you can not rely on LL::NG standard
Handler to protect the webservice, as it will expect a cookie, which is
not defined in the application requesting the service.

LL::NG offers several solutions to protect this kind of service.

ServiceToken Handler
--------------------

Two Handlers will be used:

-  The frontal Handler that will protect the web application, and will
   forge a specific token
-  The backend Handler that will protect the web service, and will
   consume the token

See :doc:`ServiceToken Handler documentation<servertoserver>`.

OAuth2 endpoints
----------------

We suppose here that LL::NG is acting as
:doc:`OpenID Connect provider<idpopenidconnect>`. The web application
will then be able to get an access token from LL::NG. This token could
be sent to the webservice that can then validate it against LL::NG
OAuth2 endpoints.

UserInfo
~~~~~~~~

You can use the UserInfo endpoint, which requires the Access Token to
provide user attributes.

For example:

::

   curl \
     -H "Authorization: Bearer a74d504ec9e784785e70a1da2b95d1d2" \
     https://auth.example.com/oauth2/userinfo | json_pp

.. code-block:: javascript

   {
      "family_name" : "OUDOT",
      "name" : "Clément OUDOT",
      "email" : "clement@example.com",
      "sub" : "coudot"
   }

Introspection
~~~~~~~~~~~~~

Introspection endpoint is defined in :rfc:`7662`. It requires an authentication
(same as the authentication for the tokens endpoint) and consumes an Access Token
as parameter.

For example:

::

   curl \
     -H "Authorization: Basic bGVtb25sZGFwOnNlY3JldA==" \
     -X POST -d "token=a74d504ec9e784785e70a1da2b95d1d2" \
     https://auth.example.com/oauth2/introspect | json_pp

.. code-block:: javascript

   {
      "client_id" : "lemonldap",
      "sub" : "coudot",
      "exp" : 1572446485,
      "active" : true,
      "scope" : "openid profile address email phone"
   }

OAuth2 Handler
--------------

We also suppose here that LL::NG is acting as
:doc:`OpenID Connect provider<idpopenidconnect>`. But the webservice
will be protected by the OAuth2 Handler and will just have to read the
HTTP headers to know which user is connected.

::

   curl \
      -H "Authorization: Bearer a74d504ec9e784785e70a1da2b95d1d2" \
      https://oauth2.example.ccom/rest/myapi

.. code-block:: javascript

   {
      "check" : "true",
      "user" : "coudot"
   }

See :doc:`OAuth2 Handler documentation<oauth2handler>`.
