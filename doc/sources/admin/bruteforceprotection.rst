Brute Force Protection plugin
=============================

This plugin prevents brute force attack. Plugin DISABLED by default.

After some failed login attempts, user must wait before trying to log in
again.

The aim of a brute force attack is to gain access to user accounts by
repeatedly trying to guess the password of an user. If disabled,
automated tools may submit thousands of password attempts in a matter of
seconds.

Configuration
-------------

To enable Brute Force Attack protection :

Go in Manager, ``General Parameters`` » ``Advanced Parameters`` »
``Security`` » ``Brute-force attack protection`` » ``Activation``\ and
set to ``On``.

Incremental lock time enabled
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You just have to activate it in the Manager :

Go in Manager, ``General Parameters`` » ``Advanced Parameters`` »
``Security`` » ``Brute-force attack protection`` »
``Incremental lock times`` and set to ``On``. (DISABLED by default) or
in ``lemonldap-ng.ini`` [portal] section:

.. code:: ini

   [portal]
   bruteForceProtectionIncrementalTempo = 1

Lock time increases between each failed login attempt. To modify lock
time values ('5 15 60 300 600' seconds by default) or max lock time
value (900 seconds by default) edit ``lemonldap-ng.ini`` in [portal]
section:

.. code:: ini

   [portal]
   bruteForceProtectionLockTimes = '5 15 60 300 600'
   bruteForceProtectionMaxLockTime = 900


.. important:: 

    Max lock time value is used by this plugin if a lock time is
    missing (number of failed logins higher than listed lock time values).
    Lock time values can not be higher than max lock time. 

Incremental lock time disabled
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After ``bruteForceProtectionMaxFailed`` failed login attempts, user must
wait ``bruteForceProtectionTempo`` seconds before trying to log in
again. To modify waiting time (30 seconds by default), MaxAge between
current and last stored failed login (300 seconds by default) or number
of allowed failed login attempts (3 by default) edit
``lemonldap-ng.ini`` in [portal] section:

.. code:: ini

   [portal]
   bruteForceProtectionTempo = 30
   bruteForceProtectionMaxAge = 300
   bruteForceProtectionMaxFailed = 3


.. important:: 

    Number of failed login attempts stored in history MUST
    be higher than allowed failed logins for this plugin takes effect.

