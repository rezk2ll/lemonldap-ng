Web Cron plugin
===============

This plugin can be used to replace cron tasks by API calls.

Configuration
-------------
To enable Web Cron:
Go in Manager, ``General Parameters`` » ``Plugins`` » ``Web Cron``.
You must set a shared secret.

Usage
-----

When enabled, portal exposes ``/webcron/purge`` and ``/webcron/localpurge`` API.
GET *(or POST)* parameters:

============= ======== ============================================================
GET Parameter Need     Value
============= ======== ============================================================
``secret``    required Same value as the shared secret given to the manager
============= ======== ============================================================

Response
--------

The plugin will respond to the HTTP request with:

* HTTP code 500 if something went wrong
* HTTP code 200 and the following JSON content if everything went right

.. code:: json

    {"result":1,"err":0}

.. versionadded:: 2.22.0

Example
~~~~~~~

-  Clean central database:
   ``curl -XPOST --data-urlencode 'secret=qwerty' https://auth.example.com/webcron/purge``
-  Clean local cache:
   ``curl -XPOST --data-urlencode 'secret=qwerty' https://auth.example.com/webcron/localpurge``
