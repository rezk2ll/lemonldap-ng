CrowdSec
========

Presentation
------------

`CrowdSec <https://crowdsec.net>`__ is a free and open-source security
automation tool leveraging local IP behavior detection and a
community-powered IP reputation system.

LL::NG provides a **CrowdSec** bouncer that can reject Crowdsec banned-IP
requests or just provide an environment variable that can be used in
another plugin rule. For example, a second factor may be required if user's
IP is CrowdSec-banned.

You can find **CrowdSec** agents in `CrowdSec hub <https://hub.crowdsec.net>`

Configuration
-------------

To configure bouncer plugin, go in ``General Parameters`` > ``Plugins`` >
``CrowdSec``.

You can then configure:

- **Activation**: enable this plugin *(default: disabled)*
- **Action**: reject **or** warn and set ``$env->{CROWDSEC_REJECT} = 1``
- **Base URL of local API**: base URL of CrowdSec local API
  *(default: http://localhost:8080)*
- **API key**: API key, usually given by ``cscli bouncers add mylemon``
