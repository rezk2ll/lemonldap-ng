Events management
=================

LemonLDAP::NG has two kinds of events to propagate between its nodes:

* configuration updates
* session logout

By default, events aren't really propagated but a timer permits to refresh
such data.

Starting from version 2.20.0, LLNG adds an **optional** :ref:`PUB/SUB system<PubSub>`
*(not enabled by default)* to replace this timers. This isn't useful in classic
deployments but may help big ones.

Default events system
---------------------

Session reload
~~~~~~~~~~~~~~

The default LLNG cache system keeps in memory sessions during 10mn, sessions
are automatically refreshed after this delay.

Configuration reload
~~~~~~~~~~~~~~~~~~~~

After configuration is saved by Manager, LemonLDAP::NG will automatically
reload the configuration after a few seconds.

The reload will happen next time a request is processed if more than
``checkTime`` (default: 1) and ``checkMsg`` (default: 5) seconds have passed
since the last check.

.. _PubSub:

Using a Pub/Sub system
----------------------

The message broker system replaces the previous system using an external
**Pub/Sub** system.

When enabled, all LLNG process subscribe to ``llng_events`` channel which
propagate "events":

* configution update (``newConf``)
* logouts (``unlog``)

Such messages are  read every 5 seconds, then logout and configuration updates
are propagated in this delay. To modify this delay *(10 seconds for example)*,
set `checkMsg=10` inside ``lemonldap-ng.ini``, section ``[all]``.

To configure the event system, go into "General Parameters » Advanced parameters » Events Management"
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

   server => "redis.example.com:6379"

.. _PubSubPg:

PostgreSQL
~~~~~~~~~~

The following parameters are needed:

* ``dbiChain``: see `DBD::Pg`_ to know the syntax
* ``dbiUser``: the username to use to connect
* ``dbiPassword``: the password to use to connect

Example:

.. code-block:: perl

   dbiChain    => "dbi:Pg:dbname=llng;host=localhost;port=5432",
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

Web
~~~

LLNG provide a light pub/sub server, named **llng-pubsub-server**, designed to be
used to manage LLNG events.

To use it, configure the message broker:

* ``server`` *(default: ``localhost:8080``)*. To enable SSL, use ``https://server:port``
* ``token``: optional token to be set if the server requires a token

You can find **llng-pubsub-server** documentation into its manpage.
