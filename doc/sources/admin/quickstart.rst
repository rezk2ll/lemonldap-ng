Quick start tutorial
====================


.. important:: 

    This tutorial will guide you into a minimal
    installation and configuration procedure. You need some prerequisites:
    
    -  A computer with a GNU/Linux recent distribution (Debian, Ubuntu,
       CentOS, RHEL, ...) with root privileges
    -  A web browser
    -  The possibility to update your local ``hosts`` file, or an easy
       access to your DNS server
    -  A cup of coffee (or tea, we are open minded)
    


Installation
------------

You should install Lemonldap::NG using packages, but you can also
install it from
:doc:`the tarball<installtarball>`.

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
   echo "[lemonldap-ng]
   name=LemonLDAP::NG packages
   baseurl=https://lemonldap-ng.org/redhat/stable/$releasever/noarch
   enabled=1
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OW2" > /etc/yum.repos.d/lemonldap-ng.repo
   yum update
   yum install lemonldap-ng

SSO domain configuration
------------------------

The defaut SSO domain is ``example.com``. You can keep it for your tests
or change it, for example for ``mydomain.com``:

::

   sed -i 's/example\.com/mydomain.com/g' /etc/lemonldap-ng/* /var/lib/lemonldap-ng/conf/lmConf-1.json
   sed -i 's/example\.com/mydomain.com/g' /etc/nginx/conf.d/*
   sed -i 's/example\.com/mydomain.com/g' /etc/httpd/conf.d/*
   sed -i 's/example\.com/mydomain.com/g' /etc/apache2/sites-available/*

In order to be able to test, update your DNS or your local ``hosts``
file to map this names to the SSO server IP:

-  auth.mydomain.com
-  manager.mydomain.com
-  test1.mydomain.com
-  test2.mydomain.com

For example on your local computer:

::

   echo "192.168.1.30 auth.mydomain.com manager.mydomain.com test1.mydomain.com test2.mydomain.com" >> /etc/hosts 

Run
---

Since LemonLDAP::NG 1.2, the
:doc:`demonstration backend<authdemo>` is
configured by default.

Demonstration backend has hard coded user accounts:

====== ======== =============
Login  Password Role
====== ======== =============
rtyler rtyler   user
msmith msmith   user
dwho   dwho     administrator
====== ======== =============

Open SSO session
~~~~~~~~~~~~~~~~

Go on http://auth.mydomain.com and log with one of the demonstration
account.

Access protected application
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Try http://test1.mydomain.com or http://test2.mydomain.com

Edit configuration
~~~~~~~~~~~~~~~~~~

Log with the dwho account and go on http://manager.mydomain.com
