Apache
======

============== ===== ========
Authentication Users Password
============== ===== ========
✔
============== ===== ========

Presentation
------------

LL::NG can delegate authentication to Apache, so it is possible to use
any `Apache authentication
module <http://httpd.apache.org/docs/current/howto/auth.html>`__, for
example Kerberos, Radius, OTP, etc.


.. attention::

    To authenticate users by using Kerberos, you can now use
    the new :doc:`Kerberos authentication module<authkerberos>` which allow
    one to chain Kerberos in a :doc:`combination<authcombination>`\


.. tip::

    Apache authentication module will set the ``REMOTE_USER``
    environment variable, which will be used by LL::NG to get authenticated
    user.

Configuration
-------------

LL::NG
~~~~~~

In General Parameters > Authentication modules, choose ``Apache`` as
authentication backend.

You may want to failback to another authentication backend in case of
the Apache authentication fails. Use then the
:doc:`Multiple authentication module<authmulti>`, for example:

::

   Apache;LDAP


.. tip::

    In this case, the Apache authentication module should not
    require a valid user and not be authoritative, else Apache server will
    return an error and not let LL::NG Portal manage the failback
    authentication.

.. _apache-1:

Apache
~~~~~~

The Apache configuration depends on the module you choose, you need to
look at the module documentation, for example:

-  `Kerberos <http://modauthkerb.sourceforge.net/>`__
-  `NTLM <http://search.cpan.org/~speeves/Apache2-AuthenNTLM-0.02/AuthenNTLM.pm>`__
-  `Radius <http://freeradius.org/mod_auth_radius/>`__
-  ...

Tips
----

Kerberos
~~~~~~~~

The Kerberos configuration is quite complex. You can find some
configuration tips :doc:`on this page<kerberos>`.


.. tip::

    Prefer new :doc:`Kerberos<authkerberos>` module.

Compatibility with Identity Provider modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When using IDP modules (like CAS or SAML), the activation of Apache
authentication can alter the operation. This is because the client often
need to request directly the IDP, and the Apache authentication will
block the request.

In this case, you can add in the Apache authentication module:

.. code-block:: apache

         Satisfy any
         Order allow,deny
         allow from APPLICATIONS_IP

This will bypass the authentication module for request from
APPLICATIONS_IP.
