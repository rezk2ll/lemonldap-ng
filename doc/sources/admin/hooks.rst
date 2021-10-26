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

oidcGotClientCredentialsGrant
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.12

This hook is triggered when LemonLDAP::NG successfully authorized a :ref:`Client Credentials Grant <client-credentials-grant>`.

The hook's parameters are:

* A hash of the current session info
* the configuration key of the relying party which is being identified

Sample code::

   use constant hook => {
       oidcGotClientCredentialsGrant => 'addSessionVariable',
   };

   sub addSessionVariable {
       my ( $self, $req, $info, $rp ) = @_;
       $info->{is_client_credentials} = 1;

       return PE_OK;
   }


oidcGenerateCode
~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.12

This hook is triggered when LemonLDAP::NG is about to generate an Authorization Code for a Relying Party.

The hook's parameters are:

* A hash of the parameters for the OIDC Authorize request, which you can modify
* the configuration key of the relying party which will receive the token
* A hash of the session keys for the (internal) Authorization Code session

Sample code::

   use constant hook => {
       oidcGenerateCode              => 'modifyRedirectUri',
   };

   sub modifyRedirectUri {
       my ( $self, $req, $oidc_request, $rp, $code_payload ) = @_;
       my $original_uri = $oidc_request->{redirect_uri};
       $oidc_request->{redirect_uri} = "$original_uri?hooked=1";
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

CAS Issuer hooks
-----------------

casGotRequest
~~~~~~~~~~~~~

.. versionadded:: 2.0.12

This hook is triggered when LemonLDAP::NG received an CAS authentication request on the `/cas/login` endpoint.

The hook's parameter is a hash containing the CAS request parameters.

Sample code::

   use constant hook => {
       casGotRequest                 => 'filterService'
   };

   sub filterService {
       my ( $self, $req, $cas_request ) = @_;
       if ( $cas_request->{service} eq "http://auth.sp.com/" ) {
           return PE_OK;
       }
       else {
           return 999;
       }
   }


casGenerateServiceTicket
~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.12

This hook is triggered when LemonLDAP::NG is about to generate a Service Ticket for a CAS application

The hook's parameters are:

* A hash of the parameters for the CAS request, which you can modify
* the configuration key of the cas application which will receive the ticket
* A hash of the session keys for the (internal) CAS session

Sample code::

   use constant hook => {
       'casGenerateServiceTicket'    => 'changeRedirectUrl',
   };

   sub changeRedirectUrl {
       my ( $self, $req, $cas_request, $app, $Sinfos ) = @_;
       $cas_request->{service} .= "?hooked=1";
       return PE_OK;
   }


casGenerateValidateResponse
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.12

This hook is triggered when LemonLDAP::NG is about to send a CAS response to an application on the `/cas/serviceValidate` endpoint.

The hook's parameters are:

* The username (CAS principal)
* A hash of modifiable attributes to be sent

Sample code::

   use constant hook => {
       casGenerateValidateResponse    => 'addAttributes',
   };

   sub addAttributes {
       my ( $self, $req, $username, $attributes ) = @_;
       $attributes->{hooked} = 1;
       return PE_OK;
   }


Password change hooks
---------------------


passwordBeforeChange
~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.12

This hook is triggered when LemonLDAP::NG is about to change or reset a user's password. Returning an error will cancel the password change operation

The hook's parameters are:

* The main user identifier
* The new password
* The old password, if relevant

Sample code::

   use constant hook => {
       passwordBeforeChange => 'blacklistPassword',
   };

   sub blacklistPassword {
       my ( $self, $req, $user, $password, $old ) = @_;
       if ( $password eq "12345" ) {
           $self->logger->error("I've got the same combination on my luggage");
           return PE_PP_INSUFFICIENT_PASSWORD_QUALITY;
       }
       return PE_OK;
   }


passwordAfterChange
~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.12

This hook is triggered after LemonLDAP::NG has changed the user's password successfully in the underlying password database

The hook's parameters are:

* The main user identifier
* The new password
* The old password, if relevant

Sample code::

   use constant hook => {
       passwordAfterChange  => 'logPasswordChange',
   };

   sub logPasswordChange {
       my ( $self, $req, $user, $password, $old ) = @_;
       $old ||= "";
       $self->userLogger->info("Password changed for $user: $old -> $password");
       return PE_OK;
   }
