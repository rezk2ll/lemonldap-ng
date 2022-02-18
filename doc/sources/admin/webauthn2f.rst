WebAuthn as a second factor
===========================

`Web Authentication <https://www.w3.org/TR/webauthn/>`__ , shortened as WebAuthn, is a standard method by which a web browser can authenticate to an application (*Relying Party*, in our case, this is LemonLDAP::NG) through the use of an *Authenticator*, which can be a hardware token (USB, NFC...) or provided by the user's device itself (TPM).


.. versionadded:: 2.0.14
   Currently, we only implement WebAuthn as a second factor. Passwordless,
   first-factor authentication will be added in a later release.

Implementation status
~~~~~~~~~~~~~~~~~~~~~

Currently, we implement:

* Device registration without attestation validation (attestation type: *None*)
* Authentication as a second factor with the registered device

Requirements
~~~~~~~~~~~~

You need to install the `Authen::WebAuthn` CPAN module for WebAuthn to work on
your LemonLDAP::NG installation. If there is no package for it in your
distribution, you can install it with::

    cpanm Authen::WebAuthn

Configuration
~~~~~~~~~~~~~

- **Activation**: set it to "on"
- **User verification**: Whether or not LemonLDAP::NG requires the user to
  authenticate to their second factor device. Usually by entering a PIN code.
  *Warning*: The *Required* option is not supported by older U2F security keys.
- **Self registration**: set it to "on" if users are authorized to
  register their keys
- **Relying Party display name**: How the LemonLDAP::NG server will appear in
  the web browser messages displayed to the user
- **Allow users to remove WebAuthn**: If enabled, users can unregister their WebAuthn device.
- **Authentication level**: you can overwrite here auth level for
  WebAuthn registered users. Leave it blank keeps auth level provided by
  first authentication module *(default: 2 for user/password based
  modules)*. **It is recommended to set an higher value here if you
  want to give access to some apps only for enrolled users**
- **Label** (Optional): label that should be displayed to the user on
  the choice screen
- **Logo** (Optional): logo file *(in static/<skin> directory)*


.. _migrateu2ftowebauthn:

Migrating existing U2F devices
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

WebAuthn is compatible with both FIDO and FIDO2 standards. Which means this
module lets you use any U2F-compatible device you already own.

You can use the ``lemonldap-ng-sessions`` tool to migrate existing U2F devices to the WebAuthn plugin ::

    # For one user
    lemonldap-ng-sessions secondfactors migrateu2f dwho

    # For all users
    lemonldap-ng-sessions secondfactors migrateu2f --all

Once you are satisfied with WebAuthn, you can remove existing U2F devices and
disable the U2F second factor module ::

    # For one user
    lemonldap-ng-sessions secondfactors delType dwho U2F

    # For all users
    lemonldap-ng-sessions secondfactors delType --all U2F
