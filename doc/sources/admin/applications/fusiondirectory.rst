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
https://fusiondirectory-user-manual.readthedocs.io/en/latest/fusiondirectory/configuration/configuration.html

LL::NG
~~~~~~

Just set the ``Auth-User`` header with the attribute that carries the
user login, for example ``$uid``.

.. |image0| image:: /applications/fusiondirectory-logo.jpg
   :class: align-center

