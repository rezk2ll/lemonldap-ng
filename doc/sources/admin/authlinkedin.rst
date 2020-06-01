LinkedIn
========

============== ===== ========
Authentication Users Password
============== ===== ========
✔
============== ===== ========

Presentation
------------

`LinkedIn <https://www.linkedin.com/>`__ is a professional social
network. It uses `OAuth2 <http://en.wikipedia.org/wiki/OAuth2>`__
protocol to allow applications to reuse its own authentication process
(see https://developer.linkedin.com/docs/oauth2).

You need to register a new application on LinkedIn to get an application
ID and a secret. See https://www.linkedin.com/developer/apps/ on how to
do that.

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose LinkedIn for authentication module.

Then, go in ``LinkedIn parameters``:

-  **Authentication level**: authentication level for this module.
-  **Client ID**: the application ID you get
-  **Client secret**: the corresponding secret
-  **Searched fields** (deprecated): Fields requested on People endpoint
   in v1, no more used in v2 API
-  **Field containing user identifier**: Field that will be used as main
   user identifier in LL::NG, usually ``id`` (LinkedIn numeric
   identifer) or ``emailAddress``.
-  **Scope**: OAuth 2.0 scopes, use ``r_liteprofile`` to get first name
   and last name, and ``r_emailaddress`` to get email.


.. tip::

    Collected fields are stored in session in ``linkedIn_``
    keys


.. attention::

    Browser implementations of formAction directive are
    inconsistent (e.g. Firefox doesn't block the redirects whereas Chrome
    does). Administrators may have to modify formAction value with wildcard
    likes \*.

    In Manager, go in :

    ``General Parameters`` > ``Advanced Parameters`` > ``Security`` >
    ``Content Security Policy`` > ``Form destination``
