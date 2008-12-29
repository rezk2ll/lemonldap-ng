#!/usr/bin/make

# Prefix for packaging
DESTDIR=

PERL=$$(which perl)
# Perl options
#PERLOPTIONS="INSTALLDIRS=vendor"
PERLOPTIONS=

# Default directories install
PREFIX=/usr/local/
LMPREFIX=$(PREFIX)lemonldap-ng/
RLMPREFIX=$(DESTDIR)$(LMPREFIX)
# BIN dirs
BINDIR=$(LMPREFIX)bin/
RBINDIR=$(DESTDIR)$(BINDIR)
DATADIR=$(LMPREFIX)data/
RDATADIR=$(DESTDIR)$(DATADIR)


EXAMPLEROOT=`pwd`/example/

# Document roots for Apache VirtualHosts
DOCUMENTROOT=$(LMPREFIX)htdocs/
PORTALDIR=$(DOCUMENTROOT)portal/
RPORTALDIR=$(DESTDIR)$(PORTALDIR)
PORTALSKINSDIR=$(PORTALDIR)skins/
RPORTALSKINSDIR=$(DESTDIR)$(PORTALSKINSDIR)
LASPPORTALDIR=$(DOCUMENTROOT)liberty-alliance-sp-portal/
RLASPPORTALDIR=$(DESTDIR)$(LASPPORTALDIR)
MANAGERDIR=$(DOCUMENTROOT)manager/
RMANAGERDIR=$(DESTDIR)$(MANAGERDIR)
MANAGERDATADIR=$(MANAGERDIR)imgs/
RMANAGERDATADIR=$(DESTDIR)$(MANAGERDATADIR)
SESSIONSEXPLORERDIR=$(MANAGERDIR)
RSESSIONSEXPLORERDIR=$(DESTDIR)$(SESSIONSEXPLORERDIR)
SESSIONSEXPLORERDATADIR=$(SESSIONSEXPLORERDIR)images/
RSESSIONSEXPLORERDATADIR=$(DESTDIR)$(SESSIONSEXPLORERDATADIR)
DOCDIR=$(DOCUMENTROOT)doc/
RDOCDIR=$(DESTDIR)$(DOCDIR)
TESTDIR=$(DOCUMENTROOT)test/
RTESTDIR=$(DESTDIR)$(TESTDIR)
EXAMPLESDIR=$(LMPREFIX)examples/
REXAMPLESDIR=$(DESTDIR)$(EXAMPLESDIR)
TOOLSDIR=$(LMPREFIX)tools/
RTOOLSDIR=$(DESTDIR)$(TOOLSDIR)

# Handler dir
HANDLERDIR=$(LMPREFIX)handler/
RHANDLERDIR=$(DESTDIR)$(HANDLERDIR)

# Configuration dir
CONFDIR=$(LMPREFIX)etc/
RCONFDIR=$(DESTDIR)$(CONFDIR)
CRONDIR=$(LMPREFIX)etc/cron.d/
RCRONDIR=$(DESTDIR)$(CRONDIR)
STORAGECONFFILE=$(CONFDIR)storage.conf

# Lemonldap-ng configuration storage dir
FILECONFIGDIR=$(DATADIR)conf/
RFILECONFIGDIR=$(DESTDIR)$(FILECONFIGDIR)

# Apache::Session::File storage dir
APACHESESSIONFILEDIR=$(DATADIR)sessions/
RAPACHESESSIONFILEDIR=$(DESTDIR)$(APACHESESSIONFILEDIR)
APACHESESSIONFILELOCKDIR=$(APACHESESSIONFILEDIR)lock/
RAPACHESESSIONFILELOCKDIR=$(DESTDIR)$(APACHESESSIONFILELOCKDIR)
APACHEUSER=
APACHEGROUP=

# DNS Domain for cookie and virtual hosts
DNSDOMAIN=example.com

# LDAP parameters
LDAPHOST=localhost
LDAPPORT=389
LDAPSUFFIX=dc=example,dc=net

# Other
VERSION=`head -n1 changelog |sed -e 's/lemonldap-ng (//' -e 's/).*$$//'`
SRCCOMMONDIR=lemonldap-ng-common/
SRCHANDLERDIR=lemonldap-ng-handler/
SRCPORTALDIR=lemonldap-ng-portal/
SRCMANAGERDIR=lemonldap-ng-manager/
EXAMPLELANG=en # For static Manager example only

all:	configure common handler manager portal

#
# Perl libraries configuration
#
configure:	common_conf handler_conf portal_conf manager_conf

common_conf:
	@cd ${SRCCOMMONDIR}; LMNGCONFFILE=$(STORAGECONFFILE) perl Makefile.PL $(PERLOPTIONS)
	@touch common_conf

handler_conf:
	@cd ${SRCHANDLERDIR}; perl Makefile.PL $(PERLOPTIONS)
	@touch handler_conf

portal_conf:
	@cd ${SRCPORTALDIR}; perl Makefile.PL $(PERLOPTIONS)
	@touch portal_conf

manager_conf:
	@cd ${SRCMANAGERDIR}; perl Makefile.PL $(PERLOPTIONS)
	@touch manager_conf

#
# Perl libraries make
#
common:		common_conf
	@$(MAKE) -C ${SRCCOMMONDIR}
	@touch common

handler:	handler_conf
	@$(MAKE) -C ${SRCHANDLERDIR}
	@touch handler

portal:		portal_conf
	@$(MAKE) -C ${SRCPORTALDIR}
	@touch portal

manager:	manager_conf
	@$(MAKE) -C ${SRCMANAGERDIR}
	@touch manager

test:		common handler portal manager common_test handler_test portal_test manager_test

common_test:	common
	@$(MAKE) -C ${SRCCOMMONDIR} test

handler_test:	handler common_test
	@$(MAKE) -C ${SRCHANDLERDIR} test FULLPERL="$(PERL) -I../${SRCCOMMONDIR}/blib/lib/"

portal_test:	portal handler_test common_test
	@$(MAKE) -C ${SRCPORTALDIR} test FULLPERL="$(PERL) -I../${SRCCOMMONDIR}/blib/lib/ -I../${SRCHANDLERDIR}/blib/lib/"

manager_test:	manager handler_test common_test
	@$(MAKE) -C ${SRCMANAGERDIR} test FULLPERL="$(PERL) -I../${SRCCOMMONDIR}/blib/lib/ -I../${SRCHANDLERDIR}/blib/lib/"

#
# INSTALL
#
install:	install_libs install_bin install_site

#
# Perl libraires install
#
install_libs:	common_install_libs handler_install_libs portal_install_libs manager_install_libs

common_install_libs:		common
	@$(MAKE) -C ${SRCCOMMONDIR} install

handler_install_libs:	handler
	@$(MAKE) -C ${SRCHANDLERDIR} install

portal_install_libs:		portal
	@$(MAKE) -C ${SRCPORTALDIR} install

manager_install_libs:	manager
	@$(MAKE) -C ${SRCMANAGERDIR} install

example:
	$(MAKE) install_site LMPREFIX=$(EXAMPLEROOT)

install_bin:	install_libs install_conf_dir
	# Binary install
	@install -v -d $(RBINDIR)
	cp --preserve=mode --remove-destination ${SRCPORTALDIR}/example/scripts/purgeCentralCache $(RBINDIR)
	cp --preserve=mode --remove-destination ${SRCMANAGERDIR}/example/scripts/lmConfigEditor $(RBINDIR)

#
# SITE INSTALL
#
install_site:	install_manager_site install_portal_site install_handler_site install_test_site install_examples_site
	# Site install
	@install -v -d $(RCONFDIR)
	# Apache configuration files
	@cp --remove-destination _example/etc/apache* $(RCONFDIR)
	@perl -i -pe 's#__HANDLER__#${HANDLERDIR}MyHandler.pm#; \
		s/__DNSDOMAIN__/$(DNSDOMAIN)/g; \
		s#__PORTALDIR__#$(PORTALDIR)#g; \
		s#__MANAGERDIR__#$(MANAGERDIR)#g; \
		s#__TESTDIR__#$(TESTDIR)#g; \
		s#__DOCDIR__#$(DOCDIR)#g;' $(RCONFDIR)/apache*
	# File for /etc/hosts inclusion
	@cp --remove-destination _example/etc/for_etc_hosts $(RCONFDIR)
	@perl -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(RCONFDIR)for_etc_hosts
	#
	@echo
	@echo "LemonLDAP::NG v${VERSION} is installed with these parameters:"
	@echo "  - System configuration: ${CONFDIR}"
	@echo "  - DNS domain (for cookies and virtual hosts): ${DNSDOMAIN}"
	@echo "  - LDAP parameters:"
	@echo "    - Host: ${LDAPHOST}"
	@echo "    - Port: ${LDAPPORT}"
	@echo "    - Suffix: ${LDAPSUFFIX}"
	@echo
	@echo "To finish configuration:"
	@echo
	@echo "1 - Add this in your Apache configuration file:"
	@echo "    with Apache-1.3.x"
	@echo "      include ${CONFDIR}apache.conf"
	@echo "    or with Apache-2.x:"
	@echo "      include ${CONFDIR}apache2.conf"
	@echo
	@echo "2 - Restart Apache (or Apache2)"
	@echo
	@echo "3 - Run 'make postconf' as root to update /etc/hosts" if your DNS service does not known auth.$(DNSDOMAIN) and manager.$(DNSDOMAIN)
	@echo
	@echo "4 - Use the manager at http://manager.${DNSDOMAIN}/ (after Apache restart) to modify LemonLDAP::NG configuration."
	@echo "    Edit ${RCONFDIR}apps/apps-list.xml to modify the menu."
	@echo
	@echo "5 - Try to connect to http://test1.${DNSDOMAIN}/ or http://test2.${DNSDOMAIN}/"
	@if [ "$(APACHEUSER)" == "" ]; then \
		echo;echo "    Warning, since APACHEUSER was not set, $(APACHESESSIONFILEDIR) and $(CONFDIR) have permissive permissions."; \
		echo "    Fix them by yourself to restrict their view to apache process only"; \
	fi
	@echo

install_manager_site:	install_conf_dir
	# Manager install
	@install -v -d ${RMANAGERDIR} ${RMANAGERDATADIR} \
		${RSESSIONSEXPLORERDIR} $(RSESSIONSEXPLORERDATADIR) \
		$(RCONFDIR)
	@find ${RMANAGERDIR} -type l -name imgs -delete
	@find ${RMANAGERDIR} -type l -name images -delete
	@cp -pR --remove-destination ${SRCMANAGERDIR}example/* ${RMANAGERDIR}
	@rm -rf $$(find ${RMANAGERDIR} -type d -name .svn) ${RMANAGERDIR}scripts ${RMANAGERDIR}mrtg ${RMANAGERDIR}soapserver.pl
	@if [ "${RMANAGERDIR}imgs/" != "${RMANAGERDATADIR}" ]; then \
		mv -f ${RMANAGERDIR}imgs/* ${RMANAGERDATADIR}; \
		rm -rf ${RMANAGERDIR}imgs; \
		ln -s $$(echo ${MANAGERDATADIR} | sed -e 's/\/$$//') ${RMANAGERDIR}imgs; \
	fi
	# apply.conf install
	@mv ${RMANAGERDIR}apply.conf $(RCONFDIR)
	@perl -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(RCONFDIR)apply.conf
	@perl -i -pe 's#__APPLYCONFFILE__#$(CONFDIR)apply.conf#' ${RMANAGERDIR}index.pl
	# Sessions explorer install
	@if [ "${MANAGERDIR}" != "$(SESSIONSEXPLORERDIR)" ]; then mv -f ${RMANAGERDIR}sessions.pl $(RSESSIONSEXPLORERDIR); fi
	@if [ "${MANAGERDIR}images/" != "${SESSIONSEXPLORERDATADIR}" ]; then \
		mv -f ${RMANAGERDIR}images/* ${RSESSIONSEXPLORERDATADIR}; \
		rm -rf ${RMANAGERDIR}images; \
		ln -s $$(echo ${SESSIONSEXPLORERDATADIR} | sed -e 's/\/$$//') ${RMANAGERDIR}images; \
	fi
	@rm -rf $$(find ${RMANAGERDIR} ${RMANAGERDATADIR} \
		${RSESSIONSEXPLORERDIR} $(RSESSIONSEXPLORERDATADIR) \
		$(RCONFDIR) -type d -name .svn)

install_portal_site:	install_conf_dir
	# Portal install
	@install -v -d $(RPORTALDIR) $(RPORTALSKINSDIR) \
		$(RPORTALDIR)skins/ $(RLASPPORTALDIR) \
		$(RCRONDIR) $(RCONFDIR)
	@for skin in $$(ls lemonldap-ng-portal/example/skins/); do \
		[ -h $(RPORTALDIR)skins/$$skin ] && rm -f $(RPORTALDIR)skins/$$skin; \
		install -v -d $(RPORTALSKINSDIR)$$skin; \
	done
	@cp -pR --remove-destination ${SRCPORTALDIR}example/index_skin.pl ${RPORTALDIR}index.pl
	@cp -pR --remove-destination ${SRCPORTALDIR}example/error.pl ${RPORTALDIR}
	@perl -i -pe 's#__SKINDIR__#$(PORTALDIR)skins#; \
		s#__APPSXMLFILE__#$(CONFDIR)apps-list.xml#;' ${RPORTALDIR}index.pl ${RPORTALDIR}error.pl
	@cp -pR --remove-destination ${SRCPORTALDIR}example/skins/* $(RPORTALSKINSDIR)
	@if [ "$(PORTALDIR)skins/" != "$(PORTALSKINSDIR)" ]; then \
		for skin in $$(ls lemonldap-ng-portal/example/skins/); do \
			rm -rf $(RPORTALDIR)skins/$$skin/; \
			ln -s $(PORTALSKINSDIR)$$skin $(RPORTALDIR)skins/$$skin; \
		done; \
	fi
	@cp --remove-destination _example/etc/apps-list* $(RCONFDIR)
	@perl -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(RCONFDIR)apps-list.xml
	# L-A portal install
	@cp -pR --remove-destination ${SRCPORTALDIR}example/AuthLA/* $(RLASPPORTALDIR)
	@perl -i -pe 's#__DIR__#$(LASPPORTALDIR)#g' $(RLASPPORTALDIR)index.pl
	# Cron files
	@cp --remove-destination lemonldap-ng-portal/example/scripts/purgeCentralCache.cron.d $(RCRONDIR)
	# Clean SVN files
	@rm -rf $$(find ${RPORTALDIR} $(RPORTALSKINSDIR) $(RLASPPORTALDIR) $(RCRONDIR) $(RCONFDIR) -type d -name .svn)

install_handler_site:	install_conf_dir
	# Handler install
	@install -v -d ${RHANDLERDIR}
	@cp --remove-destination ${SRCHANDLERDIR}/example/MyHandler.pm ${RHANDLERDIR}
	@rm -rf $$(find $(RHANDLERDIR) -type d -name .svn)

install_test_site:
	# Test site install
	@install -v -d $(RTESTDIR)
	@cp -pR --remove-destination _example/test/* $(RTESTDIR)
	@rm -rf $$(find $(RTESTDIR) -type d -name .svn)
	@perl -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(RTESTDIR)index.pl
	@rm -rf $$(find $(RTESTDIR) -type d -name .svn)

install_examples_site:
	# Examples install
	@install -v -d $(REXAMPLESDIR)
	@for i in manager portal handler; do \
		cp -dpR --remove-destination lemonldap-ng-$$i/example $(REXAMPLESDIR)/$$i; \
	done
	@rm -rf $(REXAMPLESDIR)portal/skins \
		$(REXAMPLESDIR)manager/imgs \
		$(REXAMPLESDIR)manager/images \
	@rm -rf $$(find $(REXAMPLESDIR) -type d -name .svn)
	@perl -i -pe 's#__DIR__#$(LASPPORTALDIR)#g' $(REXAMPLESDIR)portal/AuthLA/index.pl
	@perl -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(REXAMPLESDIR)manager/apply.conf
	@perl -i -pe 's#__APPLYCONFFILE__#$(CONFDIR)apply.conf#' $(REXAMPLESDIR)manager/*.pl
	@perl -i -pe 's#__SKINDIR__#$(PORTALDIR)skins#; \
		s#__APPSXMLFILE__#$(CONFDIR)apps-list.xml#; \
		s#__SESSIONDIR__#$(APACHESESSIONFILEDIR)#g;' $(REXAMPLESDIR)portal/*.pl

install_conf_dir:	install_sessions_dir
	# Configuration files install
	@install -v -d $(RCONFDIR) $(RFILECONFIGDIR) $(RTOOLSDIR)
	@cp --remove-destination $(SRCCOMMONDIR)storage.conf $(RCONFDIR)
	@perl -i -pe 's#^dirName = .*#dirName = $(FILECONFIGDIR)#g' $(RCONFDIR)storage.conf
	@cp _example/conf/lmConf-1 $(RFILECONFIGDIR)
	@perl -000 -i -pe "s#^(globalStorageOptions\\n\\s+)'[^\\n]*?'\$$#\$${1}\'\\\$$data1 = {&39;Directory&39; => &39;$(APACHESESSIONFILEDIR)&39;,&39;LockDirectory&39; => &39;$(APACHESESSIONFILELOCKDIR)&39;};'#m" $(RFILECONFIGDIR)lmConf-1
	@perl -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g;\
		s/__LDAPPORT__/$(LDAPPORT)/g;\
		s/__LDAPHOST__/$(LDAPHOST)/g;\
		s/__LDAPSUFFIX__/$(LDAPSUFFIX)/g;\
		s#__SESSIONDIR__#$(APACHESESSIONFILEDIR)#g;' $(RFILECONFIGDIR)lmConf-1
	@if [ "$(APACHEUSER)" != "" ]; then \
		chown $(APACHEUSER) $(RFILECONFIGDIR) || exit 1; \
		if [ "$(APACHEGROUP)" != "" ]; then \
			chgrp $(APACHEGROUP) $(RFILECONFIGDIR) || exit 1; \
		fi; \
		chmod 770 $(RFILECONFIGDIR); \
	else \
		chmod 777 $(RFILECONFIGDIR); \
	fi
	@cp lemonldap-ng-common/tools/lmConfig.mysql lemonldap-ng-common/tools/apache-session-mysql.sql $(RTOOLSDIR)
	@rm -rf $$(find $(RCONFDIR) $(RFILECONFIGDIR) $(RTOOLSDIR) -type d -name .svn)

install_sessions_dir:
	@install -m 777 -v -d $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR)
	# Fix Apache::Session directories permissions
	@if [ "$(APACHEUSER)" != "" ]; then \
		chown $(APACHEUSER) $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR) || exit 1; \
		if [ "$(APACHEGROUP)" != "" ]; then \
			chgrp $(APACHEGROUP) $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR) || exit 1; \
		fi; \
		chmod 770 $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR); \
	else \
		chmod 777 $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR); \
	fi

TODO:

postconf_hosts:
	@cat ${SYSTEMCONFDIR}for_etc_hosts >> /etc/hosts
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
	@- $(MAKE) clean
	@mkdir -p lemonldap-ng-$(VERSION)
	@- cp -pR lemonldap-ng-common/ lemonldap-ng-manager/ lemonldap-ng-portal/ lemonldap-ng-handler/ * lemonldap-ng-$(VERSION)
	@- dir=lemonldap-ng-$(VERSION); find $$dir -name .svn -exec rm -rf {} \; 2>/dev/null
	@rm -rf lemonldap-ng-$(VERSION)/lemonldap-ng-$(VERSION)
	@tar czf lemonldap-ng-$(VERSION).tar.gz lemonldap-ng-$(VERSION)
	@rm -rf lemonldap-ng-$(VERSION)

debian-dist:	dist
	@mv lemonldap-ng-$(VERSION).tar.gz lemonldap-ng_$(VERSION).orig.tar.gz

cpan:	clean configure common_cpan handler_cpan portal_cpan manager_cpan

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

static_example:	example
	@mkdir -p ${SCRIPTSDIR}static/
	@cd ${SCRIPTSDIR}static/;cp -a ../manager/{imgs,theme} .;cd -
	@../scripts/make_static_example.pl ${DESTMANAGERDIR}index.pl ${SCRIPTSDIR}static/index.html $(EXAMPLELANG)

documentation:
	@cd doc/ && ../scripts/doc.pl

doxygen:	clean
	doxygen Doxyfile

distclean:	clean

clean:		common_clean handler_clean portal_clean manager_clean
	@rm -rf $(EXAMPLEROOT)
	@rm -vf *gz

common_clean:
	- $(MAKE) -C ${SRCCOMMONDIR} distclean
	@rm -vf common*

handler_clean:
	- $(MAKE) -C ${SRCHANDLERDIR} distclean
	@rm -vf handler*

portal_clean:
	- $(MAKE) -C ${SRCPORTALDIR} distclean
	@rm -vf portal*

manager_clean:
	- $(MAKE) -C ${SRCMANAGERDIR} distclean
	@rm -vf manager*

