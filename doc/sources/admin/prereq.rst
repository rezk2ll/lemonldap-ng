Prerequisites and dependencies
==============================

Web Server
----------

To use LemonLDAP::NG, you have the choice of the Web Server :

-  Nginx
-  Apache 2
-  Any FastCGI or uWSGI compatible Web Server ( **Portal and manager
   only**)

For Apache2, you can use all workers mpm-worker, mpm-prefork and
mpm-event. Mpm-worker works faster and LemonLDAP::NG use the thread
system for best performance **but since Apache-2.4, mod_perl seems
unstable in this configuration**. If you have to use mpm-prefork (for
example if you use PHP), LemonLDAP::NG will work anyway.

|image0|

Perl
----


.. note::

    Here the list of Perl modules used in LemonLDAP::NG. Core modules
    must be installed on the system. Other modules are required only if you
    plan to use related features.

Core
~~~~

-  Apache::Session
-  Cache::Cache
-  Clone
-  Config::IniFiles
-  Convert::PEM
-  Cookie::Baker::XS
-  Crypt::OpenSSL::Bignum
-  Crypt::OpenSSL::RSA
-  Crypt::OpenSSL::X509
-  Crypt::Rijndael
-  Crypt::URandom
-  DBI
-  Digest::HMAC_SHA1
-  Digest::MD5
-  Digest::SHA
-  Email::Sender
-  GD::SecurityImage
-  Hash::Merge::Simple
-  HTML::Template
-  HTTP::Headers
-  HTTP::Request
-  IO::String
-  JSON
-  LWP::UserAgent
-  LWP::Protocol::https
-  MIME::Base64
-  MIME::Entity
-  Mouse
-  Net::LDAP
-  Plack
-  Regexp::Assemble
-  Regexp::Common
-  SOAP::Lite *(optional)*
-  String::Random
-  Text::Unidecode *(Since LemonLDAP::NG 2.0.5)*
-  Unicode::String
-  URI
-  URI::Escape

Deprecated features
~~~~~~~~~~~~~~~~~~~

-  Old notifications format:

   -  XML::LibXML
   -  XML::LibXSLT

-  OpenID 2.0:

   -  Net::OpenID::Server
   -  Net::OpenID::Consumer

SAML2
~~~~~

-  `Lasso <http://lasso.entrouvert.org/>`__
-  GLib
-  XML::Simple

Second factor
~~~~~~~~~~~~~

-  Crypt::U2F::Server::Simple (U2F keys)
-  Convert::Base32 (TOTP)
-  Authen::WebAuthn (FIDO2 WebAuthen)
-  Authen::OATH (OTP)

Specific authentication backends
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  Facebook:

   -  Net::Facebook::Oauth2

-  Kerberos:

   -  GSSAPI

-  PAM:

   -  Authen::PAM

-  Radius:

   -  Authen::Radius

-  Twitter:

   -  Net::OAuth

-  WebID:

   -  Web::ID

SMTP & Reset password/certificate by mail
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  Email::Sender
-  String::Random
-  Net::SMTP
-  Net::SSLeay
-  DateTime::Format::RFC3339

Unit tests
~~~~~~~~~~

-  Authen::U2F::Tester
-  Crypt::U2F::Server
-  Test::MockObject
-  DBD::SQLite 
-  Test::Output
-  Test::POD
-  Time::Fake
-  YAML

Other
-----

-  Jquery (javascript framework) is included in tarball and RPMs, but is
   a dependency on Debian official releases
-  Cache::Memcached : used by SecureToken handler

Install dependencies on your system
-----------------------------------


.. danger::

    You don't need to install them if you use LL::NG packages.
    With ``apt`` or ``yum``, dependencies will be automatically
    installed.

.. _prereq-apt-get:

APT
~~~

Perl dependencies:

::

   apt install libapache-session-perl libcache-cache-perl libclone-perl libconfig-inifiles-perl libconvert-pem-perl libcrypt-openssl-bignum-perl libcrypt-openssl-rsa-perl libcrypt-openssl-x509-perl libcrypt-rijndael-perl libdbi-perl libdigest-hmac-perl libemail-sender-perl libgd-securityimage-perl libhash-merge-simple-perl libhtml-template-perl libio-string-perl libjson-perl libmime-tools-perl libmouse-perl libnet-ldap-perl libplack-perl libregexp-assemble-perl libregexp-common-perl libsoap-lite-perl libstring-random-perl libunicode-string-perl liburi-perl libwww-perl libxml-simple-perl libxml-libxslt-perl libcrypt-urandom-perl libtext-unidecode-perl libcookie-baker-xs-perl libio-socket-timeout-perl

For Apache:

::

   apt install apache2 libapache2-mod-fcgid libapache2-mod-perl2

For Nginx:

::

   apt install nginx nginx-extras

.. _prereq-yum:

YUM
~~~


.. tip::

    You need `EPEL <http://fedoraproject.org/wiki/EPEL/>`__
    repository. See below how to enable this repository:
    http://fedoraproject.org/wiki/EPEL/FAQ#howtouse\

Perl dependencies:

::

   yum install perl-Apache-Session perl-Cache-Cache perl-Clone perl-Config-IniFiles perl-Convert-PEM perl-Crypt-OpenSSL-RSA perl-Crypt-OpenSSL-X509 perl-Crypt-Rijndael perl-Digest-HMAC perl-Digest-SHA perl-GD-SecurityImage perl-Hash-Merge-Simple perl-HTML-Template perl-IO-String perl-JSON perl-LDAP perl-Mouse perl-Plack perl-Regexp-Assemble perl-Regexp-Common perl-SOAP-Lite perl-String-Random perl-Unicode-String perl-version perl-XML-Simple perl-Crypt-URandom perl-Email-Sender

For Apache:

::

   yum install httpd mod_fcgid mod_perl

For Nginx:

::

   yum install nginx


.. attention::

    As you need a recent version of Nginx, the best is to
    install `Nginx official
    packages <https://www.nginx.com/resources/wiki/start/topics/tutorials/install/#official-red-hat-centos-packages>`__.

.. |image0| image:: /documentation/llng_deps.png
   :class: align-center
   :width: 600px
