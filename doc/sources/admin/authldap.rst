LDAP
====

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔     ✔
============== ===== ========

Presentation
------------

LL::NG can use an LDAP directory to:

-  authenticate user
-  get user attributes
-  get groups where user is registered
-  change password (with server side password policy management)

This works with every LDAP v2 or v3 server, including
:doc:`Active Directory<authad>`.

LL::NG is compatible with `LDAP password
policy <https://opends.dev.java.net/public/standards/draft-behera-ldap-password-policy.txt>`__:

-  LDAP server can check password strength, and LL::NG portal will
   display correct errors (password too short, password in history,
   etc.)
-  LDAP sever can block brute-force attacks, and LL::NG will display
   that account is locked
-  LDAP server can force password change on first connection, and LL::NG
   portal will display a password change form before opening SSO session

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose LDAP for authentication, users and/or password modules.


.. tip::

    For :doc:`Active Directory<authad>`, choose
    ``Active Directory`` instead of ``LDAP``.

Authentication level
~~~~~~~~~~~~~~~~~~~~

The authentication level given to users authenticated with this module.


.. attention::

    As LDAP is a login/password based module, the
    authentication level can be:

    -  increased (+1) if portal is protected by SSL (HTTPS)
    -  decreased (-1) if the portal autocompletion is allowed (see
       :doc:`portal customization<portalcustom>`)



Exported variables
~~~~~~~~~~~~~~~~~~

List of attributes to query to fill user session. See also
:doc:`exported variables configuration<exportedvars>`.

Connection
~~~~~~~~~~

-  **Server host**: LDAP server hostname or URI (by default: localhost).
   Accept some specificities:

   -  More than one server can be set here separated by spaces or
      commas. They will be tested in the specified order.
   -  To use StartTLS, set ``ldap+tls://server`` and to use LDAPS, set
      ``ldaps://server`` instead of server name.
   -  If you use StartTLS or LDAPS, you can set any of the
      `Net::LDAP <http://search.cpan.org/~gbarr/perl-ldap/lib/Net/LDAP.pod>`__
      start_tls() options in the URL, such as ``ldap+tls://server/verify=none``
      or ``ldaps://server/cafile=/etc/ssl/ca.pem&sslversion=tlsv1_2``. You can
      also use cafile and capath parameters.

-  **Server port**: TCP port used by LDAP server if different from the standard
   ports. Can also be specified in the server host URI.
-  **Verify LDAP server certificate**: It is highly recommended to verify the
   identity of the remote server. This setting is only enforced for LDAPS or
   TLS connections.
-  **Users search base**: Base of search in the LDAP directory.
-  **Account**: DN used to connect to LDAP server. By default, anonymous
   bind is used.
-  **Password**: password to used to connect to LDAP server. By default,
   anonymous bind is used.
-  **Connection timeout**: applies only when initiating the connection
-  **Operation timeout**: applies to all LDAP operations
-  **Version**: LDAP protocol version.
-  **Binary attributes**: regular expression matching binary attributes
   (see
   `Net::LDAP <http://search.cpan.org/~gbarr/perl-ldap/lib/Net/LDAP.pod>`__
   documentation).
-  **CA file path**: This allows you to override the default system-wide
   certificate authorities by giving a single file containing the CA used by the
   LDAP server.
-  **CA directory path**: This allows you to override the default system-wide
   certificate authorities by giving the path of a directory containing your
   trusted certificates.


.. attention::

    LL::NG needs anonymous access to LDAP Directory
    RootDSE in order to check LDAP connection.

Filters
~~~~~~~


.. tip::

    In LDAP filters, $user is replaced by user login, and $mail by
    user email.

-  **Default filter**: default LDAP filter for searches, should not be
   modified.
-  **Authentication filter**: Filter to find user from its login
   (default: ``(&(uid=$user)(objectClass=inetOrgPerson))``)
-  **Mail filter**: Filter to find user from its mail (default:
   ``(&(mail=$mail)(objectClass=inetOrgPerson))``)
-  **Alias dereference**: How to manage LDAP aliases. (default:
   ``find``)


.. tip::

    For Active Directory, the default authentication filter is:

    ::

       (&(sAMAccountName=$user)(objectClass=person))

    And the mail filter is:

    ::

       (&(mail=$mail)(objectClass=person))



.. _authldap-groups:

Groups
~~~~~~

-  **Search base**: DN of groups branch. If no value, disable group
   searching.
-  **Object class**: objectClass of the groups (default: groupOfNames).
   If you are using Active Directory you need to modify this value to ``group``. 
-  **Target attribute**: name of the attribute in the groups storing the
   link to the user (default: member).
-  **User source attribute**: name of the attribute in users entries
   used in the link (default: dn).
-  **Searched attributes**: name(s) of the attribute storing the name of
   the group, spaces separated (default: cn).
-  **Decode searched value**: with Active Directory, member DN value is
   sometimes bad decoded and groups are not found, activate this option
   to force value decoding.
-  **Recursive**: activate recursive group functionality (default: 0).
   If enabled, if the user group is a member of another group (group of
   groups), all parents groups will be stored as user's groups.
-  **Group source attribute**: name of the attribute in groups entries
   used in the link, for recursive group search (default: dn).


.. note::

    The groups that the user belongs to are available as ``$groups``
    and ``%hGroups``, as documented :ref:`here<macros_and_groups>`


.. attention::

    If your LDAP countains over a thousand groups, you
    should avoid using group processing, check out
    :ref:`the performance page<performances-ldap-performances>` for
    alternatives 

Password
~~~~~~~~

-  **Password policy control**: enable to use LDAP password policy. This
   requires at least Net::LDAP 0.38. (see ppolicy workflow below)
-  **Password modify extended operation**: enable to use the LDAP
   extended operation ``password modify`` instead of standard modify
   operation.
-  **Change as user**: enable to perform password modification with
   credentials of connected user. This requires to request user old
   password (see :doc:`portal customization<portalcustom>`).
-  **LDAP password encoding**: can allow one to manage old LDAP servers
   using specific encoding for passwords (default: utf-8).
-  **Use reset attribute**: enable to use the password reset attribute.
   This attribute is set by LemonLDAP::NG when
   :doc:`password was reset by mail<resetpassword>` and the user choose
   to generate the password (default: enabled).
-  **Reset attribute**: name of password reset attribute (default:
   pwdReset).
-  **Reset value**: value to set in reset attribute to activate password
   reset (default: TRUE).
-  **Allow a user to reset his expired password**: if activated, the
   user will be prompted to change password if his password is expired
   (default: disabled)
-  **Search for user before password change**: this option forces the password
   change module to search for the user again, refreshing its DN. This feature
   is only useful in rare cases when you use LDAP as the password module, but
   not as the UserDB module. (default: enabled)
-  **IBM Tivoli DS support**: enable this option if you use ITDS. LL::NG
   will then scan error message to return a more precise error to the
   user.

**Password expiration warning workflow** |image0| **Password expiration
workflow** |image1|

.. |image0| image:: /documentation/lemonldap-ng-password-expiration-warning.png
.. |image1| image:: /documentation/lemonldap-ng-password-expired.png

