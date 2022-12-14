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

Then, go in ``CAS parameters``:

-  **Authentication level**: Authentication level for this module

.. attention::

    Browser implementations of formAction directive are inconsistent
    (e.g. Firefox doesn't block the redirects whereas Chrome does).
    Administrators may have to modify formAction value with wildcard
    likes \*.

    In Manager, go in :

    ``General Parameters`` > ``Advanced Parameters`` > ``Security`` >
    ``Content Security Policy`` > ``Form destination``


Then create CAS servers in the Manager.

Exported Attributes
~~~~~~~~~~~~~~~~~~~

The attributes defined here will completely replace any attributes you
may have declared in the global ``CAS Service`` configuration. In order
to re-use the global configuration, simply set this section to an empty
list.

Proxied services
~~~~~~~~~~~~~~~~

In this section, set the list of services for which a proxy ticket is
requested:

-  **Key**: Service ID
-  **Value**: Service URL (CAS service identifier)


Options
~~~~~~~

-  **Server URL** *(required)*: CAS server URL (must use \https://)
-  **Renew authentication** *(default: disabled)*: Force authentication
   renewal on CAS server
-  **Gateways authentication** *(default: disabled)*: Force transparent
   authentication on CAS server
-  **Comment**: set a comment

Display
~~~~~~~

Used only if at least 2 CAS servers are declared

-  **Name**: Name of the CAS server
-  **Logo**: Logo of the CAS server
-  **Tooltip**: Information displayed on mouse over the button
-  **Resolution rule**: Rule that will be applied to preselect a CAS server for
   a user. You have access to all environment variable *(like user IP address)*
   and all session keys

For example, to preselect this server for users coming from 129.168.0.0/16 network

::

   $ENV{REMOTE_ADDR} =~ /^192\.168/

To preselect this server when the ``MY_SRV`` :doc:`choice <authchoice>` is selected ::

    $_choice eq "MY_SRV"

-  **Order**: Used for sorting CAS server

.. tip::

    If no proxied services defined, CAS authentication will not
    activate the CAS proxy mode with this CAS server.