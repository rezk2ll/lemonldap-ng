Available plugin hooks
======================

This page shows the list of hooks that you can use in your :doc:`custom plugins <plugincustom>`. Read the :doc:`plugincustom` page for full details on how to create and enable custom plugins.

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

This hook is triggered when LemonLDAP::NG is about to send a UserInfo response to a relying party on the `/oauth2/userinfo` endpoint, or to compute a list of claims to be added in an ID or Access Token.

The hook's parameter is a hash containing all the claims that are about to be released.

.. versionchanged:: 2.0.15
   Added the hash of current session data

Sample code::

   use constant hook => {
       oidcGenerateUserInfoResponse => 'addClaimToUserInfo',
   };

   sub addClaimToUserInfo {
       my ( $self, $req, $userinfo, $rp, $session_data) = @_;
       my $scope = $session_data->{_scope};
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


oidcGotOnlineRefresh
~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.15

This hook is triggered when LemonLDAP::NG handles a Refresh Token grant for an
online session

The hook's parameters are:

* the configuration key of the relying party which received the grant
* A hash of session data for the (internal) Refresh Token session
* A hash of the user's session data

Sample code::

   use constant hook => {
       oidcGotOnlineRefresh          => 'logRefresh',
   };

   sub logRefresh {
       my ( $self, $req, $rp, $refreshInfo, $sessionInfo ) = @_;
       my $uid = $sessionInfo->{uid};
       $self->userLogger->info("OIDC application $rp requested a new access token for $uid");
       return PE_OK;
   }

oidcGotOfflineRefresh
~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.15

This hook is triggered when LemonLDAP::NG handles a Refresh Token grant for an
offline session

The hook's parameters are:

* the configuration key of the relying party which received the grant
* A hash of session data for the (internal) Refresh Token session, which also
  contains user attributes

Sample code::

   use constant hook => {
       oidcGotOfflineRefresh          => 'logRefreshOffline',
   };

   sub logRefreshOffline {
       my ( $self, $req, $rp, $refreshInfo ) = @_;
       my $uid = $refreshInfo->{uid};
       $self->userLogger->info("OIDC application $rp used offline access for $uid");
       return PE_OK;
   }


oidcGotTokenExchange
~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.16

This hook is triggered when LemonLDAP::NG handles an OAuth 2.0 Token Exchange request.

It allows you to implement your own custom Token Exchange flow.

You can look for parameters in ``$req``. If you find a combination of parameters that you support, set ``$req->response`` and return ``PE_SENDRESPONSE``. Else, return ``PE_OK`` to continue or ``PE_ERROR`` to fail.


Sample code::

    use constant hook => { oidcGotTokenExchange => 'tokenExchange', };

    sub tokenExchange {
        my ( $self, $req, $rp ) = @_;
        my $subject_token = $req->param('subject_token');
        my $subject_token_type = $req->param('subject_token_type');

        if ( #... ) {
            $req->response(
                $self->p->sendJSONresponse(
                    $req,
                    {
                        access_token => ...,
                        issued_token_type => ...,
                        token_type => ...,
                    }
                )
            );
            return PE_SENDRESPONSE;
        }
        return PE_OK;
    }

getOidcRpConfig
~~~~~~~~~~~~~~~

.. versionadded:: 2.17

This hook is triggered when processing a request for a Client ID that is not
registered as an OIDC RP.

You can use this hook to inject configuration on-demand. Update `$config` with
the RP configuration ::

   use constant hook => {
      getOidcRpConfig => 'getRpFromDB',
   };

   sub getRpFromDB {
       my ( $self, $req, $client_id, $config ) = @_;

       # Lookup $entityID in some DB

       # Update the provided $config reference
       %$config = (
           confKey     => # a unique configuration key
           attributes  => # hashref of attributes to return
           options     => # hashref of options
           macros      => # hashref of macros to compute
           scopeRules  => # hashref of scope rules
           extraClaims => # hashref of additional scopes to consider
       );

       # Set the TTL even if nothing was found in DB to prevent LLNG from
       # calling the hook too often
       $config->{ttl} = 3600;

       return PE_OK;
   }


SAML service hooks
------------------

getSamlConfig
~~~~~~~~~~~~~

.. versionadded:: 2.0.16

This hook is triggered when an entityID that is not registered in SAML
configuration (IDP or SP) is trying to communicate with LemonLDAP::NG

You can use this hook to inject configuration on-demand. Update `$config` with
the IDP or SP information::

   use constant hook => {
      getSamlConfig => 'getConfFromDB',
   };

   sub getConfFromDB {
       my ( $self, $req, $entityID, $config ) = @_;

       # Lookup $entityID in some DB

       # Update the provided $config reference
       %$config = (
           sp_metadata => #XML metadata
           sp_confKey => #configuration key
           sp_attributes => #hashref of exported attributes
           sp_options => #hashref of options
           sp_macros => #hashref of macros

           idp_metadata => #XML metadata
           idp_attributes => #hashref of exported attributes
           idp_options => #hashref of options
       );

       # Set the TTL even if nothing was found in DB to prevent LLNG from
       # calling the hook too often
       $config->{ttl} = 3600;

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
       my ( $self, $req, $login ) = @_;

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
       my ( $self, $req, $login ) = @_;

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
       my ( $self, $req, $logout ) = @_;

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
       my ( $self, $req, $logout ) = @_;

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
       my ( $self, $req, $logout ) = @_;

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


SAML Authentication hooks
-------------------------

samlGenerateAuthnRequest
~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.15

This hook is triggered when LemonLDAP::NG is building a SAML authentication request for an external IDP

The hook's parameters are:

* The configuration key of the IDP
* The ``Lasso::Login`` object

Sample code::

   use constant hook => {
       samlGenerateAuthnRequest    => 'genRequest',
   };

   sub genRequest {
       my ( $self, $req, $idp, $login ) = @_;

       # Your code here
   }

samlGotAuthnResponse
~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.15

This hook is triggered after LemonLDAP::NG successfully validated a SAML authentication response from an IDP

The hook's parameters are:

* The configuration key of the IDP
* The ``Lasso::Login`` object

Sample code::

   use constant hook => {
       samlGotAuthnResponse    => 'gotResponse',
   };

   sub gotResponse {
       my ( $self, $req, $idp, $login ) = @_;

       # Your code here
   }


OpenID Connect Authentication Hooks
-----------------------------------

oidcGenerateAuthenticationRequest
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.15

This hook is triggered when LemonLDAP::NG is building the Authentication Request that will be sent to an OpenID Provider

The hook's parameters are:

* The configuration key of the OP
* A hash reference of request parameters that will be added to the OP's ``authorization_endpoint``.

Sample code::

   use constant hook => {
       oidcGenerateAuthenticationRequest  => 'genAuthRequest',
   };

   sub genAuthRequest {
       my ( $self, $req, $op, $authorize_request_params ) = @_;

       $authorize_request_params->{my_param} = "my value";
       return PE_OK;
   }



oidcGenerateTokenRequest
~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.15

This hook is triggered when LemonLDAP::NG is building the Token Request from that will be sent to an OpenID Provider

The hook's parameters are:

* The configuration key of the OP
* A hash reference of request parameters that will be sent in the body of the request to the ``token_endpoint``.

Sample code::

   use constant hook => {
       oidcGenerateTokenRequest => 'genTokenRequest',
   };

   sub genTokenRequest {
       my ( $self, $req, $op, $token_request_params) = @_;

       $token_request_params->{my_param} = "my value";
       return PE_OK;
   }

oidcGotIDToken
~~~~~~~~~~~~~~

.. versionadded:: 2.0.15

This hook is triggered after LemonLDAP::NG successfully received and decoded the ID Token from an external OpenID Provider

The hook's parameters are:

* The configuration key of the OP
* A hash reference of the decoded ID Token payload

Sample code::

   use constant hook => {
       oidcGotIDToken  => 'modifyIDToken',
   };

   sub modifyIDToken {
       my ( $self, $req, $op, $id_token_payload_hash ) = @_;

       # do some post-processing on the `sub` claim
       $id_token_payload_hash->{sub} = lc($id_token_payload_hash->{sub});
       return PE_OK;
   }

oidcGotUserInfo
~~~~~~~~~~~~~~~

.. versionadded:: 2.0.15

This hook is triggered after LemonLDAP::NG successfully received the UserInfo response from an external OpenID Provider

The hook's parameters are:

* The configuration key of the OP
* A hash reference of decoded UserInfo payload

Sample code::

   use constant hook => {
       oidcGotUserInfo  => 'modifyUserInfo',
   };

   sub modifyUserInfo {
       my ( $self, $req, $op, $userinfo_content ) = @_;

       # Custom attribute processing
       $userinfo_content->{my_attribute} = 1;
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


Second factor hooks
-------------------

sfBeforeVerify
~~~~~~~~~~~~~~

.. versionadded:: 2.18

This hook is called immediately before LemonLDAP::NG calls the `verify` method
of each second factor implementation in order to verify the code/response
submitted by the user. You can use it to run additional checks.

The hook's parameters are:
* An instance of the 2F module in use
* A hash of session information

Sample code::

    use constant hook => { sfBeforeVerify => 'ipHasChanged', };

    sub ipHasChanged {
        my ( $self, $req, $sfa, $session ) = @_;
        my $prefix = $sfa->prefix;

        if ($req->address ne $session->{ipAddr}) {
            $self->logger->error("Error when validating $prefix: IP has changed");
            return PE_ERROR;
        }

        return PE_OK;
    }

Generic hooks
-------------

sendHtml
~~~~~~~~

.. versionadded:: 2.17

This hook is called whenever the LemonLDAP::NG portal is about to generate a page using its template engine

The hook's parameters are:

* A reference to the template name (it can be changed by plugins)
* A reference to the hash of Lemonldap::NG::Common::sendHtml arguments, which
  includes template parameters and response code

Sample code::

    use constant hook => { sendHtml => 'injectParam', };

    sub injectParam {
        my ( $self, $req, $tpl, $args ) = @_;

        # Add variable to the "menu.tpl" template
        if ( $$tpl eq "menu" ) {
            $args->{params}->{MY_PARAM} = "xx";
        }
        return PE_OK;
    }
