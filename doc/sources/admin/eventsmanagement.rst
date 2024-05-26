Events management
=================

LemonLDAP::NG has two kinds of events to propagate between its nodes:

* configuration updates
* session logout

By default, events aren't really propagated but a timer permits to refresh
such data.

Starting from version 2.20.0, LLNG adds a :ref:`PUB/SUB system<PubSub>` *(not enabled by default)*
to replace this timers..

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

.. _PubSub:

Using a Pub/Sub system
----------------------

The message broker system replaces the previous system using an external
**Pub/Sub** system. For now, only Redis and Pg *(PostgreSQL)* can be used here.

When enabled, all LLNG process subscribe to ``llng_events`` channel which
propagate "orders":

* configution update (``checkConf``)
* logouts (``unlog``)

Such *orders* are  read every 5 seconds, then logout and configuration updates
are propagated in this delay.

To configure this, go into "General Parameters » Advanced parameters » Events Management"
and set **Pub/Sub** system to :ref:`Redis<PubSubRedis>`, :ref:`PostgreSQL<PubSubPg>` or
:ref:`MQTT<PubSubMQTT>`.

Then set into "**Pub/Sub system options**" the needed options depending on the
chosen system *(see below)*.

.. note::

   The corresponding parameter inside ``lemonldap-ng.ini`` is ``messageBroker``
   which takes as value: ``::Redis`` or ``::Pg`` or ``::MQTT``
   (which are abbreviations of ``Lemonldap::NG::Common::MessageBroker::<name>``).

   Options take place into ``messageBrokerOptions`` parameter.

.. _PubSubRedis:

Redis
~~~~~

See `Redis`_ options,

Example:

.. code-block:: perl

   server => "redis.example.com:3456"

.. _PubSubPg:

PostgreSQL
~~~~~~~~~~

The following parameters are needed:
* ``dbiChain``: see `DBD::Pg`_ to know the syntax
* ``dbiUser``: the username to use to connect
* ``dbiPassword``: the password to use to connect

Example:

.. code-block:: perl

   dbiChain    => "dbi:Pg:dbname=llng;host=localhost;port=54432",
   dbiUser     => "llng",
   dbiPassword => "llng",

.. _PubSubMQTT:

MQTT
~~~~

The following parameter can be set:

* ``server`` *(default: ``localhost:1883``)*
* ``ssl``: set to 1 if SSL is available. Remember then to install `IO::Socket::SSL`_ (`libio-socket-ssl-perl`_ on Debian).

If ``ssl`` is set then these parameters are allowed:

* ``user``: usernane to use for login
* ``password``: password to use for login
* ``SSL_ca_file``: file with certificate authorities *(PEM encoded)*
* ``SSL_cert_file``: client certificate
* ``SSL_key_file``: client private key

If ``ssl`` is set then these environment variables can be used also:

* ``MQTT_SIMPLE_SSL_INSECURE``: Set to something other than 0 to disable SSL validation
* ``MQTT_SIMPLE_SSL_CA``: Path to the CA certificate or a directory of certificates. `IO::Socket::SSL`_ can find the CA path automatically on some systems.
* ``MQTT_SIMPLE_SSL_CERT``: Path to the client certificate file.
* ``MQTT_SIMPLE_SSL_KEY``: Path to the client private key file.

.. _Redis: https://metacpan.org/pod/Redis

.. _`DBD::Pg`: https://metacpan.org/pod/DBD::Pg
.. _`IO::Socket::SSL`: https://metacpan.org/pod/IO::Socket::SSL
.. _`libio-socket-ssl-perl`: https://packages.debian.org/stable/libio-socket-ssl-perl
