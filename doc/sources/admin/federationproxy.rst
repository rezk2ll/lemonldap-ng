LL::NG as federation protocol proxy
===================================

LL::NG can use federation protocols (SAML, CAS, OpenID) independently to:

-  authenticate users
-  provide identities to other systems

So you can configure it to authenticate users using a federation
protocol and simultaneously to provide identities using other(s)
federation protocols.

Tested schemes:

-  SAML / OpenID-Connect:

   -  SAML-SP **<=>** LLNG as
      :doc:`SAML<idpsaml>`/:doc:`OpenID-Connect<authopenidconnect>`
      proxy **<=>** OIDC Provider
   -  OIDC-RP **<=>** LLNG as
      :doc:`OpenID-Connect<idpopenidconnect>`/:doc:`SAML<authsaml>`
      proxy **<=>** SAML Identity Provider

-  SAML / CAS

   -  SAML-SP **<=>** LLNG as :doc:`SAML<idpsaml>`/:doc:`CAS<authcas>`
      proxy **<=>** CAS Server
   -  CAS Application **<=>** LLNG as
      :doc:`CAS<idpcas>`/:doc:`SAML<authsaml>` proxy **<=>** SAML
      Identity Provider

Note that OpenID-Connect consortium has not already defined single-logout
initiated by OpenID-Connect Provider. LL::NG will implement it when this
standard will be published.


.. attention::

    Federation proxy installation can be complex. Don't
    hesitate to contact us on lemonldap-ng-users@ow2.org

See the following chapters:

-  :ref:`Authentication protocols<start-authentication-users-and-password-databases>`
-  :ref:`Identity provider<start-identity-provider>`
