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

**How it works:**

The lock times list is prepended with zeros for the allowed failed logins.
For example, with ``bruteForceProtectionMaxFailed = 3`` and
``bruteForceProtectionLockTimes = 300, 600, 900``, the effective list becomes:
``[0, 0, 300, 600, 900]``.

The lock time is determined by the number of recent failed logins:

- 1st and 2nd failed login: no lock (lock time = 0)
- 3rd failed login: locked for 300 seconds (5 minutes)
- 4th failed login: locked for 600 seconds (10 minutes)
- And so on...

When a user is locked, they must wait for the lock time to expire before
attempting to log in again. Login attempts while locked (even with the
correct password) are rejected but do **not** increase the failed login
counter.

.. note::

    Max lock time value is used if a lock time is missing
    (number of failed logins higher than listed lock time values).
    Lock time values higher than or equal to max lock time are ignored
    (a warning is logged).


Incremental lock time disabled
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After allowed failed login attempts, user must wait
the lock time before trying to log in again.


.. attention::
    Number of failed login attempts history must be higher than
    the number of incremental lock time values plus allowed failed login attempts.
    The incremental lock time values list will be truncated if not.


.. danger::
    Number of failed login attempts stored in history MUST
    be higher than allowed failed logins for this plugin takes effect.
    See :doc:`History plugin<loginhistory>`