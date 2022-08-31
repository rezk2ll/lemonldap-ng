Security recommendation
=======================

Secure configuration access
---------------------------

Configuration can be stored in several formats
(:doc:`SQL<sqlconfbackend>`, :doc:`File<fileconfbackend>`,
:doc:`LDAP<ldapconfbackend>`) but must be shared over the network if you
use more than 1 server. If some of your servers are not in the same
(secured) network than the database, it is recommended to use
:doc:`SOAP access<soapconfbackend>` for those servers.


.. tip::

    You can use different type of access:
    :doc:`SQL<sqlconfbackend>`, :doc:`File<fileconfbackend>` or
    :doc:`LDAP<ldapconfbackend>` for servers in secured network and
    :doc:`SOAP<soapconfbackend>` for remote servers.

Next, you have to configure the SOAP access as described
:ref:`here<soapconfbackend-next-configure-soap-for-your-remote-servers>`
since SOAP access is denied by default.

Protect the Manager
-------------------

By default, the manager is restricted to the user 'dwho' (default
backend is Demo). To protect the manager, you have to choose one or both
of :

-  protect the manager by Apache configuration
-  protect the manager by LL::NG

Protect the Manager by the web server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can use any of the mechanisms proposed by Apache: SSL, Auth-Basic,
Kerberos,... Example

.. code-block:: apache

   <VirtualHost *:443>
       ServerName manager.example.com
       # SSL parameters
       ...
       # DocumentRoot
       DocumentRoot /var/lib/lemonldap-ng/manager/
       <Location />
           AuthType Basic
           AuthName "Lemonldap::NG manager"
           AuthUserFile /usr/local/apache/passwd/passwords
           Require user rbowen
           Order allow,deny
           Deny from all
           Allow from 192.168.142.0/24
           Options +ExecCGI
       </Location>
   </VirtualHost>

Protect the Manager by LL::NG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To protect the manager by LL::NG, you just have to set this in
``lemonldap-ng.ini`` configuration file (section [manager]):

.. code-block:: ini

   [manager]
   protection = manager


.. attention::

    Before, you have to create the virtual host
    ``manager.your.domain`` in the manager and set a
    :ref:`rule<rules>`, else access to the manager will
    be denied.


.. _security-portal:

Portal
------

LLNG portal now embeds the following features:

-  `CSRF <https://en.wikipedia.org/wiki/Cross-site_request_forgery>`__
   protection *(Cross-Site Request Forgery)*: a token is build for each
   form. To disable it, set '​require Token for forms' ​to Off *(portal
   security parameters in the manager)*. Token timeout can be defined
   via manager (default to 120 seconds)
-  `Brute-force
   attack <https://en.wikipedia.org/wiki/Brute-force_attack>`__
   protection: after some failed logins, user must wait before re-try to
   log into Portal
-  `Content-Security-Policy <https://en.wikipedia.org/wiki/Content_Security_Policy>`__
   header: portal builds dynamically this header. You can modify default
   values in the manager *(General parameters » Advanced parameters »
   Security » Content-Security-Policy)*
-  `Cross-Origin Resource
   Sharing <https://en.wikipedia.org/wiki/Cross-origin_resource_sharing>`__
   headers: CORS is a mechanism that allows restricted resources on a
   web page to be requested from another domain outside the domain from
   which the first resource was served. A web page may freely embed
   cross-origin images, stylesheets, scripts, iframes, and videos.
   Certain "cross-domain" requests, notably Ajax requests, are forbidden
   by default by the same-origin security policy. You can modify default
   values in the manager *(General parameters » Advanced parameters »
   Security » Cross-Origin Resource Sharing)*


.. attention::



    -  Brute-force attack protection is DISABLED by default
    -  Browser implementations of formAction directive are inconsistent
       (e.g. Firefox doesn't block the redirects whereas Chrome does).
       Administrators may have to modify formAction value with wildcard
       likes ``*``.



Split portal when using SOAP/REST
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you use :doc:`SOAP<soapsessionbackend>` or
:doc:`REST<restsessionbackend>` session backend, dedicate a portal
especially for these internal requests.

.. _security-write-good-rules:

Write good rules
----------------

Order your rules
~~~~~~~~~~~~~~~~

:ref:`Rules<rules>` are applied in alphabetical order
(comment and regular expression). The first matching rule is applied.


.. attention::

    The "default" rule is only applied if no other rule
    matchs

The Manager let you define comments in rules, to order them:

|image0|

For example, if these rules are used without comments:

================== ============== =======
Regular expression Rule           Comment
================== ============== =======
^/pub/admin/       $uid eq "root"
^/pub/             accept
================== ============== =======

Then the second rule will be applied first, so every authenticated user
will access to ``/pub/admin`` directory.

Use comment to correct this:

================== ============== =======
Regular expression Rule           Comment
================== ============== =======
^/pub/admin/       $uid eq "root" 1_admin
^/pub/             accept         2_pub
================== ============== =======


.. tip::



    -  Reload the Manager to see the effective order
    -  Use rule comments to order your rules



Be careful with URL parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can write :ref:`rules<rules>` matching any
component of URL to protect including GET parameters, but be careful.

For example with this rule on the ``access`` parameter:

=============================== ========================== =======
Regular expression              Rule                       Comment
=============================== ========================== =======
``^/index.php\?.*access=admin`` ``$groups =~ /\badmin\b/``
``default``                     ``accept``
=============================== ========================== =======

Then a user that try to access to one of the following will be granted !

-  ``/index.php?access=admin&access=other``
-  ``/index.php?Access=admin``

You can use the following rules instead:

===================================== ========================== =======
Regular expression                    Rule                       Comment
===================================== ========================== =======
``^/(?i)index.php\?.*access.*access`` ``deny``                   0_bad
``^/(?i)index.php\?.*access=admin``   ``$groups =~ /\badmin\b/`` 1_admin
``default``                           ``accept``
===================================== ========================== =======


.. tip::

     **(?i)** means case no sensitive.


.. danger::

    Remember that rules written on GET parameters must be
    tested.

Encoded characters
~~~~~~~~~~~~~~~~~~

Some characters are encoded in URLs by the browser (such as space,...).
To avoid problems, LL::NG decode them using
https://metacpan.org/pod/Apache2::URI#unescape_url. So write your rules
using normal characters.

IP in rules
~~~~~~~~~~~


.. danger::

    If you are running LemonLDAP::NG behind a reverse proxy,
    make sure you check the
    :doc:`Reverse Proxy how-to<behindproxyminihowto>` so that the rule
    applies to the real user IP and not the reverse proxy's IP. Make sure
    you only specify trusted proxy addresses so that an attacker cannot
    forge the ``X-Forwarded-For`` header

.. _security-reverseproxies:

Secure reverse-proxies
----------------------

LL::NG can protect any Apache hosted application including Apache
reverse-proxy mechanism. Example:

.. code-block:: apache

   PerlOptions +GlobalRequest
   PerlRequire /var/lib/lemonldap-ng/handler/MyHandler.pm
   <VirtualHost *:443>
       SSLEngine On
       ... other SSL parameters ...
       PerlInitHandler My::Handler
       ServerName appl1.example.com
       ProxyPass / http://hiddenappl1.example.com/
       ProxyPassReverse / http://hiddenappl1.example.com/
       ProxyPassReverseCookieDomain / http://hiddenappl1.example.com/
   </VirtualHost>

See `mod_proxy <http://httpd.apache.org/docs/2.2/mod/mod_proxy.html>`__
and
`mod_rewrite <http://httpd.apache.org/docs/2.2/mod/mod_rewrite.html>`__
documentation for more about configuring Apache reverse-proxies.

Such configuration can have some security problems:

-  if a user can access directly to the hidden application, it can
   bypass LL::NG protection
-  if many hidden applications are on the same private network, if one
   is corrupted (by SQL injection, or another attack), the hacker will
   be able to access to other applications without using reverse-proxies
   so it can bypass LL::NG protection

It is recommended to secure the channel between reverse-proxies and
application to be sure that only request coming from the LL::NG
protected reverse-proxies are allowed. You can use one or a combination
of:

-  firewalls (but be careful if more than 1 server is behind the
   firewall)
-  server based restriction (like Apache "allow/deny" mechanism)
-  SSL client certificate for the reverse-proxy (see SSLProxy\*
   parameters in `mod_ssl
   documentation <http://httpd.apache.org/docs/2.2/mod/mod_ssl.html>`__)

.. _security-configure-security-settings:

Configure security settings
---------------------------

Go in Manager, ``General parameters`` » ``Advanced parameters`` »
``Security``:

-  **Username control**: Regular expression used to check user login
   syntax.
-  **Avoid browsers to store users password**: Enable this option to
   prevent browsers from prompting users to save passwords.
-  **Force authentication**: set to 'On' to force authentication when
   user connects to portal, even if he has a valid session.
-  **Force authentication interval**: time interval (in seconds) when an
   authentication renewal cannot be forced, used to prevent to loose the
   current authentication during the main process. If you experience
   slow network performances, you can increase this value.
-  **Encryption key**: key used for crypting some data, should not be known
   by other applications
-  **Trusted domains**: domains on which the user can be redirected
   after login on portal.

   -  Example: ``myapp.example.com .subdomain.example.com``
   -  ``*`` allows redirections to any external domain (DANGEROUS)

-  **Use Safe jail**: set to 'Off' to disable Safe jail. Safe module is
   used to eval expressions in headers, rules, etc. Disabling it can
   lead to security issues.
-  **Avoid assignment in expressions**: Set to 'Off' to disable syntax checking.
   Equal sign can be replaced by \x3D i.e. "dc\x3Dorg"
-  **Check XSS Attacks**: Set to 'Off' to disable XSS checks. XSS checks
   will still be done with warning in logs, but this will not prevent
   the process to continue.
-  **Required token for forms**: To prevent CSRF attack, a token is
   build for each form. To disable it, set this parameter to 'Off' or
   set a special rule
-  **Form timeout**: Form token timeout (default to 120 seconds)
-  **Use global storage**: Local cache is used by default for one time
   tokens. To use global storage, set it to 'On'
-  **Strict-Transport-Security Max-age**: set STS header max-age if you use SSL only (by example: 15768000)
-  **CrowdSec Bouncer**: set to 'On' to enable :doc:`CrowdSec Bouncer plugin<crowdsec>`
-  **Brute-Force Attack protection**: set to 'On' to enable :doc:`Brute-force protection plugin<bruteforceprotection>`
-  **LWP::UserAgent and SSL options**: insert here options to pass to
   LWP::UserAgent object (used by SAML or OpenID-Connect to query
   partners and AuthSSL or AuthBasic handler to request Portal URL).
   Example: ``verify_hostname => 0``, ``SSL_verify_mode => 0``
-  **Content Security Policy**: Portal builds dynamically this header.
   You can modify default values. Browser implementations of formAction
   directive are inconsistent (e.g. Firefox doesn't block the redirects
   whereas Chrome does). Administrators may have to modify
   ``formAction`` value with wildcard likes \*.
-  **Cross-Origin Resource Sharing**: Portal builds those headers. You
   can modify default values. Administrators may have to modify
   ``Access-Control-Allow-Origin`` value with ' '.


.. attention::

    If URLs are protected with AuthBasic handler, you have
    to disable CSRF token by setting a special rule based on callers IP
    address like this :

    requireToken => $env->{REMOTE_ADDR} && $env->{REMOTE_ADDR} !~ /^127\.0\.[1-3]\.1$/

.. danger::

    Enable global storage for one time tokens will downgrade
    Portal performance!!!

    Must ONLY be use with outdated or low performance Load Balancer.

Fail2ban
--------

To prevent brute force attack with fail2ban

Edit /etc/fail2ban/jail.conf

::

   [lemonldap-ng]
   enabled = true
   port    = http,https
   filter  = lemonldap
   action   = iptables-multiport[name=lemonldap, port="http,https"]
   logpath = /var/log/apache*/error*.log
   maxretry = 3

and edit /etc/fail2ban/filter.d/lemonldap.conf

::

   # Fail2Ban configuration file
   #
   # Author: Adrien Beudin
   #
   # $Revision: 2 $
   #

   [Definition]

   # Option:  failregex
   # Notes.:  regex to match the password failure messages in the logfile. The
   #          host must be matched by a group named "host". The tag "<HOST>" can
   #          be used for standard IP/hostname matching and is only an alias for
   #          (?f{4,6}:)?(?P<host>[\w\-.^_]+)
   # Values:  TEXT
   #
   failregex = Lemonldap\:\:NG \: .* was not found in LDAP directory \(<HOST>\)
               Lemonldap\:\:NG \: Bad password for .* \(<HOST>\)

   # Option:  ignoreregex
   # Notes.:  regex to ignore. If this regex matches, the line is ignored.
   # Values:  TEXT
   #
   ignoreregex =

Restart fail2ban

Sessions identifier
-------------------

You can change the module used for sessions identifier generation. To
do, add ``generateModule`` key in the configured session backend
options.

We recommend to use :
``Lemonldap::NG::Common::Apache::Session::Generate::SHA256``.

SAML
----

See
:ref:`samlservice#security_parameters<samlservice-security-parameters>`

.. |image0| image:: /documentation/manager-rule.png
   :class: align-center

