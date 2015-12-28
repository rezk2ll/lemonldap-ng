# Lemonldap::NG::Manager kinematic

## Main requests (index.pl)

### Main initialization (`new()`)

Simple::new():

* `getConf()`
* load `Menu` and `Display`
* load `Auth/UserDB/PasswordDB/RegisterDB`
* load `IssuerDBx`
* (load `Notifications`)

### Request managing

|   |              Method               |             Comment          | Auth users | Unauth | Proposed PSGI route
|---|-----------------------------------|:-------------------------------------:|---|---|--------------------------
| 0 |           _startSoapServices_     | Manage som path info                  |   | X | /sessions
| 1 | controlUrlOrigin                  | check `url` parameter (+confirmation) | X | X |
| 2 | checkNotifBack                    | check accepted notifications          | X |   |
| 3 | controlExistingSession            | check cookie                          | X |   |
|   |                                   | * display captcha image               |   | X | /captcha
|   |                                   | * logout                              | X |   | /logout
|   |                                   | * remove existing sessions            | X |   |
|   |                                   | * respond to ping                     | X |   | /ping
|   |                                   | * respond to `storeAppsListOrder`     | X |   | /storeAppsListOrder
|   |                                   | * _If user is authenticated, call:_   | X |   |
|   |                                   |   - _issuerForAuthUser_               | X |   |
|   |                                   |   - _authFinish_                      | X |   |
|   |                                   |   - _autoRedirect_                    | X |   |
|   |             _existingSession_     | manage reauthentication and force     | X |   |
|   | _IssuerDB::issuerDBInit_          |                                       |   |   | _(init^)_
|   | _Auth::authInit_                  |                                       |   |   | _(init^)_
| 4 | __Issuer__::issuerForUnAuthUser   |                                       |   | X | Many (SSO, SLO, SOAP,...)
| 5 | __Auth__::extractFormInfo         | First call to auth module             |   | X |
|   | _UserDB::userDBInit_              |                                       |   |   | _(init^)_
| 6 | __UserDB__::getUser               | First call to UserDB: set $\_user     |   | X |
| 7 | __Auth__::setAuthSessionInfo      | Auth module can set infos to session  |   | X |
|   | _PasswordDB::passwordDBInit_      |                                       |   |   | _(init^)_
| 8 | __PasswordDB__::modifyPassword    | Unique call to PasswordDB             |   | ? | ?
| 9 | setSessionInfo                    | Store datas in `$sessionInfo`         |   | X |
| 10 | setMacros                        | Update $sessionInfo with macros       |   | X |
| 11 | __UserDB__::setGroups            | Set `$sessionInfo-&gt;{group}`        |   | X |
| 12 | setPersistentSessionInfo         | Store some datas in persistent DB     |   | X |
| 13 | setLocalGroups                   | Set `$sessionInfo-&gt;{group}`        |   | X |
| 14 | __MailReset__::sendPasswordMail  | Called if password was changed        |   | ? |
| 15 | __Auth__::authenticate           | 3rd call to _Auth_ module (for LDAP)  | P |   |
| 16 | __Auth__::authFinish             | Last call to _Auth_                   | P |   |
| 17 | __UserDB__::userDBFinish         | Last call to _UserDB_                 | P |   |
| 18 | __PasswordDB__::passwordDBFinish | Last call to _PasswordDB_             | P |   |
| 19 | grantSession                     | Apply the rule (user is authenticated | P |   |
| 20 | removeOther                      | Remove other opened sessions          | P |   |
| 21 | store                            | Store session in DB                   | N |   |
| 22 | buildCookie                      | Build LLNG cookie(s)                  | N |   |
| 23 | checkNotification                | Check if current user has messages    | N |   |
| 24 | __IssuerDB__::issuerForAuthUser  |                                       | * |   | Many (SSO, SLO, SOAP, Attribute query,...)
| 25 | autoRedirect                     | Redirects to wanted url               | * |   |

## Other requests

### /saml/metadata (metadata.pl)

Returns the content of Lemonldap::NG::Common::Conf::SAML::Metadata-&gt;serviceToXML()

### /cas.pl

Deliver CAS tickets

### /mail.pl

Launch MailReset

### /register.pl

Registration

### /cdc.pl

Display SAML cross domain cookies

