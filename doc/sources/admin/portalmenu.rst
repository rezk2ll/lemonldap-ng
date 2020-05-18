Portal menu
===========


.. note::

    The menu is displayed if authentication is successful.

.. _portalmenu-menu-modules:

Menu modules
------------

LemonLDAP::NG portal menu has 4 modules:

-  **Application list**: display categories and applications allowed for
   the user
-  **Password change**: form to change the password
-  **Login history**: display user's last logins and last failed logins
-  **OIDC Consents**: display user's OpenId Connect consents
-  **Logout**: logout button

Each module can be activated trough a rule, using user session
information. These rules can be set trough Manager:
``General Parameters`` > ``Portal`` > ``Menu`` > ``Modules activation``.

You can use ``0`` or ``1`` to disable/enable the module, or use a more
complex rule. For example, to display the password change form only for
user authenticated trough LDAP or DBI:

.. code:: perl

   $_auth eq LDAP or $_auth eq DBI

.. _portalmenu-categories-and-applications:

Categories and applications
---------------------------

:doc:`Configuring the virtual hosts<configvhost>` is not sufficient to
display an application in the menu. Indeed, a virtual host can contain
several applications (http://vhost.example.com/appli1,
http://vhost.example.com/appli2).

In Manager, you can configure categories and applications in
``General Parameters`` > ``Portal`` > ``Menu`` >
``Categories and applications``.

Application parameters:

|image0|

-  **Name**: display text
-  **Description**
-  **URI**: URL of the application
-  **Tooltip**: information display on mouse over the button
-  **Logo**: file name to use as logo
-  **Display application**:

   -  **Enabled**: always display
   -  **Disabled**: never display
   -  **Automatic**: display only if the user can access it
   -  **Special rule**: specify a :ref:`rule<rules>`
      or "sp: <name>" where "name" is the key name of the service
      provider, the corresponding rule will be applied *(available for
      CAS, SAML or OpenID-Connect)*


.. tip::

    Categories and applications are displayed in alphabetical
    order.

|image1|


.. tip::

    The chosen logo file must be in portal applications logos
    directory (``portal/htdocs/static/common/apps/``). You can set a custom
    logo by setting the logo file name directly in the field, and copy the
    logo file in portal applications logos directory

.. |image0| image:: /documentation/manager-portal-menu-application.png
   :class: align-center
.. |image1| image:: /documentation/manager-portal-menu-icon.png
   :class: align-center

