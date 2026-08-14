Proxy
=====

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔
============== ===== ========

Presentation
------------

LemonLDAP::NG is able to send (through REST or SOAP) authentication
credentials to another LemonLDAP::NG portal, like a proxy.

The difference with :doc:`remote authentication<authremote>` is that the
client will never be redirect to the main LemonLDAP::NG portal. This
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
-  **URL**: URL of internal portal
-  **Session service URL** (optional): session service URL (default: "/session/my")
-  **Choice parameter** (optional): choice parameter of the internal portal if applicable
-  **Choice value** (optional): value of the choice parameter of the internal portal
-  **Cookie name** (optional): internal portal cookie name, if different from external portal
-  **Impersonation** (optional) : can be enabled if the internal portal provides impersonation

.. note::

    If the internal portal uses :doc:`Choice Authentication<authchoice>`,
    you have to specify 'Internal portal choice parameter' and
    'Internal portal choice value' depending on its configuration. 

Internal portal
~~~~~~~~~~~~~~~

The portal must be configured to accept REST authentication requests. See:
:doc:`REST server plugin<restservices>` or
