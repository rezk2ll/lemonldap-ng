Databases
=========

============== ===== ========
Authentication Users Password
============== ===== ========
✔
============== ===== ========

Presentation
------------

LLNG can use GPG to authenticate users. It is not useful for day-to-day
authentication but can be used for example if user has lost his
password. The login form will ask user to sign a challenge and post
result.

Configuration of LemonLDAP::NG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose GPG for authentication, users and/or password modules. Then
you just have to set GPG database. For example
``/usr/share/keyrings/debian-keyring.gpg``


.. tip::

    You can then choose any other module for users and
    password.

Then, go in ``GPG parameters``:

-  **Authentication level**: authentication level for this module
-  **GPG database**: database to store users GPG public key
