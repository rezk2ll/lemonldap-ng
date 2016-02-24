#!/usr/bin/make

# This Makefile contains 2 main sections
#  - Variables
#  - targets

# ---------
# VARIABLES
# ---------

# Prefix for packaging
DESTDIR=

# Flag for optimizations
USEDEBIANLIBS=no
PROD=$(USEDEBIANLIBS)
USEEXTERNALLIBS=no

# Perl options
#PERLOPTIONS="INSTALLDIRS=vendor"
PERLOPTIONS=

# Compression
JSCOMPRESS=$(PROD)
CSSCOMPRESS=$(PROD)

# External commands
PERL=$$(which perl)
PERLVERSION=`perl -e '$$version = $$^V; $$version =~ s/v//; print $$version'`
SU=su -c
COMPRESS=tar czf
UNCOMPRESS=tar xzf
LISTCOMPRESSED=tar tzf
COMPRESSSUFFIX=tar.gz
NGINX=/usr/sbin/nginx

# Default directories install
# ---------------------------

# Common dirs
PREFIX=/usr/local
LMPREFIX=$(PREFIX)/lemonldap-ng
# BIN dirs
BINDIR=$(LMPREFIX)/bin
SBINDIR=$(LMPREFIX)/sbin
INITDIR=$(LMPREFIX)/etc/init.d
ETCDEFAULTDIR=$(LMPREFIX)/etc/default
DATADIR=$(LMPREFIX)/data

# Document roots for Apache VirtualHosts
DOCUMENTROOT=$(LMPREFIX)/htdocs
PORTALDIR=$(DOCUMENTROOT)/portal
PORTALSKINSDIR=$(PORTALDIR)/skins
MANAGERDIR=$(DOCUMENTROOT)/manager
MANAGERSITEDIR=$(MANAGERDIR)
MANAGERSTATICDIR=$(MANAGERSITEDIR)/static
MANAGERRELATIVESTATICDIR=/static
MANAGERPSGIDIR=$(MANAGERSITEDIR)/psgi
MANAGERTEMPLATESDIR=$(MANAGERSITEDIR)/templates
DOCDIR=$(DOCUMENTROOT)
DEFDOCDIR=$(DOCUMENTROOT)/doc
FRDOCDIR=$(DOCUMENTROOT)/fr-doc
TESTDIR=$(DOCUMENTROOT)/test
EXAMPLESDIR=$(LMPREFIX)/examples
TOOLSDIR=$(LMPREFIX)/tools

# Handler dir
HANDLERDIR=$(LMPREFIX)/handler

# Configuration dir
CONFDIR=$(LMPREFIX)/etc
CRONDIR=$(LMPREFIX)/etc/cron.d
CONFFILENAME=lemonldap-ng.ini
STORAGECONFFILE=$(CONFDIR)/$(CONFFILENAME)

# LL::NG configuration storage dir
FILECONFIGDIR=$(DATADIR)/conf

# LL::NG sessions storage dir
APACHESESSIONFILEDIR=$(DATADIR)/sessions
APACHESESSIONFILELOCKDIR=$(APACHESESSIONFILEDIR)/lock

# LL::NG persistent sessions storage dir
APACHEPSESSIONFILEDIR=$(DATADIR)/psessions
APACHEPSESSIONFILELOCKDIR=$(APACHEPSESSIONFILEDIR)/lock

# LL::NG notifications storage dir
APACHEFILENOTIFDIR=$(DATADIR)/notifications

# LL::NG captcha dir
CAPTCHADIR=$(DATADIR)/captcha

# Apache user/group
APACHEUSER=
APACHEGROUP=

# FastCGI
FASTCGISOCKDIR=$(PREFIX)/run
FASTCGIUSER=$(APACHEUSER)
FASTCGIGROUP=$(APACHEGROUP)

# Apache version
APACHEVERSION=2.X

# DNS Domain for cookie and virtual hosts
DNSDOMAIN=example.com

# Virtual Host Listen IP and Port (*, *:80, ...)
PORT=80
VHOSTLISTEN="*:$(PORT)"
TESTWEBSERVER=apache
TESTWEBSERVERPORT=19876

# Other
SRCCOMMONDIR=lemonldap-ng-common
SRCHANDLERDIR=lemonldap-ng-handler
SRCPORTALDIR=lemonldap-ng-portal
SRCMANAGERDIR=lemonldap-ng-manager
ERASECONFIG=1 # Set to 0 if you do not want to replace your configuration

# INTERNAL VARIABLES

# Internal variables used to install in $(DESTDIR)
RLMPREFIX=$(DESTDIR)/$(LMPREFIX)
RBINDIR=$(DESTDIR)/$(BINDIR)
RSBINDIR=$(DESTDIR)/$(SBINDIR)
RINITDIR=$(DESTDIR)/$(INITDIR)
RETCDEFAULTDIR=$(DESTDIR)/$(ETCDEFAULTDIR)
RDATADIR=$(DESTDIR)/$(DATADIR)
RPORTALDIR=$(DESTDIR)/$(PORTALDIR)
RPORTALSKINSDIR=$(DESTDIR)/$(PORTALSKINSDIR)
RMANAGERDIR=$(DESTDIR)/$(MANAGERDIR)
RMANAGERSITEDIR=$(DESTDIR)/$(MANAGERSITEDIR)
RMANAGERSTATICDIR=$(DESTDIR)/$(MANAGERSTATICDIR)
RMANAGERPSGIDIR=$(DESTDIR)/$(MANAGERPSGIDIR)
RMANAGERTEMPLATESDIR=$(DESTDIR)/$(MANAGERTEMPLATESDIR)
RDOCDIR=$(DESTDIR)/$(DOCDIR)
RDEFDOCDIR=$(DESTDIR)/$(DEFDOCDIR)
RTESTDIR=$(DESTDIR)/$(TESTDIR)
REXAMPLESDIR=$(DESTDIR)/$(EXAMPLESDIR)
RTOOLSDIR=$(DESTDIR)/$(TOOLSDIR)
RHANDLERDIR=$(DESTDIR)/$(HANDLERDIR)
RCONFDIR=$(DESTDIR)/$(CONFDIR)
RCRONDIR=$(DESTDIR)/$(CRONDIR)
RFILECONFIGDIR=$(DESTDIR)/$(FILECONFIGDIR)
RAPACHESESSIONFILEDIR=$(DESTDIR)/$(APACHESESSIONFILEDIR)
RAPACHESESSIONFILELOCKDIR=$(DESTDIR)/$(APACHESESSIONFILELOCKDIR)
RAPACHEPSESSIONFILEDIR=$(DESTDIR)/$(APACHEPSESSIONFILEDIR)
RAPACHEPSESSIONFILELOCKDIR=$(DESTDIR)/$(APACHEPSESSIONFILELOCKDIR)
RFILENOTIFDIR=$(DESTDIR)/$(APACHEFILENOTIFDIR)
RCAPTCHADIR=$(DESTDIR)/$(CAPTCHADIR)
RFASTCGISOCKDIR=$(DESTDIR)/$(FASTCGISOCKDIR)

VERSION=`head -n1 changelog |sed -e 's/lemonldap-ng (//' -e 's/).*$$//'`
PORTALSKINS=`ls $(SRCPORTALDIR)/example/skins/`
DIFF=diff -aurN -x '*.tpl' -x '*.bak' -x .svn -x '*.map' -x '*.min.js' -x '*.min.css' -x '*.swp' --ignore-matching-lines='.*jquery.*' --ignore-matching-lines='.*lemonldap-ng\.ini.*'
DIFFPREFIX=


MANAGERLIBSTOREMOVEFORDEBIAN=$(RMANAGERSTATICDIR)/bwr/jquery/ \
			$(RMANAGERSTATICDIR)/bwr/angular/ \
			$(RMANAGERSTATICDIR)/bwr/angular-animate/ \
			$(RMANAGERSTATICDIR)/bwr/angular-cookie/ \
			$(RMANAGERSTATICDIR)/bwr/bootstrap/ \
			$(RMANAGERSTATICDIR)/bwr/es5-shim/
PORTALLIBSTOREMOVEFORDEBIAN=$(RPORTALSKINSDIR)/bootstrap/fonts \
			$(RPORTALSKINSDIR)/bootstrap/css/bootstrap* \
			$(RPORTALSKINSDIR)/bootstrap/js/bootstrap* \
			$(RPORTALSKINSDIR)/common/js/jquery-* \
			$(RPORTALSKINSDIR)/common/js/jquery.cookie*
MANAGEREXTERNALLIBS=$(RMANAGERSTATICDIR)/bwr/
PORTALEXTERNALLIBS=$(PORTALLIBSTOREMOVEFORDEBIAN) $(RPORTALSKINSDIR)/common/js/jquery*

# GENERATED SRC FILES
MANAGERJSONSRC= scripts/jsongenerator.pl \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Build.pm \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Build/Attributes.pm \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Build/Tree.pm \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Conf/Zero.pm
MANAGERJSONDST=$(SRCMANAGERDIR)/site/static/struct.json \
		$(SRCMANAGERDIR)/site/static/js/conftree.js \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Attributes.pm \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Constants.pm \
		$(SRCCOMMONDIR)/lib/Lemonldap/NG/Common/Conf/DefaultValues.pm \
		$(SRCCOMMONDIR)/lib/Lemonldap/NG/Common/Conf/Constants.pm \
		_example/conf/lmConf-1.js

# Javascript and CSS to minify
JSSRCFILES:=$(shell find $(SRCMANAGERDIR)/site/static/js $(SRCPORTALDIR)/example -type f -name '*.js' ! -name '*.min.js') \
		$(SRCMANAGERDIR)/site/static/bwr/file-saver.js/FileSaver.js
CSSSRCFILES:=$(shell find $(SRCMANAGERDIR)/site/static/css  $(SRCPORTALDIR)/example -type f -name '*.css' ! -name '*.min.css')

# Minified files
JSDSTFILES=$(JSSRCFILES:.js=.min.js)
CSSDSTFILES=$(CSSSRCFILES:.css=.min.css)

# -------
# TARGETS
# -------

# Targets section contains the following subsections:
#  - configure targets
#  - make targets
#  - test targets
#  - end-to-end tests
#  - install targets
#  - cleaning targets
#  - Perl libraries uninstall targets
#  - packaging targets
#  - developper corner

# Configure targets
# -----------------

configure:	json common_conf handler_conf portal_conf manager_conf

minify: $(JSDSTFILES) $(CSSDSTFILES)

%.min.css: %.css
	@echo "Compressing $*.css"
	@yui-compressor $*.css > $*.min.css

%.min.js: %.js
	@echo "Compressing $*.js"
	@yui-compressor $*.js > $*.min.js

fastcgi-server/man/llng-fastcgi-server.1p: fastcgi-server/sbin/llng-fastcgi-server
	@pod2man -name llng-fastcgi-server fastcgi-server/sbin/llng-fastcgi-server >fastcgi-server/man/llng-fastcgi-server.1p

# Perl libraries configuration

json:	$(MANAGERJSONDST) fastcgi-server/man/llng-fastcgi-server.1p
	@if which yui-compressor; then $(MAKE) minify; fi

$(MANAGERJSONDST):	$(MANAGERJSONSRC)
	./scripts/jsongenerator.pl

common_conf:	${SRCCOMMONDIR}/Makefile

handler_conf:	${SRCHANDLERDIR}/Makefile

portal_conf:	${SRCPORTALDIR}/Makefile

manager_conf:	${SRCMANAGERDIR}/Makefile

${SRCCOMMONDIR}/Makefile:
	@cd ${SRCCOMMONDIR}; LMNGCONFFILE=$(STORAGECONFFILE) $(PERL) Makefile.PL $(PERLOPTIONS)

${SRCHANDLERDIR}/Makefile:
	@cd ${SRCHANDLERDIR}; $(PERL) Makefile.PL $(PERLOPTIONS)

${SRCPORTALDIR}/Makefile:
	@cd ${SRCPORTALDIR}; $(PERL) Makefile.PL $(PERLOPTIONS)

${SRCMANAGERDIR}/Makefile:
	@cd ${SRCMANAGERDIR}; $(PERL) Makefile.PL $(PERLOPTIONS)

# Make targets
# ------------

all:	configure common handler manager portal
	@echo
	@echo "Building succeed. Now run :"
	@echo " - 'make test' to verify your installation"
	@echo " - 'make install PROD=yes' to install all"
	@echo
	@echo "    MAKE INSTALL OPTIONS:"
	@echo "    - PROD=yes            : use js/css minified files"
	@echo "    - USEDEBIANLIBS=yes   : use some Debian shared js/css files"
	@echo "    - USEEXTERNALLIBS=yes : use external links for some js/css files"
	@echo
	@echo 'Other targets :'
	@echo " * Partial build :"
	@echo "   - portal, manager, handler"
	@echo " * Doxygen documentation"
	@echo "   - doxygen (to build Doxygen documentation in doc/devel/)"
	@echo
	@echo 'Other targets launched by "make install" :'
	@echo " * Perl libraries install :"
	@echo "   - install_libs           (all Perl libraries)"
	@echo "   - install_portal_libs"
	@echo "   - install_manager_libs"
	@echo "   - install_handler_libs"
	@echo " * Binaries install :"
	@echo "   - install_bin            ($(BINDIR))"
	@echo " * FastCGI server install   (required for Nginx)"
	@echo "   - install_fastcgi_server ($(SBINDIR))"
	@echo " * Web sites install :"
	@echo "   - install_site           (all sites including install_doc_site)"
	@echo "   - install_portal_site    ($(PORTALDIR))"
	@echo "   - install_manager_site   ($(MANAGERDIR))"
	@echo "   - install_handler_site   ($(HANDLERDIR))"
	@echo " * Documentation install :"
	@echo "   - install_doc_site       ($(DEFDOCDIR))"
	@echo "   - install_examples_site  ($(EXAMPLESDIR))"
	@echo
	@echo "Other languages documentation (fr only for now)"
	@echo " - fr-doc                  (needs OmegaT)"
	@echo " - install_fr_doc_site"
	@echo

common:		common_conf
	@$(MAKE) -C ${SRCCOMMONDIR}

handler:	handler_conf common
	@$(MAKE) -C ${SRCHANDLERDIR}

portal:		portal_conf common
	@$(MAKE) -C ${SRCPORTALDIR}

manager:	manager_conf handler
	$(MAKE) -C ${SRCMANAGERDIR}

# Test targets
# ------------
test:		all common_test handler_test portal_test manager_test extra_test

common_test:	common
	@$(MAKE) -C ${SRCCOMMONDIR} test

handler_test:	handler
	@$(MAKE) -C ${SRCHANDLERDIR} test FULLPERL="$(PERL) -I../${SRCCOMMONDIR}/blib/lib/"

portal_test:	portal
	@$(MAKE) -C ${SRCPORTALDIR} test FULLPERL="$(PERL) -I../${SRCCOMMONDIR}/blib/lib/ -I../${SRCHANDLERDIR}/blib/lib/"

manager_test:	manager
	@$(MAKE) -C ${SRCMANAGERDIR} test FULLPERL="$(PERL) -I../${SRCCOMMONDIR}/blib/lib/ -I../${SRCHANDLERDIR}/blib/lib/"

extra_test:	all
	cd ${SRCPORTALDIR} && prove -b -I ../$(SRCCOMMONDIR)/blib/lib -I ../$(SRCHANDLERDIR)/blib/lib -I../${SRCPORTALDIR}/blib/lib/ xt
#	PERL_DL_NONLAZY=1 $(PERL) "-MExtUtils::Command::MM" "-e" "test_harness(0, 'lemonldap-ng-common/blib/lib', 'lemonldap-ng-handler/blib/lib', 'lemonldap-ng-manager/blib/lib', 'lemonldap-ng-portal/blib/lib')" extra-tests/*.t

# End-to-end tests
# ----------------

e2e_test:	all prepare_test_server start_web_server launch_protractor stop_web_server

prepare_test_server:
	@mkdir -p e2e-tests/conf/sessions/lock e2e-tests/conf/persistents/lock
	$(MAKE) install_webserver_conf install_test_site install_fastcgi_server \
		CONFDIR=`pwd`/e2e-tests/conf \
		RCONFDIR=e2e-tests/conf \
		ERASECONFIG=1 \
		VHOSTLISTEN='*:$(TESTWEBSERVERPORT)' \
		PORT=$(TESTWEBSERVERPORT) \
		FASTCGISOCKDIR=`pwd`/e2e-tests/conf \
		PORTALDIR=`pwd`/$(SRCPORTALDIR)/example \
		MANAGERDIR=`pwd`/$(SRCMANAGERDIR)/site \
		TESTDIR=`pwd`/e2e-tests/conf/site \
		MANAGERPSGIDIR=`pwd`/e2e-tests \
		DEFDOCDIR=`pwd`/doc \
		FRDOCDIR=`pwd`/po-doc/fr \
		SBINDIR=`pwd`/e2e-tests/conf/sbin \
		INITDIR=`pwd`/e2e-tests/conf/init \
		ETCDEFAULTDIR=`pwd`/e2e-tests/conf/def
	@cp e2e-tests/lmConf-1.js e2e-tests/lemonldap-ng.ini e2e-tests/env.conf e2e-tests/test-nginx.conf e2e-tests/conf/
	@cp e2e-tests/form.html e2e-tests/conf/site
	@perl -i -pe 'BEGIN{$$p=`pwd`;chomp $$p}s#__pwd__#$$p#;s#__port__#$(TESTWEBSERVERPORT)#;s#__FASTCGISOCKDIR__#$(FASTCGISOCKDIR)#;' \
		e2e-tests/conf/lemonldap-ng.ini \
		e2e-tests/conf/lmConf-1.js \
		e2e-tests/conf/env.conf \
		e2e-tests/conf/test-nginx.conf

e2e-tests/conf/apache2.pid: start_web_server

start_web_server:	all prepare_test_server
	# Clean old server if launched
	-@[ -e e2e-tests/conf/apache2.pid ] && kill `cat e2e-tests/conf/apache2.pid` || true
	-@[ -e e2e-tests/conf/nginx.pid ]   && kill `cat e2e-tests/conf/nginx.pid` || true
	-@[ -e e2e-tests/conf/llng-fastcgi.pid ] && kill `cat e2e-tests/conf/llng-fastcgi.pid` && rm -f e2e-tests/conf/llng-fastcgi.pid || true
	# Start web server (designed for Debian, path may be broken else)
	@if test "$(TESTWEBSERVER)" = "apache"; then \
		LLNG_DEFAULTCONFFILE=`pwd`/e2e-tests/conf/lemonldap-ng.ini /usr/sbin/apache2 -d `pwd`/e2e-tests -f apache2.conf -k start; \
	elif test "$(TESTWEBSERVER)" = "nginx"; then \
		echo "Testing nginx conf"; \
		$(NGINX) -t -p `pwd`/e2e-tests \
			-g 'error_log '`pwd`'/e2e-tests/conf/nginx.log;' \
			-c `pwd`/e2e-tests/nginx.conf \
			2>&1 | grep -v 'Permission denied' || true; \
		echo "Launching nginx"; \
		$(NGINX) -p `pwd`/e2e-tests \
			-g 'error_log '`pwd`'/e2e-tests/conf/nginx.log;' \
			-c `pwd`/e2e-tests/nginx.conf \
			2>&1 | grep -v 'Permission denied' || true; \
		echo "Launching plackup"; \
		$(MAKE) plackup; \
	else \
		echo "!!!!! Unknown test server: $(TESTWEBSERVER) !!!!!" >&2; \
		exit 1; \
	fi
		

reload_web_server:
	@if [ -e e2e-tests/conf/apache2.pid ]; then \
		LLNG_DEFAULTCONFFILE=`pwd`/e2e-tests/conf/lemonldap-ng.ini \
		/usr/sbin/apache2 -d `pwd`/e2e-tests -f apache2.conf -k graceful; \
	elif [ -e e2e-tests/conf/nginx.pid ]; then \
		kill -HUP `cat e2e-tests/conf/nginx.pid`; \
		kill `cat e2e-tests/conf/llng-fastcgi.pid` || true; \
		$(MAKE) plackup; \
	else \
		$(MAKE) start_web_server; \
	fi

launch_protractor:	all e2e-tests/conf/apache2.pid
	# Start e2e tests
	# NB: you must have protractor installed (using npm install -g protractor)
	# and have run update-webdriver at least once and have a node.js > 4.0
	@TESTWEBSERVERPORT=$(TESTWEBSERVERPORT) protractor e2e-tests/protractor-conf.js

stop_web_server:
	# Stop web server
	-@[ -e e2e-tests/conf/apache2.pid ] && kill `cat e2e-tests/conf/apache2.pid` || true
	-@[ -e e2e-tests/conf/nginx.pid ]   && kill `cat e2e-tests/conf/nginx.pid` ||true
	-@[ -e e2e-tests/conf/llng-fastcgi.pid ] && kill `cat e2e-tests/conf/llng-fastcgi.pid` && rm -f e2e-tests/conf/llng-fastcgi.pid || true
	# Clean
	@rm -rf e2e-tests/conf

restart_web_server: start_web_server

plackup:
	@LLNG_DEFAULTCONFFILE=`pwd`/e2e-tests/conf/lemonldap-ng.ini \
	perl -I`pwd`/lemonldap-ng-common/blib/lib/ \
			-I`pwd`/lemonldap-ng-handler/blib/lib/ \
			-I`pwd`/lemonldap-ng-portal/blib/lib/ \
			-I`pwd`/lemonldap-ng-manager/blib/lib/ \
		e2e-tests/conf/sbin/llng-fastcgi-server \
			-F >e2e-tests/conf/fastcgi.log 2>&1 &

install_test:
	@TESTWEBSERVERPORT=$(PORT) protractor e2e-tests/protractor-conf.js

# Install targets
# ---------------
install:	install_libs install_bin install_fastcgi_server install_site

# Perl libraires install

install_libs:	common_install_libs install_handler_libs install_portal_libs install_manager_libs

common_install_libs:		common
	@$(MAKE) -C ${SRCCOMMONDIR} install

install_handler_libs:	handler
	@$(MAKE) -C ${SRCHANDLERDIR} install

install_portal_libs:		portal
	@$(MAKE) -C ${SRCPORTALDIR} install

install_manager_libs:	manager
	@$(MAKE) -C ${SRCMANAGERDIR} install

install_bin:	install_conf_dir
	# Binary install
	@install -v -d $(RBINDIR)
	@cp -f\
		${SRCHANDLERDIR}/example/scripts/purgeLocalCache \
		${SRCPORTALDIR}/example/scripts/purgeCentralCache \
		${SRCPORTALDIR}/example/scripts/buildPortalWSDL \
		${SRCCOMMONDIR}/scripts/convertConfig \
		${SRCCOMMONDIR}/scripts/lmMigrateConfFiles2ini \
		${SRCCOMMONDIR}/scripts/rotateOidcKeys \
		${SRCMANAGERDIR}/scripts/lmConfigEditor \
		${SRCCOMMONDIR}/scripts/lemonldap-ng-cli \
			$(RBINDIR)
	@if [ ! "$(APACHEUSER)" ]; then \
		$(PERL) -i -pe 's#__APACHEUSER__#nobody#g;' $(RBINDIR)/lmConfigEditor; \
	else \
		$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' $(RBINDIR)/lmConfigEditor; \
	fi
	@if [ ! "$(APACHEGROUP)" ]; then \
		$(PERL) -i -pe 's#__APACHEGROUP__#nobody#g;' $(RBINDIR)/lmConfigEditor; \
	else \
		$(PERL) -i -pe 's#__APACHEGROUP__#$(APACHEGROUP)#g;' $(RBINDIR)/lmConfigEditor; \
	fi
	@chmod +x $(RBINDIR)/*

install_fastcgi_server:
	@install -v -d $(RSBINDIR) $(RINITDIR) $(RETCDEFAULTDIR) $(RFASTCGISOCKDIR)
	@cp -f fastcgi-server/sbin/llng-fastcgi-server $(RSBINDIR)
	@chmod +x $(RSBINDIR)/llng-fastcgi-server
	@cp -f fastcgi-server/rc/llng-fastcgi-server $(RINITDIR)
	@cp -f fastcgi-server/default/llng-fastcgi-server $(RETCDEFAULTDIR)
	@$(PERL) -pi -e 's#__SBINDIR__#$(SBINDIR)#;s#__DEFAULTDIR__#$(ETCDEFAULTDIR)#;s#__FASTCGISOCKDIR__#$(FASTCGISOCKDIR)#g' \
		$(RETCDEFAULTDIR)/llng-fastcgi-server \
		$(RSBINDIR)/llng-fastcgi-server \
		$(RINITDIR)/llng-fastcgi-server
	@if [ ! "$(FASTCGIUSER)" ]; then \
		$(PERL) -pi -e 's#__USER__#nobody#' $(RETCDEFAULTDIR)/llng-fastcgi-server; \
	else \
		$(PERL) -pi -e 's#__USER__#$(FASTCGIUSER)#' $(RETCDEFAULTDIR)/llng-fastcgi-server; \
	fi
	@if [ ! "$(FASTCGIGROUP)" ]; then \
		$(PERL) -pi -e 's#__GROUP__#nobody#' $(RETCDEFAULTDIR)/llng-fastcgi-server; \
	else \
		$(PERL) -pi -e 's#__GROUP__#$(FASTCGIGROUP)#' $(RETCDEFAULTDIR)/llng-fastcgi-server; \
	fi
	@if [ "$(FASTCGIUSER)" != "" ]; then \
		chown $(FASTCGIUSER) $(RFASTCGISOCKDIR) || exit 1; \
		if [ "$(FASTCGIGROUP)" != "" ]; then \
			chgrp $(FASTCGIGROUP) $(RFASTCGISOCKDIR) || exit 1; \
		fi; \
		chmod 770 $(RFASTCGISOCKDIR); \
	else \
		chmod 777 $(RFASTCGISOCKDIR); \
	fi

# Site install

install_site:	install_manager_site install_portal_site install_handler_site install_test_site install_examples_site install_doc_site install_webserver_conf
	# Site install
	@install -v -d $(RCONFDIR)
	# Check if erase is wanted
	@if [ "$(ERASECONFIG)" -eq "1" ]; then \
		cp -f _example/etc/for_etc_hosts $(RCONFDIR); \
	fi
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(RCONFDIR)/for_etc_hosts
	# Fix a lost of rights on the main directory
	@chmod 755 $(RBINDIR) $(RDOCUMENTROOT) $(REXAMPLESDIR) $(RHANDLERDIR) $(RPORTALSKINSDIR) $(RMANAGERSITEDIR) $(RTOOLSDIR) $(RCONFDIR) $(RDATADIR)
	@echo
	@echo "LemonLDAP::NG v${VERSION} is installed with these parameters:"
	@echo "  - System configuration: ${CONFDIR}"
	@echo "  - DNS domain (for cookies and virtual hosts): ${DNSDOMAIN}"
	@echo
	@echo "To finish configuration:"
	@echo
	@echo "1 - Add this in your Apache $(APACHEVERSION) configuration file:"
	@echo "      include ${CONFDIR}/portal-apache$(APACHEVERSION).conf"
	@echo "      include ${CONFDIR}/handler-apache$(APACHEVERSION).conf"
	@echo "      include ${CONFDIR}/manager-apache$(APACHEVERSION).conf"
	@echo "      include ${CONFDIR}/test-apache$(APACHEVERSION).conf"
	@echo
	@echo "2 - Restart Apache:"
	@echo "      apache$(APACHEVERSION)ctl restart"
	@echo
	@echo "3 - Run 'make postconf' as root to update /etc/hosts if your DNS service does not known auth.$(DNSDOMAIN) and manager.$(DNSDOMAIN)"
	@echo
	@echo "4 - Try to connect to http://test1.${DNSDOMAIN}/ or http://test2.${DNSDOMAIN}/ with demonstration accounts:"
	@echo "    - rtyler/rtyler"
	@echo "    - msmith/msmith"
	@echo "    - dwho/dwho"
	@echo
	@echo "5 - Connect to Manager at http://manager.${DNSDOMAIN}/ to edit configuration"
	@echo
	@if [ ! "$(APACHEUSER)" ]; then \
		echo;echo "    Warning, since APACHEUSER was not set, $(APACHESESSIONFILEDIR), $(APACHEPSESSIONFILEDIR), $(CAPTCHADIR) and $(CONFDIR) have permissive permissions."; \
		echo "    Fix them by yourself to restrict their view to apache process only"; \
	fi
	@echo

install_webserver_conf:
	@install -m 755 -v -d $(RCONFDIR)
	@if [ "$(ERASECONFIG)" -eq "1" ]; then \
		cp -f _example/etc/portal-apache$(APACHEVERSION).conf $(RCONFDIR); \
		cp -f _example/etc/handler-apache$(APACHEVERSION).conf $(RCONFDIR); \
		cp -f _example/etc/manager-apache$(APACHEVERSION).conf $(RCONFDIR); \
		cp -f _example/etc/test-apache$(APACHEVERSION).conf $(RCONFDIR); \
		cp -f _example/etc/*nginx*.conf $(RCONFDIR); \
	fi
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g; \
			s#__PORTALDIR__#$(PORTALDIR)/#g; \
			s#__MANAGERDIR__#$(MANAGERDIR)/#g; \
			s#__MANAGERSTATICDIR__#$(MANAGERSTATICDIR)/#g; \
			s#__MANAGERPSGIDIR__#$(MANAGERPSGIDIR)/#g; \
			s#__TESTDIR__#$(TESTDIR)/#g; \
			s#__PORT__#$(PORT)#g; \
			s#__CONFDIR__#$(CONFDIR)#g; \
			s#__FASTCGISOCKDIR__#$(FASTCGISOCKDIR)#g; \
			s#__VHOSTLISTEN__#$(VHOSTLISTEN)#g; \
			s#__DEFDOCDIR__#$(DEFDOCDIR)/#g; \
			s#__FRDOCDIR__#$(FRDOCDIR)/#g;' $(RCONFDIR)/*apache*.conf $(RCONFDIR)/*nginx*.conf

install_manager_site:	install_conf_dir
	# Manager install
	@install -v -d $(RMANAGERDIR) $(RMANAGERSTATICDIR) $(RMANAGERPSGIDIR) \
		$(RMANAGERTEMPLATESDIR)
	@cp -pR $(SRCMANAGERDIR)/site/static/* $(RMANAGERSTATICDIR)
	@for f in $(SRCMANAGERDIR)/site/templates/*.tpl; do \
		./scripts/transform-templates \
			usedebianlibs $(USEDEBIANLIBS) \
			useexternallibs $(USEEXTERNALLIBS) \
			jsminified $(JSCOMPRESS) \
			cssminified $(CSSCOMPRESS) <$$f \
			> $(RMANAGERTEMPLATESDIR)/`basename $$f`; \
	done
	@if test "$(USEEXTERNALLIBS)" = "yes"; then \
		rm -rvf $(MANAGEREXTERNALLIBS); \
	elif test "$(USEDEBIANLIBS)" = "yes"; then \
		rm -rvf $(MANAGERLIBSTOREMOVEFORDEBIAN); \
	fi
	@cp -pR $(SRCMANAGERDIR)/eg/* $(RMANAGERPSGIDIR)
	# Clean svn files
	@rm -rf $$(find ${RMANAGERSTATICDIR} $(RMANAGERPSGIDIR) \
		$(RMANAGERTEMPLATESDIR) $(RCONFDIR) -type d -name .svn)
	$(PERL) -i -pe 's#__MANAGERSTATICDIR__#$(MANAGERRELATIVESTATICDIR)#g' $(RCONFDIR)/$(CONFFILENAME)
	$(PERL) -i -pe 's#__MANAGERTEMPLATESDIR__#$(MANAGERTEMPLATESDIR)#g' $(RCONFDIR)/$(CONFFILENAME)

install_portal_site:	install_conf_dir
	# Portal install
	@install -v -d $(RPORTALDIR) $(RPORTALSKINSDIR) \
		$(RPORTALDIR)/skins/ \
		$(RCRONDIR) $(RCONFDIR)
	@for skin in $$(ls $(SRCPORTALDIR)/example/skins/); do \
		[ -h $(RPORTALDIR)/skins/$$skin ] && rm -f $(RPORTALDIR)/skins/$$skin; \
		install -v -d $(RPORTALSKINSDIR)/$$skin; \
	done
	@cp -pR -f ${SRCPORTALDIR}/example/index_skin.pl ${RPORTALDIR}/index.pl
	@cp -pR -f ${SRCPORTALDIR}/example/mail.pl ${RPORTALDIR}
	@cp -pR -f ${SRCPORTALDIR}/example/metadata.pl ${RPORTALDIR}
	@cp -pR -f ${SRCPORTALDIR}/example/openid-configuration.pl ${RPORTALDIR}
	@cp -pR -f ${SRCPORTALDIR}/example/cdc.pl ${RPORTALDIR}
	@cp -pR -f ${SRCPORTALDIR}/example/register.pl ${RPORTALDIR}
	@tar -cf - -C ${SRCPORTALDIR}/example/skins/ $$(ls ${SRCPORTALDIR}/example/skins/) |tar -xf - -C $(RPORTALSKINSDIR)
	@for f in `find $(RPORTALSKINSDIR) -type f -name '*.tpl'`; do \
		./scripts/transform-templates \
			usedebianlibs $(USEDEBIANLIBS) \
			useexternallibs $(USEEXTERNALLIBS) \
			jsminified $(JSCOMPRESS) \
			cssminified $(CSSCOMPRESS) <$$f \
			>$$f.tmp; \
		mv -f $$f.tmp $$f; \
	done
	@if test "$(USEEXTERNALLIBS)" = "yes"; then \
		rm -rvf $(PORTALEXTERNALLIBS); \
	elif test "$(USEDEBIANLIBS)" = "yes"; then \
		rm -rvf $(PORTALLIBSTOREMOVEFORDEBIAN); \
	fi
	@if [ "$(PORTALDIR)/skins/" != "$(PORTALSKINSDIR)/" ]; then \
		for skin in $$(ls $(SRCPORTALDIR)/example/skins/); do \
			rm -rf $(RPORTALDIR)/skins/$$skin/; \
			ln -s $(PORTALSKINSDIR)/$$skin $(RPORTALDIR)/skins/$$skin; \
		done; \
	fi
	# Cron files
	@cp -f $(SRCPORTALDIR)/example/scripts/purgeCentralCache.cron.d $(RCRONDIR)/lemonldap-ng-portal
	@if [ ! "$(APACHEUSER)" ]; then \
		$(PERL) -i -pe 's#__APACHEUSER__#nobody#g;' $(RCRONDIR)/lemonldap-ng-portal; \
	else \
		$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' $(RCRONDIR)/lemonldap-ng-portal; \
	fi
	@$(PERL) -i -pe 's#__BINDIR__#$(BINDIR)#g;' $(RCRONDIR)/lemonldap-ng-portal
	# Clean SVN files
	@rm -rf $$(find ${RPORTALDIR} $(RPORTALSKINSDIR) $(RCRONDIR) $(RCONFDIR) -type d -name .svn)

install_handler_site:	install_conf_dir
	# Handler install
	@install -v -d ${RHANDLERDIR}
	@cp -f $(SRCHANDLERDIR)/example/scripts/purgeLocalCache.cron.d $(RCRONDIR)/lemonldap-ng-handler
	@if [ ! "$(APACHEUSER)" ]; then \
		$(PERL) -i -pe 's#__APACHEUSER__#nobody#g;' $(RCRONDIR)/lemonldap-ng-handler; \
	else \
		$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' $(RCRONDIR)/lemonldap-ng-handler; \
	fi
	@$(PERL) -i -pe 's#__BINDIR__#$(BINDIR)#g;' $(RCRONDIR)/lemonldap-ng-handler
	@rm -rf $$(find $(RHANDLERDIR) -type d -name .svn)

install_test_site:
	# Test site install
	@install -v -d $(RTESTDIR)
	@cp -pR -f _example/test/* $(RTESTDIR)
	@rm -rf $$(find $(RTESTDIR) -type d -name .svn)
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(RTESTDIR)/index.pl
	@rm -rf $$(find $(RTESTDIR) -type d -name .svn)

install_examples_site:
	# Examples install
	@install -v -d $(REXAMPLESDIR)
	@for i in portal handler; do \
		cp -a -f lemonldap-ng-$$i/example $(REXAMPLESDIR)/$$i; \
	done
	@for i in manager; do \
		cp -a -f lemonldap-ng-$$i/eg $(REXAMPLESDIR)/$$i; \
	done
	@rm -rf $(REXAMPLESDIR)/portal/skins \
		$(REXAMPLESDIR)/manager/skins \
	@rm -rf $$(find $(REXAMPLESDIR) -type d -name .svn)
	@$(PERL) -i -pe 's#__SESSIONDIR__#$(APACHESESSIONFILEDIR)/#g;' $(REXAMPLESDIR)/portal/*.pl
	@$(PERL) -i -pe 's#__PSESSIONDIR__#$(APACHEPSESSIONFILEDIR)/#g;' $(REXAMPLESDIR)/portal/*.pl

install_doc_site:
	# Offline documentation install
	@rm -rf $(RDEFDOCDIR)
	@install -v -d $(RDEFDOCDIR)
	@cp -a -f doc/* $(RDEFDOCDIR)

install_conf_dir:	install_sessions_dir install_notif_dir install_captcha_dir
	# Configuration files install
	@install -v -d $(RCONFDIR) $(RFILECONFIGDIR) $(RTOOLSDIR)
	@if [ "$(ERASECONFIG)" -eq "1" ]; then \
		cp -f $(SRCCOMMONDIR)/$(CONFFILENAME) $(RCONFDIR); \
		$(PERL) -i -pe 's#^dirName\s*=\s*.*#dirName = $(FILECONFIGDIR)#g' $(RCONFDIR)/$(CONFFILENAME); \
	fi
	@cp _example/conf/lmConf-1.js $(RFILECONFIGDIR)
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g;\
		s#__SESSIONDIR__#$(APACHESESSIONFILEDIR)#g;\
		s#__PSESSIONDIR__#$(APACHEPSESSIONFILEDIR)#g;\
		s#__NOTIFICATIONDIR__#$(APACHEFILENOTIFDIR)#g;' $(RFILECONFIGDIR)/lmConf-1.js
	@if [ "$(APACHEUSER)" != "" ]; then \
		chown $(APACHEUSER) $(RFILECONFIGDIR) || exit 1; \
		if [ "$(APACHEGROUP)" != "" ]; then \
			chgrp $(APACHEGROUP) $(RFILECONFIGDIR) || exit 1; \
		fi; \
		chmod 770 $(RFILECONFIGDIR); \
	else \
		chmod 777 $(RFILECONFIGDIR); \
	fi
	@cp $(SRCCOMMONDIR)/tools/lmConfig.* $(SRCCOMMONDIR)/tools/apache-session-mysql.sql $(RTOOLSDIR)
	@cp $(SRCCOMMONDIR)/tools/sso.schema $(RTOOLSDIR)
	$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(RCONFDIR)/$(CONFFILENAME)
	@rm -rf $$(find $(RCONFDIR) $(RFILECONFIGDIR) $(RTOOLSDIR) -type d -name .svn)

install_sessions_dir:
	@install -m 777 -v -d $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR) $(RAPACHEPSESSIONFILEDIR) $(RAPACHEPSESSIONFILELOCKDIR)
	# Fix Apache::Session directories permissions
	@if [ "$(APACHEUSER)" != "" ]; then \
		chown $(APACHEUSER) $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR) $(RAPACHEPSESSIONFILEDIR) $(RAPACHEPSESSIONFILELOCKDIR) || exit 1; \
		if [ "$(APACHEGROUP)" != "" ]; then \
			chgrp $(APACHEGROUP) $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR) $(RAPACHEPSESSIONFILEDIR) $(RAPACHEPSESSIONFILELOCKDIR) || exit 1; \
		fi; \
		chmod 770 $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR) $(RAPACHEPSESSIONFILEDIR) $(RAPACHEPSESSIONFILELOCKDIR); \
	else \
		chmod 777 $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR) $(RAPACHEPSESSIONFILEDIR) $(RAPACHEPSESSIONFILELOCKDIR); \
	fi

install_notif_dir:
	@install -m 777 -v -d $(RFILENOTIFDIR)
	# Fix notifications directory permissions
	@if [ "$(APACHEUSER)" != "" ]; then \
		chown $(APACHEUSER) $(RFILENOTIFDIR) || exit 1; \
		if [ "$(APACHEGROUP)" != "" ]; then \
			chgrp $(APACHEGROUP) $(RFILENOTIFDIR) || exit 1; \
		fi; \
		chmod 770 $(RFILENOTIFDIR); \
	else \
		chmod 777 $(RFILENOTIFDIR); \
	fi

install_captcha_dir:
	@install -m 777 -v -d $(RCAPTCHADIR)
	# Fix captcha directory permissions
	@if [ "$(APACHEUSER)" != "" ]; then \
		chown $(APACHEUSER) $(RCAPTCHADIR) || exit 1; \
		if [ "$(APACHEGROUP)" != "" ]; then \
			chgrp $(APACHEGROUP) $(RCAPTCHADIR) || exit 1; \
		fi; \
		chmod 770 $(RCAPTCHADIR); \
	else \
		chmod 777 $(RCAPTCHADIR); \
	fi

postconf_hosts:
	@cat ${CONFDIR}/for_etc_hosts >> /etc/hosts
	@echo "/etc/hosts was updated"

postconf: postconf_hosts
	@echo "Post configuration done"

debian-install:
	@echo "You have now to choose between:"
	@echo " - make debian-install-for-apache"
	@echo " - make ubuntu-install-for-apache"
	@echo " - make debian-install-for-nginx"
	@echo " - make ubuntu-install-for-nginx"
	@echo
	@echo "All packages will be built in /tmp/ but only those needed by the"
	@echo "server you will choose will be installed"
	@exit 1

debian-install-for-apache: debian-packages
	perl -i -ne 'next if/fastcgi.*deb$$/;s/lemonldap-ng-fastcgi-server//;print' /tmp/lemonldap-ng_$(VERSION)*.changes
	cd /tmp/lemonldap-ng-$(VERSION) && \
	$(SU) debi

debian-install-for-nginx: debian-packages
	cd /tmp/lemonldap-ng-$(VERSION) && \
	$(SU) debi

ubuntu-install: debian-install

ubuntu-install-for-apache:
	$(MAKE) debian-install-for-apache SU=sudo

ubuntu-install-for-nginx:
	$(MAKE) debian-install-for-nginx SU=sudo

# Cleaning targets
# ----------------

distclean:	clean

clean:		common_clean handler_clean portal_clean manager_clean omegat-clean stop_web_server
	@rm -f $$(find */ -name '*bak' -delete)
	@rm -rf doc/devel
	@rm -vf *gz *zip
	@rm -rf lemonldap-ng-$(VERSION)
	@echo "Cleaned"

common_clean:
	@if test -e ${SRCCOMMONDIR}/Makefile;then $(MAKE) -C ${SRCCOMMONDIR} distclean;fi
	@rm -vf common*

handler_clean:
	@if test -e ${SRCHANDLERDIR}/Makefile;then $(MAKE) -C ${SRCHANDLERDIR} distclean;fi
	@rm -vf handler*

portal_clean:
	@if test -e ${SRCPORTALDIR}/Makefile;then $(MAKE) -C ${SRCPORTALDIR} distclean;fi
	@rm -vf portal*

manager_clean:
	@if test -e ${SRCMANAGERDIR}/Makefile;then $(MAKE) -C ${SRCMANAGERDIR} distclean;fi
	@rm -vf manager*

# Perl libraries uninstall targets
# --------------------------------

uninstall:	configure handler_uninstall portal_uninstall manager_uninstall

common_uninstall:	common
	@$(MAKE) -C ${SRCCOMMONDIR} uninstall
	@rm -vf common_uninstall

handler_uninstall:	handler
	@$(MAKE) -C ${SRCHANDLERDIR} uninstall
	@rm -vf handler_uninstall

portal_uninstall:		portal
	@$(MAKE) -C ${SRCPORTALDIR} uninstall
	@rm -vf portal_uninstall

manager_uninstall:	manager
	@$(MAKE) -C ${SRCMANAGERDIR} uninstall
	@rm -vf manager_uninstall

# Packaging target
# ----------------

dist:	clean
	@mkdir -p lemonldap-ng-$(VERSION)
	@cp -pRH $$(find * -maxdepth 0|grep -v -e "\(lemonldap-ng-$(VERSION)\|debian\|rpm\)") lemonldap-ng-$(VERSION)
	@rm -rf $$(find lemonldap-ng-$(VERSION) -name .svn -print)
	@rm -rf lemonldap-ng-$(VERSION)/po-doc/fr/*
	@find $$dir -name '*.bak' -delete
	@rm -rf lemonldap-ng-$(VERSION)/lemonldap-ng-$(VERSION)
	@$(COMPRESS) lemonldap-ng-$(VERSION).$(COMPRESSSUFFIX) lemonldap-ng-$(VERSION)
	@rm -rf lemonldap-ng-$(VERSION)

rpm-dist:	clean
	@mkdir -p lemonldap-ng-$(VERSION)
	@cp -pRH $$(find * -maxdepth 0|grep -v -e "\(lemonldap-ng-$(VERSION)\|debian\)") lemonldap-ng-$(VERSION)
	@rm -rf $$(find lemonldap-ng-$(VERSION) -name .svn -print)
	@find $$dir -name '*.bak' -delete
	@rm -rf lemonldap-ng-$(VERSION)/lemonldap-ng-$(VERSION)
	@$(COMPRESS) lemonldap-ng-$(VERSION).$(COMPRESSSUFFIX) lemonldap-ng-$(VERSION)
	@rm -rf lemonldap-ng-$(VERSION)


debian-dist:	clean
	@mkdir -p lemonldap-ng-$(VERSION)
	@cp -pRH $$(find * -maxdepth 0|grep -v -e "\(lemonldap-ng-$(VERSION)\|rpm\)") lemonldap-ng-$(VERSION)
	@rm -rf $$(find lemonldap-ng-$(VERSION) -name .svn -print)
	@find $$dir -name '*.bak' -delete
	@cp lemonldap-ng-$(VERSION)/_example/etc/handler-apache2.X.conf lemonldap-ng-$(VERSION)/_example/etc/handler-apache2.conf
	@cp lemonldap-ng-$(VERSION)/_example/etc/manager-apache2.X.conf lemonldap-ng-$(VERSION)/_example/etc/manager-apache2.conf
	@cp lemonldap-ng-$(VERSION)/_example/etc/portal-apache2.X.conf lemonldap-ng-$(VERSION)/_example/etc/portal-apache2.conf
	@cp lemonldap-ng-$(VERSION)/_example/etc/test-apache2.X.conf lemonldap-ng-$(VERSION)/_example/etc/test-apache2.conf
	@rm -rf lemonldap-ng-$(VERSION)/lemonldap-ng-$(VERSION)
	@$(COMPRESS) lemonldap-ng_$(VERSION).orig.$(COMPRESSSUFFIX) lemonldap-ng-$(VERSION)
	@rm -rf lemonldap-ng-$(VERSION)

zip-dist:
	$(MAKE) dist "COMPRESS=zip -r" COMPRESSSUFFIX=zip

manifest:   configure
	@for i in ${SRCCOMMONDIR} ${SRCHANDLERDIR} ${SRCPORTALDIR} ${SRCMANAGERDIR}; do \
		cd $$i; \
		make manifest; \
		rm -vf MANIFEST.*; \
		cd -; \
	done

cpan:	clean configure common_cpan handler_cpan portal_cpan manager_cpan
	for i in Common Portal Handler Manager; do \
		$(UNCOMPRESS) Lemonldap-NG-$$i-*.$(COMPRESSSUFFIX) \
			$$($(LISTCOMPRESSED) Lemonldap-NG-$$i-*.$(COMPRESSSUFFIX) |grep META.yml); \
		mv Lemonldap-NG-$$i-*/META.yml lemonldap-ng-$$($(PERL) -e "print lc('$$i')")/; \
		rm -rf Lemonldap-NG-$$i*/; \
		done

debian-local-packages: debian-packages

debian-packages: debian-dist
	mv lemonldap-ng_$(VERSION).orig.$(COMPRESSSUFFIX) /tmp/
	version=$(VERSION) && \
	cd /tmp/ && \
	rm -rf lemonldap-ng-$$version && \
	$(UNCOMPRESS) lemonldap-ng_$$version.orig.$(COMPRESSSUFFIX) && \
	cd lemonldap-ng-$$version && \
	debuild -us -uc -b --lintian-opts -i \
		--lintian-opts -v --lintian-opts -I --lintian-opts -E \
		--lintian-opts --color --lintian-opts auto --lintian-opts -L \
		--lintian-opts +=pedantic

# Developper corner
# -----------------

common_cpan:	common_conf
	@$(MAKE) -C ${SRCCOMMONDIR} dist
	@mv ${SRCCOMMONDIR}/Lemonldap*.gz .

handler_cpan:	handler_conf
	@$(MAKE) -C ${SRCHANDLERDIR} dist
	@mv ${SRCHANDLERDIR}/Lemonldap*.gz .

portal_cpan:		portal_conf
	@$(MAKE) -C ${SRCPORTALDIR} dist
	@mv ${SRCPORTALDIR}/Lemonldap*.gz .

manager_cpan:	manager_conf
	@$(MAKE) -C ${SRCMANAGERDIR} dist
	@mv ${SRCMANAGERDIR}/Lemonldap*.gz .

documentation:
	@cd doc/ && ../scripts/doc.pl

doxygen:	clean
	$(PERL) -i -pe 's/^(PROJECT_NUMBER\s*=\s*)\d.*$$/$${1}'$(VERSION)'/' Doxyfile
	COLLABORATIVE_GRAPH=1 doxygen Doxyfile
	mkdir doc/devel/tmp
	mv doc/devel/html/inherit* doc/devel/tmp/
	COLLABORATIVE_GRAPH=0 doxygen Doxyfile
	mv -f doc/devel/tmp/* doc/devel/html/
	rm -rf doc/devel/tmp
	$(PERL) -i -pe 's/Graphical Class Hierarchy/Class Collaboration Graph/' doc/devel/html/inherits.html doc/devel/html/tree.html
	# Some files are not generated
	for i in doc/devel/html/*dot; do dot -T png -o $${i/.dot/.png} $$i; rm -f $$i; done

diff: debian-diff

debian-diff:
	@# Portal
	@$(DIFF) $(SRCPORTALDIR)/lib/Lemonldap/NG/Portal $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Portal ||true
	@$(DIFF) $(SRCPORTALDIR)/example/scripts/purgeCentralCache $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/purgeCentralCache ||true
	@$(DIFF) $(SRCPORTALDIR)/example/scripts/buildPortalWSDL $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/buildPortalWSDL ||true
	@for i in $(PORTALSKINS); do \
		$(DIFF) -x 'jquery*' $(SRCPORTALDIR)/example/skins/$$i $(DIFFPREFIX)/usr/share/lemonldap-ng/portal-skins/$$i; \
	done ||true
	@$(DIFF) $(SRCPORTALDIR)/example/index_skin.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/index.pl ||true
	@$(DIFF) $(SRCPORTALDIR)/example/mail.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/mail.pl ||true
	@$(DIFF) $(SRCPORTALDIR)/example/metadata.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/metadata.pl ||true
	@$(DIFF) $(SRCPORTALDIR)/example/openid-configuration.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/openid-configuration.pl ||true
	@$(DIFF) $(SRCPORTALDIR)/example/cdc.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/cdc.pl ||true
	@$(DIFF) $(SRCPORTALDIR)/example/register.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/register.pl ||true
	@# Handler
	@$(DIFF) $(SRCHANDLERDIR)/lib/Lemonldap/NG/Handler $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Handler ||true
	@$(DIFF) $(SRCHANDLERDIR)/example/scripts/purgeLocalCache $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/purgeLocalCache ||true
	@# Common
	@$(DIFF) $(SRCCOMMONDIR)/lib/Lemonldap/NG/Common $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Common ||true
	@$(DIFF) $(SRCCOMMONDIR)/lib/Lemonldap/NG/Common.pm $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Common.pm ||true
	@$(DIFF) $(SRCCOMMONDIR)/scripts/lmMigrateConfFiles2ini $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/lmMigrateConfFiles2ini ||true
	@$(DIFF) $(SRCCOMMONDIR)/scripts/convertConfig $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/convertConfig ||true
	@$(DIFF) $(SRCCOMMONDIR)/scripts/rotateOidcKeys $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/rotateOidcKeys ||true
	@# Manager
	@$(DIFF) $(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Manager ||true
	@$(DIFF) $(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager.pm $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Manager.pm ||true
	@$(DIFF) $(SRCMANAGERDIR)/site/static $(DIFFPREFIX)/usr/share/lemonldap-ng/manager/static ||true
	@$(DIFF) $(SRCMANAGERDIR)/site/templates $(DIFFPREFIX)/user/share/lemonldap-ng/manager/templates ||true
	@$(DIFF) --ignore-matching-lines='set.*get.*\[2\]' $(SRCMANAGERDIR)/scripts/lmConfigEditor $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/lmConfigEditor ||true
	@$(DIFF) --ignore-matching-lines='giveUpPrivileges' $(SRCCOMMONDIR)/scripts/lemonldap-ng-cli $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/lemonldap-ng-cli ||true

default-diff:
	@# Portal
	@$(DIFF) $(SRCPORTALDIR)/lib/Lemonldap/NG/Portal /usr/local/share/perl/$(PERLVERSION)/Lemonldap/NG/Portal ||true
	@$(DIFF) $(SRCPORTALDIR)/example/scripts/purgeCentralCache $(LMPREFIX)/bin/purgeCentralCache ||true
	@$(DIFF) $(SRCPORTALDIR)/example/scripts/buildPortalWSDL $(LMPREFIX)/bin/buildPortalWSDL ||true
	@$(DIFF) $(SRCPORTALDIR)/example/skins $(LMPREFIX)/htdocs/portal/skins ||true
	@$(DIFF) $(SRCPORTALDIR)/example/index_skin.pl $(LMPREFIX)/htdocs/portal/index.pl ||true
	@$(DIFF) $(SRCPORTALDIR)/example/mail.pl $(LMPREFIX)/htdocs/portal/mail.pl ||true
	@$(DIFF) $(SRCPORTALDIR)/example/register.pl $(LMPREFIX)/htdocs/portal/register.pl ||true
	@$(DIFF) $(SRCPORTALDIR)/example/metadata.pl $(LMPREFIX)/htdocs/portal/metadata.pl ||true
	@$(DIFF) $(SRCPORTALDIR)/example/openid-configuration.pl $(LMPREFIX)/htdocs/portal/openid-configuration.pl ||true
	@$(DIFF) $(SRCPORTALDIR)/example/cdc.pl $(LMPREFIX)/htdocs/portal/cdc.pl ||true
	@# Handler
	@$(DIFF) $(SRCHANDLERDIR)/lib/Lemonldap/NG/Handler /usr/local/share/perl/$(PERLVERSION)/Lemonldap/NG/Handler ||true
	@$(DIFF) $(SRCHANDLERDIR)/example/scripts/purgeLocalCache $(LMPREFIX)/bin/purgeLocalCache ||true
	@# Common
	@$(DIFF) $(SRCCOMMONDIR)/lib/Lemonldap/NG/Common /usr/local/share/perl/$(PERLVERSION)/Lemonldap/NG/Common ||true
	@$(DIFF) $(SRCCOMMONDIR)/lib/Lemonldap/NG/Common.pm /usr/local/share/perl/$(PERLVERSION)/Lemonldap/NG/Common.pm ||true
	@$(DIFF) $(SRCCOMMONDIR)/scripts/lmMigrateConfFiles2ini $(LMPREFIX)/bin/lmMigrateConfFiles2ini ||true
	@$(DIFF) $(SRCCOMMONDIR)/scripts/convertConfig $(LMPREFIX)/bin/convertConfig ||true
	@$(DIFF) $(SRCCOMMONDIR)/scripts/rotateOidcKeys $(LMPREFIX)/bin/rotateOidcKeys ||true
	@# Manager
	@$(DIFF) $(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager /usr/local/share/perl/$(PERLVERSION)/Lemonldap/NG/Manager ||true
	@$(DIFF) $(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager.pm /usr/local/share/perl/$(PERLVERSION)/Lemonldap/NG/Manager.pm ||true
	@$(DIFF) $(SRCMANAGERDIR)/site/static $(LMPREFIX)/htdocs/manager/static ||true
	@$(DIFF) $(SRCMANAGERDIR)/site/templates $(LMPREFIX)/htdocs/manager/templates ||true
	@$(DIFF) --ignore-matching-lines='set.*get.*\[2\]' $(SRCMANAGERDIR)/scripts/lmConfigEditor $(LMPREFIX)/bin/lmConfigEditor ||true
	@$(DIFF) --ignore-matching-lines='giveUpPrivileges' $(SRCCOMMONDIR)/scripts/lemonldap-ng-cli $(LMPREFIX)/bin/lemonldap-ng-cli ||true

test-diff:
	@for file in `find lemonldap-ng-*/lib -type f`; do \
		$(DIFF) $$file `echo $$file|sed -e s/lib/blib\\\/lib/`; \
	done

tidy: clean
	find lemon*/ -type f \( -name '*.pm' -or -name '*.pl' -or -name '*.t' \) -print -exec perltidy -b {} \;
	find lemon*/ -name '*.bak' -delete
	$(MAKE) json

tidy-js: clean
	@find $(SRCMANAGERDIR)/site/static/js/ e2e-tests/ $(SRCPORTALDIR)/example \
		  -type f \
		  -name '*.js' \
		! -name 'jq*' \
		! -name 'bootstrap*' \
		! -name '*.min.js' \
		! -name conftree.js \
		  -print \
		  -exec js_beautify -o -s=2 {} \;

# Translation targets
# -------------------

language_code:
	perl -e ' \
		print { \
			fr=> "FR-FR", \
		}->{$(1)}'

test_omegat_%_dir:
	 @if [ ! -d omegat.files/$* ]; then \
	 	echo "omegat.files/$* does not exist"; \
		exit 1; \
	fi

omegat-configuration-file:
	perl -pe 'BEGIN{$$p=`pwd`;chomp $$p;}s/__LANG__/$(OMEGATCODE)/;s/__PWD__/$$p/o;' omegat.files/_base.project >omegat.files/$(LANGCODE)/omegat.project

translation: omegat-configuration-file
	omegat omegat.files/$(LANGCODE) --no-team --quiet

translated-doc: omegat-configuration-file
	omegat omegat.files/$(LANGCODE) --mode=console-translate --quiet 2>/dev/null
	cd po-doc/$(LANGCODE)/pages/documentation && rm -rf current && ln -s $$(find * -maxdepth 0 -type d) current

# 2. Public targets

%-translation: test_omegat_%_dir omegat-%-clean
	$(eval CODE = $(call language_code,$*))
	$(MAKE) translation LANGCODE=$* OMEGATCODE=`$(call language_code,$*)`

%-doc: test_omegat_%_dir omegat-%-clean
	mkdir -p po-doc/$*
	$(eval CODE = $(call language_code,$*))
	$(MAKE) translated-doc LANGCODE=$* OMEGATCODE=`$(call language_code,$*)`
	
omegat-clean:
	rm -rf omegat.files/*/omegat.project omegat.files/*/omegat/project_save*.bak

omegat-%-clean:
	rm -rf po-doc/$*

install_%_doc_site:
	@rm -rf $(RDOCDIR)/$*-doc || true
	@install -v -d $(RDOCDIR)/$*-doc
	@cp -dR -f po-doc/$*/* $(RDOCDIR)/$*-doc

