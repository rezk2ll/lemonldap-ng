SSL
===

============== ===== ========
Authentication Users Password
============== ===== ========
✔                   
============== ===== ========

Presentation
------------

LL::NG uses `Apache SSL
module <http://httpd.apache.org/docs/current/mod/mod_ssl.html>`__, like
any other :doc:`Apache authentication module<authapache>`, with extra
features:

-  Choice of any certificate attribute as user main login
-  Allow no certificate to chain with other authentication methods

Configuration (as the only authentication module)
-------------------------------------------------

By default, SSL is required before the portal is displayed (handled by
webserver). If you want to display a button to connect to LLNG
*(compatible with :doc:`Combination<authcombination>`)*, you can
activate "SSL by Ajax request" in the manager. See "SSL by Ajax"
below.

With Apache
~~~~~~~~~~~

Enable SSL in Apache
^^^^^^^^^^^^^^^^^^^^

You have to install mod_ssl for Apache.

For CentOS/RHEL:

.. code:: shell

   yum install mod_ssl


.. tip:: 

    In Debian/Ubuntu mod_ssl is already shipped in
    ``apache*-common`` package.


.. tip:: 

    For CentOS/RHEL, We advice to disable the default SSL virtual
    host configured in /etc/httpd/conf.d/ssl.conf.

Apache SSL global configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can then use this default SSL configuration, for example in the head
of /etc/lemonldap-ng/portal-apache2.conf:

.. code:: apache

   SSLProtocol all -SSLv2
   SSLCipherSuite HIGH:MEDIUM
   SSLCertificateFile /etc/httpd/certs/ow2.cert
   SSLCertificateKeyFile /etc/httpd/certs/ow2.key
   SSLCACertificateFile /etc/httpd/certs/ow2-ca.cert


.. important:: 

    Put your own files instead of ``ow2.cert``, ``ow2.key``,
    ``ow2-ca.cert``:
    
    -  **SSLCertificateFile**: Server certificate
    -  **SSLCertificateKeyFile**: Server private key
    -  **SSLCACertificateFile**: CA certificate to validate client
       certificates
    


If you specify port in virtual host, then declare SSL port:

.. code:: apache

   NameVirtualHost *:80
   NameVirtualHost *:443

Apache portal SSL configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Edit the portal virtual host to enable SSL double authentication:

.. code:: apache

   SSLEngine On
   SSLVerifyClient optional
   SSLVerifyDepth 10
   SSLOptions +StdEnvVars
   SSLUserName SSL_CLIENT_S_DN_CN

All SSL options are documented in `Apache mod_ssl
page <http://httpd.apache.org/docs/current/mod/mod_ssl.html>`__.

Here are the main options used by LL::NG:

-  **SSLVerifyClient**: set to ``optional`` to allow user with a bad
   certificate to access to LL::NG portal page. To switch to another
   authentication backend, use the :doc:`Multi<authmulti>` module, for
   example: ``Multi SSL;LDAP``
-  **SSLOptions**: set to ``+StdEnvVars`` to get certificate fields in
   environment variables
-  **SSLUserName** (optional): certificate field that will be used to
   identify user in LL::NG portal virtual host

With Nginx
~~~~~~~~~~

Enable SSL:

.. code:: nginx

   ssl on;
   ssl_verify_client optional;
   ssl_certificate /etc/letsencrypt/live/my/fullchain.pem;
   ssl_certificate_key /etc/letsencrypt/live/my/privkey.pem;
   ssl_verify_depth 3;
   # All CA certificates concatenated in a single file
   ssl_client_certificate /etc/nginx/ssl/ca.pem;
   ssl_crl /etc/nginx/ssl/crl/my.crl;

   # Reset SSL connection. User does not have to close his browser to try connecting again
   keepalive_timeout 0 0;
   add_header 'Connection' 'close';
   ssl_session_timeout 1s;

You must also export SSL_CLIENT_S_DN_CN in FastCGI params:

.. code:: nginx

   # map directive must be set in http context
   map $ssl_client_s_dn $ssl_client_s_dn_cn {
              default           "";
              ~/CN=(?<CN>[^/]+) $CN; # prior Nginx 1.11.6
              #~,CN=(?<CN>[^,]+) $CN; # Nginx >= 1.11.6
         }
   fastcgi_param  SSL_CLIENT_S_DN_CN $ssl_client_s_dn_cn;

Nginx SSL Virtual Host example with uWSGI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: nginx

   server {
     listen 443;
     server_name authssl.example.com;
     root /usr/share/lemonldap-ng/portal/htdocs/;
     # Use "lm_app" format to get username in nginx.log (see nginx-lmlog.conf)
     access_log /var/log/nginx/access.log lm_app;

     ssl_verify_client on;
     ssl_verify_depth 3;
     
     # Full chain CRL is required
     # All CRLs must be concatenated in a single .pem format file
     ssl_crl /etc/nginx/ssl/crl/crls.pem;
     if ($uri !~ ^/((static|javascript|favicon).*|.*\.psgi)) {
       rewrite ^/(.*)$ /index.psgi/$1 break;
     }

     location ~ ^(?<sc>/.*\.psgi)(?:$|/) {
       # uWSGI Configuration
       include /etc/nginx/uwsgi_params;
       uwsgi_pass 127.0.0.1:5000;
       uwsgi_param LLTYPE psgi;
       uwsgi_param SCRIPT_FILENAME $document_root$sc;
       uwsgi_param SCRIPT_NAME $sc;
       uwsgi_param  SSL_CLIENT_S_DN_CN $ssl_client_s_dn_cn;
     }

     #index index.psgi;
     location / {
       try_files $uri $uri/ =404;
       add_header Strict-Transport-Security "max-age=15768000";
     }
   }


.. important:: 

    Nginx 1.11.6 change: format of the $ssl_client_s_dn and
    $ssl_client_i_dn variables has been changed to follow RFC 2253 (RFC
    4514); values in the old format are available in the
    $ssl_client_s_dn_legacy and $ssl_client_i_dn_legacy variables. 

Configuration of LemonLDAP::NG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose SSL for authentication.


.. tip:: 

    You can then choose any other module for users and
    password.

Then, go in ``SSL parameters``:

-  **Authentication level**: authentication level for this module
-  **Extracted certificate field**: field of the certificate affected to
   $user internal variable

Auto reloading SSL Certificates
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A known problematic is that many browser (Firefox, Chrome) remembers the
fact that the certificate is not available at a certain time. It is
particularly important for smart cards: when the card is not inserted
before the browser starts, the user must restart his browser, or at
least refresh (F5) the page.

Apache server
^^^^^^^^^^^^^

It is possible with AJAX code and 3 Apache locations to bypass this
limitation.

1. Modify the portal virtual host to match this example:

.. code:: apache

       SSLEngine On
       SSLCACertificateFile /etc/apache2/ssl/ca.crt
       SSLCertificateKeyFile /etc/apache2/ssl/lemonldap.key
       SSLCertificateFile /etc/apache2/ssl/lemonldap.crt

       SSLVerifyDepth 10
       SSLOptions +StdEnvVars
       SSLUserName SSL_CLIENT_S_DN_CN

       # DocumentRoot
       DocumentRoot /var/lib/lemonldap-ng/portal/
       <Directory /var/lib/lemonldap-ng/portal/>
           Order Deny,Allow
           Allow from all
           Options +ExecCGI +FollowSymLinks
           SSLVerifyClient none
       </Directory>

       <Location /index>
           Order Deny,Allow
           Allow from all
           SSLVerifyClient none
       </Location>

       <Location /testssl>
           Order Deny,Allow
           Allow from all
           SSLVerifyClient require
       </Location>

       Alias /sslok /var/lib/lemonldap-ng/portal
       <Location /sslok>
           Order Deny,Allow
           Allow from all
           SSLVerifyClient require
       </Location>

-  /index/ is an unprotected page to display a SSL test button
-  /testssl/ is a SSL protected page to check the certificate
-  /sslok/ is the new LemonLDAP::NG portal. You need to declare the new
   url in the manager: Portal -> URL: https://auth.example.com/sslok/

2. Then you need to construct the Ajax page, for example in
/index/bouton.html. It looks like this:

.. code:: html

   <body>
   <script src="./jquery-2.1.4.min.js"             type="text/javascript"> </script>
   <!--<script src="./jquery-ui-1.8-rass.js"   type="text/javascript">  </script>-->


   <a href="http://www.google.fr" class="enteteBouton" id="continuerButton"><img src=authent.png></a>
   <script>
   $('.enteteBouton').click( function (e) {
     var b=navigator.userAgent.toLowerCase();
     if(b.indexOf("msie")!==-1){
       document.execCommand("ClearAuthenticationCache")
     }
     e.preventDefault();
     $.ajax({
           url:"https://auth.example.com/testssl",
           beforeSend:function(){},
           type:"GET",
           dataType:"html",
           success:function(c,a){ 
             if (c !== "") {
                   alert("Carte OK");
                   window.location.href = "https://auth.example.com/sslok/";
             }
             else {
                 alert('Carte KO');
             }
           },
           error:function (xhr, ajaxOptions, thrownError){
             if(xhr.status==404) {
                   alert("Carte OK");
                   window.location.href = "https://auth.example.com/sslok/";
             }
             else {
                 alert('Carte KO');
             }
           },
           complete:function(c,a){}
     });
   });
   </script>
   </body>

Nginx server
^^^^^^^^^^^^

With Nginx, append those server context directives to force SSL
connexion reset:

.. code:: nginx

   keepalive_timeout 0 0;
   add_header 'Connection' 'close';
   ssl_session_timeout 1s;


.. warning:: 

    It is incompatible with authentication combination because
    of Apache parameter "SSLVerifyClient", which must have the value
    "require". To enable SSL with :doc:`Combination<authcombination>`, use
    "SSL by Ajax" 

Configuration (for Combination/Choice)
--------------------------------------

If you enable this feature, you must configure 2 portal virtual hosts:

-  the main *(which corresponds to portal URL)* with
   ``SSLVerifyClient none``
-  the second with ``SSLVerifyClient require`` and a
   ``Header set Allow-Control-Allow-Origin %%https://portal-main-url%%``

then declare the second URL in SSL options in the Manager. That's all !
Then you can chain it in a :doc:`combination<authcombination>`. 
.. important:: 

    
    With :doc:`choice<authchoice>`, the second URL should be also declared
    in module URL parameter to redirect user to Portal menu.  

.. important:: 

    
    Ajax authentication request can be sent to an another URL than Portal
    URL.
    
    To avoid a persistent loop between Portal and a redirection URL (pdata
    is not removed because domains mismatch), you have to set pdata cookie
    domain by editing ``lemonldap-ng.ini`` in section [portal]:
    
    .. code:: ini
    
       [portal]
       pdataDomain = example.com
    
    To avoid a bad/expired token during session upgrading (Reauthentication)
    if URLs are served by different load balancers, you can force Upgrade
    tokens to be stored into Global Storage by editing ``lemonldap-ng.ini``
    in section [portal]:
    
    .. code:: ini
    
       [portal]
       forceGlobalStorageUpgradeOTT = 1
    
 
.. important:: 

    **Content Security Policy** may prevent to
    submit Ajax Request. To avoid security warning,
    
    Go to :
    ``General Parameters > Advanced Parameters > Security > Content security policy``
    
    and set :
    
    **Default value** => 'self' "Ajax request URL"
    
    **Form destinations** => 'self' "Ajax request URL"
    
    **Ajax destinations** => 'self' "Ajax request URL"
    
    **Script source** => 'self' "Ajax request URL" 

Extracting the username attribute
---------------------------------

The "Extracted certificate field" must be set to the Apache/Nginx
environment variable containing the username attribute.

See the `mod_ssl
documentation <https://httpd.apache.org/docs/current/en/mod/mod_ssl.html>`__
for a list of supported variables names.

If your webserver configuration allows multiple CAs, you may configure a
different environment variable for each CA.

In the "Conditional extracted certificate field", add a line for each
CA.

-  key: the CA subject DN (will be printed in debug logs)
-  value: the variable containing the username when using certificates
   emitted by this CA
