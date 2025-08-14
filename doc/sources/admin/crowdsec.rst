CrowdSec
========

Presentation
------------

`CrowdSec <https://crowdsec.net>`__ is a free and open-source security
automation tool leveraging local IP behavior detection and a
community-powered IP reputation system.

LL::NG provides two **Crowdsec** plugins:

* a :ref:`Bouncer` that can reject CrowdSec banned IP requests or just provide
  an environment variable that can be used inanother plugin rule. For example,
  a second factor may be required if user'si IP is CrowdSec banned.
* an :ref:`Agent` that push alerts to Crowdsec server and ban IP addresses if
  limits are reached:

  * for each authentication failure
  * if filters are set, for each filter alert (see :ref:`Filters<Agent>`)

You can also find **CrowdSec** agents in `CrowdSec hub <https://hub.crowdsec.net>`__.

Configuration
-------------

.. important::

   If you need to whitelist something, you can use a rule in "activation" using
   ``$env->{REMOTE_ADDR}`` for example.

.. _Bouncer:

Bouncer
~~~~~~~

To configure bouncer plugin, go in ``General Parameters`` > ``Advanced Parameters`` > ``Security`` > ``CrowdSec`` > ``Bouncer``.

You can then configure:

- **Activation**: enable this plugin *(default: disabled)*
- **Ignore CrowdSec failures**: avoid to block user in case of CrowdSec error *(default: disabled)*
- **Action**: reject **or** warn and set ``$env->{CROWDSEC_REJECT} = 1``
- **Base URL of local API**: base URL of CrowdSec local API
  *(default: http://localhost:8080)*
- **API key**: API key, usually given by ``cscli bouncers add mylemon``

.. _Agent:

Agent
~~~~~

To configure agent plugin, go in ``General Parameters`` > ``Advanced Parameters`` > ``Security`` > ``CrowdSec`` > ``Agent``.

You can then configure:

- **Activation**: enable this plugin *(default: disabled)*
- **Crowdsec agent ID**: machine_id registered in Crowdsec local server
- **Password**: password
- **Max failures allowed during delay**: maximume failures allowed in the delay.
  If reached, the plugin will send a Crowdsec decision *(ban)*. 0 means that
  no ban decision will be pushed
- **Check delay**: number of seconds to consider failures. Default: 180
- **Filters directory**: directory where Crowdsec can find its filters. If
  not defined or empty, filters are disabled. See :ref:`Filters`

Note that:

- Agent just push alerts, it never block anything. You must enable **Bouncer** to do this
- **Base URL of local API** has to be configured into ``Bouncer``.

.. _Filters:

Filters
^^^^^^^

When this feature is enabled, the **CrowdsecAgent** plugin parse the directory
given in **Filters directory** to find files. A file must refer to:

* a :ref:`category<Categories>`
* a :ref:`type<Formats>`

The category is the scope of the filter *(example: "url")* and the type is the
format of the file *(example: "txt")*.
The type is the suffix of the file, there are two ways to define the category:
either by setting the category as second suffix in the main directory, either
by storing the file into a subdirectory with a name starting by the category.
Examples:

- ``bad.url.txt`` is a file formatted as "txt" and owned by category "url"
- ``url1/bad.re`` is a file formatted as "re" and owned by category "url"

.. _Formats:

**Formats**
***********

* **txt**: list of substring
* **re**: list of regular expression

An empty line or a line started by ``#`` is ignored.

Examples:

* **txt**

  .. code-block::

   phpinfo.php
   config.php
   /.htaccess

* **re**

  .. code-block::

   /php(my|pg|ldap)admin
   \.exe(\?.*)?$

.. _Categories:

**Categories**
**************

* **url**, if the required URI matches a given expression, then:

  * an alert is sent to local Crowdsec server
  * the portal sends a ``404 Not found`` response
