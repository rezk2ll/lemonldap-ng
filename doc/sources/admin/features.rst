Main features
=============

Full access control
-------------------

LL::NG is a web single-sign-on system, but unlike some systems it can
manage rights on applications based on regular expressions on URL.

Easy to customize
-----------------

LL::NG is designed using `Model–View–Controller software
architecture <http://en.wikipedia.org/wiki/Model%E2%80%93View%E2%80%93Controller>`__,
so you just have to
:doc:`change HTML/CSS files<portalcustom>` to
custom portal.

Easy to integrate
-----------------

:doc:`Integrating applications<applications>` in
LL::NG is easy since its dialog with applications is based on
:doc:`customizable HTTP headers<writingrulesand_headers>`.

Unifying authentications (Identity Federation)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LL::NG can easily exchange with other authentication systems by using
SAML, OpenID or CAS protocoles. It may be the backbone of a
heterogeneous architecture. LL:NG can be set as Identity provider,
Service Provider or Protocol Proxy
(:doc:`LL::NG as federation protocol proxy<federationproxy>`).

Its SOAP API can also be used to dialog directly with your custom
applications.

Sessions
--------

Session explorer
~~~~~~~~~~~~~~~~

LL::NG Manager has a session explorer module that can be used to browse
opened sessions:

-  by users
-  by IP *(IPv4 and IPv6)*
-  by date
-  by double IP (sessions opened by the same user from multiple
   computers)

It can be used to delete a session

Session restrictions
~~~~~~~~~~~~~~~~~~~~

By default, a user can open several
:doc:`sessions<sessions>`. LL::NG can restrict
this:

-  Allow only one session per user
-  Allow only one IP address per user
-  Allow only one user per IP address

Those capabilities can be used simultaneously or separately.

Double cookie
~~~~~~~~~~~~~

LL::NG can be configured to provides
:doc:`2 cookies<ssocookie>`:

-  one secured (SSL only) for sensitive applications
-  one unsecured for other applications

So if the http cookie is stolen, sensitive applications stay secured.

Notifications
-------------

LL::NG can be used to prompt users with a message. This can be used to
notify right changes,... See
:doc:`notifications<notifications>` for more.
