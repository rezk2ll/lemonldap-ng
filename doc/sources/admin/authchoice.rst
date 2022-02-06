Backend choice by users
=======================

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔     ✔
============== ===== ========

Presentation
------------

By default, only the configured authentication backend is available for
users.

Contrary to :doc:`multiple backend stacking<authmulti>`, backend choice
will present all available authentication methods to users, who will
choose the one they want.

The choice will concern three backends:

-  Authentication
-  Users
-  Password

The chosen backends will be registered in session:

-  ``$_auth``
-  ``$_userDB``
-  ``$_passwordDB``

Authentication choice will also be registered in session:

-  ``$_authChoice``

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose Choice for authentication.


.. attention::

    When ``Choice`` is selected for authentication, values
    for Users and Password modules are also forced to ``Choice``.

Then, go in ``Choice Parameters``:

-  **URL parameter**: parameter name used to set choice value (default:
   ``lmAuth``)
-  **Allowed modules**: click on ``New chain`` to add a choice.
-  **Choice used for password authentication**: authentication module used by
   :doc:`AuthBasic handler<authbasichandler>` and :ref:`OAuth2.0 Password Grant <resource-owner-password-grant>`
-  **FindUser plugin parameter**: authentication module called by
   Find user plugin (:doc:`Find user plugin<finduser>`)

|image0|

Define here:

-  **Name**: Text displayed on choice tab.
-  **Authentication module**
-  **Users module**
-  **Password module**
-  **URL**: optional, can be used to redirect on another URL (for
   example https://authssl.example.com). This is mandatory if you want
   to use an Apache authentication module, which is run by Apache before
   showing the LemonLDAP::NG portal page.
-  **Condition**: optional, can be used to evaluate an expression to
   display the tab. For example, to display a tab only if redirected by
   Handler from application ``test1.example.com``, you can set this
   condition:

.. code-block:: perl

   $env->{urldc} =~ /test1\.example\.com/


.. note::

    Federated authentication need pdata cookie.
    SameSite cookie value must be set to "Lax" or "None".
    See :doc:`SSO cookie parameters<ssocookie>`

.. note::

    Authentication request to an another URL than Portal URL can lead
    to a persistent loop between Portal and a redirection URL (pdata is not
    removed because domains mismatch). To avoid this, you have to set pdata
    cookie domain by editing ``lemonldap-ng.ini`` in section [portal]:

    .. code:: ini

       [portal]
       pdataDomain = example.com




.. tip::

    You can prefix the key name with a digit to order them. The
    digit will not be shown on portal page. Underscore characters are also
    replaced by spaces.


.. tip::

    You can also override some LLNG parameters for each chain. See
    :doc:`Parameters list<parameterlist>` to have the key names to use

.. |image0| image:: /documentation/manager-choice.png
   :class: align-center

