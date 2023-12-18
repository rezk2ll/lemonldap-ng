Okta Second Factor
==================

`Okta <https://www.okta.com/>`__ is a cloud identity provider that can be used as 2FA service.

This module uses Okta API to list 2FA registered for the user, displays the list to the user
and run the selected choice. It manages at least mail, SMS, TOTP and push modes.

Configuration
--------------

All parameters are configured in "General Parameters » Portal Parameters
» Extensions » Okta 2nd Factor".

-  **Activation**: rule to enable this module
-  **Administration URL**: Okta administration URL for your organization
-  **API key**: Okta API key
-  **Authentication level** (Optional): if you want to overwrite the
   value sent by your authentication module, you can define here the new
   authentication level. Example: 5
-  **Label** (Optional): label that should be displayed to the user on
   the choice screen
-  **Logo** (Optional): logo file (in static/<skin> directory)

