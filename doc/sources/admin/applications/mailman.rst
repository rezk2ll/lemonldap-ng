GNU Mailman
===========

.. image:: /applications/mailman.jpg
   :class: align-center


Presentation
------------

`Mailman <http://www.list.org/>`__ is free software for managing electronic mail discussion and e-newsletter lists. Mailman is integrated with the web, making it easy for users to manage their accounts and for list owners to administer their lists. Mailman supports built-in archiving, automatic bounce processing, content filtering, digest delivery, spam filters, and more.

Mailman uses `django-allauth <https://www.intenct.nl/projects/django-allauth/>`__ for external authentication. And as of version 0.49, *django-allauth* is `compatible with LemonLDAP::NG <https://django-allauth.readthedocs.io/en/latest/providers.html#lemonldap-ng>`__

First, make sure you have set up LemonLDAP::NG 's
:doc:`OpenID Connect service<..//openidconnectservice>` and added
:doc:`a Relaying Party for your Mailman instance<..//idpopenidconnect>`

Mailman can use the following OpenID Connect attributes to fill the
user's profile:

* ``name``
* ``email``
* ``preferred_username``

Make sure you create a Client ID and a Client Secret for the Relying Party, and
that the mailman callback URL is allowed : ``https://mailman.example.com/accounts/lemonldap/login/callback/``

Mailman configuration
---------------------

.. note::

   Make sure you are using at least version 0.49 of *django-allauth*


Provider activation
~~~~~~~~~~~~~~~~~~~

In the Mailman config (`settings.py`), enable the LemonLDAP::NG provider::

    INSTALLED_APPS = [
     'allauth',
     'allauth.account',
     'allauth.socialaccount',
     'allauth.socialaccount.providers.lemonldap',
    ]

    SOCIALACCOUNT_PROVIDERS = {
        'lemonldap': {
            'LEMONLDAP_URL': 'https://auth.example.com',
        },
    }


Provider configuration
~~~~~~~~~~~~~~~~~~~~~~

Browse to Mailman django administration, then add a new *Social application*

* Provider: *LemonLDAP::NG*
* Name: pick one
* Client id: must match the Client ID set in LemonLDAP::NG
* Secret key: must match the Client Secret set in LemonLDAP::NG
* Sites: choose which Mailman site can use LemonLDAP::NG

You should then be able to login on your Mailman site using LemonLDAP::NG
