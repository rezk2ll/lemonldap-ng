#
# Regular cron jobs for LemonLDAP::NG Portal
#
7 *	* * *	www-data	[ -x /usr/share/lemonldap-ng/bin/purgeCentralCache ] && if [ ! -d /run/systemd/system ]; then /usr/share/lemonldap-ng/bin/purgeCentralCache; fi
