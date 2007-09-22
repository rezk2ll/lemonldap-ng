#!/usr/bin/make

VERSION=`head -n1 changelog |sed -e 's/lemonldap-ng (//' -e 's/).*$$//'`
HANDLERDIR=lemonldap-ng-handler
PORTALDIR=lemonldap-ng-portal
MANAGERDIR=lemonldap-ng-manager
EXAMPLEDIRBUILD=`pwd`/example/
EXAMPLEDIR=$(EXAMPLEDIRBUILD)
EXAMPLECONFDIR=$(EXAMPLEDIR)conf/
EXAMPLELANG=en

all:	handler manager portal

handler:	handler_conf
	$(MAKE) -C ${HANDLERDIR}
	touch handler

portal:		portal_conf
	$(MAKE) -C ${PORTALDIR}
	touch portal

manager:	manager_conf
	$(MAKE) -C ${MANAGERDIR}
	touch manager

configure:	handler_conf portal_conf manager_conf

handler_conf:
	cd ${HANDLERDIR}; perl Makefile.PL INSTALLDIRS=$(INSTALLDIRS)
	touch handler_conf

portal_conf:
	cd ${PORTALDIR}; perl Makefile.PL INSTALLDIRS=$(INSTALLDIRS)
	touch portal_conf

manager_conf:
	cd ${MANAGERDIR}; perl Makefile.PL INSTALLDIRS=$(INSTALLDIRS)
	touch manager_conf

test:		manager_test handler_test portal_test

manager_test:	manager
	$(MAKE) -C ${MANAGERDIR} test

handler_test:	handler
	$(MAKE) -C ${HANDLERDIR} test INST_ARCHLIB=../${MANAGERDIR}/blib/lib/

portal_test:	portal
	$(MAKE) -C ${PORTALDIR} test INST_ARCHLIB=../${MANAGERDIR}/blib/lib/

install:	handler_install portal_install manager_install

handler_install:	handler
	$(MAKE) -C ${HANDLERDIR} install
	touch handler_install

portal_install:		portal
	$(MAKE) -C ${PORTALDIR} install
	touch portal_install

manager_install:	manager
	$(MAKE) -C ${MANAGERDIR} install
	touch manager_install

distclean:	clean

clean:		handler_clean portal_clean manager_clean
	rm -rf example
	find . -name '*.gz' -exec rm -vf {} \;

handler_clean:
	- $(MAKE) -C ${HANDLERDIR} distclean
	rm -vf handler*

portal_clean:
	- $(MAKE) -C ${PORTALDIR} distclean
	rm -vf portal*

manager_clean:
	- $(MAKE) -C ${MANAGERDIR} distclean
	rm -vf manager*

example: all
	mkdir -p ${EXAMPLEDIRBUILD}/portal ${EXAMPLEDIRBUILD}/manager ${EXAMPLEDIRBUILD}/handler ${EXAMPLEDIRBUILD}/conf
	chmod 1777 ${EXAMPLEDIRBUILD}/conf
	cp -a ${HANDLERDIR}/example/* ${EXAMPLEDIRBUILD}/handler
	cp -a ${PORTALDIR}/example/* ${EXAMPLEDIRBUILD}/portal
	cp -a ${MANAGERDIR}/example/* ${EXAMPLEDIRBUILD}/manager
	cp -a _example/* ${EXAMPLEDIRBUILD}
	find ${EXAMPLEDIRBUILD} -type f -exec perl -i -pe 's#__DIR__/?#'${EXAMPLEDIR}'#g;s#__CONFDIR__/?#'${EXAMPLECONFDIR}'#g;' {} \;
	@echo
	@echo "Example is ready."
	@echo
	@echo "1 - Add this in your Apache configuration file:"
	@echo "    with Apache-1.3.x"
	@echo
	@echo "      include ${EXAMPLEDIR}apache.conf"
	@echo
	@echo "    or with Apache-2.x:"
	@echo
	@echo "      include ${EXAMPLEDIR}apache2.conf"
	@echo
	@echo "2 - Add test.example.com and auth.example.com in your /etc/hosts or"
	@echo "    modify apache.conf to use NameVirtualHost, different port or"
	@echo "    address;"
	@echo
	@echo "    cat ${EXAMPLEDIRBUILD}/for_etc_hosts >> /etc/hosts"
	@echo
	@echo "3 - Use the manager at http://manager.example.com/ (after apache restart)"
	@echo "    or edit ${EXAMPLEDIR}/conf/lmConf-1 and set ldapServer and ldapBase."
	@echo
	@echo "4 - Restart Apache (or Apache2)"
	@echo
	@echo "5 - Try to connect to http://test.example.com/"

uninstall:	configure handler_uninstall portal_uninstall manager_uninstall

handler_uninstall:	handler
	$(MAKE) -C ${HANDLERDIR} uninstall
	rm -vf handler_uninstall

portal_uninstall:		portal
	$(MAKE) -C ${PORTALDIR} uninstall
	rm -vf portal_uninstall

manager_uninstall:	manager
	$(MAKE) -C ${MANAGERDIR} uninstall
	rm -vf manager_uninstall

dist:	clean
	- $(MAKE) clean
	mkdir -p lemonldap-ng-$(VERSION)
	- cp -pR lemonldap-ng-manager/ lemonldap-ng-portal/ lemonldap-ng-handler/ * lemonldap-ng-$(VERSION)
	- dir=lemonldap-ng-$(VERSION); find $$dir -name .svn -exec rm -rf {} \; 2>/dev/null
	rm -rf lemonldap-ng-$(VERSION)/lemonldap-ng-$(VERSION)
	tar czf lemonldap-ng-$(VERSION).tar.gz lemonldap-ng-$(VERSION)
	rm -rf lemonldap-ng-$(VERSION)

cpan:	clean configure handler_cpan portal_cpan manager_cpan

handler_cpan:	handler_conf
	$(MAKE) -C ${HANDLERDIR} dist
	mv ${HANDLERDIR}/Lemonldap*.gz .

portal_cpan:		portal_conf
	$(MAKE) -C ${PORTALDIR} dist
	mv ${PORTALDIR}/Lemonldap*.gz .

manager_cpan:	manager_conf
	$(MAKE) -C ${MANAGERDIR} dist
	mv ${MANAGERDIR}/Lemonldap*.gz .

static_example:	example
	mkdir -p ${EXAMPLEDIRBUILD}/static
	cd ${EXAMPLEDIRBUILD}/static/;ln -s ../manager/imgs;cd -
	scripts/make_static_example.pl ${EXAMPLEDIRBUILD}/manager/index.pl ${EXAMPLEDIRBUILD}/static/index.html $(EXAMPLELANG)

documentation:
	cd doc && ../scripts/doc.pl

