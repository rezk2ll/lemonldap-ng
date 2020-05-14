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


.. important:: 

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
