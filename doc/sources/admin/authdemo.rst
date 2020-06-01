Demonstration
=============

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔     ✔
============== ===== ========

Presentation
------------

This mode allow one to test LemonLDAP::NG without any third-party
software.


.. danger::

    This mode must not be used for other purpose than test and
    demonstration!

Demonstration backend has hard coded user accounts:

====== ======== ================== =============
Login  Password Mail               Role
====== ======== ================== =============
rtyler rtyler   rtyler@badwolf.org user
msmith msmith   msmith@badwolf.org user
dwho   dwho     dwho@badwolf.org   administrator
====== ======== ================== =============


.. note::

    As you may have guessed, these accounts are famous characters from
    the TV show `Doctor
    Who <http://en.wikipedia.org/wiki/Doctor_Who>`__.

The AuthDemo and UserDBDemo will allow you to log in and get the
standard attributes (uid, cn and mail). The PasswordDBDemo will allow
you to change the password with some basic checks, but as the data are
hard coded, the password will never be really changed.

Configuration
-------------

Select Demonstration for authentication, user and password backend.

You can also modify list of exported variables. Only uid, cn and mail
attributes are available. See also
:doc:`exported variables configuration<exportedvars>`.
