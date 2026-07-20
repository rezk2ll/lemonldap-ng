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

Run the following SQL command on your database ::

    # If you use notifications
    alter table notifications alter column xml type text USING convert_from(convert_to(convert_from(xml, 'utf8'), 'iso8859-1'), 'utf-8');

    # Convert your session storage
    update sessions set a_session=convert_from(convert_to(a_session::text, 'iso8859-1'), 'utf-8');
    update sessions set a_session=convert_from(convert_to(a_session::text, 'iso8859-1'), 'utf-8');
    update sessions set a_session=convert_from(convert_to(a_session::text, 'iso8859-1'), 'utf-8');

    # Convert your configuration storage
    update lmconfig set data=convert_from(convert_to(data, 'iso8859-1'), 'utf-8');


MySQL
~~~~~

Run the following SQL command on your database ::

    alter table notifications modify xml text NOT NULL;

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

Reload URLs do not exist anymore
--------------------------------

The ``reloadUrls`` and ``reloadTimeout`` parameters have been removed, check out
the :doc:`eventsmanagement` section for more information about configuration reload.
