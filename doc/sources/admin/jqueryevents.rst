Available JQuery Events
========================

Some portal functions (such as 2FA registration) are performed by Javascript.

We offer a few custom events that let you react to certain high-level Javascript events

Preventing default behavior
---------------------------

.. versionadded:: 2.17

Event handlers can stop the default LemonLDAP::NG behavior from executing:

.. code:: javascript

    $(document).on( "sslFailure", { }, function( event ) {
                event.preventDefault();
                // Navigate the user to the smartcard help page, etc.
    });


Second factor management
------------------------

mfaAdded
~~~~~~~~

.. versionadded:: 2.0.15

This event is triggered when a TOTP, WebAuthn or U2F device is registered

Sample code:

.. code:: javascript

    $(document).on( "mfaAdded", { }, function( event, info ) {
                console.log( "Added MFA of type" + info.type );
                // Your code here

                // If you want to prevent the redirection to the 2FA register page
                // event.preventDefault();
    });

.. versionchanged:: 2.0.16

    LemonLDAP::NG redirects to the 2FA Register page after your
    device has been added. You can cancel this redirection by calling
    ``event.preventDefault()`` in your listener.

mfaDeleted
~~~~~~~~~~~

.. versionadded:: 2.0.15

This event is triggered when a TOTP, WebAuthn or U2F device is removed

Sample code:

.. code:: javascript

    $(document).on( "mfaDeleted", { }, function( event, info ) {
                console.log( "Removed MFA of type" + info.type );
                // Your code here
    });

UI
--

portalLoaded
~~~~~~~~~~~~
.. versionadded:: 2.0.16

This even is triggered after the main portal javascript has run

Sample code:

.. code:: javascript


    $(document).on( "portalLoaded", { }, function( event, info ) {
            // Make sure DOM is ready as well
            $( document ).ready(function() {
                    console.log("Portal loaded and DOM ready");
            });
    });



Authentication
--------------

kerberosAttempt
~~~~~~~~~~~~~~~

.. versionadded:: 2.17

This even is triggered immediately before the user tries to authenticate using Kerberos

.. code:: javascript

    $(document).on( "kerberosAttempt", { }, function( event ) {
                console.log( "Kerberos attempt" );
    });

kerberosFailure
~~~~~~~~~~~~~~~

.. versionadded:: 2.17

This even is triggered when the user failed to authenticate using Kerberos

.. code:: javascript

    $(document).on( "kerberosFailure", { }, function( event , info ) {
                console.log( "Kerberos failure", info );
    });

kerberosSuccess
~~~~~~~~~~~~~~~

.. versionadded:: 2.17

This even is triggered when before the user successfully authenticated using Kerberos

.. code:: javascript

    $(document).on( "kerberosSuccess", { }, function( event , info ) {
                console.log( "Kerberos success", info );
    });

sslAttempt
~~~~~~~~~~

.. versionadded:: 2.17

This even is triggered immediately before the user tries to authenticate using SSL

.. code:: javascript

    $(document).on( "sslAttempt", { }, function( event ) {
                console.log( "SSL attempt" );
    });

sslFailure
~~~~~~~~~~

.. versionadded:: 2.17

This even is triggered when the user failed to authenticate using SSL

.. code:: javascript

    $(document).on( "sslFailure", { }, function( event , info ) {
                console.log( "SSL failure", info );
    });

sslSuccess
~~~~~~~~~~

.. versionadded:: 2.17

This even is triggered when before the user successfully authenticated using SSL

.. code:: javascript

    $(document).on( "sslSuccess", { }, function( event , info ) {
                console.log( "SSL success", info );
    });


webauthnAttempt
~~~~~~~~~~~~~~~

.. versionadded:: 2.17

This even is triggered immediately before the user tries to use a WebAuthn device

.. code:: javascript

    $(document).on( "webauthnAttempt", { }, function( event ) {
                console.log( "WebAuthn attempt" );
    });

webauthnFailure
~~~~~~~~~~~~~~~

.. versionadded:: 2.17

This even is triggered when the user failed to use a WebAuthn device

.. code:: javascript

    $(document).on( "webauthnFailure", { }, function( event , info ) {
                console.log( "WebAuthn failure", info );
    });

webauthnSuccess
~~~~~~~~~~~~~~~

.. versionadded:: 2.17

This even is triggered when the user successfully used a WebAuthn device

.. code:: javascript

    $(document).on( "webauthnSuccess", { }, function( event , info ) {
                console.log( "WebAuthn success", info );
    });

webauthnRegistrationAttempt
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.17

This even is triggered immediately before the user tries to register a WebAuthn device

.. code:: javascript

    $(document).on( "webauthnRegistrationAttempt", { }, function( event ) {
                console.log( "WebAuthn registration attempt" );
    });

webauthnRegistrationFailure
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.17

This even is triggered when the user failed to register a WebAuthn device

.. code:: javascript

    $(document).on( "webauthnRegistrationFailure", { }, function( event , info ) {
                console.log( "WebAuthn registration failure", info );
    });

webauthnRegistrationSuccess
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.17

This even is triggered when the user successfully registered a WebAuthn device

.. code:: javascript

    $(document).on( "webauthnRegistrationSuccess", { }, function( event , info ) {
                console.log( "WebAuthn registration success", info );
    });
