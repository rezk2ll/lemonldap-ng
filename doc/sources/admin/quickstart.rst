Quick start tutorial
====================


.. attention::

    This tutorial will guide you into a minimal
    installation and configuration procedure. You need some prerequisites:

    - Root access to a Debian, Ubuntu, CentOS or RHEL test system
    - A web browser
    - A cup of coffee (or tea, we are open minded)



Installation
------------

Debian / Ubuntu
~~~~~~~~~~~~~~~

::

   apt install apt-transport-https
   wget -O - https://lemonldap-ng.org/_media/rpm-gpg-key-ow2 | apt-key add -
   echo "deb https://lemonldap-ng.org/deb stable main" > /etc/apt/sources.list.d/lemonldap-ng.list
   apt update
   apt install lemonldap-ng

CentOS / RHEL
~~~~~~~~~~~~~

::

   curl https://lemonldap-ng.org/_media/rpm-gpg-key-ow2 > /etc/pki/rpm-gpg/RPM-GPG-KEY-OW2
   echo '[lemonldap-ng]
   name=LemonLDAP::NG packages
   baseurl=https://lemonldap-ng.org/redhat/stable/$releasever/noarch
   enabled=1
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OW2' > /etc/yum.repos.d/lemonldap-ng.repo
   yum update
   yum install epel-release
   yum install lemonldap-ng
   # If you use SELinux
   yum install lemonldap-ng-selinux

SSO domain configuration
------------------------

LemonLDAP::NG needs all its components to be served on the same DNS domain.

If you can edit your `/etc/hosts` file or have access to a DNS server, check :ref:`quickstart_own_domain`, if you have no way to modify your DNS configuration, check :ref:`quickstart_nipio`.

.. _quickstart_own_domain:

Using your own domain
~~~~~~~~~~~~~~~~~~~~~

The defaut SSO domain is ``example.com``. You can keep it for your tests
or change it, for example for ``mydomain.com``:

::

   sed -i 's/example\.com/mydomain.com/g' \
      /etc/lemonldap-ng/* /var/lib/lemonldap-ng/conf/lmConf-1.json \
      /etc/nginx/conf.d/* \
      /etc/httpd/conf.d/* \
      /etc/apache2/sites-available/*

In order to be able to test, update your DNS or your local ``hosts``
file to map these names to the SSO server IP:

-  auth.mydomain.com
-  manager.mydomain.com
-  test1.mydomain.com
-  test2.mydomain.com

For example, you can enter the following command on your local computer: 
(adjust according to your server IP and test domain)

::

   echo "192.168.1.30 auth.mydomain.com manager.mydomain.com test1.mydomain.com test2.mydomain.com" >> /etc/hosts

.. _quickstart_nipio:

Using nip.io (or other DNS wildcard services)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you cannot edit /etc/hosts or your DNS zone, don't give up yet, you can use services such as `nip.io`_, `xip.io`_, `sslip.io`_ or others.

.. _nip.io: http://nip.io/
.. _xip.io: http://xip.io/
.. _sslip.io: https://sslip.io

For example, if your server IP is 192.168.12.13, you can use 192-168-12-13.nip.io as your SSO domain:

::

   sed -i 's/example\.com/192-168-12-13.nip.io/g' \
      /etc/lemonldap-ng/* /var/lib/lemonldap-ng/conf/lmConf-1.json \
      /etc/nginx/conf.d/* \
      /etc/httpd/conf.d/* \
      /etc/apache2/sites-available/*

.. warning::

   nip.io, xip.io or any DNS wildcard services mentionned in this section are not affiliated with the LemonLDAP::NG project in any way. These services will receive DNS requests that will allow them to know your test server's IP address. If this is an issue for you, do not use these services.

Run
---

Starting services
~~~~~~~~~~~~~~~~~

Debian / Ubuntu
'''''''''''''''

Enable the Nginx virtualhosts and restart the web server and LemonLDAP::NG server to apply the configuration changes ::

   cd /etc/nginx/sites-enabled
   ln -s ../sites-available/*nginx* .
   systemctl restart lemonldap-ng-fastcgi-server
   systemctl restart nginx

CentOS / RHEL
'''''''''''''

Enable and start httpd ::

   systemctl enable httpd
   systemctl start httpd


Open SSO session
~~~~~~~~~~~~~~~~

Go on http://auth.mydomain.com and log with one of the demonstration
account.

====== ======== =============
Login  Password Role
====== ======== =============
rtyler rtyler   user
msmith msmith   user
dwho   dwho     administrator
====== ======== =============

Access protected application
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Try http://test1.mydomain.com or http://test2.mydomain.com

Edit configuration
~~~~~~~~~~~~~~~~~~

Log with the dwho account and go on http://manager.mydomain.com
