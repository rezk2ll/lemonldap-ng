Radius as Second Factor
=======================

Some proprietary, OTP-based second factor implementations expose a
Radius server that allow an authenticating application (such as
LemonLDAP::NG) to verify the validity of an OTP using the standard
Radius protocol.


.. tip::

    This page is about using Radius to connect to an external 2FA
    system for the *second factor only*. If your 2FA system works by
    concatenating the user's password and their OTP (LinOTP), you should
    probably be using :doc:`regular Radius authentication<authradius>`
    instead

After choosing the Radius second factor type, the user is prompted with
a code that will be checked against the Radius server.

Prerequisites and dependencies
------------------------------

This feature uses ``Authen::Radius``. Before enable it, on Debian you
must install it :

For CentOS/RHEL:

.. code-block:: shell

   yum install perl-Authen-Radius

In Debian/Ubuntu, install the library through apt-get command

.. code-block:: shell

   apt-get install libauthen-radius-perl

Configuration
-------------

.. _configuration-1:

Configuration
~~~~~~~~~~~~~

All parameters are configured in "General Parameters » Second factors »
Mail second factor".

-  **Activation**: Set to ``On`` to activate this module, or use a
   specific rule to select which users may use this type of second
   factor
-  **Server hostname**: The hostname of the Radius server
-  **Shared secret**: The secret key shared with the Radius server
-  **Session key containing login** (Optional): When verifying the OTP
   code against the Radius server, use this attribute as the login and
   the OTP code as password. By default, the attribute designated as
   ``whatToTrace`` is used.
-  **Authentication timeout** (Optional): Allowed time to perform authentication
-  **Authentication level** (Optional): if you want to overwrite the
   value sent by your authentication module, you can define here the new
   authentication level. Example: 5
-  **Label** (Optional): label that should be displayed to the user on
   the choice screen
-  **Logo** (Optional): logo file *(in static/<skin> directory)*

Vendor specific
~~~~~~~~~~~~~~~

Some configuration examples for specific vendors:

.. toctree::
   :maxdepth: 1

   radius2f-inwebo
