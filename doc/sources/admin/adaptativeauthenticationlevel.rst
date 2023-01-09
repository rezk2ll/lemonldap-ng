Adaptative Authentication Level
===============================

Presentation
------------

A user reaches an authentication level depending on which authentication
module was used, and eventually which second factor module.

This plugin allows to adapt this authentication level depending on
other conditions, like network, device, etc.

Sample use case: a strategic application is configured to require an
authentication level of 5. Users obtain level 2 with their login/password
and level 5 using a TOTP second factor. You can trust users form internal
network by incrementing their authentication level based on their IP address,
they would then not be forced to use 2FA to access the strategic application.

.. tip::

    This use case works if you enable the *Use 2FA for session upgrade* option.

Configuration
-------------

This plugin is enabled when at least one rule is defined.

To configure rules, go in ``General Parameters`` > ``Plugins`` >
``Adapative Authentication Level``.

You can then create rules with these fields:

-  **Rule**: The condition that will be evaluated. If this condition
   does not return true, then the level is not changed.
-  **Value**: How change the authentication level. First character is
   ``+``, ``-`` or ``=``, the second part is the number to add, remove 
   or set.


.. tip::

    By example, to add 3 to authentication level for users from 192.168.0.0/16 network:
    
    - Rule: ``$env->{REMOTE_ADDR} =~ /^192\.168\./``
    - Value: ``+3``

