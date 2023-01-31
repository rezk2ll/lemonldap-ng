Check password on "Have I been Pwned" API
=========================================

This plugin can be used to check your password against the `HIBP API <https://haveibeenpwned.com/>`_.

It is used in:

- :doc:`password change<portalmenu>`
- :doc:`password reset by mail<resetpassword>`

Configuration
-------------

Browse the Manager web interface for this configuration.

You have to enable the :doc:`local password policy <portalcustom>` in ``General Parameters > Portal > Customization > Password policy`` for the plugin to work:

- **Activation**: on
- **Display policy in password form**: on


Then enable the checkHIBP plugin in ``General Parameters > Plugins > check HIBP API``:

-  **Activation**: Enable / Disable this plugin
-  **Have I Been Pwned URL**: URL of I have been pwned API (default to ``https://api.pwnedpasswords.com/range/``)
-  **Require HIBP check to pass**: Is the HIBP check required to pass? (default to ``Off``)

Usage
-----

When enabled, ``/checkhibp`` route is added to LemonLDAP API
It will check new user passwords on Have I Been Pwned API and
display a warning message if it is compromised.

.. note::

    The URL parameter is mandatory, and there is no default value.
