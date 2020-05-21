Viewer module
=============

This module can be useful to allow certain users to edit WebSSO
configuration in Read Only mode.

Configuration
-------------

Parameters are set in ``lemonldap-ng.ini`` file, section [manager]:

.. code-block:: ini

   [manager]
   enabledModules = conf, sessions, notifications, 2ndFA, viewer

   defaultModule = viewer

   viewerHiddenKeys = samlIDPMetaDataNodes samlSPMetaDataNodes managerPassword ManagerDn globalStorageOptions persistentStorageOptions
   viewerAllowBrowser = $groups =~ /\bsu\b/
   viewerAllowDiff = $groups =~ /\bsu\b/

-  **Parameters**:

   -  **enabledModules**: list of modules to enable
   -  **defaultModule**: module displayed by default route
      (http://manager.example.com/manager.(fcgi|psgi)
   -  **viewerHiddenKeys**: keys not displayed by Viewer
   -  **viewerAllowBrowser**: allow to browse other configurations
   -  **viewerAllowDiff**: enable "difference with previous" link


.. danger::



    You have to set access rules to allow/deny users to access modules.

    In Manager: \* Declare a Virtual Host : manager.example.com \* Set an
    access rule for each enabled module :

    #. Configuration : ^/(.*?\.(fcgi|psgi)/)?(manager\.html|confs|$) = $uid
       eq 'dwho'
    #. Notifications : ^/(.*?\.(fcgi|psgi)/)?notifications = $uid eq 'dwho'
    #. Sessions : ^/(.*?\.(fcgi|psgi)/)?sessions = $uid eq 'dwho'
    #. Viewer : ^/(.*?\.(fcgi|psgi)/)?viewer = $uid =~ /\b(?:dwho|rtyler)\b/
    #. Default : $uid =~ /\b(?:dwho|rtyler)\b/




.. attention::

    To avoid that Read-Only users can access to
    configuration module by using default route, keep in mind to set
    'defaultModule' option
