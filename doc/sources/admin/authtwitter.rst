Twitter
=======

============== ===== ========
Authentication Users Password
============== ===== ========
✔
============== ===== ========

Presentation
------------

`Twitter <https://twitter.com>`__ is a famous microblogging server.
Twitter use `OAuth <http://en.wikipedia.org/wiki/OAuth>`__ protocol to
allow applications to reuse its own authentication process (it means, if
your are connected to Twitter, other applications can trust Twitter and
let you in).

You need `Net::Twitter <http://search.cpan.org/~mmims/Net-Twitter/>`__
package, with a very recent version (>3).

You need to register a new application on Twitter to get API key and API
secret. See `Twitter FAQ <http://dev.twitter.com/pages/api_faq>`__ on
how to do that:.

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose Twitter for authentication module.


.. tip::

    You can then choose any other module for users and
    password.


.. attention::

    Browser implementations of formAction directive are
    inconsistent (e.g. Firefox doesn't block the redirects whereas Chrome
    does). Administrators may have to modify formAction value with wildcard
    likes \*.

    In Manager, go in :

    ``General Parameters`` > ``Advanced Parameters`` > ``Security`` >
    ``Content Security Policy`` > ``Form destination``

Then, go in ``Twitter parameters``:

-  **Authentication level**: authentication level for this module.
-  **API key**: API key from Twitter
-  **API secret**: API secret from Twitter
-  **Application name** (optional): Application name (visible in
   Twitter)
-  **User field**: Twitter field that will be used as default user
   identifier. Allowed values:

   -  ``screen_name``
   -  ``user_id``
