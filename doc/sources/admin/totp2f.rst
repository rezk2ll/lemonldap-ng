TOTP 2nd Factor Authentication
==============================

`Time based One Time
Password <https://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm>`__
(TOTP) is an algorithm that computes a one-time password from a shared
secret key and the current time. This is currently use by `Google
Authenticator <https://en.wikipedia.org/wiki/Google_Authenticator>`__ or
`FreeOTP <https://freeotp.github.io/>`__.

LLNG can propose users to register this kind of software to increase
authentication level.


.. tip::

    Note that it's a second factor, not an authentication module.
    Users are authenticated both by login form and TOTP.

Prerequisites and dependencies
------------------------------

This feature uses libconvert-base32-perl. Before enable it, on Debian
you must install libconvert-base32-perl by :

::

   apt update
   apt install libconvert-base32-perl
   apt install libdigest-hmac-perl

Or from CPAN repository :

::

   cpanm Convert::Base32

Configuration
-------------

In the manager (advanced parameters), you just have to enable it:

-  **Activation**: set it to "on"
-  **Self registration**: set it to "on" if users are authorized to
   generate themselves a TOTP secret
-  **Authentication level**: you can overwrite here auth level for TOTP
   registered users. Leave it blank keeps auth level provided by first
   authentication module *(default: 2 for user/password based modules)*.
   **It is recommended to set an higher value here if you want to give
   access to some apps only to users enrolled**
-  **Issuer**: default to portal hostname
-  **Interval**: interval for TOTP algorithm (default: 30)
-  **Range**: number of additional intervals to test (default: 1)
-  **Digits**: number of digit by codes (default: 6)
-  **Allow users to remove TOTP**: If enabled, users can unregister
   TOTP.
-  **Lifetime**: Unlimited by default. Set a Time To Live in seconds.
   TTL is checked at each login process if set. If TTL is expired,
   relative TOTP is removed.
-  **Logo** (Optional): logo file *(in static/<skin> directory)*
-  **Label** (Optional): label that should be displayed to the user on
   the choice screen


.. attention::

    If you want to use a custom rule for "activation" and
    want to keep self-registration, you must include this in your rule that
    ``$_2fDevices =~ /"type":\s*"TOTP"/s`` is set, else TOTP will be
    required even if users are not registered. This is automatically done
    when "activation" is simply set to "on".


.. danger::

    Range is tested backward and forward to prevent
    positive or negative clock drift.

Enrollment
----------

If you've enabled self registration, users can register their keys by
using https://portal/2fregisters

Assistance
----------

If a user loses its key, you can remove it from manager Second Factor
module.// // To enable manager Second Factor Administration Module, set
``enabledModules`` key in your ``lemonldap-ng.ini`` file :// //

.. code-block:: ini

   [portal]
   enabledModules = conf, sessions, notifications, 2ndFA

Developer corner
----------------

If you have another TOTP registration interface, you have to set these
keys in Second Factor Devices array (JSON) in your user-database. Then
map it to the \_2fDevices attribute (see
:doc:`exported variables<exportedvars>`):

.. code::

   [{"name" : "MyTOTP" , "type" : "TOTP" , "_secret" : "########" , "epoch":"1524078936"}, ...]

