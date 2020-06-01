Grant Session
=============

Presentation
------------

The goal of this plugin is to evaluate different conditions before
allowing a user to open a session on the portal. When a condition is not
met, then the user is prompted with a customized message.

Configuration
-------------

This plugin is enabled by default.

To configure rules, go in ``General Parameters`` > ``Sessions`` >
``Opening conditions``.

You can then create rules with these fields:

-  **Comment**: a label for your rule, than can be used to order it
   (rules are evaluated by alphabetical order).
-  **Rule**: The condition that will be evaluated. If this condition
   does not return true, then the session is refused.
-  **Message**: The message that will be displayed. That message can
   contain session data as user attributes or macros.

.. tip::

    By example, you can set a message like this:
    "hello $uid your are not allowed to login"
