Passkeys / WebAuthn
===================

============== ===== ========
Authentication Users Password
============== ===== ========
✔
============== ===== ========

.. versionadded:: 2.20.0

|beta|

.. |beta| image:: /documentation/beta.png

Presentation
------------

This mode allow you to authenticate to LemonLDAP::NG using nothing but your FIDO2 credential.

Requirements
------------

As of version 2.20.0, authenticating with Passkeys requires enabling :doc:`webauthn2f`

.. important::

   Passkeys require the *Use discoverable credential* option to be set to *preferred* or *required*

   Non-discoverable credentials can only be used as second factors

Configuring passkeys as an alternate authentication method
----------------------------------------------------------

The simplest way to use Passkeys is to enable :doc:`authchoice` and add a new authentication choice using the *WebAuthn* module and your usual LDAP/AD/etc. user backend, in addition to another (LDAP/AD/etc.) authentication backend that users can use on their first login to register their passwordless credential.

Passwordless credentials have to be registered in the portal's *Second factor manager* at the moment.

Tips
----

Custom second factor activation rule
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you used custom rule to trigger *WebAuthn* second factors, you may notice that *WebAuthn* is asked *twice* in order to authenticate with passkeys. In order to prevent this, add ::

    and $_auth ne "WebAuthn"

to the *WebAuthn* activation rule.

You should also add this rule if you have enabled other 2FA types and want to skip them after authenticating with WebAuthn
