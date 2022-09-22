Store user password in session
==============================

Presentation
------------

Password is not a common attribute. Indeed, in most of the cases, it is
not stored in clear text in the backend (LDAP or database).

So, to keep user password in session, you cannot just export the
password variable in session. To bypass this, LL::NG can remember what
password was given by user on authentication phase.


.. attention::



    -  As this may be a security hole, password store in session is not
       activated by default
    -  This mechanism can only work with authentication backends using a
       login/password form (:doc:`LDAP<authldap>`, :doc:`DBI<authdbi>`, ...)



Configuration
-------------

Go in Manager, ``General Parameters`` » ``Sessions`` »
``Store user password in session data`` and set to ``On``.

Usage
-----

User password is now available in ``$_password`` variable. For example,
to send it in an header:

::

   Auth-Password => $_password


.. tip::

    For security reasons, the password is not shown in sessions
    explorer.
