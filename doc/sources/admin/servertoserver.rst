Handling server webservice calls
================================

In modern applications, web application may need to request some other
web applications on behalf of the authenticated users. There are three
ways to do this:

-  the Ugly: provide to all applications SSO cookie. Not secured
   because SSO cookie can be caught and used everywhere, every time by
   everyone!!! **NOT RECOMMENDED**.
-  the Bad (:doc:`Secure Token Handler<securetoken>`): **Deprecated**.
   Should be used for specific cases
-  the Good (Service Token Handler): See below! (Thanks Sergio...)

The "Bad" method consists to give the token (cookie value) to WebApp1
which uses it as cookie header in its request. Since 2.0 version, LL::NG
gives a better way (the Good!) to do this by using limited scope
tokens.

Tokens are time limited (30 seconds by default) and URL restricted.

|Kinematic|

Webapp1 handler configuration
-----------------------------

Select **Main** handler type to protect WebApp1 and append a header containing:

.. code-block:: perl

   token($_session_id, 'test.example.com', '/^webapp[23]\.example\.c/', 'serviceHeader1=webapp1.example.com', "testHeader=$uid")

WebApp1 can retrieve this header and use it in its requests to query other server(s) by setting
the ``X-LLNG-TOKEN`` header. The ServiceToken is built by using the ``token`` extended function.
This function takes a list of parameters:
-  session ID that must be the first one: ``$_session_id``
-  virtual hosts authorized to be requested by WebApp1
   It can be some strings defining VHosts explicitly or regular expressions that must start and end with a slash ``/`` character.
-  ServiceHeaders that will be sent to requested apps. A ServiceHeader is defined like this: ``headerName1=headerValue1``

A ServiceToken is only valide for the authorized virtual hosts and during a restricted time period (30 seconds by default).
It can also be used for sending ServiceHeaders (headerName1=headerValue1) to requested apps. A ServiceHeader can be useful
to send the source host by example. ServiceHeaders are sent to ALL requested applications.
You can define ServiceToken TTL by setting relative option for each requested virtualHost in Manager.

You can also set ServiceToken default timeout (30 seconds) by editing ``lemonldap-ng.ini`` in section [handler]:

.. code-block:: ini

   [handler]
   handlerServiceTokenTTL = 30


.. note::

    ServiceToken timeout can be set for each virtual hosts.

Webapp2 handler configuration
-----------------------------

Change handler type to **ServiceToken**. So it is able to manage both
user and server connections. And that's all!

.. |Kinematic| image:: documentation/server_to_server.png


If you want to protect only a virtualHost part (location), keep handler type on "Main"
and set type in your configuration file:

-  Apache: just use ``PerlSetVar VHOSTTYPE ServiceToken`` directive
-  Nginx: create another FastCGI parameter with ``fastcgi_param VHOSTTYPE ServiceToken;``