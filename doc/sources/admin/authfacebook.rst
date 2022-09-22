Facebook
========

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔
============== ===== ========

Presentation
------------

`Facebook <http://facebook.com>`__ is a famous social network service.
Facebook uses `OAuth2 <http://en.wikipedia.org/wiki/OAuth2>`__ protocol
to allow applications to reuse its own authentication process (it means,
if your are connected to Facebook, other applications can trust Facebook
and let you in).

You need
`Net::Facebook::Oauth2 <https://metacpan.org/release/Net-Facebook-Oauth2>`__
package.

You need to register a new application on Facebook to get an application
ID and a secret. See https://developers.facebook.com/apps on how to do
that.

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose Facebook for authentication module. You can also use Facebook
as user database.

Then, go in ``Facebook parameters``:

-  **Authentication level**: authentication level for this module.
-  **Facebook application ID**: the application ID you get
-  **Facebook application secret**: the corresponding secret
-  **User field**: Facebook field that will be used as default user
   identifier

If you use Facebook as user database, declare values in exported
variables:

-  use any key name you want. If you want to refuse access when a data
   is missing, just add a "!" before the key name
-  in the value field, set the field name. You can show them using
   `Facebook Graph API
   explorer <https://developers.facebook.com/tools/explorer>`__ and have
   a list of supported fields in the `Graph API User
   reference <https://developers.facebook.com/docs/graph-api/reference/user/>`__.
   For example:

   -  cn => name
   -  mail => email
   -  sn => last_name


.. attention::

    Do not query user field in exported variables, as it is
    already registered by the authentication module in ``$_user``.


.. attention::

    Browser implementations of formAction directive are
    inconsistent (e.g. Firefox doesn't block the redirects whereas Chrome
    does). Administrators may have to modify formAction value with wildcard
    likes \*.

    In Manager, go in :

    ``General Parameters`` > ``Advanced Parameters`` > ``Security`` >
    ``Content Security Policy`` > ``Form destination``


.. tip::

    You can use the same Facebook access token in your
    applications. It is stored in session data under the name ``$_facebookToken``\
