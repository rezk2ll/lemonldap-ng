Liferay
=======

|image0|

Presentation
------------

`Liferay <http://www.liferay.com/>`__ is an enterprise portal.

Liferay can use LL::NG as an SSO provider but you have to manage how
users are created:

-  By hand in Liferay administration screens
-  Imported from an LDAP directory

Of course, integration will be full if you use the LDAP directory as
users backend for LL::NG and Liferay.


.. attention::

    If the user is not created, or can not be created via
    LDAP import, the connection to Liferay will be refused. With LDAP,
    login, mail, first name and last name are required attributes. If one is
    missing, the user is not created.

This documentation just explains how to set up the SSO part. Please
refer to Liferay documentation to enable LDAP provisionning.

Configuration
-------------

Liferay administration
~~~~~~~~~~~~~~~~~~~~~~

Access to Liferay (first time):

|image1|

Login as administrator:

|image2|

Go to ``My Account``:

|image3|

Go to ``Portal`` » ``Settings``:

|image4|

Go to ``Configuration`` » ``Authentication``:

|image5|

In ``General``, fill at least the following information:

-  **How do users authenticate?**: by login


.. tip::

    We advice to deactivate other options, cause users will use
    LL::NG portal to modify or reset their password.

|image6|


.. attention::

    You need to activate LDAP authentication, else SSO
    authentication will not work. Do this in the control panel or in the
    configuration file:

    ::

       ldap.auth.enabled=true



Then use the ``SiteMinder`` tab to configure SSO:

-  **Enabled**: Yes
-  **Import from LDAP**: Yes (see :doc:`presentation<>`)
-  **User Header**: Auth-User (case sensitive)

|image7|


.. attention::

    Do not forget to save your changes!

Liferay virtual host
~~~~~~~~~~~~~~~~~~~~

Configure Liferay virtual host like other
:doc:`protected virtual host<../configvhost>`.

-  For Apache:

.. code-block:: apache

   <VirtualHost *:80>
          ServerName liferay.example.com

          PerlHeaderParserHandler Lemonldap::NG::Handler

          ...

   </VirtualHost>

-  For Nginx:

.. code-block:: nginx

   server {
     listen 80;
     server_name liferay.example.com;
     root /path/to/application;
     # Internal authentication request
     location = /lmauth {
       internal;
       include /etc/nginx/fastcgi_params;
       fastcgi_pass unix:/var/run/llng-fastcgi-server/llng-fastcgi.sock;
       # Drop post data
       fastcgi_pass_request_body  off;
       fastcgi_param CONTENT_LENGTH "";
       # Keep original hostname
       fastcgi_param HOST $http_host;
       # Keep original request (LL::NG server will receive /lmauth)
       fastcgi_param X_ORIGINAL_URI  $original_uri;
     }

     # Client requests
     location / {
       auth_request /lmauth;
       set $original_uri $uri$is_args$args;
       auth_request_set $lmremote_user $upstream_http_lm_remote_user;
       auth_request_set $lmlocation $upstream_http_location;
       error_page 401 $lmlocation;
       try_files $uri $uri/ =404;

       ...

       include /etc/lemonldap-ng/nginx-lua-headers.conf;
     }
     location / {
       try_files $uri $uri/ =404;
     }
   }

Liferay virtual host in Manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to the Manager and :doc:`create a new virtual host<../configvhost>`
for Liferay.

Just configure the :ref:`access rules<rules>`. You
can add a rule for logout:

::

    ^/c/portal/logout => logout_sso

Configure the ``Auth-User`` :ref:`header<headers>`.

.. |image0| image:: /applications/liferay_logo.png
   :class: align-center
.. |image1| image:: /documentation/liferay_1.png
   :class: align-center
   :width: 600px
.. |image2| image:: /documentation/liferay_2.png
   :class: align-center
   :width: 600px
.. |image3| image:: /documentation/liferay_3.png
   :class: align-center
   :width: 600px
.. |image4| image:: /documentation/liferay_4.png
   :class: align-center
   :width: 600px
.. |image5| image:: /documentation/liferay_5.png
   :class: align-center
   :width: 600px
.. |image6| image:: /documentation/liferay_6.png
   :class: align-center
   :width: 600px
.. |image7| image:: /documentation/liferay_7.png
   :class: align-center
   :width: 600px
