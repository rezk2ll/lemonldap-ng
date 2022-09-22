CAS
===

============== ===== ========
Authentication Users Password
============== ===== ========
✔
============== ===== ========

Presentation
------------

LL::NG can delegate authentication to a CAS server. This requires `Perl
CAS module <http://sourcesup.cru.fr/projects/perlcas/>`__.


.. tip::

    LL::NG can also act as :doc:`CAS server<idpcas>`, that allows
    one to interconnect two LL::NG systems.

LL::NG can also request proxy tickets for its protected services. Proxy
tickets will be collected at authentication phase and stored in user
session under the form:

``_casPT<serviceID>`` = **Proxy ticket value**

They can then be forwarded to applications through
:ref:`HTTP headers<headers>`.

.. tip::

    CAS authentication will automatically add a
    :doc:`logout forward rule<logoutforward>` on CAS server logout URL in
    order to close CAS session on LL::NG logout.

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose CAS for authentication.


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

Then, go in ``CAS parameters``:

-  **Authentication level**: authentication level for this module.

Then create the list of CAS servers in the manager.

Options
~~~~~~~

-  **Server URL** *(required)*: CAS server URL (must use https://)
-  **Renew authentication** *(default: disabled)*: force authentication
   renewal on CAS server
-  **Gateways authentication** *(default: disabled)*: force transparent
   authentication on CAS server

Proxied services
~~~~~~~~~~~~~~~~

In this section, set the list of services for which a proxy ticket is
requested:

-  **Key**: Service ID
-  **Value** Service URL (CAS service identifier)

Display
~~~~~~~
-  **Display Name**: Name to display. Required if you have more than 1
   CAS server declared
-  **Icon**: Path to CAS Server icon. Used only if you have more than 1
   CAS server declared
-  **Resolution Rule**: rule that will be applied to preselect a CAS server for
   a user. You have access to all environment variable *(like user IP address)*
   and all session keys.

For example, to preselect this server for users coming from 129.168.0.0/16
network

::

   $ENV{REMOTE_ADDR} =~ /^192\.168/

To preselect this server when the ``MY_SRV`` :doc:`choice <authchoice>` is selected ::

    $_choice eq "MY_SRV"

-  **Order**: Number to sort CAS Servers display


.. tip::

    If no proxied services defined, CAS authentication will not
    activate the CAS proxy mode with this CAS server.
