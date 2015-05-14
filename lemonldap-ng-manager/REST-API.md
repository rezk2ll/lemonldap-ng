# Lemonldap::NG::Manager REST API

## Configurations

* List of available configuration: `/confs`
* Last configuration number: `/confs/latest/cfgNum`
* Configuration metadatas: `/confs/<cfgNum|latest>`
* Key value: `/confs/<cfgNum|latest>/<key>`
* Full configuration (for saving): `/confs/<cfgNum|latest>?full`

Examples:

* `/confs/latest/portal`
* `/confs/184/portal`
* `/confs/184/virtualHosts/test1.example.com/locationRules`

### Available verbs:

* `GET`: see above
* `POST /confs`: push a new configuration (or a saved one)
  `POST /confs?force=yes`: push a new configuration even if another has been
  posted before
* _`DELETE /confs/<cfgNum>`: not allowed_, administrator has to push an older
  with `?force=yes`

**And perhaps:**

* `PUT /confs/prepared/<key>`: modify a value in the future configuration
* `DELETE /confs/prepared/<path>/<key>`: delete a hash entry (virtual host for
  example)
* `GET /confs/prepared/<key>`: get value from prepared configuration if exists,
  get current value otherwise

## Sessions

* Sessions list: `/sessions`
* Session: `/sessions/<hash>`
* **TODO**: Session key: `/sessions/<hash>/<key>`
* Delete session: `DELETE /sessions/<hash>`
* Filters:
  * All connected users which username start by a letter:
    `/sessions?_whatToTrace=<letter>*&groupBy=_whatToTrace`
  * User's sessions: `/sessions?_whatToTrace=foo.bar`
  * IP's sessions: `/sessions?ip=1.2.3.4`
  * Double sessions by IP: `/sessions?doubleIP`
* Group by:
  * First letter of Connected users: `/sessions?groupBy=substr(_whatToTrace,1)`
* Order:
  * Sessions sorted by user: `/sessions?orderBy=_whatToTrace`

Note that sessions are grouped automaticaly.

## Notifications

* Notifications list: `/notifications/actives`
* Notification: `/notifications/actives/<notif_id>`
* Notified elements list: `/notifications/done`
* Notified element: `/notifications/done/<notif_id>`
* New session: `POST /notifications`
* Filters:
  * All notifications for users which name starts by a letter:
    `/notifications?_whatToTrace=<letter>*&groupBy=_whatToTrace`
  * User's notifications: `/notifications/(actives|done)?_whatToTrace=foo.bar`
* Mark as notified: `PUT /notifications/actives/<notif_id> done=1`
* Delete notofication: `DELETE /notifications/done/<notif_id>`
