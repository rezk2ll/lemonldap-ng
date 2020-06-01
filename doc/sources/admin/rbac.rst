RBAC model
==========

Presentation
------------

`RBAC <http://en.wikipedia.org/wiki/Role-based_access_control>`__ stands
for Role Based Access Control. It means that you manage authorizations
to access applications by checking the role(s) of the user, and provide
this role to the application.

As the definition of access rules is free in LemonLDAP::NG, you can
implement an RBAC model if you need.

Configuration
-------------

Roles as simple values of a user attribute
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Imagine you've set your directory schema to store roles as values of an
attribute of the user, for example "description". This is simple because
you can send the role to the application by creating a HTTP header (for
example Auth-Role) with the concatenated values (';' is the
concatenation string):

::

   Auth-Roles => $description

If the user has these values inside its entry:

::

   description: user
   description: admin

Then you got this value inside the Auth-Roles header:

::

   user; admin

Roles as entries in the directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now imagine the following DIT:

-  dc=example,dc=com

   -  ou=users

      -  uid=coudot

   -  ou=roles

      -  ou=aaa

         -  cn=admin
         -  cn=user

      -  ou=bbb

         -  cn=admin
         -  cn=user

Roles are entries, below branches representing applications. We can use
the standard LDAP objectClass ``organizationalRole`` to maintain roles,
for example:

.. code::

   dn: cn=admin,ou=aaa,ou=roles,dc=example,dc=com
   objectClass: organizationalRole
   objectClass: top
   cn: admin
   ou: aaa
   roleOccupant: uid=coudot,ou=users,dc=example,dc=com

A user is attached to a role if its DN is in ``roleOccupant`` attribute.
We add the attribute ``ou`` to allow LL::NG to know which application is
concerned by this role.

So imagine the user coudot is "user" on application "BBB" and "admin" on
application "AAA".

Gather roles in session
^^^^^^^^^^^^^^^^^^^^^^^

Use the :ref:`LDAP group<authldap-groups>` configuration to store roles
as groups in the user session:

-  Base: ou=roles,dc=example,dc=com
-  Object class: organizationalRole
-  Target attribute: roleOccupant
-  Searched attributes: cn ou

Restrict access to application
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We configure LL::NG to authorize people on an application only if they
have a role on it. For this, we use the ``$hGroups`` variable.

-  For application AAA:

::

   default => groupMatch($hGroups, 'ou', 'aaa')

-  For application BBB:

::

   default => groupMatch($hGroups, 'ou', 'bbb')

Send role to application
^^^^^^^^^^^^^^^^^^^^^^^^

It is done by creating the correct HTTP header:

-  For application AAA:

::

   Auth-Roles => ((grep{/aaa/} split(';',$groups))[0] =~ /([a-zA-Z]+?)/)[0]

-  For application BBB:

::

   Auth-Roles => ((grep{/bbb/} split(';',$groups))[0] =~ /([a-zA-Z]+?)/)[0]

