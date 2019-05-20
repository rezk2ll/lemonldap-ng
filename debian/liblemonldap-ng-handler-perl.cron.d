#
# Regular cron jobs for the Lemonldap::NG handler
# Launched only if systemd isn't running
#
17-59/30 *	* * *	www-data	[ -d /run/systemd/system ] || [ ! -x /usr/share/lemonldap-ng/bin/purgeLocalCache ] || /usr/share/lemonldap-ng/bin/purgeLocalCache
