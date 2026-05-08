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
  a second factor may be required if user'si IP is CrowdSec banned
* an :ref:`Agent` that push alerts to Crowdsec server and ban IP addresses if
  limits are reached:

  * for each authentication failure *(Crowdsec scenario: llng/badcredentials)*
  * if filters are set, for each filter alert, see :ref:`Filters<Agent>`
    *(Crowdsec scenario: llng/urlscan)*

You can also find **CrowdSec** agents to parse webserver logs in
`CrowdSec hub <https://hub.crowdsec.net>`__.

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
- **Max failures allowed during delay**: maximum failures allowed in the delay.
  If reached, the plugin will send a CrowdSec decision *(ban)*. 0 means that
  no ban decision will be pushed
- **Check delay**: number of seconds to consider failures. Default: 180
- **Ban duration**: duration of the ban decision sent to CrowdSec
  *(default: 4h)*. Accepts CrowdSec duration format (e.g. 4h, 1d, 30m)
- **Filters directory**: directory where Crowdsec can find its filters. If
  not defined or empty, filters are disabled. See :ref:`Filters`
- **Ban response code**: code for rejections based on filters *(default: 404)*
- **Ban response content**: override the content of rejection responses

Note that:

- Agent pushes alerts to CrowdSec. When the maximum failures threshold is
  reached, it also pushes a ban decision that will be immediately available
  to the **Bouncer**
- You must enable **Bouncer** to block banned IPs
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
by storing the file into a subdirectory named with the category followed by a
separator (``_``, ``-`` or space) and an optional description, or exactly the
category name. Examples:

- ``bad.url.txt`` is a file formatted as "txt" and owned by category "url"
- ``url_scanner/bad.re`` is a file formatted as "re" and owned by category "url"
- ``urlskip-icons/icons.re`` is a file formatted as "re" and owned by category "urlskip"

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

  * an alert is sent to local Crowdsec server *(scenario: llng/urlscan)*
  * the portal sends a ``404 Not found`` response

* **urlskip**, whitelisted patterns that won't trigger alerts even if they
  match other categories

.. _Named Scenarios:

**Named Scenarios**
*******************

You can define custom CrowdSec scenarios by creating a subdirectory with a
``.scenario`` file. The ``.scenario`` file contains the scenario name that
will be sent to CrowdSec.

Example structure:

.. code-block::

   crowdsec-filters/
   ├── url/                          # Legacy: uses llng/urlscan
   │   └── bad.txt
   ├── urlskip/                      # Whitelist (no alerts)
   │   └── allowed.txt
   ├── http-sensitive-files/         # Named scenario
   │   ├── .scenario                 # Contains: llng/http-sensitive-files
   │   └── patterns.txt
   └── custom-scenario/              # User-defined scenario
       ├── .scenario                 # Contains: custom/my-scenario
       └── patterns.txt

The ``.scenario`` file should contain a single line with the scenario name,
for example:

.. code-block::

   llng/http-sensitive-files

When a URI matches a pattern in a named scenario directory, the alert sent
to CrowdSec will use this scenario name instead of the default ``llng/urlscan``.

**Per-scenario configuration**

You can override global settings for a specific scenario by adding special
files in the scenario directory:

* ``.maxfailures`` - Override ``crowdsecMaxFailures`` (integer)
* ``.banduration`` - Override ``crowdsecBanDuration`` (duration string: 4h, 1d, 30m, etc.)

Example:

.. code-block::

   crowdsec-filters/
   └── http-admin-probing/
       ├── .scenario         # Contains: llng/http-admin-probing
       ├── .maxfailures      # Contains: 11
       ├── .banduration      # Contains: 24h
       └── patterns.txt

In this example, the ``http-admin-probing`` scenario will:

* Trigger a ban after 11 failures (instead of global ``crowdsecMaxFailures``)
* Ban IPs for 24 hours (instead of global ``crowdsecBanDuration``)

This is useful for tuning detection sensitivity per scenario type.
