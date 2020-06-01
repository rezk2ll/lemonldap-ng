Auto Signin Addon
=================

Auto-Signin plugin provides an easy way to bypass authentication process
based on rules. For example, a TV can be automatically authenticated by
its IP address.

Configuration
-------------

This add-on is automatically enabled if a rule is defined. A rule links
rule to an username. The only availble variable here is ``$env``. Example:

============== ===========================================
Key (username) Rule
============== ===========================================
dwho           ''$env->{REMOTE_ADDR} eq '192.168.42.42' ''
============== ===========================================


.. attention::

    Username must be defined in users database.
