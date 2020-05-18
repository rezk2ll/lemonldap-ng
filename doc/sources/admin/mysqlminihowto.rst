Configure LemonLDAP::NG to use MySQL as main database
=====================================================

LL::NG use 2 internal databases to store its configuration and sessions.

Use MySQL for Lemonldap::NG configuration
-----------------------------------------

Steps:

-  :doc:`Prepare the database and the LL::NG configuration file<sqlconfbackend>`
-  :doc:`Convert existing configuration<changeconfbackend>`
-  Restart all your Apache servers

Use MySQL for Lemonldap::NG sessions
------------------------------------

Steps:

-  Choose one of the following:

   -  :doc:`Using Apache::Session::Browseable::MySQL<browseablesessionbackend>`
      (recommended for best performances)
   -  :doc:`Using Apache::Session::MySQL<sqlsessionbackend>` (if you
      choose this option, then read
      :ref:`how to increase MySQL performances<performances-apachesession-performances>`)
