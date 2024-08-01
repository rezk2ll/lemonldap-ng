reCaptcha
=========

Presentation
------------

Captcha system provided by `Google <https://about.google>`__.

See `Google reCAPTCHA <https://www.google.com/recaptcha/about/>`__
for more.

Configuration
-------------

Configure captcha like :doc:`LLNG internal captcha<captcha>` but use a
"custom captcha module", set:

- **Captcha module** to "``::Captcha::ReCaptcha``"
- in **Captcha module options**, add the following keys

   - ``dataSiteKey``: the key ID given in Google console
   - ``secretKey``: the secret key

Then adapt the "Content-Security-Policy" headers, cspDefault and cspScript
should be set to :

::

  https://www.google.com https://www.gstatic.com 'self'
