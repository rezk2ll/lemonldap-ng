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

Since 2.0, LLNG provides some second factor plugins that can be used to
complete authentication module with 2FA :

-  :doc:`U2F-or-TOTP<utotp2f>` *(enable both U2F and TOTP)*
-  :doc:`TOTP<totp2f>` *(to use
   with* `FreeOTP <https://freeotp.github.io/>`__\ *,*\ `Google-Authenticator <https://en.wikipedia.org/wiki/Google_Authenticator>`__\ *,…)*
-  :doc:`U2F tokens<u2f>`
-  :doc:`Yubikey tokens<yubikey2f>` *(provided by Yubico)*
-  :doc:`E-Mail 2F<mail2f>` *(Send a code to an email address)*
-  :doc:`External 2F<external2f>` *(to call an external command)*
-  :doc:`REST<rest2f>` *(Remote REST app)*
-  :doc:`RADIUS<radius2f>` *(Remote RADIUS server)*

The E-Mail, External and REST 2F modules
:doc:`may be declared multiple times<sfextra>` with different sets of
parameters.


.. tip::

    If you want to force a 2F registration on first login, you can
    use 'Require 2FA'. You can also use a rule to force 2FA registration
    only for some users.
.. tip::

    You can display a message if an
    expired second factor has been removed by enabling 'Display a message if
    an expired SF is removed' option or setting a rule.

.. tip::

    Link to second factor Manager is automatically display if at least a
    SFA module is enabled. You can set a rule to display or not the
    link.

Providing tokens from an external source
----------------------------------------

If you don't want to use self-registration features for U2F, TOTP and so
on, you can set tokens by yourself *(in your LDAP server for example)*
and map it to ``_2fDevices`` attribute. ``_2fDevices`` is a JSON array
that contains token descriptions :

.. code:: json

   [ {"type" : "TOTP", "name" : "MyTOTP", …}, {<other_token>}, …]

U2F Tokens
~~~~~~~~~~

.. code:: json

   {"name" : "MyU2FKey" , "type" : "U2F" , "_userKey" : "########" , "_keyHandle":"########" , "epoch":"1524078936"}

TOTP Tokens
~~~~~~~~~~~

.. code:: json

   {"name" : "MyTOTP" , "type" : "TOTP" , "_secret" : "########" , "epoch" : "1523817955"}

Yubikey Tokens
~~~~~~~~~~~~~~

.. code:: json

   {"name" : "MyYubikey" , "type" : "UBK" , "_yubikey" : "########" , "epoch" : "1523817715"}

Developer corner
----------------

To develop a new 2FA plugin, read
``Lemonldap::NG::Portal::Main::SecondFactor (3pm)`` manpage. Your 2F
module must be a Perl class named
``Lemonldap::NG::Portal::2F:://<custom_name>//``. To enable it, set
``available2F`` key in your ``lemonldap-ng.ini`` file :

.. code:: ini

   [portal]
   available2F = U2F,TOTP,<custom_name>

To enable manager Second Factor Administration Module, set
``enabledModules`` key in your ``lemonldap-ng.ini`` file :

.. code:: ini

   [portal]
   enabledModules = conf, sessions, notifications, 2ndFA

