#
# Regular cron jobs for the Lemonldap::NG portal
#
1 *	* * *	www-data	test -x /usr/share/lemonldap-ng/bin/purgeLocalCache && /usr/share/lemonldap-ng/bin/purgeLocalCache
