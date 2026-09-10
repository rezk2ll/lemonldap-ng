Filesystem placeholder
======================

Presentation
------------

``Lemonldap::NG::Common::Conf::Placeholder::Filesystem`` is a
:doc:`configuration placeholder module<customconfigplaceholder>` that reads
secrets in local files. The LemonLDAP::NG configuration then holds only a
reference, for example ``%FILE:managerPassword%`` instead of the LDAP
password, and the value is read in the file ``managerPassword`` when the
configuration is loaded, in each LemonLDAP::NG process.

It suits the platforms that deliver secrets as files: Docker secrets
(``/run/secrets``), Kubernetes secrets mounted as a volume, systemd
credentials (``$CREDENTIALS_DIRECTORY``), or files deployed by a configuration
management tool. It replaces the former
:doc:`Overlay configuration backend<overlayconfbackend>`.

Resolution is *fail-closed*: if a file can not be read, the whole
configuration is rejected. Running handlers and portals keep the configuration
they already loaded.

Configuration
-------------

Edit the ``[configuration]`` section of ``lemonldap-ng.ini``:

.. code-block:: ini

   [configuration]

   configPlaceHolderModules = FILE=Lemonldap::NG::Common::Conf::Placeholder::Filesystem
   filesystemPlaceholderDirectory = /run/secrets

``FILE`` is only the prefix used in this document: choose the one you like,
it is the name used in the ``%PREFIX:...%`` placeholders.

``filesystemPlaceholderDirectory`` is the directory holding the secrets. When
it is not set, ``$CREDENTIALS_DIRECTORY`` is used: a systemd service
declaring ``LoadCredential=`` or ``SetCredential=`` needs no option.

Placeholder syntax
------------------

::

   %FILE:name%

``name`` is the path of the file, relative to the directory: ``password`` or
``ldap/password``. Each segment of the path must start with a letter, a digit
or ``_``, and may then only contain letters, digits, ``_``, ``.`` and ``-``:
``..``, absolute paths and hidden files are refused, so the configuration can
not designate a file outside of the directory.

The value is the content of the file, UTF-8 encoded, without its leading and
trailing spaces and newlines. A multi-line content, a private key for example,
is kept as is otherwise. An empty file is an error.

A parameter declared as a hash (``globalStorageOptions``, ``macros``, ...)
can not receive a placeholder as a whole: put one in each of its values, for
example ``%FILE:sessionsDbPassword%`` for the ``Password`` key of
``globalStorageOptions``.

Files are read again at each configuration load: a secret rotated in place is
used once the configuration is reloaded (see :doc:`configlocation`).

Examples
--------

Docker secrets are mounted in ``/run/secrets``:

.. code-block:: yaml

   # docker-compose.yml
   services:
     lemonldap-ng:
       secrets:
         - managerPassword
   secrets:
     managerPassword:
       file: ./secrets/managerPassword

With systemd, a credential loaded by the service is found in
``$CREDENTIALS_DIRECTORY``, so ``filesystemPlaceholderDirectory`` can be
omitted:

.. code-block:: ini

   # drop-in file of the service running LemonLDAP::NG
   [Service]
   LoadCredential=managerPassword:/etc/lemonldap-ng/secrets/managerPassword

Security
--------

* make the directory and its files readable only by the user running
  LemonLDAP::NG (mode ``0400`` or ``0440``);
* symbolic links found in the directory are followed: this is how Kubernetes
  rotates the secrets of a volume. The directory belongs to the administrator
  of the server, not to the one of the LemonLDAP::NG configuration;
* the Manager reads and writes the configuration in *raw* mode: it displays
  ``%FILE:managerPassword%``, never the secret;
* the content of a file never appears in error messages, which only give its
  path.
