Auto Signin Addon
=================

Auto-Signin add-on provides an easy way to bypass authentication process
based on rules. For example, a TV can be automatically authenticated by
its IP address.

Configuration
-------------

This add-on is automatically enabled if a rule is declared. A rule links
rule to a username. The only usable variable here is ``$env``. Example:

============== ===========================================
Key (username) Rule
============== ===========================================
dwho           ''$env->{REMOTE_ADDR} eq '192.168.42.42' ''
============== ===========================================


.. important:: 

    Username must be defined in the user database.
