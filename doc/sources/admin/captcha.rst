Captcha
=======

Presentation
------------

Captcha is a security mechanism to prevent forms from being submited by robots.

Captchas are available on following forms:

-  Login form: where user inputs login and password for authenticating
-  Password reset by mail form: where user inputs mail to recover a forgotten password
-  Register form: where user inputs information to create a new account


.. attention::

    We use the GD::SecurityImage Perl module to generate images.
    This module is required if you enable Captcha feature.
    With Debian-based distributions, you may have to install 'gsfonts' package.

Configuration
-------------

Go in ``General parameters`` > ``Portal`` > ``Captcha``:

-  **Activation in login form**: set to 1 to display captcha in login
   form
-  **Activation in password reset by mail form**: set to 1 to display
   captcha in password reset by mail form
-  **Activation in register form**: set to 1 to display captcha in
   register form
-  **Size**: define captcha length
-  **Captcha module**: allows you to use a custom Captcha module, see
   :ref:`below <customcaptcha>`. Leave it blank to use the default Captcha
   implementation
-  **Captcha module options**: options for the custom Captcha module

.. _customcaptcha:

Custom Captcha modules
----------------------

.. versionadded:: 2.0.15

If the default Captcha does not meet your requirements, you can replace it with
a different implementation. See the ``Lemonldap::NG::Portal::Captcha`` manual
page for details on how to implement a Captcha module.
