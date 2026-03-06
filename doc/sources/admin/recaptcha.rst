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

- **Captcha module** to "``::Captcha::ReCaptcha``" or "``::Captcha::ReCaptcha3``" for version 3
- in **Captcha module options**, add the following keys

   - ``dataSiteKey``: the key ID given in Google console
   - ``secretKey``: the secret key
   - ``score`` *(version 3 only)*: the minimal score. Default to 0.5

Then adapt the "Content-Security-Policy" headers, cspDefault and cspScript
should be set to :

::

  https://www.google.com https://www.gstatic.com 'self'


.. important::
   Starting from version 2.23.0, authentication form is locked until ReCaptcha
   is loaded. On slow networks, this avoids getting "Bad captcha" answers,
   especially with ReCaptcha version 3
