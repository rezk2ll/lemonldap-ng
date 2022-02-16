Logs
====

Presentation
------------

Main settings:

-  **REMOTE_USER**: session attribute used for logging user access
-  **REMOTE_CUSTOM**: can be used for logging an another user attribute or a macro
   (optional)
-  **Hidden attributes**: session attributes never displayed or sent

LemonLDAP::NG provides 5 levels of error and has two kind of logs:

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

Therefore, LLNG provides a username that can be used by webservers in
their access log. To configure the user identifier to write into access
logs, go into Manager, ``General Parameters`` > ``Logging`` >
``REMOTE_USER``.

User log samples
----------------

.. note::

    The user name set in user log messages is configured with `whatToTrace` parameter, except
    for messages corresponding to failed authentification, whe the user name logged is the
    login used by the user.

Authentication:

::

   [notice] Session granted for dwho by LDAP (81.20.13.21)
   [notice] User dwho.com successfully authenticated at level 2
   [notice] dwho connected

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

-  Apache handlers use by default Apache2 logger. This logger can't be
   used for other LLNG components
-  Except when launched by LLNG FastCGI server *(used by Nginx)*, Portal
   and Manager use Std logger by default
-  All components launched by LLNG FastCGI server use Syslog by default

Log levels
----------

Technical log levels
~~~~~~~~~~~~~~~~~~~~

-  **error** is used for problems that must be reported to administrator
   and needs an action. In this case, some feature may not work
-  **warn** is used for problems that doesn't block LLNG features but
   should be solved
-  **notice** is used for actions that must be kept in logs
-  **info** display some technical information
-  **debug** produce a lot a debugging logs

Log levels for user actions
~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  **error** is used to log bad user actions that looks malicious
-  **warn** is used to log some errors like "bad password"
-  **notice** is used for actions that must be kept in logs for
   accounting (connections, logout)
-  **info** display some useful information like handler authorizations
   (at least 1 for each HTTP hit)
-  **debug** isn't used

Logger configuration
--------------------

Std logger
~~~~~~~~~~

Nothing to configure except logLevel.

Apache2 logger
~~~~~~~~~~~~~~

The log level can be set with Apache ``LogLevel`` parameter. It can be
configured globally, or inside a virtual host.

See http://httpd.apache.org/docs/current/mod/core.html#loglevel for more
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

Log4perl
~~~~~~~~

You can indicate the Log4perl configuration file and the classes to use.
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

Use it to use more than one logger. Example:

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

    At least ``logDispatchError`` (or
    ``userLogDispatchError`` for user logs) must be defined. All sub level
    will be dispatched on it, until another lever is declared. In the above
    example, Sentry collects ``error`` and ``warn`` levels and all user
    actions, while syslog stores technical ``notice``, ``info`` and
    ``debug`` logs.
