FusionDirectory
===============

|image0|

Presentation
------------

`FusionDirectory <https://www.fusiondirectory.org/>`__ provides a
solution to daily management of data stored in an LDAP directory.

Configuration
-------------

.. _fusiondirectory-1:

FusionDirectory
~~~~~~~~~~~~~~~

Go in Configuration and in Login and Session panel. Set:

-  **HTTP Header authentication**: Activate
-  **Header name**: Auth-User

See also
https://documentation.fusiondirectory.org/en/documentation/admin_installation/core_configuration#login-and-session

LL::NG
~~~~~~

Just set the ``Auth-User`` header with the attribute that carries the
user login, for example ``$uid``.

.. |image0| image:: /applications/fusiondirectory-logo.jpg
   :class: align-center

