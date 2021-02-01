Available plugin hooks
======================

OpenID Connect Issuer hooks
---------------------------

oidcGotRequest
~~~~~~~~~~~~~~~

.. versionadded:: 2.0.10

This hook is triggered when LemonLDAP::NG received an authorization request on the `/oauth2/authorize` endpoint.

The hook's parameter is a hash containing the authorization request parameters.

Sample code::

   use constant hook => {
       oidcGotRequest               => 'addScopeToRequest',
   };

   sub addScopeToRequest {
       my ( $self, $req, $oidc_request ) = @_;
       $oidc_request->{scope} = $oidc_request->{scope} . " my_hooked_scope";

       return PE_OK;
   }


oidcGenerateUserInfoResponse
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.10

This hook is triggered when LemonLDAP::NG is about to send a UserInfo response to a relying party on the `/oauth2/userinfo` endpoint.

The hook's parameter is a hash containing all the claims that are about to be released.

Sample code::

   use constant hook => {
       oidcGenerateUserInfoResponse => 'addClaimToUserInfo',
   };

   sub addClaimToUserInfo {
       my ( $self, $req, $userinfo ) = @_;
       $userinfo->{"userinfo_hook"} = 1;
       return PE_OK;
   }

oidcGenerateIDToken
~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.10

This hook is triggered when LemonLDAP::NG is generating an ID Token.

The hook's parameters are:

* A hash of the claims to be contained in the ID Token
* the configuration key of the relying party which will receive the token 

Sample code::

   use constant hook => {
       oidcGenerateIDToken          => 'addClaimToIDToken',
   };

   sub addClaimToIDToken {
       my ( $self, $req, $payload, $rp ) = @_;
       $payload->{"id_token_hook"} = 1;
       return PE_OK;
   }

oidcGenerateAccessToken
~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.12

This hook is triggered when LemonLDAP::NG is generating an JWT-formatted Access Token

The hook's parameters are:

* A hash of the claims to be contained in the Access Token
* the configuration key of the relying party which will receive the token

Sample code::

   use constant hook => {
       oidcGenerateAccessToken          => 'addClaimToAccessToken',
   };

   sub addClaimToAccessToken {
       my ( $self, $req, $payload, $rp ) = @_;
       $payload->{"access_token_hook"} = 1;
       return PE_OK;
   }


oidcResolveScope
~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.12

This hook is triggered when LemonLDAP::NG is resolving scopes.

The hook's parameters are:

* An array ref of currently granted scopes, which you can modify
* The configuration key of the requested RP

Sample code::

   use constant hook => {
       oidcResolveScope          => 'addHardcodedScope',
   };

   sub addHardcodedScope{
       my ( $self, $req, $scopeList, $rp ) = @_;
       push @{$scopeList}, "myscope";
       return PE_OK;
   }


SAML Issuer hooks
-----------------

samlGotAuthnRequest
~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.10

This hook is triggered when LemonLDAP::NG has received a SAML login request

The hook's parameter is the Lasso::Login object

Sample code::

   use constant hook => { 
      samlGotAuthnRequest => 'gotRequest',
   };

   sub gotRequest {
       my ( $self, $res, $login ) = @_;

       # Your code here
   }

samlBuildAuthnResponse
~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.10

This hook is triggered when LemonLDAP::NG is about to build a response to the SAML login request

The hook's parameter is the Lasso::Login object

Sample code::

   use constant hook => { 
      samlBuildAuthnResponse => 'buildResponse',
   };

   sub buildResponse {
       my ( $self, $res, $login ) = @_;

       # Your code here
   }

samlGotLogoutRequest
~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.10

This hook is triggered when LemonLDAP::NG has received a SAML logout request

The hook's parameter is the Lasso::Logout object

Sample code::

   use constant hook => { 
      samlGotLogoutRequest => 'gotLogout',
   };

   sub gotLogout {
       my ( $self, $res, $logout ) = @_;

       # Your code here
   }

samlGotLogoutResponse
~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.10

This hook is triggered when LemonLDAP::NG has received a SAML logout response

The hook's parameter is the Lasso::Logout object

Sample code::

   use constant hook => { 
      samlGotLogoutResponse => 'gotLogoutResponse',
   };

   sub gotLogoutResponse {
       my ( $self, $res, $logout ) = @_;

       # Your code here
   }

samlBuildLogoutResponse
~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.10

This hook is triggered when LemonLDAP::NG is about to generate a SAML logout response

The hook's parameter is the Lasso::Logout object

Sample code::

   use constant hook => { 
      samlBuildLogoutResponse => 'buildLogoutResponse',
   };

   sub buildLogoutResponse {
       my ( $self, $res, $logout ) = @_;

       # Your code here
   }
