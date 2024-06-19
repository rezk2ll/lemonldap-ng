#!/bin/sh

mkdir -p "$(pwd)/dev/sessions/lock" "$(pwd)/dev/sessions/persistents/lock"

plackup \
	--port 8080 \
	-I "$(pwd)/lemonldap-ng-common/lib/" \
	-I "$(pwd)/lemonldap-ng-handler/lib/" \
	-I "$(pwd)/lemonldap-ng-manager/lib/" \
	-I "$(pwd)/lemonldap-ng-portal/lib/" \
	--Reload "$(pwd)/lemonldap-ng-common/lib/,$(pwd)/lemonldap-ng-handler/lib/,$(pwd)/lemonldap-ng-manager/lib/,$(pwd)/lemonldap-ng-portal/lib/" \
	--app "$(pwd)/dev/llng.psgi"
