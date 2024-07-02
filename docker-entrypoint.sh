#!/bin/sh

mkdir -p "$(pwd)/dev/sessions/lock" "$(pwd)/dev/sessions/persistents/lock"

# Create default conf. if missing
[ ! -e "$(pwd)/dev/conf/lmConf-1.json" ] && mkdir -p "$(pwd)/dev/conf/" && cp "$(pwd)/dev/lmConf-1.json" "$(pwd)/dev/conf/"

plackup \
	--port 8080 \
	-I "$(pwd)/lemonldap-ng-common/lib/" \
	-I "$(pwd)/lemonldap-ng-handler/lib/" \
	-I "$(pwd)/lemonldap-ng-manager/lib/" \
	-I "$(pwd)/lemonldap-ng-portal/lib/" \
	--Reload "$(pwd)/lemonldap-ng-common/lib/,$(pwd)/lemonldap-ng-handler/lib/,$(pwd)/lemonldap-ng-manager/lib/,$(pwd)/lemonldap-ng-portal/lib/,$(pwd)/dev/conf/" \
	--app "$(pwd)/dev/llng.psgi"
