The Portal
==========

The Portal is the main component of LL::NG. It provides many features:

-  **Authentication service** of course

   -  Web based for normal users:

      -  using own database (:doc:`LDAP<authldap>`, :doc:`SQL<authdbi>`,
         ...)
      -  using web server authentication system (used for
         :doc:`SSL<authssl>`, :doc:`Kerberos<authapache>`,
         :doc:`HTTP basic authentication<authapache>`, ...)
      -  using external identity provider (:doc:`SAML<authsaml>`,
         :doc:`OpenID<authopenid>`, :doc:`CAS<authcas>`,
         :doc:`Twitter<authtwitter>`, other LL::NG system, ...)
      -  all together (based on user :doc:`choice<authchoice>`,
         :doc:`rules<authmulti>`, ...)

   -  :doc:`SOAP based<soapservices>` and
      :doc:`REST based<restservices>` for client-server software,
      specific development, ...

-  **Identity provider**: LL::NG is able to provide identity service
   using:

   -  :doc:`SAML<idpsaml>`
   -  :doc:`OpenID Connect<idpopenidconnect>`
   -  :doc:`CAS<idpcas>`

-  :doc:`Identity provider proxy<federationproxy>`: LL::NG can be
   used as proxy translator between systems talking SAML, OpenID, CAS,
   ...
-  **Internal SOAP server** used by
   :doc:`SOAP configuration backend<soapconfbackend>` and usable for
   specific development (see :doc:`SOAP services<soapservices>` for
   more)
-  **Internal REST server** used by
   :doc:`REST configuration backend<restconfbackend>` and usable for
   specific development (see :doc:`REST services<restservices>` for
   more)
-  Interactive **management of user passwords**:

   -  Password change form (in menu)
   -  Self service reset (send a mail to the user with a to change the
      password)
   -  Force password change with LDAP password policy password reset
      flag

-  :doc:`Application menu<portalmenu>`: display authorized
   applications in categories
-  :doc:`Notifications<notifications>`: prompt users with a message
   if found in the notification database
-  Second factors management

Functioning
-----------

LL::NG portal is a modular component. It needs 4 modules to work:

-  :ref:`Authentication<start-authentication-users-and-password-databases>`:
   how check user credentials
-  :ref:`User database<start-authentication-users-and-password-databases>`:
   where collect user information
-  :ref:`Password database<start-authentication-users-and-password-databases>`:
   where change password
-  :ref:`Identity provider<start-identity-provider>`: how forward user
   identity


.. tip::

    Each module can be disabled using the ``Null`` backend.

Kinematics
----------

#. Check if URL asked is valid
#. Check if user is already authenticated

   -  If not authenticated (or authentication is forced), try to find
      (userDB module) and authenticate him (auth module), collect user data,
      compute groups and macros, ask for second factor if required,
      create a session and store it. LL::NG affords a captcha feature
      which can be enabled.

#. Modify password if asked (password module)
#. Provide identity if asked (IdP module)
#. Build :doc:`cookie(s)<ssocookie>`
#. Redirect user to the asked URL or display dynamic menu


.. note::

    See also
    :ref:`general kinematics presentation<presentation-kinematics>`.

URL parameters
--------------

Some parameters in URL can change the behavior of the portal:

-  **logout**: Launch the logout process (for example: ``logout=1``)
-  **tab**: Preselect a tab (Choice or Menu) (for example:
   ``tab=password``)
-  **llnglanguage**: Force lang used to display the page (for example:
   ``llnglanguage=fr``)
-  **setCookieLang**: Update lang cookie to persist the language set
   with ``llnglanguage`` parameter (for example: ``setCookieLang=1``)
