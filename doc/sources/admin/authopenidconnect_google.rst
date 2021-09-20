Google
======

|image0|

Presentation
------------

Do you we have to present `Google <http://www.google.com>`__? The good
news is that Google is a standard OpenID Provider, and so you can easily
delegate the authentication of LL::NG to Google:
https://developers.google.com/identity/protocols/OpenIDConnect


.. attention::

    Google does not support logout through OpenID Connect. If
    you close your session on LL::NG side, your Google session will still be
    open.

Register on Google
------------------

You need a Google developer account to access to
https://console.developers.google.com/

Here you can go in API Manager and get new credentials (``client_id``
and ``client_secret``).

You need to provide the callback URLs, for example
https://auth.domain.com/?openidconnectcallback=1.

Declare Google in your LL::NG server
------------------------------------

Go in Manager and create a new OpenID Connect provider. You can call it
``google`` for example.

Click on ``Metadata``, and use the OpenID Connect configuration URL to
load them: https://accounts.google.com/.well-known/openid-configuration.

You can also load the JWKS data from the URL
https://www.googleapis.com/oauth2/v3/certs. But as Google rotate their
keys, we will also configure a refresh interval on JKWS data.

Go in ``Exported attributes`` to choose which attributes you want to
collect. Google supports these claims:

-  email
-  email_verified
-  family_name
-  given_name
-  locale
-  name
-  picture
-  sub

Now go in ``Options``:

-  In ``Configuration``, register the ``client_id`` and
   ``client_secret`` given by Google. Set also the configuration URI
   with https://accounts.google.com/.well-known/openid-configuration,
   and JWKS refresh, for example every day: 86400.
-  In ``Protocol``, adapt the ``scope`` to the exported attributes you
   want. You can for example use ``openid profile email``.
-  In ``Display``, you can set the name and the logo

.. |image0| image:: /applications/google_logo.png
   :class: align-center

