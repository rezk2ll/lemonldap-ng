Combination of authentication schemes
=====================================

============== ===== ==================
Authentication Users Password
============== ===== ==================
✔              ✔     ✔ (since *2.0.10*)
============== ===== ==================

Presentation
------------

This backend allows one to chain authentication method, for example to
failback to LDAP authentication if Remote authentication failed…

Configuration
-------------

You have to use ``Combination`` as authentication module (users module
must be set to "Same"). Then go in ``Combination parameters`` to :

-  declare the modules that will be used
-  set the rule chain

Modules declaration
~~~~~~~~~~~~~~~~~~~

Each module that will be used in combination rule must be declared. You
must set:

-  the name used in the rule (a uniq string)
-  the type (LDAP, DBI,...)
-  the scope:

   -  authentication and user DB
   -  authentication only
   -  user DB only

-  overloaded parameters: you can redefine any LLNG string parameters.
   For example, if you use 2 different LDAP, the first can use normal
   configuration and for the second, overwritten parameter can redefine
   ldapServer or any existing parameter.


.. note::

    To overload parameters, you must select a module, add a parameter
    and set its value.  For example:

==== ==== ============ ===========================
Name Type Scope        Parameters
==== ==== ============ ===========================
DB1  DBI  Auth only
DB2  DBI  User DB only dbiAuthChain => "mysql:..."
==== ==== ============ ===========================

Usually, you can't declare two modules of the same type if they don't
have the same parameters. For example, usually you can't declare a MySQL
DBI and a PostgreSQL DBI, because there is no extra field for PostgreSQL
parameters. Now with Combination, you can declare some overloaded
parameters.

For example, if DBI is configured to use PostgreSQL but DB2 is a MySQL
DB, you can override the "dbiChain" parameter.

The over parameter is a HASH ref where keys are attributes names and values are the overriden value.
To override a complex key like ldapExportedVars, you must use a JSON value, as the over parameter
expect string values:

.. code-block:: javascript

   {"cn": "cn", "uid": "sAMAccounName", "mail": "mail"}


.. attention::

    If your JSON is corrupted, LLNG will use it as string
    and just report a warning in logs.

Rule chain
~~~~~~~~~~

Combination allows:

-  to chain schemes (example: ``[LDAP] and [DBI]``)
-  to test different schemes (example: ``[LDAP] or [DBI]``)
-  to mix schemes (example: ``[Kerberos,LDAP] or [LDAP,LDAP]``)
-  to choose authentication scheme depending on some request values

Each scheme must be enclose in ``[]``. A comma separates auth and user
DB modules. If only one value is set, the same is used for both.

Boolean expression
^^^^^^^^^^^^^^^^^^

Remember that schemes in rules are the names declared above.

======================================= =============================================================================
Example                                 Explanation
======================================= =============================================================================
``[myLDAP] or [myDBI]``                 If myLDAP fails, use myDBI
``[mySSL, myLDAP] or [myLDAP, myLDAP]`` Try mySSL for auth and myLDAP for userDB. If fails, switch to myLDAP for both
``[myLDAP] or [myDBI1] or [myDBI2]``    Try myLDAP, then if it fails, myDBI1, then if it fails myDBI2
``[mySSL and myLDAP, myLDAP ]``         Use mySSL and myLDAP to authentify, myLDAP to get user
======================================= =============================================================================


.. attention::

    Note that "or" can't be used inside a scheme. If you
    think to "[mySSL or myLDAP, myLDAP]", you must write
    ``[mySSL, myLDAP] or [myLDAP, myLDAP]``

================================================== =========================================================
Example                                            Explanation
================================================== =========================================================
``[myDBI1] and [myDBI2] or [myLDAP]``              Try myDBI1 and myDBI2, if it fails, try myLDAP
``[myDBI1] and [myDBI2] or [myLDAP] and [myDBI2]`` Try myDBI1 and myDBI2, if it fails, try myLDAP and myDBI2
================================================== =========================================================


.. attention::

    You can't use brackets in a boolean expression and "and"
    has precedence on "or".

    If you think to "( [myLDAP] or [myDBI1] ) and [myDBI2]", you must write
    ``[myLDAP] and [myDBI2] or [myDBI1] and [myDBI2]``

Tests
^^^^^

Test can use only the ``$env`` variable. It contains the FastCGI
environment variables.

======================================================================================================================= ==============================================================================
Example                                                                                                                 Explanation
======================================================================================================================= ==============================================================================
``if($env->{REMOTE_ADDR} =~ /^10\./) then [myLDAP] else [mySSL, myLDAP]``                                               If user doesn't come from 10.0.0.0/8 network, use SSL as authentication module
``if($env->{REMOTE_ADDR} =~ /^10\./) then [myLDAP] else if($env->{REMOTE_ADDR} =~ /^192/) then [myDBI1] else [myDBI2]`` Chain tests
======================================================================================================================= ==============================================================================


.. attention::

    Note that brackets can't be used except to enclose test.

    If you wants to write ``if(...) then if...``, you must write
    ``if(not ...) then ... else if(...)...``

Let's be crazy
^^^^^^^^^^^^^^

The following rule is valid:

``if($env->{REMOTE_ADDR} =~ /^192\./) then [mySSL, myLDAP] or [myLDAP] else [myLDAP and myDBI, myLDAP]``

Combine second factor
~~~~~~~~~~~~~~~~~~~~~

Imagine you want to authenticate users either by SSL or LDAP+U2F, you
can't directly write this rule: this is done in 2 steps:

-  use this combination rule: ``[SSL,LDAP] or [LDAP]``
-  enable U2F with this rule: ``$_auth eq "LDAP"`` or
   ``$authenticationLevel < 4`` *(and adapt U2F authentication level)*

Now if you want to authenticate users either by LDAP or LDAP+U2F *(to
have 2 different authentication level)*, 2 possibilities:

-  configure 2 portals and overwrite U2F activation in the second
-  Modify login template to propose the choice *(add a "submit" button
   that points to the second portal)*

Display multiple forms
~~~~~~~~~~~~~~~~~~~~~~

Combination module returns the form corresponding to the first
authentication scheme available for the current request. You can force
it to display the forms chosen using ``combinationForms`` in
lemonldap-ng.ini. Example:

::

   [portal]
   combinationForms = standardform, openidform


Password management
-------------------

.. versionadded:: 2.0.10

Not all configurations of the Combination module allow password management. 

If your combination looks like this ::

   [Kerberos, LDAP] or [LDAP]

Then you can simply set ``LDAP`` as the password module, and password changes
and reset will work as expected.

If your combination looks like this ::

   [LDAP1] or [LDAP2]

Then you can configure the ``Combination`` password module to automatically
send password changes to the LDAP server which was used during authentication.
This module also enables password reset.

.. note::

   You can set the ``_cmbPasswordDB`` session variable to manually select which
   backend will be called when changing the password. This is useful when using
   SASL delegation

Limitations
~~~~~~~~~~~

* When using password reset with a combination of 2 or more LDAP servers, you
  need to make sure that there is no duplication of email addresses between all
  your servers. If an email exists in more than one server, the password will
  be reset on the first LDAP server that contains this email address
* Combinations using the ``and`` boolean expression will not cause passwords to
  be changed in both backends for now
* Forcing the user to reset their password on next login is not currently
  supported by the combination module

Known problems
--------------

Federation protocols
~~~~~~~~~~~~~~~~~~~~

:doc:`SAML<authsaml>`, :doc:`OpenID-Connect<authopenidconnect>`,
:doc:`CAS<authcas>` or :doc:`old OpenID<authopenid>` can't be chained
with a "and" for authentication part. So "[SAML] and [LDAP]" isn't
valid. This is because their authentication kinematic don't use the same
steps.

================================= =================================== ========================================================================
Bad expression                    Solution                            Explanation
================================= =================================== ========================================================================
``[SAML] and [LDAP]``             ``[SAML, SAML and LDAP]``           Authentication is done by SAML only but user must match an LDAP entry
``[SAML] and [LDAP] or [LDAP]``   ``[SAML, SAML and LDAP] or [LDAP]`` Authentication is done by SAML or LDAP but user must match an LDAP entry
================================= =================================== ========================================================================

Auth::Apache authentication
~~~~~~~~~~~~~~~~~~~~~~~~~~~

When using this module, LL::NG portal will be called only if Apache does
not return "401 Authentication required", but this is not the Apache
behaviour: if the auth module fails, Apache returns 401. So it can be
used only with a "and" boolean expression.


.. tip::

    The new :doc:`Kerberos authentication module<authkerberos>`
    solve this for Kerberos: you just have to use it instead of Apache and
    enable authentication by Ajax in Kerberos parameters.

Example: ``[ Apache and LDAP, LDAP ]``

To bypass this, follow the documentation of
:doc:`AuthApache module<authapache>`

SSL authentication
~~~~~~~~~~~~~~~~~~

To chain SSL, you have to set "SSLRequire optional" in Apache
configuration, else users will be authenticated by SSL only.

Migrating from Multi
--------------------

Old :doc:`Multiple backends stack<authmulti>`
implemented only \`if\` and \`or\` keywords. Examples:

================================================================ =====================================================
Multi expressions                                                Combination
================================================================ =====================================================
``LDAP;DBI``                                                     ``[myLDAP] or [myDBI]``
``DBI $ENV{REMOTE_ADDR}=~/^192/;LDAP $ENV{REMOTE_ADDR}!~/^192/`` ``if $env->{REMOTE_ADDR} then [myDBI] else [myLDAP]``
================================================================ =====================================================
