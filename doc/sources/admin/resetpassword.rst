Reset password by mail
======================

Presentation
------------

LL::NG can propose a password reset form, for users who loose their
password (this kind of application is also called a self service
password interface).

Kinematics:

-  User clicks on the link ``Reset my password``
-  User enters his email (or another information) in the password reset
   form
-  LL::NG try to find the user in users database with the given
   information
-  A mail with a token is sent to user
-  The user click on the link in the mail
-  LL::NG validate the token and propose a password change form
-  The user can choose a new password or ask to generate one
-  The new password is sent to user by mail if user ask to generate one,
   else the mail only confirm that the password was changed


.. tip::

    If :doc:`LDAP backend<authldap>` is used, and LDAP password
    policy is enabled, the 'password reset flag is set to true when password
    is generated, so that the user is forced to change his password on next
    connection. This feature can be disabled in
    :doc:`LDAP configuration<authldap>`.


.. tip::

    If the user do a new password reset request but there is
    already a request pending, the user can ask the confirmation mail to be
    resent. The request validity time is a configuration parameter.

Configuration
-------------

The reset password link must be activated, see
:ref:`portal customization<portalcustom-other-parameters>`.

The SMTP server must be setup, see :doc:`SMTP server setup<smtp>`.

Then go in Manager, ``General Parameters`` » ``Plugins`` »
``Password management`` :

-  **Password reset mail content**:

   -  **Success mail subject**: Subject of mail sent when password is
      changed (default: [LemonLDAP::NG] Your new password)
   -  **Success mail content** (optional): Content of mail sent when
      password is changed
   -  **Confirmation mail subject**: Subject of mail sent when password
      change is asked (default: [LemonLDAP::NG] Password reset
      confirmation)
   -  **Confirmation mail content** (optional): Content of mail sent
      when password change is asked


.. attention::

    By default, mail content are empty in order to use HTML
    templates:

    -  portal/skins/common/mail_confirm.tpl
    -  portal/skins/common/mail_password.tpl

    If you define mail contents in Manager, HTML templates will not be used.


-  **Other**:

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

