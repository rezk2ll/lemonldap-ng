Overlay configuration backend (removed in 3.0)
==============================================

The ``Overlay`` pseudo configuration backend read the configuration from a
real backend (``overlayRealtype``) and replaced top level parameters by the
content of the files found in ``overlayDirectory`` (file name == parameter
name), to keep secrets out of the configuration.

.. attention::

   ``Overlay`` has been **removed in LemonLDAP::NG 3.0**, with no
   compatibility layer: a ``type = Overlay`` configuration backend refuses to
   load and logs the migration path described here.

It is replaced by the :doc:`Filesystem placeholder <filesystemplaceholder>`,
which reads secrets in the files of a directory too, but at the *value*
level: each parameter holds a placeholder pointing to its file.

Migration
---------

In ``lemonldap-ng.ini``, the former ``overlayRealtype`` becomes the ``type``
(the options of that backend are unchanged) and ``overlayDirectory`` becomes
``filesystemPlaceholderDirectory``. This 2.x configuration:

.. code-block:: ini

   [configuration]
   type = Overlay
   overlayRealtype = File
   overlayDirectory = /var/lib/lemonldap-ng/secrets
   dirName = /var/lib/lemonldap-ng/conf

becomes:

.. code-block:: ini

   [configuration]
   type = File
   dirName = /var/lib/lemonldap-ng/conf
   configPlaceHolderModules = FILE=Lemonldap::NG::Common::Conf::Placeholder::Filesystem
   filesystemPlaceholderDirectory = /var/lib/lemonldap-ng/secrets

Then, in the configuration (Manager or configuration file), each parameter
that was overlayed takes the value ``%FILE:<parameter name>%``, for example
``%FILE:managerPassword%`` for the *LDAP password*. The files stay where they
are.

A parameter declared as a hash can not receive a placeholder as a whole: a
former JSON file, ``globalStorageOptions`` for example, must be split into one
file per secret value, see :doc:`filesystemplaceholder`.

``overlayWrite`` has **no equivalent**, and this is deliberate: the Manager
does not write secrets on disk any more, it only stores the placeholders.
