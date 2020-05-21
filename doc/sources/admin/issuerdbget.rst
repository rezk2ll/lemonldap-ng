Get parameters Provider
=======================

Presentation
------------

For application not managing other provider protocols (CAS, OpenID
Connect, SAML,...) it is possible to configure LL::NG as a provider of
GET parameters:

-  An application can call LL::NG portal with a redirection url, such as
   ``http://auth.example.com/get/login?url=base64(application_url)``
-  When computing redirection, LL::NG portal will transmit any GET
   parameter you have configured for this application. (session id for
   example)


.. danger::

    Passing such sensitive information can be dangerous. Using
    other well-known secured protocols is recommended.

There is also the possibility to trigger a logout action by passing the
return url , such as
``http://auth.example.com/get/logout?url=base64(return_url)``

Configuration
-------------

In the Manager, go in ``General Parameters`` » ``Issuer modules`` »
``GET`` and configure:

-  **Activation**: set to ``On``.
-  **Path**: keep ``^/get/`` unless you have change
   :ref:`Apache portal configuration<configlocation-portal>` file.
-  **Use rule**: a rule to allow user to use this module, set to 1 to
   always allow.


.. tip::

    For example, to allow only users with a strong authentication
    level:

    ::

       $authenticationLevel > 2



Then go in ``Get parameters`` to define variables to transmit:

-  Define a new virtual host
-  Declare all get parameters you need. You have access to any
   :doc:`variable or macro<exportedvars>` (but no perl expression).

For example:

::

   "test1.example.com" => {
       "id" => "_session_id",
   }


.. danger::

    In the previous example, \_session_id is quite sensitive,
    thus it is encouraged that the application revalidate \_session_id using
    getCookie() SOAP call to avoid some security problems


.. tip::

    If host is not already registered in virtual hosts, you need
    to declare it in
    :ref:`trusted domains<security-configure-security-settings>` to allow
    redirection
