PAM
===

============== ===== ========
Authentication Users Password
============== ===== ========
✔
============== ===== ========

Presentation
------------

LL::NG can use `Pluggable authentication
module <https://en.wikipedia.org/wiki/Pluggable_authentication_module>`__
as a simple authentication backend.

Configuration
-------------

Install Authen::PAM
~~~~~~~~~~~~~~~~~~~

You have to install the corresponding Perl module.

For CentOS/RHEL:

.. code-block:: shell

   yum install perl-Authen-PAM

In Debian/Ubuntu, install the library through apt-get command

.. code-block:: shell

   apt-get install libauthen-pam-perl

Configuration of LemonLDAP::NG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose PAM for authentication.


.. tip::

    You can then choose any other module for users and
    password.

Then, go in ``PAM parameters``:

-  **Authentication level**: authentication level for PAM module
-  **PAM service**: the PAM service to use *(default: login)*
