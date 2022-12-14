Second Factors
==============

Two-Factor Authentication *(as known as 2FA)* is a kind (subset) of
`multi-factor
authentication <https://en.wikipedia.org/wiki/Multi-factor_authentication>`__.
It is a method to confirm a user's claimed identity by using a
combination of two different factors between:

#. something they know *(login / password, …)*
#. something they have *(U2F Key, smartphone, …)*
#. something they are *(biometrics like fingerprints, ...)*

Since 2.0, LL::NG provides some second factor plugins that can be used for
completing authentication module with 2FA:

Second factors that can be registered by the user:

-  :doc:`TOTP<totp2f>` *(to use with* `FreeOTP <https://freeotp.github.io/>`__\ *,*\ `Google-Authenticator <https://en.wikipedia.org/wiki/Google_Authenticator>`__\ *,…)*
-  :doc:`WebAuthn<webauthn2f>` *(Web Authentication API)*
-  :doc:`Yubico OTP<yubikey2f>` *(Legacy OTP method from Yubico)*
-  :doc:`U2F tokens<u2f>` |deprecated|
-  :doc:`U2F-or-TOTP<utotp2f>` *(enable both U2F and TOTP)* |deprecated|

Second factors that rely on external systems:

-  :doc:`E-Mail 2F<mail2f>` *(Send a code to an email address)*
-  :doc:`External 2F<external2f>` *(to call an external command)*
-  :doc:`REST<rest2f>` *(Remote REST app)*
-  :doc:`RADIUS<radius2f>` *(Remote RADIUS server)*

.. |deprecated| image:: /documentation/deprecated.png
   :alt: deprecated

The E-Mail, External and REST 2F modules
:doc:`may be declared multiple times<sfextra>` with different sets of
parameters.


Self-care on Portal
-------------------

User may register second factors themselves on the Portal by using the 2FA Manager.

The link will be displayed if at least one SFA module is enabled. You can set a
rule to display or not the link.

Registration on first use
-------------------------

If you want to force a 2F registration on first login, you can use the *Force
2FA registration at login* option.

You can use a :doc:`rule <writingrulesand_headers>` to enable this behavior only for
some users.

Session upgrade through 2FA
---------------------------

|beta| 

If you enable the *Use 2FA for session upgrade* option, second factor will only
be asked on login if the target application requires an authentication level
that is strictly higher than the one obtained by the Authentication backend
(first factor).

The session upgrade mechanism will only require the second factor step, instead
of doing a complete reauthentication.

.. tip::

    You can disable the upgrade confirmation by setting on the *Skip upgrade confirmation*
    option.

    Go in Manager, ``General Parameters`` » ``Advanced parameters`` » ``Portal redirections``.

.. |beta| image:: /documentation/beta.png

Login timeout
-------------

Allowed time for the user to authenticate using their second factor. By default
it is set to 2 minutes, but some complex second factor types (TOTP, email...)
may require more time to be used.

Registration timeout
--------------------

Allowed time for the user to register their new second factor. By default it is
set to 2 minutes, but some complex second factor types (TOTP...) may require
more time to be registered.

Second factor expiration
------------------------

You can display a message if an expired second factor has been removed by
enabling *Display a message if an expired SF is removed* option or setting a
rule.
SF name(s) or number of removed SF can be displayed in message BODY by using
`_nameSF_` or `_removedSF_` respectively.

Providing tokens from an external source
----------------------------------------

If you do not want to use self-registration features for U2F, TOTP and so
on, you can set devices by yourself *(in your LDAP server for example)*
and map it to ``_2fDevices`` attribute. ``_2fDevices`` is a JSON array
that contains device descriptions :

.. code::

   [ {"type" : "TOTP", "name" : "MyTOTP", …}, {<other_device>}, …]

U2F Device
~~~~~~~~~~

.. code-block:: json

   {"name" : "MyU2FKey" , "type" : "U2F" , "_userKey" : "########" , "_keyHandle":"########" , "epoch":"1524078936"}

TOTP Device
~~~~~~~~~~~

.. code-block:: json

   {"name" : "MyTOTP" , "type" : "TOTP" , "_secret" : "########" , "epoch" : "1523817955"}

Yubico OTP Device
~~~~~~~~~~~~~~~~~

.. code-block:: json

   {"name" : "MyYubikey" , "type" : "UBK" , "_yubikey" : "########" , "epoch" : "1523817715"}

Developer corner
----------------

To develop a new 2FA plugin, read
``Lemonldap::NG::Portal::Main::SecondFactor (3pm)`` manpage. Your 2F
module must be a Perl class named
``Lemonldap::NG::Portal::2F:://<custom_name>//``. To enable it, set
``available2F`` key in your ``lemonldap-ng.ini`` file :

.. code-block:: ini

   [portal]
   available2F = U2F,TOTP,<custom_name>

To enable manager Second Factor Administration Module, set
``enabledModules`` key in your ``lemonldap-ng.ini`` file :

.. code-block:: ini

   [portal]
   enabledModules = conf, sessions, notifications, 2ndFA
