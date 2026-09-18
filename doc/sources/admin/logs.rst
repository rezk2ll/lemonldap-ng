Logs
====

Presentation
------------

Main settings:

-  **REMOTE_USER**: session attribute used for logging user access
-  **REMOTE_CUSTOM**: can be used for logging an another user attribute or a macro
   (optional)
-  **Hidden attributes**: session attributes never displayed or sent.

.. versionchanged:: 2.17.0

   Since version 2.17.0 hidden attributes parameter supports regular expressions.
   You can hide attributes by listing them or by providing one or more regexps.
   By example: ``_password, _session_id, /^notification_/ /^real\d+$/  _oidcConsents``

.. attention::

    Regexp must start and end with a slash ``/`` character.

LemonLDAP::NG provides 5 levels of error and has two kinds of logs:

-  technical logs
-  user actions logs

Each category can be handle by a different logging framework. You can
choose between:

-  **Lemonldap::NG::Common::Logger::Std**: standard output (mapped in
   web server logs, see below)
-  **Lemonldap::NG::Common::Logger::Syslog**: syslog logging
-  **Lemonldap::NG::Common::Logger::Apache2**: use Apache2 logging,
   levels are stored in Apache2 logs and the log level is defined by
   ``LogLevel`` Apache parameter
-  **Lemonldap::NG::Common::Logger::Log4perl**: use ``Log4perl``
   framework to log *(inspired by Java Log4J)*
-  **Lemonldap::NG::Common::Logger::Loki**: push logs into a
   `Loki server <https://github.com/grafana/loki#readme>`__
-  **Lemonldap::NG::Common::Logger::Sentry (experimental)**: use
   `Sentry <https://sentry.io>`__ to store logs
-  **Lemonldap::NG::Common::Logger::Dispatch**: dispatch logs in other
   backends depending on log level


.. attention::

    Except for Apache2 and Log4Perl, log level is defined
    by ``logLevel`` parameter set in ``lemonldap-ng.ini`` file. Logger
    configurations are defined in lemonldap-ng.ini.  Example:

.. code-block:: ini

   [all]
   logger     = Lemonldap::NG::Common::Logger::Log4perl
   userLogger = Lemonldap::NG::Common::Logger::Syslog
   logLevel   = notice

You can also modify these values in each lemonldap-ng.ini section to
have different values for portal, manager and handlers.

Therefore, LLNG provides a username that can be used by web servers in
their access logs. To configure the user identifier to write into access
logs, go to Manager, ``General Parameters`` > ``Logging`` >
``REMOTE_USER``.

User log samples
----------------

.. note::

    The user name set in user log messages is set with `whatToTrace` parameter, except
    for messages corresponding to failed authentifications, when the user name logged is the
    login used by the user.

Authentication:

::

   [info] User dwho successfully authenticated at level 2
   [info] User dwho connected from LDAP (81.20.13.21)

Failed authentication:

::

   [warn] foo.bar was not found in LDAP directory (81.20.13.21)
   [warn] Bad password for dwho (81.20.13.21)

Failed authentication with Combination module:

::

   [warn] All schemes failed for user dwho (81.20.13.21)

Logout:

::

   [notice] User dwho has been disconnected from LDAP (81.20.13.21)

Password change:

::

   [notice] Password changed for dwho (81.20.13.21)

Access to a CAS application non registered in configuration (when CAS server is open):

::

   [notice] User dwho is redirected to https://cas.service.url

Access to a CAS application whose configuration key is ``app-example``:

::

   [notice] User dwho is authorized to access to app-example

Access to an SAML SP whose configuration key is ``sp-example``:

::

   [notice] User dwho is authorized to access to sp-example

Access to an OIDC RP whose configuration key is ``rp-example``:

::

   [notice] User dwho is authorized to access to rp-example

Access to a Get application whose vhost configuration key is ``host.example.com``:

::

   [notice] User dwho is authorized to access to host.example.com


Default loggers
---------------

-  Apache handlers use by default Apache2 logger. This logger can not be
   used for other LLNG components
-  Except when launched by LLNG FastCGI server *(used by Nginx)*, Portal
   and Manager use Std logger by default
-  All components launched by LLNG FastCGI server use Syslog by default

Log levels
----------

Technical log levels
~~~~~~~~~~~~~~~~~~~~

-  **error** is used for problems that must be reported to administrator
   and needs an action. In this case, some features may not work
-  **warn** is used for problems that do not block LLNG features but
   should be solved
-  **notice** is used for actions that must be logged
-  **info** displays some technical information
-  **debug** generates lot of debugging logs

Log levels for user actions
~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  **error** is used for logging bad user actions that seem malicious
-  **warn** is used for logging some errors like "bad password"
-  **notice** is used for actions that must be logged for
   accounting (connections, logout and so on)
-  **info** displays some useful information like handler authorizations
   (at least one for each HTTP hit)
-  **debug** not relevant

Logger configuration
--------------------

Std logger
~~~~~~~~~~

Nothing to configure except logLevel.

Apache2 logger
~~~~~~~~~~~~~~

The log level can be set with Apache ``LogLevel`` parameter. It can be
configured globally, or inside a virtual host.

See https://httpd.apache.org/docs/current/mod/core.html#loglevel for more
information.

Syslog
~~~~~~

You can choose facility in lemonldap-ng.ini file. Default values:

.. code-block:: ini

   syslogFacility     = daemon
   userSyslogFacility = auth

You can also override options. Default values:

.. code-block:: ini

   syslogOptions      = cons,pid,ndelay
   userSyslogOptions  = cons,pid,ndelay


.. tip:: You can find more information on Syslog options in
         `Sys::Syslog <https://metacpan.org/pod/Sys::Syslog>`__ Perl
         module.

And you can add additional options. Example to send log to another host:

.. code-block:: ini

   syslogSockOptions = { host => "remote.com", port => 6514 }

See `setlogsock() <https://metacpan.org/pod/Sys::Syslog#setlogsock()>`_ for more.

Log4perl
~~~~~~~~

You can define the Log4perl configuration file and classes to use.
Default values:

.. code-block:: ini

   log4perlConfFile   = /etc/log4perl.conf
   log4perlLogger     = LLNG
   log4perlUserLogger = LLNGuser


Sample ``log4perl.conf`` file

.. code::

    log4perl.logger.LLNG = DEBUG, Syslog
    log4perl.logger.LLNGuser = INFO, Syslog
    log4perl.appender.Syslog = Log::Dispatch::Syslog
    log4perl.appender.Syslog.ident = LLNG
    log4perl.appender.Syslog.layout = PatternLayout
    log4perl.appender.Syslog.layout.ConversionPattern = [%p] %m

For additional information, please read the `Log4Perl documentation <https://metacpan.org/pod/Log::Log4perl>`__

.. versionadded:: 2.0.14

    The following special formatters have been added to standard `PatternLayout placeholders <https://metacpan.org/pod/Log::Log4perl::Layout::PatternLayout>`__

* ``%Q{address}``: IP address of the request
* ``%Q{user}``: Username of the current user
* ``%Q{id}``: Session ID of the current user
* ``%E{ENV_VAR}``: content of the ``ENV_VAR`` variable

.. versionadded:: 2.17

* ``%S{mail}``: content of the ``mail`` session variable

.. versionadded:: 2.19

* ``%Q{request_id}``: Unique request ID, from ``UNIQUE_ID`` environment
  variable, or generated by LemonLDAP::NG if ``UNIQUE_ID`` is not found.


.. versionadded:: 2.21.0

Loki
~~~~

Here are the configuration parameters with their default values:

===================== ================================================================================================================================================= ==========================================
Parameter             Comment                                                                                                                                           Default value
===================== ================================================================================================================================================= ==========================================
``lokiUrl``           URL of Loki API                                                                                                                                   ``http://localhost:3100/loki/api/v1/push``
``lokiLabel``         Value of ``label`` field                                                                                                                          ``llng``
``lokiInstance``      Value of ``instance`` field                                                                                                                       *(hostname command result)*
``lokiEnv``           Value of ``env`` field                                                                                                                            ``prod``
``lokiService``       Value of "service" when used as technical logger                                                                                                  ``llng``
``lokiUserService``   Value of "service" when used as userLogger                                                                                                        ``auth``
``lokiTenant``        Used to populate ``X-Scope-OrgID`` header
``lokiTenantHeader``  Used to change default tenant header                                                                                                              ``X-Scope-OrgID``
``lokiAuthorization`` Set here the whole value to put in the ``Authorization`` header. For example: ``Basic dXNlcjpwYXNzd29yZA==`` *(Base64 encoding of user:password)*
``lokiDeferDir``      Temporary directory to store logs (see :ref:`async options <async-opts>`)
``lokiProxy``         Buffer-Proxy to be used (see :ref:`async options <async-opts>`)
===================== ================================================================================================================================================= ==========================================

Is it recommended to combine this logger with the :ref:`auditLogger <auditlogs>`
"``Lemonldap::NG::Common::AuditLogger::UserLoggerJSON``" to have useful logs
for Grafana. Example of ``lemonldap-ng.ini`` file:

.. code-block:: ini

   [ all ]
   logger      = Lemonldap::NG::Common::Logger::Loki
   auditLogger = Lemonldap::NG::Common::AuditLogger::UserLoggerJSON
   lokiUrl     = http://10.1.2.3/loki/api/v1/push


.. _async-opts:

Async options
^^^^^^^^^^^^^

.. attention::

    This logger uses synchronous process, so it can cause latency in
    heavily loaded systems. To avoid this, you can use an asynchronous
    mechanism.

LLNG proposes 2 options:

* use a :ref:`transitional directory to store logs formated for Loki<lokideferdir>`.

* use a :ref:`reverse-proxy that will bufferize messages<lokiproxy>`.

.. _lokideferdir:

**Using a transitional directory**
""""""""""""""""""""""""""""""""""

When option ``lokiDeferDir`` is set, the Loki logger no more send directly logs
to Loki API but write them into this transitional directory. You can use the
`lokiSender <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/blob/v2.0/lemonldap-ng-common/eg/lokiSender>`_
program to pick logs from the transitional directory and push then to Loki
API. It can be used as daemon or as cron task.

.. _lokiproxy:

**Using a custom reverse-proxy**
""""""""""""""""""""""""""""""""

When using ``lokiProxy`` optiion, Loki logger simply send Loki requests to this
URL instead of using ``lokiUrl`` value but keeps ``Host`` header. This permits
one to write a simple proxy, faster than loki API which will group message to
send them asynchronously.

Sentry
~~~~~~

You just have to give your DSN:

.. code-block:: ini

   sentryDsn = https://...


.. attention::

    This experimental logger requires
    `Sentry::Raven <https://metacpan.org/pod/Sentry::Raven>`__ Perl
    module.

Dispatch
~~~~~~~~

Use it to enable more than one logger. Example:

.. code-block:: ini

   logger               = Lemonldap::NG::Common::Logger::Dispatch
   userLogger           = Lemonldap::NG::Common::Logger::Dispatch
   logDispatchError     = Lemonldap::NG::Common::Logger::Sentry
   logDispatchNotice    = Lemonldap::NG::Common::Logger::Syslog
   userLogDispatchError = Lemonldap::NG::Common::Logger::Sentry
   ; Other parameters
   syslogFacility    = daemon
   sentryDsn         = https://...


.. attention::

    At least ``logDispatchError`` (or     ``userLogDispatchError`` for user logs)
    must be defined. All sub level will be dispatched on it,
    until another lever is declared. In the above example,
    Sentry collects ``error`` and ``warn`` levels and all user
    actions, while syslog stores technical ``notice``, ``info`` and ``debug`` logs.


.. _webserverlogs:

Webserver logs
--------------

The Apache or Nginx webserver has also the capacity to log the user access to resources.

Depending on the load trafic, you should enable such logs for accountability reasons.

If using Nginx, it consists in adding this line in ``portal-nginx.conf`` virtual host:

.. code-block:: nginx

    access_log /var/log/nginx/portal.log lm_app;

and this line in all handler virtual hosts (for example in ``test-nginx.conf``):

.. code-block:: nginx

    access_log /var/log/nginx/access.log lm_combined;

Take care to ensure that the ``log_format`` parameter is already defined before. Usually, it is declared in ``nginx-lmlog.conf``, loaded by ``handler-nginx.conf``:

.. code-block:: nginx

    include /etc/lemonldap-ng/nginx-lmlog.conf;

For more information, read the :doc:`Configuration overview<configlocation>`.


.. _auditlogs:

Audit logs
----------

.. versionadded:: 2.19

|beta| This feature may change in a future version, event codes and format should not be considered stable.

LemonLDAP::NG user logs (see above) are being replaced with a new facility: :ref:`auditlogs`.

Audit logs are structured logs that are meant to be easier to process than the current log messages.

At the moment, audit logs are transmitted by default to the configured
``userLogger``. But you can plug-in your own custom implementation.

.. code:: ini

    auditLogger=My::Logger::Class

Your logger class can look something like this:

.. code:: perl

    package My::Logger::Class;
    use Scalar::Util qw(weaken);

    sub new {
        my ( $class, $psgi_or_handler ) = @_;
        my $self = bless {}, $class;

        # Populate $self with options read from $psgi_or_handler
        # ...

        return $self;
    }

    sub log {
        my ( $self, $req, %fields ) = @_;

        # Your logging actions here. %fields is the structured
        # data from the logging context, which you can enrich with
        # data from the HTTP request ($req).
        # The "code" field generally contains an upper case event code such as
        # AUTHENTICATED or 2FA_REQUIRED

        # my $code = $fields{code};
        # ...
    };

    1;

.. |beta| image:: /documentation/beta.png
