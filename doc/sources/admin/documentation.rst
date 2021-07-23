Documentation
=============

Presentation
------------

|image0|

-  :doc:`How it works <presentation>`
-  :doc:`Main features <features>`
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

-  Maintained versions:

   -  `Version 3.0 </documentation/3.0/>`__ (dev)
   -  `Version 2.0 </documentation/2.0/>`__ (stable)
   -  `Version 1.9 </documentation/1.9/>`__ (oldstable)

-  Archived versions (unmaintained by `LLNG Team </team>`__ )

   -  `Version 1.4 </documentation/1.4/>`__
   -  `Version 1.3 </documentation/1.3/>`__
   -  `Version 1.2 </documentation/1.2/>`__
   -  `Version 1.1 </documentation/1.1/>`__
   -  `Version 1.0 </documentation/1.0/>`__

Packaged versions
~~~~~~~~~~~~~~~~~

These versions are maintained under distribution umbrella following
their policy.

Debian
^^^^^^

.. tip::

   Following Debian Policy, LLNG packages are never upgraded in published distributions. However, security patches are backported by maintenance teams *(except some inor ones)*.

=========== ======================== ======================================== ===================================================== ============================================================ =============================== =============================================================
Debian dist                          LLNG version                             Secured                                               Maintenance                                                  LTS Limit                       `Extended LTS <https://wiki.debian.org/LTS/Extended>`__ Limit
=========== ======================== ======================================== ===================================================== ============================================================ =============================== =============================================================
*6*         *Squeeze*                *0.9.4.1*                                |maybe| No known vulnerability                        *None*                                                       *February 2016*                 *April 2019*
**7**       Wheezy                   `1.1.2 </documentation/1.1/>`__          |maybe| No known vulnerability                        **None**  [1]_                                               May 2018                        Probably 2021
**8**       Jessie                   `1.3.3 </documentation/1.3/>`__          |clean| CVE-2019-19791 tagged as minor                **None**  [1]_                                               June 2020                       Probably 2023
**9**       Stretch                  `1.9.7 </documentation/1.9/>`__          |clean| CVE-2019-19791 tagged as minor                `Debian LTS Team <https://www.debian.org/lts/>`__            June 2022                      
\           *Stretch-backports*      `2.0.2 </documentation/2.0/>`__          |bad| CVE-2019-12046, CVE-2019-13031, CVE-2019-15941  *None*                                                       *June 2019*                    
\           Stretch-backports-sloppy `2.0.11 </documentation/2.0/>`__         |maybe|                                               *Maybe none*, "best effort"  [3]_                            Until Debian 11 release  [4]_
**10**      Buster                   `2.0.2 </documentation/2.0/>`__          |clean| CVE-2019-19791 tagged as minor                `Debian Security Team <https://security-team.debian.org/>`__ Probably July 2024             
\           Buster-backports         `2.0.11 </documentation/2.0/>`__         |clean|                                               `LLNG Team </team>`, "best effort" [3]_                      Until Debian 11 release  [4]_
\           Bullseye                 `2.0.11 </documentation/2.0/>`__         |clean|                                               `Debian Security Team <https://security-team.debian.org/>`__ Probably July 2026             
**Next**    Testing                  Latest  [5]_                             |clean|                                               `LLNG Team </team>`__                                                                       
=========== ======================== ======================================== ===================================================== ============================================================ =============================== =============================================================

See `Debian Security
Tracker <https://security-tracker.debian.org/tracker/source-package/lemonldap-ng>`__
and `Debian Package
Tracker <https://tracker.debian.org/pkg/lemonldap-ng>`__ for more.

Ubuntu
^^^^^^

.. attention::

   Ubuntu version are included in "universe" branch [8]_, so not really security maintained. Prefer to use our repositories or Debian ones

=========== ============= ================================ ==================================================================== ===========
Ubuntu dist               LLNG version                     Secured                                                              Maintenance
=========== ============= ================================ ==================================================================== ===========
12.04       Precise       `1.1.2 </documentation/1.1/>`__  |maybe| No known vulnerability                                       None
14.04       Trusty        `1.2.5 </documentation/1.2/>`__  |maybe| No known vulnerability                                       None
16.04       Xenial  [9]_  `1.4.6 </documentation/1.4/>`__  |bad| CVE-2019-12046, CVE-2019-13031                                 None
18.04       Bionic  [9]_  `1.9.16 </documentation/1.9/>`__ |bad| CVE-2019-12046, CVE-2019-13031, CVE-2020-24660                 None
20.04       Focal  [9]_   `2.0.7 </documentation/2.0/>`__  |bad| CVE-2020-24660, CVE-2021-35472, CVE-2021-35473                 None
20.10       Groovy        `2.0.8 </documentation/2.0/>`__  |bad| CVE-2020-24660, CVE-2021-35472, CVE-2021-35473                 None
21.04       Hirsute       `2.0.11 </documentation/2.0/>`__ |bad| CVE-2021-35472, CVE-2021-35473                                 None
=========== ============= ================================ ==================================================================== ===========

Bug report
----------

See :doc:`Reporting a bug <bugreport>`.

Development
-----------

|image13|

-  `Bugtracker <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues>`__
-  `Source
   code <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/tree/master>`__
-  `Nightly trunk builds <http://lemonldap-ng.ow2.io/lemonldap-ng/>`__
   *(for Debian or Ubuntu,*\ **really unstable**\ *)*
-  Git access:

::

   git clone https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng.git

-  CPAN test reports:

   -  `LemonLDAP::NG
      Common <http://www.cpantesters.org/distro/L/Lemonldap-NG-Common.html>`__
   -  `LemonLDAP::NG
      Handler <http://www.cpantesters.org/distro/L/Lemonldap-NG-Handler.html>`__
   -  `LemonLDAP::NG
      Portal <http://www.cpantesters.org/distro/L/Lemonldap-NG-Portal.html>`__
   -  `LemonLDAP::NG
      Manager <http://www.cpantesters.org/distro/L/Lemonldap-NG-Manager.html>`__

Other
-----

|image14|

-  `Conferences </documentation/conferences>`__
-  `References </references>`__
-  `Press </press>`__

.. [1]
   Possible `Extended LTS <https://wiki.debian.org/LTS/Extended>`__

.. [3]
   updated by `LLNG Team </team>`__ until dependencies are compatible.
   Don't use backports unless you plan to update your system because
   backports are not covered by Debian Security Policy

.. [4]
   around September 2021

.. [5]
   few days after release

.. [8]
   Ubuntu universe/multiverse branches are community maintained *(so not
   maintained by Canonical)*, but in fact nobody considers LLNG security
   issues. See `this
   issue <https://bugs.launchpad.net/ubuntu/+source/lemonldap-ng/+bug/1829016>`__
   for example

.. [9]
   LTS

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

