**Do you want to contribute to LemonLdap::NG project ?**

Contribute to Project
=====================

LemonLDAP::NG is mostly written in Perl and Javascript. Community
applies the following rules:

-  Perl:

   -  code must be written in modern object-oriented code (using
      `Mouse <https://metacpan.org/pod/Mouse>`__) *(except handler and
      Apache::Session inheritance)*
   -  code must be formatted using the `make tidy` command

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

   ssh -T git@gitlab.ow2.org

Accept messages

Install basic tools
-------------------

Debian
^^^^^^

As *root:*

::

   apt install make devscripts equivs yui-compressor git uglifyjs coffeescript autopkgtest cpanminus

Configure Git
^^^^^^^^^^^^^

As *user:*

::

   git config --global user.name "Name Surname"
   git config --global user.email "your@mail"
   git config --global color.ui true
   git config --list

Import Project and using Git
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As *user*, create directory in directory:

::

   git clone git@gitlab.ow2.org:lemonldap-ng/lemonldap-ng.git
   cd lemonldap-ng/

   # Use your own clone for pushes
   git remote set-url --push origin git@gitlab.ow2.org:user/lemonldap-ng.git


Install dependencies
--------------------

::

    # Install build dependancies
    mk-build-deps debian/control
    sudo apt install ./lemonldap-ng-build-deps*deb
    apt install apache2 libapache2-mod-fcgid libapache2-mod-perl2  # install Apache
    cpanm Perl::Tidy@$(make tidyversion)

For SAML:

::

   apt install liblasso-perl libglib-perl

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

Launch tests with LDAP backend

::

   apt install slapd
   make LLNGTESTLDAP=1 test

Other commands
^^^^^^^^^^^^^^

* Start a test web server on port 19876::

     make start_web_server # TESTUSESSL=1 to enable SSL engine (only available for Apache)
     make start_web_server TESTWEBSERVER=nginx # to use Nginx web server
     make stop_web_server
     make reload_web_server # to reload LL:NG conf

* Clean test files ::

     make clean

* Compile CoffeeScript and minify ::

     make minify

* Rebuild manager tree, this is needed everytime you add a new option ::

     make json

* Update Perl manifest ::

     make manifest

* Reformat Perl files ::

     make tidy

Add a translation key
^^^^^^^^^^^^^^^^^^^^^

If you need to create a new parameter in Manager or add a new message in Portal, you must add a key in JSON languages files.

To ease this process, use the script ``scripts/addTrKey`` provided in the sources:

::

    $ scripts/addTrEntry
    Usage:
    scripts/addTrEntry <option> key enText <frText>
    scripts/addTrEntry <option> key '$otherkey'

    Options:
      --portal  -p: add entry in portal translation instead of manager
      --modify  -m: modify an existing entry
      --delete  -d: delete an existing key
      --reorder -r: reorder files
      --help   -h: display this


For example:

::

    $ scripts/addTrEntry MyNewParameter 'A new parameter' 'Un nouveau paramètre'


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
