Parameter list
==============


.. tip::

    Click on a column header to sort table. The attribute key
    name can be used directly in ``lemonldap-ng.ini`` or in Perl scripts to
    override configuration parameters (see
    :doc:`configuration location<configlocation>`).

Main parameters
---------------

======================================================= ==================================================================================== ====== ======= ======= =============
Key name                                                Documentation                                                                        Portal Handler Manager ini file only
======================================================= ==================================================================================== ====== ======= ======= =============
ADPwdExpireWarning                                      AD password expire warning                                                           ✔
ADPwdMaxAge                                             AD password max age                                                                  ✔
AuthLDAPFilter                                          LDAP filter for auth search                                                          ✔
LDAPFilter                                              Default LDAP filter                                                                  ✔
SMTPAuthPass                                            Password to use to send mails                                                        ✔
SMTPAuthUser                                            Login to use to send mails                                                           ✔
SMTPPort                                                Fix SMTP port                                                                        ✔
SMTPServer                                              SMTP Server                                                                          ✔
SMTPTLS                                                 TLS protocol to use with SMTP                                                        ✔
SMTPTLSOpts                                             TLS/SSL options for SMTP                                                             ✔
SSLAuthnLevel                                           SSL authentication level                                                             ✔
SSLVar                                                                                                                                       ✔
SSLVarIf                                                                                                                                     ✔
activeTimer                                             Enable timers on portal pages                                                        ✔
adaptativeAuthenticationLevelRules                      Adaptative authentication level rules                                                ✔
apacheAuthnLevel                                        Apache authentication level                                                          ✔
applicationList                                         Applications list                                                                    ✔
authChoiceAuthBasic                                     Auth module used by AuthBasic handler                                                ✔
authChoiceFindUser                                      Auth module used by FindUser plugin                                                  ✔
authChoiceModules                                       Hash list of Choice strings                                                          ✔
authChoiceParam                                         Applications list                                                                    ✔
authentication                                          Authentication module                                                                ✔
autoSigninRules                                         List of auto signin rules                                                            ✔
available2F                                             Available second factor modules                                                      ✔                      ✔
available2FSelfRegistration                             Available self-registration modules for second factor                                ✔                      ✔
avoidAssignment                                         Avoid assignment in expressions                                                      ✔      ✔
browsersDontStorePassword                               Avoid browsers to store users password                                               ✔
bruteForceProtection                                    Enable brute force attack protection                                                 ✔
bruteForceProtectionIncrementalTempo                    Enable incremental lock time for brute force attack protection                       ✔
bruteForceProtectionLockTimes                           Incremental lock time values for brute force attack protection                       ✔
bruteForceProtectionMaxAge                              Max age between current and first failed login                                       ✔
bruteForceProtectionMaxFailed                           Max allowed failed login                                                             ✔
bruteForceProtectionMaxLockTime                         Max lock time                                                                        ✔
bruteForceProtectionTempo                               Lock time                                                                            ✔
captcha                                                 Captcha backend module                                                               ✔      ✔
captchaOptions                                          Captcha module options                                                               ✔      ✔
captcha_login_enabled                                   Captcha on login page                                                                ✔
captcha_mail_enabled                                    Captcha on password reset page                                                       ✔
captcha_register_enabled                                Captcha on account creation page                                                     ✔
captcha_size                                            Captcha size                                                                         ✔
casAccessControlPolicy                                  CAS access control policy                                                            ✔
casAppMetaDataOptions                                   Root of CAS app options                                                              ✔                      [1]
casAttr                                                 Pivot attribute for CAS                                                              ✔
casAttributes                                           CAS exported attributes                                                              ✔
casAuthnLevel                                           CAS authentication level                                                             ✔
casSrvMetaDataOptions                                   Root of CAS server options                                                           ✔                      [1]
casStorage                                              Apache::Session module to store CAS user data                                        ✔
casStorageOptions                                       Apache::Session module parameters                                                    ✔
casStrictMatching                                       Disable host-based matching of CAS services                                          ✔
casTicketExpiration                                     Expiration time of Service and Proxy tickets                                         ✔
cda                                                     Enable Cross Domain Authentication                                                   ✔      ✔
certificateResetByMailCeaAttribute                                                                                                           ✔
certificateResetByMailCertificateAttribute                                                                                                   ✔
certificateResetByMailStep1Body                         Custom Certificate reset mail body                                                   ✔
certificateResetByMailStep1Subject                      Mail subject for certificate reset email                                             ✔
certificateResetByMailStep2Body                         Custom confirm Certificate reset mail body                                           ✔
certificateResetByMailStep2Subject                      Mail subject for reset confirmation                                                  ✔
certificateResetByMailURL                               URL of certificate reset page                                                        ✔
certificateResetByMailValidityDelay                                                                                                          ✔
cfgAuthor                                               Name of the author of the current configuration                                      ✔                      ✔
cfgAuthorIP                                             Uploader IP address of the current configuration                                     ✔                      ✔
cfgDate                                                 Timestamp of the current configuration                                               ✔                      ✔
cfgLog                                                  Configuration update log                                                             ✔                      ✔
cfgNum                                                  Enable Cross Domain Authentication                                                   ✔                      ✔
cfgVersion                                              Version of LLNG which build configuration                                            ✔                      ✔
checkDevOps                                             Enable check DevOps                                                                  ✔
checkDevOpsCheckSessionAttributes                       Check if session attributes exist                                                    ✔
checkDevOpsDisplayNormalizedHeaders                     Display normalized headers                                                           ✔
checkDevOpsDownload                                     Enable check DevOps download field                                                   ✔
checkState                                              Enable CheckState plugin                                                             ✔
checkStateSecret                                        Secret token for CheckState plugin                                                   ✔
checkTime                                               Timeout to check new configuration in local cache                                    ✔      ✔               ✔
checkUser                                               Enable check user                                                                    ✔
checkUserDisplayComputedSession                         Display empty headers rule                                                           ✔
checkUserDisplayEmptyHeaders                            Display empty headers rule                                                           ✔
checkUserDisplayEmptyValues                             Display session empty values rule                                                    ✔
checkUserDisplayHiddenAttributes                        Display hidden attributes rule                                                       ✔
checkUserDisplayHistory                                 Display history rule                                                                 ✔
checkUserDisplayNormalizedHeaders                       Display normalized headers rule                                                      ✔
checkUserDisplayPersistentInfo                          Display persistent session info rule                                                 ✔
checkUserHiddenAttributes                               Attributes to hide in CheckUser plugin                                               ✔
checkUserHiddenHeaders                                  Header values to hide if not empty                                                   ✔
checkUserIdRule                                         checkUser identities rule                                                            ✔
checkUserSearchAttributes                               Attributes used for retrieving sessions in user DataBase                             ✔
checkUserUnrestrictedUsersRule                          checkUser unrestricted users rule                                                    ✔
checkXSS                                                Check XSS                                                                            ✔
combModules                                             Combination module description                                                       ✔
combination                                             Combination rule                                                                     ✔
compactConf                                             Compact configuration                                                                ✔
configStorage                                           Configuration storage                                                                ✔      ✔       ✔       ✔
confirmFormMethod                                       HTTP method for confirm page form                                                    ✔
contextSwitchingAllowed2fModifications                  Allowed SFA modifications                                                            ✔
contextSwitchingIdRule                                  Context switching identities rule                                                    ✔
contextSwitchingPrefix                                  Prefix to store real session Id                                                      ✔                      ✔
contextSwitchingRule                                    Context switching activation rule                                                    ✔
contextSwitchingStopWithLogout                          Stop context switching by logout                                                     ✔
contextSwitchingUnrestrictedUsersRule                   Context switching unrestricted users rule                                            ✔
cookieExpiration                                        Cookie expiration                                                                    ✔      ✔
cookieName                                              Name of the main cookie                                                              ✔      ✔
corsAllow_Credentials                                   Allow credentials for Cross-Origin Resource Sharing                                  ✔
corsAllow_Headers                                       Allowed headers for Cross-Origin Resource Sharing                                    ✔
corsAllow_Methods                                       Allowed methods for Cross-Origin Resource Sharing                                    ✔
corsAllow_Origin                                        Allowed origine for Cross-Origin Resource Sharing                                    ✔
corsEnabled                                             Enable Cross-Origin Resource Sharing                                                 ✔
corsExpose_Headers                                      Exposed headers for Cross-Origin Resource Sharing                                    ✔
corsMax_Age                                             Max-age for Cross-Origin Resource Sharing                                            ✔
crowdsec                                                CrowdSec plugin activation                                                           ✔
crowdsecAction                                          CrowdSec action                                                                      ✔
crowdsecKey                                             CrowdSec API key                                                                     ✔
crowdsecUrl                                             Base URL of CrowdSec local API                                                       ✔
cspConnect                                              Authorized Ajax destination for Content-Security-Policy                              ✔
cspDefault                                              Default value for Content-Security-Policy                                            ✔
cspFont                                                 Font source for Content-Security-Policy                                              ✔
cspFormAction                                           Form action destination for Content-Security-Policy                                  ✔
cspFrameAncestors                                       Frame-Ancestors for Content-Security-Policy                                          ✔
cspImg                                                  Image source for Content-Security-Policy                                             ✔
cspScript                                               Javascript source for Content-Security-Policy                                        ✔
cspStyle                                                Style source for Content-Security-Policy                                             ✔
customAddParams                                         Custom additional parameters                                                         ✔
customAuth                                              Custom auth module                                                                   ✔
customFunctions                                         List of custom functions                                                             ✔      ✔       ✔
customPassword                                          Custom password module                                                               ✔
customPlugins                                           Custom plugins                                                                       ✔
customPluginsParams                                     Custom plugins parameters                                                            ✔
customRegister                                          Custom register module                                                               ✔
customResetCertByMail                                   Custom certificateResetByMail module                                                 ✔
customToTrace                                           Session parameter used to fill REMOTE_CUSTOM                                         ✔      ✔
customUserDB                                            Custom user DB module                                                                ✔
dbiAuthChain                                                                                                                                 ✔
dbiAuthLoginCol                                                                                                                              ✔
dbiAuthPassword                                                                                                                              ✔
dbiAuthPasswordCol                                                                                                                           ✔
dbiAuthPasswordHash                                                                                                                          ✔
dbiAuthTable                                                                                                                                 ✔
dbiAuthUser                                                                                                                                  ✔
dbiAuthnLevel                                           DBI authentication level                                                             ✔
dbiDynamicHashEnabled                                                                                                                        ✔
dbiDynamicHashNewPasswordScheme                                                                                                              ✔
dbiDynamicHashValidSaltedSchemes                                                                                                             ✔
dbiDynamicHashValidSchemes                                                                                                                   ✔
dbiExportedVars                                         DBI exported variables                                                               ✔
dbiPasswordMailCol                                                                                                                           ✔
dbiUserChain                                                                                                                                 ✔
dbiUserPassword                                                                                                                              ✔
dbiUserTable                                                                                                                                 ✔
dbiUserUser                                                                                                                                  ✔
decryptValueFunctions                                   Custom function used for decrypting values                                           ✔
decryptValueRule                                        Decrypt value activation rule                                                        ✔
demoExportedVars                                        Demo exported variables                                                              ✔
disablePersistentStorage                                Enabled persistent storage                                                           ✔
displaySessionId                                        Display _session_id with sessions explorer                                           ✔
domain                                                  DNS domain                                                                           ✔      ✔
exportedAttr                                            List of attributes to export by SOAP or REST servers                                 ✔
exportedVars                                            Main exported variables                                                              ✔
ext2FSendCommand                                        Send command of External second factor                                               ✔
ext2FValidateCommand                                    Validation command of External second factor                                         ✔
ext2fActivation                                         External second factor activation                                                    ✔
ext2fAuthnLevel                                         Authentication level for users authentified by External second factor                ✔
ext2fCodeActivation                                     OTP generated by Portal                                                              ✔
ext2fLabel                                              Portal label for External second factor                                              ✔
ext2fLogo                                               Custom logo for External 2F                                                          ✔
ext2fResendInterval                                     Delay before user is allowed to resend code                                          ✔
facebookAppId                                                                                                                                ✔
facebookAppSecret                                                                                                                            ✔
facebookAuthnLevel                                      Facebook authentication level                                                        ✔
facebookExportedVars                                    Facebook exported variables                                                          ✔
facebookUserField                                                                                                                            ✔
failedLoginNumber                                       Number of failures stored in login history                                           ✔
findUser                                                Enable find user                                                                     ✔
findUserControl                                         Regular expression to validate parameters                                            ✔
findUserExcludingAttributes                             Attributes used for excluding accounts                                               ✔
findUserSearchingAttributes                             Attributes used for searching accounts                                               ✔
findUserWildcard                                        Character used as wildcard                                                           ✔
forceGlobalStorageIssuerOTT                             Force Issuer tokens to be stored into Global Storage                                 ✔                      ✔
forceGlobalStorageUpgradeOTT                            Force Upgrade tokens be stored into Global Storage                                   ✔                      ✔
formTimeout                                             Token timeout for forms                                                              ✔
githubAuthnLevel                                        GitHub authentication level                                                          ✔
githubClientID                                                                                                                               ✔
githubClientSecret                                                                                                                           ✔
githubScope                                                                                                                                  ✔
githubUserField                                                                                                                              ✔
globalLogoutCustomParam                                 Custom session parameter to display                                                  ✔
globalLogoutRule                                        Global logout activation rule                                                        ✔
globalLogoutTimer                                       Global logout auto accept time                                                       ✔
globalStorage                                           Session backend module                                                               ✔      ✔
globalStorageOptions                                    Session backend module options                                                       ✔      ✔
gpgAuthnLevel                                           GPG authentication level                                                             ✔
gpgDb                                                   GPG keys database                                                                    ✔
grantSessionRules                                       Rules to grant sessions                                                              ✔
groups                                                  Groups                                                                               ✔
groupsBeforeMacros                                      Compute groups before macros                                                         ✔
handlerInternalCache                                    Handler internal cache timeout                                                       ✔      ✔               ✔
handlerServiceTokenTTL                                  Handler ServiceToken timeout                                                         ✔      ✔               ✔
hiddenAttributes                                        Name of attributes to hide in logs                                                   ✔
hideOldPassword                                         Hide old password in portal                                                          ✔
httpOnly                                                Enable httpOnly flag in cookie                                                       ✔      ✔
https                                                   Use HTTPS for redirection from portal                                                       ✔
impersonationHiddenAttributes                           Attributes to skip                                                                   ✔
impersonationIdRule                                     Impersonation identities rule                                                        ✔
impersonationMergeSSOgroups                             Merge spoofed and real SSO groups                                                    ✔
impersonationPrefix                                     Prefix to rename real session attributes                                             ✔                      ✔
impersonationRule                                       Impersonation activation rule                                                        ✔
impersonationSkipEmptyValues                            Skip session empty values                                                            ✔
impersonationUnrestrictedUsersRule                      Impersonation unrestricted users rule                                                ✔
infoFormMethod                                          HTTP method for info page form                                                       ✔
issuerDBCASActivation                                   CAS server activation                                                                ✔
issuerDBCASPath                                         CAS server request path                                                              ✔
issuerDBCASRule                                         CAS server rule                                                                      ✔
issuerDBGetActivation                                   Get issuer activation                                                                ✔
issuerDBGetParameters                                   List of virtualHosts with their get parameters                                       ✔
issuerDBGetPath                                         Get issuer request path                                                              ✔
issuerDBGetRule                                         Get issuer rule                                                                      ✔
issuerDBOpenIDActivation                                OpenID server activation                                                             ✔
issuerDBOpenIDConnectActivation                         OpenID Connect server activation                                                     ✔
issuerDBOpenIDConnectPath                               OpenID Connect server request path                                                   ✔
issuerDBOpenIDConnectRule                               OpenID Connect server rule                                                           ✔
issuerDBOpenIDPath                                      OpenID server request path                                                           ✔
issuerDBOpenIDRule                                      OpenID server rule                                                                   ✔
issuerDBSAMLActivation                                  SAML IDP activation                                                                  ✔
issuerDBSAMLPath                                        SAML IDP request path                                                                ✔
issuerDBSAMLRule                                        SAML IDP rule                                                                        ✔
issuersTimeout                                          Token timeout for issuers                                                            ✔
jsRedirect                                              Use javascript for redirections                                                      ✔
key                                                     Secret key                                                                           ✔
krbAllowedDomains                                       Allowed domains                                                                      ✔
krbAuthnLevel                                           Null authentication level                                                            ✔
krbByJs                                                 Launch Kerberos authentication by Ajax                                               ✔
krbKeytab                                               Kerberos keytab                                                                      ✔
krbRemoveDomain                                         Remove domain in Kerberos username                                                   ✔
ldapAllowResetExpiredPassword                           Allow a user to reset his expired password                                           ✔
ldapAuthnLevel                                          LDAP authentication level                                                            ✔
ldapBase                                                LDAP search base                                                                     ✔
ldapCAFile                                              Location of the certificate file for LDAP connections                                ✔
ldapCAPath                                              Location of the CA directory for LDAP connections                                    ✔
ldapChangePasswordAsUser                                                                                                                     ✔
ldapExportedVars                                        LDAP exported variables                                                              ✔
ldapGetUserBeforePasswordChange                                                                                                              ✔
ldapGroupAttributeName                                  LDAP attribute name for member in groups                                             ✔
ldapGroupAttributeNameGroup                             LDAP attribute name in group entry referenced as member in groups                    ✔
ldapGroupAttributeNameSearch                            LDAP attributes to search in groups                                                  ✔
ldapGroupAttributeNameUser                              LDAP attribute name in user entry referenced as member in groups                     ✔
ldapGroupBase                                                                                                                                ✔
ldapGroupDecodeSearchedValue                            Decode value before searching it in LDAP groups                                      ✔
ldapGroupObjectClass                                    LDAP object class of groups                                                          ✔
ldapGroupRecursive                                      LDAP recursive search in groups                                                      ✔
ldapIOTimeout                                           LDAP operation timeout                                                               ✔
ldapITDS                                                Support for IBM Tivoli Directory Server                                              ✔
ldapPasswordResetAttribute                              LDAP password reset attribute                                                        ✔
ldapPasswordResetAttributeValue                         LDAP password reset value                                                            ✔
ldapPort                                                LDAP port                                                                            ✔
ldapPpolicyControl                                                                                                                           ✔
ldapPwdEnc                                              LDAP password encoding                                                               ✔
ldapRaw                                                                                                                                      ✔
ldapSearchDeref                                         "deref" param of Net::LDAP::search()                                                 ✔
ldapServer                                              LDAP server (host or URI)                                                            ✔
ldapSetPassword                                                                                                                              ✔
ldapTimeout                                             LDAP connection timeout                                                              ✔
ldapUsePasswordResetAttribute                           LDAP store reset flag in an attribute                                                ✔
ldapVerify                                              Whether to validate LDAP certificates                                                ✔
ldapVersion                                             LDAP protocol version                                                                ✔
linkedInAuthnLevel                                      LinkedIn authentication level                                                        ✔
linkedInClientID                                                                                                                             ✔
linkedInClientSecret                                                                                                                         ✔
linkedInFields                                                                                                                               ✔
linkedInScope                                                                                                                                ✔
linkedInUserField                                                                                                                            ✔
localSessionStorage                                     Local sessions cache module                                                          ✔
localSessionStorageOptions                              Sessions cache module options                                                        ✔
localStorage                                            Local cache                                                                          ✔      ✔       ✔       ✔
localStorageOptions                                     Local cache parameters                                                               ✔      ✔       ✔       ✔
log4perlConfFile                                        Log4Perl logger configuration file                                                   ✔      ✔       ✔       ✔
logLevel                                                Log level, must be set in .ini                                                       ✔      ✔       ✔       ✔
logger                                                  technical logger                                                                     ✔      ✔       ✔       ✔
loginHistoryEnabled                                     Enable login history                                                                 ✔
logoutServices                                          Send logout trough GET request to these services                                     ✔
lwpOpts                                                 Options passed to LWP::UserAgent                                                     ✔
lwpSslOpts                                              SSL options passed to LWP::UserAgent                                                 ✔
macros                                                  Macros                                                                               ✔
mail2fActivation                                        Mail second factor activation                                                        ✔
mail2fAuthnLevel                                        Authentication level for users authenticated by Mail second factor                   ✔
mail2fBody                                              Mail body for second factor authentication                                           ✔
mail2fCodeRegex                                         Regular expression to create a mail OTP code                                         ✔
mail2fLabel                                             Portal label for Mail second factor                                                  ✔
mail2fLogo                                              Custom logo for Mail 2F                                                              ✔
mail2fResendInterval                                    Delay before user is allowed to resend code                                          ✔
mail2fSessionKey                                        Session parameter where mail is stored                                               ✔
mail2fSubject                                           Mail subject for second factor authentication                                        ✔
mail2fTimeout                                           Second factor code timeout                                                           ✔
mailBody                                                Custom password reset mail body                                                      ✔
mailCharset                                             Mail charset                                                                         ✔
mailConfirmBody                                         Custom confirm password reset mail body                                              ✔
mailConfirmSubject                                      Mail subject for reset confirmation                                                  ✔
mailFrom                                                Sender email                                                                         ✔
mailLDAPFilter                                          LDAP filter for mail search                                                          ✔
mailOnPasswordChange                                    Send a mail when password is changed                                                 ✔
mailReplyTo                                             Reply-To address                                                                     ✔
mailSessionKey                                          Session parameter where mail is stored                                               ✔
mailSubject                                             Mail subject for new password email                                                  ✔
mailTimeout                                             Mail password reset session timeout                                                  ✔
mailUrl                                                 URL of password reset page                                                           ✔
maintenance                                             Maintenance mode for all virtual hosts                                                      ✔
managerDn                                               LDAP manager DN                                                                      ✔
managerPassword                                         LDAP manager Password                                                                ✔
max2FDevices                                            Maximum registered 2F devices                                                        ✔                      ✔
max2FDevicesNameLength                                  Maximum 2F devices name length                                                       ✔                      ✔
multiValuesSeparator                                    Separator for multiple values                                                        ✔      ✔       ✔
mySessionAuthorizedRWKeys                               Alterable session keys by user itself                                                ✔                      ✔
newLocationWarning                                      Enable New Location Warning                                                          ✔
newLocationWarningLocationAttribute                     New location session attribute                                                       ✔
newLocationWarningLocationDisplayAttribute              New location session attribute for user display                                      ✔
newLocationWarningMailAttribute                         New location warning mail session attribute                                          ✔
newLocationWarningMailBody                              Mail body for new location warning                                                   ✔
newLocationWarningMailSubject                           Mail subject for new location warning                                                ✔
newLocationWarningMaxValues                             How many previous locations should be compared                                       ✔
nginxCustomHandlers                                     Custom Nginx handler (deprecated)                                                    ✔
noAjaxHook                                              Avoid replacing 302 by 401 for Ajax responses                                        ✔
notification                                            Notification activation                                                              ✔
notificationDefaultCond                                 Notification default condition                                                       ✔
notificationServer                                      Notification server activation                                                       ✔
notificationServerDELETE                                Notification server activation                                                       ✔
notificationServerGET                                   Notification server activation                                                       ✔
notificationServerPOST                                  Notification server activation                                                       ✔
notificationServerSentAttributes                        Prameters to send with notification server GET method                                ✔
notificationStorage                                     Notification backend                                                                 ✔
notificationStorageOptions                              Notification backend options                                                         ✔
notificationWildcard                                    Notification string to match all users                                               ✔
notificationXSLTfile                                    Custom XSLT document for notifications                                               ✔
notificationsExplorer                                   Notifications explorer activation                                                    ✔
notificationsMaxRetrieve                                Max number of displayed notifications                                                ✔                      ✔
notifyDeleted                                           Show deleted sessions in portal                                                      ✔
notifyOther                                             Show other sessions in portal                                                        ✔
nullAuthnLevel                                          Null authentication level                                                            ✔
oidcAuthnLevel                                          OpenID Connect authentication level                                                  ✔
oidcOPMetaDataOptions                                                                                                                        ✔                      [1]
oidcRPCallbackGetParam                                  OpenID Connect Callback GET URLparameter                                             ✔
oidcRPMetaDataOptions                                                                                                                        ✔                      [1]
oidcRPStateTimeout                                      OpenID Connect Timeout of state sessions                                             ✔
oidcServiceAccessTokenExpiration                        OpenID Connect global access token TTL                                               ✔
oidcServiceAllowAuthorizationCodeFlow                   OpenID Connect allow authorization code flow                                         ✔
oidcServiceAllowDynamicRegistration                     OpenID Connect allow dynamic client registration                                     ✔
oidcServiceAllowHybridFlow                              OpenID Connect allow hybrid flow                                                     ✔
oidcServiceAllowImplicitFlow                            OpenID Connect allow implicit flow                                                   ✔
oidcServiceAllowOnlyDeclaredScopes                      OpenID Connect allow only declared scopes                                            ✔
oidcServiceAuthorizationCodeExpiration                  OpenID Connect global code TTL                                                       ✔
oidcServiceDynamicRegistrationExportedVars              OpenID Connect exported variables for dynamic registration                           ✔
oidcServiceDynamicRegistrationExtraClaims               OpenID Connect extra claims for dynamic registration                                 ✔
oidcServiceIDTokenExpiration                            OpenID Connect global ID token TTL                                                   ✔
oidcServiceKeyIdSig                                     OpenID Connect Signature Key ID                                                      ✔
oidcServiceMetaDataAuthnContext                         OpenID Connect Authentication Context Class Ref                                      ✔
oidcServiceMetaDataAuthorizeURI                         OpenID Connect authorizaton endpoint                                                 ✔
oidcServiceMetaDataBackChannelURI                       OpenID Connect Front-Channel logout endpoint                                         ✔
oidcServiceMetaDataCheckSessionURI                      OpenID Connect check session iframe                                                  ✔
oidcServiceMetaDataEndSessionURI                        OpenID Connect end session endpoint                                                  ✔
oidcServiceMetaDataFrontChannelURI                      OpenID Connect Front-Channel logout endpoint                                         ✔
oidcServiceMetaDataIntrospectionURI                     OpenID Connect introspection endpoint                                                ✔
oidcServiceMetaDataIssuer                               OpenID Connect issuer                                                                ✔
oidcServiceMetaDataJWKSURI                              OpenID Connect JWKS endpoint                                                         ✔
oidcServiceMetaDataRegistrationURI                      OpenID Connect registration endpoint                                                 ✔
oidcServiceMetaDataTokenURI                             OpenID Connect token endpoint                                                        ✔
oidcServiceMetaDataUserInfoURI                          OpenID Connect user info endpoint                                                    ✔
oidcServiceOfflineSessionExpiration                     OpenID Connect global offline session TTL                                            ✔
oidcServicePrivateKeySig                                                                                                                     ✔
oidcServicePublicKeySig                                                                                                                      ✔
oidcStorage                                             Apache::Session module to store OIDC user data                                       ✔
oidcStorageOptions                                      Apache::Session module parameters                                                    ✔
oldNotifFormat                                          Use old XML format for notifications                                                 ✔
openIdAttr                                                                                                                                   ✔
openIdAuthnLevel                                        OpenID authentication level                                                          ✔
openIdExportedVars                                      OpenID exported variables                                                            ✔
openIdIDPList                                                                                                                                ✔
openIdIssuerSecret                                                                                                                           ✔
openIdSPList                                                                                                                                 ✔
openIdSecret                                                                                                                                 ✔
openIdSreg_country                                                                                                                           ✔
openIdSreg_dob                                                                                                                               ✔
openIdSreg_email                                        OpenID SREG email session parameter                                                  ✔
openIdSreg_fullname                                     OpenID SREG fullname session parameter                                               ✔
openIdSreg_gender                                                                                                                            ✔
openIdSreg_language                                                                                                                          ✔
openIdSreg_nickname                                     OpenID SREG nickname session parameter                                               ✔
openIdSreg_postcode                                                                                                                          ✔
openIdSreg_timezone                                     OpenID SREG timezone session parameter                                               ✔
pamAuthnLevel                                           PAM authentication level                                                             ✔
pamService                                              PAM service                                                                          ✔
passwordDB                                              Password module                                                                      ✔
passwordPolicyActivation                                Enable password policy                                                               ✔
passwordPolicyMinDigit                                  Password policy: minimal digit characters                                            ✔
passwordPolicyMinLower                                  Password policy: minimal lower characters                                            ✔
passwordPolicyMinSize                                   Password policy: minimal size                                                        ✔
passwordPolicyMinSpeChar                                Password policy: minimal special characters                                          ✔
passwordPolicyMinUpper                                  Password policy: minimal upper characters                                            ✔
passwordPolicySpecialChar                               Password policy: allowed special characters                                          ✔
passwordResetAllowedRetries                             Maximum number of retries to reset password                                          ✔
pdataDomain                                             pdata cookie DNS domain                                                              ✔      ✔               ✔
persistentSessionAttributes                             Persistent session attributes to hide                                                ✔                      ✔
persistentStorage                                       Storage module for persistent sessions                                               ✔
persistentStorageOptions                                Options for persistent sessions storage module                                       ✔
port                                                    Force port in redirection                                                                   ✔
portal                                                  Portal URL                                                                           ✔      ✔       ✔
portalAntiFrame                                         Avoid portal to be displayed inside frames                                           ✔
portalCheckLogins                                       Display login history checkbox in portal                                             ✔
portalCustomCss                                         Path to custom CSS file                                                              ✔
portalDisplayAppslist                                   Display applications tab in portal                                                   ✔
portalDisplayCertificateResetByMail                     Display certificate reset by mail button in portal                                   ✔
portalDisplayChangePassword                             Display password tab in portal                                                       ✔
portalDisplayGeneratePassword                           Display password generate box in reset password form                                 ✔
portalDisplayLoginHistory                               Display login history tab in portal                                                  ✔
portalDisplayLogout                                     Display logout tab in portal                                                         ✔
portalDisplayOidcConsents                               Display OIDC consent tab in portal                                                   ✔
portalDisplayPasswordPolicy                             Display policy in password form                                                      ✔
portalDisplayRefreshMyRights                            Display link to refresh the user session                                             ✔
portalDisplayRegister                                   Display register button in portal                                                    ✔
portalDisplayResetPassword                              Display reset password button in portal                                              ✔
portalEnablePasswordDisplay                             Allow to display password in login form                                              ✔
portalErrorOnExpiredSession                             Show error if session is expired                                                     ✔
portalErrorOnMailNotFound                               Show error if mail is not found in password reset process                            ✔
portalFavicon                                           Path to favicon file                                                                 ✔
portalForceAuthn                                        Enable force to authenticate when displaying portal                                  ✔
portalForceAuthnInterval                                Maximum interval in seconds since last authentication to force reauthentication      ✔
portalMainLogo                                          Portal main logo path                                                                ✔
portalOpenLinkInNewWindow                               Open applications in new windows                                                     ✔
portalPingInterval                                      Interval in ms between portal Ajax pings                                             ✔
portalRequireOldPassword                                Rule to require old password to change the password                                  ✔
portalSkin                                              Name of portal skin                                                                  ✔
portalSkinBackground                                    Background image of portal skin                                                      ✔
portalSkinRules                                         Rules to choose portal skin                                                          ✔
portalStatus                                            Enable portal status                                                                 ✔
portalUserAttr                                          Session parameter to display connected user in portal                                ✔
protection                                              Manager protection method                                                                   ✔       ✔       ✔
proxyAuthService                                                                                                                             ✔
proxyAuthServiceChoiceParam                                                                                                                  ✔
proxyAuthServiceChoiceValue                                                                                                                  ✔
proxyAuthServiceImpersonation                           Enable internal portal Impersonation                                                 ✔
proxyAuthnLevel                                         Proxy authentication level                                                           ✔
proxyCookieName                                         Name of the internal portal cookie                                                   ✔
proxySessionService                                                                                                                          ✔
proxyUseSoap                                            Use SOAP instead of REST                                                             ✔
radius2fActivation                                      Radius second factor activation                                                      ✔
radius2fAuthnLevel                                      Authentication level for users authenticated by Radius second factor                 ✔
radius2fLabel                                           Portal label for Radius 2F                                                           ✔
radius2fLogo                                            Custom logo for Radius 2F                                                            ✔
radius2fSecret                                                                                                                               ✔
radius2fServer                                                                                                                               ✔
radius2fTimeout                                         Radius 2f verification timeout                                                       ✔
radius2fUsernameSessionKey                              Session key used as Radius login                                                     ✔
radiusAuthnLevel                                        Radius authentication level                                                          ✔
radiusSecret                                                                                                                                 ✔
radiusServer                                                                                                                                 ✔
randomPasswordRegexp                                    Regular expression to create a random password                                       ✔
redirectFormMethod                                      HTTP method for redirect page form                                                   ✔
refreshSessions                                         Refresh sessions plugin                                                              ✔
registerConfirmBody                                     Mail body for register confirmation                                                  ✔
registerConfirmSubject                                  Mail subject for register confirmation                                               ✔
registerDB                                              Register module                                                                      ✔
registerDoneBody                                        Mail body when register is done                                                      ✔
registerDoneSubject                                     Mail subject when register is done                                                   ✔
registerTimeout                                         Register session timeout                                                             ✔
registerUrl                                             URL of register page                                                                 ✔
reloadTimeout                                           Configuration reload timeout                                                                        ✔
reloadUrls                                              URL to call on reload                                                                ✔
rememberAuthChoiceRule                                  remember auth choice activation rule                                                 ✔
rememberCookieName                                      Name of the remember auth choice cookie                                              ✔
rememberCookieTimeout                                   lifetime of the remember auth choice cookie                                                         ✔
rememberDefaultChecked                                  Is remember auth choice checkbox enabled by default?                                 ✔
rememberTimer                                           timer before automatic authentication with remembered choice                                        ✔
remoteCookieName                                        Name of the remote portal cookie                                                     ✔
remoteGlobalStorage                                     Remote session backend                                                               ✔
remoteGlobalStorageOptions                              Apache::Session module parameters                                                    ✔
remotePortal                                                                                                                                 ✔
requireToken                                            Enable token for forms                                                               ✔
rest2fActivation                                        REST second factor activation                                                        ✔
rest2fAuthnLevel                                        Authentication level for users authentified by REST second factor                    ✔
rest2fCodeActivation                                    OTP generated by Portal                                                              ✔
rest2fInitArgs                                          Args for REST 2F init                                                                ✔
rest2fInitUrl                                           REST 2F init URL                                                                     ✔
rest2fLabel                                             Portal label for REST second factor                                                  ✔
rest2fLogo                                              Custom logo for REST 2F                                                              ✔
rest2fResendInterval                                    Delay before user is allowed to resend code                                          ✔
rest2fVerifyArgs                                        Args for REST 2F init                                                                ✔
rest2fVerifyUrl                                         REST 2F init URL                                                                     ✔
restAuthServer                                          Enable REST authentication server                                                    ✔
restAuthUrl                                                                                                                                  ✔
restAuthnLevel                                          REST authentication level                                                            ✔
restClockTolerance                                      How tolerant the REST session server will be to clock dift                           ✔
restConfigServer                                        Enable REST config server                                                            ✔
restExportSecretKeys                                    Allow to export secret keys in REST session server                                   ✔
restFindUserDBUrl                                                                                                                            ✔
restPasswordServer                                      Enable REST password reset server                                                    ✔
restPwdConfirmUrl                                                                                                                            ✔
restPwdModifyUrl                                                                                                                             ✔
restSessionServer                                       Enable REST session server                                                           ✔
restUserDBUrl                                                                                                                                ✔
sameSite                                                Cookie SameSite value                                                                ✔      ✔
samlAttributeAuthorityDescriptorAttributeServiceSOAP    SAML Attribute Authority SOAP                                                        ✔
samlAuthnContextMapKerberos                             SAML authn context kerberos level                                                    ✔
samlAuthnContextMapPassword                             SAML authn context password level                                                    ✔
samlAuthnContextMapPasswordProtectedTransport           SAML authn context password protected transport level                                ✔
samlAuthnContextMapTLSClient                            SAML authn context TLS client level                                                  ✔
samlCommonDomainCookieActivation                        SAML CDC activation                                                                  ✔
samlCommonDomainCookieDomain                                                                                                                 ✔
samlCommonDomainCookieReader                                                                                                                 ✔
samlCommonDomainCookieWriter                                                                                                                 ✔
samlDiscoveryProtocolActivation                         SAML Discovery Protocol activation                                                   ✔
samlDiscoveryProtocolIsPassive                          SAML Discovery Protocol Is Passive                                                   ✔
samlDiscoveryProtocolPolicy                             SAML Discovery Protocol Policy                                                       ✔
samlDiscoveryProtocolURL                                SAML Discovery Protocol EndPoint URL                                                 ✔
samlEntityID                                            SAML service entityID                                                                ✔
samlIDPMetaDataOptions                                                                                                                       ✔                      [1]
samlIDPSSODescriptorArtifactResolutionServiceArtifact   SAML IDP artifact resolution service                                                 ✔
samlIDPSSODescriptorSingleLogoutServiceHTTPPost         SAML IDP SLO HTTP POST                                                               ✔
samlIDPSSODescriptorSingleLogoutServiceHTTPRedirect     SAML IDP SLO HTTP Redirect                                                           ✔
samlIDPSSODescriptorSingleLogoutServiceSOAP             SAML IDP SLO SOAP                                                                    ✔
samlIDPSSODescriptorSingleSignOnServiceHTTPArtifact     SAML IDP SSO HTTP Artifact                                                           ✔
samlIDPSSODescriptorSingleSignOnServiceHTTPPost         SAML IDP SSO HTTP POST                                                               ✔
samlIDPSSODescriptorSingleSignOnServiceHTTPRedirect     SAML IDP SSO HTTP Redirect                                                           ✔
samlIDPSSODescriptorWantAuthnRequestsSigned             SAML IDP want authn request signed                                                   ✔
samlMetadataForceUTF8                                   SAML force metadata UTF8 conversion                                                  ✔
samlNameIDFormatMapEmail                                SAML session parameter for NameID email                                              ✔
samlNameIDFormatMapKerberos                             SAML session parameter for NameID kerberos                                           ✔
samlNameIDFormatMapWindows                              SAML session parameter for NameID windows                                            ✔
samlNameIDFormatMapX509                                 SAML session parameter for NameID x509                                               ✔
samlOrganizationDisplayName                             SAML service organization display name                                               ✔
samlOrganizationName                                    SAML service organization name                                                       ✔
samlOrganizationURL                                     SAML service organization URL                                                        ✔
samlOverrideIDPEntityID                                 Override SAML EntityID when acting as an IDP                                         ✔
samlRelayStateTimeout                                   SAML timeout of relay state                                                          ✔
samlSPMetaDataOptions                                                                                                                        ✔                      [1]
samlSPSSODescriptorArtifactResolutionServiceArtifact    SAML SP artifact resolution service                                                  ✔
samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact SAML SP ACS HTTP artifact                                                            ✔
samlSPSSODescriptorAssertionConsumerServiceHTTPPost     SAML SP ACS HTTP POST                                                                ✔
samlSPSSODescriptorAuthnRequestsSigned                  SAML SP AuthnRequestsSigned                                                          ✔
samlSPSSODescriptorSingleLogoutServiceHTTPPost          SAML SP SLO HTTP POST                                                                ✔
samlSPSSODescriptorSingleLogoutServiceHTTPRedirect      SAML SP SLO HTTP Redirect                                                            ✔
samlSPSSODescriptorSingleLogoutServiceSOAP              SAML SP SLO SOAP                                                                     ✔
samlSPSSODescriptorWantAssertionsSigned                 SAML SP WantAssertionsSigned                                                         ✔
samlServicePrivateKeyEnc                                SAML encryption private key                                                          ✔
samlServicePrivateKeyEncPwd                                                                                                                  ✔
samlServicePrivateKeySig                                SAML signature private key                                                           ✔
samlServicePrivateKeySigPwd                             SAML signature private key password                                                  ✔
samlServicePublicKeyEnc                                 SAML encryption public key                                                           ✔
samlServicePublicKeySig                                 SAML signature public key                                                            ✔
samlServiceSignatureMethod                                                                                                                   ✔
samlServiceUseCertificateInResponse                     Use certificate instead of public key in SAML responses                              ✔
samlStorage                                             Apache::Session module to store SAML user data                                       ✔
samlStorageOptions                                      Apache::Session module parameters                                                    ✔
samlUseQueryStringSpecific                              SAML use specific method for query_string                                            ✔
scrollTop                                               Display back to top button                                                           ✔
secureTokenAllowOnError                                 Secure Token allow requests in error                                                        ✔               ✔
secureTokenAttribute                                    Secure Token attribute                                                                      ✔               ✔
secureTokenExpiration                                   Secure Token expiration                                                                     ✔               ✔
secureTokenHeader                                       Secure Token header                                                                         ✔               ✔
secureTokenMemcachedServers                             Secure Token Memcached servers                                                              ✔               ✔
secureTokenUrls                                                                                                                                     ✔               ✔
securedCookie                                           Cookie securisation method                                                           ✔      ✔
sentryDsn                                               Sentry logger DSN                                                                    ✔      ✔       ✔       ✔
sessionDataToRemember                                   Data to remember in login history                                                    ✔
sfEngine                                                Second factor engine                                                                 ✔                      ✔
sfExtra                                                 Extra second factors                                                                 ✔
sfLoginTimeout                                          Timeout for 2F login process                                                         ✔
sfManagerRule                                           Rule to display second factor Manager link                                           ✔
sfOnlyUpgrade                                           Only trigger second factor on session upgrade                                        ✔
sfRegisterTimeout                                       Timeout for 2F registration process                                                  ✔
sfRemovedMsgRule                                        Display a message if at leat one expired SF has been removed                         ✔
sfRemovedNotifMsg                                       Notification message                                                                 ✔
sfRemovedNotifRef                                       Notification reference                                                               ✔
sfRemovedNotifTitle                                     Notification title                                                                   ✔
sfRemovedUseNotif                                       Use Notifications plugin to display message                                          ✔
sfRequired                                              Second factor required                                                               ✔
showLanguages                                           Display langs icons                                                                  ✔
singleIP                                                Allow only one session per IP                                                        ✔
singleSession                                           Allow only one session per user                                                      ✔
singleUserByIP                                          Allow only one user per IP                                                           ✔
skipRenewConfirmation                                   Avoid asking confirmation when an Issuer asks to renew auth                          ✔
skipUpgradeConfirmation                                 Avoid asking confirmation during a session upgrade                                   ✔
slaveAuthnLevel                                         Slave authentication level                                                           ✔
slaveDisplayLogo                                        Display Slave authentication logo                                                    ✔
slaveExportedVars                                       Slave exported variables                                                             ✔
slaveHeaderContent                                                                                                                           ✔
slaveHeaderName                                                                                                                              ✔
slaveMasterIP                                                                                                                                ✔
slaveUserHeader                                                                                                                              ✔
soapConfigServer                                        Enable SOAP config server                                                            ✔
soapProxyUrn                                            SOAP URN for Proxy                                                                   ✔                      ✔
soapSessionServer                                       Enable SOAP session server                                                           ✔
sslByAjax                                               Use Ajax request for SSL                                                             ✔
sslHost                                                 URL for SSL Ajax request                                                             ✔
staticPrefix                                            Prefix of static files for HTML templates                                            ✔                      ✔
status                                                  Status daemon activation                                                                    ✔               ✔
stayConnected                                           Stay connected activation rule                                                       ✔
stayConnectedBypassFG                                   Disable fingerprint checkng                                                          ✔
stayConnectedCookieName                                 Name of the stayConnected plugin cookie                                              ✔
stayConnectedTimeout                                    StayConnected persistent connexion session timeout                                                  ✔
storePassword                                           Store password in session                                                            ✔
strictTransportSecurityMax_Age                          Max-age for Strict-Transport-Security                                                ✔
successLoginNumber                                      Number of success stored in login history                                            ✔
syslogFacility                                          Syslog logger technical facility                                                     ✔      ✔       ✔       ✔
timeout                                                 Session timeout on server side                                                       ✔
timeoutActivity                                         Session activity timeout on server side                                              ✔
timeoutActivityInterval                                 Update session timeout interval on server side                                       ✔
tokenUseGlobalStorage                                   Enable global token storage                                                          ✔
totp2fActivation                                        TOTP activation                                                                      ✔
totp2fAuthnLevel                                        Authentication level for users authentified by password+TOTP                         ✔
totp2fDigits                                            Number of digits for TOTP code                                                       ✔
totp2fEncryptSecret                                     Encrypt TOTP secrets in database                                                     ✔
totp2fInterval                                          TOTP interval                                                                        ✔
totp2fIssuer                                            TOTP Issuer                                                                          ✔
totp2fLabel                                             Portal label for TOTP 2F                                                             ✔
totp2fLogo                                              Custom logo for TOTP 2F                                                              ✔
totp2fRange                                             TOTP range (number of interval to test)                                              ✔
totp2fSelfRegistration                                  TOTP self registration activation                                                    ✔
totp2fTTL                                               TOTP device time to live                                                             ✔
totp2fUserCanRemoveKey                                  Authorize users to remove existing TOTP secret                                       ✔
trustedDomains                                          Trusted domains                                                                      ✔
twitterAppName                                                                                                                               ✔
twitterAuthnLevel                                       Twitter authentication level                                                         ✔
twitterKey                                                                                                                                   ✔
twitterSecret                                                                                                                                ✔
twitterUserField                                                                                                                             ✔
u2fActivation                                           U2F activation                                                                       ✔
u2fAuthnLevel                                           Authentication level for users authentified by password+U2F                          ✔
u2fLabel                                                Portal label for U2F                                                                 ✔
u2fLogo                                                 Custom logo for U2F                                                                  ✔
u2fSelfRegistration                                     U2F self registration activation                                                     ✔
u2fTTL                                                  U2F device time to live                                                              ✔
u2fUserCanRemoveKey                                     Authorize users to remove existing U2F key                                           ✔
upgradeSession                                          Upgrade session activation                                                           ✔
useRedirectOnError                                      Use 302 redirect code for error (500)                                                       ✔
useRedirectOnForbidden                                  Use 302 redirect code for forbidden (403)                                            ✔
useSafeJail                                             Activate Safe jail                                                                   ✔      ✔
userControl                                             Regular expression to validate login                                                 ✔
userDB                                                  User module                                                                          ✔
userLogger                                              User actions logger                                                                  ✔      ✔       ✔       ✔
userPivot                                                                                                                                    ✔
userSyslogFacility                                      Syslog logger user-actions facility                                                  ✔      ✔       ✔       ✔
utotp2fActivation                                       UTOTP activation (mixed U2F/TOTP module)                                             ✔
utotp2fAuthnLevel                                       Authentication level for users authentified by password+(U2F or TOTP)                ✔
utotp2fLabel                                            Portal label for U2F+TOTP                                                            ✔
utotp2fLogo                                             Custom logo for U2F+TOTP                                                             ✔
vhostOptions                                                                                                                                 ✔                      [1]
viewerAllowBrowser                                      Allow configuration browser                                                          ✔                      ✔
viewerAllowDiff                                         Allow configuration diff                                                             ✔                      ✔
viewerHiddenKeys                                        Hidden Conf keys                                                                                    ✔       ✔
webIDAuthnLevel                                         WebID authentication level                                                           ✔
webIDExportedVars                                       WebID exported variables                                                             ✔
webIDWhitelist                                                                                                                               ✔
webauthn2fActivation                                    WebAuthn second factor activation                                                    ✔
webauthn2fAuthnLevel                                    Authentication level for users authentified by WebAuthn second factor                ✔
webauthn2fLabel                                         Portal label for WebAuthn second factor                                              ✔
webauthn2fLogo                                          Custom logo for WebAuthn 2F                                                          ✔
webauthn2fSelfRegistration                              WebAuthn self registration activation                                                ✔
webauthn2fUserCanRemoveKey                              Authorize users to remove existing WebAuthn                                          ✔
webauthn2fUserVerification                              Verify user during registration and login                                            ✔
webauthnDisplayNameAttr                                 Session attribute containing user display name                                       ✔
webauthnRpName                                          WebAuthn Relying Party display name                                                  ✔
whatToTrace                                             Session parameter used to fill REMOTE_USER                                           ✔      ✔
wsdlServer                                              Enable /portal.wsdl server                                                           ✔
yubikey2fActivation                                     Yubikey second factor activation                                                     ✔
yubikey2fAuthnLevel                                     Authentication level for users authentified by Yubikey second factor                 ✔
yubikey2fClientID                                       Yubico client ID                                                                     ✔
yubikey2fFromSessionAttribute                           Provision yubikey from the given session variable                                    ✔
yubikey2fLabel                                          Portal label for Yubikey second factor                                               ✔
yubikey2fLogo                                           Custom logo for Yubikey 2F                                                           ✔
yubikey2fNonce                                          Yubico nonce                                                                         ✔
yubikey2fPublicIDSize                                   Yubikey public ID size                                                               ✔
yubikey2fSecretKey                                      Yubico secret key                                                                    ✔
yubikey2fSelfRegistration                               Yubikey self registration activation                                                 ✔
yubikey2fTTL                                            Yubikey device time to live                                                          ✔
yubikey2fUrl                                            Yubico server                                                                        ✔
yubikey2fUserCanRemoveKey                               Authorize users to remove existing Yubikey                                           ✔
zimbraAccountKey                                        Zimbra account session key                                                                  ✔               ✔
zimbraBy                                                Zimbra account type                                                                         ✔               ✔
zimbraPreAuthKey                                        Zimbra preauthentication key                                                                ✔               ✔
zimbraSsoUrl                                            Zimbra local SSO URL pattern                                                                ✔               ✔
zimbraUrl                                               Zimbra preauthentication URL                                                                ✔               ✔
======================================================= ==================================================================================== ====== ======= ======= =============

*[1]: complex nodes*

Configuration backend parameters
--------------------------------

============================================================================= ==================== ===========================================================
Full name                                                                     Key name             Configuration backend
============================================================================= ==================== ===========================================================
Configuration load timeout                                                    confTimeout          all backends (default: 10)
DBI connection string                                                         dbiChain             :doc:`CDBI / RDBI<sqlconfbackend>`
DBI user                                                                      dbiUser
DBI password                                                                  dbiPassword
DBI table name                                                                dbiTable
Directory                                                                     dirName              :doc:`File<fileconfbackend>` / :doc:`YAML<yamlconfbackend>`
LDAP server                                                                   ldapServer           :doc:`LDAP<ldapconfbackend>`
LDAP port                                                                     ldapPort
LDAP base                                                                     ldapConfBase
LDAP bind dn                                                                  ldapBindDN
LDAP bind password                                                            ldapBindPassword
LDAP ObjectClass                                                              ldapObjectClass
LDAP ID attribute                                                             ldapAttributeId
LDAP content attribute                                                        ldapAttributeContent
Certificate authorities file                                                  caFile
Certificate authorities directory                                             caPath
MongoDB database                                                              dbName               :doc:`MongoDB<mongodbconfbackend>`
MongoDB collection                                                            collectionName
Pretty print                                                                  prettyPrint          :doc:`File<fileconfbackend>`
REST base URL                                                                 baseUrl              :doc:`REST<restconfbackend>`
REST realm                                                                    realm
REST user                                                                     user
REST password                                                                 password
SOAP server location (URL)                                                    proxy                :doc:`SOAP<soapconfbackend>`
`LWP::UserAgent <http://search.cpan.org/perldoc?LWP::UserAgent>`__ parameters proxyOptions
SOAP user                                                                     User
SOAP password                                                                 Password
============================================================================= ==================== ===========================================================
