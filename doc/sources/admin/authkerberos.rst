Kerberos
========

============== ===== ========
Authentication Users Password
============== ===== ========
✔
============== ===== ========

Presentation
------------

`Kerberos <https://en.wikipedia.org/wiki/Kerberos_(protocol)>`__ is a
network authentication protocol used for authenticating users based on
their desktop session.

LL::NG uses GSSAPI module to validate Kerberos ticket against a local
keytab.

LL::NG Configuration
--------------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose Kerberos for authentication. Then go to "Kerberos parameters"
and configure the following parameters:

-  **Keytab file** (required): the Kerberos keytab file (see below.)
-  **Use Ajax request**: set to "enabled" if you want to use an Ajax
   request instead of a direct Kerberos attempt. **This is required if
   you want to chain Kerberos in a** :doc:`combination<authcombination>`
-  **Kerberos authentication level**: default to 3
-  **Remove domain in username**: set to "enabled" to strip username
   value and remove the '@domain'.
-  **Allowed domains**: if set, tickets will only be accepted if they come
   from one of the domains listed here. This is a space-separated list.
   This feature can be useful when using :doc:`combination<authcombination>`
   and cross-realm Kerberos trusts.

.. attention::

    -  Due to a perl GSSAPI issue, you may need to copy the keytab in
       /etc/krb5.keytab which is the default location hardcoded in the
       library


Obtaining the Keytab 
~~~~~~~~~~~~~~~~~~~~

Configuring your environment (Windows domain, workstations, etc) and obtaining
a keytab for LemonLDAP::NG is quite complex. You can find some guidance
:doc:`on this page<kerberos>`.

