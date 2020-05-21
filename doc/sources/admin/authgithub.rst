GitHub
======

============== ===== ========
Authentication Users Password
============== ===== ========
✔
============== ===== ========

Presentation
------------

`GitHub <https://github.com/>`__ uses
`OAuth2 <http://en.wikipedia.org/wiki/OAuth2>`__ protocol to allow
applications to reuse its own authentication process (see
https://developer.github.com/apps/building-oauth-apps/authorizing-oauth-apps/).

You need to register a new application on LinkedIn to get an application
ID and a secret: https://github.com/settings/apps/new.

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose GitHub for authentication module.

Then, go in ``GitHub parameters``:

-  **Authentication level**: authentication level for this module.
-  **Client ID**: the application ID you get
-  **Client secret**: the corresponding secret
-  **Field containing user identifier**: Field that will be used as main
   user identifier in LL::NG, usually ``login``
-  **Scope**: OAuth 2.0 scopes, see
   https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/


.. tip::

    Collected fields are stored in session in ``github_``
    keys


.. attention::

    Browser implementations of formAction directive are
    inconsistent (e.g. Firefox doesn't block the redirects whereas Chrome
    does). Administrators may have to modify formAction value with wildcard
    likes \*.

    In Manager, go in:

    ``General Parameters`` > ``Advanced Parameters`` > ``Security`` >
    ``Content Security Policy`` > ``Form destination``
