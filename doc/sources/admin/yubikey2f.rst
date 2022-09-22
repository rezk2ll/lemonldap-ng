Yubico OTP Second Factor
========================

Yubico OTP is a type of One-Time-Password authentication based on a
keyboard-emulating hardware device (Yubikey). OTPs are validated against an
external server, either on the cloud or on premices.

|deprecated| Almost all Yubikeys sold by Yubico now support :doc:`FIDO2 <webauthn2f>`.
You are encouraged to use this type of second factor instead, since it is
compatible with a much broader range of devices, and also more secure.

Prerequisites and dependencies
------------------------------

You must install
`Auth::Yubikey_WebClient <http://search.cpan.org/~massyn/Auth-Yubikey_WebClient/>`__
package.

You have to retrieve a client ID and a secret key from Yubico. See
`Yubico API <https://upgrade.yubico.com/getapikey/>`__ page.

Configuration
-------------

In the manager (second factors), you just have to enable it:

-  **Activation**: set it to "on"
-  **Self registration**: set it to "on" if users are authorized to
   register their keys
-  **Allow users to remove Yubikey**: If enabled, users can unregister
   Yubikey device.
-  **API client ID**: given by Yubico or another service
-  **API secret key**: given by Yubico or another service
-  **Nonce** (optional): if any
-  **Service URL**: service URL (leave it blank to use Yubico cloud services)
-  **OTP public ID part size**: leave it to default (12) unless you know
   what you are doing
-  **Get Yubikey ID from session attribute**: if non-empty, the Yubikey ID will
   be read from this session attribute. This allows external provisionning of Yubikeys.
-  **Authentication level**: you can overwrite here auth level for
   Yubikey registered users. Leave it blank keeps auth level provided by
   first authentication module *(default: 2 for user/password based
   modules)*. **It is recommended to set an higher value here if you
   want to give access to some apps only for enrolled users**
-  **Label** (Optional): label that should be displayed to the user on
   the choice screen
-  **Logo** (Optional): logo file *(in static/<skin> directory)*
-  **Lifetime** (Optional): Unlimited by default. Set a Time To Live in seconds.
   TTL is checked at each login process if set. If TTL is expired,
   relative Yubikey is removed.


.. attention::

    If you want to use a custom rule for "activation" and
    want to keep self-registration, you must include this in your rule:
    ``has2f('UBK')``, else Yubico OTP will be required even if users are not
    registered. This is automatically done when "activation" is simply set to
    "on".

Provisioning
------------

If you don't want to use self-registration, set public part of user's
yubikey in Second Factor Devices array (JSON) in your user-database.
Then map it to the \_2fDevices attribute (see
:doc:`exported variables<exportedvars>`):

.. code::

   [{"name" : "MyYubikey" , "type" : "UBK" , "_secret" : "########" , "epoch":"1524078936"}, ...]

Enrollment
----------

If you have enabled self registration, users can register their U2F keys
using https://portal/2fregisters

.. |deprecated| image:: /documentation/deprecated.png
