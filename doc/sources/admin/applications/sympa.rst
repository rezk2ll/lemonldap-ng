Sympa
=====

|image0|

Presentation
------------

`Sympa <http://www.sympa.org>`__ is a mailing list manager.

To configure SSO with Sympa, you have the choice between:
  * CAS
  * **Magic authentication**: a special SSO URL is protected by LL::NG, Sympa will display a button for users who wants to use this feature.

We recommend to use CAS.

CAS
---


Sympa configuration
~~~~~~~~~~~~~~~~~~~

Edit the file "auth.conf", for example:

::

   vi /etc/sympa/auth.conf

And fill it:

::

    cas
        base_url                        https://auth.example.com/cas
        non_blocking_redirection        on
        auth_service_name               SSO
        ldap_host                       ldap.example.com:389
        ldap_get_email_by_uid_filter    (uid=[uid])
        ldap_timeout                    7
        ldap_suffix                     dc=example,dc=com
        ldap_scope                      sub
        ldap_email_attribute            mail

Restart services:

::

    service sympa restart
    service apache2 restart

See also `official documentation <https://sympa-community.github.io/manual/customize/cas.html>`__

LemonLDAP::NG configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Declare CAS application in the configuration, register the service URL.

No attributes are needed.


Magic authentication
--------------------


.. tip::

    Since LL::NG 1.9, old Auto-Login feature has been
    removed since it works only with Sympa-5 which has been deprecated


Sympa configuration
~~~~~~~~~~~~~~~~~~~

Edit the file "auth.conf", for example:

::

   vi /etc/sympa/auth.conf

And fill it:

::

   generic_sso
           service_name                   Centralized auth service
           service_id                          lemonldapng
           email_http_header            HTTP_MAIL
           netid_http_header             HTTP_AUTH_USER
           internal_email_by_netid    1
           logout_url                          http://sympa.example.com/wws/logout


.. tip::

    You can also disable internal Sympa authentication to keep
    only LemonLDAP::NG by removing user_table paragraph

    Note that if you use FastCGI, you must restart Apache to enable changes.


You can also use <portal>?logout=1 as logout_url to remove LemonLDAP::NG
session when "disconnect" is chosen.

Sympa virtual host
~~~~~~~~~~~~~~~~~~

Configure Sympa virtual host like other
:doc:`protected virtual host<../configvhost>` but protect only magic
authentication URL.


.. tip::

    The location URL end is based on the ``service_id`` defined in
    Sympa apache configuration.

-  For Apache:

.. code-block:: apache

   <VirtualHost *:80>
          ServerName sympa.example.com

          <Location /wws/sso_login/lemonldapng>
          PerlHeaderParserHandler Lemonldap::NG::Handler
          </Location>

          ...

   </VirtualHost>

-  For Nginx:

.. code-block:: nginx

   server {
     listen 80;
     server_name sympa.example.com;
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
     location /wws/sso_login/lemonldapng {
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

Sympa virtual host in Manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to the Manager and :doc:`create a new virtual host<../configvhost>`
for Sympa.

Configure the :ref:`access rules<rules>` and define
the following :ref:`headers<headers>`:

-  Auth-User
-  Mail

.. |image0| image:: /applications/sympa_logo.png
   :class: align-center

