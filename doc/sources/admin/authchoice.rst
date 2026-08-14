Configuring authentication methods
==================================

LemonLDAP::NG allows you to configure multiple authentication methods.

On a new installation, a single authentication method is configured, and uses the "Demo" backend for:

* User authentication (making sure the user is who they claim)
* User information (knowing whether a user exists or not, and what are their attributes)
* Password modification

In most configurations, you only need to change the Demo backend to your actual
users backend: usually a LDAP or Active Directory server, or an external SAML
or OIDC provider.

However, you can also configure multiple methods with the "New chain" button.

|image0|

-  **Name**: Text displayed on choice tab.
-  **Authentication module**
-  **Users module**
-  **Password module**
-  **URL**: optional, can be used to redirect on another URL (for
   example https://authssl.example.com). This is mandatory if you want
   to use an Apache authentication module, which is run by Apache before
   showing the LemonLDAP::NG portal page.
-  **Condition**: optional, can be used to evaluate an expression to
   display the tab.


Condition rule syntax
~~~~~~~~~~~~~~~~~~~~~

You can use the same syntax as :doc:`regular rules <rules_examples>`. In
addition to the following special variables

* ``$targetAuthnLevel``: authentication level requested by the current application

For example, to display a tab only if redirected by Handler from application
``test1.example.com``, you can set this condition:

.. code-block:: perl

   $env->{urldc} =~ /test1\.example\.com/

Ordering of choices on the main login page
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can prefix the key name with a digit to order them. The
digit will not be shown on portal page. Underscore characters are also
replaced by spaces.

For example, use ``2_France_Connect`` to use *France Connect* as the second
choice.

.. _choiceAdvParam:

Advanced parameters
~~~~~~~~~~~~~~~~~~~

-  **URL parameter**: parameter name used to set choice value (default:
   ``lmAuth``)
-  **Choice used for password authentication**: authentication module used by
   :doc:`AuthBasic handler<authbasichandler>` and :ref:`OAuth2.0 Password Grant <resource-owner-password-grant>`
-  **Choice used for searching user account**: authentication module called by
   Find user plugin (:doc:`Find user plugin<finduser>`)
-  **Auto-select only method**: if only one authentication method is available,
   automatically select it. This is useful if you are using an external IDP and
   don't want the user to have to explicitely select it
-  **Force authentication module**, **Force user module**, **Force password
   module**: this option should generally not be used, it overrides the module
   used by your authentication choices. It only exists to help migrating from
   LemonLDAP::NG 2.0

Parameter override
~~~~~~~~~~~~~~~~~~

You can also override some LemonLDAP::NG parameters for each chain. See
:doc:`Parameters list<parameterlist>` to have the key names to use

Custom logo
~~~~~~~~~~~

You can customize the logo by copying a PNG file that matches the *Name* of the
choice in ``/usr/share/lemonldap-ng/portal/htdocs/static/common/modules/``.

For example: ``2_France_Connect.png``

Issues with persistent data
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Federated authentication need pdata cookie.
SameSite cookie value must be set to "Lax" or "None".
See :doc:`SSO cookie parameters<ssocookie>`

Authentication request to another URL than Portal URL can lead
to a persistent loop between Portal and a redirection URL (pdata is not
removed because domains mismatch). To avoid this, you have to set pdata
cookie domain by editing ``lemonldap-ng.ini`` in section [portal]:

.. code:: ini

   [portal]
   pdataDomain = example.com


.. |image0| image:: /documentation/manager-choice.png
   :class: align-center

