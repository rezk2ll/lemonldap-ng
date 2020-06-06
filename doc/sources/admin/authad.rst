Active Directory
================

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔     ✔
============== ===== ========

Presentation
------------

The Active Directory module is based on
:doc:`LDAP module<authldap>`, with the following features:

-  Specific default values for filters to match AD schema
-  Compatible password modification
-  Reset password on next logon workflow

Configuration
-------------

The configuration is the same as the :doc:`LDAP module<authldap>`.

AD password policy
------------------

AD password policy does not follow the LDAP RFC, but Microsoft has
implemented its own policy. LemonLDAP::NG implements partially the
policy:

-  when pwdLastSet = 0 in the user entry, it means that password has
   been reset, and a form is displayed to the user to change his
   password.
-  when computed virtual attribute 'msDS-User-Account-Control-Computed'
   as 6th flag set to 8, the password is considered expired (support
   from Windows Server 2003). It is too late for the user to do
   anything. He must contact his administrator.
-  a warning before password expiration is possible in AD, but only in
   GPO (Computer Configuration\Windows Settings\Local Policies\Security
   Options under Interactive Logon: Prompt user to change password
   before expiration). However it as no reality in LDAP referential. A
   "password warning time before password expiration" variable can be
   specified in LemonLDAP::NG to do so.


.. attention::

    Note: since AD 2012, each user can have a specific
    password expiration policy. Then, the "maximum password age" can have
    different values. This is currently unsupported in LemonLDAP::NG because
    every policy must be computed with their precedence to know which
    maximum password age to apply.

To configure warning before password expiration, you must set two
variables in Active Directory parameters in Manager:

-  **Password max age** : number of seconds after the last password
   change, before it expires. It must match AD policy
-  **Password expire warning** : number of seconds between password
   expiration and the date from which user is warned his password will
   expire.
