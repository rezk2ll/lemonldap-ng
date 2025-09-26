
Timers
------

LL::NG use timers (or cron jobs) to:

- purge old sessions
- clean Handler cache

.. attention::

   Depending on your OS and LL:NG version, you may still be using cron jobs. Section `Cron jobs`_
   Jobs were handled through cron jobs for versions older than:

   - Debian: **2.18.0**
   - Red Hat/Rocky Linux: **2.19.0**


Edit systemd timers
~~~~~~~~~~~~~~~~~~~

If you need to modify the frequence of execution:


.. code-block:: bash

   systemd edit liblemonldap-ng-portal-perl.timer
   systemd edit liblemonldap-ng-handler-perl.timer

.. attention::

    Names used here are for Debian family distributions, in RHEL they are named:

    - lemonldap-ng-portal.timer
    - lemonldap-ng-handler.timer

For example:

.. code-block:: bash

   [Timer]
   OnCalendar=*-*-* *:07:07

Cron jobs
~~~~~~~~~

As stated above, for older LL:NG versions, the timers were handled by cron jobs. If you need to modify the frequence of execution:

.. code-block:: bash

   vi /etc/cron.d/liblemonldap-ng-portal-perl
   vi /etc/cron.d/liblemonldap-ng-handler-perl

.. code-block:: bash

   7 * * * * www-data [ -x /usr/share/lemonldap-ng/bin/purgeCentralCache ] && if [ ! -d /run/systemd/system ]; then /usr/share/lemonldap-ng/bin/purgeCentralCache; fi
