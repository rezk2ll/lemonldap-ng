**Do you want to contribute to LemonLdap::NG project ?**

Contribute to Project
=====================

LemonLDAP::NG is mostly written in Perl and Javascript. Community
applies the following rules:

-  Perl:

   -  code must be written in modern object-oriented code (using
      `Mouse <https://metacpan.org/pod/Mouse>`__) *(except handler and
      Apache::Session inheritance)*
   -  code must be formatted using
      `perltidy <https://metacpan.org/pod/distribution/Perl-Tidy/bin/perltidy>`__
      version 20181120 *(from Debian/buster)*

-  Javascript:

   -  code must be written in
      `CoffeeScript <http://coffeescript.org/>`__ (in
      ``<component>/site/coffee``): ``make minify`` will generate JS
      files

Configure SSH
-------------

*On Debian developper station :*

::

   ssh-keygen -o -t rsa -b 4096 -C "your@email"

Go to your gitlab account : https://gitlab.ow2.org/profile/keys

::

   cat ~/.ssh/id_rsa.pub

Copy id_rsa.pub content to key section and enter a name into "Title" and click "Add key" button. 
Test ssh connexion :

::

   ssh -T git@gitlab.com

Accept messages

Install basic tools
-------------------

Debian
^^^^^^

As *root:*

::

   apt install aptitude
   aptitude install vim make devscripts yui-compressor git git-gui libjs-uglify coffeescript cpanminus autopkgtest pkg-perl-autopkgtest
   aptitude install libauth-yubikey-webclient-perl libnet-smtp-server-perl libtime-fake-perl libtest-output-perl libtest-pod-perl libtest-leaktrace-perl libtest-mockobject-perl uglifyjs libdbd-sqlite3-perl libauthen-webauthn-perl libauthen-oath-perl

   cpanm Authen::U2F Authen::U2F::Tester Crypt::U2F::Server::Simple

   curl -sL https://deb.nodesource.com/setup_9.x | bash -
   apt-get install -y nodejs

   npm install -g protractor # end-2-end tests
   webdriver-manager update # install/update selenium driver

Configure Git
^^^^^^^^^^^^^

As *user:*

::

   git config --global user.name "Name Surname"
   git config --global user.email "your@mail"
   git config --global core.editor vim
   git config --global merge.tool vimdiff
   git config --global color.ui true
   git config --list

Import Project and using Git
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As *user*, create directory in directory:

::

   git clone git@gitlab.ow2.org://user///lemonldap-ng.git
   cd lemonldap-ng/
   git log
   git checkout master # go to master branch
   git remote add upstream https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng.git # to connect to remote branch
   git fetch upstream  # import branch
   git checkout v2.0 # to change branch
   git fetch upstream

Import version branch on linux station:

::

   git checkout v2.0
   git fetch upstream
   git rebase upstream/v2.0 # to align to parent project remote branch

On gitlab, create working branch, one per thematic on linux station:

::

   git checkout workingbranch
   git log
   git status
   git commit -am "explanations (#number gitlab ticket)"
   git commit --amend file(s) # to modify a commit
   git rebase v2.0 # align local working branch to local 2.0
   git checkout -- file(s) # revert
   git push # to send on remote working branch ! Only after doing some commits !

On gitlab, submit merge request when tests are corrects.

Install dependencies
--------------------

::

   aptitude install libapache-session-perl libcache-cache-perl libclone-perl libconfig-inifiles-perl libconvert-pem-perl libio-socket-timeout-perl libcrypt-openssl-bignum-perl libcrypt-openssl-rsa-perl libcrypt-openssl-x509-perl libcrypt-rijndael-perl libdbi-perl libdigest-hmac-perl libemail-sender-perl libgd-securityimage-perl libhtml-template-perl libio-string-perl libjson-perl libmime-tools-perl libmouse-perl libnet-ldap-perl libplack-perl libregexp-assemble-perl libregexp-common-perl libsoap-lite-perl libstring-random-perl libtext-unidecode-perl libunicode-string-perl liburi-perl libwww-perl libxml-simple-perl libxml-libxslt-perl libcrypt-urandom-perl libconvert-base32-perl cpanminus
   aptitude install apache2 libapache2-mod-fcgid libapache2-mod-perl2  # install Apache
   aptitude install nginx nginx-extras  # install Nginx
   cpanm perltidy@20181120

For SAML:

::

   aptitude install liblasso-perl libglib-perl

Working Project
---------------

Configure hosts file
^^^^^^^^^^^^^^^^^^^^
::

     echo '127.0.0.1       auth.example.com manager.example.com test1.example.com test2.example.com' >> /etc/hosts

Unit tests
^^^^^^^^^^

Launch unit tests:

::

     make test # or manager_test, portal_test, ... to launch unit tests

Same tests launched on a simulated install

::

     make autopkgtest # or autopkg_portal, autopkg_manager, ... to launch unit tests

Execute an unit test :

::

     # Building project
     cd ~/lemonldap-ng/; make
     # Go to parent test directory
     cd ~/lemonldap-ng/lemonldap-ng-portal
     # and execute the unit test:
     prove -v t/67-CheckUser.t

Launch tests with LDAP backend, for example with OpenLDAP LTB package (https://ltb-project.org/documentation):

::

   make LLNGTESTLDAP=1 LLNGTESTLDAP_SLAPD_BIN=/usr/local/openldap/libexec/slapd LLNGTESTLDAP_SLAPADD_BIN=/usr/local/openldap/sbin/slapadd LLNGTESTLDAP_SCHEMA_DIR=/usr/local/openldap/etc/openldap/schema/ test

Other commands
^^^^^^^^^^^^^^

::

     make start_web_server # TESTUSESSL=1 to enable SSL engine (only available for Apache)
     make start_web_server TESTWEBSERVER=nginx # to use Nginx web server
     make stop_web_server
     make reload_web_server # to reload LL:NG conf
     make clean # to clean test files
     make minify # to minify and compile coffeescript
     make json # to build conf and manager tree
     make manifest # to update manifest
     make tidy # to magnify perl files (perl best pratices)

Documentation
^^^^^^^^^^^^^

Install dependencies:

::

    apt install python3-sphinx python3-sphinx-bootstrap-theme

Then edit sources in doc/sources/admin.

You can check the result with:

::

    make documentation
    firefox doc/pages/documentation/current/start.html
