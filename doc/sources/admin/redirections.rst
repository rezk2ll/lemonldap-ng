Redirections
============

Handler Redirections
--------------------


.. note::

    When a user access a Handler without a cookie, he is redirected on
    portal, and the target URL is encoded in redirection URL (to redirect
    user after authentication process).

Protocol and port
~~~~~~~~~~~~~~~~~

To encode the redirection URL, the handler will use some Apache
environment variables and also configuration settings:

-  **HTTPS**: use https as protocol
-  **Port**: port of the application (by default, 80 for http, 443 for
   https)

These parameters can be configured in Manager, in ``General Parameters``
> ``Advanced parameters`` > ``Handler redirections``.


.. tip::

    These settings can be overridden per virtual host, see
    :doc:`virtual host management<configvhost>`.

Forbidden and Server error
~~~~~~~~~~~~~~~~~~~~~~~~~~

Handler use the default Apache error code for the following cases:

-  User has no access authorization: FORBIDDEN (403)
-  An error occurs on server side: SERVER_ERROR (500)
-  The application is in maintenance: HTTP_SERVICE_UNAVAILABLE (503)

These errors can be catch through Apache ``ErrorDocument`` directive or
Nginx ``error_page`` directive, to redirect user on a specific page:

.. code-block:: apache

   # Apache: Common error page and security parameters
   ErrorDocument 403 http://auth.example.com/?lmError=403
   ErrorDocument 500 http://auth.example.com/?lmError=500
   ErrorDocument 503 http://auth.example.com/?lmError=503

.. code-block:: nginx

   # Nginx: Common error page and security parameters
   error_page 403 http://auth.example.com/?lmError=403;
   error_page 500 http://auth.example.com/?lmError=500;
   error_page 503 http://auth.example.com/?lmError=503;

It is also possible to redirect the user without using
``ErrorDocument``: the Handler will not return 403, 500, 503 code, but
code 302 (REDIRECT).

The user will be redirected on portal URL with error in the ``lmError``
URL parameter.

These parameters can be configured in Manager, in ``General Parameters``
> ``Advanced parameters`` > ``Handler redirections``:

-  **Redirect on forbidden**: use 302 instead 403
-  **Redirect on error**: use 302 instead 500 or 503

Portal Redirections
-------------------


.. note::

    If a user is redirected from handler to portal for authentication
    and once he is authenticated, portal redirects him to the redirection
    URL.

-  **Redirection message**: The redirection from portal can be done
   either with code 303 (See Other), or with a JavaScript redirection.
   Often the redirection takes some time because it is user's first
   access to the protected app, so a new app session has to be created :
   JavaScript redirection improves user experience by informing that
   authentication is performed, and by preventing from clicking again on
   the button because it is too slow.
-  **Keep redirections for Ajax**: By default, when an Ajax request is
   done on the portal for an unauthenticated user (after a redirection
   done by the handler), a 401 code will be sentwith a
   ``WWW-Authenticate`` header containing "SSO <portal-URL>". Set this
   option to 1 to keep the old behavior (return of HTML code).
-  **Skip re-auth confirmation**: by default, when re-authentication is
   needed, a confirmation screen is displayed to let user accept the
   re-authentication. If you enable this option, user will be directly
   redirected to login page.
-  **Skip upgrade confirmation**: by default, when upgrade is needed,
   a confirmation screen is displayed to let user accept the authentication
   level upgrade. If you enable this option, user will be directly
   redirected to 2FA page.
