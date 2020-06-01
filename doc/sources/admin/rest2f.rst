REST Second Factor
==================

This plugin can be used to append a second factor authentication device
like SMS or OTP. It uses an external web service to submit and validate
the second factor.

Configuration
~~~~~~~~~~~~~

All parameters are set in "General Parameters » Portal Parameters »
Second Factors » REST 2nd Factor".

-  **Activation**
-  **Init URL** *(optional)*: REST URL to initialize dialog *(send
   OTP)*. Leave it blank if your API doesn't need any initialization
-  **Init arguments**: list of arguments to send *(see below)*
-  **Verify URL** *(required)*: REST URL to verify code
-  **Verify arguments**: list of arguments to send *(see below)*
-  **Authentication level** (Optional): if you want to overwrite the
   value sent by your authentication module, you can define here the new
   authentication level. Example: 5
-  **Logo** (Optional): logo file *(in static/<skin> directory)*
-  **Label** (Optional): label that should be displayed to the user on
   the choice screen

Arguments
---------

Arguments are a list of key/value. Key is the name of JSON entry, value
is attribute or macro name.


.. attention::

    For Verify URL, you should send ``$code`` at least

REST Dialog
-----------

REST web services have just to reply with a "result" key in a JSON file.
Auth/UserDB can add an "info" array. It will be stored in session data
(without reading "Exported variables").

========== ================================================ ====================================
URL        Query                                            Response
========== ================================================ ====================================
Init URL   JSON file: ``{"user":$user,...}``                JSON file: ``{"result":true/false}``
Verify URL JSON file: ``{"user":$user,"code":"$code",...}`` JSON file: ``{"result":true/false}``
========== ================================================ ====================================
