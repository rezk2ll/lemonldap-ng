Register a new account
======================

Presentation
------------

This feature is a page that allows a user to create an account.

**Kinematics:**

-  User click on the button "Create a new account"
-  They enter first name, last name and email
-  They receive an email with a confirmation link
-  After clicking, their account is created
-  An email with his login and password is sent


Configuration
-------------

**Requirements**

-  You have to activate the 'create a new account' linbuttonk in the login page.

Go in Manager, ``General Parameters`` » ``Portal`` » ``Customization`` »
``Buttons on login page`` » ``Register new account``


See :ref:`portal customization<portalcustom-other-parameters>`.

**Manager Configuration**

Go in ``General Parameters`` » ``Plugins`` » ``Register new account``:

-  **Mail content:**

   -  **Confirmation mail subject**: Subject of the email containing the confirmation link
   -  **Confirmation mail content**: Content of the confirmation email sent to the user. If blank, the ``mail_register_confirm`` HTML template will be used. Confirmation link is stored in the ``$url`` variable
   -  **Credentials mail subject**: Subject of the email providing login and password
   -  **Credentials mail content**: Content of the credentials email sent to the user. If blank, the ``mail_register_done`` HTML template will be used. Login and generated password are stored in the corresponding ``$login`` and ``$password`` variables.


-  **Other:**

   -  **Page URL**: URL of register page
   -  **Validity time of a register request**: Duration in seconds of a new account request. The request will be deleted after this time if user do not click on the link.


.. note::

   Following variables are available in:

   \* Register email body => ``$expMailDate``, ``$expMailTime``, ``$url``, ``$mail``, ``$firstname``, ``$lastname`` and ``$ipAddr``

   \* Done email body     => ``$login``, ``$password`` and ``$url``