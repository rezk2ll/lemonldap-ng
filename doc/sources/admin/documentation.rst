Documentation
=============

Presentation
------------

|image0|

-  :doc:`How it works <presentation>`
-  :doc:`Quick start tutorial <quickstart>`

Workshops
---------

-  LDAPCon 2019: `Connect LL::NG to OpenLDAP and use 2FA, configure SSO
   on Fusion Directory and
   Dokuwiki <https://github.com/Worteks/ldapcon2019-llng-workshop>`__
-  Pass the SALT 2019: `Connect LL::NG to OpenLDAP and use 2FA,
   configure SSO on Fusion
   Directory <https://github.com/LemonLDAPNG/pts2019-llng-workshop>`__

Installation and configuration
------------------------------

|image1|

Supported distributions
~~~~~~~~~~~~~~~~~~~~~~~

The LemonLDAP::NG team supports running our software in the following distributions:

* Debian
* Ubuntu
* RHEL and derivatives (Rocky Linux, AlmaLinux, etc.)

We release new versions of LemonLDAP::NG for all, currently community-supported
versions of these distributions. If you need LemonLDAP::NG to work on a
different distribution, or on an older version, please contact one of `our
contributing sponsors <https://lemonldap-ng.org/sponsors.html>`_.

Long Term Support
~~~~~~~~~~~~~~~~~

LL::NG Team maintains these versions following a "Long Term Support" policy:
these versions are maintained without software updates by transposing only
security fixes.

=========== ======= =========
Version LTS Secured Limit
=========== ======= =========
**2.16.x**  |clean| June 2028
**2.21.x**  |clean| June 2030
=========== ======= =========

Packaged versions
~~~~~~~~~~~~~~~~~

These versions are maintained under distribution umbrella following their policy.

Debian
^^^^^^

.. tip::

   Following Debian Policy, LL::NG packages are never upgraded in published distributions. However, security patches are backported by maintenance teams *(except some minor ones)*.
   See `Security tracker <https://security-tracker.debian.org/tracker/source-package/lemonldap-ng>`__

=========== ========================== ======================================== ===================================================================================================== ============================================================ =================================== =============================================================
N°          Debian name                LL::NG version                           Secured                                                                                               Maintenance                                                  LTS Limit                           `Extended LTS <https://wiki.debian.org/LTS/Extended>`__ Limit
=========== ========================== ======================================== ===================================================================================================== ============================================================ =================================== =============================================================
*6*         *Squeeze*                  *0.9.4.1*                                |maybe| *minor issues*                                                                                *None*                                                       *February 2016*
*7*         *Wheezy*                   *1.1.2*                                  |maybe| *minor issues*                                                                                *None*                                                       *May 2018*
*8*         *Jessie*                   *1.3.3*                                  |maybe| `minor issues <https://deb.freexian.com/extended-lts/tracker/source-package/lemonldap-ng>`__  *None*                                                       *June 2020*
*9*         *Stretch*                  *1.9.7*                                  |maybe| `minor issues <https://deb.freexian.com/extended-lts/tracker/source-package/lemonldap-ng>`__  *None*  [1]_                                                 *June 2022*
*10*        *Buster*                   `2.0.2 </documentation/2.0/>`__          |maybe| `minor issues <https://deb.freexian.com/extended-lts/tracker/source-package/lemonldap-ng>`__  *None*  [1]_                                                 *June 2024*                         Possibly 2029
**11**      Bullseye                   `2.0.11 </documentation/2.0/>`__         |clean|                                                                                               `Debian LTS Team <https://wiki.debian.org/LTS/Team>`__       August 2026                         Possibly 2031
**12**      Bookworm                   `2.16.1 </documentation/2.0/>`__         |clean|                                                                                               `Debian Security Team <https://security-team.debian.org/>`__ June 2028                           Possibly 2033
\           Bookworm-backports         `Latest </documentation/2.0/>`__ [3]_    |clean|                                                                                               LL::NG Team, "best effort" [2]_                              July 2026
**13**      Trixie                     `2.21.2 </documentation/2.0/>`_          |clean|                                                                                               `Debian Security Team <https://security-team.debian.org/>`__ July 2030                           Possibly 2035
**Next**    Testing/Unstable           Latest  [3]_                             |clean|                                                                                               LL::NG Team
=========== ========================== ======================================== ===================================================================================================== ============================================================ =================================== =============================================================

See `Debian Security
Tracker <https://security-tracker.debian.org/tracker/source-package/lemonldap-ng>`__
and `Debian Package
Tracker <https://tracker.debian.org/pkg/lemonldap-ng>`__ for more.

Ubuntu
^^^^^^

.. attention::

   Ubuntu version are included in "universe" branch [4]_, so not really security maintained. Prefer to use our repositories or Debian ones

=========== ============= ================================ ==================================================================================================================================== ===========
Ubuntu dist               LL::NG version                     Secured                                                                                                                            Maintenance
=========== ============= ================================ ==================================================================================================================================== ===========
*12.04*     *Precise*     *1.1.2*                          |maybe| minor issues                                                                                                                 None
*14.04*     *Trusty*      *1.2.5*                          |maybe| minor issues                                                                                                                 None
*16.04*     *Xenial*      *1.4.6*                          |bad| **CVE-2019-12046**, ...                                                                                                        None
*18.04*     *Bionic*      `1.9.16 </documentation/1.9/>`__ |bad| **CVE-2019-12046**, **CVE-2020-24660**, ...                                                                                    None
*20.04*     *Focal*       `2.0.7 </documentation/2.0/>`__  |bad| **CVE-2020-24660**, **CVE-2021-35472**, ...                                                                                    None
22.04       Jammy *(LTS)* `2.0.13 </documentation/2.0/>`__ |maybe| minor issues: CVE-2021-40874, CVE-2023-28862, CVE-2023-44469, CVE-2024-52946, CVE-2024-52947, CVE-2024-52948, CVE-2025-31510 None
24.04       Noble *(LTS)* `2.18.2 </documentation/2.0/>`__ |maybe| minor issues: CVE-2024-45160, CVE-2024-48933, CVE-2024-52946, CVE-2024-52947, CVE-2024-52948, CVE-2025-31510                 None
25.04       Plucky        `2.20.2 </documentation/2.0/>`__ |maybe| minor issue: CVE-2025-31510                                                                                                  None
=========== ============= ================================ ==================================================================================================================================== ===========

RHEL and derivatives
^^^^^^^^^^^^^^^^^^^^

The LemonLDAP::NG development team provides packages for the latest version of
LemonLDAP::NG directly in `EPEL <https://docs.fedoraproject.org/en-US/epel/>`__
repositories.

===========  ================== ========= ============ ==============
N°           LL::NG version     Secured   Maintenance  End of life
===========  ================== ========= ============ ==============
*8*          *latest*           |clean|   LL::NG Team  *June 2029*
*9*          *latest*           |clean|   LL::NG Team  *June 2032*
*10*         *latest*           |clean|   LL::NG Team  *June 2035*
===========  ================== ========= ============ ==============


Bug report
----------

See :doc:`Reporting a bug <bugreport>`.

Development
-----------

|image13|

-  `Bugtracker <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues>`__
-  `Source
   code <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/tree/master>`__
-  `Nightly trunk builds <https://lemonldap-ng.ow2.io/lemonldap-ng/>`__
   *(for Debian or Ubuntu,* **really unstable** *)*
-  Git access:

::

   git clone https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng.git

-  CPAN test reports:

   -  `LemonLDAP::NG
      Common <https://matrix.cpantesters.org/?dist=Lemonldap-NG-Common>`__
   -  `LemonLDAP::NG
      Handler <https://matrix.cpantesters.org/?dist=Lemonldap-NG-Handler>`__
   -  `LemonLDAP::NG
      Portal <https://matrix.cpantesters.org/?dist=Lemonldap-NG-Portal>`__
   -  `LemonLDAP::NG
      Manager <https://matrix.cpantesters.org/?dist=Lemonldap-NG-Manager>`__

Other
-----

|image14|

-  `Conferences </documentation/conferences>`__
-  `References </references>`__
-  `Press </press>`__

.. [1]
   Possible `Extended LTS <https://wiki.debian.org/LTS/Extended>`__

.. [2]
   updated by `LL::NG Team </team>`__ until dependencies are compatible.
   Don't use backports unless you plan to update your system because
   backports are not covered by Debian Security Policy

.. [3]
   few days after release

.. [4]
   Ubuntu universe/multiverse branches are community maintained *(so not
   maintained by Canonical)*, but in fact nobody considers LL::NG security
   issues. See `this
   issue <https://bugs.launchpad.net/ubuntu/+source/lemonldap-ng/+bug/1829016>`__
   for example

.. |clean| image:: /icons/clean.png
   :width: 20px
.. |bad| image:: /icons/bad.png
   :width: 20px
.. |maybe| image:: /icons/maybe.png
   :width: 20px
.. |image0| image:: /icons/tutorials.png
.. |image1| image:: /icons/windowlist.png
.. |image13| image:: /icons/terminal.png
.. |image14| image:: /icons/wizard.png
