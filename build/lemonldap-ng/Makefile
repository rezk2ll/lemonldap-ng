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

test:		all common_test handler_test portal_test manager_test extra_test

common_test:	common
	@$(MAKE) -C ${SRCCOMMONDIR} test

handler_test:	handler common_test
	@$(MAKE) -C ${SRCHANDLERDIR} test FULLPERL="$(PERL) -I../${SRCCOMMONDIR}/blib/lib/"

portal_test:	portal handler_test common_test
	@$(MAKE) -C ${SRCPORTALDIR} test FULLPERL="$(PERL) -I../${SRCCOMMONDIR}/blib/lib/ -I../${SRCHANDLERDIR}/blib/lib/"

manager_test:	manager handler_test common_test
	@$(MAKE) -C ${SRCMANAGERDIR} test FULLPERL="$(PERL) -I../${SRCCOMMONDIR}/blib/lib/ -I../${SRCHANDLERDIR}/blib/lib/"

extra_test:	all
	PERL_DL_NONLAZY=1 $(PERL) "-MExtUtils::Command::MM" "-e" "test_harness(0, 'lemonldap-ng-common/blib/lib', 'lemonldap-ng-handler/blib/lib', 'lemonldap-ng-manager/blib/lib', 'lemonldap-ng-portal/blib/lib')" extra-tests/*.t

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
		${SRCHANDLERDIR}/example/scripts/purgeLocalCache \
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
		${RSESSIONSEXPLORERDIR} \
		$(RCONFDIR) ${RMANAGERDIR}/skins/
	@for skin in $$(ls lemonldap-ng-manager/example/skins/); do \
		[ -h $(RMANAGERDIR)/skins/$$skin ] && rm -f $(RMANAGERDIR)/skins/$$skin; \
		install -v -d $(RMANAGERSKINSDIR)/$$skin; \
	done
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
	@rm -rf $$(find ${RMANAGERDIR} ${RMANAGERSKINSDIR} \
		${RSESSIONSEXPLORERDIR} \
		$(RCONFDIR) -type d -name .svn)

install_portal_site:	install_conf_dir
	# Portal install
	@install -v -d $(RPORTALDIR) $(RPORTALSKINSDIR) \
		$(RPORTALDIR)/skins/ \
		$(RCRONDIR) $(RCONFDIR)
	@for skin in $$(ls lemonldap-ng-portal/example/skins/); do \
		[ -h $(RPORTALDIR)/skins/$$skin ] && rm -f $(RPORTALDIR)/skins/$$skin; \
		install -v -d $(RPORTALSKINSDIR)/$$skin; \
	done
	@cp -pR --remove-destination ${SRCPORTALDIR}/example/index_skin.pl ${RPORTALDIR}/index.pl
	@cp -pR --remove-destination ${SRCPORTALDIR}/example/mail.pl ${RPORTALDIR}
	@cp -pR --remove-destination ${SRCPORTALDIR}/example/metadata.pl ${RPORTALDIR}
	@cp -pR --remove-destination ${SRCPORTALDIR}/example/cdc.pl ${RPORTALDIR}
	@tar -cf - -C ${SRCPORTALDIR}/example/skins/ $$(ls ${SRCPORTALDIR}/example/skins/) |tar -xvf - -C $(RPORTALSKINSDIR)
	#@cp -a --remove-destination ${SRCPORTALDIR}/example/skins/* $(RPORTALSKINSDIR)
	@if [ "$(PORTALDIR)/skins/" != "$(PORTALSKINSDIR)/" ]; then \
		for skin in $$(ls lemonldap-ng-portal/example/skins/); do \
			rm -rf $(RPORTALDIR)/skins/$$skin/; \
			ln -s $(PORTALSKINSDIR)/$$skin $(RPORTALDIR)/skins/$$skin; \
		done; \
	fi
	# Cron files
	@cp --remove-destination lemonldap-ng-portal/example/scripts/purgeCentralCache.cron.d $(RCRONDIR)/lemonldap-ng-portal
	@if [ ! "$(APACHEUSER)" ]; then \
		$(PERL) -i -pe 's#__APACHEUSER__#root#g;' $(RCRONDIR)/lemonldap-ng-portal; \
	else \
		$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' $(RCRONDIR)/lemonldap-ng-portal; \
	fi
	@$(PERL) -i -pe 's#__BINDIR__#$(BINDIR)#g;' $(RCRONDIR)/lemonldap-ng-portal
	# Clean SVN files
	@rm -rf $$(find ${RPORTALDIR} $(RPORTALSKINSDIR) $(RCRONDIR) $(RCONFDIR) -type d -name .svn)

install_handler_site:	install_conf_dir
	# Handler install
	@install -v -d ${RHANDLERDIR}
	@cp --remove-destination ${SRCHANDLERDIR}/example/MyHandler.pm ${RHANDLERDIR}
	@cp --remove-destination ${SRCHANDLERDIR}/example/MyHandlerZimbra.pm ${RHANDLERDIR}
	@cp --remove-destination ${SRCHANDLERDIR}/example/MyHandlerSympa.pm ${RHANDLERDIR}
	@cp --remove-destination ${SRCHANDLERDIR}/example/MyUpdateCookieHandler.pm ${RHANDLERDIR}
	@cp --remove-destination lemonldap-ng-handler/example/scripts/purgeLocalCache.cron.d $(RCRONDIR)/lemonldap-ng-handler
	@if [ ! "$(APACHEUSER)" ]; then \
		$(PERL) -i -pe 's#__APACHEUSER__#root#g;' $(RCRONDIR)/lemonldap-ng-handler; \
	else \
		$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' $(RCRONDIR)/lemonldap-ng-handler; \
	fi
	@$(PERL) -i -pe 's#__BINDIR__#$(BINDIR)#g;' $(RCRONDIR)/lemonldap-ng-handler
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
	@rm -rf $$(find $(REXAMPLESDIR) -type d -name .svn)
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
	@cp lemonldap-ng-common/tools/lmConfig.* lemonldap-ng-common/tools/apache-session-mysql.sql $(RTOOLSDIR)
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
	@cp -pRH $$(find * -maxdepth 0|grep -v lemonldap-ng-$(VERSION)) lemonldap-ng-$(VERSION)
	@rm -rf $$(find lemonldap-ng-$(VERSION) -name .svn -print)
	@find $$dir -name '*.bak' -delete
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
	@rm -f doc/pages/documentation/latest
	@cd doc/ && ../scripts/doc.pl
	@rm -rf doc/pages/documentation/latest
	@ln -s $$(perl -e '$$h{sprintf("%03d\.%03d\.%03d",split/\./,$$_)}=$$_ foreach(@ARGV); \
		foreach(sort keys %h){$$last="$$h{$$_}\n"};print $$last;' \
		$$(find doc/pages/documentation/ -maxdepth 1 -mindepth 1 -type d ! \
		-name .svn ! -name latest -printf "%f\n") \
	) doc/pages/documentation/latest

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

clean:		common_clean handler_clean portal_clean manager_clean
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
	@$(DIFF) lemonldap-ng-portal/lib/Lemonldap/NG/Portal $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Portal ||true
	@$(DIFF) lemonldap-ng-portal/example/scripts/purgeCentralCache $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/purgeCentralCache ||true
	@$(DIFF) lemonldap-ng-portal/example/scripts/buildPortalWSDL $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/buildPortalWSDL ||true
	@for i in $(PORTALSKINS); do \
		$(DIFF) -x 'jquery*' lemonldap-ng-portal/example/skins/$$i $(DIFFPREFIX)/usr/share/lemonldap-ng/portal-skins/$$i; \
	done ||true
	@$(DIFF) lemonldap-ng-portal/example/index_skin.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/index.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/mail.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/mail.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/metadata.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/metadata.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/cdc.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/portal/cdc.pl ||true
	@# Handler
	@$(DIFF) lemonldap-ng-handler/lib/Lemonldap/NG/Handler $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Handler ||true
	@$(DIFF) lemonldap-ng-handler/example/scripts/purgeLocalCache $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/purgeLocalCache ||true
	@# Common
	@$(DIFF) lemonldap-ng-common/lib/Lemonldap/NG/Common $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Common ||true
	@$(DIFF) lemonldap-ng-common/lib/Lemonldap/NG/Common.pm $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Common.pm ||true
	@$(DIFF) lemonldap-ng-common/scripts/lmMigrateConfFiles2ini $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/lmMigrateConfFiles2ini ||true
	@$(DIFF) lemonldap-ng-common/scripts/convertConfig $(DIFFPREFIX)/usr/share/lemonldap-ng/bin/convertConfig ||true
	@# Manager
	@$(DIFF) lemonldap-ng-manager/lib/Lemonldap/NG/Manager $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Manager ||true
	@$(DIFF) lemonldap-ng-manager/lib/Lemonldap/NG/Manager.pm $(DIFFPREFIX)/usr/share/perl5/Lemonldap/NG/Manager.pm ||true
	@$(DIFF) lemonldap-ng-manager/example/index.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/manager/index.pl ||true
	@$(DIFF) lemonldap-ng-manager/example/sessions.pl $(DIFFPREFIX)/var/lib/lemonldap-ng/manager/sessions.pl ||true
	@for i in $(MANAGERSKINS); do \
		$(DIFF) -x 'jquery*' lemonldap-ng-manager/example/skins/$$i $(DIFFPREFIX)/usr/share/lemonldap-ng/manager-skins/$$i; \
	done ||true

default-diff:
	@# Portal
	@$(DIFF) lemonldap-ng-portal/lib/Lemonldap/NG/Portal /usr/local/share/perl/5.10.0/Lemonldap/NG/Portal ||true
	@$(DIFF) lemonldap-ng-portal/example/scripts/purgeCentralCache $(LMPREFIX)/bin/purgeCentralCache ||true
	@$(DIFF) lemonldap-ng-portal/example/scripts/buildPortalWSDL $(LMPREFIX)/bin/buildPortalWSDL ||true
	@$(DIFF) lemonldap-ng-portal/example/skins $(LMPREFIX)/htdocs/portal/skins ||true
	@$(DIFF) lemonldap-ng-portal/example/index_skin.pl $(LMPREFIX)/htdocs/portal/index.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/mail.pl $(LMPREFIX)/htdocs/portal/mail.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/metadata.pl $(LMPREFIX)/htdocs/portal/metadata.pl ||true
	@$(DIFF) lemonldap-ng-portal/example/cdc.pl $(LMPREFIX)/htdocs/portal/cdc.pl ||true
	@# Handler
	@$(DIFF) lemonldap-ng-handler/lib/Lemonldap/NG/Handler /usr/local/share/perl/5.10.0/Lemonldap/NG/Handler ||true
	@$(DIFF) lemonldap-ng-handler/example/MyHandler.pm $(LMPREFIX)/handler/MyHandler.pm ||true
	@$(DIFF) lemonldap-ng-handler/example/MyHandlerZimbra.pm $(LMPREFIX)/handler/MyHandlerZimbra.pm ||true
	@$(DIFF) lemonldap-ng-handler/example/MyHandlerSympa.pm $(LMPREFIX)/handler/MyHandlerSympa.pm ||true
	@$(DIFF) lemonldap-ng-handler/example/scripts/purgeLocalCache $(LMPREFIX)/bin/purgeLocalCache ||true
	@# Common
	@$(DIFF) lemonldap-ng-common/lib/Lemonldap/NG/Common /usr/local/share/perl/5.10.0/Lemonldap/NG/Common ||true
	@$(DIFF) lemonldap-ng-common/lib/Lemonldap/NG/Common.pm /usr/local/share/perl/5.10.0/Lemonldap/NG/Common.pm ||true
	@$(DIFF) lemonldap-ng-common/scripts/lmMigrateConfFiles2ini $(LMPREFIX)/bin/lmMigrateConfFiles2ini ||true
	@$(DIFF) lemonldap-ng-common/scripts/convertConfig $(LMPREFIX)/bin/convertConfig ||true
	@# Manager
	@$(DIFF) lemonldap-ng-manager/lib/Lemonldap/NG/Manager /usr/local/share/perl/5.10.0/Lemonldap/NG/Manager ||true
	@$(DIFF) lemonldap-ng-manager/lib/Lemonldap/NG/Manager.pm /usr/local/share/perl/5.10.0/Lemonldap/NG/Manager.pm ||true
	@$(DIFF) lemonldap-ng-manager/example/skins $(LMPREFIX)/htdocs/manager/skins ||true
	@$(DIFF) lemonldap-ng-manager/example/index.pl $(LMPREFIX)/htdocs/manager/index.pl ||true
	@$(DIFF) lemonldap-ng-manager/example/sessions.pl $(LMPREFIX)/htdocs/manager/sessions.pl ||true

tidy: clean
	find lemon*/ -type f \( -name '*.pm' -or -name '*.pl' -or -name '*.t' \) -print -exec perltidy -b {} \;
	find lemon*/ -name '*.bak' -delete

