#
# Regular cron jobs for LemonLDAP::NG Handler
#
1 *	* * *	www-data	[ -x /usr/share/lemonldap-ng/bin/purgeLocalCache ] && if [ ! -d /run/systemd/system ]; then /usr/share/lemonldap-ng/bin/purgeLocalCache; fi
