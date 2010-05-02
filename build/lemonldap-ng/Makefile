#!/usr/bin/make

# Prefix for packaging
DESTDIR=

PERL=$$(which perl)
SU=su -c
COMPRESS=tar czf
UNCOMPRESS=tar xzf
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
MANAGERSKINSDIR=$(MANAGERDIR)/skins
RMANAGERSKINSDIR=$(DESTDIR)/$(MANAGERSKINSDIR)
SESSIONSEXPLORERDIR=$(MANAGERDIR)
RSESSIONSEXPLORERDIR=$(DESTDIR)/$(SESSIONSEXPLORERDIR)
SESSIONSEXPLORERDATADIR=$(SESSIONSEXPLORERDIR)/images
RSESSIONSEXPLORERDATADIR=$(DESTDIR)/$(SESSIONSEXPLORERDATADIR)
DOCDIR=$(DOCUMENTROOT)/doc
RDOCDIR=$(DESTDIR)/$(DOCDIR)
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

# Lemonldap-ng configuration storage dir
FILECONFIGDIR=$(DATADIR)/conf
RFILECONFIGDIR=$(DESTDIR)/$(FILECONFIGDIR)

# Apache::Session::File storage dir
APACHESESSIONFILEDIR=$(DATADIR)/sessions
RAPACHESESSIONFILEDIR=$(DESTDIR)/$(APACHESESSIONFILEDIR)
APACHESESSIONFILELOCKDIR=$(APACHESESSIONFILEDIR)/lock
RAPACHESESSIONFILELOCKDIR=$(DESTDIR)/$(APACHESESSIONFILELOCKDIR)

# Apache user/group
APACHEUSER=
APACHEGROUP=

# Apache version
APACHEVERSION=2

# DNS Domain for cookie and virtual hosts
DNSDOMAIN=example.com

# LDAP parameters
LDAPHOST=localhost
LDAPPORT=389
LDAPSUFFIX=dc=example,dc=com

# Virtual Host Listen IP and Port (*, *:80, ...)
VHOSTLISTEN=*:80

# Other
VERSION=`head -n1 changelog |sed -e 's/lemonldap-ng (//' -e 's/).*$$//'`
PORTALSKINS=`ls lemonldap-ng-portal/example/skins/`
MANAGERSKINS=`ls lemonldap-ng-manager/example/skins/`
DIFF=diff -aburN -x '*.bak' -x .svn -x '*.swp' --ignore-matching-lines='.*jquery.*' --ignore-matching-lines='.*lemonldap-ng\.ini.*'

SRCCOMMONDIR=lemonldap-ng-common
SRCHANDLERDIR=lemonldap-ng-handler
SRCPORTALDIR=lemonldap-ng-portal
SRCMANAGERDIR=lemonldap-ng-manager
EXAMPLELANG=en # For static Manager example only
ERASECONFIG=1 # Set to 0 if you do not want to replace your configuration

# Liberty Alliance support
WITHLA=0 # Set to 1 if you want to install Liberty Alliance portal (deprecated by SAML2 support)
LASPPORTALDIR=$(DOCUMENTROOT)/liberty-alliance-sp-portal
RLASPPORTALDIR=$(DESTDIR)/$(LASPPORTALDIR)

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
	@echo "   - install_doc_site      ($(DOCDIR))"
	@echo "   - install_examples_site ($(EXAMPLESDIR))"
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
	@cp --preserve=mode --remove-destination \
		${SRCPORTALDIR}/example/scripts/purgeCentralCache \
		${SRCPORTALDIR}/example/scripts/buildPortalWSDL \
		${SRCCOMMONDIR}/scripts/convertConfig \
		${SRCCOMMONDIR}/scripts/lmMigrateConfFiles2ini \
		${SRCMANAGERDIR}/example/scripts/lmConfigEditor \
			$(RBINDIR)
	chmod +x $(RBINDIR)/*

#
# SITE INSTALL
#
install_site:	install_manager_site install_portal_site install_handler_site install_test_site install_examples_site install_doc_site
	# Site install
	@install -v -d $(RCONFDIR)
	# Check if erase is wanted
	@if [ "$(ERASECONFIG)" -eq "1" ]; then \
		cp --remove-destination _example/etc/portal-apache$(APACHEVERSION).conf $(RCONFDIR); \
		cp --remove-destination _example/etc/handler-apache$(APACHEVERSION).conf $(RCONFDIR); \
		cp --remove-destination _example/etc/manager-apache$(APACHEVERSION).conf $(RCONFDIR); \
		cp --remove-destination _example/etc/for_etc_hosts $(RCONFDIR); \
	fi
	@$(PERL) -i -pe 's#__HANDLER__#${HANDLERDIR}/MyHandler.pm#; \
			s/__DNSDOMAIN__/$(DNSDOMAIN)/g; \
			s#__PORTALDIR__#$(PORTALDIR)/#g; \
			s#__MANAGERDIR__#$(MANAGERDIR)/#g; \
			s#__TESTDIR__#$(TESTDIR)/#g; \
			s#__VHOSTLISTEN__#$(VHOSTLISTEN)#g; \
			s#__DOCDIR__#$(DOCDIR)/#g;' $(RCONFDIR)/*apache*.conf
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(RCONFDIR)/for_etc_hosts
	# Fix a lost of rights on the main directory
	@chmod 755 $(LMPREFIX)
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
	@echo "1 - Add this in your Apache $(APACHEVERSION) configuration file:"
	@echo "      include ${CONFDIR}/portal-apache$(APACHEVERSION).conf"
	@echo "      include ${CONFDIR}/handler-apache$(APACHEVERSION).conf"
	@echo "      include ${CONFDIR}/manager-apache$(APACHEVERSION).conf"
	@echo
	@echo "2 - Restart Apache:"
	@echo "      apache$(APACHEVERSION)ctl restart"
	@echo
	@echo "3 - Run 'make postconf' as root to update /etc/hosts if your DNS service does not known auth.$(DNSDOMAIN) and manager.$(DNSDOMAIN)"
	@echo
	@echo "4 - Use the manager from localhost at http://manager.${DNSDOMAIN}/ (after Apache restart) to modify LemonLDAP::NG configuration."
	@echo "      Warning: If you access http://manager.${DNSDOMAIN}/ from other host, modify first Apache Manager configuration to allow access from non local address."
	@echo
	@echo "5 - Try to connect to http://test1.${DNSDOMAIN}/ or http://test2.${DNSDOMAIN}/"
	@if [ ! "$(APACHEUSER)" ]; then \
		echo;echo "    Warning, since APACHEUSER was not set, $(APACHESESSIONFILEDIR) and $(CONFDIR) have permissive permissions."; \
		echo "    Fix them by yourself to restrict their view to apache process only"; \
	fi
	@echo

install_manager_site:	install_conf_dir
	# Manager install
	@install -v -d ${RMANAGERDIR} ${RMANAGERSKINSDIR} \
		${RSESSIONSEXPLORERDIR} $(RSESSIONSEXPLORERDATADIR) \
		$(RCONFDIR) ${RMANAGERDIR}/skins/
	@for skin in $$(ls lemonldap-ng-manager/example/skins/); do \
		[ -h $(RMANAGERDIR)/skins/$$skin ] && rm -f $(RMANAGERDIR)/skins/$$skin; \
		install -v -d $(RMANAGERSKINSDIR)/$$skin; \
	done
	@find ${RSESSIONSEXPLORERDIR} -type l -name images -delete
	@cp -pR --remove-destination ${SRCMANAGERDIR}/example/index.pl ${RMANAGERDIR}
	@cp -pR --remove-destination ${SRCMANAGERDIR}/example/skins/* $(RMANAGERSKINSDIR)
	@if [ "$(MANAGERDIR)/skins/" != "$(MANAGERSKINSDIR)/" ]; then \
		for skin in $$(ls lemonldap-ng-manager/example/skins/); do \
			rm -rf $(RMANAGERDIR)/skins/$$skin/; \
			ln -s $(MANAGERSKINSDIR)/$$skin $(RMANAGERDIR)/skins/$$skin; \
		done; \
	fi
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(RCONFDIR)/$(CONFFILENAME)
	# Sessions explorer install
	@cp -pR --remove-destination ${SRCMANAGERDIR}/example/sessions.pl $(RSESSIONSEXPLORERDIR)
	@cp -pR --remove-destination ${SRCMANAGERDIR}/example/images $(RSESSIONSEXPLORERDIR)
	@if [ "${SESSIONSEXPLORERDIR}/images/" != "${SESSIONSEXPLORERDATADIR}/" ]; then \
		mv -f ${RSESSIONSEXPLORERDIR}/images/* ${RSESSIONSEXPLORERDATADIR}; \
		rm -rf ${RMANAGERDIR}/images; \
		ln -s $$(echo ${SESSIONSEXPLORERDATADIR} | sed -e 's/\/$$//') ${RMANAGERDIR}/images; \
	fi
	@rm -rf $$(find ${RMANAGERDIR} ${RMANAGERSKINSDIR} \
		${RSESSIONSEXPLORERDIR} $(RSESSIONSEXPLORERDATADIR) \
		$(RCONFDIR) -type d -name .svn)

install_portal_site:	install_conf_dir
	# Portal install
	@install -v -d $(RPORTALDIR) $(RPORTALSKINSDIR) \
		$(RPORTALDIR)/skins/ \
		$(RCRONDIR) $(RCONFDIR)
	@if [ "$(WITHLA)" -eq "1" ]; then \
		install -v -d $(RLASPPORTALDIR); \
	fi
	@for skin in $$(ls lemonldap-ng-portal/example/skins/); do \
		[ -h $(RPORTALDIR)/skins/$$skin ] && rm -f $(RPORTALDIR)/skins/$$skin; \
		install -v -d $(RPORTALSKINSDIR)/$$skin; \
	done
	@cp -pR --remove-destination ${SRCPORTALDIR}/example/index_skin.pl ${RPORTALDIR}/index.pl
	@cp -pR --remove-destination ${SRCPORTALDIR}/example/error.pl ${RPORTALDIR}
	@cp -pR --remove-destination ${SRCPORTALDIR}/example/mail.pl ${RPORTALDIR}
	@cp -pR --remove-destination ${SRCPORTALDIR}/example/metadata.pl ${RPORTALDIR}
	@cp -pR --remove-destination ${SRCPORTALDIR}/example/apps ${RPORTALDIR}
	@cp -pR --remove-destination ${SRCPORTALDIR}/example/skins/* $(RPORTALSKINSDIR)
	@if [ "$(PORTALDIR)/skins/" != "$(PORTALSKINSDIR)/" ]; then \
		for skin in $$(ls lemonldap-ng-portal/example/skins/); do \
			rm -rf $(RPORTALDIR)/skins/$$skin/; \
			ln -s $(PORTALSKINSDIR)/$$skin $(RPORTALDIR)/skins/$$skin; \
		done; \
	fi
	# L-A portal install
	@if [ "$(WITHLA)" -eq "1" ]; then \
		cp -pR --remove-destination ${SRCPORTALDIR}/example/AuthLA/* $(RLASPPORTALDIR); \
		$(PERL) -i -pe 's#__DIR__#$(LASPPORTALDIR)/#g' $(RLASPPORTALDIR)/index.pl; \
	fi
	# Cron files
	@cp --remove-destination lemonldap-ng-portal/example/scripts/purgeCentralCache.cron.d $(RCRONDIR)/lemonldap-ng
	@if [ ! "$(APACHEUSER)" ]; then \
		$(PERL) -i -pe 's#__APACHEUSER__#root#g;' $(RCRONDIR)/lemonldap-ng; \
	else \
		$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' $(RCRONDIR)/lemonldap-ng; \
	fi
	@$(PERL) -i -pe 's#__BINDIR__#$(BINDIR)#g;' $(RCRONDIR)/lemonldap-ng
	# Clean SVN files
	@rm -rf $$(find ${RPORTALDIR} $(RPORTALSKINSDIR) $(RCRONDIR) $(RCONFDIR) -type d -name .svn)
	@if [ "$(WITHLA)" -eq "1" ]; then \
		rm -rf $$(find $(RLASPPORTALDIR) -type d -name .svn); \
	fi

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
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(RTESTDIR)/index.pl
	@rm -rf $$(find $(RTESTDIR) -type d -name .svn)

install_examples_site:
	# Examples install
	@install -v -d $(REXAMPLESDIR)
	@for i in manager portal handler; do \
		cp -dpR --remove-destination lemonldap-ng-$$i/example $(REXAMPLESDIR)/$$i; \
	done
	@rm -rf $(REXAMPLESDIR)/portal/skins \
		$(REXAMPLESDIR)/manager/skins \
		$(REXAMPLESDIR)/manager/images \
	@rm -rf $$(find $(REXAMPLESDIR) -type d -name .svn)
	@if [ "$(WITHLA)" -eq "1" ]; then \
		$(PERL) -i -pe 's#__DIR__#$(LASPPORTALDIR)#g' $(REXAMPLESDIR)/portal/AuthLA/index.pl; \
	fi
	@$(PERL) -i -pe 's#__SESSIONDIR__#$(APACHESESSIONFILEDIR)/#g;' $(REXAMPLESDIR)/portal/*.pl

install_doc_site:
	@install -v -d $(RDOCDIR)
	@cp -R --remove-destination doc/* $(RDOCDIR)

install_conf_dir:	install_sessions_dir
	# Configuration files install
	@install -v -d $(RCONFDIR) $(RFILECONFIGDIR) $(RTOOLSDIR)
	@if [ "$(ERASECONFIG)" -eq "1" ]; then \
		cp --remove-destination $(SRCCOMMONDIR)/$(CONFFILENAME) $(RCONFDIR); \
		$(PERL) -i -pe 's#^dirName\s*=\s*.*#dirName = $(FILECONFIGDIR)#g' $(RCONFDIR)/$(CONFFILENAME); \
	fi
	@cp _example/conf/lmConf-1 $(RFILECONFIGDIR)
	@$(PERL) -000 -i -pe "s#^(globalStorageOptions\\n\\s+)'[^\\n]*?'\$$#\$${1}\'\\\$$data1 = {&39;Directory&39; => &39;$(APACHESESSIONFILEDIR)&39;,&39;LockDirectory&39; => &39;$(APACHESESSIONFILELOCKDIR)&39;};'#m" $(RFILECONFIGDIR)/lmConf-1
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g;\
		s/__LDAPPORT__/$(LDAPPORT)/g;\
		s/__LDAPHOST__/$(LDAPHOST)/g;\
		s/__LDAPSUFFIX__/$(LDAPSUFFIX)/g;\
		s#__SESSIONDIR__#$(APACHESESSIONFILEDIR)#g;' $(RFILECONFIGDIR)/lmConf-1
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
	@cp lemonldap-ng-common/tools/sso.schema $(RTOOLSDIR)
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

postconf_hosts:
	@cat ${SYSTEMCONFDIR}/for_etc_hosts >> /etc/hosts
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
	@- cp -pR lemonldap-ng-common/ lemonldap-ng-manager/ lemonldap-ng-portal/ lemonldap-ng-handler/ * lemonldap-ng-$(VERSION)
	@- dir=lemonldap-ng-$(VERSION); find $$dir -name .svn -exec rm -rf {} \; 2>/dev/null
	@- find $$dir -name '*.bak' -delete
	@rm -rf lemonldap-ng-$(VERSION)/lemonldap-ng-$(VERSION)
	@$(COMPRESS) lemonldap-ng-$(VERSION).$(COMPRESSSUFFIX) lemonldap-ng-$(VERSION)
	@rm -rf lemonldap-ng-$(VERSION)

debian-dist:	dist
	@mv lemonldap-ng-$(VERSION).$(COMPRESSSUFFIX) lemonldap-ng_$(VERSION).orig.$(COMPRESSSUFFIX)

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
	@for i in Common Portal Handler Manager; do \
		$(UNCOMPRESS) Lemonldap-NG-$$i-*.$(COMPRESSSUFFIX) \
			$$($(COMPRESS) tzf Lemonldap-NG-$$i-*.$(COMPRESSSUFFIX) |grep META.yml); \
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

sub_static_example: install_site
	mkdir -p ${EXAMPLEROOT}/static
	cd ${EXAMPLEROOT}/static/;cp -a ../manager/{skins} .;cd -
	../scripts/make_static_example.pl ${DESTMANAGERDIR}/index.pl ${SCRIPTSDIR}/static/index.html $(EXAMPLELANG)

static_example:
	@$(MAKE) sub_static_example LMPREFIX=$(EXAMPLEROOT)

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

distclean:	clean

clean:		common_clean handler_clean portal_clean manager_clean
	@rm -f $$(find */ -name '*bak' -delete)
	@rm -rf $(EXAMPLEROOT) example/ doc/devel
	@rm -vf *gz *zip
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

debian-packages: debian-dist
	mv lemonldap-ng_$(VERSION).orig.$(COMPRESSSUFFIX) /tmp/
	version=$(VERSION) && \
	cd /tmp/ && \
	rm -rf lemonldap-ng-$$version && \
	$(UNCOMPRESS) lemonldap-ng_$$version.orig.$(COMPRESSSUFFIX) && \
	cd lemonldap-ng-$$version && \
	export LOCALBUILD=1; debuild -us -uc

debian-install: debian-packages
	cd /tmp/lemonldap-ng-$(VERSION) && \
	$(SU) debi

ubuntu-install:
	$(MAKE) debian-install SU=sudo

diff: debian-diff

debian-diff:
	@# Portal
	@$(DIFF) lemonldap-ng-portal/lib/Lemonldap/NG/Portal /usr/share/perl5/Lemonldap/NG/Portal ||true
	@$(DIFF) lemonldap-ng-portal/example/scripts/purgeCentralCache /usr/share/lemonldap-ng/bin/purgeCentralCache ||true
	@$(DIFF) lemonldap-ng-portal/example/scripts/buildPortalWSDL /usr/share/lemonldap-ng/bin/buildPortalWSDL ||true
	@for i in $(PORTALSKINS); do \
		$(DIFF) -x 'jquery*' lemonldap-ng-portal/example/skins/$$i /usr/share/lemonldap-ng/portal-skins/$$i; \
	done ||true
	@$(DIFF) lemonldap-ng-portal/example/index_skin.pl /var/lib/lemonldap-ng/portal/index.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/error.pl /var/lib/lemonldap-ng/portal/error.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/mail.pl /var/lib/lemonldap-ng/portal/mail.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/metadata.pl /var/lib/lemonldap-ng/portal/metadata.pl ||true
	@# Handler
	@$(DIFF) lemonldap-ng-handler/lib/Lemonldap/NG/Handler /usr/share/perl5/Lemonldap/NG/Handler ||true
	@# Common
	@$(DIFF) lemonldap-ng-common/lib/Lemonldap/NG/Common /usr/share/perl5/Lemonldap/NG/Common ||true
	@$(DIFF) lemonldap-ng-common/lib/Lemonldap/NG/Common.pm /usr/share/perl5/Lemonldap/NG/Common.pm ||true
	@$(DIFF) lemonldap-ng-common/scripts/lmMigrateConfFiles2ini /usr/share/lemonldap-ng/bin/lmMigrateConfFiles2ini ||true
	@$(DIFF) lemonldap-ng-common/scripts/convertConfig /usr/share/lemonldap-ng/bin/convertConfig ||true
	@# Manager
	@$(DIFF) lemonldap-ng-manager/lib/Lemonldap/NG/Manager /usr/share/perl5/Lemonldap/NG/Manager ||true
	@$(DIFF) lemonldap-ng-manager/lib/Lemonldap/NG/Manager.pm /usr/share/perl5/Lemonldap/NG/Manager.pm ||true
	@$(DIFF) lemonldap-ng-manager/example/images /usr/share/lemonldap-ng/sessions-explorer-imgs ||true
	@$(DIFF) lemonldap-ng-manager/example/index.pl /var/lib/lemonldap-ng/manager/index.pl ||true
	@$(DIFF) lemonldap-ng-manager/example/sessions.pl /var/lib/lemonldap-ng/manager/sessions.pl ||true
	@for i in $(MANAGERSKINS); do \
		$(DIFF) -x 'jquery*' lemonldap-ng-manager/example/skins/$$i /usr/share/lemonldap-ng/manager-skins/$$i; \
	done ||true

default-diff:
	@# Portal
	@$(DIFF) lemonldap-ng-portal/lib/Lemonldap/NG/Portal /usr/local/share/perl/5.10.0/Lemonldap/NG/Portal ||true
	@$(DIFF) lemonldap-ng-portal/example/scripts/purgeCentralCache $(LMPREFIX)/bin/purgeCentralCache ||true
	@$(DIFF) lemonldap-ng-portal/example/scripts/buildPortalWSDL $(LMPREFIX)/bin/buildPortalWSDL ||true
	@$(DIFF) lemonldap-ng-portal/example/skins $(LMPREFIX)/htdocs/portal/skins ||true
	@$(DIFF) lemonldap-ng-portal/example/index_skin.pl $(LMPREFIX)/htdocs/portal/index.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/error.pl $(LMPREFIX)/htdocs/portal/error.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/mail.pl $(LMPREFIX)/htdocs/portal/mail.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/metadata.pl $(LMPREFIX)/htdocs/portal/metadata.pl ||true
	@# Handler
	@$(DIFF) lemonldap-ng-handler/lib/Lemonldap/NG/Handler /usr/local/share/perl/5.10.0/Lemonldap/NG/Handler ||true
	@$(DIFF) lemonldap-ng-handler/example/MyHandler.pm $(LMPREFIX)/handler/MyHandler.pm ||true
	@# Common
	@$(DIFF) lemonldap-ng-common/lib/Lemonldap/NG/Common /usr/local/share/perl/5.10.0/Lemonldap/NG/Common ||true
	@$(DIFF) lemonldap-ng-common/lib/Lemonldap/NG/Common.pm /usr/local/share/perl/5.10.0/Lemonldap/NG/Common.pm ||true
	@$(DIFF) lemonldap-ng-common/scripts/lmMigrateConfFiles2ini $(LMPREFIX)/bin/lmMigrateConfFiles2ini ||true
	@$(DIFF) lemonldap-ng-common/scripts/convertConfig $(LMPREFIX)/bin/convertConfig ||true
	@# Manager
	@$(DIFF) lemonldap-ng-manager/lib/Lemonldap/NG/Manager /usr/local/share/perl/5.10.0/Lemonldap/NG/Manager ||true
	@$(DIFF) lemonldap-ng-manager/lib/Lemonldap/NG/Manager.pm /usr/local/share/perl/5.10.0/Lemonldap/NG/Manager.pm ||true
	@$(DIFF) lemonldap-ng-manager/example/images $(LMPREFIX)/htdocs/manager/images ||true
	@$(DIFF) lemonldap-ng-manager/example/skins $(LMPREFIX)/htdocs/manager/skins ||true
	@$(DIFF) lemonldap-ng-manager/example/index.pl $(LMPREFIX)/htdocs/manager/index.pl ||true
	@$(DIFF) lemonldap-ng-manager/example/sessions.pl $(LMPREFIX)/htdocs/manager/sessions.pl ||true

tidy: clean
	find lemon*/ -type f \( -name '*.pm' -or -name '*.pl' -or -name '*.t' \) -exec perltidy -b {} \;
	find lemon*/ -name '*.bak' -delete

