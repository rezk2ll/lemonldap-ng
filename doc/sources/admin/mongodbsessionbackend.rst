MongoDB session backend (deprecated)
====================================

`Apache::Session::MongoDB <https://metacpan.org/pod/Apache::Session::MongoDB>`__
is a faster shareable session backend.

.. tip::

   `MongoDB has officially deprecated the Perl driver <https://www.mongodb.com/blog/post/the-mongodb-perl-driver-is-being-deprecated>`__, so we advice to choose another backend


.. attention::

    Use an up-to-date version of Apache::Session::MongoDB, at least 1.8.1.

Setup
-----

Install and launch a `MongoDB server <https://www.mongodb.org/>`__.
Install
`Apache::Session::MongoDB <http://search.cpan.org/perldoc?Apache::Session::MongoDB>`__
Perl module (version ⩾ 0.15 required). You also need a recent version of
`Perl MongoDB
client <http://search.cpan.org/~mongodb/MongoDB-v1.2.2/>`__ (version ⩾
1.00 required).

For Debian, you can install mongodb module and Apache::Session module with:

::

   apt install libmongodb-perl
   cpan Apache::Session::MongoDB

For CentOS:

::

   yum install perl-MongoDB
   cpan Apache::Session::MongoDB


In the manager: set
`Apache::Session::MongoDB <http://search.cpan.org/perldoc?Apache::Session::MongoDB>`__
in ``General parameters`` » ``Sessions`` » ``Session storage`` »
``Apache::Session module`` and add the following parameters (case
sensitive):

============================= ============================================================================================ ===============
Optional parameters
------------------------------------------------------------------------------------------------------------------------------------------
Name                          Comment                                                                                      Example
============================= ============================================================================================ ===============
**host**                      `MongoDB server URI <https://metacpan.org/pod/MongoDB::MongoClient#CONNECTION-STRING-URI>`__ 127.0.0.1:27017
**db_name**                   Session database (default: sessions)                                                         llconfdb
**collection**                Collection (default: sessions)                                                               sessions
**auth_mechanism**            Authentication mechanism                                                                     PLAIN
**auth_mechanism_properties**
**connect_timeout**           Connection timeout                                                                           10000
**ssl**                       Boolean or hash ref (default: 0)                                                             1
**username**                  Username to use to connect                                                                   lluser
**password**                  Password                                                                                     llpassword
============================= ============================================================================================ ===============

Advanced connection parameters (Replica Sets, timeouts...) may be
specified in the ``host`` parameter. `Refer to the perl MongoDB
documentation for
details <https://metacpan.org/pod/MongoDB::MongoClient#CONNECTION-STRING-URI>`__

Security
--------

Restrict network access to the MongoDB server. For remote servers, you
can use :doc:`SOAP session backend<soapsessionbackend>` in cunjunction
to increase security for remote server that access through an unsecure
network
