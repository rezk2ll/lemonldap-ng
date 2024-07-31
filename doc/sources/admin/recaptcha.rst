reCaptcha v3
============

Presentation
------------

reCaptcha version 3 is an evolution of Google's reCaptcha that returns a score
for each request without user friction. The score is based on interactions with
your site and enables you to take an appropriate action for your site.

See `Google reCAPTCHA v3 <https://developers.google.com/recaptcha/docs/v3>`__
for more.

Configuration
-------------

Configure captcha like :doc:`LLNG internal captcha<captcha>` but use a
"custom captcha module", set:
- **Captcha module** to "**::Captcha::ReCaptcha**"
- in **Captcha module options**, add the following keys
   - **dataSiteKey**: the key ID given in Google console
   - **secretKey**: the secret key
