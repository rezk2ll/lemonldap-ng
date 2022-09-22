MongoDB configuration backend (deprecated)
==========================================

`MongoDB <https://www.mongodb.org/>`__ is a NoSQL database that can be
used both for storing configuration and
:doc:`sessions<mongodbsessionbackend>`. You need to install Perl MongoDB
module to be able to use this backend.

.. tip::

   `MongoDB has officially deprecated the Perl driver <https://www.mongodb.com/blog/post/the-mongodb-perl-driver-is-being-deprecated>`__, so we advice to choose another backend

For Debian, you can install mongodb module with:

::

   apt install libmongodb-perl

For CentOS:

::

   yum install perl-MongoDB

See :doc:`how to change configuration backend<changeconfbackend>` to
change your configuration database.

Configuration
-------------

To use a MongoDB backend, configure your ``lemonldap-ng.ini`` file
(section configuration) :

-  Choose MongoDB as type
-  Set dbName and collectionName parameters if different than default
   values (llConfDB and configuration)
-  Set host and if needed db_name username, password and ssl fields as
   follow.

Example :

.. code-block:: ini

   [configuration]
   type = MongoDB
   dbName = llConfDB
   collectionName = configuration
   ; using a single server
   host = 127.0.0.1:27017
   ; using a replicaSet
   ; host = mongodb://mongo1.example.com,mongo2.example.com/?replicaSet=myset
   ssl = 1
   ; authentication parameters
   db_name = admin
   user = lluser
   password = llpassword

===================================================================================================================== ================================ ==========
Optional parameters (see `MongoDB::MongoClient <http://search.cpan.org/perldoc?MongoDB%3A%3AMongoClient>`__ man page)
===================================================================================================================== ================================ ==========
Name                                                                                                                  Comment                          Example
db_name                                                                                                               Admin database (default: admin)  admin
auth_mechanism                                                                                                        Authentication mechanism         PLAIN
auth_mechanism_properties
connect_timeout                                                                                                       Connection timeout               10000
ssl                                                                                                                   Boolean or hash ref (default: 0) 1
username                                                                                                              Username to use to connect       lluser
password                                                                                                              Password                         llpassword
===================================================================================================================== ================================ ==========

Mini MongoDB howto
==================

Just some commands needed to create collection and user:

::

   $ mongo
   connecting to: test
   > use configuration
   switched to db configuration
   > db.createCollection("configuration")
   ...
   > db.createUser({user:"lluser",pwd:"llpassword",roles:["readWrite"]})
   ...
   > exit
   bye
   $

