Remote
======

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔
============== ===== ========


.. danger::

    This module is a LL::NG specific identity federation
    protocol. You may rather use standards protocols like
    :doc:`SAML<idpsaml>`, :doc:`OpenID Connect<idpopenidconnect>` or
    :doc:`CAS<idpcas>`.

Presentation
------------

-  The main portal is configured to use CDA. The secondary portal is
   declared in the Manager of the main LL::NG structure (else user will
   be rejected).
-  The portal of the secondary LL::NG structure is configured to
   delegate authentication to a remote portal. A request to the main
   session database is done (through
   :doc:`SOAP session backend<soapsessionbackend>`) to be sure that the
   session exists.
-  If ``exportedAttr`` is set, only those attributes are copied in the
   session database of the secondary LL::NG structure. Else, all data
   are copied in the session database.

|image0|

#. User tries to access to an application in the secondary LL::NG
   structure without having a session in this area
#. Redirection to the portal of the secondary area (transparent)
#. Redirection to the portal of the main area and normal authentication
   (if not done before)
#. Redirection to the portal of the secondary area (transparent)
#. Secondary portal check if remote session is available. It can be done
   via direct access to the session database or using SOAP access. Then
   it creates the session (with attribute filter)
#. User can now access to the protected application


.. note::

    Note that if the user is already authenticated on the first
    portal, all redirections are transparent.

Configuration
-------------

Main LL::NG structure
~~~~~~~~~~~~~~~~~~~~~

Go in Manager, and:

-  activate CDA in ``General Parameters`` » ``Cookies`` »
   ``Multiple domains``
-  declare secondary portal in ``General Parameters`` »
   ``Advanced Parameters`` » ``Security`` » ``Trusted domains``

Secondary LL::NG structure
~~~~~~~~~~~~~~~~~~~~~~~~~~

Configure the portal to use the remote LL::NG structure.

In Manager, go in ``General Parameters`` » ``Authentication modules``
and choose Remote for authentication and users.

Then, go in ``Remote parameters``:

-  **Portal URL**: remote portal URL
-  **Cookie name** (optional): name of the cookie of primary portal, if
   different from secondary portal
-  **Sessions module**: set
   ``Lemonldap::NG::Common::Apache::Session::SOAP`` for
   :doc:`SOAP session backend<soapsessionbackend>`.
-  **Sessions module options**:

   -  **proxy**: SOAP sessions end point (see
      :doc:`SOAP session backend<soapsessionbackend>` documentation)

Example: interoperability between 2 organizations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Using this, we can do a very simple interoperability system between 2
organizations using two LL::NG structures:

-  each area has 2 portals:

   -  One standard portal
   -  One remote portal that delegates authentication to the second
      organization (just another file on the same server)

-  The normal portal has a link included in the authentication form
   pointing to the remote portal for the users of the other organization

So on each main portal, internal users can access normally, and users
issued from the other organization have just to click on the link:

|image1|

#. One user tries to access to the portal
#. External user clicks to be redirected to the remote type portal
#. After redirection, normal authentication in the remote portal
#. Redirection to the remote type portal
#. Validation of the session: external user has now a local session

.. |image0| image:: /documentation/remote-principle.png
   :class: align-center
.. |image1| image:: /documentation/remote-interoperability.png
   :class: align-center

