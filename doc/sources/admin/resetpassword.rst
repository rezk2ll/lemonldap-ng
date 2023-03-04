Password reset by mail
======================

Presentation
------------

LL::NG can propose a password reset form, for users who loose their
password (this kind of application is also called a self service
password interface).

**Kinematics:**

-  User clicks on the link ``Reset my password``
-  User provides his email address (or another information) in password reset form
-  LL::NG try to find the user in users database with the provided information
-  An email contening a token is sent to the user
-  The user clicks on the link in the mail
-  LL::NG validates the token and proposes a password change form
-  The user can choose a password or ask to generate a new one
-  The new password is sent to user by mail if user ask to generate one,
   else the sent mail only confirms that the password has been successfully changed


.. tip::

    If :doc:`LDAP backend<authldap>` is used and LDAP password policy is enabled,
    'password reset flag is set to true when password is generated. 
    So user is forced to change his password at next connection.
    This feature can be disabled in :doc:`LDAP configuration<authldap>`.


.. tip::

    If the user performs a new password reset request when a request is already pending,
    the user can ask the confirmation mail to be resent. Request validity time can be set.

Configuration
-------------

**Requirements**

-  You have to activate the 'password reset' button in the login page.
Go in Manager, ``General Parameters`` » ``Portal`` » ``Customization`` »
``Buttons on login page`` » ``Reset password``

See :ref:`portal customization<portalcustom-other-parameters>`.

-  The SMTP server must be setup, see :doc:`SMTP server setup<smtp>`.

**Manager Configuration**

Go in Manager, ``General Parameters`` » ``Plugins`` » ``Password management``:

-  **Mail content:**

   -  **Success mail subject**: Subject of mail sent when password is changed (default: [LemonLDAP::NG] Your new password)
   -  **Success mail content** (optional): Content of mail sent when password is changed
   -  **Confirmation mail subject**: Subject of mail sent when password
      change is asked (default: [LemonLDAP::NG] Password reset confirmation)
   -  **Confirmation mail content** (optional): Content of mail sent when password change is asked


.. attention::

    By default, mail content are empty in order to use HTML templates:

    -  portal/skins/common/mail_confirm.tpl
    -  portal/skins/common/mail_password.tpl

    If you define mail contents in Manager, HTML templates will not be used.


-  **Other:**

   -  **Page URL**: URL of password reset page (default:
      [PORTAL]/resetpwd)
   -  **Validity time of a password reset request**: number of seconds
      for password reset request validity. During this period, user can
      ask the confirmation mail to be resent (default: session timeout
      value)
   -  **Display generate password box**: display a checkbox to allow
      user to generate a new password instead of choosing one (default:
      disabled)
   -  **Regexp for password generation**: Regular expression used to generate the password. Set a blank value to use
      password policy if enabled or default regexp will be employed: [A-Z]{3}[a-z]{5}.\d{2}

