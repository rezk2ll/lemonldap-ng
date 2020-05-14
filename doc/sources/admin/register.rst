Register a new account
======================

Presentation
------------

This feature is a page that allows a user to create an account. The
steps are the following:

#. User click on the button "Create a new account"
#. He enters first name, last name and email
#. He gets a mail with a confirmation link
#. After clicking, his entry is added
#. He gets a mail with his login and his password

Configuration
-------------

You can enable the "Create your account" button in
:doc:`portal customization parameters<portalcustom>`.

Then, go in ``Portal`` > ``Advanced parameters`` >
``Register new account``:

-  **Module**: Choose the backend to use to create the new account.
-  **Page URL**: URL of register page
-  **Validity time of a register request**: duration in seconds of a new
   account request. The request will be deleted after this time if user
   do not click on the link.
-  **Subject for confirmation mail**: Subject of the mail containing the
   confirmation link
-  **Subject for done mail**: Subject of the mail giving login and
   password
