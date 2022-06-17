REST services
=============

LL::NG portal is a REST server that gives access to configuration,
session and also authentication.

Portal REST services
--------------------

Authentication
~~~~~~~~~~~~~~

The authentication service is always available with REST, you just need
to send credentials on portal URL. But by default, the portal is
protected by :ref:`one time tokens to prevent CSRF<security-portal>`.
You must disable them or set a rule (configuration parameter
``requireToken``) so token will not be required for REST requests, for
example:

.. code-block:: perl

   $env->{HTTP_ACCEPT} !~ m:application/json:


Another solution is using the :doc:`REST auth/user/password backend<restauthuserpwdbackend>`.

API
^^^

Request parameters:

-  Endpoint: ``/``
-  Method: ``POST``
-  Request headers:

   -  ``Accept``: ``application/json``

-  POST data:

   -  ``user``: user login
   -  ``password``: user password
   -  xxx: optional parameters, like ``lmAuth`` if your portal uses
      ``Choice`` or ``spoofId`` to impersonate.

The JSON response fields are:

-  ``result``: authentication result, ``0`` if it fails, ``1`` if it
   succeed
-  ``error``: error code, the corresponding error can be found in
   :doc:`Portal error codes<error_codes>`
-  ``id``: if authentication succeed, the session id is returned in this
   field. This id is not returned if you call the REST endpoint with the
   session cookie (which means you are already authenticated).


.. tip::

    You can also get the cookie by reading the response header
    ``Cookie`` returned by the portal.


.. attention::

    Before version 2.0.4, the response to a success
    authentication had no ``id`` field, and ``error`` field was named
    ``code``.

Example
^^^^^^^

-  Request with curl:

::

   curl -H "Accept: application/json" -d user=rtyler -d password=rtyler http://auth.example.com/ | json_pp


.. attention::

    With ``cURL > 7.18.0``, to include special characters
    like @, & or + in the cURL POST data:

    ::

       curl -H "Accept: application/json" -d name=rtyler --data-urlencode passwd=@31&3+*J http://auth.example.com/ | json_pp



-  Response for bad authentication:

.. code-block:: javascript

   {
       "result" : 0,
       "error" : 5
   }

-  Response for good authentication:

.. code-block:: javascript

   {
       "result" : 1,
       "error" : "0",
       "id" : "b048bf87ca401da1d89419813e3acf466d5e4465fe3a1f7adfd8240bd161bde2"
   }

Sessions
~~~~~~~~

REST functions for sessions are protected by Web Server, you can change
this in :ref:`portal configuration<configlocation-portal>`.

See :doc:`REST session backend documentation<restsessionbackend>` for
more.

Configuration
~~~~~~~~~~~~~

REST functions for configuration are protected by Web Server, you can
change this in :ref:`portal configuration<configlocation-portal>`.

See :doc:`REST configuration backend documentation<restconfbackend>` for
more.
