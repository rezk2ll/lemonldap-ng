Logout forward
==============

Presentation
------------

Even if LL:NG can catch logout URL through
:ref:`virtual host rules<rules>`, you can have the
need to forward a logout to other applications, to close their local
sessions.

LL::NG has a logout forward mechanism, that will add a step in logout
process, to send logout requests (indeed, GET requests on application
logout URL) inside hidden iframes.


.. tip::

    The logout request will be sent even if the user did not use
    the application.

Configuration
-------------

Go in Manager, ``General parameters`` » ``Advanced parameters`` »
``Logout forward`` and click on ``Add a key``, then fill:

-  **Key**: application name
-  **Value**: application logout URL


.. attention::

    The request on logout URL will be sent after user is
    disconnected, so you should unprotect this URL if it is protected by an
    LL::NG Handler.
