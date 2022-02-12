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

-  **keytab file** (required): the Kerberos keytab file
-  **Use Ajax request**: set to "enabled" if you want to use an Ajax
   request instead of a direct Kerberos attempt. **This is required if
   you want to chain Kerberos in a** :doc:`combination<authcombination>`
-  **Kerberos authentication level**: default to 3
-  **Use Web Server Kerberos module**: set to "enabled" to use the Web
   Server module (for example Apache mod_auth_kerb) instead of Perl
   Kerberos code to validate Kerberos ticket
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
    -  As Kerberos ticket is passed inside Authorization header, you may
       need to set CGIPassAuth on in Apache (with old Apache, use
       ``RewriteCond %{HTTP:Authorization}`` followed by
       ``RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]``)



Kerberos configuration
~~~~~~~~~~~~~~~~~~~~~~

The Kerberos configuration is quite complex. You can find some
configuration tips :doc:`on this page<kerberos>`.

Web Server Kerberos module
~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to let Web Server Kerberos module validates the Kerberos
ticket, set the according option to "enabled" and configure the portal
virtual host to launch the module if "kerberos" GET parameter is in the
request.

Example with Apache and mod_auth_kerb:

.. code-block:: apache

     <If "%{QUERY_STRING} =~ /kerberos=/">
       <IfModule auth_kerb_module>
         AuthType Kerberos
         KrbMethodNegotiate On
         KrbMethodK5Passwd Off
         KrbAuthRealms EXAMPLE.COM
         Krb5KeyTab /etc/lemonldap-ng/auth.keytab
         KrbVerifyKDC On
         KrbServiceName Any
         require valid-user
       </IfModule>
     </If>

