Node.js handler
===============

Since version 2.0, a beta Node.js handler is available on
`GitHub <https://github.com/LemonLDAPNG/node-lemonldap-ng-handler>`__
and `NPMJS <https://www.npmjs.com/package/lemonldap-ng-handler>`__.

Up-to-date documentation is available on GitHub.

Examples
--------

**Important things**:

-  The above examples below are written for version 0.6.0 in CommonJS
   but Node.js handler can be used in ES7 and/or Typescript code
-  Rules and headers must be written in javascript for these hosts
   (example ``$uid eq "dwho"`` becomes ``$uid === "dwho"``)
-  Virtualhosts handled by node-lemonldap-ng-handler must be explicitly
   declared in your ``lemonldap-ng.ini`` file in ``[node-handler]``
   section

.. code-block:: ini

   [node-handler]

   nodeVhosts = test.example.com, test2.example.com

Use it as FastCGI server (application protection only)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FastCGI server
^^^^^^^^^^^^^^

.. code-block:: javascript

   var handler = require('lemonldap-ng-handler');

   handler.init({
     configStorage: {
       "confFile": "/path/to/lemonldap-ng.ini"
     }
   }).then( () => {

     handler.nginxServer({
       "mode": "fcgi",   // or "http", default: fcgi
       "port": 9090,     // default value
       "ip": 'localhost' // default value
     });

   });

Nginx configuration
^^^^^^^^^^^^^^^^^^^

.. code-block:: nginx

   server {
     #...
     # Internal authentication request
     location = /lmauth {
       internal;
       include /etc/nginx/fastcgi_params;
       fastcgi_pass localhost:9090;

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
       include conf/nginx-lua-headers.conf;
     }
   }

Use it to protect an express app
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: javascript

   // Variables
   var express = require('express');
   var app = express();
   var handler = require('lemonldap-ng-handler');

   // initialize handler (optional args)
   handler.init({
     configStorage: {
       "confFile":"test/lemonldap-ng.ini"
     }
   }).then( () => {

     // and load it
     app.use(handler.run);

     // Then simply use your express app
     app.get('/', function(req, res) {
       return res.send('Hello ' + req.headers['Auth-User'] + ' !');
     });
     app.listen(3000, function() {
       return console.log('Example app listening on port 3000!');
     });
   });

