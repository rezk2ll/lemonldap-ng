Single Sign On cookie, domain and portal URL
============================================

SSO cookie
----------

The SSO cookie is built by the portal (as described in the
:ref:`login kinematic<presentation-login>`), or by the
Handler for cross domain authentication (see
:ref:`CDA kinematic<cda>`).

To edit SSO cookie parameters, go in Manager, ``General Parameters`` >
``Cookies``:

-  **Cookie name**: name of the cookie, can be changed to avoid
   conflicts with other LemonLDAP::NG installations
-  **Domain**: validity domain for the cookie (the cookie will not be
   sent on other domains)
-  **Multiple domains**: enable :doc:`cross domain mechanism<cda>`
   (without this, you cannot extend SSO to other domains)
-  **Secured cookie**: 4 options:

   -  **Non secured cookie**: the cookie can be sent over HTTP and HTTPS
      connections
   -  **Secured cookie**: the cookie can only be sent over HTTPS
   -  **Double cookie**: two cookies are delivered, one for HTTP and
      HTTPS connections, the other for HTTPS only
   -  **Double cookie for single session**: same as double cookie but
      only one session is created in session database

-  **Javascript protection**: set httpOnly flag, to prevent cookie from
   being leaked by malicious javascript code
-  **Cookie expiration time**: by default, SSO cookie is a session
   cookie, which means it will be destroyed when browser is closed. You
   can change this behavior by setting a cookie expiration time. It must
   be an integer. **Cookie Expiration Time** value is a number of
   seconds until the cookie expires. Set a zero value to disable
   expiration time and use a session cookie.
-  **Cookie SameSite value**: the value of the SameSite cookie attribute. By
   default, LemonLDAP::NG will set it to "Lax" in most cases, and "None" if you
   use federated authentiication like SAML or OIdC. Using "None" requires Secured Cookies,
   and accessing applications over HTTPS on most web browsers.


.. danger::

    When you change cookie expiration time, it is written on
    the user hard disk unlike session cookie


.. attention::

    Changing the domain value will not update other
    configuration parameters, like virtual host names, portal URL, etc. You
    have to update them by yourself.

Portal URL
----------

Portal URL is the address used to redirect users on the authentication
portal by:

-  **Handler**: user is redirected if he has no SSO cookie (or in
   :doc:`CDA<cda>` mode)
-  **Portal**: the portal redirect on itself in many cases (credentials
   POST, SAML, etc.)


.. danger::

    The portal URL **must** be inside SSO domain. If secured
    cookie is enabled, the portal URL **must** be HTTPS.
