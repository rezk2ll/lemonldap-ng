Writing rules and headers
=========================

Lemonldap::NG manage applications by their hostname (Apache's
virtualHosts). Rules are used to protect applications, headers are HTTP
headers added to the request to give datas to the application (for logs,
profiles,...).


.. attention::

    Note that variables designed by $xx correspond to the
    name of the :doc:`exported variables<exportedvars>` or
    :ref:`macro names<macros_and_groups>` except for ``$ENV{<cgi-header>}`` which
    correspond to CGI header (``$ENV{REMOTE_ADDR}`` for example).

Available $ENV variables
------------------------

The %ENV table provides:

-  all headers in CGI format (``User-Agent`` becomes
   ``HTTP_USER_AGENT``)
-  some CGI variables depending on the context:

   -  For portal: all CGI standard variables (you can add custom
      headers using ``fastcgi_param`` with Nginx),
   -  For Apache handler: REMOTE_ADDR, QUERY_STRING, REQUEST_URI,
      SERVER_PORT, REQUEST_METHOD,
   -  For Nginx handler: all variables given by ``fastcgi_param``
      commands.

-  For portal:

   -  $ENV{urldc} : Origin URL before Handler redirection, in cleartext
   -  $ENV{_url} : Origin URL before Handler redirection, base64 encoded

See also :doc:`extended functions<extendedfunctions>`.

.. _rules:

Rules
-----

A rule associates a `regular
expression <http://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions>`__
to a Perl boolean expression or a keyword.

|image0|

Examples:

=============================================================================================================================================== ================== ======================================
Goal                                                                                                                                            Regular expression Rule
=============================================================================================================================================== ================== ======================================
Restrict /admin/ directory to user bart.simpson                                                                                                 ^/admin/
Restrict /js/ and /css/ directory to authenticated users                                                                                        ^/(css|js)/        accept
Deny access to /config/ directory                                                                                                               ^/config/          deny
Do not restrict /public/                                                                                                                        ^/public/          skip
Do not restrict /skip/ and restrict other to authenticated users                                                                                ^/skip/            $ENV{REQUEST_URI} =~ /skip/ ? skip : 1
Makes authentication optional, but authenticated users are seen as such (that is, user data are sent to the app through HTTP headers)           ^/forum/           unprotect
Restrict access to the whole site to users that have the LDAP description field set to "LDAP administrator" (must be set in exported variables) default
=============================================================================================================================================== ================== ======================================

The "**default**" access rule is used if no other access rule match the
current URL.


.. tip::

    See :doc:`the rules examples page<rules_examples>` for a few
    common use cases


.. tip::



    -  Comments can be used to order your rules: rules are applied in the
       alphabetical order of comment (or regexp in there is no comment). See
       :ref:`security chapter<security-write-good-rules>` to learn more
       about writing good rules.
    -  See :ref:`performances<performances-handler-performance>` to know how
       to use macros and groups in rules.


Rules can also be used to intercept logout URL:

================================================================================================================= =================== =====================================
Goal                                                                                                              Regular expression  Rule
================================================================================================================= =================== =====================================
Logout user from Lemonldap::NG and redirect it to http://intranet/                                                ^/index.php\?logout logout_sso http://intranet/
Logout user from current application and redirect it to the menu **(Apache only)**                                ^/index.php\?logout logout_app https://auth.example.com/
Logout user from current application and from Lemonldap::NG and redirect it to http://intranet/ **(Apache only)** ^/index.php\?logout logout_app_sso http://intranet/
================================================================================================================= =================== =====================================


.. danger::

    \ ``logout_app`` and ``logout_app_sso`` rules are not
    available on Nginx, only on Apache.

By default, user will be redirected on portal if no URL defined, or on
the specified URL if any.


.. attention::

    Only current application is concerned by logout_app\*
    targets. Be careful with some applications which doesn't verify
    Lemonldap::NG headers after having created their own cookies. If so, you
    can redirect users to a HTML page that explain that it is safe to close
    browser after disconnect.

Rules based on authentication level
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LLNG set an "authentication level" during authentication process. This
level depends on authentication backend used by this user. Default
values are:

-  0 for :doc:`Null<authnull>`
-  1 for :doc:`CAS<authcas>`, :doc:`old OpenID-2<authopenid>`,
   :doc:`Facebook<authfacebook>`,…
-  2 for web-form based authentication (:doc:`LDAP<authldap>`,
   :doc:`DBI<authdbi>`,…)
-  3 for :doc:`Yubikey<authyubikey>`
-  4 for :doc:`Kerberos<authapache>`
-  5 for :doc:`SSL<authssl>`

There are three ways to impose users a higher authentication level:

-  writing a rule based on authentication level:
   ``$authenticationLevel > 3``
-  since 2.0, set a minimum level in virtual host options (default value
   for ALL access rules)
-  since 2.0.7, a minimum authentication level can be set for each URI
   access rule. Useful if URI are protected by different types of
   handler (AuthBasic -> level 2, Main -> level set by authentication
   backend).


.. tip::

    Instead of returning a 403 code, "minimum level" returns user
    to a form that explain that a higher level is required and propose to
    reauthenticate himself.

.. _headers:

Headers
-------

Headers are associations between an header name and a perl expression
that returns a string. Headers are used to give user data to the
application.

Examples:

============================= ============ =======================
Goal                          Header name  Header value
============================= ============ =======================
Give the uid (for accounting) Auth-User    $uid
Give a static value           Some-Thing   "static-value"
Give display name             Display-Name $givenName." ".$surName
Give a non ascii data         Display-Name
============================= ============ =======================

As described in
:ref:`performances chapter<performances-handler-performance>`, you can
use macros, local macros,...


.. attention::



    -  Since many HTTP servers refuse non ascii headers, it is recommended
       to use encode_base64() function to transmit those headers
    -  Don't forget to add an empty string as second argument to
       encode_base64 function to avoid a "newline" characters insertion in
       result
    -  Header names must contain only letters and "-" character




.. tip::

    By default, SSO cookie is hidden. So protected applications
    cannot retrieve SSO session key. But you can forward this key if
    absolutely needed:

    ::

       Session-ID => $_session_id



Available functions
-------------------

In addition to macros and name, you can use some functions in rules and
headers:

-  :doc:`LLNG extended functions<extendedfunctions>`
-  :doc:`Your custom functions<customfunctions>`

Wildcards in hostnames
----------------------

|image1| Since 2.0, a wildcard can be used in virtualhost name (not in
aliases !): ``*.example.com`` matches all hostnames that belong to
``example.com`` domain. Version 2.0.9 improves this and allows better
wildcards such as ``test-*.example.com`` or ``test-%.example.com``. The
``%`` wilcard doesn't match subdomains.

Even if a wildcard exists, if a virtualhost is explicitly declared, this
rule is applied. Example with precedence order for test.sub.example.com:

#. test.sub.example.com
#. test%.sub.example.com
#. test*.sub.example.com
#. %.sub.example.com
#. \*.sub.example.com
#. \*.example.com (``%.example.com`` does not match
   test.sub.example.com)

.. |image0| image:: /documentation/manager-rule.png
   :class: align-center
.. |image1| image:: /documentation/new.png
   :width: 35px
