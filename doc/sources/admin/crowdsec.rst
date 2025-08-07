CrowdSec
========

Presentation
------------

`CrowdSec <https://crowdsec.net>`__ is a free and open-source security
automation tool leveraging local IP behavior detection and a
community-powered IP reputation system.

LL::NG provides two **Crowdsec** plugins:
* a bouncer that can reject CrowdSec banned IP requests or just provide an
  environment variable that can be used inanother plugin rule. For example,
  a second factor may be required if user'si IP is CrowdSec banned.
* an agent that push alerts to Crowdsec server for each authentication failure.
  It can also push "ban" decisions if limits are reached

You can also find **CrowdSec** agents in `CrowdSec hub <https://hub.crowdsec.net>`__.

Configuration
-------------

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

Note that:

- Agent just push alerts, it never block anything. You must enable **Bouncer** to do this
- **Base URL of local API** has to be configured into ``Bouncer``.
