Universal 2nd Factor Authentication (U2F)
=========================================

`Universal 2nd
Factor <https://en.wikipedia.org/wiki/Universal_2nd_Factor>`__ (U2F) is
an open authentication standard that strengthens and simplifies
two-factor authentication using specialized USB or NFC devices.

LLNG can propose to users to register their keys. When done, 2F
registered users can not login without using their key.

.. warning::

    Since February 2022, U2F is considered to be deprecated in Chrome and its
    derivatives. Administrators must migrate to :doc:`WebAuthn <webauthn2f>`
    instead. U2F security keys are compatible with WebAuthn but require a
    :ref:`migration step <migrateu2ftowebauthn>` to be performed in
    LemonLDAP::NG.

Prerequisites and dependencies
------------------------------

This feature uses
`Crypt::U2F::Server::Simple <https://metacpan.org/pod/Crypt::U2F::Server::Simple>`__.

It is available as package on Debian:

::

   apt install libcrypt-u2f-server-perl

For other systems, use CPAN. Before compiling it, you must install
Yubico's C library headers.


.. attention::

    An HTTPS portal is required to use U2F

Configuration
-------------

In the manager (second factors), you just have to enable it:

-  **Activation**: set it to "on"
-  **Self registration**: set it to "on" if users are authorized to
   register their keys
-  **Allow users to remove U2F key**: If enabled, users can unregister
   enrolled U2F device
-  **Authentication level**: you can overwrite here auth level for U2F
   registered users. Leave it blank keeps auth level provided by first
   authentication module *(default: 2 for user/password based modules)*.
   **It is recommended to set an higher value here if you want to give
   access to some apps only for enrolled users**
-  **Label** (Optional): label that should be displayed to the user on
   the choice screen
-  **Logo** (Optional): logo file *(in static/<skin> directory)*
-  **Lifetime** (Optional): Unlimited by default. Set a Time To Live in seconds.
   TTL is checked at each login process if set. If TTL is expired,
   relative 2F device is removed.

.. attention::

    If you want to use a custom rule for "activation" and
    enable self-registration, you have to include this in your rule:
    ``$_2fDevices =~ /"type":\s*"U2F"/s``, else U2F will be required even if
    users are not registered. This is automatically done when "activation"
    is set to "on".

Browser compatibility
---------------------

-  Chrome/Chromium ≥ 38
-  Firefox :

   -  38 to 56 with `U2F Support
      Add-on <https://addons.mozilla.org/fr/firefox/addon/u2f-support-add-on/>`__
   -  57 to 59, with "security.webauth.u2f" set to "true" in
      about:config (see `Yubico
      explanations <https://www.yubico.com/2017/11/how-to-navigate-fido-u2f-in-firefox-quantum/>`__)
   -  probably enabled by default for versions ≥ 60

-  Opera ≥ 40

Enrollment
----------

If you have enabled self registration, users can register their U2F keys
using https://portal/2fregisters

Assistance
----------

If a user loses its key, you can delete it from the manager Second
Factor module. To enable manager Second Factor Administration Module,
set ``enabledModules`` key in your ``lemonldap-ng.ini`` file :

.. code-block:: ini

   [portal]
   enabledModules = conf, sessions, notifications, 2ndFA

Developer corner
----------------

If you have another U2F registration interface, you have to set these
keys in Second Factor Devices array (JSON) in your user-database. Then
map it to the \_2fDevices attribute (see
:doc:`exported variables<exportedvars>`):

.. code-block:: perl

   $_2fDevices = [{"name" : "MyU2FKey" , "type" : "U2F" , "_userKey" : "########" , "_keyHandle":"########" , "epoch":"1524078936"}, ...]


.. attention::

    \ ``_userKey`` must be base64 encoded

Note that both "origin" and "appId" are fixed to portal URL.
