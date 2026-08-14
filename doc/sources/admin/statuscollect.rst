Use message broker to collect LemonLDAP::NG status
==================================================

LemonLDAP::NG includes a system to use a message broker to dispatch its events between nodes.
It can also be used to collect LemonLDAP::NG status.

Note that LemonLDAP::NG only push statuses, you have to use another software to collect
and exploit them.

Configuration
~~~~~~~~~~~~~

First you need to :doc:`enable a message broker <eventsmanagement>`. Then
enable status push into ``lemonldap-ng.ini`` by adding ``eventStatus = 1``
into ``[all]`` section.

Status are then sent to the status queue. By default, its name is ``llng_status``.
To change it, set the chosen name into ``statusQueueName`` parameter.
