CAS server
==========

Presentation
------------

LL::NG can be used as a CAS server. It can allow one to federate LL::NG with:

-  Another :doc:`CAS authentication<authcas>` LL::NG provider
-  Any CAS consumer

LL::NG is compatible with the `CAS protocol <https://apereo.github.io/cas/6.5.x/index.html>`__
versions 1.0, 2.0 and part of 3.0 (attributes exchange).

Configuration
-------------

Enabling CAS
~~~~~~~~~~~~

In the Manager, go in ``General Parameters`` » ``Issuer modules`` » ``CAS`` and configure:

-  **Activation**: set to ``On``.
-  **Path**: it is recommended to keep the default value (``^/cas/``)
-  **Use rule**: a rule to allow user to use this module, set to ``1``
   to always allow.


.. tip::

    For example, to allow only users with a strong authentication level:

    ::

       $authenticationLevel > 2


.. _idpcas-configuring-cas-applications:

Configuring the CAS Service
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Then go in ``CAS Service`` to define:

-  **CAS login**: the session key transmitted to CAS client as the main
   identifier (CAS Principal). This setting can be overridden
   per-application.
-  **Access control policy**: define if access control should be done on
   CAS service. Three options:

   -  **none**: no access control. The CAS service will accept
      non-declared CAS applications and ignore access control rules.
      This is the default.
   -  **error**: if user has no access, an error is shown on the portal,
      the user is not redirected to CAS service
   -  **faketicket**: if the user has no access, a fake ticket is built,
      and the user is redirected to CAS service. Then CAS service has to
      show a correct error when service ticket validation will fail.

-  **Use strict URL matching**: (since *2.0.12*) enforces a stricter URL
   matching. By default, LemonLDAP::NG will try to find a declared CAS
   Application matching the hostname of the requested application if it cannot
   find a match using the full path. See :ref:`idpcas-url-matching` for details
-  **Temporary ticket lifetime**: (since *2.0.14*): restricts how long Service
   and Proxy tickets are valid after being generated. For compatibility, the
   default value of ``0`` means they are valid for the entire session duration.
   But the CAS spefications recommends ``300`` (5 minutes).
-  **CAS session module name and options**: choose a specific module if
   you do not want to mix CAS sessions and normal sessions (see
   :ref:`why<samlservice-saml-sessions-module-name-and-options>`).
-  **CAS attributes**: list of attributes that will be transmitted by
   default in the validate response. Keys are the name of attribute in
   the CAS response, values are the name of session key.


.. tip::

    If ``CAS login`` is not set, it uses ``General Parameters`` »
    ``Logs`` » ``REMOTE_USER`` data, which is set to ``uid`` by
    default

.. _idpcas-configuring-the-cas-service:

Configuring CAS Applications
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If an access control policy other than ``none`` is specified,
applications that want to authenticate users through the CAS protocol
have to be declared before LemonLDAP::NG accepts to issue service
tickets for them.

Go to ``CAS Applications`` and then ``Add CAS Application``. Give a
technical name (no spaces, no special characters), like "app-example".

You can then access the configuration of this application.

Exported Attributes
^^^^^^^^^^^^^^^^^^^

You may add a list of attributes that will be transmitted in the
validate response. Keys are the name of attribute in the CAS response,
values are the name of session key.

The attributes defined here will completely replace any attributes you
may have declared in the global ``CAS Service`` configuration. In order
to re-use the global configuration, simply set this section to an empty
list.

Options
^^^^^^^

-  **Service URL**: the service (user-facing) URL of the CAS-enabled
   application. See :ref:`idpcas-url-matching`
-  **User attribute**: session field that will be used as main
   identifier.
-  **Authentication Level**: required authentication level to access this
   application
-  **Access rule**: access rule to enforce on this application. If
   left blank, access will be allowed for everyone.
-  **Comment**: set a comment


.. attention::

    If the access control policy is set to ``none``, this
    rule will be ignored

Macros
^^^^^^

You can define here macros that will be only evaluated for this service,
and not registered in the session of the user.

.. _idpcas-url-matching:

URL Matching
^^^^^^^^^^^^

.. versionchanged:: 2.0.10

Before version 2.0.10, only the hostname was taken into account, which made it impossible to have two different CAS services behind the same hostname.

Since version 2.0.10, the entire service URL is compared to the Service URL defined in LemonLDAP::NG. The longest prefix wins.

For example, if you declared two applications in LemonLDAP::NG with the following service URLs:

* https://cas.example.com/applications/zone1
* https://cas.example.com/applications/

An application located at https://cas.example.com/applications/zone1/myapp will match the first CAS service definition

An application located at https://cas.example.com/undeclared/ will also be accepted in order to preserve the previous behavior of matching on hostnames only.

.. versionchanged:: 2.0.12

   The *Strict URL matching* option now lets you decide if LemonLDAP::NG should
   fall back to legacy host-based matching if it cannot find a declared service
   matching an incoming service URL. In the previous example,
   https://cas.example.com/undeclared/ will no longer match if strict URL
   matching is enabled
