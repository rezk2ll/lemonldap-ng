#
# Regular cron jobs for LemonLDAP::NG Handler
#
17-59/30 *	* * *	www-data	[ -x /usr/share/lemonldap-ng/bin/purgeLocalCache ] && /usr/share/lemonldap-ng/bin/purgeLocalCache
