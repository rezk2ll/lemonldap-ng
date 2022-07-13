Captcha
=======

Presentation
------------

Captcha is a security mechanism aimed to prevent robots to submit forms.

Captchas are available on the following forms:

-  Login form: where user enters login and password to authenticate
-  Password reset by mail form: where user enters mail to recover a lost
   password
-  Register form: where user enters information to create a new account


.. attention::

    We use the Perl module GD::SecurityImage to generate
    images, you need to install it if you enable Captcha feature.

Configuration
-------------

Go in ``General parameters`` > ``Portal`` > ``Captcha``:

-  **Activation in login form**: set to 1 to display captcha in login
   form
-  **Activation in password reset by mail form**: set to 1 to display
   captcha in password reset by mail form
-  **Activation in register form**: set to 1 to display captcha in
   register form
-  **Size**: length of captcha
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
