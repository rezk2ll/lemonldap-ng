SAML
====

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔
============== ===== ========

Presentation
------------

LL::NG can use SAML2 to get user identity and grab some attributes
defined in user profile on its Identity Provider (IDP). In this case,
LL::NG acts like an SAML2 Service Provider (SP).

Several IDPs are allowed, in this case the user will choose the IDP he
wants. You can preselect IDP with an IDP resolution rule.

For each IDP, you can configure attributes that are collected. Some can
be mandatory, so if they are not returned by IDP, the session will not
open.


.. tip::

    LL::NG can also act as :doc:`SAML IDP<idpsaml>`, that allows
    one to interconnect two LL::NG systems.

Configuration
-------------

SAML Service
~~~~~~~~~~~~

See :doc:`SAML service<samlservice>` configuration chapter.


.. attention::

    Browser implementations of formAction directive are
    inconsistent (e.g. Firefox doesn't block the redirects whereas Chrome
    does). Administrators may have to modify formAction value with wildcard
    likes \*.

    In Manager, go in :

    ``General Parameters`` > ``Advanced Parameters`` > ``Security`` >
    ``Content Security Policy`` > ``Form destination``

Authentication and UserDB
~~~~~~~~~~~~~~~~~~~~~~~~~

In ``General Parameters`` > ``Authentication modules``, set:

-  Authentication module: SAML v2
-  Users module: Same (eq SAML)


.. tip::

    As passwords will not be managed by LL::NG, you can disable
    :ref:`menu password module<portalmenu-menu-modules>`.

Register LemonLDAP::NG on partner Identity Provider
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After configuring SAML Service, you can export metadata to your partner
Identity Provider.

They are available at the EntityID URL, by default:
http://auth.example.com/saml/metadata. You can also use
http://auth.example.com/saml/metadata/sp to have only SP related
metadata.

Register partner Identity Provider on LemonLDAP::NG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the Manager, select node ``SAML identity providers`` and click on
``Add SAML IDP``. The IDP name is asked, enter it and click OK.

Metadata
^^^^^^^^

You must register IDP metadata here. You can do it either by uploading
the file, or get it from IDP metadata URL (this require a network link
between your server and the IDP):

|image0|


.. tip::

    You can also edit the metadata directly in the textarea

Exported attributes
^^^^^^^^^^^^^^^^^^^

For each attribute, you can set:

-  **Variable name**: name of the variable in LemonLDAP::NG session that will contain this attribute. For example
   "uid" will then be used as $uid in access rules
-  **Attribute name**: name of the SAML attribute coming from the remote IDP
-  **Friendly Name**: optional, SAML attribute friendly name.
-  **Mandatory**: if set to On, then session will not open if this
   attribute is not given by IDP.
-  **Format** (optional): SAML attribute format.

|image1|

Options
^^^^^^^

General options
'''''''''''''''

-  **Resolution Rule**: rule that will be applied to preselect an IDP
   for a user. You have access to all environment variable *(like user
   IP address)* and all session keys.

For example, to preselect this IDP for users coming from 129.168.0.0/16
network and member of "admin" group:

::

   $ENV{REMOTE_ADDR} =~ /^192\.168/ and $groups =~ /\badmin\b/

Authentication request
''''''''''''''''''''''

-  **NameID format**: force NameID format here (email, persistent,
   transient, etc.). If no value, will use first NameID Format activated
   in metadata.
-  **Force authentication**: set ForceAuthn flag in authentication
   request
-  **Passive authentication**: set IsPassive flag in authentication
   request
-  **Allow proxied authentication**: allow an authentication response to
   be issued from another IDP that the one we register (proxy IDP). If
   you disallow this, you should also disallow direct login form IDP,
   because proxy restriction is set in authentication requests.
-  **Allow login from IDP**: allow a user to connect directly from an
   IDP link. In this case, authentication is not a response to an issued
   authentication request, and we have less control on conditions.
-  **Requested authentication context**: this context is declared in
   authentication request. When receiving the request, the real
   authentication context will be mapped to an internal authentication
   level (see
   :ref:`how configure the mapping<samlservice-authentication-contexts>`),
   that you can check to allow or deny session creation.
-  **Allow URL as RelayState**: Set to On if the RelayState value sent
   by IDP is the URL where the user must be redirected after
   authentication.

Session
'''''''

-  **Adapt session lifetime**: session lifetime will be adapted from
   ``SessionNotOnOrAfter`` value found in authentication response. It
   means that if the IDP propose to close session earlier than the
   default LemonLDAP::NG timeout, the session \_utime will be modified
   so that session is erased at the date indicated by the IDP.
-  **Force UTF-8**: this will force UTF-8 conversion of attributes
   values collected from IDP.
-  **Store SAML Token**: allows one to keep SAML token (assertion)
   inside user session. Don't enable it unless you need to replay this
   token on an application.
-  **Attribute containing user identifier**: set the value of SAML
   attribute ("Name") that should be used as user main identifier
   ($user). If empty, the NameID content is used.

Signature
'''''''''

These options override service signature options (see
:ref:`SAML service configuration<samlservice-general-options>`).

-  **Signature method**: signature method for requests sent to this provider
-  **Sign SSO message**: sign SSO message
-  **Check SSO message signature**: check SSO message signature
-  **Sign SLO message**: sign SLO message
-  **Check SLO message signature**: check SLO message signature

Binding
'''''''

-  **SSO binding**: force binding to use for SSO (http-redirect,
   http-post, etc.)
-  **SLO binding**: force binding to use for SLO (http-redirect,
   http-post, etc.)


.. note::

    If no binding defined, the default binding in IDP metadata will be
    used.

Security
''''''''

-  **Encryption mode**: set the encryption mode for this IDP (None,
   NameID or Assertion).
-  **Check time conditions**: set to Off to disable time conditions
   checking on authentication responses.
-  **Check audience conditions**: set to Off to disable audience
   conditions checking on authentication responses.

Display
'''''''

Used only if you have more than 1 SAML Identity Provider declared

-  **Display name**: Name of the IDP
-  **Logo**: Logo of the IDP
-  **Order**: Number to sort IDP display


.. tip::

    The chosen logo must be in Portal icons directory
    (``portal/static/common/``). You can set a custom icon by setting the
    icon file name directly in the field and copy the logo file in portal
    icons directory

.. |image0| image:: /documentation/manager-saml-metadata.png
   :class: align-center
.. |image1| image:: /documentation/manager-saml-attributes.png
   :class: align-center

