Check entropy of the password
=============================

This plugin can be used to check your password entropy.

It is used in:

- :doc:`password change<portalmenu>`
- :doc:`password reset by mail<resetpassword>`


Requirements
------------

Make sure you have installed these perl dependencies:
- **Data::Password::zxcvbn**

Configuration
-------------

Browse the Manager web interface for this configuration.

You have to enable the :doc:`local password policy <portalcustom>` in ``General Parameters > Portal > Customization > Password policy`` for the plugin to work:

- **Activation**: on
- **Display policy in password form**: on


Then enable the checkEntropy plugin in ``General Parameters > Advanced parameters > Security > Check entropy``:

-  **Activation**: Enable / Disable this plugin
-  **Require entropy check to pass**: Is the entropy check required to pass? (default to ``Off``)
-  **Minimal entropy level**: If entropy check is required, which minimal level is expected for password to be accepted? (0-4)

Usage
-----

When enabled, ``/checkentropy`` route is added to LemonLDAP API
It will check new user passwords against zxcvbn library and
display a bar showing the strength of the password.

