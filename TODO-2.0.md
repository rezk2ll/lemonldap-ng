Bad usage of "safe":
* lemonldap-ng-portal/lib/Lemonldap/NG/Portal/Auth/SAML.pm: must be compiled in
  init() and have parameters
* lemonldap-ng-portal/lib/Lemonldap/NG/Portal/Lib/Notifications/XML.pm: must
  have parameters

Other:
* securize SOAP session creation by cipher
* Verify securedCookie=3 (strange)
* Test ForceAuth
* Calendar in notifications explorer
* Test for Zero
* "mail" in UserDB/*
* verify activeTimer on/off on screen
* Add test for #173

# Combination

* detect changes
* diff()

# Password

* Enable it during auth

