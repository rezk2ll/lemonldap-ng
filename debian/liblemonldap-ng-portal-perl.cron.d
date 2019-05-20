#
# Regular cron jobs to clean Lemonldap::NG sessions DB
# Launched only if systemd isn't running
#
7 *	* * *	www-data	[ -d /run/systemd/system ] || [ ! -x /usr/share/lemonldap-ng/bin/purgeCentralCache ] || /usr/share/lemonldap-ng/bin/purgeCentralCache
