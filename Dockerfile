FROM debian:stable-slim

WORKDIR /tmp/
COPY debian/control /tmp/

RUN apt-get update && \
	apt-get install -y --no-install-recommends devscripts/stable equivs/stable libauthen-webauthn-perl/stable && \
	mk-build-deps /tmp/control && \
	apt-get install -y --no-install-recommends /tmp/lemonldap-ng-build-deps*deb && \
	apt-get purge -y devscripts equivs && apt-get autoremove -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /app/

ENV PERL5LIB="/app/lemonldap-ng-common/blib/lib/:/app/lemonldap-ng-handler/blib/lib/:/app/lemonldap-ng-portal/blib/lib/:/app/lemonldap-ng-manager/blib/lib/"

COPY docker-entrypoint.sh /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]
