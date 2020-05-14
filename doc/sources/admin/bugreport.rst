How to report a bug
===================

If you don't know if the problem is a bug, first try to contact us on
lemonldap-ng-users@ow2.org.

Before reporting bug
--------------------

First, verify that the bug isn't known; the list is here: `Known
Lemonldap::NG
bugs <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues>`__.

Bug reports must provide enough information for developers. So here are
the steps:

-  set log level to debug:

   -  in lemonldap-ng.ini, section [all]
   -  for Apache users, set also "LogLevel perl:debug" or "LogLevel
      debug" in your httpd.conf

-  restart the web server
-  replay the sequence that fails

Report the bug
--------------

-  Go to https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues
-  Create an account if you don't have one
-  Create the the bug using "New issue" button
-  Fill the form:

   -  don't forget to set the version you're using
   -  explain the sequence that generates the bug
   -  attach the log file *(or part of it if it's enough)*

-  Submit the form
