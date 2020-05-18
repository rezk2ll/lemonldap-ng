CAS server
==========

Presentation
------------

LL::NG can be used as a CAS server. It can allow one to federate LL::NG
with:

-  Another :doc:`CAS authentication<authcas>` LL::NG provider
-  Any CAS consumer

LL::NG is compatible with the `CAS
protocol <https://jasig.github.io/cas/development/protocol/CAS-Protocol-Specification.html>`__
versions 1.0, 2.0 and part of 3.0 (attributes exchange).

Configuration
-------------

Enabling CAS
~~~~~~~~~~~~

In the Manager, go in ``General Parameters`` » ``Issuer modules`` »
``CAS`` and configure:

-  **Activation**: set to ``On``.
-  **Path**: it is recommended to keep the default value (``^/cas/``)
-  **Use rule**: a rule to allow user to use this module, set to ``1``
   to always allow.


.. tip::

    For example, to allow only users with a strong authentication
    level:

    ::

       $authenticationLevel > 2


.. _idpcas-configuring-cas-applications:

Configuring the CAS Service
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Then go in ``CAS Service`` to define:

-  **CAS login**: the session key transmitted to CAS client as the main
   identifier (CAS Principal). This setting can be overriden
   per-application.
-  **CAS attributes**: list of attributes that will be transmitted by
   default in the validate response. Keys are the name of attribute in
   the CAS response, values are the name of session key.
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

-  **CAS session module name and options**: choose a specific module if
   you do not want to mix CAS sessions and normal sessions (see
   :ref:`why<samlservice-saml-sessions-module-name-and-options>`).


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

-  **Service URL** : the service (user-facing) URL of the CAS-enabled
   application.
-  **User attribute** : session field that will be used as main
   identifier.
-  **Rule** : The access control rule to enforce on this application. If
   left blank, access will be allowed for everyone.


.. important::

    If the access control policy is set to ``none``, this
    rule will be ignored

Macros
^^^^^^

You can define here macros that will be only evaluated for this service,
and not registered in the session of the user.
