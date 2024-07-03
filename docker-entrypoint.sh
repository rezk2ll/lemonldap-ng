#!/bin/sh

# Run given command-line, if any
if [ -n "$1" ]; then
	rm lemonldap-ng-*/Makefile
	make
	echo "Running command-line:" "$@"
	"$@"
	exit
fi

export LLNG_DEFAULTCONFFILE="/app/dev/lemonldap-ng.ini"

mkdir -p "$(pwd)/dev/sessions/lock" "$(pwd)/dev/sessions/persistents/lock"

plackup \
	--port 8080 \
	-I "$(pwd)/lemonldap-ng-common/lib/" \
	-I "$(pwd)/lemonldap-ng-handler/lib/" \
	-I "$(pwd)/lemonldap-ng-manager/lib/" \
	-I "$(pwd)/lemonldap-ng-portal/lib/" \
	--Reload "$(pwd)/lemonldap-ng-common/lib/,$(pwd)/lemonldap-ng-handler/lib/,$(pwd)/lemonldap-ng-manager/lib/,$(pwd)/lemonldap-ng-portal/lib/" \
	--app "$(pwd)/dev/llng.psgi"
