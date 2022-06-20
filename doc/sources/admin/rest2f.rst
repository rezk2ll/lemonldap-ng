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
-  **Code regex**: regular expression to create an OTP code. If this option is
   set, LemonLDAP::NG will generate the code and send it through the Init URL,
   then verify it internally.
-  **Init URL** *(optional)*: REST URL to initialize dialog *(send
   OTP)*. Leave it blank if your API doesn't need any initialization
-  **Init arguments**: list of arguments to send *(see below)*
-  **Verify URL** *(required)*: REST URL to verify code
-  **Verify arguments**: list of arguments to send *(see below)*
-  **Re-send interval**: Set this to a non-empty value to allow the user to
   re-send the code in case a transmission error occured. The value sets how
   many seconds the user has to wait before each attempt
-  **Authentication level** (Optional): if you want to overwrite the
   value sent by your authentication module, you can define here the new
   authentication level. Example: 5
-  **Label** (Optional): label that should be displayed to the user on
   the choice screen
-  **Logo** (Optional): logo file *(in static/<skin> directory)*

Arguments
---------

Arguments are a list of key/value. Key is the name of JSON entry, value
is attribute or macro name.


REST Dialog 
-----------


REST web services have just to reply with a "result" key in a JSON file.
Auth/UserDB can add an "info" array. It will be stored in session data
(without reading "Exported variables").

If *Code regex* is set
~~~~~~~~~~~~~~~~~~~~~~

========== ================================================ ====================================
URL        Query                                            Response
========== ================================================ ====================================
Init URL   JSON body: ``{"user":$user,"code":"$code",...}`` JSON body: ``{"result":true/false}``
========== ================================================ ====================================

The Verify URL is not called, since the code is checked against the internally saved value

If *Code regex* is not set
~~~~~~~~~~~~~~~~~~~~~~~~~~

========== ================================================ ====================================
URL        Query                                            Response
========== ================================================ ====================================
Init URL   JSON body: ``{"user":$user,...}``                JSON body: ``{"result":true/false}``
Verify URL JSON body: ``{"user":$user,"code":"$code",...}`` JSON body: ``{"result":true/false}``
========== ================================================ ====================================
