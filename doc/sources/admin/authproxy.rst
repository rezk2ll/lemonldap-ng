Proxy
=====

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔
============== ===== ========

Presentation
------------

LL::NG is able to transfer (trough REST or SOAP) authentication
credentials to another LL::NG portal, like a proxy.

The difference with :doc:`remote authentication<authremote>` is that the
client will never be redirect to the main LL::NG portal. This
configuration is usable if you want to expose your internal SSO portal
to another network (DMZ).

Configuration
-------------

External portal
~~~~~~~~~~~~~~~

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose Proxy for authentication and users.

Then, go in ``Proxy parameters``:

-  **Internal portal URL**: URL of internal portal
-  **Session service URL** (optional): Session service URL (default:
   same as previous for SOAP, same with "/session/my" for REST)
-  **Cookie name** (optional): name of the cookie of internal portal, if
   different from external portal
-  **Authentication level**: level given to this authentication
-  **Use SOAP instead of REST**: use a deprecated SOAP server instead of
   a REST one (you must set it if internal portal version is < 2.0). In
   this case, "Portal URL" parameter must contains SOAP endpoint
   (generally http://auth.example.com/index.pl/sessions for 1.9 and
   earlier, http://auth.example.com/sessions for 2.0)

Internal portal
~~~~~~~~~~~~~~~

The portal must be configured to accept REST or SOAP authentication
requests if you've choose to use SOAP. See:
:doc:`REST server plugin<restservices>` or
:doc:`SOAP session backend<soapsessionbackend>` *(deprecated)*.

SOAP compatibility with 1.9 server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you Proxy is a 2.0.x and your server is a 1.9.x, you should add this
in your lemonldap-ng.ini:

.. code:: ini

   soapProxyUrn = urn:Lemonldap/NG/Common/CGI/SOAPService


.. important::

    This needs LLNG version 2.0.8 at least
