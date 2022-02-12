OpenID
======

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔
============== ===== ========


.. danger::

    OpenID protocol is deprecated. You should now use
    :doc:`OpenID Connect<authopenidconnect>`.

Presentation
------------

LL::NG can delegate authentication to an OpenID server. This requires
`Perl OpenID consumer
module <http://search.cpan.org/~mart/Net-OpenID-Consumer/>`__ with at
least version 1.0.


.. tip::

    LL::NG can also act as :doc:`OpenID server<idpopenid>`, that
    allows one to interconnect two LL::NG systems.

LL::NG will then display a form with an OpenID input, where users will
type their OpenID login.


.. tip::

    OpenID authentication can proposed as an alternate
    authentication scheme using the :doc:`authentication choice<authchoice>`
    method.

LL::NG can use a white list or a black list to filter allowed OpenID
domains.

If OpenID is used as users database, attributes will be requested to the
server with SREG extension.

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose OpenID for authentication and/or users.

Then, go in ``OpenID parameters``:

-  **Authentication level**: authentication level for this module.
-  **Secret token**: used to check integrity of OpenID response.
-  **Authorizated domain**:

   -  **List type**: choose white list to define allowed domains or
      black list to define forbidden domains
   -  **List**: domains list (comma separated values)

To configure requested attributes, edit **Exported variables** and
define attributes:

-  **Key**: internal session key, can be prefixed by ``!`` to make the
   attribute required
-  **Value**: SREG attribute name:

   -  fullname
   -  nickname
   -  language
   -  postcode
   -  timezone
   -  country
   -  gender
   -  email
   -  dob

See also :doc:`exported variables configuration<exportedvars>`.


.. attention::

    Browser implementations of formAction directive are inconsistent
    (e.g. Firefox doesn't block the redirects whereas Chrome
    does). Administrators may have to modify formAction value with wildcard
    likes \*.

    In Manager, go in:

    ``General Parameters`` > ``Advanced Parameters`` > ``Security`` >
    ``Content Security Policy`` > ``Form destination``
