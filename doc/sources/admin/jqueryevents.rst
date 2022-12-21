Available JQuery Events
========================

Some portal functions (such as 2FA registration) are performed by Javascript.

We offer a few custom events that let you react to certain high-level Javascript events

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
    });


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
