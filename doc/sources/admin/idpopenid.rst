OpenID server
=============


.. danger::

    OpenID protocol is deprecated, you should now use
    :doc:`OpenID Connect<idpopenidconnect>`\

Presentation
------------

LL::NG can act as an OpenID 2.0 Server, that can allow one to federate
LL::NG with:

-  Another LL::NG system configured with
   :doc:`OpenID authentication<authopenid>`
-  Any OpenID consumer

LL::NG is compatible with the OpenID Authentication protocol `version
2.0 <http://openid.net/specs/openid-authentication-2_0.html>`__ and
`version
1.0 <http://openid.net/specs/openid-authentication-1_1.html>`__. It can
be used just to share authentication or to share user's attributes
following the `OpenID Simple Registration Extension 1.0
(SREG) <http://openid.net/specs/openid-simple-registration-extension-1_0.html>`__
specification.

When LL::NG is configured as OpenID identity provider, users can share
their authentication using [PORTAL]/openidserver/[login] where:

-  [PORTAL] is the portal URL
-  [login] is the user login (or any other session information,
   :ref:`see below<idpopenid-configuration>`)

Example:

::

   http://auth.example.com/openidserver/foo.bar

.. _idpopenid-configuration:

Configuration
-------------

In the Manager, go in ``General Parameters`` » ``Issuer modules`` »
``OpenID`` and configure:

-  **Activation**: set to ``On``
-  **Path**: keep ``^/openidserver/`` unless you have change
   :ref:`Apache portal configuration<configlocation-portal>` file.
-  **Use rule**: a rule to allow user to use this module, set to 1 to
   always allow.


.. tip::

    For example, to allow only users with a strong authentication
    level:

    ::

       $authenticationLevel > 2



Then go in ``Options`` to define:

-  **Secret token**: a secret token used to secure transmissions between
   OpenID client and server (:ref:`see below<idpopenid-security>`).
-  **OpenID login**: the session key used to match OpenID login.
-  **Authorized domains**: white list or black list of OpenID client
   domains (:ref:`see below<idpopenid-security>`).
-  **SREG mapping**: link between SREG attributes and session keys
   (:ref:`see below<idpopenid-shared-attributes-sreg>`).


.. tip::

    If ``OpenID login`` is not set, it uses ``General Parameters``
    » ``Logs`` » ``REMOTE_USER`` data, which is set to ``uid`` by
    default

.. _idpopenid-shared-attributes-sreg:

Shared attributes (SREG)
~~~~~~~~~~~~~~~~~~~~~~~~

`SREG <http://openid.net/specs/openid-simple-registration-extension-1_0.html>`__
permit the share of 8 attributes:

-  Nick name
-  Email
-  Full name
-  Date of birth
-  Gender
-  Postal code
-  Country
-  Language
-  Timezone

Each SREG attribute will be associated to a user session key. A session
key can be associated to more than one SREG attribute.


.. note::

    If the OpenID consumer ask for data, users will be prompted to
    accept or not the data sharing.

.. _idpopenid-security:

Security
~~~~~~~~

-  LL::NG can be configured to restrict OpenID exchange using a white or
   a black list of domains.
-  If not set, the secret token is calculated using the general
   encryption key.


.. attention::

    Note that :doc:`SAML<idpsaml>` protocol is more secured
    than OpenID, so when your partners are known, prefer
    :doc:`SAML<idpsaml>`.
