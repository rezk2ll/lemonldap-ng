LimeSurvey
==========

|image0|

Presentation
------------

`LimeSurvey <http://www.limesurvey.org>`__ is a web survey software
written in PHP.

HTTP Headers
------------

LimeSurvey has a webserver authentication mode that allows one to
integrate it directly into LemonLDAP::NG.

To have a stronger integration, we will configure LimeSurvey to
autocreate unknown users and use HTTP headers to fill name and mail.


.. attention::

    We suppose that LimeSurvey is installed in
    /var/www/html/limesurvey

LimeSurvey configuration
~~~~~~~~~~~~~~~~~~~~~~~~

In Administration panel, go in Configuration > Parameters > Extensions
manager. Select the WebServer module and configure it.

|image1|

This is enough for the authentication part.


.. tip::

    If you are blocked, you can deactivate the plugin with this
    request in database:

    ::

       update lime_plugins SET active=0 where name="Authwebserver";



To configure account autocreation, you need to edit
application/config/config.php: The configuration is done in config.php:

::

   vi /var/www/html/limesurvey/application/config/config.php

.. code-block:: php

           'config'=>array(
           // debug: Set this to 1 if you are looking for errors. If you still get no errors after enabling this
           // then please check your error-logs - either in your hosting provider admin panel or in some /logs directory
           // on your webspace.
           // LimeSurvey developers: Set this to 2 to additionally display STRICT PHP error messages and get full access to standard templates
                   'debug'=>0,
                   'debugsql'=>0, // Set this to 1 to enanble sql logging, only active when debug = 2
                   // Update default LimeSurvey config here
                   'auth_webserver_autocreate_user' => true,
                   'auth_webserver_autocreate_profile' => Array('full_name' => $_SERVER['HTTP_AUTH_CN'],'email' => $_SERVER['HTTP_AUTH_MAIL'],'lang'=>'en'),
                   'auth_webserver_autocreate_permissions' => Array('surveys' => array('create'=>true,'read'=>false,'update'=>false,'delete'=>false)),
                   )

See also
https://manual.limesurvey.org/Optional_settings#Authentication_delegation_with_automatic_user_import

LimeSurvey virtual host
~~~~~~~~~~~~~~~~~~~~~~~

Configure LimeSurvey virtual host like other
:doc:`protected virtual host<../configvhost>`.

LimeSurvey virtual host in Manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to the Manager and :doc:`create a new virtual host<../configvhost>`
for LimeSurvey.

Headers
^^^^^^^

=========== ==============
Header name Description
=========== ==============
Auth-User   user login
Auth-Cn     user full name
Auth-Mail   user email
=========== ==============

Rules
^^^^^

========= =========== ========================================
Rule name Expression  Description
========= =========== ========================================
Logout    /sa/logout$ Logout rule (for example logout_app_sso)
Admin                 Allow only admin and superadmin users
Default   default     Allow only users with a LimeSurvey role
========= =========== ========================================


.. tip::

    You can set the default access to:

    * **accept**: all authenticated users will access surveys
    * **unprotect**: no authentication will be asked to access surveys



.. |image0| image:: /applications/limesurvey_logo.png
   :class: align-center
.. |image1| image:: /applications/screenshot_limesurvey_configuration.png
   :class: align-center

