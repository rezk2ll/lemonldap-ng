Events management
=================

LemonLDAP::NG has two kinds of events to propagate between its nodes:

* configuration updates
* session logout

By default, events aren't really propagated but a timer permits to refresh
such data.

Starting from version 2.20.0, LLNG adds a **PUB/SUB** system *(not enabled by default)*
to replace this timers.

Default events system
---------------------

Session reload
~~~~~~~~~~~~~~

The default LLNG cache system keeps in memory sessions during 10mn, sessions
are automatically refreshed after this delay.

Configuration reload
~~~~~~~~~~~~~~~~~~~~

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

Using a Pub/Sub system
----------------------

The message broker system replaces the previous system using an external
**Pub/Sub** system. For now, only Redis can be used here.

When enabled, all LLNG process subscribe to ``llng_events`` channel which
propagate "orders":

* configution update *(``checkConf``)*
* logouts *(``unlog``)*

Such *orders* are  read every 5 seconds, then logout and configuration updates
are propagated in this delay.


Configuration
~~~~~~~~~~~~~

In "General Parameters » Advanced parameters » Events Management", set
**Pub/Sub** system to ``::Redis`` *(which is an abbreviation of
``Lemonldap::NG::Common::MessageBroker::Redis``)*.

Then set into "**Pub/Sub system options**" the `Redis`_ options.

Example:

.. code-block:: perl

   server => "redis.example.com:3456"


.. _Redis: https://metacpan.org/pod/Redis
