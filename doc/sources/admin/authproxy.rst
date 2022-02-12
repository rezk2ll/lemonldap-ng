Proxy
=====

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔
============== ===== ========

Presentation
------------

LL::NG is able to send (through REST or SOAP) authentication
credentials to another LL::NG portal, like a proxy.

The difference with :doc:`remote authentication<authremote>` is that the
client will never be redirect to the main LL::NG portal. This
configuration is useful if you want to expose your internal SSO portal
to another network (DMZ).

Configuration
-------------

External portal
~~~~~~~~~~~~~~~

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose Proxy for authentication and users.

Then, go in ``Proxy parameters``:

-  **Authentication level**: authentication level for Proxy module
-  **Use SOAP instead of REST**: use a deprecated SOAP server instead of
   a REST one (you must set it if internal portal version is < 2.0). In
   this case, "Portal URL" parameter must contain SOAP endpoint
   (generally http://auth.example.com/index.pl/sessions for 1.9 and
   earlier, http://auth.example.com/sessions for 2.0)
-  **URL**: URL of internal portal
-  **Session service URL** (optional): session service URL (default:
   same as previous for SOAP, same with "/session/my" for REST)
-  **Choice parameter** (optional): choice parameter of the internal portal if applicable
-  **Choice value** (optional): value of the choice parameter of the internal portal
-  **Cookie name** (optional): internal portal cookie name,
   if different from external portal
-  **Impersonation** (optional) : can be enabled if the internal portal provides impersonation

.. note::

    If the internal portal uses :doc:`Choice Authentication<authchoice>`,
    you have to specify 'Internal portal choice parameter' and
    'Internal portal choice value' depending on its configuration. 
    This feature needs at least LL::NG version 2.0.14.

Internal portal
~~~~~~~~~~~~~~~

The portal must be configured to accept REST or SOAP authentication
requests. See:
:doc:`REST server plugin<restservices>` or
:doc:`SOAP session backend<soapsessionbackend>` *(deprecated)*.

SOAP compatibility with 1.9 server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If your Proxy is a 2.0.x and your server is a 1.9.x, you should add this
in your lemonldap-ng.ini:

.. code-block:: ini

   soapProxyUrn = urn:Lemonldap/NG/Common/CGI/SOAPService

.. attention::

    This feature needs at least LL::NG version 2.0.8
