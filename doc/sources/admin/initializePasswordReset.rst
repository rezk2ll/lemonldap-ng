Password Initialization Reset Plugin
====================================

This plugin can be used to initialize a reset password for a user.

It is used by:

- :doc:`password reset by mail<resetpassword>`

Configuration
-------------

Browse the Manager web interface for this configuration.

Enable the  plugin in ``General Parameters > Plugins > Initialize Password Reset API plugin``:

-  **Activation**: Enable / Disable this plugin
-  **Secret key**: Secret key for the Initialize Password Reset API

.. note::

    Take care to define a userDB module. The plugin does not work currently with Choice module.



Usage
-----

When enabled, ``/initializepasswordreset`` route is added to LemonLDAP API.
It will generate a mail session, usable for reinitializating a password by mail for a given user.

.. danger::

    The secret key parameter is mandatory, and there is no default value.


Send a REST request with parameters `mail` and `secret` in JSON.

For example:

.. code-block:: console

    curl -s -X POST -H "Content-Type: application/json" -d '{"mail":"user@domain.com","secret":"mysecret"}' https://auth.domain.com/initializepasswordreset | jq .

Result:

.. code-block:: console

    {
      "url": "http://auth.domain.com/resetpwd?mail_token=8c717a2eb8233a95181846e0db29791c20c0b2dbbeab60ab5ae155559511a1d4",
      "mail_token": "8c717a2eb8233a95181846e0db29791c20c0b2dbbeab60ab5ae155559511a1d4"
    }

