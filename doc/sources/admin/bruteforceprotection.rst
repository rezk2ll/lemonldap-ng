Brute Force Protection plugin
=============================

This plugin prevents brute force attack. Plugin DISABLED by default.

After some failed login attempts, user must wait before trying to log in
again.

The aim of a brute force attack is to gain access to user accounts by
repeatedly trying to guess the password of an user. If disabled,
automated tools may submit thousands of password attempts in a matter of
seconds.

.. attention::
    This plugin relies on the Login History, stored in users' persistent sessions.
    This means that the authentication and persistent session backends will be
    accessed for every login attempt, even fraudulent ones. This plugin is not
    meant to protect against denial of service attacks.


Configuration
-------------

To enable Brute Force Attack protection:

Go in Manager, ``General Parameters`` » ``Advanced Parameters`` »
``Security`` » ``Brute-force attack protection`` » ``Activation``\ and
set to ``On``.

-  **Parameters**:

   -  **Activation**: Enable/disable brute force attack protection
   -  **Lock time**: Waiting time before another login attempt
   -  **Allowed failed login**: Number of failed login attempts allowed before account is locked
   -  **Incremental lock**: Enable/disable incremental lock times
   -  **Incremental lock times**: List of comma separated lock time values in seconds
   -  **Maximum lock time**: Lock time values can not be higher than max lock time
   -  **Maximum age**: Delta between current and last stored failed login 


Incremental lock time enabled
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You just have to activate it in the Manager :

Go in Manager, ``General Parameters`` » ``Advanced Parameters`` »
``Security`` » ``Brute-force attack protection`` »
``Incremental lock times`` and set to ``On``. (DISABLED by default) or
in ``lemonldap-ng.ini`` [portal] section:

.. code-block:: ini

   [portal]
   bruteForceProtectionIncrementalTempo = 1

Lock time increases between each failed login attempt after allowed failed logins.

.. code-block:: ini

   [portal]
   bruteForceProtectionLockTimes = 5, 15, 60, 300, 600
   bruteForceProtectionMaxLockTime = 900


.. note::

    Max lock time value is used if a lock time is missing
    (number of failed logins higher than listed lock time values).
    Lock time values can not be higher than max lock time.


Incremental lock time disabled
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After allowed failed login attempts, user must wait
the lock time before trying to log in again.


.. attention::
    Number of failed login attempts history might be also higher than
    number of incremental lock time value plus allowed failed login attempts.
    Incremental lock time values list will be truncated if not.


.. danger::
    Number of failed login attempts stored in history MUST
    be higher than allowed failed logins for this plugin takes effect.
    See :doc:`History plugin<loginhistory>`