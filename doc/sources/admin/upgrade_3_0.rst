Upgrade from 2.X to 3.0
=======================


.. attention::

    3.0 is a major release, lot of things have been changed.
    You must read this document before upgrade.

Encoding changes
----------------

LemonLDAP::NG 3 contains many under-the-hood changes related to text encoding.
In the long run, these changes will improve the way text is handled in macros,
rules, etc. But thoses changes require some manual modifications when migrating
from LemonLDAP::NG 2.X

In particular, all data that LemonLDAP::NG stores in external systems requires
reencoding, because LemonLDAP::NG 2.0 did not encode strings correctly before
storing them.

PostgreSQL
~~~~~~~~~~

You have to rename `xml` column into `content` first.

And then run the following SQL command on your database ::

    # If you use notifications

    alter table notifications alter column content type text USING convert_from(convert_to(convert_from(content, 'utf8'), 'iso8859-1'), 'utf-8');

    # Convert your session storage
    update sessions set a_session=convert_from(convert_to(a_session::text, 'iso8859-1'), 'utf-8');
    update sessions set a_session=convert_from(convert_to(a_session::text, 'iso8859-1'), 'utf-8');
    update sessions set a_session=convert_from(convert_to(a_session::text, 'iso8859-1'), 'utf-8');

    # Convert your configuration storage
    update lmconfig set data=convert_from(convert_to(data, 'iso8859-1'), 'utf-8');


MySQL
~~~~~

You have to rename `xml` column into `content` first.

And then run the following SQL command on your database ::

    alter table notifications modify content text NOT NULL;

Then in a shell, reencode existing data and reimport it ::

    mysqldump MYDB > database.sql
    iconv -f utf-8 -t iso8859-1 database.sql > database.fixed.sql
    mysql MYDB < database.utf8.sql


Other backends
~~~~~~~~~~~~~~

If you are using another backend, you have several options:

* Use your backend's native export/import tools, and make sure the text data
  that appears in the backup is valid UTF-8 before reimporting it.

::

    iconv -f utf-8 -t iso8859-1 backup.bad.encoding > backup.good.encoding

* Use LemonLDAP::NG's native export tools: ``lemonldap-ng-sessions`` or
  ``lemonldap-ng-cli`` to backup sessions and configuration, fix the encoding
  using ``iconv``, and reimport

"Double Cookies" no longer supported
------------------------------------

Previous versions of LemonLDAP::NG could be configured to set an insecure
SSO cookie in addition to the main SSO cookie.

This is no longer supported, which means if you configure the main SSO cookie
to have the *Secure* flag (highly recommended), you cannot use LemonLDAP::NG
Handler to access insecure, unencrypted HTTP applications at all.

You can find this setting in in *General Parameters* » *Cookies* » *Secured
Cookie (SSL)*

Changes in outgoing proxy configuration
---------------------------------------

If LemonLDAP::NG has to use an outgoing HTTP proxy (generally in entreprise
deployments only), you must review the proxy configuration.

Starting from LemonLDAP::NG 3.0, all outgoing HTTP requests will obey the proxy
configuration set in the process' environment.

On package-based installations, environment variables are set in
``/etc/default/llng-fastcgi-server``.

- set the ``http_proxy`` environment variable to the URL of your outgoing http proxy
- set the ``https_proxy`` environment variable to the URL of your outgoing https proxy
- set the ``no_proxy`` environment variable to a comma-separated list of destination domains
  that must not use the proxy

In most situations, you will want your internal domains to be added to the
``no_proxy`` list so that requests performed internally by LemonLDAP::NG will
not go through the proxy.

New TOTP storage format
-----------------------

As of LemonLDAP::NG 3.0, the storage format for TOTP registrations has evolved
to allow changing the parameters (algorithm, code length, and time interval) in
the future. It is recommanded to run the `migrateTotpSecrets` script in order
to update the existing registrations with this information. If you don't do
this, TOTP registrations will start failing if you change the parameters in the
future.

In most situations, you can update the storage with this command ::

    migrateTotpSecrets --interval 30 --digits 6 --algorithm sha1

If you are currenly using a different set of parameters, you need adjust the command
accordingly.

.. warning:: Make sure to back up your persistent sessions before running this
   command. If you use incorrect parameters, TOTP registrations will no longer
   work. The parameters must match the configuration you used in LemonLDAP 2.0

Plugins
-------

Encoding changes
~~~~~~~~~~~~~~~~

Because of the new way LemonLDAP::NG 3 handles text, existing plugins that
handle text containing non-ASCII characters will likely break.

Refer to :doc:`devutf8` for a primer on how text should be handled from now on.

XML format for notifications
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

XML format for notifications is not longer support. Notifications should be
convert into JSON format.

Refer to :doc:`notifications` section for more informations about notifications system.

If you use database to store notifications, you have to rename `xml` column into `content`.

OneTimeToken library name changes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lib::OneTimeToken library becomes Lib::StateToken.
getToken, updateToken and createToken methods become getState, updateState and storeState.


Reload URLs do not exist anymore
--------------------------------

The ``reloadUrls`` and ``reloadTimeout`` parameters have been removed, check out
the :doc:`eventsmanagement` section for more information about configuration reload.

No default kind
---------------

``$self->p->getApacheSession()`` used to fall back to the ``SSO`` session kind
when the ``kind`` argument was missing. This default has been removed: ``kind``
is now mandatory.

A plugin that omits it gets nothing back, and an error is logged::

    getApacheSession() called without 'kind' at /path/to/MyPlugin.pm line 42

Custom plugins must now declare the kind of session they expect::

    # 3.0
    my $session = $self->p->getApacheSession( $id, kind => 'SSO' );
    my $token =
      $self->p->getApacheSession( undef, kind => 'TOKEN', info => $infos );


Second factor routes
--------------------

All second factor routes are now relative to ``2ndfa`` to be more
consistent when writing access rules ::

    /sfa/persistent/
    becomes
    /2ndfa/persistent/
    like 2ndfa.html

SAML URL parameters
-------------------

To automatically select an IDP, ``idp`` parameter is replaced by ``idpEntityId`` parameter to specify
SAML IDP by its encoded url: https://auth.example.com/?idpEntityId=https%3A%2F%2Fidp.example.com%2Fsaml.

``idpName`` parameter is replaced by ``idp`` parameter to specify
the IDP name in LemonLDAP::NG Manager: https://auth.example.com/?idp=idp-example

Hashed session storage enabled on new installations
---------------------------------------------------

``hashedSessionStore`` is now enabled on new installations: sessions are stored
under the SHA-256 hash of their identifier, so a read access to the session
backend is no longer enough to hijack a session.

Existing installations keep their own value. To benefit from it, migrate your
sessions using the ``convertToHashSessionStorage`` utility (see
:doc:`changesessionbackend`).

Overlay configuration backend removed
-------------------------------------

The ``Overlay`` configuration backend has been removed, with no compatibility
layer: a ``type = Overlay`` configuration backend refuses to load and logs the
migration to perform.

It is replaced by the new :doc:`Filesystem placeholder
<filesystemplaceholder>`, which reads secrets in the files of a directory. The
former ``overlayRealtype`` becomes the ``type``, and ``overlayDirectory``
becomes ``filesystemPlaceholderDirectory``:

.. code-block:: ini

   [configuration]
   type = File
   dirName = /var/lib/lemonldap-ng/conf
   configPlaceHolderModules = FILE=Lemonldap::NG::Common::Conf::Placeholder::Filesystem
   filesystemPlaceholderDirectory = /var/lib/lemonldap-ng/secrets

Then each overlayed parameter must hold a placeholder as value in the
configuration: ``%FILE:<parameter name>%`` keeps using the same files. A
parameter declared as a hash can not be replaced as a whole any more: put a
placeholder in each of its values. ``overlayWrite`` has no equivalent.

Graphical interface
-------------------

Portal skin
~~~~~~~~~~~

Portal skin has been upgrade to Boostrap5.

Read carefully :doc:`bootstrapskin` to know what changes you need to do.

Backgrounds
~~~~~~~~~~~

Default background images have been deleted, these files are no more in LemonLDAP::NG packages:

* 1280px-Anse_Source_d'Argent_2-La_Digue.jpg
* 1280px-Autumn-clear-water-waterfall-landscape\_-_Virginia_-_ForestWander.jpg
* 1280px-BrockenSnowedTrees.jpg
* 1280px-Cedar_Breaks_National_Monument_partially.jpg
* 1280px-Parry_Peak_from_Winter_Park.jpg
* Aletschgletscher_mit_Pinus_cembra1.jpg

If you are using one of them, you can download it and install it in ``/usr/share/lemonldap-ng/portal/htdocs/static/common/backgrounds``.

If you already configured a custom background image, you have nothing to do.
