Error messages
==============


.. note::

    This page does not reference all error messages,
    but only the most common ones

Lemonldap::NG::Common
---------------------

::

   Warning: key is not defined, set it in the manager !

→ LemonLDAP::NG uses a key to crypt/decrypt some data. You have to set
its value in Manager. This message is displayed only when you upgrade
from a version older than 1.0

::

   Can't locate /usr/share/lemonldap-ng/configStorage.pl

→ When you upgrade from Debian Lenny with customized index.pl files, you
must upgrade them. 

Lemonldap::NG::Handler
----------------------

::

   Unable to clear local cache

→ Local cache cannot be cleared, check the localStorage and
localStorageOptions or file permissions

::

   Status module can not be loaded without localStorage parameter

→ You tried to activate Status module without localStorage. Configure
local cache first.

::

   No configuration found

→ The configuration cannot be loaded. Check configStorage and
configStorageOptionsor file permissions.

::

   User rejected because VirtualHost XXXX has no configuration

→ The specified virtual host is not configured in Manager.

::

   mkdir /tmp/MyNamespace/2: Permission denied ...

→ The cache has been created by another user than Apache's user. Restart
Apache to purge it.

.. attention::

    This can append when you use
    lmConfigEditor or launch **cron files** with a different user than
    Apache process. That is why it is important to set APACHEUSER variable
    when you launch "make install"

::

   Lemonldap::NG::Handler::SharedConf: No cookie found

→ User does not have Lemonldap::NG cookie, handler redirect it to the
portal

::

   The cookie $id isn't yet available: Object does not exist in the data store

→ User session has expired or handler does not have access to the same
Apache::Session database than the portal

::

   Firefox has detected that the server is redirecting the request for this address in a way that will never complete

→ Your browser loops between portal and handler, it is probably a cookie
problem. Verify that:

-  the portal is in the declared domain
-  CDA is set if the handler is not in the same domain
-  portal is in a https virtualhost if securedCookie is set
-  you've restart all Apache server after having change cookie name or
   domain

Lemonldap::NG::Manager
----------------------

::

   XXXX was not found in tree

→ The specified node is not the uploaded tree.

Lemonldap::NG::Portal
---------------------

::

   User XXXX was not granted to open session

→ Check grantSessionRule parameter.

::

   XML menu configuration is deprecated. Please use lmMigrateConfFiles2ini to migrate your menu configuration

→ You do not use the new configuration syntax for application list. XML
file is no more accepted.

::

   Apache is not configured to authenticate users !

→ You use the Apache authentication backend, but Apache is not or bad
configured (no REMOTE_USER send to LemonLDAP::NG).

::

   URL contains a non protected host

→ The host is not known by LemonLDAP::NG. Add it to trustedDomains (or
set ``*`` in trustedDomains to accept all).

::

   XSS attack detected

→ Some URL parameters contain forbidden characters.

::
   
   Detailled error codes list

→ Corresponding error codes can be found in
   :doc:`Portal error codes<error_codes>`
