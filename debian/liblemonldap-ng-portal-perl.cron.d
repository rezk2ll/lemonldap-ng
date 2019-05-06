#
# Regular cron jobs for LemonLDAP::NG Portal
#
*/10 *	* * *	www-data	[ -x /usr/share/lemonldap-ng/bin/purgeCentralCache ] && /usr/share/lemonldap-ng/bin/purgeCentralCache
