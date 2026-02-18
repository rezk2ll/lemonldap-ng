OpenID Connect Security
=======================

This document provides a comprehensive overview of OpenID Connect and OAuth 2.0 security options in LemonLDAP::NG.

.. contents::
   :local:
   :depth: 2

Supported Security Specifications
---------------------------------

LemonLDAP::NG implements security recommendations from:

* **OpenID Connect Core 1.0** - Authentication and security requirements
* **OpenID Connect Back-Channel Logout 1.0**
* **RFC 7636** - Proof Key for Code Exchange (PKCE)
* **RFC 7662** - OAuth 2.0 Token Introspection
* **RFC 9068** - JWT Profile for OAuth 2.0 Access Tokens
* **RFC 9207** - OAuth 2.0 Authorization Server Issuer Identification
* **RFC 9700** - OAuth 2.0 Security Best Current Practice
* **ANSSI Guidelines** and **France-Connect+ compliance** - French National Cybersecurity Agency recommendations

  - RFC 6749 (OAuth 2.0 - authorization code flow, state parameter)
  - RFC 6750 (Bearer Token Usage)
  - RFC 7515/7516 (JWS/JWE signatures and encryption)
  - RFC 7518 (JSON Web Algorithms)

Quick Reference
---------------

.. csv-table:: Security Options by Role
   :header: "Feature", "Specification", "OP Config", "RP Config"
   :widths: 25, 15, 30, 30

   "PKCE", "RFC 7636", "Require PKCE (per RP)", "PKCE required (per OP)"
   "Issuer verification (Since 2.23.0)", "RFC 9207", "Always enabled (auto)", "Issuer required"
   "State parameter", "RFC 6749", "Require state (2.19.0)", "Always sent (auto)"
   "Nonce parameter", "OIDC Core", "Require nonce (2.19.0)", "Use nonce"
   "JWS signatures", "RFC 7515", "ID Token signature alg", "Check JWT signature"
   "JWE encryption (2.19.0 FC+)", "RFC 7516", "Encryption algorithms", "N/A"
   "Hashed tokens", "ANSSI R21/R25", "Hashed session storage", "N/A"
   "Token endpoint auth", "RFC 6749", "Token endpoint auth method", "Token endpoint auth method"
   "Request objects", "OIDC Core", "Require JWS for auth requests", "Auth method for code request"


OP Security Configuration
-------------------------

This section covers all security options to configure when LemonLDAP::NG acts as an OpenID Connect Provider.

Flows
~~~~~

**RFC 9700 Recommendation**: Use the Authorization Code flow instead of Implicit or Hybrid flows.

**Configuration**: ``OpenID Connect Service`` > ``Security``:

- Disable ``Allow Implicit Grant``
- Disable ``Allow Hybrid Grant``
- Enable only ``Allow Authorization Code Grant`` (default)

PKCE
~~~~

Proof Key for Code Exchange (RFC 7636) prevents authorization code interception attacks.

**Configuration** (per Relying Party): ``OpenID Connect Relying Parties`` > *RP name* > ``Options`` > ``Security``:

- **Require PKCE**: Set to ``On`` to require code_challenge at token endpoint

.. tip::

   For public clients (mobile apps, SPAs), PKCE is essential. Enable it for all clients when possible.

State and Nonce
~~~~~~~~~~~~~~~

.. versionadded:: 2.19.0

**Configuration** (per Relying Party): ``OpenID Connect Relying Parties`` > *RP name* > ``Options`` > ``Security``:

- **Require "state" in authorization request**: Prevents CSRF attacks (ANSSI R12)
- **Require "nonce" in authorization request**: Prevents ID Token replay attacks (ANSSI R16)

Redirect URI Validation
~~~~~~~~~~~~~~~~~~~~~~~

**RFC 9700 Recommendation**: Use exact redirect URI matching, no wildcards.

**Configuration** (per Relying Party): ``OpenID Connect Relying Parties`` > *RP name* > ``Basic options``:

- **Allowed redirection addresses for login**: Space-separated list of exact URIs

Token Security
~~~~~~~~~~~~~~

Token Endpoint Authentication
"""""""""""""""""""""""""""""

**ANSSI R23 Recommendation**: Use asymmetric authentication (``private_key_jwt``) over symmetric methods.

**Configuration** (per Relying Party): ``OpenID Connect Relying Parties`` > *RP name* > ``Options`` > ``Security``:

- **Token endpoint authentication method**:

  - ``client_secret_basic`` - HTTP Basic Auth (default)
  - ``client_secret_post`` - Secret in POST body
  - ``client_secret_jwt`` - HMAC-signed JWT
  - ``private_key_jwt`` - Asymmetric signed JWT (recommended)

Hashed Token Storage
""""""""""""""""""""

Store tokens as hashes to prevent exposure in case of database compromise (ANSSI R21/R25).

**Configuration**: ``General Parameters`` > ``Advanced parameters`` > ``Security``:

- **Hashed session storage**: Set to ``On``

.. attention::

   This breaks existing OIDC offline sessions and is incompatible with SOAP-mode Proxy authentication.

Authorization Code Lifetime
"""""""""""""""""""""""""""

**Configuration**: ``OpenID Connect Service`` > ``Timeouts`` > ``Authorization Codes`` (default: 60 seconds)

Algorithms
~~~~~~~~~~

ID Token Signature
""""""""""""""""""

**Configuration** (per Relying Party): ``OpenID Connect Relying Parties`` > *RP name* > ``Options`` > ``Algorithms``:

- **ID Token signature algorithm**:

  - **Avoid**: ``none``, ``HS256`` (HMAC-based)
  - **Recommended**: ``RS256``, ``RS384``, ``RS512``, ``ES256``, ``ES384``, ``ES512``, ``PS256``, ``PS384``, ``PS512``, ``EdDSA``

.. note::

   Elliptic curve algorithms (ES*) added in 2.19.0 for `France-Connect+`_ compliance.

.. _France-Connect+: https://docs.partenaires.franceconnect.gouv.fr/fs/fs-technique/fs-technique-oidc-fc-plus/

JWT Encryption
""""""""""""""

.. versionadded:: 2.19.0
   Added for `France-Connect+`_ compliance.

For sensitive data, encrypt tokens in addition to signing.

**Configuration** (per Relying Party): ``OpenID Connect Relying Parties`` > *RP name* > ``Options`` > ``Algorithms``:

- **ID Token Encryption key management algorithm**
- **ID Token Encryption content encryption algorithm**
- **Access Token Encryption algorithms** (if JWT format)
- **UserInfo Encryption algorithms**

Other Options
~~~~~~~~~~~~~

**Require signed authorization requests** (ANSSI R9)

Per RP: ``Options`` > ``Security`` > ``Require JWS for authorization requests``

**Disable automated discovery** (ANSSI R48)

``OpenID Connect Service`` > ``Security`` > ``Don't display metadata``

**Disable dynamic registration** (ANSSI R49)

``OpenID Connect Service`` > ``Dynamic registration`` > ``Activation``: Off (default)

**Secret management** (ANSSI R35-R37)

- Use random, unique secrets per RP (use ``pwgen`` or similar)
- Plan regular secret rotation

**Logging** (ANSSI R32)

Set log level to ``info`` or ``notice`` (tokens visible in ``debug`` level).


RP Security Configuration
-------------------------

This section covers all security options to configure when LemonLDAP::NG acts as an OpenID Connect Relying Party.

PKCE
~~~~

**Configuration** (per Provider): ``OpenID Connect Providers`` > *OP name* > ``Options`` > ``Configuration``:

- **PKCE required**: Set to ``On`` to always use PKCE in authorization requests

Issuer Verification (RFC 9207)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.23.0

RFC 9207 prevents mix-up attacks by including the ``iss`` parameter in authorization responses.

**Configuration** (per Provider): ``OpenID Connect Providers`` > *OP name* > ``Options`` > ``Configuration``:

- **Issuer required (RFC 9207)**: When enabled, the RP will:

  - Verify the ``iss`` parameter matches the expected issuer (if present)
  - Reject responses without ``iss`` (when required)

.. attention::

   Enable this option when connecting to OPs that support RFC 9207 to protect against mix-up attacks.

Nonce
~~~~~

**Configuration** (per Provider): ``OpenID Connect Providers`` > *OP name* > ``Options`` > ``Protocol``:

- **Use nonce**: On (default) - Prevents ID Token replay attacks

Token Security
~~~~~~~~~~~~~~

**Configuration** (per Provider): ``OpenID Connect Providers`` > *OP name* > ``Options`` > ``Protocol``:

- **Token endpoint authentication method**: Use ``private_key_jwt`` (recommended)
- **Authentication method for authorization code request**: Prefer asymmetric algorithms
- **Signature algorithm for authorization code authentication**: Set explicit algorithm

JWT Verification
~~~~~~~~~~~~~~~~

**Configuration** (per Provider): ``OpenID Connect Providers`` > *OP name* > ``Options`` > ``Protocol``:

- **Check JWT signature**: Set to ``On``


Built-in Security Features
--------------------------

These security features are automatically implemented without configuration:

.. csv-table::
   :header: "Feature", "Description", "Reference"
   :widths: 25, 50, 25

   "State parameter (RP)", "Always sent in authorization requests", "RFC 6749, ANSSI R10"
   "Secure random generation", "State, nonce, auth codes, tokens use cryptographic random", "ANSSI R11/R15/R18/R24"
   "Domain verification", "Automatic domain name verification", "ANSSI R6"
   "Session cookies", "SSO uses secure session cookies", "ANSSI R13"
   "Open redirect protection", "URI validation prevents open redirects", "ANSSI R17"
   "Authorization code binding", "Auth codes bound to OIDC client", "ANSSI R20"
   "One-time auth codes", "Used auth codes are invalidated", "ANSSI R30"
   "ID Token validation", "Integrity and claims verification", "ANSSI R26/R28"
   "Authentication level", "ACR/AMR support for level verification", "ANSSI R29"
   "Bearer token handling", "Access tokens via Authorization header", "ANSSI R31"
   "Token timeouts", "Configurable validity limits", "ANSSI R33"
   "UserInfo cross-check", "UserInfo validated against ID Token", "ANSSI R34"
   "Event logging", "Important events logged", "ANSSI R47"
   "Issuer parameter (OP)", "RFC 9207 ``iss`` always included in responses", "RFC 9207"


Compliance Reference
--------------------

ANSSI Guidelines
~~~~~~~~~~~~~~~~

|anssi-logo|

.. |anssi-logo| image:: logos/240px-ANSSI_Logo.svg.png
   :class: align-center
   :scale: 50%

The `Agence Nationale de la Sécurité des Systèmes d'Information`_ (ANSSI) published `recommendations for securing OpenID Connect`_.

.. _Agence Nationale de la Sécurité des Systèmes d'Information: https://ssi.gouv.fr
.. _recommendations for securing OpenID Connect: https://cyber.gouv.fr/publications/recommandations-pour-la-securisation-de-la-mise-en-oeuvre-du-protocole-openid-connect

Compliance Matrix
"""""""""""""""""

.. csv-table::
   :header: "Category", "Recommendations", "LL::NG Implementation"
   :widths: 20, 30, 50

   "Flow Security", "R1", "Disable Implicit/Hybrid (configurable)"
   "TLS/Crypto", "R3-R8", "HTTPS required, JWS algorithms configurable"
   "Auth Request", "R9-R16", "State/nonce automatic (RP) or required (OP 2.19.0)"
   "Auth Code", "R17-R22", "Automatic: random, bound, one-time, hashed (opt)"
   "Token Security", "R23-R25", "Token endpoint auth methods, hashed storage (opt)"
   "ID Token", "R26-R30", "Automatic validation and verification"
   "Access Token", "R31-R34", "Automatic: header, timeouts, cross-check"
   "Secrets", "R35-R41", "Per-RP secrets recommended"
   "Algorithms", "R42-R44", "Configurable per RP, ES* since 2.19.0"
   "Operations", "R45-R51", "Logging, discovery toggle, no dynamic reg"

Complete ANSSI Recommendations Reference
""""""""""""""""""""""""""""""""""""""""

Below is the complete list of ANSSI recommendations (in French, as in the original document):

* **R1** Utiliser en priorité la cinématique authorization code pour les applications Web
* **R2** Mettre en place une politique de sécurité
* **R3** Mettre en œuvre HTTPS
* **R4** Appliquer les recommandations de sécurité relatives à TLS
* **R5** Imposer aux clients OIDC des suites cryptographiques recommandées pour les communications serveur à serveur
* **R6** Vérifier le nom de domaine
* **R7** Utiliser le certificate pinning
* **R8** Utiliser un JWS protégé par un HMAC
* **R8+** Utiliser un JWS protégé par une signature
* **R9** Imposer un mode de transmission des paramètres dans une demande d'authentification
* **R10** Systématiser l'envoi du paramètre state
* **R11** Générer aléatoirement le paramètre state
* **R12** Détecter les demandes d'authentification sans le paramètre state
* **R13** Utiliser les cookies de session
* **R14** Systématiser l'envoi du paramètre nonce
* **R15** Générer aléatoirement le paramètre nonce
* **R16** Détecter les demandes d'authentification sans le paramètre nonce
* **R17** Se protéger contre les redirections ouvertes
* **R18** Générer aléatoirement les authorization code
* **R19** Limiter la durée de vie d'un authorization code
* **R20** Associer le code authorization code au client OIDC
* **R21** Stocker les authorization code sous forme d'empreinte
* **R22** Vérifier le paramètre state associé à la session de l'utilisateur
* **R23** Utiliser une authentification du client OIDC adaptée
* **R24** Générer aléatoirement les access token
* **R25** Stocker les access token sous formes d'empreintes
* **R26** Vérifier l'intégrité de l'ID Token
* **R27** Utiliser un secret partagé différent du client_secret pour générer le HMAC de l'ID Token
* **R28** Vérifier les informations d'un ID Token
* **R29** Vérifier le niveau d'authentification de l'utilisateur
* **R30** Rendre inutilisables les authorization code
* **R31** Transmettre les access token par l'entête Authorization
* **R32** Ne pas écrire dans les journaux les access token
* **R33** Restreindre la durée de validité d'un access token
* **R34** Croiser les informations du UserInfo et de l'ID Token
* **R35** Générer aléatoirement les secrets d'authentification partagés
* **R36** Renouveler les secrets d'authentification partagés
* **R37** Utiliser un secret différent par client OIDC
* **R38** Restreindre l'accès au secret d'authentification
* **R39** Utiliser des certificats pour authentifier les JWS
* **R40** Restreindre l'accès à la clé privée de signature
* **R41** Vérifier la révocation des certificats
* **R42** Utiliser des fonctions de hachage recommandées
* **R43** Utiliser des mécanismes de signature recommandés
* **R44** Fixer l'algorithme utilisé pour le JWS
* **R45** Sécuriser l'application Web OIDC
* **R46** Mettre en oeuvre un système de journalisation
* **R47** Journaliser les évènements importants
* **R48** Désactiver la découverte automatisée
* **R49** Ne pas utiliser l'enrôlement automatisé
* **R50** Sécuriser l'interface Web de configuration d'un client OIDC
* **R51** Vérifier l'identité des fournisseurs de service

France-Connect+
~~~~~~~~~~~~~~~

.. versionadded:: 2.19.0

`France-Connect+`_ requires specific security options:

- **JWE encryption**: ID Token and UserInfo encryption support
- **Elliptic curve algorithms**: ES256, ES384, ES512 for signatures

RFC Coverage
~~~~~~~~~~~~

RFC 9700 - Security Best Current Practice
"""""""""""""""""""""""""""""""""""""""""

RFC 9700 (formerly draft-ietf-oauth-security-topics) defines best current practices for OAuth 2.0 security.

**Key recommendations implemented:**

- Authorization Code flow only (configurable)
- PKCE support (configurable per RP/OP)
- Exact redirect URI matching
- Secure token handling

RFC 9207 - Issuer Identification
""""""""""""""""""""""""""""""""

.. versionadded:: 2.23.0

- **OP**: ``iss`` parameter automatically included in all authorization responses
- **RP**: Configurable verification of ``iss`` parameter

RFC 7636 - PKCE
"""""""""""""""

- **OP**: Require PKCE per RP
- **RP**: Enable PKCE per OP


Security Checklists
-------------------

OP Security Checklist
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: text

   [ ] Disable Implicit and Hybrid flows
   [ ] Enable PKCE requirement for all RPs
   [ ] Require state and nonce parameters
   [ ] Use private_key_jwt for token endpoint authentication
   [ ] Configure ID Token signature algorithm (RS256 or ES256)
   [ ] Enable hashed session storage
   [ ] Set appropriate token timeouts
   [ ] Use unique secrets per RP
   [ ] Disable dynamic registration (unless needed)
   [ ] Configure appropriate log level
   [ ] Protect Manager access
   [ ] Use HTTPS only

RP Security Checklist
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: text

   [ ] Enable PKCE
   [ ] Enable Issuer verification (RFC 9207)
   [ ] Enable nonce
   [ ] Use private_key_jwt for token endpoint authentication
   [ ] Enable JWT signature verification
   [ ] Use appropriate ACR values
   [ ] Configure proper redirect URIs
   [ ] Use HTTPS only


See Also
--------

* :doc:`OpenID Connect Provider<idpopenidconnect>`
* :doc:`OpenID Connect Relying Party<authopenidconnect>`
* :doc:`OpenID Connect Service<openidconnectservice>`
* :doc:`Security recommendations<security>`
* :doc:`Keys management<keys>`
