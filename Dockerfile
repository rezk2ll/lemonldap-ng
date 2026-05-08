# hadolint global ignore=DL3008
FROM debian:stable-slim

WORKDIR /tmp/
COPY debian/control /tmp/

RUN apt-get update && \
	apt-get install -y --no-install-recommends devscripts/stable equivs/stable libauthen-webauthn-perl/stable yui-compressor/stable python3-sphinx/stable python3-sphinx-bootstrap-theme/stable cpanminus/stable terser/stable coffeescript/stable && \
	mk-build-deps /tmp/control && \
	apt-get install -y --no-install-recommends /tmp/lemonldap-ng-build-deps*deb && \
	apt-get purge -y devscripts equivs && apt-get autoremove -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

COPY Makefile /tmp/
RUN cpanm "Perl::Tidy@$(make tidyversion)"

WORKDIR /app/

ENV PERL5LIB="/app/lemonldap-ng-common/blib/lib/:/app/lemonldap-ng-handler/blib/lib/:/app/lemonldap-ng-portal/blib/lib/:/app/lemonldap-ng-manager/blib/lib/"
ENV LLNG_DEFAULTCONFFILE="/app/dev/lemonldap-ng.ini"

# Install & configure client apps
RUN apt-get update && \
	apt-get install -y --no-install-recommends apache2 libapache2-mod-auth-openidc libapache2-mod-auth-mellon libapache2-mod-auth-cas libapache2-mod-php && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/www/protected/cas /var/www/protected/oidc /var/www/protected/saml
COPY docker/client-apps/cas.php /var/www/protected/cas/index.php
COPY docker/client-apps/oidc.php /var/www/protected/oidc/index.php
COPY docker/client-apps/saml.php /var/www/protected/saml/index.php
RUN sed -i 's/80/0.0.0.0:3000/' /etc/apache2/ports.conf && rm /etc/apache2/sites-enabled/000-default.conf

COPY docker/client-apps/ /tmp/

# OIDC apps
RUN a2enmod auth_openidc
RUN for i in $(seq 1 5); \
	do \
		cp /tmp/oidc.conf "/etc/apache2/sites-enabled/oidc-$i.conf" && \
		sed -i "s/<index>/$i/g" "/etc/apache2/sites-enabled/oidc-$i.conf" ; \
	done

# SAML apps
RUN a2enmod auth_mellon
RUN mkdir -p /etc/apache2/mellon && \
	cp /tmp/idp-metadata.xml /etc/apache2/mellon && \
	for i in $(seq 1 5); \
	do \
		cp /tmp/urn_saml_client.key "/etc/apache2/mellon/urn_saml_client_$i.key" && \
		cp /tmp/urn_saml_client.cert "/etc/apache2/mellon/urn_saml_client_$i.cert" && \
		cp /tmp/urn_saml_client.xml "/etc/apache2/mellon/urn_saml_client_$i.xml" && \
		cp /tmp/saml.conf "/etc/apache2/sites-enabled/saml-$i.conf" && \
		sed -i "s/<index>/$i/g" "/etc/apache2/sites-enabled/saml-$i.conf" ; \
		sed -i "s/<index>/$i/g" "/etc/apache2/mellon/urn_saml_client_$i.xml" ; \
	done

# CAS apps
RUN a2enmod auth_cas
RUN for i in $(seq 1 5); \
	do \
		cp /tmp/cas.conf "/etc/apache2/sites-enabled/cas-$i.conf" && \
		sed -i "s/<index>/$i/g" "/etc/apache2/sites-enabled/cas-$i.conf" ; \
	done

COPY docker/entrypoint.sh /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]
