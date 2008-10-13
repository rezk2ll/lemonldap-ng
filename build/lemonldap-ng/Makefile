#!/usr/bin/make

# Example CHROOT
EXAMPLECHROOT=`pwd`/example/
# Subfolders
SYSTEMCONFDIR=$(EXAMPLECHROOT)etc/lemonldap-ng/
SCRIPTSDIR=$(EXAMPLECHROOT)var/lib/lemonldap-ng/
# DNS Domain for cookie and virtual hosts
DNSDOMAIN="example.com"
# LDAP parameters
LDAPHOST="localhost"
LDAPPORT="389"
LDAPSUFFIX="dc=example,dc=net"
# Other
VERSION=`head -n1 changelog |sed -e 's/lemonldap-ng (//' -e 's/).*$$//'`
SRCHANDLERDIR=lemonldap-ng-handler
SRCPORTALDIR=lemonldap-ng-portal
SRCMANAGERDIR=lemonldap-ng-manager
EXAMPLELANG=en # For static Manager only
DESTFILECONFDIR=$(SYSTEMCONFDIR)conf/
DESTSESSIONDIR=$(SCRIPTSDIR)sessions/
DESTLASPDIR=$(SCRIPTSDIR)liberty-alliance-sp-portal
DESTPORTALDIR=$(SCRIPTSDIR)portal/
DESTHANDLERDIR=$(SCRIPTSDIR)handler/
DESTMANAGERDIR=$(SCRIPTSDIR)manager/
DESTDOCSDIR=$(SCRIPTSDIR)docs/

all:	handler manager portal

handler:	handler_conf
	@$(MAKE) -C ${SRCHANDLERDIR}
	@touch handler

portal:		portal_conf
	@$(MAKE) -C ${SRCPORTALDIR}
	@touch portal

manager:	manager_conf
	@$(MAKE) -C ${SRCMANAGERDIR}
	@touch manager

configure:	handler_conf portal_conf manager_conf

handler_conf:
	@cd ${SRCHANDLERDIR}; perl Makefile.PL
	@touch handler_conf

portal_conf:
	@cd ${SRCPORTALDIR}; perl Makefile.PL
	@touch portal_conf

manager_conf:
	@cd ${SRCMANAGERDIR}; perl Makefile.PL
	@touch manager_conf

test:		manager handler portal manager_test handler_test portal_test

manager_test:	manager
	@$(MAKE) -C ${SRCMANAGERDIR} test

handler_test:	handler
	@$(MAKE) -C ${SRCHANDLERDIR} test INST_ARCHLIB=../${SRCMANAGERDIR}/blib/lib/

portal_test:	portal
	@$(MAKE) -C ${SRCPORTALDIR} test INST_ARCHLIB=../${SRCMANAGERDIR}/blib/lib/

install:	handler_install portal_install manager_install

handler_install:	handler
	@$(MAKE) -C ${SRCHANDLERDIR} install
	@touch handler_install

portal_install:		portal
	@$(MAKE) -C ${SRCPORTALDIR} install
	@touch portal_install

manager_install:	manager
	@$(MAKE) -C ${SRCMANAGERDIR} install
	@touch manager_install

distclean:	clean

clean:		handler_clean portal_clean manager_clean
	@rm -rf ${SYSTEMCONFDIR}
	@rm -rf ${SCRIPTSDIR}
	@rm -vf *gz

handler_clean:
	- $(MAKE) -C ${SRCHANDLERDIR} distclean
	@rm -vf handler*

portal_clean:
	- $(MAKE) -C ${SRCPORTALDIR} distclean
	@rm -vf portal*

manager_clean:
	- $(MAKE) -C ${SRCMANAGERDIR} distclean
	@rm -vf manager*

example: all
	@mkdir -p ${DESTFILECONFDIR} ${DESTPORTALDIR} ${DESTHANDLERDIR} ${DESTMANAGERDIR} ${SYSTEMCONFDIR} ${DESTDOCSDIR} ${DESTSESSIONDIR}
	@cp -a ${SRCHANDLERDIR}/example/* ${DESTHANDLERDIR}
	@cp -a ${SRCPORTALDIR}/example/* ${DESTPORTALDIR}
	@rm -rf ${DESTLASPDIR}
	@mv ${DESTPORTALDIR}AuthLA $$(echo ${DESTLASPDIR}  | sed -e 's/\/$$//')
	@cp -a ${SRCMANAGERDIR}/example/* ${DESTMANAGERDIR}
	@cp -a _example/etc/lemonldap-ng/* ${SYSTEMCONFDIR}
	@cp -a _example/var/lib/lemonldap-ng/* ${SCRIPTSDIR}
	@cp -a doc/* ${DESTDOCSDIR}
	@find ${DESTLASPDIR} -type f -exec perl -i -pe 's#__DIR__/?#'${DESTLASPDIR}'#g;s#__CONFDIR__/?#'${DESTFILECONFDIR}'#g' {} \;
	@find ${SCRIPTSDIR} -type f -exec perl -i -pe 's#__DIR__/?#'${SCRIPTSDIR}'#g;s#__SYSCONFDIR__/?#'${SYSTEMCONFDIR}'#g;s#__CONFDIR__/?#'${DESTFILECONFDIR}'#g;s#__SESSIONDIR__/?#'${DESTSESSIONDIR}'#g;s#__DNSDOMAIN__#'${DNSDOMAIN}'#g;s#__LDAPHOST__#'${LDAPHOST}'#g;s#__LDAPPORT__#'${LDAPPORT}'#g;s#__LDAPSUFFIX__#'${LDAPSUFFIX}'#g;' {} \;
	@find ${SYSTEMCONFDIR} -type f -exec perl -i -pe 's#__DIR__/?#'${SCRIPTSDIR}'#g;s#__SESSIONDIR__/?#'${DESTSESSIONDIR}'#g;s#__DNSDOMAIN__#'${DNSDOMAIN}'#g;s#__LDAPHOST__#'${LDAPHOST}'#g;s#__LDAPPORT__#'${LDAPPORT}'#g;s#__LDAPSUFFIX__#'${LDAPSUFFIX}'#g;' {} \;
	@echo
	@echo "LemonLDAP::NG example v${VERSION} is installed with these parameters:"
	@echo "  - System configuration: ${SYSTEMCONFDIR}"
	@echo "  - Scripts: ${SCRIPTSDIR}"
	@echo "  - LemonLDAP::NG Configuration: ${DESTFILECONFDIR}"
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
	@echo "      include ${SYSTEMCONFDIR}apache.conf"
	@echo "    or with Apache-2.x:"
	@echo "      include ${SYSTEMCONFDIR}apache2.conf"
	@echo
	@echo "2 - Run 'make postconf' as root to update /etc/hosts and set UNIX rights"
	@echo
	@echo "3 - Use the manager at http://manager.${DNSDOMAIN}/ (after Apache restart) or edit ${DESTFILECONFDIR}lmConf-1 to modify LemonLDAP::NG configuration."
	@echo "    Edit ${DESTPORTALDIR}apps/apps-list.xml to modify the menu."
	@echo
	@echo "4 - Restart Apache (or Apache2)"
	@echo
	@echo "5 - Try to connect to http://test1.${DNSDOMAIN}/ or http://test2.${DNSDOMAIN}/"

postconf_hosts:
	@cat ${SYSTEMCONFDIR}for_etc_hosts >> /etc/hosts
	@echo "/etc/hosts was updated"

postconf_unixrights:
	@chmod 1777 ${DESTFILECONFDIR}
	@chmod 1777 ${DESTSESSIONDIR}
	@echo "UNIX files permissions set"

postconf: postconf_hosts postconf_unixrights
	@echo "Post configuration done"

production_preconf:
# TODO: modify EXAMPLECHROOT and set it to /
# TODO: ask parameters value (like DNSDOMAIN, LDAPHOST, etc.)

production_install:	production_preconf example

uninstall:	configure handler_uninstall portal_uninstall manager_uninstall

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
	@- cp -pR lemonldap-ng-manager/ lemonldap-ng-portal/ lemonldap-ng-handler/ * lemonldap-ng-$(VERSION)
	@- dir=lemonldap-ng-$(VERSION); find $$dir -name .svn -exec rm -rf {} \; 2>/dev/null
	@rm -rf lemonldap-ng-$(VERSION)/lemonldap-ng-$(VERSION)
	@tar czf lemonldap-ng-$(VERSION).tar.gz lemonldap-ng-$(VERSION)
	@rm -rf lemonldap-ng-$(VERSION)

debian-dist:	dist
	@mv lemonldap-ng-$(VERSION).tar.gz lemonldap-ng_$(VERSION).orig.tar.gz

cpan:	clean configure handler_cpan portal_cpan manager_cpan

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

