#!/usr/bin/make

# Prefix for packaging
DESTDIR=

PERL=$$(which perl)
PERLVERSION=`perl -e '$$version = $$^V; $$version =~ s/v//; print $$version'`
SU=su -c
COMPRESS=tar czf
UNCOMPRESS=tar xzf
LISTCOMPRESSED=tar tzf
COMPRESSSUFFIX=tar.gz
# Perl options
#PERLOPTIONS="INSTALLDIRS=vendor"
PERLOPTIONS=

# Default directories install
PREFIX=/usr/local
LMPREFIX=$(PREFIX)/lemonldap-ng
RLMPREFIX=$(DESTDIR)/$(LMPREFIX)
# BIN dirs
BINDIR=$(LMPREFIX)/bin
RBINDIR=$(DESTDIR)/$(BINDIR)
DATADIR=$(LMPREFIX)/data
RDATADIR=$(DESTDIR)/$(DATADIR)

EXAMPLEROOT=`pwd`/example

# Document roots for Apache VirtualHosts
DOCUMENTROOT=$(LMPREFIX)/htdocs
PORTALDIR=$(DOCUMENTROOT)/portal
RPORTALDIR=$(DESTDIR)/$(PORTALDIR)
PORTALSKINSDIR=$(PORTALDIR)/skins
RPORTALSKINSDIR=$(DESTDIR)/$(PORTALSKINSDIR)
MANAGERDIR=$(DOCUMENTROOT)/manager
RMANAGERDIR=$(DESTDIR)/$(MANAGERDIR)
MANAGERSITEDIR=$(MANAGERDIR)
RMANAGERSITEDIR=$(DESTDIR)/$(MANAGERSITEDIR)
MANAGERSTATICDIR=$(MANAGERSITEDIR)/static
RMANAGERSTATICDIR=$(DESTDIR)/$(MANAGERSTATICDIR)
MANAGERRELATIVESTATICDIR=/static
MANAGERPSGIDIR=$(MANAGERSITEDIR)/psgi
RMANAGERPSGIDIR=$(DESTDIR)/$(MANAGERPSGIDIR)
MANAGERTEMPLATESDIR=$(MANAGERSITEDIR)/templates
RMANAGERTEMPLATESDIR=$(DESTDIR)/$(MANAGERTEMPLATESDIR)
DOCDIR=$(DOCUMENTROOT)
RDOCDIR=$(DESTDIR)/$(DOCDIR)
DEFDOCDIR=$(DOCUMENTROOT)/doc
RDEFDOCDIR=$(DESTDIR)/$(DEFDOCDIR)
FRDOCDIR=$(DOCUMENTROOT)/fr-doc
TESTDIR=$(DOCUMENTROOT)/test
RTESTDIR=$(DESTDIR)/$(TESTDIR)
EXAMPLESDIR=$(LMPREFIX)/examples
REXAMPLESDIR=$(DESTDIR)/$(EXAMPLESDIR)
TOOLSDIR=$(LMPREFIX)/tools
RTOOLSDIR=$(DESTDIR)/$(TOOLSDIR)

# Handler dir
HANDLERDIR=$(LMPREFIX)/handler
RHANDLERDIR=$(DESTDIR)/$(HANDLERDIR)

# Configuration dir
CONFDIR=$(LMPREFIX)/etc
RCONFDIR=$(DESTDIR)/$(CONFDIR)
CRONDIR=$(LMPREFIX)/etc/cron.d
RCRONDIR=$(DESTDIR)/$(CRONDIR)
CONFFILENAME=lemonldap-ng.ini
STORAGECONFFILE=$(CONFDIR)/$(CONFFILENAME)

# LL::NG configuration storage dir
FILECONFIGDIR=$(DATADIR)/conf
RFILECONFIGDIR=$(DESTDIR)/$(FILECONFIGDIR)

# LL::NG sessions storage dir
APACHESESSIONFILEDIR=$(DATADIR)/sessions
RAPACHESESSIONFILEDIR=$(DESTDIR)/$(APACHESESSIONFILEDIR)
APACHESESSIONFILELOCKDIR=$(APACHESESSIONFILEDIR)/lock
RAPACHESESSIONFILELOCKDIR=$(DESTDIR)/$(APACHESESSIONFILELOCKDIR)

# LL::NG persistent sessions storage dir
APACHEPSESSIONFILEDIR=$(DATADIR)/psessions
RAPACHEPSESSIONFILEDIR=$(DESTDIR)/$(APACHEPSESSIONFILEDIR)
APACHEPSESSIONFILELOCKDIR=$(APACHEPSESSIONFILEDIR)/lock
RAPACHEPSESSIONFILELOCKDIR=$(DESTDIR)/$(APACHEPSESSIONFILELOCKDIR)

# LL::NG notifications storage dir
APACHEFILENOTIFDIR=$(DATADIR)/notifications
RFILENOTIFDIR=$(DESTDIR)/$(APACHEFILENOTIFDIR)

# LL::NG captcha dir
CAPTCHADIR=$(DATADIR)/captcha
RCAPTCHADIR=$(DESTDIR)/$(CAPTCHADIR)

# Apache user/group
APACHEUSER=
APACHEGROUP=

# Apache version
APACHEVERSION=2.X

# DNS Domain for cookie and virtual hosts
DNSDOMAIN=example.com

# Virtual Host Listen IP and Port (*, *:80, ...)
VHOSTLISTEN=*:80

# Other
VERSION=`head -n1 changelog |sed -e 's/lemonldap-ng (//' -e 's/).*$$//'`
PORTALSKINS=`ls lemonldap-ng-portal/example/skins/`
DIFF=diff -aurN -x '*.bak' -x .svn -x '*.swp' --ignore-matching-lines='.*jquery.*' --ignore-matching-lines='.*lemonldap-ng\.ini.*'

SRCCOMMONDIR=lemonldap-ng-common
SRCHANDLERDIR=lemonldap-ng-handler
SRCPORTALDIR=lemonldap-ng-portal
SRCMANAGERDIR=lemonldap-ng-manager
EXAMPLELANG=en # For static Manager example only
ERASECONFIG=1 # Set to 0 if you do not want to replace your configuration

DIFFPREFIX=

all:	configure common handler manager portal
	@echo
	@echo "Building succeed. Now run :"
	@echo " - make test to verify your installation"
	@echo " - make install to install all"
	@echo
	@echo 'Other targets :'
	@echo " * Partial build :"
	@echo "   - portal, manager, handler"
	@echo " * Doxygen documentation"
	@echo "   - doxygen (to build Doxygen documentation in doc/devel/)"
	@echo
	@echo 'Other targets launched by "make install" :'
	@echo " * Perl libraries install :"
	@echo "   - install_libs          (all Perl libraries)"
	@echo "   - install_portal_libs"
	@echo "   - install_manager_libs"
	@echo "   - install_handler_libs"
	@echo " * Binaries install :"
	@echo "   - install_bin           ($(BINDIR))"
	@echo " * Web sites install :"
	@echo "   - install_site          (all sites including install_doc_site)"
	@echo "   - install_portal_site   ($(PORTALDIR))"
	@echo "   - install_manager_site  ($(MANAGERDIR))"
	@echo "   - install_handler_site  ($(HANDLERDIR))"
	@echo " * Documentation install :"
	@echo "   - install_doc_site      ($(DEFDOCDIR))"
	@echo "   - install_examples_site ($(EXAMPLESDIR))"
	@echo
	@echo "Other languages documentation (fr only for now)"
	@echo " - fr-doc                  (needs OmegaT)"
	@echo " - install_fr_doc_site"
	@echo

#
# Perl libraries configuration
#

configure:	common_conf handler_conf portal_conf manager_conf

common_conf:
	@cd ${SRCCOMMONDIR}; LMNGCONFFILE=$(STORAGECONFFILE) $(PERL) Makefile.PL $(PERLOPTIONS)
	@touch common_conf

handler_conf:
	@cd ${SRCHANDLERDIR}; $(PERL) Makefile.PL $(PERLOPTIONS)
	@touch handler_conf

portal_conf:
	@cd ${SRCPORTALDIR}; $(PERL) Makefile.PL $(PERLOPTIONS)
	@touch portal_conf

manager_conf:
	@cd ${SRCMANAGERDIR}; $(PERL) Makefile.PL $(PERLOPTIONS)
	@touch manager_conf

#
# Perl libraries make
#
common:		common_conf
	@$(MAKE) -C ${SRCCOMMONDIR}
	@touch common

handler:	handler_conf common
	@$(MAKE) -C ${SRCHANDLERDIR}
	@touch handler

portal:		portal_conf common
	@$(MAKE) -C ${SRCPORTALDIR}
	@touch portal

manager:	manager_conf handler
	@$(MAKE) -C ${SRCMANAGERDIR}
	@touch manager

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
	cd ${SRCPORTALDIR} && prove -b -I ../lemonldap-ng-common/blib/lib -I ../lemonldap-ng-handler/blib/lib -I../${SRCPORTALDIR}/blib/lib/ xt
#	PERL_DL_NONLAZY=1 $(PERL) "-MExtUtils::Command::MM" "-e" "test_harness(0, 'lemonldap-ng-common/blib/lib', 'lemonldap-ng-handler/blib/lib', 'lemonldap-ng-manager/blib/lib', 'lemonldap-ng-portal/blib/lib')" extra-tests/*.t

e2e_test:
	protractor e2e-tests/protractor-conf.js

#
# INSTALL
#
install:	install_libs install_bin install_site

#
# Perl libraires install
#
install_libs:	common_install_libs install_handler_libs install_portal_libs install_manager_libs

common_install_libs:		common
	@$(MAKE) -C ${SRCCOMMONDIR} install

install_handler_libs:	handler
	@$(MAKE) -C ${SRCHANDLERDIR} install

install_portal_libs:		portal
	@$(MAKE) -C ${SRCPORTALDIR} install

install_manager_libs:	manager
	@$(MAKE) -C ${SRCMANAGERDIR} install

example:
	$(MAKE) install_site install_bin LMPREFIX=$(EXAMPLEROOT)

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
		${SRCMANAGERDIR}/scripts/lemonldap-ng-cli \
			$(RBINDIR)
	@if [ ! "$(APACHEUSER)" ]; then \
		$(PERL) -i -pe 's#__APACHEUSER__#nobody#g;' $(RBINDIR)/lmConfigEditor; \
		$(PERL) -i -pe 's#__APACHEUSER__#nobody#g;' $(RBINDIR)/lemonldap-ng-cli; \
	else \
		$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' $(RBINDIR)/lmConfigEditor; \
		$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' $(RBINDIR)/lemonldap-ng-cli; \
	fi
	@if [ ! "$(APACHEGROUP)" ]; then \
		$(PERL) -i -pe 's#__APACHEGROUP__#nobody#g;' $(RBINDIR)/lmConfigEditor; \
		$(PERL) -i -pe 's#__APACHEGROUP__#nobody#g;' $(RBINDIR)/lemonldap-ng-cli; \
	else \
		$(PERL) -i -pe 's#__APACHEGROUP__#$(APACHEGROUP)#g;' $(RBINDIR)/lmConfigEditor; \
		$(PERL) -i -pe 's#__APACHEGROUP__#$(APACHEGROUP)#g;' $(RBINDIR)/lemonldap-ng-cli; \
	fi
	@chmod +x $(RBINDIR)/*

#
# SITE INSTALL
#
install_site:	install_manager_site install_portal_site install_handler_site install_test_site install_examples_site install_doc_site
	# Site install
	@install -v -d $(RCONFDIR)
	# Check if erase is wanted
	@if [ "$(ERASECONFIG)" -eq "1" ]; then \
		cp -f _example/etc/portal-apache$(APACHEVERSION).conf $(RCONFDIR); \
		cp -f _example/etc/handler-apache$(APACHEVERSION).conf $(RCONFDIR); \
		cp -f _example/etc/manager-apache$(APACHEVERSION).conf $(RCONFDIR); \
		cp -f _example/etc/test-apache$(APACHEVERSION).conf $(RCONFDIR); \
		cp -f _example/etc/handler-nginx.conf $(RCONFDIR); \
		cp -f _example/etc/test-nginx.conf $(RCONFDIR); \
		cp -f _example/etc/nginx-access-control $(RCONFDIR); \
		cp -f _example/etc/nginx-http-accounting $(RCONFDIR); \
		cp -f _example/etc/nginx-fcgi-accounting $(RCONFDIR); \
		cp -f _example/etc/for_etc_hosts $(RCONFDIR); \
	fi
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g; \
			s#__PORTALDIR__#$(PORTALDIR)/#g; \
			s#__MANAGERDIR__#$(MANAGERDIR)/#g; \
			s#__MANAGERSTATICDIR__#$(MANAGERSTATICDIR)/#g; \
			s#__MANAGERPSGIDIR__#$(MANAGERPSGIDIR)/#g; \
			s#__TESTDIR__#$(TESTDIR)/#g; \
			s#__VHOSTLISTEN__#$(VHOSTLISTEN)#g; \
			s#__DEFDOCDIR__#$(DEFDOCDIR)/#g; \
			s#__FRDOCDIR__#$(FRDOCDIR)/#g;' $(RCONFDIR)/*apache*.conf $(RCONFDIR)/*nginx*.conf
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

install_manager_site:	install_conf_dir
	# Manager install
	@install -v -d ${RMANAGERDIR} $(RMANAGERSTATICDIR) $(RMANAGERPSGIDIR) \
		$(RMANAGERTEMPLATESDIR)
	@cp -pR $(SRCMANAGERDIR)/site/static/* $(RMANAGERSTATICDIR)
	@cp -pR $(SRCMANAGERDIR)/site/templates/* $(RMANAGERTEMPLATESDIR)
	@cp -pR $(SRCMANAGERDIR)/eg/* $(RMANAGERPSGIDIR)
	# Clean svn files
	@rm -rf $$(find ${RMANAGERDIR} ${RMANAGERSTATICDIR} $(RMANAGERPSGIDIR) \
		$(RMANAGERTEMPLATESDIR) $(RCONFDIR) -type d -name .svn)
	$(PERL) -i -pe 's#__MANAGERSTATICDIR__#$(MANAGERRELATIVESTATICDIR)#g' $(RCONFDIR)/$(CONFFILENAME)
	$(PERL) -i -pe 's#__MANAGERTEMPLATESDIR__#$(MANAGERTEMPLATESDIR)#g' $(RCONFDIR)/$(CONFFILENAME)

install_portal_site:	install_conf_dir
	# Portal install
	@install -v -d $(RPORTALDIR) $(RPORTALSKINSDIR) \
		$(RPORTALDIR)/skins/ \
		$(RCRONDIR) $(RCONFDIR)
	@for skin in $$(ls lemonldap-ng-portal/example/skins/); do \
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
	@if [ "$(PORTALDIR)/skins/" != "$(PORTALSKINSDIR)/" ]; then \
		for skin in $$(ls lemonldap-ng-portal/example/skins/); do \
			rm -rf $(RPORTALDIR)/skins/$$skin/; \
			ln -s $(PORTALSKINSDIR)/$$skin $(RPORTALDIR)/skins/$$skin; \
		done; \
	fi
	# Cron files
	@cp -f lemonldap-ng-portal/example/scripts/purgeCentralCache.cron.d $(RCRONDIR)/lemonldap-ng-portal
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
	@cp -f lemonldap-ng-handler/example/scripts/purgeLocalCache.cron.d $(RCRONDIR)/lemonldap-ng-handler
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
	@for i in manager portal handler; do \
		cp -a -f lemonldap-ng-$$i/example $(REXAMPLESDIR)/$$i; \
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
	@cp lemonldap-ng-common/tools/lmConfig.* lemonldap-ng-common/tools/apache-session-mysql.sql $(RTOOLSDIR)
	@cp lemonldap-ng-common/tools/sso.schema $(RTOOLSDIR)
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

distclean:	clean

clean:		common_clean handler_clean portal_clean manager_clean omegat-clean omegat-fr-clean
	@rm -f $$(find */ -name '*bak' -delete)
	@rm -rf $(EXAMPLEROOT) example/ doc/devel
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

debian-local-packages: debian-dist
	mv lemonldap-ng_$(VERSION).orig.$(COMPRESSSUFFIX) /tmp/
	version=$(VERSION) && \
	cd /tmp/ && \
	rm -rf lemonldap-ng-$$version && \
	$(UNCOMPRESS) lemonldap-ng_$$version.orig.$(COMPRESSSUFFIX) && \
	cd lemonldap-ng-$$version && \
	export LOCALBUILD=1; debuild -e LOCALBUILD -us -uc -b --lintian-opts -i \
		--lintian-opts -v --lintian-opts -I --lintian-opts -E \
		--lintian-opts --color --lintian-opts auto --lintian-opts -L \
		--lintian-opts +=pedantic

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

debian-install: debian-local-packages
	cd /tmp/lemonldap-ng-$(VERSION) && \
	$(SU) debi

ubuntu-install:
	$(MAKE) debian-install SU=sudo

diff: debian-diff

debian-diff:
	@# Portal
	@$(DIFF) lemonldap-ng-portal/lib/Lemonldap/NG/Portal $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Portal ||true
	@$(DIFF) lemonldap-ng-portal/example/scripts/purgeCentralCache $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/purgeCentralCache ||true
	@$(DIFF) lemonldap-ng-portal/example/scripts/buildPortalWSDL $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/buildPortalWSDL ||true
	@for i in $(PORTALSKINS); do \
		$(DIFF) -x 'jquery*' lemonldap-ng-portal/example/skins/$$i $(DIFFPREFIX)/usr/share/lemonldap-ng/portal-skins/$$i; \
	done ||true
	@$(DIFF) lemonldap-ng-portal/example/index_skin.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/index.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/mail.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/mail.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/metadata.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/metadata.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/openid-configuration.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/openid-configuration.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/cdc.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/cdc.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/register.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/register.pl ||true
	@# Handler
	@$(DIFF) lemonldap-ng-handler/lib/Lemonldap/NG/Handler $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Handler ||true
	@$(DIFF) lemonldap-ng-handler/example/scripts/purgeLocalCache $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/purgeLocalCache ||true
	@# Common
	@$(DIFF) lemonldap-ng-common/lib/Lemonldap/NG/Common $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Common ||true
	@$(DIFF) lemonldap-ng-common/lib/Lemonldap/NG/Common.pm $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Common.pm ||true
	@$(DIFF) lemonldap-ng-common/scripts/lmMigrateConfFiles2ini $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/lmMigrateConfFiles2ini ||true
	@$(DIFF) lemonldap-ng-common/scripts/convertConfig $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/convertConfig ||true
	@$(DIFF) lemonldap-ng-common/scripts/rotateOidcKeys $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/rotateOidcKeys ||true
	@# Manager
	@$(DIFF) lemonldap-ng-manager/lib/Lemonldap/NG/Manager $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Manager ||true
	@$(DIFF) lemonldap-ng-manager/lib/Lemonldap/NG/Manager.pm $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Manager.pm ||true
	@$(DIFF) lemonldap-ng-manager/eg $(DIFFPREFIX)/var/lib/lemonldap-ng/manager/psgi ||true
	@$(DIFF) lemonldap-ng-manager/site/static $(DIFFPREFIX)/var/lib/lemonldap-ng/manager/static ||true
	@$(DIFF) lemonldap-ng-manager/site/templates $(DIFFPREFIX)/var/lib/lemonldap-ng/manager/templates ||true
	@$(DIFF) --ignore-matching-lines='set.*get.*\[2\]' lemonldap-ng-manager/scripts/lmConfigEditor $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/lmConfigEditor ||true
	@$(DIFF) --ignore-matching-lines='giveUpPrivileges' lemonldap-ng-manager/scripts/lemonldap-ng-cli $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/lemonldap-ng-cli ||true

default-diff:
	@# Portal
	@$(DIFF) lemonldap-ng-portal/lib/Lemonldap/NG/Portal /usr/local/share/perl/$(PERLVERSION)/Lemonldap/NG/Portal ||true
	@$(DIFF) lemonldap-ng-portal/example/scripts/purgeCentralCache $(LMPREFIX)/bin/purgeCentralCache ||true
	@$(DIFF) lemonldap-ng-portal/example/scripts/buildPortalWSDL $(LMPREFIX)/bin/buildPortalWSDL ||true
	@$(DIFF) lemonldap-ng-portal/example/skins $(LMPREFIX)/htdocs/portal/skins ||true
	@$(DIFF) lemonldap-ng-portal/example/index_skin.pl $(LMPREFIX)/htdocs/portal/index.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/mail.pl $(LMPREFIX)/htdocs/portal/mail.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/register.pl $(LMPREFIX)/htdocs/portal/register.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/metadata.pl $(LMPREFIX)/htdocs/portal/metadata.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/openid-configuration.pl $(LMPREFIX)/htdocs/portal/openid-configuration.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/cdc.pl $(LMPREFIX)/htdocs/portal/cdc.pl ||true
	@# Handler
	@$(DIFF) lemonldap-ng-handler/lib/Lemonldap/NG/Handler /usr/local/share/perl/$(PERLVERSION)/Lemonldap/NG/Handler ||true
	@$(DIFF) lemonldap-ng-handler/example/scripts/purgeLocalCache $(LMPREFIX)/bin/purgeLocalCache ||true
	@# Common
	@$(DIFF) lemonldap-ng-common/lib/Lemonldap/NG/Common /usr/local/share/perl/$(PERLVERSION)/Lemonldap/NG/Common ||true
	@$(DIFF) lemonldap-ng-common/lib/Lemonldap/NG/Common.pm /usr/local/share/perl/$(PERLVERSION)/Lemonldap/NG/Common.pm ||true
	@$(DIFF) lemonldap-ng-common/scripts/lmMigrateConfFiles2ini $(LMPREFIX)/bin/lmMigrateConfFiles2ini ||true
	@$(DIFF) lemonldap-ng-common/scripts/convertConfig $(LMPREFIX)/bin/convertConfig ||true
	@$(DIFF) lemonldap-ng-common/scripts/rotateOidcKeys $(LMPREFIX)/bin/rotateOidcKeys ||true
	@# Manager
	@$(DIFF) lemonldap-ng-manager/lib/Lemonldap/NG/Manager /usr/local/share/perl/$(PERLVERSION)/Lemonldap/NG/Manager ||true
	@$(DIFF) lemonldap-ng-manager/lib/Lemonldap/NG/Manager.pm /usr/local/share/perl/$(PERLVERSION)/Lemonldap/NG/Manager.pm ||true
	@$(DIFF) lemonldap-ng-manager/eg $(LMPREFIX)/htdocs/manager/psgi ||true
	@$(DIFF) lemonldap-ng-manager/site/static $(LMPREFIX)/htdocs/manager/static ||true
	@$(DIFF) lemonldap-ng-manager/site/templates $(LMPREFIX)/htdocs/manager/templates ||true
	@$(DIFF) --ignore-matching-lines='set.*get.*\[2\]' lemonldap-ng-manager/scripts/lmConfigEditor $(LMPREFIX)/bin/lmConfigEditor ||true
	@$(DIFF) --ignore-matching-lines='giveUpPrivileges' lemonldap-ng-manager/scripts/lemonldap-ng-cli $(LMPREFIX)/bin/lemonldap-ng-cli ||true

tidy: clean
	find lemon*/ -type f \( -name '*.pm' -or -name '*.pl' -or -name '*.t' \) -print -exec perltidy -b {} \;
	find lemon*/ -name '*.bak' -delete

tidy-js: clean
	find lemon*/ -type f -name '*.js' ! -name 'jq*' ! -name 'bootstrap*' -print -exec scripts/javascript-indent {} \;

# TRANSLATION TARGETS #

# 1. Internal targets

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
	omegat omegat.files/$(LANGCODE) --quiet

translated-doc: omegat-configuration-file
	omegat omegat.files/$(LANGCODE) --mode=console-translate --quiet 2>/dev/null
	cd po-doc/$(LANGCODE)/pages/documentation && rm -rf current && ln -s $$(find * -maxdepth 0 -type d) current

# 2. Public targets

%-translation: test_omegat_%_dir omegat-%-clean
	$(eval CODE = $(call language_code,$*))
	$(MAKE) translation LANGCODE=$* OMEGATCODE=$(CODE)

%-doc: test_omegat_%_dir omegat-%-clean
	mkdir -p po-doc/$*
	$(eval CODE = $(call language_code,$*))
	$(MAKE) translated-doc LANGCODE=$* OMEGATCODE=$(CODE)
	
omegat-clean:
	rm -rf omegat.files/*/omegat.project omegat.files/*/omegat/project_save*.bak

omegat-%-clean:
	rm -rf po-doc/$*

install_%_doc_site:
	@rm -rf $(RDOCDIR)/$*-doc || true
	@install -v -d $(RDOCDIR)/$*-doc
	@cp -dR -f po-doc/$*/* $(RDOCDIR)/$*-doc

