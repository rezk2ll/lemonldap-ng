Register a new account
======================

Presentation
------------

This feature is a page that allows a user to create an account.
Following steps are performed:

#. User click on the button "Create a new account"
#. They enter first name, last name and email
#. They receive an email with a confirmation link
#. After clicking, their account is created
#. An email with his login and password is sent

Configuration
-------------

The "Create your account" button can be enabled in
:doc:`Portal customization parameters<portalcustom>`.

Then, go in ``General Parameters`` > ``Plugins`` > ``Register new account``:

-  **Module**: Backend used for creating new account.
-  **Page URL**: URL of register page
-  **Validity time of a register request**: Duration in seconds of a new
   account request. The request will be deleted after this time if user
   do not click on the link.
-  **Subject for confirmation mail**: Subject of the email containing the
   confirmation link
-  **Body for confirmation mail**: The plain text content of the confirmation email the user will
   receive. If you leave it blank, the ``mail_register_confirm`` HTML template will be used.
   Confirmation link is stored in the ``$url`` variable
-  **Subject for done mail**: Subject of the email providing login and password.
-  **Body for done mail**: The plain text content of the done email the user will
   receive. If you leave it blank, the ``mail_register_done`` HTML template will be used.
   Login and generated password are stored in the corresponding ``$login`` and ``$password`` variables


.. note::

   Following variables are available in:

   \* Register email body => ``$expMailDate``, ``$expMailTime``, ``$url``, ``$mail``, ``$firstname``, ``$lastname`` and ``$ipAddr``

   \* Done email body     => ``$login``, ``$password`` and ``$url``