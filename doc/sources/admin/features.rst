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
customize the portal.

Easy to integrate
-----------------

:doc:`Integrating applications<applications>` in
LL::NG is easy since its dialogue with applications is based on
:ref:`customizable HTTP headers<headers>`.

Unifying authentications (Identity Federation)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LL::NG can easily exchange with other authentication systems by using
SAML, OpenID or CAS protocoles. It may be the backbone of a
heterogeneous architecture.

LL:NG can be set as Identity provider,
Service Provider or Protocol Proxy
(:doc:`LL::NG as federation protocol proxy<federationproxy>`).

Its REST / SOAP API can also be used to dialogue directly with your custom
applications.

Sessions
--------

.. _session-explorer:

Session explorer
~~~~~~~~~~~~~~~~

LL::NG Manager has a session explorer module that can be used to browse
opened sessions:

-  by users
-  by IP *(IPv4 and IPv6)*
-  by double IP (sessions opened by the same user from multiple computers)
-  by date

It can be used to delete a session

.. _session-restrictions:

Session restrictions
~~~~~~~~~~~~~~~~~~~~

By default, a user can open several :doc:`sessions<sessions>`.
LL::NG can restrict the following:

-  Allow only one session per user
-  Allow only one IP address per user
-  Allow only one user per IP address

Those capabilities can be used simultaneously or separately.

Double cookie
~~~~~~~~~~~~~

LL::NG can be configured to provides :doc:`2 cookies<ssocookie>`:

-  one secured (SSL only) for sensitive applications
-  one unsecured for other applications

So that if the http cookie is stolen, sensitive applications remain secured.


Notifications
-------------

LL::NG can be used to notify users with a message when authenticating. This can be used to
inform of a change in access rights, the publication of a new IT charter, etc...
(See :doc:`notifications<notifications>` for more details)
