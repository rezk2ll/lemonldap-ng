LemonLDAP::NG in Docker
=======================

|image0|

Presentation
------------

`Docker <https://www.docker.com/>`__ allows do run application into
containers.

You can find a Docker image for LemonLDAP::NG in this repository:
`<https://hub.docker.com/r/lemonldapng/lemonldap-ng>`_

See also this github project:
https://github.com/LemonLDAPNG/lemonldap-ng-docker

.. note::

   The docker images are compatible with podman. The images can also be built with podman if needed.

Usage
-----

Prerequisites:

-  Add the URLs below to /etc/hosts on your host server where the docker container will be deployed

::

   echo "127.0.0.1 auth.example.com manager.example.com reload.example.com test1.example.com test2.example.com" | sudo tee -a /etc/hosts

Simple Deployment
-----------------

-  With sudo the container can be deployed directly to the host port 80 (option -p)

::

   sudo docker run -d -p 80:80 --name lemonldap-ng lemonldapng/lemonldap-ng

-  With a rootless docker instance mapping the container to the host port 8080 on the host is neccessary

::

  docker run -d -p 8080:8080 -e PORT=8080 --name lemonldap-ng lemonldapng/lemonldap-ng

.. attention::

   With more complex deployments such as with SELinux the internal container port can be modified with the environment variable specified above with PORTS

Then connect to http://auth.example.com with your browser and log in
with dwho/dwho.

Advanced configuration
----------------------

For first time deployments you will need access to the lemonldap static (lemonldap-ng.ini) and dynamic configuration (lmConf-X.json) we will need to configure the volume mounts.

The following folders will container the theme components such as logos, templates and more:

-  /usr/share/lemonldap-ng/portal/htdocs/static/CustomTheme
-  /usr/share/lemonldap-ng/portal/htdocs/static/CustomTheme/css
-  /usr/share/lemonldap-ng/portal/htdocs/static/CustomTheme/js
-  /usr/share/lemonldap-ng/portal/htdocs/static/CustomTheme/images
-  /usr/share/lemonldap-ng/portal/templates/CustomTheme

.. note::

   Loading the custom theme elements requires the configuration of portalSkin variable. In docker this variable must also be configured with the name of the folder being used.
   In our example case we would configure the variable with "CustomTheme" Keeping the folder name consistant between "templates" and "htdocs/static" is important.

The plugins will be stored in these folders:

-  /usr/share/perl5/Lemonldap/NG/Portal/Plugins/CustomPlugin
-  /usr/share/perl5/Lemonldap/NG/Portal/Register/CustomRegister
-  /usr/share/perl5/Lemonldap/NG/Portal/UserDB/CustomUserdb
-  /usr/share/perl5/Lemonldap/NG/Portal/Auth/CustomAuth
-  /usr/share/perl5/Lemonldap/NG/Portal/Captcha/CustomCaptcha
-  /usr/share/perl5/Lemonldap/NG/Portal/MenuTab/CustomMenuTab

.. note::

   The plugins will be stored in a foler appended with "Custom" therefore all plugins much include the full path to the plugin in the header of the perl file.
   Example: For plugins stored in /usr/share/perl5/Lemonldap/NG/Portal/Plugins/CustomPlugin/LDAPSearch.pm the header would be package Lemonldap::NG::Portal::Plugin::CustomPlugin::LDAPSeach

The following folders for the configuration and session data can also be mounted and exposed:

-  /etc/lemonldap-ng
-  /var/lib/lemonldap-ng/conf
-  /var/lib/lemonldap-ng/sessions
-  /var/lib/lemonldap-ng/psessions
-  /etc/nginx/sites-enabled

Finally a cron job to purge sessions must also be configured with `crontab`:

::

  # Lemonldap::NG::Handler Session Purge
  1 * * * * docker exec -it lemonldap bash -c "[ -x /usr/share/lemonldap-ng/bin/purgeLocalCache ] && if [ ! -d /run/systemd/system ]; then /usr/share/lemonldap-ng/bin/purgeLocalCache; fi"
  # Lemonldap::NG::Portal Session Purge
  7 * * * * docker exec -it lemonldap bash -c "[ -x /usr/share/lemonldap-ng/bin/purgeCentralCache ] && if [ ! -d /run/systemd/system ]; then /usr/share/lemonldap-ng/bin/purgeCentralCache; fi"

.. note::

   If the container is deployed with rootless docker make sure to execute the crontab without sude.
   Running sudo crontab will execute the cronjobs on the sudo docker instance deployment.

We can use the docker run command as follows which include all the possible customisations feasible with the image:

::

  docker run -d \
    --name lemonldap-ng
    -e SSODOMAIN=example.com \
    -e PORTAL_HOSTNAME=auth.example.com \
    -e MANAGER_HOSTNAME=manager.example.com \
    -e HANDLER_HOSTNAME=reload.example.com \
    -e TEST1_HOSTNAME=test1.example.com \
    -e TEST2_HOSTNAME=test2.example.com \
    -e PRESERVEFILES=/etc/lemonldap-ng /var/lib/lemonldap-ng/conf /var/lib/lemonldap-ng/sessions /var/lib/lemonldap-ng/psessions \
    -e LOGLEVEL=debug \
    -e FASTCGI_LISTEN_PORT=9000 \
    -e PORT=8080 \
    -e IPV4_ONLY=true \
    -p 8080:8080 \
    -p 9000:9000 \
    -v ./llng/etc:/etc/lemonldap-ng \
    -v ./llng/var-conf:/var/lib/lemonldap-ng/conf \
    -v ./llng/var-sessions:/var/lib/lemonldap-ng/sessions \
    -v ./llng/var-psessions:/var/lib/lemonldap-ng/psessions \
    -v ./llng/theme:/usr/share/lemonldap-ng/portal/htdocs/static/CustomTheme \
    -v ./llng/template:/usr/share/lemonldap-ng/portal/templates/CustomTheme \
    -v ./llng/plugins:/usr/share/perl5/Lemonldap/NG/Portal/Plugins/CustomPlugin \
    -v ./llng/register:/usr/share/perl5/Lemonldap/NG/Portal/Register/CustomRegister \
    -v ./llng/userdb:/usr/share/perl5/Lemonldap/NG/Portal/UserDB/CustomUserdb \
    -v ./llng/auth:/usr/share/perl5/Lemonldap/NG/Portal/Auth/CustomAuth \
    -v ./llng/captcha:/usr/share/perl5/Lemonldap/NG/Portal/Captcha/CustomCaptcha \
    -v ./llng/menutab:/usr/share/perl5/Lemonldap/NG/Portal/MenuTab/CustomMenuTab \
    -v ./llng/nginx:/etc/nginx/sites-enabled \
    lemonldapng/lemonldap-ng:latest

Adding the `:Z` is required for SELinux:

::

  docker run -d \
    --name lemonldap-ng
    -e SSODOMAIN=example.com \
    -e PORTAL_HOSTNAME=auth.example.com \
    -e MANAGER_HOSTNAME=manager.example.com \
    -e HANDLER_HOSTNAME=reload.example.com \
    -e TEST1_HOSTNAME=test1.example.com \
    -e TEST2_HOSTNAME=test2.example.com \
    -e PRESERVEFILES=/etc/lemonldap-ng /var/lib/lemonldap-ng/conf /var/lib/lemonldap-ng/sessions /var/lib/lemonldap-ng/psessions \
    -e LOGLEVEL=debug \
    -e FASTCGI_LISTEN_PORT=9000 \
    -e PORT=8080 \
    -e IPV4_ONLY=true \
    -p 8080:8080 \
    -p 9000:9000 \
    -v ./llng/etc:/etc/lemonldap-ng:Z \
    -v ./llng/var-conf:/var/lib/lemonldap-ng/conf:Z \
    -v ./llng/var-sessions:/var/lib/lemonldap-ng/sessions:Z \
    -v ./llng/var-psessions:/var/lib/lemonldap-ng/psessions:Z \
    -v ./llng/theme:/usr/share/lemonldap-ng/portal/htdocs/static/CustomTheme:Z \
    -v ./llng/template:/usr/share/lemonldap-ng/portal/templates/CustomTheme:Z \
    -v ./llng/plugins:/usr/share/perl5/Lemonldap/NG/Portal/Plugins/CustomPlugin:Z \
    -v ./llng/register:/usr/share/perl5/Lemonldap/NG/Portal/Register/CustomRegister:Z \
    -v ./llng/userdb:/usr/share/perl5/Lemonldap/NG/Portal/UserDB/CustomUserdb:Z \
    -v ./llng/auth:/usr/share/perl5/Lemonldap/NG/Portal/Auth/CustomAuth:Z \
    -v ./llng/captcha:/usr/share/perl5/Lemonldap/NG/Portal/Captcha/CustomCaptcha:Z \
    -v ./llng/menutab:/usr/share/perl5/Lemonldap/NG/Portal/MenuTab/CustomMenuTab:Z \
    -v ./llng/nginx:/etc/nginx/sites-enabled:Z \
    lemonldapng/lemonldap-ng:latest

The above command is a rootless docker deployment, using sudo, removing the PORT environment variable and binding to port 80 should be sufficient to directly expose the container.

In addition, the FASTCGI_LISTEN_PORT executes the fastcgi-server exposing port 9000 in the container. Removing this variable from the container deployment causes fastcgi-server to deploy with socket file inside the container. Regardless of the fastcgi-server deployment mechanism nginx is able to connect to fastcgi-server.

We provide docker-compose.yml example files in the github repository.

-  `https://github.com/LemonLDAPNG/lemonldap-ng-docker/blob/master/docker-compose-selinux.yaml`
-  `https://github.com/LemonLDAPNG/lemonldap-ng-docker/blob/master/docker-compose.yaml`

::

  docker compose -f docker-compose-selinux.yaml up -d
  docker compose up -d

Utilities
---------

The docker image provides the same utilities that is provided in a native installation of lemonldap.

::

  docker exec -it lemonldap-ng /usr/share/lemonldap-ng/bin/lemonldap-ng-cli
  docker exec -it lemonldap-ng /usr/share/lemonldap-ng/bin/lmConfigEditor

Import and export configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Restoring existing configuration can be done by either placing the lmConf-X.json in the folder mounted to /var/lib/lemonldap-ng/ or executing the following commands:

::

  docker cp lmConf-X.json lemonldap-ng:/var/lib/lemonldap-ng/lmConfig.json
  docker exec -it lemonldap-ng bash
  /usr/share/lemonldap-ng/bin/lemonldap-ng-cli restore - < /var/lib/lemonldap-ng/lmConfig.json
  rm /var/lib/lemonldap-ng/lmConfig.json

Exporting configuration is simple when copied directly from the mounted folder /var/lib/lemonldap-ng/ or following these commands:

::

  docker exec -it lemonldap-ng bash
  /usr/share/lemonldap-ng/bin/lemonldap-ng-cli save > /var/lib/lemonldap-ng/lmConfig.json
  docker cp lemonldap-ng:/var/lib/lemonldap-ng/lmConfig.json lmConfig.json

Reverse Proxy
-------------

Apache2 or NGinx can both be configured to bind to port 80 and proxy pass to another port binding of lemonldap.

HTTP
^^^^
::

  <VirtualHost *:80>
    ProxyPreserveHost On
    ProxyRequests Off
    CustomLog /var/log/httpd/llng.log combined
    ServerName example.com
    ServerAlias auth.example.com manager.example.com reload.example.com test1.example.com test2.example.com
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/
  </VirtualHost>

HTTPS
^^^^^

::

  <VirtualHost *:80>
    ServerName example.com
    ServerAlias auth.example.com manager.example.com reload.example.com test1.example.com test2.example.com

    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
  </VirtualHost>

  <VirtualHost *:443>
    ServerName example.com
    CustomLog /var/log/httpd/llng.log combined

    SSLEngine on
    SSLCertificateChainFile "/path/to/example.com.cacert.cert"
    SSLCertificateFile "/path/to/example.com.cert"
    SSLCertificateKeyFile "/path/to/example.com.key"

    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/
  </VirtualHost>

Protecting applications
^^^^^^^^^^^^^^^^^^^^^^^

Lemonldap::NG provides capabilities to [protect applications](https://lemonldap-ng.org/documentation/latest/configvhost.html?highlight=nginx%20reverse#reverse-proxy-1) with the handler. However the nginx configuration needs to be modified slightly to work in a containerised deployment. The creation of a [virtual host](https://lemonldap-ng.org/documentation/latest/configvhost.html?highlight=virtual%20host#lemonldap-ng-configuration) in Lemonldap::NG manager is also required for it to accepted by lemonldap for authentication and redirection of the protected application.

The following nginx configuration can be added to the `./llng/nginx` folder mounted as a volume to docker container. All configurations will be picked up by nginx after restarting the container as the folder is mounted to `/etc/nginx/sites-enabled/`.

::

  server {
    listen 8080;
    server_name application.example.com;

    # Internal authentication request
    location = /lmauth {
      internal;
      include /etc/nginx/fastcgi_params;
      fastcgi_pass /path/to/llng-fastcgi-server.sock;
      # Drop post data
      fastcgi_pass_request_body  off;
      fastcgi_param CONTENT_LENGTH "";
      # Keep original hostname
      fastcgi_param HOST $http_host;
      # Keep original request (LLNG server will receive /lmauth)
      fastcgi_param X_ORIGINAL_URI  $original_uri;
    }

    # Client requests
    location / {
      auth_request /lmauth;
      set $original_uri $uri$is_args$args;
      auth_request_set $lmremote_user $upstream_http_lm_remote_user;
      auth_request_set $lmlocation $upstream_http_location;
      error_page 401 $lmlocation;

      proxy_pass http://application-proxy.example.com/;
      include /etc/nginx/proxy_params;

      ##################################
      # PASSING HEADERS TO APPLICATION #
      ##################################
      # IF LUA IS SUPPORTED
      #include /path/to/nginx-lua-headers.conf;

      # ELSE
      # Set manually your headers
      #auth_request_set $authuser $upstream_http_auth_user;
      #proxy_set_header HTTP_AUTH_USER $authuser;
    }
  }

If the application being protected by Lemonldap::NG and also requires AUTH-USER or other HTTP headers sent to the application during proxy_pass directive make sure use `proxy_set_header` in the nginx configuration above.

When the docker deployment directly exploses Lemonldap::NG with nginx the following configuration is required:

::

  include /etc/nginx/proxy_params;

When a reverse proxy is used to redirect to the containerised instance of Lemonldap:NG additional configuration is required.

The following Nginx configurations needs to added and modified:

::

  #include /etc/nginx/proxy_params
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_pass_request_headers on;

Meanwhile the following Apache2 (httpd) configurations need to be created:

::

  <VirtualHost *:80>
    ServerName application.example.com

    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
  </VirtualHost>

  <VirtualHost *:443>
    ServerName application.example.com
    CustomLog /var/log/httpd/application.log combined

    SSLEngine on
    SSLCertificateChainFile "/path/to/application.example.com.cacert.cert"
    SSLCertificateFile "/path/to/application.example.com.cert"
    SSLCertificateKeyFile "/path/to/application.example.com.key"

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://application.example.com:8080/
  </VirtualHost>

.. note::

   Use of directory volumes mounts or docker volumes ensure safe storage of persistent configurations and important files.

.. |image0| image:: /documentation/lemonldap-ng-docker.png
   :class: align-center

