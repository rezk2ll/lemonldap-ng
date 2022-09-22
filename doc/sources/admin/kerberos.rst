Kerberos
========

Presentation
------------

This documentation will explain how to use Active Directory as Kerberos
server, and provide transparent authentication for one or multiple AD
domains.

You can use Kerberos in LL::NG with the following authentication
modules:

-  :doc:`Kerberos<authkerberos>` (recommended): use Perl GSSAPI module,
   compatible with Apache and Nginx
-  :doc:`Apache<authapache>`: use mod_auth_kerb or mod_auth_gssapi in
   Apache

Prerequisites
-------------

Example values
~~~~~~~~~~~~~~

We will use the following values in our examples

-  **EXAMPLE.COM**: First AD domain
-  **ACME.COM**: Second AD domain
-  **auth.example.com**: DNS of the LL::NG portal
-  **KERB_AUTH**: AD account to generate the keytab for LL::NG server

Server time
~~~~~~~~~~~

It is mandatory that LL::NG servers and AD servers have the same time.
It is recommended to use NTP to do this.

DNS
~~~

In our experience, we have observed the following limitations when using Kerberos for web applications in an Active Directory environment

* ``auth.example.com`` must be registered in the DNS server as a ``A`` record. ``CNAME`` usually do not work
* The reverse DNS (``PTR``) for ``auth.example.com``'s IP address MUST point back to ``auth.example.com``

.. tip::

    If you have a SSO cluster, you must setup a Virtual IP in
    cluster and register this IP in DNS.

.. tip::

   If you cannot configure the PTR record to point to the portal's hostname, it
   may help to run the following command. Assuming that ``proxy.example.com`` is
   the PTR record of the portal's IP address ::

      setspn -s HTTP/proxy.example.com keytab-account

SSL
~~~

SSL is not mandatory, but it is strongly recommended. Your portal URL
should be https://auth.example.com.

Web browser configuration
~~~~~~~~~~~~~~~~~~~~~~~~~

Firefox
^^^^^^^

Type ``about:config`` in a tab and search for ``trusted``. Then edit the
property ``network.negotiate-auth.trusted-uris`` and set value
``example.com``.

Internet Explorer
^^^^^^^^^^^^^^^^^

Add ``https://auth.example.com`` as trusted site.

Check into security parameters that Kerberos authentication is allowed.

Single AD domain
----------------

Client Kerberos configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On LL::NG server, edit ``/etc/krb5.conf``:

.. code-block:: ini

   [libdefaults]
    default_realm = EXAMPLE.COM
    dns_lookup_kdc = false
    dns_lookup_realm = no
    ticket_lifetime = 24h
    forwardable = yes
    renewable = true

   [realms]
    EXAMPLE.COM = {
     kdc = ad.example.com
     admin_server = ad.example.com
    }

   [domain_realm]
    .example.com = EXAMPLE.COM
    example.com = EXAMPLE.COM

You can check that Kerberos is working by trying to get a ticket for a
user of the domain (for example coudot):

::

   kinit coudot@EXAMPLE.COM

You should be prompted to enter password. Then list the tickets:

::

   klist -e

You should see a krbtgt ticket:

::

   Valid starting     Expires            Service principal
   06/04/15 15:43:24  06/05/15 01:43:29  krbtgt/EXAMPLE.COM@EXAMPLE.COM
           renew until 06/05/15 15:43:24, Etype (skey, tkt): aes256-cts-hmac-sha1-96, aes256-cts-hmac-sha1-96

You can then close the Kerberos session:

::

   kdestroy

Obtain keytab file
~~~~~~~~~~~~~~~~~~

You have to run this command on Active Directory:

::

   ktpass -princ HTTP/auth.example.com@EXAMPLE.COM -mapuser KERB_AUTH@EXAMPLE.COM -crypto All -ptype KRB5_NT_PRINCIPAL -mapOp set -pass <PASSWORD> -out c:\auth.keytab


.. attention::

    The values passed in -crypto and -ptype depend on the
    Active Directory version and the windows version of the workstations.
    You can for example use RC4-HMAC-NT as crypto protocol if DES is not
    supported by workstations (this the case by default for Window 8 for
    example).

The file ``auth.keytab`` should then be copied (with a secure media) to
the Linux server (for example in ``/etc/lemonldap-ng``).

Change rights on keytab file:

::

   chown apache /etc/lemonldap-ng/auth.keytab
   chmod 600 /etc/lemonldap-ng/auth.keytab

You can check the validity of the keytab file by trying to request a
service ticket, and compare the result with the keytab content.

Open a Kerberos session (like done in the previous step):

::

   kinit coudot@example.com

Request a service ticket:

::

   kvno HTTP/auth.example.com@EXAMPLE.COM

The result of the command should be:

::

   HTTP/auth.example.com@EXAMPLE.COM: kvno = 3

Read the service ticket:

::

   klist -e

You should see this kind of ticket:

::

   06/04/15 16:28:49  06/05/15 02:28:11  HTTP/auth.example.com@EXAMPLE.COM
           renew until 06/05/15 16:28:07, Etype (skey, tkt): arcfour-hmac, arcfour-hmac

You can close the Kerberos session:

::

   kdestroy

Now you can compare the above result with the same request done through
the keytab file:

::

   klist -e -k -t /etc/lemonldap-ng/auth.keytab

The result of the command should be:

::

   Keytab name: FILE:/etc/lemonldap-ng/auth.keytab
   KVNO Timestamp         Principal
   ---- ----------------- --------------------------------------------------------
      3 01/01/70 01:00:00 HTTP/auth.example.com@EXAMPLE.COM (arcfour-hmac)

The important things to check are:

-  KVNO must be the same
-  Principal names must be the same
-  Encryption types must be the same

Multiple AD domains
-------------------

.. _client-kerberos-configuration-1:

Client Kerberos configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The two domains must be defined in ``/etc/krb5.conf``:

.. code-block:: ini

   [libdefaults]
    default_realm = EXAMPLE.COM
    dns_lookup_kdc = false
    dns_lookup_realm = no
    ticket_lifetime = 24h
    forwardable = yes
    renewable = true

   [realms]
    EXAMPLE.COM = {
     kdc = ad.example.com
     admin_server = ad.example.com
     default_domain = EXAMPLE.COM
    }
    ACME.COM = {
     kdc = ad.acme.com
     admin_server = ad.acme.com
     }

   [domain_realm]
    .example.com = EXAMPLE.COM
    example.com = EXAMPLE.COM
    .acme.com = ACME.COM
    acme.com = ACME.COM

You should then be able to open a Kerberos session on each domain:

::

   kinit coudot@EXAMPLE.COM
   klist -e
   kdestroy

::

   kinit coudot@ACME.COM
   klist -e
   kdestroy

.. _obtain-keytab-file-1:

Obtain keytab file
~~~~~~~~~~~~~~~~~~

You need to obtain a keytab for each node on each domain. This means the
ktpass commands should be run on both AD.

Then you will have 2 keytab files for each node, for example:

-  node1-example.keytab
-  node1-acme.keytab

You need to concatenate the keytab files, thanks to ``ktutil`` command:

::

   ktutil
   ktutil: read_kt node1-example.keytab
   ktutil: read_kt node1-acme.keytab
   ktutil: write_kt /etc/lemonldap-ng/auth.keytab
   ktutil: quit

You can then remove the original keytab files and protect the final
keytab file:

::

   chown apache /etc/lemonldap-ng/auth.keytab
   chmod 600 /etc/lemonldap-ng/auth.keytab

Other resources
---------------

You can check these documentations to get more information:

-  http://modauthkerb.sourceforge.net/configure.html
-  http://www.grolmsnet.de/kerbtut/
