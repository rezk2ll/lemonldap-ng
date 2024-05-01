#
# Regular cron jobs for LemonLDAP::NG Handler
#
1 *	* * *	www-data	[ -x /usr/share/lemonldap-ng/bin/purgeLocalCache ] && /usr/share/lemonldap-ng/bin/purgeLocalCache
