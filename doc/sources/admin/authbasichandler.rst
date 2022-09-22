AuthBasic Handler
=================

Presentation
------------

The AuthBasic Handler is a special Handler using AuthBasic method to
authenticate and grante access to a virtual host.

The Handler sends a WWW-Authenticate header to the client, to request
user id and password. Then it checks credentials by using LL::NG REST
web service (REST session service must be enabled in the manager). Once
session is granted, the Handler will check authorizations like the
standard Handler.

This feature can be useful to allow a third party application to access
a virtual host with user credentials by sending a Basic challenge to it.

Configuration
-------------

Portal
~~~~~~

:doc:`REST server<restservices>` must be enabled on portal.

Virtual host
~~~~~~~~~~~~

You just have to set "Type: AuthBasic" in the virtualHost options in the
manager.

If you want to protect only a virtualHost part, keep type on "Main" and
set type in your configuration file:

-  Apache: use simply a ``PerlSetVar VHOSTTYPE AuthBasic``
-  Nginx: create another FastCGI with a
   ``fastcgi_param VHOSTTYPE AuthBasic;`` *(and remove error_page 401)*

Handler parameters
~~~~~~~~~~~~~~~~~~

No parameters needed. But you have to allow REST sessions web services,
see :doc:`REST sessions backend<restsessionbackend>`, enable local cache
(enabled by default in lemonldap-ng.ini) and allow source IP addresses
to access required locations in Portal Virtual Host.


.. danger::

    With AuthBasic Handler, you have to disable CSRF token by
    setting a special rule based on source IP addresses like this :

    requireToken => $env->{REMOTE_ADDR} !~ /^127\.0\.[1-3]\.1$/

    With :doc:`authchoice`, you have to declare which authentication module is
    requested by the AuthBasic Handler to create global session.

    Go to:
    ``General Parameters > Authentication parameters > Choice parameters``

    and set authentication module's name :

    **Choice used for password authentication** => 2_LDAP (by example)


.. attention::

    With HTTPS, you may have to set **LWP::UserAgent object**
    with ``verify_hostname => 0`` and ``SSL_verify_mode => 0``.

    Go to:

    ``General Parameters > Advanced Parameters > Security > SSL options for server requests``

