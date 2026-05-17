CaptchEtat
==========

|beta|

this plugin has not been tested in production yet, its behavior and
parameters are subject to change in future versions

Presentation
------------

CaptchEtat is a CAPTCHA system provided by the French government

Configuration
-------------

Configure captcha like :doc:`LLNG internal captcha<captcha>` but use a
"custom captcha module", set:

- **Captcha module** to ``::Captcha::CaptchEtat``
- in **Captcha module options**, add the following keys
   - ``clientId``: client ID to obtain access tokens
   - ``clientSecret``: client secret to obtain access tokens
   - ``oauthTokenEndpoint``: endpoint to obtain access tokens
   - ``oauthScope``: authorization scope for access tokens (such as ``piste.captchetat``)
   - ``captchaStyleName``: CAPTCHA style name (such as ``captchaFR``)
   - ``captchaApiBase``: base URL of the CaptchEtat API ( such as ``https://xxx.example.com/piste/captchetat/v2`` )


.. |beta| image:: /documentation/beta.png
