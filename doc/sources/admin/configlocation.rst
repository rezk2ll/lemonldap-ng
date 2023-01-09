Configuration overview
======================

Backends
--------

LemonLDAP::NG configuration is stored in a backend that allows all
modules to access it.


.. attention::

    Note that all LL::NG components must have access:

    -  to the configuration backend
    -  to the sessions storage backend

    Detailed configuration backends documentation is available
    :ref:`here<start-configuration-database>`.

By default, configuration is stored in :doc:`files<fileconfbackend>`, so
access through network is not possible. To allow this, use
:doc:`SOAP<soapconfbackend>` for configuration access, or use a network
service like :doc:`SQL database<sqlconfbackend>` or
:doc:`LDAP directory<ldapconfbackend>`.

Configuration backend can be set in the
:ref:`local configuration file<configlocation-local-file>`, in ``configuration``
section.

For example, to configure the ``File`` configuration backend:

.. code-block:: ini

   [configuration]
   type=File
   dirName = /usr/local/lemonldap-ng/data/conf


.. tip::

    See
    :doc:`How to change configuration backend<changeconfbackend>` to known
    how to change this.

Manager
-------

Most of configuration can be done through LemonLDAP::NG Manager (by
default http://manager.example.com).

By default, Manager is protected to allow only the demonstration user
"dwho".


.. attention::

    This user will not be available anymore if you configure
    a new authentication backend! Remember to change the access rule in
    Manager virtual host to allow new administrators.

If you can not access the Manager anymore, you can unprotect it by
editing ``lemonldap-ng.ini`` and changing the ``protection`` parameter:

.. code-block:: ini

   [manager]

   # Manager protection: by default, the manager is protected by a demo account.
   # You can protect it :
   # * by Apache itself,
   # * by the parameter 'protection' which can take one of the following
   # values :
   #   * authenticate : all authenticated users can access
   #   * manager      : manager is protected like other virtual hosts: you
   #                    have to set rules in the corresponding virtual host
   #   * rule: <rule> : you can set here directly the rule to apply
   #   * none         : no protection


.. tip::

    See :doc:`Manager protection documentation<managerprotection>`
    to know how to use Apache modules or LL::NG to manage access to
    Manager.

The Manager displays main branches:

-  **General Parameters**: Authentication modules, portal, etc.
-  **Variables**: User information, macros and groups used to fill SSO
   session
-  **Virtual Hosts**: Access rules, headers, etc.
-  **SAML 2 Service**: SAML metadata administration
-  **SAML identity providers**: Registered IDP
-  **SAML service providers**: Registered SP
-  **OpenID Connect Service**: OpenID Connect service configuration
-  **OpenID Connect Providers**: Registered OP
-  **OpenID Connect Relying Parties**: Registered RP

LemonLDAP::NG configuration is mainly a key/value structure, so Manager
will present all keys into a structured tree. A click on a key will
display the associated value.

When all modifications are done, click on ``Save`` to store
configuration.


.. danger::

    LemonLDAP::NG will do some checks on configuration and
    display errors and warnings if any. Configuration **is not saved** if
    errors occur.


.. tip::



    -  :doc:`Configuration viewer<viewer>` allow some users to edit WebSSO
       configuration in Read Only mode.

    -  You can set and display instance name in Manager menu by editing
       ``lemonldap-ng.ini`` in [manager] section:

    .. code:: ini

       [manager]
       instanceName = LLNG_Demo


.. tip::


    It is possible to use environment variable placeholders anywhere in
    configuration. Those placeholders will be replaced by each LLNG component
    using environment variables set locally.
    The format is: ``%SERVERENV:VariableName%``.
    To enable this feature, you must edit ``lemonldap-ng.ini`` to set
    ``useServerEnv`` value in [configuration] section:

    .. code:: ini

       [configuration]
       useServerEnv = 1


Manager API
-----------

Since 2.0.8, a Manager API is available for:

-  Second factors management for users
-  OpenID Connect RP management
-  SAML SP management

See `Manager API
documentation <https://lemonldap-ng.org/manager-api/2.0/>`__.


.. attention::

    To access Manager API, enable the ``manager-api``
    virtual host and change the access rule. You can protect the API through
    Basic authentication, IP white list or any other condition.

Configuration text editor
-------------------------

LemonLDAP::NG provide a script that allows one to edit configuration
without graphical interface, this script is called ``lmConfigEditor``
and is stored in the LemonLDAP::NG bin/ directory, for example
/usr/share/lemonldap-ng/bin:

-  On Debian:

::

   /usr/share/lemonldap-ng/bin/lmConfigEditor

-  On CentOS:

::

   /usr/libexec/lemonldap-ng/bin/lmConfigEditor


.. tip::

    This script must be run as root, it will then use the Apache
    user and group to access configuration.

.. tip::

    You can change the user and group by setting ``--user`` and
    ``--group`` options in the command line.

The script uses the ``editor`` system command, that links to your
favorite editor. To change it:

::

   update-alternatives --config editor

The configuration is displayed as a big Perl Hash, that you can edit:

.. code-block:: perl

   $VAR1 = {
             'ldapAuthnLevel' => '2',
             'notificationWildcard' => 'allusers',
             'loginHistoryEnabled' => '1',
             'key' => 'q`e)kJE%<&wm>uaA',
             'samlIDPSSODescriptorSingleSignOnServiceHTTPPost' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST;#PORTAL#/saml/singleSignOn;',
             'portalSkin' => 'pastel',
             'failedLoginNumber' => '5',
             ...
             };

If a modification is done, the configuration is saved with a new
configuration number. Else, current configuration is kept.

.. _configlocation-command-line-interface-cli:

Command Line Interface (CLI)
----------------------------

LemonLDAP::NG provide a script that allows one to edit configuration
items in non interactive mode. This script is called
``lemonldap-ng-cli`` and is stored in the LemonLDAP::NG bin/ directory,
for example /usr/share/lemonldap-ng/bin:

-  On Debian:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli

-  On CentOS:

::

   /usr/libexec/lemonldap-ng/bin/lemonldap-ng-cli


.. tip::

    This script must be run as root, it will then use the Apache
    user and group to access configuration.

To see available actions, do:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli help

You can force an update of configuration cache with:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli update-cache

To get information about current configuration:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli info

To view a configuration parameter, for example portal URL:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli get portal

To set a parameter, for example domain:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli set domain example.org

To delete a parameter, for example portalSkinBackground:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli del portalSkinBackground

.. tip::

   Use addKey and delKey actions to manage values of hash configuration parameters

You can use accessors (options) to change the behavior:

-  -sep: separator of hierarchical values (by default: /).
-  -iniFile: the lemonldap-ng.ini file to use if not default value.
-  -yes: do not prompt for confirmation before saving new configuration.
-  -cfgNum: the configuration number. If not set, it will use the latest
   configuration.
-  -force: set it to 1 to save a configuration earlier than latest.

Additional options:

- --user=<user>: change user running the script
- --group=<group>: change group running the script

Some examples:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -cfgNum 10 get exportedHeaders/test1.example.com
   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 set notification 1
   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -sep ',' get macros,_whatToTrace
   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli get portal --user=nginx --group=nginx


.. tip::

    See :doc:`other examples<cli_examples>`.


.. _configlocation-apache:

Apache
------


.. attention::

    LemonLDAP::NG does not manage Apache
    configuration

LemonLDAP::NG ships 3 Apache configuration files:

-  **portal-apache2.conf**: Portal virtual host, with SOAP/REST end
   points
-  **manager-apache2.conf**: Manager virtual host
-  **handler-apache2.conf** : Handler declaration, reload virtual hosts
-  **test-apache2.conf** : Example protected virtual hosts

See :doc:`how to deploy them<configapache>`.

.. _configlocation-portal:

Portal
~~~~~~

After enabling any REST/SOAP endpoints in the Manager, you also need to
configure some for of authentication on the corresponding URLs in the
**portal-apache2.conf** configuration file.

By default, access to those URLs is denied:

.. code-block:: apache

       # REST/SOAP functions for sessions management (disabled by default)
       <Location /index.fcgi/adminSessions>
           Order deny,allow
           Deny from all
       </Location>

Allowing configuration reload
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to allow configuration reload from a different server (if your
manager is on a different server or if you are using load-balancing),
you need to edit the access rule in **handler-apache2.conf**

.. code-block:: apache

       <Location /reload>
           #CHANGE THIS######
           Require ip 127 ::1
           ###########^^^^^^^
           SetHandler perl-script
           PerlResponseHandler Lemonldap::NG::Handler::ApacheMP2->reload
       </Location>

Handler
~~~~~~~

In order to protect your application VHosts with the LemonLDAP::NG
handler, you need to add these directives:

-  Load Handler in Apache memory:

(in a global configuration file)

.. code-block:: apache

   PerlOptions +GlobalRequest
   PerlModule Lemonldap::NG::Handler::ApacheMP2

-  Catch error pages:

.. code-block:: apache

   ErrorDocument 403 http://auth.example.com/lmerror/403
   ErrorDocument 404 http://auth.example.com/lmerror/404
   ErrorDocument 500 http://auth.example.com/lmerror/500
   ErrorDocument 502 http://auth.example.com/lmerror/502
   ErrorDocument 503 http://auth.example.com/lmerror/503

Then, to protect a standard virtual host, the only configuration line to
add is:

.. code-block:: apache

   PerlHeaderParserHandler Lemonldap::NG::Handler::ApacheMP2

See **test-apache2.conf** for a complete example of a protected
application

Nginx
-----


.. attention::

    LemonLDAP::NG does not manage Nginx configuration

LemonLDAP::NG ships 3 Nginx configuration files:

-  **portal-nginx.conf**: Portal virtual host, with REST/SOAP end points
-  **manager-nginx.conf**: Manager virtual host
-  **handler-nginx.conf** : Handler reload virtual hosts
-  **test-nginx.conf** : Example protected application

See :doc:`how to deploy them<confignginx>`.


.. danger::

    \ :doc:`LL::NG FastCGI<fastcgiserver>` server must be
    enabled and started separately.

.. _portal-1:

Portal
~~~~~~

After enabling any REST/SOAP endpoints in the Manager, you also need to
configure some for of authentication on the corresponding URLs in the
**portal-nginx.conf** configuration file.

By default, access to those URLs is denied:

.. code-block:: nginx

       location ~ ^/index.psgi/adminSessions {
         fastcgi_pass llng_portal_upstream;
         deny all;
       }

.. _allowing-configuration-reload-1:

Allowing configuration reload
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to allow configuration reload from a different server (if your
manager is on a different server or if you are using load-balancing),
you need to edit the access rule in **handler-nginx.conf**

.. code-block:: nginx

     location = /reload {

       ## CHANGE THIS #
       allow 127.0.0.1;
       ######^^^^^^^^^#

       deny all;

       # FastCGI configuration
       include /etc/nginx/fastcgi_params;
       fastcgi_pass unix:__FASTCGISOCKDIR__/llng-fastcgi.sock;
       fastcgi_param LLTYPE reload;
     }

.. _handler-1:

Handler
~~~~~~~

Nginx handler is provided by the
:doc:`LemonLDAP::NG FastCGI server<fastcgiserver>`.

-  Handle errors:

.. code-block:: nginx

   error_page 403 http://auth.example.com/lmerror/403;
   error_page 404 http://auth.example.com/lmerror/404;
   error_page 500 http://auth.example.com/lmerror/500;
   error_page 502 http://auth.example.com/lmerror/502;
   error_page 503 http://auth.example.com/lmerror/503;

To protect a standard virtual host, you must insert this (or create an
included file):

.. code-block:: nginx

     # Insert $_user in logs
     include /etc/lemonldap-ng/nginx-lmlog.conf;
     access_log /var/log/nginx/access.log lm_combined;

     # Internal call to FastCGI server
     location = /lmauth {
       internal;
       include /etc/nginx/fastcgi_params;
       fastcgi_pass unix:/var/run/llng-fastcgi-server/llng-fastcgi.sock;
       fastcgi_pass_request_body  off;
       fastcgi_param CONTENT_LENGTH "";
       fastcgi_param HOST $http_host;
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

       # Set REMOTE_USER (for FastCGI apps only)
       #fastcgi_param REMOTE_USER $lmremote_user

       ##################################
       # PASSING HEADERS TO APPLICATION #
       ##################################

       # IF LUA IS SUPPORTED
       #include /path/to/nginx-lua-headers.conf

       # ELSE
       # Set manually your headers
       #auth_request_set $authuser $upstream_http_auth_user;
       #proxy_set_header Auth-User $authuser;
       # OR
       #fastcgi_param HTTP_AUTH_USER $authuser;

       # Then (if LUA not supported), change cookie header to hide LLNG cookie
       #auth_request_set $lmcookie $upstream_http_cookie;
       #proxy_set_header Cookie: $lmcookie;
       # OR
       #fastcgi_param HTTP_COOKIE $lmcookie;

       # Insert then your configuration (fastcgi_* or proxy_*)

Configuration reload
--------------------


.. note::

    As Handlers keep configuration in cache, when configuration
    change, it should be updated in Handlers. An Apache restart will work,
    but LemonLDAP::NG offers the mean to reload them through an HTTP
    request. Configuration reload will then be effective in less than 10
    minutes. If you want to change this timeout, set ``checkTime = 240`` in
    your lemonldap-ng.ini file *(values in seconds)*\

After configuration is saved by Manager, LemonLDAP::NG will try to
reload configuration on distant Handlers by sending an HTTP request to
the servers. The servers and URLs can be configured in Manager,
``General Parameters`` > ``reload configuration URLs``: keys are server
names or IP the requests will be sent to, and values are the requested
URLs.

You also have a parameter to adjust the timeout used to request reload
URLs, it is be default set to 5 seconds.


.. attention::

    If "Compact configuration file" option is enabled, all
    useless parameters are removed to limit file size. Typically, if SAMLv2
    service is disabled, all relative parameters will be erased. To avoid
    useless parameters to be purged, you can disable this option.

These parameters can be overwritten in LemonLDAP::NG ini file, in the
section ``apply``.


.. tip::

    You only need a reload URL per physical servers, as Handlers
    share the same configuration cache on each physical server.

The ``reload`` target is managed in Apache or Nginx configuration,
inside a virtual host protected by LemonLDAP::NG Handler (see below
examples in Apache->handler or Nginx->Handler).


.. attention::

    You must allow access to declared URLs to your Manager
    IP.


.. attention::

    If reload URL is served in HTTPS, to avoid "Error 500
    (certificate verify failed)", Go to :

    ``General Parameters > Advanced Parameters > Security > SSL options for server requests``

    and set :

    **verify_hostname => 0**

    **SSL_verify_mode => 0**


.. attention::

    If you want to use reload mechanism on a portal only
    host, you must install a handler in Portal host to be able to refresh
    local cache. Include ``handler-nginx.conf`` or ``handler-apache2.conf``
    for example

Practical use case: configure reload in a LL::NG cluster. In this case
you will have two servers (with IP 1.1.1.1 and 1.1.1.2), but you can
keep only one reload URL (reload.example.com):

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 addKey \
   reloadUrls '1.1.1.1' 'http://reload.example.com/reload' \
   reloadUrls '1.1.1.2' 'http://reload.example.com/reload'

You also need to adjust the protection of the reload vhost, for example:

.. code-block:: apache

       <Location /reload>
           Require ip 127 ::1 1.1.1.1 1.1.1.2
           SetHandler perl-script
           PerlResponseHandler Lemonldap::NG::Handler::ApacheMP2->reload
       </Location>


.. _configlocation-local-file:

Local file
----------

LemonLDAP::NG configuration can be managed in a local file with `INI
format <http://en.wikipedia.org/wiki/INI_file>`__. This file is called
``lemonldap-ng.ini`` and has the following sections:

-  **configuration**: where configuration is stored
-  **apply**: reload URL for distant Hanlders
-  **all**: parameters for all modules
-  **portal**: parameters only for Portal
-  **manager**: parameters only for Manager
-  **handler**: parameters only for Handler

When you set a parameter in ``lemonldap-ng.ini``, it will override the
parameter from the global configuration.

For example, to override configured skin for portal:

.. code-block:: ini

   [portal]
   portalSkin = dark


.. tip::

    You need to know the technical name of configuration parameter
    to do this. You can refer to :doc:`parameter list<parameterlist>` to
    find it.
