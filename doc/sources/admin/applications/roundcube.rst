RoundCube
=========

Presentation
------------

`RoundCube <http://www.roundcube.net>`__ webmail is a browser-based
multilingual IMAP client with an application-like user interface. It
provides full functionality you expect from an email client, including
MIME support, address book, folder manipulation, message searching and
spell checking.

Configuration
-------------

LemonLDAP::NG
~~~~~~~~~~~~~

-  Add a new virtual host webmail.domain.tld
-  Add a new rule:

::

   "^/\?_task\=logout" -> "logout_app https://auth.domain.tld"

-  in HTTP headers, you need Auth-User ($mail) and Auth-Pw ($_password).


.. attention::

    To be able to forward password to RoundCube, see
    :doc:`how to store password in session<../passwordstore>`\

-  Configure :doc:`Apache or Nginx virtual host<../configvhost>`

.. _roundcube-1:

RoundCube
~~~~~~~~~

-  install http_authentication plugin
-  Patch it to replace ``PHP_AUTH_*`` by ``HTTP_AUTH_*``
-  enable http_authentication plugin in main.inc.php :

.. code-block:: php

   $rcmail_config['plugins'] = array('http_authentication');

