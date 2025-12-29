Parameter list
==============

Main parameters
---------------

ADPwdExpireWarning
    :Location: General Parameters » Authentication parameters » Active Directory parameters » Password expire warning
    :Description: AD password expire warning
    :Used by portal: yes

ADPwdMaxAge
    :Location: General Parameters » Authentication parameters » Active Directory parameters » Password max age
    :Description: AD password max age
    :Used by portal: yes

AuthLDAPFilter
    :Location: General Parameters » Authentication parameters » LDAP parameters » Filters » Authentication filter
    :Description: LDAP filter for auth search
    :Used by portal: yes

LDAPFilter
    :Location: General Parameters » Authentication parameters » LDAP parameters » Filters » Default filter
    :Description: Default LDAP filter
    :Used by portal: yes

SMTPAuthPass
    :Location: General Parameters » Advanced parameters » SMTP » Password
    :Description: Password to use to send mails
    :Used by portal: yes

SMTPAuthUser
    :Location: General Parameters » Advanced parameters » SMTP » User
    :Description: Login to use to send mails
    :Used by portal: yes

SMTPPort
    :Location: General Parameters » Advanced parameters » SMTP » Port
    :Description: Fix SMTP port
    :Used by portal: yes

SMTPServer
    :Location: General Parameters » Advanced parameters » SMTP » Server
    :Description: SMTP Server
    :Used by portal: yes

SMTPTLS
    :Location: General Parameters » Advanced parameters » SMTP » SSL/TLS protocol
    :Description: TLS protocol to use with SMTP
    :Used by portal: yes

SMTPTLSOpts
    :Location: General Parameters » Advanced parameters » SMTP » SSL/TLS options
    :Description: TLS/SSL options for SMTP
    :Used by portal: yes

SSLAuthnLevel
    :Location: General Parameters » Authentication parameters » mTLS parameters » Authentication level
    :Description: Mutual TLS authentication level
    :Used by portal: yes

SSLIssuerVar
    :Location: General Parameters » Authentication parameters » mTLS parameters » Issuer environment variable
    :Used by portal: yes

SSLVar
    :Location: General Parameters » Authentication parameters » mTLS parameters » Extracted certificate field
    :Used by portal: yes

SSLVarIf
    :Location: General Parameters » Authentication parameters » mTLS parameters » Conditional extracted certificate field
    :Used by portal: yes

activeTimer
    :Location: General Parameters » Advanced parameters » Forms » Auto accept time
    :Description: Enable timers on portal pages
    :Used by portal: yes

adaptativeAuthenticationLevelRules
    :Location: General Parameters » Plugins » Adaptative authentication rules
    :Description: Adaptative authentication level rules
    :Used by portal: yes

adminLogoutServerSecret
    :Location: General Parameters » Plugins » Admin logout server » Secret
    :Description: REST OIDC token revocation secret
    :Used by portal: yes

apacheAuthnLevel
    :Location: General Parameters » Authentication parameters » Apache parameters » Authentication level
    :Description: Apache authentication level
    :Used by portal: yes

appAccessHistoryEnabled
    :Location: General Parameters » Sessions » Log application access
    :Description: Shall OIDC/SAML/CAS protected apps access be recorded to session?
    :Used by portal: yes

applicationList
    :Location: General Parameters » Portal » Menu » Categories and applications
    :Description: Applications list
    :Used by portal: yes

authChoiceAuthBasic
    :Location: General Parameters » Authentication parameters » Choice parameters » Choice used for password authentication
    :Description: Auth module used by AuthBasic handler
    :Used by portal: yes

authChoiceFindUser
    :Location: General Parameters » Authentication parameters » Choice parameters » Choice used for searching user account
    :Description: Auth module used by FindUser plugin
    :Used by portal: yes

authChoiceModules
    :Location: General Parameters » Authentication parameters » Choice parameters » Allowed modules
    :Description: Hash list of Choice strings
    :Used by portal: yes

authChoiceParam
    :Location: General Parameters » Authentication parameters » Choice parameters » URL parameter
    :Description: Applications list
    :Used by portal: yes

authChoiceSelectOnly
    :Location: General Parameters » Authentication parameters » Choice parameters » Auto-select only method
    :Description: Automatically select only available choice
    :Used by portal: yes

authentication
    :Location: General Parameters » Authentication parameters » Authentication module
    :Description: Authentication module
    :Used by portal: yes

autoSigninRules
    :Location: General Parameters » Plugins » Auto signin rules
    :Description: List of auto signin rules
    :Used by portal: yes

available2F
    :Description: Available second factor modules
    :Used by portal: yes
    :Ini only: yes

available2FSelfRegistration
    :Description: Available self-registration modules for second factor
    :Used by portal: yes
    :Ini only: yes

avoidAssignment
    :Location: General Parameters » Advanced parameters » Security » Avoid assignment in expressions
    :Description: Avoid assignment in expressions
    :Used by portal: yes
    :Used by handler: yes

browsersDontStorePassword
    :Location: General Parameters » Advanced parameters » Security » Avoid browsers to store users password
    :Description: Avoid browsers to store users password
    :Used by portal: yes

bruteForceProtection
    :Location: General Parameters » Advanced parameters » Security » Brute-force attack protection » Activation
    :Description: Enable brute force attack protection
    :Used by portal: yes

bruteForceProtectionIncrementalTempo
    :Location: General Parameters » Advanced parameters » Security » Brute-force attack protection » Incremental lock
    :Description: Enable incremental lock time for brute force attack protection
    :Used by portal: yes

bruteForceProtectionLockTimes
    :Location: General Parameters » Advanced parameters » Security » Brute-force attack protection » Incremental lock times
    :Description: Incremental lock time values for brute force attack protection
    :Used by portal: yes

bruteForceProtectionMaxAge
    :Location: General Parameters » Advanced parameters » Security » Brute-force attack protection » Maximum age
    :Description: Max age between current and first failed login
    :Used by portal: yes

bruteForceProtectionMaxFailed
    :Location: General Parameters » Advanced parameters » Security » Brute-force attack protection » Allowed failed logins
    :Description: Max allowed failed login
    :Used by portal: yes

bruteForceProtectionMaxLockTime
    :Location: General Parameters » Advanced parameters » Security » Brute-force attack protection » Maximum lock time
    :Description: Max lock time
    :Used by portal: yes

bruteForceProtectionTempo
    :Location: General Parameters » Advanced parameters » Security » Brute-force attack protection » Lock time
    :Description: Lock time
    :Used by portal: yes

cacheTagSalt
    :Location: General Parameters » Portal » Customization » Other » Cache-busting salt
    :Description: Salt value for cache busting tag
    :Used by portal: yes

captcha
    :Location: General Parameters » Portal » Captcha » Custom Captcha module » Captcha module
    :Description: Captcha backend module
    :Used by portal: yes
    :Used by handler: yes

captchaOptions
    :Location: General Parameters » Portal » Captcha » Custom Captcha module » Captcha module options
    :Description: Captcha module options
    :Used by portal: yes
    :Used by handler: yes

captcha_login_enabled
    :Location: General Parameters » Portal » Captcha » Activation in login form
    :Description: Captcha on login page
    :Used by portal: yes

captcha_mail_enabled
    :Location: General Parameters » Portal » Captcha » Activation in password reset by mail form
    :Description: Captcha on password reset page
    :Used by portal: yes

captcha_register_enabled
    :Location: General Parameters » Portal » Captcha » Activation in register form
    :Description: Captcha on account creation page
    :Used by portal: yes

captcha_size
    :Location: General Parameters » Portal » Captcha » Size
    :Description: Captcha size
    :Used by portal: yes

casAccessControlPolicy
    :Location: CAS Service » Access control policy
    :Description: CAS access control policy
    :Used by portal: yes

casAppMetaDataExportedVars
    :Location: CAS Applications » *configuration key* » Exported attributes
    :Description: CAS exported variables
    :Used by portal: yes

casAppMetaDataMacros
    :Location: CAS Applications » *configuration key* » Macros
    :Description: Macros
    :Used by portal: yes

casAppMetaDataNodes
    :Used by portal: yes
    :Ini only: yes

casAppMetaDataOptions
    :Location: Options
    :Description: Root of CAS app options
    :Used by portal: yes

casAppMetaDataOptionsAllowProxy
    :Location: CAS Applications » *configuration key* » Options » Allow proxy
    :Description: Allow CAS proxy
    :Used by portal: yes

casAppMetaDataOptionsAuthnLevel
    :Location: CAS Applications » *configuration key* » Options » Required authentication level
    :Description: Authentication level requires to access to this CAS application
    :Used by portal: yes

casAppMetaDataOptionsComment
    :Location: CAS Applications » *configuration key* » Options » Comment
    :Description: Comment for this CAS application
    :Used by portal: yes

casAppMetaDataOptionsDisplayName
    :Location: CAS Applications » *configuration key* » Display » Name
    :Used by portal: yes

casAppMetaDataOptionsLogout
    :Location: CAS Applications » *configuration key* » Options » Logout
    :Used by portal: yes

casAppMetaDataOptionsRule
    :Location: CAS Applications » *configuration key* » Options » Access rule
    :Description: CAS application rule
    :Used by portal: yes

casAppMetaDataOptionsService
    :Location: CAS Applications » *configuration key* » Options » Service URL
    :Description: CAS application service
    :Used by portal: yes

casAppMetaDataOptionsUserAttribute
    :Location: CAS Applications » *configuration key* » Options » User attribute
    :Description: CAS User attribute
    :Used by portal: yes

casAttr
    :Location: CAS Service » CAS login
    :Description: Pivot attribute for CAS
    :Used by portal: yes

casAttributes
    :Location: CAS Service » CAS exported attributes
    :Description: CAS exported attributes
    :Used by portal: yes

casAuthnLevel
    :Location: General Parameters » Authentication parameters » CAS parameters » Authentication level
    :Description: CAS authentication level
    :Used by portal: yes

casBackChannelSingleLogout
    :Location: CAS Service » Back-channel logout
    :Description: Enable CAS (Back-Channel) Single Logout
    :Used by portal: yes

casSrvMetaDataExportedVars
    :Location: CAS Servers » *configuration key* » Exported attributes
    :Description: CAS exported variables
    :Used by portal: yes

casSrvMetaDataNodes
    :Used by portal: yes
    :Ini only: yes

casSrvMetaDataOptions
    :Location: Options
    :Description: Root of CAS server options
    :Used by portal: yes

casSrvMetaDataOptionsComment
    :Location: CAS Servers » *configuration key* » Options » Comment
    :Description: Comment for this CAS server
    :Used by portal: yes

casSrvMetaDataOptionsDisplayName
    :Location: CAS Servers » *configuration key* » Display » Name
    :Description: Name to display for this CAS server
    :Used by portal: yes

casSrvMetaDataOptionsGateway
    :Location: CAS Servers » *configuration key* » Options » Gateway authentication
    :Used by portal: yes

casSrvMetaDataOptionsIcon
    :Location: CAS Servers » *configuration key* » Display » Logo
    :Description: Path of CAS server icon
    :Used by portal: yes

casSrvMetaDataOptionsProxiedServices
    :Location: CAS Servers » *configuration key* » Proxied services
    :Used by portal: yes

casSrvMetaDataOptionsRenew
    :Location: CAS Servers » *configuration key* » Options » Renew authentication
    :Used by portal: yes

casSrvMetaDataOptionsResolutionRule
    :Location: CAS Servers » *configuration key* » Display » Resolution rule
    :Used by portal: yes

casSrvMetaDataOptionsSamlValidate
    :Location: CAS Servers » *configuration key* » Options » Use SAML 1.1 validation
    :Description: use SAML validateion
    :Used by portal: yes

casSrvMetaDataOptionsSortNumber
    :Location: CAS Servers » *configuration key* » Display » Order
    :Description: Number to sort buttons
    :Used by portal: yes

casSrvMetaDataOptionsTooltip
    :Location: CAS Servers » *configuration key* » Display » Tooltip
    :Description: Tooltip for this CAS Server
    :Used by portal: yes

casSrvMetaDataOptionsUrl
    :Location: CAS Servers » *configuration key* » Options » Server URL
    :Used by portal: yes

casStorage
    :Location: CAS Service » Sessions » CAS sessions module name
    :Description: Apache::Session module to store CAS user data
    :Used by portal: yes

casStorageOptions
    :Location: CAS Service » Sessions » CAS sessions module options
    :Description: Apache::Session module parameters
    :Used by portal: yes

casStrictMatching
    :Location: CAS Service » Use strict URL matching
    :Description: Disable host-based matching of CAS services
    :Used by portal: yes

casTicketExpiration
    :Location: CAS Service » Temporary ticket lifetime
    :Description: Expiration time of Service and Proxy tickets
    :Used by portal: yes

cda
    :Location: General Parameters » Cookies » Multiple domains
    :Description: Enable Cross Domain Authentication
    :Used by portal: yes
    :Used by handler: yes

certificateResetByMailCeaAttribute
    :Location: General Parameters » Plugins » Reset certificate by mail » Other »  Certificate Exact Assertion attribute name
    :Used by portal: yes

certificateResetByMailCertificateAttribute
    :Location: General Parameters » Plugins » Reset certificate by mail » Other »  Certificate binary content attribute name
    :Used by portal: yes

certificateResetByMailStep1Body
    :Location: General Parameters » Plugins » Reset certificate by mail » Mail content » Reset mail content
    :Description: Custom Certificate reset mail body
    :Used by portal: yes

certificateResetByMailStep1Subject
    :Location: General Parameters » Plugins » Reset certificate by mail » Mail content » Reset mail subject
    :Description: Mail subject for certificate reset email
    :Used by portal: yes

certificateResetByMailStep2Body
    :Location: General Parameters » Plugins » Reset certificate by mail » Mail content » Confirmation mail content
    :Description: Custom confirm Certificate reset mail body
    :Used by portal: yes

certificateResetByMailStep2Subject
    :Location: General Parameters » Plugins » Reset certificate by mail » Mail content » Confirmation mail subject
    :Description: Mail subject for reset confirmation
    :Used by portal: yes

certificateResetByMailURL
    :Location: General Parameters » Plugins » Reset certificate by mail » Other » Reset page URL
    :Description: URL of certificate reset page
    :Used by portal: yes

certificateResetByMailValidityDelay
    :Location: General Parameters » Plugins » Reset certificate by mail » Other » Minimum duration before expiration
    :Used by portal: yes

checkDevOps
    :Location: General Parameters » Plugins » Check DevOps handler file » Activation
    :Description: Enable check DevOps
    :Used by portal: yes

checkDevOpsCheckSessionAttributes
    :Location: General Parameters » Plugins » Check DevOps handler file » Check session attributes
    :Description: Check if session attributes exist
    :Used by portal: yes

checkDevOpsDisplayNormalizedHeaders
    :Location: General Parameters » Plugins » Check DevOps handler file » Display normalized headers
    :Description: Display normalized headers
    :Used by portal: yes

checkDevOpsDownload
    :Location: General Parameters » Plugins » Check DevOps handler file » Download file
    :Description: Enable check DevOps download field
    :Used by portal: yes

checkEntropy
    :Location: General Parameters » Advanced parameters » Security » Check password entropy » Activation
    :Description: Enable entropy check of password
    :Used by portal: yes

checkEntropyRequired
    :Location: General Parameters » Advanced parameters » Security » Check password entropy » Require entropy check to pass
    :Description: Require entropy check to pass
    :Used by portal: yes

checkEntropyRequiredLevel
    :Location: General Parameters » Advanced parameters » Security » Check password entropy » Minimal entropy level for password to be accepted
    :Description: Minimal entropy required for the password to be accepted
    :Used by portal: yes

checkHIBP
    :Location: General Parameters » Advanced parameters » Security » Check HIBP API » Activation
    :Description: Enable check HIBP
    :Used by portal: yes

checkHIBPRequired
    :Location: General Parameters » Advanced parameters » Security » Check HIBP API » Require HIBP check to pass
    :Description: Require HIBP check to pass
    :Used by portal: yes

checkHIBPURL
    :Location: General Parameters » Advanced parameters » Security » Check HIBP API » HIBP URL
    :Description: URL of Have I Been Pwned API
    :Used by portal: yes

checkMsg
    :Description: Timeout to check new evant
    :Used by portal: yes
    :Used by handler: yes
    :Ini only: yes

checkState
    :Location: General Parameters » Plugins » Check state » Activation
    :Description: Enable CheckState plugin
    :Used by portal: yes

checkStateSecret
    :Location: General Parameters » Plugins » Check state » Shared secret
    :Description: Secret token for CheckState plugin
    :Used by portal: yes

checkTime
    :Description: Timeout to check new configuration in local cache
    :Used by portal: yes
    :Used by handler: yes
    :Ini only: yes

checkUser
    :Location: General Parameters » Plugins » Check user SSO profile » Activation
    :Description: Enable check user
    :Used by portal: yes

checkUserDisplayComputedSession
    :Location: General Parameters » Plugins » Check user SSO profile » Display » Computed sessions
    :Description: Display empty headers rule
    :Used by portal: yes

checkUserDisplayEmptyHeaders
    :Location: General Parameters » Plugins » Check user SSO profile » Display » Empty headers
    :Description: Display empty headers rule
    :Used by portal: yes

checkUserDisplayEmptyValues
    :Location: General Parameters » Plugins » Check user SSO profile » Display » Empty values
    :Description: Display session empty values rule
    :Used by portal: yes

checkUserDisplayHiddenAttributes
    :Location: General Parameters » Plugins » Check user SSO profile » Display » Hidden attributes
    :Description: Display hidden attributes rule
    :Used by portal: yes

checkUserDisplayHistory
    :Location: General Parameters » Plugins » Check user SSO profile » Display » History
    :Description: Display history rule
    :Used by portal: yes

checkUserDisplayNormalizedHeaders
    :Location: General Parameters » Plugins » Check user SSO profile » Display » Normalized headers
    :Description: Display normalized headers rule
    :Used by portal: yes

checkUserDisplayPersistentInfo
    :Location: General Parameters » Plugins » Check user SSO profile » Display » Persistent session data
    :Description: Display persistent session info rule
    :Used by portal: yes

checkUserHiddenAttributes
    :Location: General Parameters » Plugins » Check user SSO profile » Hidden attributes
    :Description: Attributes to hide in CheckUser plugin
    :Used by portal: yes

checkUserHiddenHeaders
    :Location: General Parameters » Plugins » Check user SSO profile » Hidden headers
    :Description: Header values to hide if not empty
    :Used by portal: yes

checkUserIdRule
    :Location: General Parameters » Plugins » Check user SSO profile » Identities use rule
    :Description: checkUser identities rule
    :Used by portal: yes

checkUserSearchAttributes
    :Location: General Parameters » Plugins » Check user SSO profile » Attributes used for searching sessions
    :Description: Attributes used for retrieving sessions in user DataBase
    :Used by portal: yes

checkUserUnrestrictedUsersRule
    :Location: General Parameters » Plugins » Check user SSO profile » Unrestricted users rule
    :Description: checkUser unrestricted users rule
    :Used by portal: yes

checkXSS
    :Location: General Parameters » Advanced parameters » Security » Check XSS attacks
    :Description: Check XSS
    :Used by portal: yes

combModules
    :Location: General Parameters » Authentication parameters » Combination parameters » Module list
    :Description: Combination module description
    :Used by portal: yes

combination
    :Location: General Parameters » Authentication parameters » Combination parameters » Combination
    :Description: Combination rule
    :Used by portal: yes

compactConf
    :Location: General Parameters » Advanced parameters » Events management » Compact configuration file
    :Description: Compact configuration
    :Used by portal: yes

configStorage
    :Description: Configuration storage
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

confirmFormMethod
    :Location: General Parameters » Advanced parameters » Forms » Method for confirm form
    :Description: HTTP method for confirm page form
    :Used by portal: yes

contextSwitchingAllowed2fModifications
    :Location: General Parameters » Plugins » Switch context another user » Allow 2FA modifications
    :Description: Allowed SFA modifications
    :Used by portal: yes

contextSwitchingIdRule
    :Location: General Parameters » Plugins » Switch context another user » Identities use rule
    :Description: Context switching identities rule
    :Used by portal: yes

contextSwitchingPrefix
    :Description: Prefix to store real session Id
    :Used by portal: yes
    :Ini only: yes

contextSwitchingRule
    :Location: General Parameters » Plugins » Switch context another user » Use rule
    :Description: Context switching activation rule
    :Used by portal: yes

contextSwitchingStopWithLogout
    :Location: General Parameters » Plugins » Switch context another user » Stop by logout
    :Description: Stop context switching by logout
    :Used by portal: yes

contextSwitchingUnrestrictedUsersRule
    :Location: General Parameters » Plugins » Switch context another user » Unrestricted users rule
    :Description: Context switching unrestricted users rule
    :Used by portal: yes

cookieExpiration
    :Location: General Parameters » Cookies » Cookie expiration time
    :Description: Cookie expiration
    :Used by portal: yes
    :Used by handler: yes

cookieName
    :Location: General Parameters » Cookies » Cookie name
    :Description: Name of the main cookie
    :Used by portal: yes
    :Used by handler: yes

corsAllow_Credentials
    :Location: General Parameters » Advanced parameters » Security » Cross-Origin Resource Sharing » Access-Control-Allow-Credentials
    :Description: Allow credentials for Cross-Origin Resource Sharing
    :Used by portal: yes

corsAllow_Headers
    :Location: General Parameters » Advanced parameters » Security » Cross-Origin Resource Sharing » Access-Control-Allow-Headers
    :Description: Allowed headers for Cross-Origin Resource Sharing
    :Used by portal: yes

corsAllow_Methods
    :Location: General Parameters » Advanced parameters » Security » Cross-Origin Resource Sharing » Access-Control-Allow-Methods
    :Description: Allowed methods for Cross-Origin Resource Sharing
    :Used by portal: yes

corsAllow_Origin
    :Location: General Parameters » Advanced parameters » Security » Cross-Origin Resource Sharing » Access-Control-Allow-Origin
    :Description: Allowed origine for Cross-Origin Resource Sharing
    :Used by portal: yes

corsEnabled
    :Location: General Parameters » Advanced parameters » Security » Cross-Origin Resource Sharing » Activation
    :Description: Enable Cross-Origin Resource Sharing
    :Used by portal: yes

corsExpose_Headers
    :Location: General Parameters » Advanced parameters » Security » Cross-Origin Resource Sharing » Access-Control-Expose-Headers
    :Description: Exposed headers for Cross-Origin Resource Sharing
    :Used by portal: yes

corsMax_Age
    :Location: General Parameters » Advanced parameters » Security » Cross-Origin Resource Sharing » Access-Control-Max-Age
    :Description: Max-age for Cross-Origin Resource Sharing
    :Used by portal: yes

crowdSecAgentResponseCode
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Agent » Ban response code
    :Description: Crowdsec ban response code
    :Used by portal: yes

crowdSecAgentResponseValue
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Agent » Ban response content,
    :Description: Crowdsec ban response text
    :Used by portal: yes

crowdsec
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Bouncer » Activation
    :Description: CrowdSec bouncer activation
    :Used by portal: yes

crowdsecAction
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Bouncer » Action
    :Description: CrowdSec action
    :Used by portal: yes

crowdsecAgent
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Agent » Activation
    :Description: Enable plugin to report auth failures to Crowdsec (simple alert)
    :Used by portal: yes

crowdsecBlockDelay
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Agent » Check delay
    :Description: Crowdsec-Agent check delay
    :Used by portal: yes

crowdsecFilters
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Agent » Filters directory
    :Description: Crowdsec filters directory
    :Used by portal: yes

crowdsecIgnoreFailures
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Bouncer » Ignore Crowdsec failures
    :Description: Ignore Crowdsec errors
    :Used by portal: yes

crowdsecKey
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Bouncer » API key
    :Description: CrowdSec API key
    :Used by portal: yes

crowdsecMachineId
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Agent » Crowdsec agent ID
    :Description: Crowdsec machine ID to send alerts
    :Used by portal: yes

crowdsecMaxFailures
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Agent » Max failures allowed during delay
    :Description: Crowdesc-Agent maximum failures allowed during delay
    :Used by portal: yes

crowdsecPassword
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Agent » Password
    :Description: Crowdsec password to send alerts
    :Used by portal: yes

crowdsecUrl
    :Location: General Parameters » Advanced parameters » Security » Crowdsec » Bouncer » Base URL of local API
    :Description: Base URL of CrowdSec local API
    :Used by portal: yes

cspConnect
    :Location: General Parameters » Advanced parameters » Security » Content Security Policy » Ajax destinations
    :Description: Authorized Ajax destination for Content-Security-Policy
    :Used by portal: yes

cspDefault
    :Location: General Parameters » Advanced parameters » Security » Content Security Policy » Default value
    :Description: Default value for Content-Security-Policy
    :Used by portal: yes

cspFont
    :Location: General Parameters » Advanced parameters » Security » Content Security Policy » Font source
    :Description: Font source for Content-Security-Policy
    :Used by portal: yes

cspFormAction
    :Location: General Parameters » Advanced parameters » Security » Content Security Policy » Form destinations
    :Description: Form action destination for Content-Security-Policy
    :Used by portal: yes

cspFrameAncestors
    :Location: General Parameters » Advanced parameters » Security » Content Security Policy » Frame ancestors URL
    :Description: Frame-Ancestors for Content-Security-Policy
    :Used by portal: yes

cspImg
    :Location: General Parameters » Advanced parameters » Security » Content Security Policy » Image source
    :Description: Image source for Content-Security-Policy
    :Used by portal: yes

cspScript
    :Location: General Parameters » Advanced parameters » Security » Content Security Policy » Script source
    :Description: Javascript source for Content-Security-Policy
    :Used by portal: yes

cspStyle
    :Location: General Parameters » Advanced parameters » Security » Content Security Policy » Style source
    :Description: Style source for Content-Security-Policy
    :Used by portal: yes

customAddParams
    :Location: General Parameters » Authentication parameters » Custom module names » Additional parameters
    :Description: Custom additional parameters
    :Used by portal: yes

customAuth
    :Location: General Parameters » Authentication parameters » Custom module names » Custom authentication module
    :Description: Custom auth module
    :Used by portal: yes

customFunctions
    :Location: General Parameters » Advanced parameters » Custom functions
    :Description: List of custom functions
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes

customPassword
    :Location: General Parameters » Authentication parameters » Custom module names » Custom password module
    :Description: Custom password module
    :Used by portal: yes

customPlugins
    :Location: General Parameters » Plugins » Custom plugins » Modules list
    :Description: Custom plugins
    :Used by portal: yes

customPluginsParams
    :Location: General Parameters » Plugins » Custom plugins » Additional parameters
    :Description: Custom plugins parameters
    :Used by portal: yes

customRegister
    :Location: General Parameters » Authentication parameters » Custom module names » Custom register module
    :Description: Custom register module
    :Used by portal: yes

customResetCertByMail
    :Location: General Parameters » Authentication parameters » Custom module names » Custom certificateResetByMail module
    :Description: Custom certificateResetByMail module
    :Used by portal: yes

customToTrace
    :Location: General Parameters » Logs » REMOTE_CUSTOM
    :Description: Session parameter used to fill REMOTE_CUSTOM
    :Used by portal: yes
    :Used by handler: yes

customUserDB
    :Location: General Parameters » Authentication parameters » Custom module names » Custom users module
    :Description: Custom user DB module
    :Used by portal: yes

dbiAuthChain
    :Location: General Parameters » Authentication parameters » DBI parameters » Connection » Chain
    :Used by portal: yes

dbiAuthLoginCol
    :Location: General Parameters » Authentication parameters » DBI parameters » Schema » Login field name
    :Used by portal: yes

dbiAuthPassword
    :Location: General Parameters » Authentication parameters » DBI parameters » Connection » Password
    :Used by portal: yes

dbiAuthPasswordCol
    :Location: General Parameters » Authentication parameters » DBI parameters » Schema » Password field name
    :Used by portal: yes

dbiAuthPasswordHash
    :Location: General Parameters » Authentication parameters » DBI parameters » Password » Hash scheme
    :Used by portal: yes

dbiAuthTable
    :Location: General Parameters » Authentication parameters » DBI parameters » Schema » Authentication table
    :Used by portal: yes

dbiAuthUser
    :Location: General Parameters » Authentication parameters » DBI parameters » Connection » User
    :Used by portal: yes

dbiAuthnLevel
    :Location: General Parameters » Authentication parameters » DBI parameters » Authentication level
    :Description: DBI authentication level
    :Used by portal: yes

dbiDynamicHashEnabled
    :Location: General Parameters » Authentication parameters » DBI parameters » Password » dynamic hashing » dynamic hash activation
    :Used by portal: yes

dbiDynamicHashNewPasswordScheme
    :Location: General Parameters » Authentication parameters » DBI parameters » Password » dynamic hashing » Dynamic hash scheme for new passwords
    :Used by portal: yes

dbiDynamicHashValidSaltedSchemes
    :Location: General Parameters » Authentication parameters » DBI parameters » Password » dynamic hashing » Supported salted schemes
    :Used by portal: yes

dbiDynamicHashValidSchemes
    :Location: General Parameters » Authentication parameters » DBI parameters » Password » dynamic hashing » Supported non-salted schemes
    :Used by portal: yes

dbiExportedVars
    :Location: General Parameters » Authentication parameters » DBI parameters » Exported variables
    :Description: DBI exported variables
    :Used by portal: yes

dbiPasswordMailCol
    :Location: General Parameters » Authentication parameters » DBI parameters » Schema » Mail field name
    :Used by portal: yes

dbiUserTable
    :Location: General Parameters » Authentication parameters » DBI parameters » Schema » User table
    :Used by portal: yes

decryptValueFunctions
    :Location: General Parameters » Plugins » Decrypt value » Decrypt functions
    :Description: Custom function used for decrypting values
    :Used by portal: yes

decryptValueRule
    :Location: General Parameters » Plugins » Decrypt value » Use rule
    :Description: Decrypt value activation rule
    :Used by portal: yes

defaultNewKeySize
    :Description: Default size for new RSA key helper
    :Used by manager: yes
    :Ini only: yes

demoExportedVars
    :Location: General Parameters » Authentication parameters » Demonstration parameters » Exported variables
    :Description: Demo exported variables
    :Used by portal: yes

disablePersistentStorage
    :Location: General Parameters » Sessions » Persistent sessions » Disable storage
    :Description: Enabled persistent storage
    :Used by portal: yes

disabledPlugins
    :Location: General Parameters » Plugins » Custom plugins » Disabled plugins
    :Description: Disabled plugins
    :Used by portal: yes

displaySessionId
    :Location: General Parameters » Sessions » Display session identifier
    :Description: Display _session_id with sessions explorer
    :Used by portal: yes

domain
    :Location: General Parameters » Cookies » Domain
    :Description: DNS domain
    :Used by portal: yes
    :Used by handler: yes

eventQueueName
    :Location: General Parameters » Advanced parameters » Events management » Event channel name
    :Description: Event channel name
    :Used by portal: yes

eventStatus
    :Description: Push status into message broker
    :Used by handler: yes
    :Ini only: yes

exportedAttr
    :Location: General Parameters » Plugins » Portal servers » SOAP/REST exported attributes
    :Description: List of attributes to export by SOAP or REST servers
    :Used by portal: yes

exportedHeaders
    :Location: Virtual Hosts » *configuration key* » Exported headers
    :Description: Virtualhost headers
    :Used by handler: yes

exportedVars
    :Location: Variables » Exported Variables
    :Description: Main exported variables
    :Used by portal: yes

ext2FSendCommand
    :Location: General Parameters » Second factors » External second factor » Send command
    :Description: Send command of External second factor
    :Used by portal: yes

ext2FValidateCommand
    :Location: General Parameters » Second factors » External second factor » Validation command
    :Description: Validation command of External second factor
    :Used by portal: yes

ext2fActivation
    :Location: General Parameters » Second factors » External second factor » Activation
    :Description: External second factor activation
    :Used by portal: yes

ext2fAuthnLevel
    :Location: General Parameters » Second factors » External second factor » Authentication level
    :Description: Authentication level for users authentified by External second factor
    :Used by portal: yes

ext2fCodeActivation
    :Location: General Parameters » Second factors » External second factor » Code regex
    :Description: OTP generated by Portal
    :Used by portal: yes

ext2fLabel
    :Location: General Parameters » Second factors » External second factor » Label
    :Description: Portal label for External second factor
    :Used by portal: yes

ext2fLogo
    :Location: General Parameters » Second factors » External second factor » Logo
    :Description: Custom logo for External 2F
    :Used by portal: yes

ext2fResendInterval
    :Location: General Parameters » Second factors » External second factor » Re-send interval
    :Description: Delay before user is allowed to resend code
    :Used by portal: yes

facebookAppId
    :Location: General Parameters » Authentication parameters » Facebook parameters » Facebook application ID
    :Used by portal: yes

facebookAppSecret
    :Location: General Parameters » Authentication parameters » Facebook parameters » Facebook application secret
    :Used by portal: yes

facebookAuthnLevel
    :Location: General Parameters » Authentication parameters » Facebook parameters » Authentication level
    :Description: Facebook authentication level
    :Used by portal: yes

facebookExportedVars
    :Location: General Parameters » Authentication parameters » Facebook parameters » Exported variables
    :Description: Facebook exported variables
    :Used by portal: yes

facebookUserField
    :Location: General Parameters » Authentication parameters » Facebook parameters » Field containing user identifier
    :Used by portal: yes

failedLoginNumber
    :Location: General Parameters » Plugins » Login history » Max failed logins count
    :Description: Number of failures stored in login history
    :Used by portal: yes

findUser
    :Location: General Parameters » Plugins » Search for user account » Activation
    :Description: Enable find user
    :Used by portal: yes

findUserControl
    :Location: General Parameters » Plugins » Search for user account » Parameters control
    :Description: Regular expression to validate parameters
    :Used by portal: yes

findUserExcludingAttributes
    :Location: General Parameters » Plugins » Search for user account » Excluding attributes
    :Description: Attributes used for excluding accounts
    :Used by portal: yes

findUserSearchingAttributes
    :Location: General Parameters » Plugins » Search for user account » Searching attributes
    :Description: Attributes used for searching accounts
    :Used by portal: yes

findUserWildcard
    :Location: General Parameters » Plugins » Search for user account » Character used as wildcard
    :Description: Character used as wildcard
    :Used by portal: yes

floatingCategoryName
    :Location: General Parameters » Portal » Customization » Floating category name
    :Description: Name of the category displayed as floating menu
    :Used by portal: yes

forceGlobalStorageIssuerOTT
    :Description: Force Issuer tokens to be stored into Global Storage
    :Used by portal: yes
    :Ini only: yes

forceGlobalStorageUpgradeOTT
    :Description: Force Upgrade tokens be stored into Global Storage
    :Used by portal: yes
    :Ini only: yes

formTimeout
    :Location: General Parameters » Advanced parameters » Security » Form timeout
    :Description: Token timeout for forms
    :Used by portal: yes

githubAuthnLevel
    :Location: General Parameters » Authentication parameters » GitHub Parameters » Authentication level
    :Description: GitHub authentication level
    :Used by portal: yes

githubClientID
    :Location: General Parameters » Authentication parameters » GitHub Parameters » Client ID
    :Used by portal: yes

githubClientSecret
    :Location: General Parameters » Authentication parameters » GitHub Parameters » Client secret
    :Used by portal: yes

githubScope
    :Location: General Parameters » Authentication parameters » GitHub Parameters » Scope
    :Used by portal: yes

githubUserField
    :Location: General Parameters » Authentication parameters » GitHub Parameters » Field containing user identifier
    :Used by portal: yes

globalLogoutCustomParam
    :Location: General Parameters » Plugins » Global logout » Custom parameter
    :Description: Custom session parameter to display
    :Used by portal: yes

globalLogoutRule
    :Location: General Parameters » Plugins » Global logout » Activation
    :Description: Global logout activation rule
    :Used by portal: yes

globalLogoutTimer
    :Location: General Parameters » Plugins » Global logout » Auto accept time
    :Description: Global logout auto accept time
    :Used by portal: yes

globalStorage
    :Location: General Parameters » Sessions » Sessions storage » Apache::Session module
    :Description: Session backend module
    :Used by portal: yes
    :Used by handler: yes

globalStorageOptions
    :Location: General Parameters » Sessions » Sessions storage » Apache::Session module parameters
    :Description: Session backend module options
    :Used by portal: yes
    :Used by handler: yes

gpgAuthnLevel
    :Location: General Parameters » Authentication parameters » GPG parameters » Authentication level
    :Description: GPG authentication level
    :Used by portal: yes

gpgDb
    :Location: General Parameters » Authentication parameters » GPG parameters » GPG database
    :Description: GPG keys database
    :Used by portal: yes

grantSessionRules
    :Location: General Parameters » Sessions » Opening conditions
    :Description: Rules to grant sessions
    :Used by portal: yes

groupLDAPFilter
    :Location: General Parameters » Authentication parameters » LDAP parameters » Groups » Group Filter
    :Description: LDAP filter for group search
    :Used by portal: yes

groups
    :Location: Variables » Groups
    :Description: Groups
    :Used by portal: yes

groupsBeforeMacros
    :Location: General Parameters » Advanced parameters » Compute groups before macros
    :Description: Compute groups before macros
    :Used by portal: yes

handlerInternalCache
    :Description: Handler internal cache timeout
    :Used by portal: yes
    :Used by handler: yes
    :Ini only: yes

handlerServiceTokenTTL
    :Description: Handler ServiceToken timeout
    :Used by portal: yes
    :Used by handler: yes
    :Ini only: yes

hashedSessionStore
    :Location: General Parameters » Advanced parameters » Security » Hashed session storage
    :Description: Securize storage of sensible sessions
    :Used by portal: yes

hiddenAttributes
    :Location: General Parameters » Logs » Hidden attributes
    :Description: Name of attributes to hide in logs
    :Used by portal: yes

hideOldPassword
    :Location: General Parameters » Portal » Customization » Password management » Hide old password
    :Description: Hide old password in portal
    :Used by portal: yes

httpOnly
    :Location: General Parameters » Cookies » Javascript protection
    :Description: Enable httpOnly flag in cookie
    :Used by portal: yes
    :Used by handler: yes

https
    :Location: General Parameters » Advanced parameters » Handler redirections » HTTPS
    :Description: Use HTTPS for redirection from portal
    :Used by handler: yes

impersonationHiddenAttributes
    :Location: General Parameters » Plugins » Impersonation » Hidden attributes
    :Description: Attributes to skip
    :Used by portal: yes

impersonationIdRule
    :Location: General Parameters » Plugins » Impersonation » Identities use rule
    :Description: Impersonation identities rule
    :Used by portal: yes

impersonationMergeSSOgroups
    :Location: General Parameters » Plugins » Impersonation » Merge spoofed and real SSO groups
    :Description: Merge spoofed and real SSO groups
    :Used by portal: yes

impersonationPrefix
    :Description: Prefix to rename real session attributes
    :Used by portal: yes
    :Ini only: yes

impersonationRule
    :Location: General Parameters » Plugins » Impersonation » Use rule
    :Description: Impersonation activation rule
    :Used by portal: yes

impersonationSkipEmptyValues
    :Location: General Parameters » Plugins » Impersonation » Skip empty values
    :Description: Skip session empty values
    :Used by portal: yes

impersonationUnrestrictedUsersRule
    :Location: General Parameters » Plugins » Impersonation » Unrestricted users rule
    :Description: Impersonation unrestricted users rule
    :Used by portal: yes

infoFormMethod
    :Location: General Parameters » Advanced parameters » Forms » Method for info form
    :Description: HTTP method for info page form
    :Used by portal: yes

initializePasswordReset
    :Location: General Parameters » Plugins » Initialize Password Reset API plugin » Activation
    :Description: Enable Password Reset API plugin
    :Used by portal: yes

initializePasswordResetSecret
    :Location: General Parameters » Plugins » Initialize Password Reset API plugin » Secret key
    :Description: Secret key for the Initialize Password Reset API
    :Used by portal: yes

issuerDBCASActivation
    :Location: General Parameters » Issuer modules » CAS » Activation
    :Description: CAS server activation
    :Used by portal: yes

issuerDBCASPath
    :Location: General Parameters » Issuer modules » CAS » Path
    :Description: CAS server request path
    :Used by portal: yes

issuerDBCASRule
    :Location: General Parameters » Issuer modules » CAS » Use rule
    :Description: CAS server rule
    :Used by portal: yes

issuerDBGetActivation
    :Location: General Parameters » Issuer modules » GET » Activation
    :Description: Get issuer activation
    :Used by portal: yes

issuerDBGetParameters
    :Location: General Parameters » Issuer modules » GET » GET parameters
    :Description: List of virtualHosts with their get parameters
    :Used by portal: yes

issuerDBGetPath
    :Location: General Parameters » Issuer modules » GET » Path
    :Description: Get issuer request path
    :Used by portal: yes

issuerDBGetRule
    :Location: General Parameters » Issuer modules » GET » Use rule
    :Description: Get issuer rule
    :Used by portal: yes

issuerDBJitsiMeetTokensActivation
    :Location: General Parameters » Issuer modules » Jitsi » Activation
    :Description: Jitsi issuer activation
    :Used by portal: yes

issuerDBJitsiMeetTokensPath
    :Location: General Parameters » Issuer modules » Jitsi » Path
    :Description: Jitsi issuer request path
    :Used by portal: yes

issuerDBJitsiMeetTokensRule
    :Location: General Parameters » Issuer modules » Jitsi » Use rule
    :Description: Jitsi issuer rule
    :Used by portal: yes

issuerDBOpenIDActivation
    :Location: General Parameters » Issuer modules » OpenID » Activation
    :Description: OpenID server activation
    :Used by portal: yes

issuerDBOpenIDConnectActivation
    :Location: General Parameters » Issuer modules » OpenID Connect » Activation
    :Description: OpenID Connect server activation
    :Used by portal: yes

issuerDBOpenIDConnectPath
    :Location: General Parameters » Issuer modules » OpenID Connect » Path
    :Description: OpenID Connect server request path
    :Used by portal: yes

issuerDBOpenIDConnectRule
    :Location: General Parameters » Issuer modules » OpenID Connect » Use rule
    :Description: OpenID Connect server rule
    :Used by portal: yes

issuerDBOpenIDPath
    :Location: General Parameters » Issuer modules » OpenID » Path
    :Description: OpenID server request path
    :Used by portal: yes

issuerDBOpenIDRule
    :Location: General Parameters » Issuer modules » OpenID » Use rule
    :Description: OpenID server rule
    :Used by portal: yes

issuerDBSAMLActivation
    :Location: General Parameters » Issuer modules » SAML » Activation
    :Description: SAML IDP activation
    :Used by portal: yes

issuerDBSAMLPath
    :Location: General Parameters » Issuer modules » SAML » Path
    :Description: SAML IDP request path
    :Used by portal: yes

issuerDBSAMLRule
    :Location: General Parameters » Issuer modules » SAML » Use rule
    :Description: SAML IDP rule
    :Used by portal: yes

issuersTimeout
    :Location: General Parameters » Issuer modules » Options » Issuers timeout
    :Description: Token timeout for issuers
    :Used by portal: yes

jitsiAppId
    :Location: General Parameters » Issuer modules » Jitsi » Options » Application ID
    :Description: Jitsi application ID
    :Used by portal: yes

jitsiAppSecret
    :Location: General Parameters » Issuer modules » Jitsi » Options » Shared secret
    :Description: Jitsi application secret
    :Used by portal: yes

jitsiDefaultServer
    :Location: General Parameters » Issuer modules » Jitsi » Options » Jitsi server URL
    :Description: Jitsi server URL
    :Used by portal: yes

jitsiExpiration
    :Location: General Parameters » Issuer modules » Jitsi » Options » Jitsi JWT expiration
    :Description: Jitsi JWT expiration
    :Used by portal: yes

jitsiIdAttribute
    :Location: General Parameters » Issuer modules » Jitsi » Options » Exported attributes » Identifier attribute
    :Description: Jitsi attribute for ID
    :Used by portal: yes

jitsiMailAttribute
    :Location: General Parameters » Issuer modules » Jitsi » Options » Exported attributes » Email attribute
    :Description: Jitsi attribute for email
    :Used by portal: yes

jitsiNameAttribute
    :Location: General Parameters » Issuer modules » Jitsi » Options » Exported attributes » Name attribute
    :Description: Jitsi attribute for name
    :Used by portal: yes

jitsiSigningAlg
    :Location: General Parameters » Issuer modules » Jitsi » Options » Signature algorithm
    :Description: Jitsi JWT signature method
    :Used by portal: yes

jitsiSigningKey
    :Location: General Parameters » Issuer modules » Jitsi » Options » Signing key name
    :Description: Jitsi JWT signature key
    :Used by portal: yes

jsRedirect
    :Location: General Parameters » Advanced parameters » Portal redirections » Redirection message
    :Description: Use javascript for redirections
    :Used by portal: yes

key
    :Location: General Parameters » Advanced parameters » Security » Encryption key
    :Description: Secret key
    :Used by portal: yes

keyComment
    :Location: General Parameters » Keys » *configuration key* » Options » Comment
    :Used by portal: yes

keyId
    :Location: General Parameters » Keys » *configuration key* » Options » External key identifier
    :Used by portal: yes

keyNodes
    :Used by portal: yes
    :Ini only: yes

keyPrivate
    :Location: General Parameters » Keys » *configuration key* » Key material » Private key
    :Used by portal: yes

keyPrivatePwd
    :Location: General Parameters » Keys » *configuration key* » Key material » Private key password
    :Used by portal: yes

keyPublic
    :Location: General Parameters » Keys » *configuration key* » Key material » Public key
    :Used by portal: yes

keys
    :Description: Root of keys
    :Used by portal: yes
    :Ini only: yes

krbAllowedDomains
    :Location: General Parameters » Authentication parameters » Kerberos parameters » Allowed domains
    :Description: Allowed domains
    :Used by portal: yes

krbAuthnLevel
    :Location: General Parameters » Authentication parameters » Kerberos parameters » Kerberos authn level
    :Description: Null authentication level
    :Used by portal: yes

krbByJs
    :Location: General Parameters » Authentication parameters » Kerberos parameters » Use Ajax request
    :Description: Launch Kerberos authentication by Ajax
    :Used by portal: yes

krbKeytab
    :Location: General Parameters » Authentication parameters » Kerberos parameters » Keytab file
    :Description: Kerberos keytab
    :Used by portal: yes

krbRemoveDomain
    :Location: General Parameters » Authentication parameters » Kerberos parameters » Remove domain from Kerberos username
    :Description: Remove domain in Kerberos username
    :Used by portal: yes

ldapAllowResetExpiredPassword
    :Location: General Parameters » Authentication parameters » LDAP parameters » Password » Allow to reset an expired password
    :Description: Allow a user to reset his expired password
    :Used by portal: yes

ldapAuthnLevel
    :Location: General Parameters » Authentication parameters » LDAP parameters » Authentication level
    :Description: LDAP authentication level
    :Used by portal: yes

ldapBase
    :Location: General Parameters » Authentication parameters » LDAP parameters » Connection » Users search base
    :Description: LDAP search base
    :Used by portal: yes

ldapCAFile
    :Location: General Parameters » Authentication parameters » LDAP parameters » Connection » CA file path
    :Description: Location of the certificate file for LDAP connections
    :Used by portal: yes

ldapCAPath
    :Location: General Parameters » Authentication parameters » LDAP parameters » Connection » CA directory path
    :Description: Location of the CA directory for LDAP connections
    :Used by portal: yes

ldapChangePasswordAsUser
    :Location: General Parameters » Authentication parameters » LDAP parameters » Password » Change as user
    :Used by portal: yes

ldapExportedVars
    :Location: General Parameters » Authentication parameters » LDAP parameters » Exported variables
    :Description: LDAP exported variables
    :Used by portal: yes

ldapForcePasswordChangeExpirationWarning
    :Location: General Parameters » Authentication parameters » LDAP parameters » Password » Delay to force password change before expiration
    :Description: Delay to force password change if password is about to expire
    :Used by portal: yes

ldapGetUserBeforePasswordChange
    :Location: General Parameters » Authentication parameters » LDAP parameters » Password » Search for user before password change
    :Used by portal: yes

ldapGroupAttributeName
    :Location: General Parameters » Authentication parameters » LDAP parameters » Groups » Target attribute
    :Description: LDAP attribute name for member in groups
    :Used by portal: yes

ldapGroupAttributeNameGroup
    :Location: General Parameters » Authentication parameters » LDAP parameters » Groups » Group source attribute
    :Description: LDAP attribute name in group entry referenced as member in groups
    :Used by portal: yes

ldapGroupAttributeNameSearch
    :Location: General Parameters » Authentication parameters » LDAP parameters » Groups » Searched attributes
    :Description: LDAP attributes to search in groups
    :Used by portal: yes

ldapGroupAttributeNameUser
    :Location: General Parameters » Authentication parameters » LDAP parameters » Groups » User source attribute
    :Description: LDAP attribute name in user entry referenced as member in groups
    :Used by portal: yes

ldapGroupBase
    :Location: General Parameters » Authentication parameters » LDAP parameters » Groups » Search base
    :Used by portal: yes

ldapGroupDecodeSearchedValue
    :Location: General Parameters » Authentication parameters » LDAP parameters » Groups » Decode searched value
    :Description: Decode value before searching it in LDAP groups
    :Used by portal: yes

ldapGroupObjectClass
    :Location: General Parameters » Authentication parameters » LDAP parameters » Groups » Object class
    :Description: LDAP object class of groups
    :Used by portal: yes

ldapGroupRecursive
    :Location: General Parameters » Authentication parameters » LDAP parameters » Groups » Recursive
    :Description: LDAP recursive search in groups
    :Used by portal: yes

ldapIOTimeout
    :Location: General Parameters » Authentication parameters » LDAP parameters » Connection » Operation timeout
    :Description: LDAP operation timeout
    :Used by portal: yes

ldapITDS
    :Location: General Parameters » Authentication parameters » LDAP parameters » Password » IBM Tivoli DS support
    :Description: Support for IBM Tivoli Directory Server
    :Used by portal: yes

ldapPasswordResetAttribute
    :Location: General Parameters » Authentication parameters » LDAP parameters » Password » Reset attribute
    :Description: LDAP password reset attribute
    :Used by portal: yes

ldapPasswordResetAttributeValue
    :Location: General Parameters » Authentication parameters » LDAP parameters » Password » Reset value
    :Description: LDAP password reset value
    :Used by portal: yes

ldapPort
    :Location: General Parameters » Authentication parameters » LDAP parameters » Connection » Server port
    :Description: LDAP port
    :Used by portal: yes

ldapPpolicyControl
    :Location: General Parameters » Authentication parameters » LDAP parameters » Password » Password policy control
    :Used by portal: yes

ldapPwdEnc
    :Location: General Parameters » Authentication parameters » LDAP parameters » Password » LDAP password encoding
    :Description: LDAP password encoding
    :Used by portal: yes

ldapRaw
    :Location: General Parameters » Authentication parameters » LDAP parameters » Connection » Binary attributes
    :Used by portal: yes

ldapSearchDeref
    :Location: General Parameters » Authentication parameters » LDAP parameters » Filters » Alias dereference
    :Description: "deref" param of Net::LDAP::search()
    :Used by portal: yes

ldapServer
    :Location: General Parameters » Authentication parameters » LDAP parameters » Connection » Server host
    :Description: LDAP server (host or URI)
    :Used by portal: yes

ldapSetPassword
    :Location: General Parameters » Authentication parameters » LDAP parameters » Password » Password modify extended operation
    :Used by portal: yes

ldapTimeout
    :Location: General Parameters » Authentication parameters » LDAP parameters » Connection » Connection timeout
    :Description: LDAP connection timeout
    :Used by portal: yes

ldapUsePasswordResetAttribute
    :Location: General Parameters » Authentication parameters » LDAP parameters » Password » Use reset attribute
    :Description: LDAP store reset flag in an attribute
    :Used by portal: yes

ldapVerify
    :Location: General Parameters » Authentication parameters » LDAP parameters » Connection » Verify LDAP server certificate
    :Description: Whether to validate LDAP certificates
    :Used by portal: yes

ldapVersion
    :Location: General Parameters » Authentication parameters » LDAP parameters » Connection » Version
    :Description: LDAP protocol version
    :Used by portal: yes

linkedInAuthnLevel
    :Location: General Parameters » Authentication parameters » LinkedIn Parameters » Authentication level
    :Description: LinkedIn authentication level
    :Used by portal: yes

linkedInClientID
    :Location: General Parameters » Authentication parameters » LinkedIn Parameters » Client ID
    :Used by portal: yes

linkedInClientSecret
    :Location: General Parameters » Authentication parameters » LinkedIn Parameters » Client secret
    :Used by portal: yes

linkedInFields
    :Location: General Parameters » Authentication parameters » LinkedIn Parameters » Searched fields
    :Used by portal: yes

linkedInScope
    :Location: General Parameters » Authentication parameters » LinkedIn Parameters » Scope
    :Used by portal: yes

linkedInUserField
    :Location: General Parameters » Authentication parameters » LinkedIn Parameters » Field containing user identifier
    :Used by portal: yes

localSessionStorage
    :Location: General Parameters » Sessions » Sessions storage » Cache module
    :Description: Local sessions cache module
    :Used by portal: yes

localSessionStorageOptions
    :Location: General Parameters » Sessions » Sessions storage » Cache module options
    :Description: Sessions cache module options
    :Used by portal: yes

localStorage
    :Description: Local cache
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

localStorageOptions
    :Description: Local cache parameters
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

locationDetect
    :Location: General Parameters » Plugins » Location detection » Activation
    :Description: Enable LocationDetect plugin
    :Used by portal: yes

locationDetectGeoIpDatabase
    :Location: General Parameters » Plugins » Location detection » Path to GeoIP database
    :Description: Path to GeoIP database
    :Used by portal: yes

locationDetectGeoIpLanguages
    :Location: General Parameters » Plugins » Location detection » Languages for GeoIP database
    :Description: Languages for GeoIP database
    :Used by portal: yes

locationDetectIpDetail
    :Location: General Parameters » Plugins » Location detection » Information requested for IP
    :Description: Information requested for IP
    :Used by portal: yes

locationDetectUaDetail
    :Location: General Parameters » Plugins » Location detection » Information requested for User Agent
    :Description: Information requested for User Agent
    :Used by portal: yes

locationRules
    :Location: Virtual Hosts » *configuration key* » Access rules
    :Description: Virtualhost rules
    :Used by handler: yes

log4perlConfFile
    :Description: Log4Perl logger configuration file
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

logLevel
    :Description: Log level, must be set in .ini
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

logger
    :Description: technical logger
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

loginHistoryEnabled
    :Location: General Parameters » Plugins » Login history » Activation
    :Description: Enable login history
    :Used by portal: yes

logoutServices
    :Location: General Parameters » Advanced parameters » Logout forward
    :Description: Send logout trough GET request to these services
    :Used by portal: yes

lokiAuthorization
    :Description: Loki Authorization header value
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

lokiEnv
    :Description: Loki env, default "prod"
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

lokiInstance
    :Description: Loki instance, default `hostname` output
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

lokiLabel
    :Description: Loki label, default llng
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

lokiService
    :Description: Loki Service (technical context)
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

lokiTenant
    :Description: Loki Tenant
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

lokiTenantHeader
    :Description: Loki Tenant Header name
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

lokiUrl
    :Description: Loki API
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

lokiUserService
    :Description: Loki (userLogger context)
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

lwpOpts
    :Location: General Parameters » Advanced parameters » Security » Options for server requests
    :Description: Options passed to LWP::UserAgent
    :Used by portal: yes

lwpSslOpts
    :Location: General Parameters » Advanced parameters » Security » TLS/SSL options for server requests
    :Description: TLS/SSL options passed to LWP::UserAgent
    :Used by portal: yes

macros
    :Location: Variables » Macros
    :Description: Macros
    :Used by portal: yes

mail2fActivation
    :Location: General Parameters » Second factors » Mail second factor » Activation
    :Description: Mail second factor activation
    :Used by portal: yes

mail2fAuthnLevel
    :Location: General Parameters » Second factors » Mail second factor » Authentication level
    :Description: Authentication level for users authenticated by Mail second factor
    :Used by portal: yes

mail2fBody
    :Location: General Parameters » Second factors » Mail second factor » Mail body
    :Description: Mail body for second factor authentication
    :Used by portal: yes

mail2fCodeRegex
    :Location: General Parameters » Second factors » Mail second factor » Code regex
    :Description: Regular expression to create a mail OTP code
    :Used by portal: yes

mail2fLabel
    :Location: General Parameters » Second factors » Mail second factor » Label
    :Description: Portal label for Mail second factor
    :Used by portal: yes

mail2fLogo
    :Location: General Parameters » Second factors » Mail second factor » Logo
    :Description: Custom logo for Mail 2F
    :Used by portal: yes

mail2fResendInterval
    :Location: General Parameters » Second factors » Mail second factor » Re-send interval
    :Description: Delay before user is allowed to resend code
    :Used by portal: yes

mail2fSessionKey
    :Location: General Parameters » Second factors » Mail second factor » Session key containing mail address
    :Description: Session parameter where mail is stored
    :Used by portal: yes

mail2fSubject
    :Location: General Parameters » Second factors » Mail second factor » Mail subject
    :Description: Mail subject for second factor authentication
    :Used by portal: yes

mail2fTimeout
    :Location: General Parameters » Second factors » Mail second factor » Code timeout
    :Description: Second factor code timeout
    :Used by portal: yes

mailBody
    :Location: General Parameters » Plugins » Reset password by mail » Mail content » Success mail content
    :Description: Custom password reset mail body
    :Used by portal: yes

mailCharset
    :Location: General Parameters » Advanced parameters » SMTP » Mail headers » Charset
    :Description: Mail charset
    :Used by portal: yes

mailConfirmBody
    :Location: General Parameters » Plugins » Reset password by mail » Mail content » Confirmation mail content
    :Description: Custom confirm password reset mail body
    :Used by portal: yes

mailConfirmSubject
    :Location: General Parameters » Plugins » Reset password by mail » Mail content » Confirmation mail subject
    :Description: Mail subject for reset confirmation
    :Used by portal: yes

mailFrom
    :Location: General Parameters » Advanced parameters » SMTP » Mail headers » Mail sender
    :Description: Sender email
    :Used by portal: yes

mailLDAPFilter
    :Location: General Parameters » Authentication parameters » LDAP parameters » Filters » Mail filter
    :Description: LDAP filter for mail search
    :Used by portal: yes

mailOnPasswordChange
    :Location: General Parameters » Portal » Customization » Password management » Send a mail when password is changed
    :Description: Send a mail when password is changed
    :Used by portal: yes

mailReplyTo
    :Location: General Parameters » Advanced parameters » SMTP » Mail headers » Reply address
    :Description: Reply-To address
    :Used by portal: yes

mailSessionKey
    :Location: General Parameters » Advanced parameters » SMTP » Session key containing mail address
    :Description: Session parameter where mail is stored
    :Used by portal: yes

mailSubject
    :Location: General Parameters » Plugins » Reset password by mail » Mail content » Success mail subject
    :Description: Mail subject for new password email
    :Used by portal: yes

mailTimeout
    :Location: General Parameters » Plugins » Reset password by mail » Other » Validity time of a password reset request
    :Description: Mail password reset session timeout
    :Used by portal: yes

mailUrl
    :Location: General Parameters » Plugins » Reset password by mail » Other » Reset page URL
    :Description: URL of password reset page
    :Used by portal: yes

maintenance
    :Location: General Parameters » Advanced parameters » Handler redirections » Maintenance mode
    :Description: Maintenance mode for all virtual hosts
    :Used by handler: yes

managerDn
    :Location: General Parameters » Authentication parameters » LDAP parameters » Connection » Account
    :Description: LDAP manager DN
    :Used by portal: yes

managerPassword
    :Location: General Parameters » Authentication parameters » LDAP parameters » Connection » Password
    :Description: LDAP manager Password
    :Used by portal: yes

max2FDevices
    :Description: Maximum registered 2F devices
    :Used by portal: yes
    :Ini only: yes

max2FDevicesNameLength
    :Description: Maximum 2F devices name length
    :Used by portal: yes
    :Ini only: yes

messageBroker
    :Location: General Parameters » Advanced parameters » Events management » Pub/Sub system
    :Description: Messages broker module
    :Used by portal: yes
    :Used by handler: yes

messageBrokerOptions
    :Location: General Parameters » Advanced parameters » Events management » Pub/Sub system options
    :Description: Options of messages broker module
    :Used by portal: yes
    :Used by handler: yes

multiValuesSeparator
    :Location: General Parameters » Advanced parameters » Separator
    :Description: Separator for multiple values
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes

mySessionAuthorizedRWKeys
    :Description: Alterable session keys by user itself
    :Used by portal: yes
    :Ini only: yes

newLocationWarning
    :Location: General Parameters » Advanced parameters » Security » New location warning » Activation
    :Description: Enable New Location Warning
    :Used by portal: yes

newLocationWarningLocationAttribute
    :Location: General Parameters » Advanced parameters » Security » New location warning » Session attribute containing location
    :Description: New location session attribute
    :Used by portal: yes

newLocationWarningLocationDisplayAttribute
    :Location: General Parameters » Advanced parameters » Security » New location warning » Session attribute to display
    :Description: New location session attribute for user display
    :Used by portal: yes

newLocationWarningMailAttribute
    :Location: General Parameters » Advanced parameters » Security » New location warning » Session mail attribute
    :Description: New location warning mail session attribute
    :Used by portal: yes

newLocationWarningMailBody
    :Location: General Parameters » Advanced parameters » Security » New location warning » Warning mail content
    :Description: Mail body for new location warning
    :Used by portal: yes

newLocationWarningMailSubject
    :Location: General Parameters » Advanced parameters » Security » New location warning » Warning mail subject
    :Description: Mail subject for new location warning
    :Used by portal: yes

newLocationWarningMaxValues
    :Location: General Parameters » Advanced parameters » Security » New location warning » Maximum number of locations to consider
    :Description: How many previous locations should be compared
    :Used by portal: yes

nginxCustomHandlers
    :Location: General Parameters » Advanced parameters » Custom Nginx handlers
    :Description: Custom Nginx handler (deprecated)
    :Used by portal: yes

noAjaxHook
    :Location: General Parameters » Advanced parameters » Portal redirections » Keep redirections for Ajax
    :Description: Avoid replacing 302 by 401 for Ajax responses
    :Used by portal: yes

notification
    :Location: General Parameters » Plugins » Notifications » Activation
    :Description: Notification activation
    :Used by portal: yes

notificationDefaultCond
    :Location: General Parameters » Plugins » Notifications » Server » Default condition
    :Description: Notification default condition
    :Used by portal: yes

notificationServer
    :Location: General Parameters » Plugins » Notifications » Server » Notification server
    :Description: Notification server activation
    :Used by portal: yes

notificationServerDELETE
    :Location: General Parameters » Plugins » Notifications » Server » HTTP methods » DELETE method
    :Description: Notification server activation
    :Used by portal: yes

notificationServerGET
    :Location: General Parameters » Plugins » Notifications » Server » HTTP methods » GET method
    :Description: Notification server activation
    :Used by portal: yes

notificationServerPOST
    :Location: General Parameters » Plugins » Notifications » Server » HTTP methods » POST method
    :Description: Notification server activation
    :Used by portal: yes

notificationServerSentAttributes
    :Location: General Parameters » Plugins » Notifications » Server » Notification parameters to send
    :Description: Prameters to send with notification server GET method
    :Used by portal: yes

notificationStorage
    :Location: General Parameters » Plugins » Notifications » Storage module
    :Description: Notification backend
    :Used by portal: yes

notificationStorageOptions
    :Location: General Parameters » Plugins » Notifications » Storage module parameters
    :Description: Notification backend options
    :Used by portal: yes

notificationWildcard
    :Location: General Parameters » Plugins » Notifications » Wildcard for all users
    :Description: Notification string to match all users
    :Used by portal: yes

notificationXSLTfile
    :Location: General Parameters » Plugins » Notifications » Custom XSLT file
    :Description: Custom XSLT document for notifications
    :Used by portal: yes

notificationsExplorer
    :Location: General Parameters » Plugins » Notifications » Explorer
    :Description: Notifications explorer activation
    :Used by portal: yes

notificationsMaxRetrieve
    :Description: Max number of displayed notifications
    :Used by portal: yes
    :Ini only: yes

notifyDeleted
    :Location: General Parameters » Sessions » Multiple sessions » Display deleted sessions
    :Description: Show deleted sessions in portal
    :Used by portal: yes

notifyOther
    :Location: General Parameters » Sessions » Multiple sessions » Display other sessions
    :Description: Show other sessions in portal
    :Used by portal: yes

nullAuthnLevel
    :Location: General Parameters » Authentication parameters » Null parameters » Authentication level
    :Description: Null authentication level
    :Used by portal: yes

oidcAuthnLevel
    :Location: General Parameters » Authentication parameters » OpenID Connect parameters » Authentication level
    :Description: OpenID Connect authentication level
    :Used by portal: yes

oidcDropCspHeaders
    :Location: OpenID Connect Service » Security » Drop CSP headers from OIDC responses
    :Description: Drop CORS headers from OIDC issuer responses
    :Used by portal: yes

oidcOPMetaDataExportedVars
    :Location: OpenID Connect Providers » *configuration key* » Exported attributes
    :Used by portal: yes

oidcOPMetaDataJSON
    :Location: OpenID Connect Providers » *configuration key* » Metadata
    :Used by portal: yes

oidcOPMetaDataJWKS
    :Location: OpenID Connect Providers » *configuration key* » JWKS data
    :Used by portal: yes

oidcOPMetaDataNodes
    :Used by portal: yes
    :Ini only: yes

oidcOPMetaDataOptions
    :Location: Options
    :Used by portal: yes

oidcOPMetaDataOptionsAcrValues
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » ACR values
    :Used by portal: yes

oidcOPMetaDataOptionsAuthnEndpointAuthMethod
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Authentication method for authorization code request
    :Used by portal: yes

oidcOPMetaDataOptionsAuthnEndpointAuthSigAlg
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Signature algorithm for authorization code authentication
    :Used by portal: yes

oidcOPMetaDataOptionsCheckJWTSignature
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Check JWT signature
    :Used by portal: yes

oidcOPMetaDataOptionsClientID
    :Location: OpenID Connect Providers » *configuration key* » Options » Configuration » Client ID
    :Used by portal: yes

oidcOPMetaDataOptionsClientSecret
    :Location: OpenID Connect Providers » *configuration key* » Options » Configuration » Client secret
    :Used by portal: yes

oidcOPMetaDataOptionsComment
    :Location: OpenID Connect Providers » *configuration key* » Options » Comment
    :Used by portal: yes

oidcOPMetaDataOptionsConfigurationURI
    :Location: OpenID Connect Providers » *configuration key* » Options » Configuration » Configuration endpoint
    :Used by portal: yes

oidcOPMetaDataOptionsDisplay
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Display
    :Used by portal: yes

oidcOPMetaDataOptionsDisplayName
    :Location: OpenID Connect Providers » *configuration key* » Display » Name
    :Used by portal: yes

oidcOPMetaDataOptionsIDTokenMaxAge
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » ID Token max age
    :Used by portal: yes

oidcOPMetaDataOptionsIcon
    :Location: OpenID Connect Providers » *configuration key* » Display » Logo
    :Used by portal: yes

oidcOPMetaDataOptionsJWKSTimeout
    :Location: OpenID Connect Providers » *configuration key* » Options » Configuration » JWKS data timeout
    :Used by portal: yes

oidcOPMetaDataOptionsMaxAge
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Max age
    :Used by portal: yes

oidcOPMetaDataOptionsNoJwtHeader
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Do not add JWT typ header
    :Description: Don't insert typ header
    :Used by portal: yes

oidcOPMetaDataOptionsPrompt
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Prompt
    :Used by portal: yes

oidcOPMetaDataOptionsRequirePkce
    :Location: OpenID Connect Providers » *configuration key* » Options » Configuration » PKCE required
    :Description: Use PKCE with this OP
    :Used by portal: yes

oidcOPMetaDataOptionsResolutionRule
    :Location: OpenID Connect Providers » *configuration key* » Display » Resolution rule
    :Used by portal: yes

oidcOPMetaDataOptionsScope
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Scope
    :Used by portal: yes

oidcOPMetaDataOptionsSigningKey
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Signing key name
    :Used by portal: yes

oidcOPMetaDataOptionsSortNumber
    :Location: OpenID Connect Providers » *configuration key* » Display » Order
    :Used by portal: yes

oidcOPMetaDataOptionsStoreIDToken
    :Location: OpenID Connect Providers » *configuration key* » Options » Configuration » Store ID Token
    :Used by portal: yes

oidcOPMetaDataOptionsTokenEndpointAuthMethod
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Token endpoint authentication method
    :Used by portal: yes

oidcOPMetaDataOptionsTokenEndpointAuthSigAlg
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Signature algorithm for token endpoint authentication
    :Used by portal: yes

oidcOPMetaDataOptionsTooltip
    :Location: OpenID Connect Providers » *configuration key* » Display » Tooltip
    :Used by portal: yes

oidcOPMetaDataOptionsUiLocales
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Locales UI
    :Used by portal: yes

oidcOPMetaDataOptionsUseNonce
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » Use nonce
    :Used by portal: yes

oidcOPMetaDataOptionsUserAttribute
    :Location: OpenID Connect Providers » *configuration key* » Options » Configuration » Attribute containing user identifier
    :Used by portal: yes

oidcOPMetaDataOptionsUserinfoSource
    :Location: OpenID Connect Providers » *configuration key* » Options » Protocol » User Info source
    :Description: Source of userinfo
    :Used by portal: yes

oidcOfflineTokens
    :Location: General Parameters » Plugins » Offline session tab
    :Description: OIDC personnal offline token removal
    :Used by portal: yes

oidcRPCallbackGetParam
    :Location: General Parameters » Authentication parameters » OpenID Connect parameters » Callback GET parameter
    :Description: OpenID Connect Callback GET URLparameter
    :Used by portal: yes

oidcRPMetaDataExportedVars
    :Location: OpenID Connect Relying Parties » *configuration key* » Exported attributes (claims)
    :Used by portal: yes

oidcRPMetaDataMacros
    :Location: OpenID Connect Relying Parties » *configuration key* » Macros
    :Description: Macros
    :Used by portal: yes

oidcRPMetaDataNodes
    :Used by portal: yes
    :Ini only: yes

oidcRPMetaDataOptions
    :Location: Options
    :Used by portal: yes

oidcRPMetaDataOptionsAccessTokenClaims
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Advanced » Release claims in Access Token
    :Used by portal: yes

oidcRPMetaDataOptionsAccessTokenEncContentEncAlg
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Algorithms » Access Token Encryption content encryption algorithm
    :Description: "enc" algorithm for access_token encryption
    :Used by portal: yes

oidcRPMetaDataOptionsAccessTokenEncKeyMgtAlg
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Algorithms » Access Token Encryption key management alg
    :Description: "alg" algorithm for access_token encryption
    :Used by portal: yes

oidcRPMetaDataOptionsAccessTokenExpiration
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Timeouts » Access Tokens
    :Used by portal: yes

oidcRPMetaDataOptionsAccessTokenJWT
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Advanced » Use JWT format for Access Token
    :Used by portal: yes

oidcRPMetaDataOptionsAccessTokenSignAlg
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Algorithms » Access Token signature algorithm
    :Used by portal: yes

oidcRPMetaDataOptionsAdditionalAudiences
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Advanced » Additional audiences
    :Used by portal: yes

oidcRPMetaDataOptionsAllowClientCredentialsGrant
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Allow OAuth2.0 Client Credentials Grant
    :Description: Allow OAuth2 Client Credentials Grant
    :Used by portal: yes

oidcRPMetaDataOptionsAllowNativeSso
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Allow Native SSO for Mobile App
    :Description: Allow Native SSO for Mobile Apps
    :Used by portal: yes

oidcRPMetaDataOptionsAllowOffline
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Allow offline access
    :Description: Allow offline access
    :Used by portal: yes

oidcRPMetaDataOptionsAllowPasswordGrant
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Allow OAuth2.0 Password Grant
    :Description: Allow OAuth2 Resource Owner Password Credentials Grant
    :Used by portal: yes

oidcRPMetaDataOptionsAuthMethod
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Token endpoint authentication method
    :Used by portal: yes

oidcRPMetaDataOptionsAuthRequiredForAuthorize
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Require JWS for authorization requests
    :Used by portal: yes

oidcRPMetaDataOptionsAuthnLevel
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Required authentication level
    :Description: Authentication level requires to access to this RP
    :Used by portal: yes

oidcRPMetaDataOptionsAuthnRequireNonce
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Require "nonce" in authorization request
    :Used by portal: yes

oidcRPMetaDataOptionsAuthnRequireState
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Require "state" in authorization request
    :Used by portal: yes

oidcRPMetaDataOptionsAuthorizationCodeExpiration
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Timeouts » Authorization Codes
    :Used by portal: yes

oidcRPMetaDataOptionsBypassConsent
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Advanced » Bypass consent
    :Used by portal: yes

oidcRPMetaDataOptionsClientID
    :Location: OpenID Connect Relying Parties » *configuration key* » Basic » Client ID
    :Used by portal: yes

oidcRPMetaDataOptionsClientSecret
    :Location: OpenID Connect Relying Parties » *configuration key* » Basic » Client secret
    :Used by portal: yes

oidcRPMetaDataOptionsComment
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Comment
    :Used by portal: yes

oidcRPMetaDataOptionsDisplayName
    :Location: OpenID Connect Relying Parties » *configuration key* » Display » Name
    :Used by portal: yes

oidcRPMetaDataOptionsExtraClaims
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Scope » Scope values content
    :Used by portal: yes

oidcRPMetaDataOptionsIDTokenExpiration
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Timeouts » ID Tokens
    :Used by portal: yes

oidcRPMetaDataOptionsIDTokenForceClaims
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Advanced » Force claims to be returned in ID Token
    :Used by portal: yes

oidcRPMetaDataOptionsIDTokenSignAlg
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Algorithms » ID Token signature algorithm
    :Used by portal: yes

oidcRPMetaDataOptionsIcon
    :Location: OpenID Connect Relying Parties » *configuration key* » Display » Logo
    :Used by portal: yes

oidcRPMetaDataOptionsIdTokenEncContentEncAlg
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Algorithms » ID Token Encryption content encryption algorithm
    :Description: "enc" algorithm for id_token encryption
    :Used by portal: yes

oidcRPMetaDataOptionsIdTokenEncKeyMgtAlg
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Algorithms » ID Token Encryption key management alg
    :Description: "alg" algorithm for id_token encryption
    :Used by portal: yes

oidcRPMetaDataOptionsJwks
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Keys » JWKS data
    :Description: Relying party JWKS document
    :Used by portal: yes

oidcRPMetaDataOptionsJwksUri
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Keys » JWKS URL
    :Description: Relying party JWKS endpoint (to get encryption keys)
    :Used by portal: yes

oidcRPMetaDataOptionsLogoutBypassConfirm
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Logout » Bypass confirm
    :Description: Bypass logout confirmation
    :Used by portal: yes

oidcRPMetaDataOptionsLogoutEncContentEncAlg
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Algorithms » Logout Encryption content encryption algorithm
    :Description: "enc" algorithm for logout encryption
    :Used by portal: yes

oidcRPMetaDataOptionsLogoutEncKeyMgtAlg
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Algorithms » Logout Encryption key management alg
    :Description: "alg" algorithm for logout token encryption
    :Used by portal: yes

oidcRPMetaDataOptionsLogoutSessionRequired
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Logout » Session required
    :Description: Session required for back/front channel logout
    :Used by portal: yes

oidcRPMetaDataOptionsLogoutType
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Logout » Type
    :Description: Logout type
    :Used by portal: yes

oidcRPMetaDataOptionsLogoutUrl
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Logout » URL
    :Description: Logout URL
    :Used by portal: yes

oidcRPMetaDataOptionsNoJwtHeader
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Advanced » Do not add JWT typ header
    :Description: Don't insert typ header
    :Used by portal: yes

oidcRPMetaDataOptionsOfflineSessionExpiration
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Timeouts » Offline sessions
    :Used by portal: yes

oidcRPMetaDataOptionsPostLogoutRedirectUris
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Logout » Allowed redirection addresses for logout
    :Used by portal: yes

oidcRPMetaDataOptionsPublic
    :Location: OpenID Connect Relying Parties » *configuration key* » Basic » Public client
    :Description: Declare this RP as public client
    :Used by portal: yes

oidcRPMetaDataOptionsRedirectUris
    :Location: OpenID Connect Relying Parties » *configuration key* » Basic » Allowed redirection addresses for login
    :Used by portal: yes

oidcRPMetaDataOptionsRefreshToken
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Advanced » Use refresh tokens
    :Description: Issue refresh tokens
    :Used by portal: yes

oidcRPMetaDataOptionsRefreshTokenRotation
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Invalidate refresh tokens after use
    :Description: Invalidate refresh token after use
    :Used by portal: yes

oidcRPMetaDataOptionsRequestUris
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Allowed URLs for fetching Request Object
    :Used by portal: yes

oidcRPMetaDataOptionsRequirePKCE
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Require PKCE
    :Description: Require PKCE
    :Used by portal: yes

oidcRPMetaDataOptionsRtActivity
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Timeouts » refresh_token activity timeout
    :Description: refresh_token activity timeout
    :Used by portal: yes

oidcRPMetaDataOptionsRule
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Access rule
    :Description: Rule to grant access to this RP
    :Used by portal: yes

oidcRPMetaDataOptionsSigningKey
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Keys » Signing key name
    :Used by portal: yes

oidcRPMetaDataOptionsTokenXAuthorizedRP
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Advanced » Other RP allowed to exchange Access Token
    :Description: List of RP authorized to query for an access_token of this RP
    :Used by portal: yes

oidcRPMetaDataOptionsUserIDAttr
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Advanced » User attribute
    :Used by portal: yes

oidcRPMetaDataOptionsUserInfoEncContentEncAlg
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Algorithms » Userinfo encryption content encryption algorithm
    :Description: "enc" algorithm for user_info encryption
    :Used by portal: yes

oidcRPMetaDataOptionsUserInfoEncKeyMgtAlg
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Algorithms » Userinfo encryption key management algorithm
    :Description: "alg" algorithm for user_info encryption
    :Used by portal: yes

oidcRPMetaDataOptionsUserInfoSignAlg
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Algorithms » Userinfo response format
    :Used by portal: yes

oidcRPMetaDataOptionsUserinfoRequireHeaderToken
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Security » Userinfo endpoint authentication using header only
    :Description: /userinfo endpoint requires authn using Bearer token
    :Used by portal: yes

oidcRPMetaDataScopeRules
    :Location: OpenID Connect Relying Parties » *configuration key* » Options » Scope » Scope rules
    :Description: Scope rules
    :Used by portal: yes

oidcRPStateTimeout
    :Location: General Parameters » Authentication parameters » OpenID Connect parameters » State session timeout
    :Description: OpenID Connect Timeout of state sessions
    :Used by portal: yes

oidcServiceAccessTokenExpiration
    :Location: OpenID Connect Service » Timeouts » Access Tokens
    :Description: OpenID Connect global access token TTL
    :Used by portal: yes

oidcServiceAllowAuthorizationCodeFlow
    :Location: OpenID Connect Service » Security » Authorization Code Flow
    :Description: OpenID Connect allow authorization code flow
    :Used by portal: yes

oidcServiceAllowDynamicRegistration
    :Location: OpenID Connect Service » Dynamic registration » Activation
    :Description: OpenID Connect allow dynamic client registration
    :Used by portal: yes

oidcServiceAllowHybridFlow
    :Location: OpenID Connect Service » Security » Hybrid Flow
    :Description: OpenID Connect allow hybrid flow
    :Used by portal: yes

oidcServiceAllowImplicitFlow
    :Location: OpenID Connect Service » Security » Implicit Flow
    :Description: OpenID Connect allow implicit flow
    :Used by portal: yes

oidcServiceAllowOnlyDeclaredScopes
    :Location: OpenID Connect Service » Security » Only allow declared scopes
    :Description: OpenID Connect allow only declared scopes
    :Used by portal: yes

oidcServiceAuthorizationCodeExpiration
    :Location: OpenID Connect Service » Timeouts » Authorization Codes
    :Description: OpenID Connect global code TTL
    :Used by portal: yes

oidcServiceDynamicRegistrationExportedVars
    :Location: OpenID Connect Service » Dynamic registration » Exported vars
    :Description: OpenID Connect exported variables for dynamic registration
    :Used by portal: yes

oidcServiceDynamicRegistrationExtraClaims
    :Location: OpenID Connect Service » Dynamic registration » Extra claims
    :Description: OpenID Connect extra claims for dynamic registration
    :Used by portal: yes

oidcServiceEncAlgorithmAlg
    :Location: OpenID Connect Service » Security » Default "alg" algorithm for JWE encryption
    :Description: JWT encryption algorithme
    :Used by portal: yes

oidcServiceEncAlgorithmEnc
    :Location: OpenID Connect Service » Security » Default "enc" algorithm for JWE encryption
    :Description: JWT encryption algorithme
    :Used by portal: yes

oidcServiceEncryptionKey
    :Location: OpenID Connect Service » Security » Advanced key configuration » Encryption key name
    :Description: Key to use for OIDC encryption
    :Used by portal: yes

oidcServiceHideMetadata
    :Location: OpenID Connect Service » Security » Do not display metadata
    :Used by portal: yes

oidcServiceIDTokenExpiration
    :Location: OpenID Connect Service » Timeouts » ID Tokens
    :Description: OpenID Connect global ID token TTL
    :Used by portal: yes

oidcServiceIgnoreScopeForClaims
    :Location: OpenID Connect Service » Security » Always send exported attributes
    :Description: OpenID Connect release all attributes even when not allowed by scope
    :Used by portal: yes

oidcServiceKeyIdEnc
    :Location: OpenID Connect Service » Security » Keys » Encryption keys » Encryption key ID
    :Description: OpenID Connect Encryption Key ID
    :Used by portal: yes

oidcServiceKeyIdSig
    :Location: OpenID Connect Service » Security » Keys » Signature keys » Signing key ID
    :Description: OpenID Connect Signature Key ID
    :Used by portal: yes

oidcServiceKeyTypeEnc
    :Location: OpenID Connect Service » Security » Keys » Encryption keys » Key type
    :Used by portal: yes

oidcServiceKeyTypeSig
    :Location: OpenID Connect Service » Security » Keys » Signature keys » Key type
    :Used by portal: yes

oidcServiceMetaDataAmrRules
    :Location: OpenID Connect Service » Authentication Method Reference rules
    :Description: OpenID Connect AMR rules
    :Used by portal: yes

oidcServiceMetaDataAuthnContext
    :Location: OpenID Connect Service » Authentication context
    :Description: OpenID Connect Authentication Context Class Ref
    :Used by portal: yes

oidcServiceMetaDataAuthorizeURI
    :Location: OpenID Connect Service » Endpoints » Authorization
    :Description: OpenID Connect authorizaton endpoint
    :Used by portal: yes

oidcServiceMetaDataBackChannelURI
    :Location: OpenID Connect Service » Endpoints » Back-Channel URI
    :Description: OpenID Connect Back-Channel logout endpoint
    :Used by portal: yes

oidcServiceMetaDataCheckSessionURI
    :Location: OpenID Connect Service » Endpoints » Check Session
    :Description: OpenID Connect check session iframe
    :Used by portal: yes

oidcServiceMetaDataDisallowNoneAlg
    :Location: OpenID Connect Service » Security » Disallow "none" algorithm for signature
    :Used by portal: yes

oidcServiceMetaDataEndSessionURI
    :Location: OpenID Connect Service » Endpoints » End of session
    :Description: OpenID Connect end session endpoint
    :Used by portal: yes

oidcServiceMetaDataFrontChannelURI
    :Location: OpenID Connect Service » Endpoints » Front-Channel URI
    :Description: OpenID Connect Front-Channel logout endpoint
    :Used by portal: yes

oidcServiceMetaDataIntrospectionURI
    :Location: OpenID Connect Service » Endpoints » Introspection
    :Description: OpenID Connect introspection endpoint
    :Used by portal: yes

oidcServiceMetaDataIssuer
    :Location: OpenID Connect Service » Issuer identifier
    :Description: OpenID Connect issuer
    :Used by portal: yes

oidcServiceMetaDataJWKSURI
    :Location: OpenID Connect Service » Endpoints » JWKS
    :Description: OpenID Connect JWKS endpoint
    :Used by portal: yes

oidcServiceMetaDataRegistrationURI
    :Location: OpenID Connect Service » Endpoints » Registration
    :Description: OpenID Connect registration endpoint
    :Used by portal: yes

oidcServiceMetaDataRevokeURI
    :Location: OpenID Connect Service » Endpoints » Token revocation
    :Description: OpenID Connect token revocation endpoint
    :Used by portal: yes

oidcServiceMetaDataRpLogoutReturnURI
    :Location: OpenID Connect Service » Endpoints » Logout return endpoint
    :Description: OpenID Connect RP-Initiated logout return endpoint
    :Used by portal: yes

oidcServiceMetaDataTokenURI
    :Location: OpenID Connect Service » Endpoints » Tokens
    :Description: OpenID Connect token endpoint
    :Used by portal: yes

oidcServiceMetaDataUserInfoURI
    :Location: OpenID Connect Service » Endpoints » User Info
    :Description: OpenID Connect user info endpoint
    :Used by portal: yes

oidcServiceMetadataTtl
    :Location: OpenID Connect Service » Timeouts » OIDC Metadata TTL
    :Description: OIDC Metadata TTL
    :Used by portal: yes

oidcServiceNewKeyIdSig
    :Location: OpenID Connect Service » Security » Keys » Signature keys » Next signing key ID
    :Description: Future OpenID Connect Signature Key ID
    :Used by portal: yes

oidcServiceNewKeyTypeSig
    :Location: OpenID Connect Service » Security » Keys » Signature keys » Key type
    :Used by portal: yes

oidcServiceNewPrivateKeySig
    :Location: OpenID Connect Service » Security » Keys » Signature keys » Next signing private key
    :Used by portal: yes

oidcServiceNewPublicKeySig
    :Location: OpenID Connect Service » Security » Keys » Signature keys » Next signing public key
    :Used by portal: yes

oidcServiceOfflineSessionExpiration
    :Location: OpenID Connect Service » Timeouts » Offline sessions
    :Description: OpenID Connect global offline session TTL
    :Used by portal: yes

oidcServiceOldKeyIdEnc
    :Location: OpenID Connect Service » Security » Keys » Encryption keys » Previous encryption key ID
    :Description: Previous OpenID Connect Encryption Key ID
    :Used by portal: yes

oidcServiceOldKeyIdSig
    :Location: OpenID Connect Service » Security » Keys » Signature keys » Previous signing key ID
    :Description: Previous OpenID Connect Signature Key ID
    :Used by portal: yes

oidcServiceOldKeyTypeEnc
    :Location: OpenID Connect Service » Security » Keys » Encryption keys » Key type
    :Used by portal: yes

oidcServiceOldKeyTypeSig
    :Location: OpenID Connect Service » Security » Keys » Signature keys » Key type
    :Used by portal: yes

oidcServiceOldPrivateKeyEnc
    :Location: OpenID Connect Service » Security » Keys » Encryption keys » Previous encryption private key
    :Used by portal: yes

oidcServiceOldPrivateKeySig
    :Location: OpenID Connect Service » Security » Keys » Signature keys » Previous signing private key
    :Used by portal: yes

oidcServiceOldPublicKeyEnc
    :Location: OpenID Connect Service » Security » Keys » Encryption keys » Previous encryption public key
    :Used by portal: yes

oidcServiceOldPublicKeySig
    :Location: OpenID Connect Service » Security » Keys » Signature keys » Previous signing public key
    :Used by portal: yes

oidcServicePrivateKeyEnc
    :Location: OpenID Connect Service » Security » Keys » Encryption keys » Encryption private key
    :Used by portal: yes

oidcServicePrivateKeySig
    :Location: OpenID Connect Service » Security » Keys » Signature keys » Signing private key
    :Used by portal: yes

oidcServicePublicKeyEnc
    :Location: OpenID Connect Service » Security » Keys » Encryption keys » Encryption public key
    :Used by portal: yes

oidcServicePublicKeySig
    :Location: OpenID Connect Service » Security » Keys » Signature keys » Signing public key
    :Used by portal: yes

oidcServiceSignatureKey
    :Location: OpenID Connect Service » Security » Advanced key configuration » Signing key name
    :Description: Key to use for OIDC signature
    :Used by portal: yes

oidcStorage
    :Location: OpenID Connect Service » Sessions » OIDC sessions module name
    :Description: Apache::Session module to store OIDC user data
    :Used by portal: yes

oidcStorageOptions
    :Location: OpenID Connect Service » Sessions » OIDC sessions module options
    :Description: Apache::Session module parameters
    :Used by portal: yes

okta2fActivation
    :Location: General Parameters » Second factors » Okta » Activation
    :Description: Okta2F activation
    :Used by portal: yes

okta2fAdminURL
    :Location: General Parameters » Second factors » Okta » Administration URL
    :Description: Okta Administration URL
    :Used by portal: yes

okta2fApiKey
    :Location: General Parameters » Second factors » Okta » API key
    :Description: Okta API key
    :Used by portal: yes

okta2fAuthnLevel
    :Location: General Parameters » Second factors » Okta » Authentication level
    :Description: Authentication level for users authentified by Okta2F
    :Used by portal: yes

okta2fLabel
    :Location: General Parameters » Second factors » Okta » Label
    :Description: Portal label for Okta2F
    :Used by portal: yes

okta2fLoginAttribute
    :Location: General Parameters » Second factors » Okta » Attribute containing the login
    :Description: Session key containing Okta login
    :Used by portal: yes

okta2fLogo
    :Location: General Parameters » Second factors » Okta » Logo
    :Description: Custom logo for Okta 2F
    :Used by portal: yes

oldNotifFormat
    :Location: General Parameters » Plugins » Notifications » Use old XML format
    :Description: Use old XML format for notifications
    :Used by portal: yes

openIdAttr
    :Location: General Parameters » Issuer modules » OpenID » Options » OpenID login
    :Used by portal: yes

openIdAuthnLevel
    :Location: General Parameters » Authentication parameters » OpenID parameters » Authentication level
    :Description: OpenID authentication level
    :Used by portal: yes

openIdExportedVars
    :Location: General Parameters » Authentication parameters » OpenID parameters » Exported variables
    :Description: OpenID exported variables
    :Used by portal: yes

openIdIDPList
    :Location: General Parameters » Authentication parameters » OpenID parameters » Authorized domains
    :Used by portal: yes

openIdIssuerSecret
    :Location: General Parameters » Issuer modules » OpenID » Options » Secret token
    :Used by portal: yes

openIdSPList
    :Location: General Parameters » Issuer modules » OpenID » Options » Authorized domains
    :Used by portal: yes

openIdSecret
    :Location: General Parameters » Authentication parameters » OpenID parameters » Secret token
    :Used by portal: yes

openIdSreg_country
    :Location: General Parameters » Issuer modules » OpenID » Options » SREG mapping » Country
    :Used by portal: yes

openIdSreg_dob
    :Location: General Parameters » Issuer modules » OpenID » Options » SREG mapping » Date of birth
    :Used by portal: yes

openIdSreg_email
    :Location: General Parameters » Issuer modules » OpenID » Options » SREG mapping » Email
    :Description: OpenID SREG email session parameter
    :Used by portal: yes

openIdSreg_fullname
    :Location: General Parameters » Issuer modules » OpenID » Options » SREG mapping » Full name
    :Description: OpenID SREG fullname session parameter
    :Used by portal: yes

openIdSreg_gender
    :Location: General Parameters » Issuer modules » OpenID » Options » SREG mapping » Gender
    :Used by portal: yes

openIdSreg_language
    :Location: General Parameters » Issuer modules » OpenID » Options » SREG mapping » Language
    :Used by portal: yes

openIdSreg_nickname
    :Location: General Parameters » Issuer modules » OpenID » Options » SREG mapping » Nick name
    :Description: OpenID SREG nickname session parameter
    :Used by portal: yes

openIdSreg_postcode
    :Location: General Parameters » Issuer modules » OpenID » Options » SREG mapping » Postal code
    :Used by portal: yes

openIdSreg_timezone
    :Location: General Parameters » Issuer modules » OpenID » Options » SREG mapping » Timezone
    :Description: OpenID SREG timezone session parameter
    :Used by portal: yes

pamAuthnLevel
    :Location: General Parameters » Authentication parameters » PAM parameters » Authentication level
    :Description: PAM authentication level
    :Used by portal: yes

pamService
    :Location: General Parameters » Authentication parameters » PAM parameters » PAM service
    :Description: PAM service
    :Used by portal: yes

password2fActivation
    :Location: General Parameters » Second factors » Password » Activation
    :Description: Password2F activation
    :Used by portal: yes

password2fAuthnLevel
    :Location: General Parameters » Second factors » Password » Authentication level
    :Description: Authentication level for users authentified by Password2F
    :Used by portal: yes

password2fLabel
    :Location: General Parameters » Second factors » Password » Label
    :Description: Portal label for Password2F
    :Used by portal: yes

password2fLogo
    :Location: General Parameters » Second factors » Password » Logo
    :Description: Custom logo for Password 2F
    :Used by portal: yes

password2fSelfRegistration
    :Location: General Parameters » Second factors » Password » Self registration
    :Description: Password2F self registration activation
    :Used by portal: yes

password2fTTL
    :Location: General Parameters » Second factors » Password » Lifetime
    :Description: Password2F device time to live
    :Used by portal: yes

password2fUserCanRemoveKey
    :Location: General Parameters » Second factors » Password » Allow user to remove password
    :Description: Authorize users to remove existing Password2F secret
    :Used by portal: yes

passwordDB
    :Location: General Parameters » Authentication parameters » Password module
    :Description: Password module
    :Used by portal: yes

passwordPolicyActivation
    :Location: General Parameters » Portal » Customization » Password policy » Activation
    :Description: Enable password policy
    :Used by portal: yes

passwordPolicyMaxSize
    :Location: General Parameters » Portal » Customization » Password policy » Maximal size
    :Description: Password policy: maximal size
    :Used by portal: yes

passwordPolicyMinDigit
    :Location: General Parameters » Portal » Customization » Password policy » Minimal digit characters
    :Description: Password policy: minimal digit characters
    :Used by portal: yes

passwordPolicyMinLower
    :Location: General Parameters » Portal » Customization » Password policy » Minimal lower characters
    :Description: Password policy: minimal lower characters
    :Used by portal: yes

passwordPolicyMinSize
    :Location: General Parameters » Portal » Customization » Password policy » Minimal size
    :Description: Password policy: minimal size
    :Used by portal: yes

passwordPolicyMinSpeChar
    :Location: General Parameters » Portal » Customization » Password policy » Minimal special characters
    :Description: Password policy: minimal special characters
    :Used by portal: yes

passwordPolicyMinUpper
    :Location: General Parameters » Portal » Customization » Password policy » Minimal upper characters
    :Description: Password policy: minimal upper characters
    :Used by portal: yes

passwordPolicySpecialChar
    :Location: General Parameters » Portal » Customization » Password policy » Allowed special characters
    :Description: Password policy: allowed special characters
    :Used by portal: yes

passwordResetAllowedRetries
    :Location: General Parameters » Plugins » Reset password by mail » Other » Max reset password retries
    :Description: Maximum number of retries to reset password
    :Used by portal: yes

pdataDomain
    :Description: pdata cookie DNS domain
    :Used by portal: yes
    :Used by handler: yes
    :Ini only: yes

persistentSessionAttributes
    :Description: Persistent session attributes to hide
    :Used by portal: yes
    :Ini only: yes

persistentStorage
    :Location: General Parameters » Sessions » Persistent sessions » Apache::Session module
    :Description: Storage module for persistent sessions
    :Used by portal: yes

persistentStorageOptions
    :Location: General Parameters » Sessions » Persistent sessions » Apache::Session module parameters
    :Description: Options for persistent sessions storage module
    :Used by portal: yes

port
    :Location: General Parameters » Advanced parameters » Handler redirections » Port
    :Description: Force port in redirection
    :Used by handler: yes

portal
    :Location: General Parameters » Portal » URL
    :Description: Portal URL
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes

portalAntiFrame
    :Location: General Parameters » Portal » Customization » Other » Anti iFrame protection
    :Description: Avoid portal to be displayed inside frames
    :Used by portal: yes

portalCheckLogins
    :Location: General Parameters » Portal » Customization » Buttons on login page » Check last logins
    :Description: Display login history checkbox in portal
    :Used by portal: yes

portalCustomCss
    :Location: General Parameters » Portal » Customization » Custom CSS file
    :Description: Path to custom CSS file
    :Used by portal: yes

portalCustomJs
    :Location: General Parameters » Portal » Customization » Custom JS file
    :Description: Path to custom JS file
    :Used by portal: yes

portalCustomTplParams
    :Location: General Parameters » Portal » Customization » Custom template parameters
    :Description: Custom templates parameters
    :Used by portal: yes

portalDisplayAppslist
    :Location: General Parameters » Portal » Menu » Modules activation » Application list
    :Description: Display applications tab in portal
    :Used by portal: yes

portalDisplayCertificateResetByMail
    :Location: General Parameters » Portal » Customization » Buttons on login page » Reset certificate
    :Description: Display certificate reset by mail button in portal
    :Used by portal: yes

portalDisplayChangePassword
    :Location: General Parameters » Portal » Menu » Modules activation » Password change
    :Description: Display password tab in portal
    :Used by portal: yes

portalDisplayGeneratePassword
    :Location: General Parameters » Plugins » Reset password by mail » Other » Display generate password box
    :Description: Display password generate box in reset password form
    :Used by portal: yes

portalDisplayLoginHistory
    :Location: General Parameters » Portal » Menu » Modules activation » Login history
    :Description: Display login history tab in portal
    :Used by portal: yes

portalDisplayLogout
    :Location: General Parameters » Portal » Menu » Modules activation » Logout
    :Description: Display logout tab in portal
    :Used by portal: yes

portalDisplayOfflineTokens
    :Location: General Parameters » Portal » Menu » Modules activation » Display offline session tab
    :Used by portal: yes

portalDisplayOidcConsents
    :Location: General Parameters » Portal » Menu » Modules activation » OIDC consents
    :Description: Display OIDC consents tab in portal
    :Used by portal: yes

portalDisplayOrder
    :Location: General Parameters » Portal » Menu » Modules activation » Display order
    :Description: List for ordering tabs in portal
    :Used by portal: yes

portalDisplayPasswordPolicy
    :Location: General Parameters » Portal » Customization » Password policy » Display policy in password form
    :Description: Display policy in password form
    :Used by portal: yes

portalDisplayRefreshMyRights
    :Location: General Parameters » Portal » Customization » Other » Display rights refresh link
    :Description: Display link to refresh the user session
    :Used by portal: yes

portalDisplayRegister
    :Location: General Parameters » Portal » Customization » Buttons on login page » Register new account
    :Description: Display register button in portal
    :Used by portal: yes

portalDisplayResetPassword
    :Location: General Parameters » Portal » Customization » Buttons on login page » Reset password
    :Description: Display reset password button in portal
    :Used by portal: yes

portalEnablePasswordDisplay
    :Location: General Parameters » Portal » Customization » Password management » Allow to display password
    :Description: Allow to display password in login form
    :Used by portal: yes

portalErrorOnExpiredSession
    :Location: General Parameters » Portal » Customization » Other » Show error on expired session
    :Description: Show error if session is expired
    :Used by portal: yes

portalErrorOnMailNotFound
    :Location: General Parameters » Portal » Customization » Other » Show error on mail not found
    :Description: Show error if mail is not found in password reset process
    :Used by portal: yes

portalFavicon
    :Location: General Parameters » Portal » Customization » Favicon
    :Description: Path to favicon file
    :Used by portal: yes

portalForceAuthn
    :Location: General Parameters » Advanced parameters » Security » Force authentication
    :Description: Enable force to authenticate when displaying portal
    :Used by portal: yes

portalForceAuthnInterval
    :Location: General Parameters » Advanced parameters » Security » Force authentication interval
    :Description: Maximum interval in seconds since last authentication to force reauthentication
    :Used by portal: yes

portalMainLogo
    :Location: General Parameters » Portal » Customization » Main logo
    :Description: Portal main logo path
    :Used by portal: yes

portalOpenLinkInNewWindow
    :Location: General Parameters » Portal » Customization » Other » New window
    :Description: Open applications in new windows
    :Used by portal: yes

portalPingInterval
    :Location: General Parameters » Portal » Customization » Other » Ping interval
    :Description: Interval in ms between portal Ajax pings
    :Used by portal: yes

portalRequireOldPassword
    :Location: General Parameters » Portal » Customization » Password management » Require old password
    :Description: Rule to require old password to change the password
    :Used by portal: yes

portalSkin
    :Location: General Parameters » Portal » Customization » Default skin
    :Description: Name of portal skin
    :Used by portal: yes

portalSkinBackground
    :Location: General Parameters » Portal » Customization » Skin background
    :Description: Background image of portal skin
    :Used by portal: yes

portalSkinRules
    :Location: General Parameters » Portal » Customization » Skin display rules
    :Description: Rules to choose portal skin
    :Used by portal: yes

portalStatus
    :Location: General Parameters » Plugins » Publish portal status
    :Description: Enable portal status
    :Used by portal: yes

portalUserAttr
    :Location: General Parameters » Portal » Customization » Other » User attribute
    :Description: Session parameter to display connected user in portal
    :Used by portal: yes

post
    :Location: Virtual Hosts » *configuration key* » Form replay
    :Description: Virtualhost urls/Data to post
    :Used by portal: yes

protection
    :Description: Manager protection method
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

proxyAuthService
    :Location: General Parameters » Authentication parameters » Proxy parameters » Internal Portal » URL
    :Used by portal: yes

proxyAuthServiceChoiceParam
    :Location: General Parameters » Authentication parameters » Proxy parameters » Internal Portal » Choice parameter
    :Used by portal: yes

proxyAuthServiceChoiceValue
    :Location: General Parameters » Authentication parameters » Proxy parameters » Internal Portal » Choice value
    :Used by portal: yes

proxyAuthServiceImpersonation
    :Location: General Parameters » Authentication parameters » Proxy parameters » Internal Portal » Impersonation
    :Description: Enable internal portal Impersonation
    :Used by portal: yes

proxyAuthnLevel
    :Location: General Parameters » Authentication parameters » Proxy parameters » Authentication level
    :Description: Proxy authentication level
    :Used by portal: yes

proxyCookieName
    :Location: General Parameters » Authentication parameters » Proxy parameters » Internal Portal » Cookie name
    :Description: Name of the internal portal cookie
    :Used by portal: yes

proxySessionService
    :Location: General Parameters » Authentication parameters » Proxy parameters » Internal Portal » Session service URL
    :Used by portal: yes

proxyUseSoap
    :Location: General Parameters » Authentication parameters » Proxy parameters » Use SOAP instead of REST
    :Description: Use SOAP instead of REST
    :Used by portal: yes

publicNotifications
    :Location: General Parameters » Plugins » Notifications » Public notifications
    :Description: Enable PublicNotification plugin
    :Used by portal: yes

radius2fActivation
    :Location: General Parameters » Second factors » Radius second factor » Activation
    :Description: Radius second factor activation
    :Used by portal: yes

radius2fAuthnLevel
    :Location: General Parameters » Second factors » Radius second factor » Authentication level
    :Description: Authentication level for users authenticated by Radius second factor
    :Used by portal: yes

radius2fDictionaryFile
    :Location: General Parameters » Second factors » Radius second factor » Dictionary
    :Used by portal: yes

radius2fLabel
    :Location: General Parameters » Second factors » Radius second factor » Label
    :Description: Portal label for Radius 2F
    :Used by portal: yes

radius2fLogo
    :Location: General Parameters » Second factors » Radius second factor » Logo
    :Description: Custom logo for Radius 2F
    :Used by portal: yes

radius2fMsgAuth
    :Location: General Parameters » Second factors » Radius second factor » Authenticate RADIUS requests
    :Description: Use Message-Authentication for Radius requests
    :Used by portal: yes

radius2fRequestAttributes
    :Location: General Parameters » Second factors » Radius second factor » Access request attributes
    :Description: RADIUS second factor authentication attributes
    :Used by portal: yes

radius2fSecret
    :Location: General Parameters » Second factors » Radius second factor » Shared secret
    :Used by portal: yes

radius2fSendInitialRequest
    :Location: General Parameters » Second factors » Radius second factor » Add login validation call
    :Description: Dial in to radius server before displaying form
    :Used by portal: yes

radius2fServer
    :Location: General Parameters » Second factors » Radius second factor » Server hostname
    :Used by portal: yes

radius2fTimeout
    :Location: General Parameters » Second factors » Radius second factor » Authentication timeout
    :Description: Radius 2f verification timeout
    :Used by portal: yes

radius2fUsernameSessionKey
    :Location: General Parameters » Second factors » Radius second factor » Session key containing login
    :Description: Session key used as Radius login
    :Used by portal: yes

radiusAuthnLevel
    :Location: General Parameters » Authentication parameters » Radius parameters » Authentication level
    :Description: Radius authentication level
    :Used by portal: yes

radiusDictionaryFile
    :Location: General Parameters » Authentication parameters » Radius parameters » Dictionary
    :Used by portal: yes

radiusExportedVars
    :Location: General Parameters » Authentication parameters » Radius parameters » Exported variables
    :Description: RADIUS exported variables
    :Used by portal: yes

radiusMsgAuth
    :Location: General Parameters » Authentication parameters » Radius parameters » Authenticate RADIUS requests
    :Description: Use Message-Authentication for Radius requests
    :Used by portal: yes

radiusRequestAttributes
    :Location: General Parameters » Authentication parameters » Radius parameters » Access request attributes
    :Description: RADIUS authentication attributes
    :Used by portal: yes

radiusSecret
    :Location: General Parameters » Authentication parameters » Radius parameters » Shared secret
    :Used by portal: yes

radiusServer
    :Location: General Parameters » Authentication parameters » Radius parameters » Server hostname
    :Used by portal: yes

radiusTimeout
    :Location: General Parameters » Authentication parameters » Radius parameters » Authentication timeout
    :Used by portal: yes

randomPasswordRegexp
    :Location: General Parameters » Plugins » Reset password by mail » Other » Regexp for password generation
    :Description: Regular expression to create a random password
    :Used by portal: yes

redirectFormMethod
    :Location: General Parameters » Advanced parameters » Forms » Method for redirect form
    :Description: HTTP method for redirect page form
    :Used by portal: yes

refreshSessions
    :Location: General Parameters » Plugins » Refresh sessions API
    :Description: Refresh sessions plugin
    :Used by portal: yes

registerConfirmBody
    :Location: General Parameters » Plugins » Register new account » Mail content » Verification mail content
    :Description: Mail body for register confirmation
    :Used by portal: yes

registerConfirmSubject
    :Location: General Parameters » Plugins » Register new account » Mail content » Verification mail subject
    :Description: Mail subject for register confirmation
    :Used by portal: yes

registerDB
    :Location: General Parameters » Authentication parameters » Register module
    :Description: Register module
    :Used by portal: yes

registerDoneBody
    :Location: General Parameters » Plugins » Register new account » Mail content » Credentials mail content
    :Description: Mail body when register is done
    :Used by portal: yes

registerDoneSubject
    :Location: General Parameters » Plugins » Register new account » Mail content » Credentials mail subject
    :Description: Mail subject when register is done
    :Used by portal: yes

registerTimeout
    :Location: General Parameters » Plugins » Register new account » Other » Validity time of a register request
    :Description: Register session timeout
    :Used by portal: yes

registerUrl
    :Location: General Parameters » Plugins » Register new account » Other » Register page URL
    :Description: URL of register page
    :Used by portal: yes

reloadTimeout
    :Location: General Parameters » Advanced parameters » Events management » Reload timeout
    :Description: Configuration reload timeout
    :Used by manager: yes

reloadUrls
    :Location: General Parameters » Advanced parameters » Events management » Reload URLs
    :Description: URL to call on reload
    :Used by portal: yes

rememberAuthChoiceForgetAtLogout
    :Location: General Parameters » Plugins » Remember authentication choice » Forget auth choice at logout
    :Description: Forget Auth Choice at logout
    :Used by portal: yes

rememberAuthChoiceRule
    :Location: General Parameters » Plugins » Remember authentication choice » Activation
    :Description: remember auth choice activation rule
    :Used by portal: yes

rememberCookieName
    :Location: General Parameters » Plugins » Remember authentication choice » Cookie name
    :Description: Name of the remember auth choice cookie
    :Used by portal: yes

rememberCookieTimeout
    :Location: General Parameters » Plugins » Remember authentication choice » cookie lifetime
    :Description: lifetime of the remember auth choice cookie
    :Used by manager: yes

rememberDefaultChecked
    :Location: General Parameters » Plugins » Remember authentication choice » Check by default
    :Description: Is remember auth choice checkbox enabled by default?
    :Used by portal: yes

rememberTimer
    :Location: General Parameters » Plugins » Remember authentication choice » Timer before automatic authentication choice
    :Description: timer before automatic authentication with remembered choice
    :Used by manager: yes

remoteCookieName
    :Location: General Parameters » Authentication parameters » Remote parameters » Cookie name
    :Description: Name of the remote portal cookie
    :Used by portal: yes

remoteGlobalStorage
    :Location: General Parameters » Authentication parameters » Remote parameters » Sessions module
    :Description: Remote session backend
    :Used by portal: yes

remoteGlobalStorageOptions
    :Location: General Parameters » Authentication parameters » Remote parameters » Sessions module options
    :Description: Apache::Session module parameters
    :Used by portal: yes

remotePortal
    :Location: General Parameters » Authentication parameters » Remote parameters » Portal URL
    :Used by portal: yes

requireToken
    :Location: General Parameters » Advanced parameters » Security » Require token for forms
    :Description: Enable token for forms
    :Used by portal: yes

rest2fActivation
    :Location: General Parameters » Second factors » REST second factor » Activation
    :Description: REST second factor activation
    :Used by portal: yes

rest2fAuthnLevel
    :Location: General Parameters » Second factors » REST second factor » Authentication level
    :Description: Authentication level for users authentified by REST second factor
    :Used by portal: yes

rest2fCodeActivation
    :Location: General Parameters » Second factors » REST second factor » Code regex
    :Description: OTP generated by Portal
    :Used by portal: yes

rest2fInitArgs
    :Location: General Parameters » Second factors » REST second factor » Init arguments
    :Description: Args for REST 2F init
    :Used by portal: yes

rest2fInitUrl
    :Location: General Parameters » Second factors » REST second factor » Init URL
    :Description: REST 2F init URL
    :Used by portal: yes

rest2fLabel
    :Location: General Parameters » Second factors » REST second factor » Label
    :Description: Portal label for REST second factor
    :Used by portal: yes

rest2fLogo
    :Location: General Parameters » Second factors » REST second factor » Logo
    :Description: Custom logo for REST 2F
    :Used by portal: yes

rest2fResendInterval
    :Location: General Parameters » Second factors » REST second factor » Re-send interval
    :Description: Delay before user is allowed to resend code
    :Used by portal: yes

rest2fVerifyArgs
    :Location: General Parameters » Second factors » REST second factor » Verify arguments
    :Description: Args for REST 2F init
    :Used by portal: yes

rest2fVerifyUrl
    :Location: General Parameters » Second factors » REST second factor » Verify URL
    :Description: REST 2F init URL
    :Used by portal: yes

restAuthServer
    :Location: General Parameters » Plugins » Portal servers » REST services » Authentication server
    :Description: Enable REST authentication server
    :Used by portal: yes

restAuthUrl
    :Location: General Parameters » Authentication parameters » REST parameters » Authentication URL
    :Used by portal: yes

restAuthnLevel
    :Location: General Parameters » Authentication parameters » REST parameters » Authentication level
    :Description: REST authentication level
    :Used by portal: yes

restClockTolerance
    :Location: General Parameters » Plugins » Portal servers » REST services » Server clock tolerance
    :Description: How tolerant the REST session server will be to clock dift
    :Used by portal: yes

restConfigServer
    :Location: General Parameters » Plugins » Portal servers » REST services » Configuration server
    :Description: Enable REST config server
    :Used by portal: yes

restExportSecretKeys
    :Location: General Parameters » Plugins » Portal servers » REST services » Export secret attributes
    :Description: Allow to export secret keys in REST session server
    :Used by portal: yes

restFindUserDBUrl
    :Location: General Parameters » Plugins » Search for user account » User accounts URL
    :Used by portal: yes

restPasswordServer
    :Location: General Parameters » Plugins » Portal servers » REST services » Password reset server
    :Description: Enable REST password reset server
    :Used by portal: yes

restPwdConfirmUrl
    :Location: General Parameters » Authentication parameters » REST parameters » Password confirmation URL
    :Used by portal: yes

restPwdModifyUrl
    :Location: General Parameters » Authentication parameters » REST parameters » Password change URL
    :Used by portal: yes

restSessionServer
    :Location: General Parameters » Plugins » Portal servers » REST services » Session server
    :Description: Enable REST session server
    :Used by portal: yes

restUserDBUrl
    :Location: General Parameters » Authentication parameters » REST parameters » User data URL
    :Used by portal: yes

sameSite
    :Location: General Parameters » Cookies » Cookie SameSite value
    :Description: Cookie SameSite value
    :Used by portal: yes
    :Used by handler: yes

samlAttributeAuthorityDescriptorAttributeServiceSOAP
    :Location: SAML2 Service » Attribute Authority » Attribute Service » SOAP
    :Description: SAML Attribute Authority SOAP
    :Used by portal: yes

samlAuthnContextMapExtra
    :Location: SAML2 Service » Authentication contexts » Other authentication contexts
    :Description: SAML extra authn contexts
    :Used by portal: yes

samlAuthnContextMapKerberos
    :Location: SAML2 Service » Authentication contexts » Kerberos
    :Description: SAML authn context kerberos level
    :Used by portal: yes

samlAuthnContextMapPassword
    :Location: SAML2 Service » Authentication contexts » Password
    :Description: SAML authn context password level
    :Used by portal: yes

samlAuthnContextMapPasswordProtectedTransport
    :Location: SAML2 Service » Authentication contexts » Password protected transport
    :Description: SAML authn context password protected transport level
    :Used by portal: yes

samlAuthnContextMapTLSClient
    :Location: SAML2 Service » Authentication contexts » TLS client
    :Description: SAML authn context TLS client level
    :Used by portal: yes

samlCommonDomainCookieActivation
    :Location: SAML2 Service » Advanced » Common Domain Cookie » Activation
    :Description: SAML CDC activation
    :Used by portal: yes

samlCommonDomainCookieDomain
    :Location: SAML2 Service » Advanced » Common Domain Cookie » Common domain
    :Used by portal: yes

samlCommonDomainCookieReader
    :Location: SAML2 Service » Advanced » Common Domain Cookie » Reader URL
    :Used by portal: yes

samlCommonDomainCookieWriter
    :Location: SAML2 Service » Advanced » Common Domain Cookie » Writer URL
    :Used by portal: yes

samlDiscoveryProtocolActivation
    :Location: SAML2 Service » Advanced » Discovery Protocol » Activation
    :Description: SAML Discovery Protocol activation
    :Used by portal: yes

samlDiscoveryProtocolIsPassive
    :Location: SAML2 Service » Advanced » Discovery Protocol » Is Passive
    :Description: SAML Discovery Protocol Is Passive
    :Used by portal: yes

samlDiscoveryProtocolPolicy
    :Location: SAML2 Service » Advanced » Discovery Protocol » Policy
    :Description: SAML Discovery Protocol Policy
    :Used by portal: yes

samlDiscoveryProtocolURL
    :Location: SAML2 Service » Advanced » Discovery Protocol » EndPoint URL
    :Description: SAML Discovery Protocol EndPoint URL
    :Used by portal: yes

samlEntityID
    :Location: SAML2 Service » Entity Identifier
    :Description: SAML service entityID
    :Used by portal: yes

samlFederationFiles
    :Location: SAML2 Service » Advanced » Federation » SAML Federation Metadata files
    :Description: Path to SAML Federation Metadata
    :Used by portal: yes

samlIDPMetaDataExportedAttributes
    :Location: SAML Identity Providers » *configuration key* » Exported attributes
    :Used by portal: yes

samlIDPMetaDataNodes
    :Used by portal: yes
    :Ini only: yes

samlIDPMetaDataOptions
    :Location: Options
    :Used by portal: yes

samlIDPMetaDataOptionsAdaptSessionUtime
    :Location: SAML Identity Providers » *configuration key* » Session » Adapt session lifetime
    :Used by portal: yes

samlIDPMetaDataOptionsAllowLoginFromIDP
    :Location: SAML Identity Providers » *configuration key* » Options » Allow login from IDP
    :Used by portal: yes

samlIDPMetaDataOptionsCheckAudience
    :Location: SAML Identity Providers » *configuration key* » Security » Check audience conditions
    :Used by portal: yes

samlIDPMetaDataOptionsCheckSLOMessageSignature
    :Location: SAML Identity Providers » *configuration key* » Signature » Check SLO message signature
    :Used by portal: yes

samlIDPMetaDataOptionsCheckSSOMessageSignature
    :Location: SAML Identity Providers » *configuration key* » Signature » Check SSO message signature
    :Used by portal: yes

samlIDPMetaDataOptionsCheckTime
    :Location: SAML Identity Providers » *configuration key* » Security » Check time conditions
    :Used by portal: yes

samlIDPMetaDataOptionsComment
    :Location: SAML Identity Providers » *configuration key* » Options » Comment
    :Used by portal: yes

samlIDPMetaDataOptionsDisplayName
    :Location: SAML Identity Providers » *configuration key* » Display » Name
    :Used by portal: yes

samlIDPMetaDataOptionsEncryptionMode
    :Location: SAML Identity Providers » *configuration key* » Security » Encryption mode
    :Used by portal: yes

samlIDPMetaDataOptionsFederationEntityID
    :Location: SAML Identity Providers » *configuration key* » Options » Federation » Entity Identifier
    :Used by portal: yes

samlIDPMetaDataOptionsForceAuthn
    :Location: SAML Identity Providers » *configuration key* » Options » Force authentication
    :Used by portal: yes

samlIDPMetaDataOptionsForceUTF8
    :Location: SAML Identity Providers » *configuration key* » Session » Force UTF-8
    :Used by portal: yes

samlIDPMetaDataOptionsIcon
    :Location: SAML Identity Providers » *configuration key* » Display » Logo
    :Used by portal: yes

samlIDPMetaDataOptionsIsPassive
    :Location: SAML Identity Providers » *configuration key* » Options » Passive authentication
    :Used by portal: yes

samlIDPMetaDataOptionsNameIDFormat
    :Location: SAML Identity Providers » *configuration key* » Options » NameID format
    :Used by portal: yes

samlIDPMetaDataOptionsRelayStateURL
    :Location: SAML Identity Providers » *configuration key* » Options » Allow URL as RelayState
    :Used by portal: yes

samlIDPMetaDataOptionsRequestedAuthnContext
    :Location: SAML Identity Providers » *configuration key* » Options » Requested authentication context
    :Used by portal: yes

samlIDPMetaDataOptionsResolutionRule
    :Location: SAML Identity Providers » *configuration key* » Display » Resolution rule
    :Used by portal: yes

samlIDPMetaDataOptionsSLOBinding
    :Location: SAML Identity Providers » *configuration key* » Binding » SLO binding
    :Used by portal: yes

samlIDPMetaDataOptionsSSOBinding
    :Location: SAML Identity Providers » *configuration key* » Binding » SSO binding
    :Used by portal: yes

samlIDPMetaDataOptionsSignSLOMessage
    :Location: SAML Identity Providers » *configuration key* » Signature » Sign SLO message
    :Used by portal: yes

samlIDPMetaDataOptionsSignSSOMessage
    :Location: SAML Identity Providers » *configuration key* » Signature » Sign SSO message
    :Used by portal: yes

samlIDPMetaDataOptionsSignatureKey
    :Location: SAML Identity Providers » *configuration key* » Signature » Signing key name
    :Used by portal: yes

samlIDPMetaDataOptionsSignatureMethod
    :Location: SAML Identity Providers » *configuration key* » Signature » Signature method
    :Used by portal: yes

samlIDPMetaDataOptionsSortNumber
    :Location: SAML Identity Providers » *configuration key* » Display » Order
    :Used by portal: yes

samlIDPMetaDataOptionsStoreSAMLToken
    :Location: SAML Identity Providers » *configuration key* » Session » Store SAML Token
    :Used by portal: yes

samlIDPMetaDataOptionsTooltip
    :Location: SAML Identity Providers » *configuration key* » Display » Tooltip
    :Used by portal: yes

samlIDPMetaDataOptionsURL
    :Location: SAML Identity Providers » *configuration key* » Options » Metadata URL
    :Used by portal: yes

samlIDPMetaDataOptionsUserAttribute
    :Location: SAML Identity Providers » *configuration key* » Session » Attribute containing user identifier
    :Used by portal: yes

samlIDPMetaDataXML
    :Location: SAML Identity Providers » *configuration key* » Metadata
    :Used by portal: yes

samlIDPSSODescriptorArtifactResolutionServiceArtifact
    :Location: SAML2 Service » Identity Provider » Artifact Resolution » Artifact Service
    :Description: SAML IDP artifact resolution service
    :Used by portal: yes

samlIDPSSODescriptorSingleLogoutServiceHTTPPost
    :Location: SAML2 Service » Identity Provider » Single Logout » HTTP POST
    :Description: SAML IDP SLO HTTP POST
    :Used by portal: yes

samlIDPSSODescriptorSingleLogoutServiceHTTPRedirect
    :Location: SAML2 Service » Identity Provider » Single Logout » HTTP Redirect
    :Description: SAML IDP SLO HTTP Redirect
    :Used by portal: yes

samlIDPSSODescriptorSingleLogoutServiceSOAP
    :Location: SAML2 Service » Identity Provider » Single Logout » SOAP
    :Description: SAML IDP SLO SOAP
    :Used by portal: yes

samlIDPSSODescriptorSingleSignOnServiceHTTPArtifact
    :Location: SAML2 Service » Identity Provider » Single Sign On » HTTP Artifact
    :Description: SAML IDP SSO HTTP Artifact
    :Used by portal: yes

samlIDPSSODescriptorSingleSignOnServiceHTTPPost
    :Location: SAML2 Service » Identity Provider » Single Sign On » HTTP POST
    :Description: SAML IDP SSO HTTP POST
    :Used by portal: yes

samlIDPSSODescriptorSingleSignOnServiceHTTPRedirect
    :Location: SAML2 Service » Identity Provider » Single Sign On » HTTP Redirect
    :Description: SAML IDP SSO HTTP Redirect
    :Used by portal: yes

samlIDPSSODescriptorWantAuthnRequestsSigned
    :Location: SAML2 Service » Identity Provider » Want Authentication Request Signed
    :Description: SAML IDP want authn request signed
    :Used by portal: yes

samlMetadataForceUTF8
    :Location: SAML2 Service » Advanced » UTF8 metadata conversion
    :Description: SAML force metadata UTF8 conversion
    :Used by portal: yes

samlNameIDFormatMapEmail
    :Location: SAML2 Service » NameID formats » Email
    :Description: SAML session parameter for NameID email
    :Used by portal: yes

samlNameIDFormatMapKerberos
    :Location: SAML2 Service » NameID formats » Kerberos
    :Description: SAML session parameter for NameID kerberos
    :Used by portal: yes

samlNameIDFormatMapWindows
    :Location: SAML2 Service » NameID formats » Windows
    :Description: SAML session parameter for NameID windows
    :Used by portal: yes

samlNameIDFormatMapX509
    :Location: SAML2 Service » NameID formats » X509
    :Description: SAML session parameter for NameID x509
    :Used by portal: yes

samlOrganizationDisplayName
    :Location: SAML2 Service » Organization » Display Name
    :Description: SAML service organization display name
    :Used by portal: yes

samlOrganizationName
    :Location: SAML2 Service » Organization » Name
    :Description: SAML service organization name
    :Used by portal: yes

samlOrganizationURL
    :Location: SAML2 Service » Organization » URL
    :Description: SAML service organization URL
    :Used by portal: yes

samlOverrideIDPEntityID
    :Location: SAML2 Service » Advanced » Override Entity ID when acting as IDP
    :Description: Override SAML EntityID when acting as an IDP
    :Used by portal: yes

samlRelayStateTimeout
    :Location: SAML2 Service » Advanced » RelayState session timeout
    :Description: SAML timeout of relay state
    :Used by portal: yes

samlSPMetaDataExportedAttributes
    :Location: SAML Service Providers » *configuration key* » Exported attributes
    :Used by portal: yes

samlSPMetaDataMacros
    :Location: SAML Service Providers » *configuration key* » Macros
    :Description: Macros
    :Used by portal: yes

samlSPMetaDataNodes
    :Used by portal: yes
    :Ini only: yes

samlSPMetaDataOptions
    :Location: Options
    :Used by portal: yes

samlSPMetaDataOptionsAuthnLevel
    :Location: SAML Service Providers » *configuration key* » Options » Security » Required authentication level
    :Description: Authentication level requires to access to this SP
    :Used by portal: yes

samlSPMetaDataOptionsCheckSLOMessageSignature
    :Location: SAML Service Providers » *configuration key* » Options » Signature » Check SLO message signature
    :Used by portal: yes

samlSPMetaDataOptionsCheckSSOMessageSignature
    :Location: SAML Service Providers » *configuration key* » Options » Signature » Check SSO message signature
    :Used by portal: yes

samlSPMetaDataOptionsComment
    :Location: SAML Service Providers » *configuration key* » Options » Comment
    :Used by portal: yes

samlSPMetaDataOptionsEnableIDPInitiatedURL
    :Location: SAML Service Providers » *configuration key* » Options » Security » Enable use of IDP initiated URL
    :Used by portal: yes

samlSPMetaDataOptionsEncryptionMode
    :Location: SAML Service Providers » *configuration key* » Options » Security » Encryption mode
    :Used by portal: yes

samlSPMetaDataOptionsFederationEntityID
    :Location: SAML Service Providers » *configuration key* » Options » Federation » Entity Identifier
    :Used by portal: yes

samlSPMetaDataOptionsFederationOptionalAttributes
    :Location: SAML Service Providers » *configuration key* » Options » Federation » Optional attributes
    :Used by portal: yes

samlSPMetaDataOptionsFederationRequiredAttributes
    :Location: SAML Service Providers » *configuration key* » Options » Federation » Required attributes
    :Used by portal: yes

samlSPMetaDataOptionsForceUTF8
    :Location: SAML Service Providers » *configuration key* » Options » Authentication response » Force UTF-8
    :Used by portal: yes

samlSPMetaDataOptionsNameIDFormat
    :Location: SAML Service Providers » *configuration key* » Options » Authentication response » Default NameID format
    :Used by portal: yes

samlSPMetaDataOptionsNameIDSessionKey
    :Location: SAML Service Providers » *configuration key* » Options » Authentication response » Force NameID session key
    :Used by portal: yes

samlSPMetaDataOptionsNotOnOrAfterTimeout
    :Location: SAML Service Providers » *configuration key* » Options » Authentication response » notOnOrAfter duration
    :Used by portal: yes

samlSPMetaDataOptionsOneTimeUse
    :Location: SAML Service Providers » *configuration key* » Options » Authentication response » One time use
    :Used by portal: yes

samlSPMetaDataOptionsRule
    :Location: SAML Service Providers » *configuration key* » Options » Security » Access rule
    :Description: Rule to grant access to this SP
    :Used by portal: yes

samlSPMetaDataOptionsSessionNotOnOrAfterTimeout
    :Location: SAML Service Providers » *configuration key* » Options » Authentication response » sessionNotOnOrAfter duration
    :Used by portal: yes

samlSPMetaDataOptionsSignSLOMessage
    :Location: SAML Service Providers » *configuration key* » Options » Signature » Sign SLO message
    :Used by portal: yes

samlSPMetaDataOptionsSignSSOMessage
    :Location: SAML Service Providers » *configuration key* » Options » Signature » Sign SSO message
    :Used by portal: yes

samlSPMetaDataOptionsSignatureKey
    :Location: SAML Service Providers » *configuration key* » Options » Signature » Signing key name
    :Used by portal: yes

samlSPMetaDataOptionsSignatureMethod
    :Location: SAML Service Providers » *configuration key* » Options » Signature » Signature method
    :Used by portal: yes

samlSPMetaDataOptionsURL
    :Location: SAML Service Providers » *configuration key* » Options » Metadata URL
    :Used by portal: yes

samlSPMetaDataXML
    :Location: SAML Service Providers » *configuration key* » Metadata
    :Used by portal: yes

samlSPSSODescriptorArtifactResolutionServiceArtifact
    :Location: SAML2 Service » Service Provider » Artifact Resolution » Artifact Service
    :Description: SAML SP artifact resolution service
    :Used by portal: yes

samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact
    :Location: SAML2 Service » Service Provider » Assertion Consumer » HTTP Artifact
    :Description: SAML SP ACS HTTP artifact
    :Used by portal: yes

samlSPSSODescriptorAssertionConsumerServiceHTTPPost
    :Location: SAML2 Service » Service Provider » Assertion Consumer » HTTP POST
    :Description: SAML SP ACS HTTP POST
    :Used by portal: yes

samlSPSSODescriptorAuthnRequestsSigned
    :Location: SAML2 Service » Service Provider » Signed Authentication Request
    :Description: SAML SP AuthnRequestsSigned
    :Used by portal: yes

samlSPSSODescriptorSingleLogoutServiceHTTPPost
    :Location: SAML2 Service » Service Provider » Single Logout » HTTP POST
    :Description: SAML SP SLO HTTP POST
    :Used by portal: yes

samlSPSSODescriptorSingleLogoutServiceHTTPRedirect
    :Location: SAML2 Service » Service Provider » Single Logout » HTTP Redirect
    :Description: SAML SP SLO HTTP Redirect
    :Used by portal: yes

samlSPSSODescriptorSingleLogoutServiceSOAP
    :Location: SAML2 Service » Service Provider » Single Logout » SOAP
    :Description: SAML SP SLO SOAP
    :Used by portal: yes

samlSPSSODescriptorWantAssertionsSigned
    :Location: SAML2 Service » Service Provider » Want Assertions Signed
    :Description: SAML SP WantAssertionsSigned
    :Used by portal: yes

samlServiceEncryptionKey
    :Location: SAML2 Service » Security parameters » Encryption key name
    :Description: Key to use for SAML encryption
    :Used by portal: yes

samlServicePrivateKeyEnc
    :Location: SAML2 Service » Security parameters » Encryption » Private key
    :Description: SAML encryption private key
    :Used by portal: yes

samlServicePrivateKeyEncPwd
    :Location: SAML2 Service » Security parameters » Encryption » Private key password
    :Used by portal: yes

samlServicePrivateKeySig
    :Location: SAML2 Service » Security parameters » Signature » Private key
    :Description: SAML signature private key
    :Used by portal: yes

samlServicePrivateKeySigPwd
    :Location: SAML2 Service » Security parameters » Signature » Private key password
    :Description: SAML signature private key password
    :Used by portal: yes

samlServicePublicKeyEnc
    :Location: SAML2 Service » Security parameters » Encryption » Public key
    :Description: SAML encryption public key
    :Used by portal: yes

samlServicePublicKeySig
    :Location: SAML2 Service » Security parameters » Signature » Public key
    :Description: SAML signature public key
    :Used by portal: yes

samlServiceSignatureKey
    :Location: SAML2 Service » Security parameters » Signing key name
    :Description: Key to use for SAML signature
    :Used by portal: yes

samlServiceSignatureMethod
    :Location: SAML2 Service » Security parameters » Signature method
    :Used by portal: yes

samlServiceUseCertificateInResponse
    :Location: SAML2 Service » Security parameters » Use certificate in responses
    :Description: Use certificate instead of public key in SAML responses
    :Used by portal: yes

samlStorage
    :Location: SAML2 Service » Sessions » SAML sessions module name
    :Description: Apache::Session module to store SAML user data
    :Used by portal: yes

samlStorageOptions
    :Location: SAML2 Service » Sessions » SAML sessions module options
    :Description: Apache::Session module parameters
    :Used by portal: yes

samlUseQueryStringSpecific
    :Location: SAML2 Service » Advanced » Use specific query_string method
    :Description: SAML use specific method for query_string
    :Used by portal: yes

scrollTop
    :Location: General Parameters » Portal » Customization » Scroll to top button
    :Description: Display back to top button
    :Used by portal: yes

secureTokenAllowOnError
    :Description: Secure Token allow requests in error
    :Used by handler: yes
    :Ini only: yes

secureTokenAttribute
    :Description: Secure Token attribute
    :Used by handler: yes
    :Ini only: yes

secureTokenExpiration
    :Description: Secure Token expiration
    :Used by handler: yes
    :Ini only: yes

secureTokenHeader
    :Description: Secure Token header
    :Used by handler: yes
    :Ini only: yes

secureTokenMemcachedServers
    :Description: Secure Token Memcached servers
    :Used by handler: yes
    :Ini only: yes

secureTokenUrls
    :Used by handler: yes
    :Ini only: yes

securedCookie
    :Location: General Parameters » Cookies » Secured Cookie (SSL)
    :Description: Cookie securisation method
    :Used by portal: yes
    :Used by handler: yes

sentryDsn
    :Description: Sentry logger DSN
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

sessionDataToRemember
    :Location: General Parameters » Plugins » Login history » Session data to store
    :Description: Data to remember in login history
    :Used by portal: yes

sfEngine
    :Description: Second factor engine
    :Used by portal: yes
    :Ini only: yes

sfExtra
    :Location: General Parameters » Second factors » Additional second factors
    :Description: Extra second factors
    :Used by portal: yes

sfLoginTimeout
    :Location: General Parameters » Second factors » Global options » Login timeout
    :Description: Timeout for 2F login process
    :Used by portal: yes

sfManagerRule
    :Location: General Parameters » Second factors » Global options » Display Manager link
    :Description: Rule to display second factor Manager link
    :Used by portal: yes

sfOnlyUpgrade
    :Location: General Parameters » Second factors » Global options » Use 2FA for session upgrade
    :Description: Only trigger second factor on session upgrade
    :Used by portal: yes

sfRegisterTimeout
    :Location: General Parameters » Second factors » Global options » Registration timeout
    :Description: Timeout for 2F registration process
    :Used by portal: yes

sfRemovedMsgRule
    :Location: General Parameters » Second factors » Global options » Warn if an expired 2FA is removed » Activation
    :Description: Display a message if at leat one expired SF has been removed
    :Used by portal: yes

sfRemovedNotifMsg
    :Location: General Parameters » Second factors » Global options » Warn if an expired 2FA is removed » Notification message
    :Description: Notification message
    :Used by portal: yes

sfRemovedNotifRef
    :Location: General Parameters » Second factors » Global options » Warn if an expired 2FA is removed » Notification reference
    :Description: Notification reference
    :Used by portal: yes

sfRemovedNotifTitle
    :Location: General Parameters » Second factors » Global options » Warn if an expired 2FA is removed » Notification title
    :Description: Notification title
    :Used by portal: yes

sfRemovedUseNotif
    :Location: General Parameters » Second factors » Global options » Warn if an expired 2FA is removed » Use Notifications plugin
    :Description: Use Notifications plugin to display message
    :Used by portal: yes

sfRequired
    :Location: General Parameters » Second factors » Global options » Force 2FA registration at login
    :Description: Second factor required
    :Used by portal: yes

sfRetries
    :Location: General Parameters » Second factors » Global options » Allowed retries
    :Description: Allowed number of retries
    :Used by portal: yes

showLanguages
    :Location: General Parameters » Portal » Customization » Show languages choice
    :Description: Display langs icons
    :Used by portal: yes

singleIP
    :Location: General Parameters » Sessions » Multiple sessions » One IP address per user
    :Description: Allow only one session per IP
    :Used by portal: yes

singleSession
    :Location: General Parameters » Sessions » Multiple sessions » One session per user
    :Description: Allow only one session per user
    :Used by portal: yes

singleUserByIP
    :Location: General Parameters » Sessions » Multiple sessions » One user per IP address
    :Description: Allow only one user per IP
    :Used by portal: yes

skipRenewConfirmation
    :Location: General Parameters » Advanced parameters » Portal redirections » Skip re-auth confirmation
    :Description: Avoid asking confirmation when an Issuer asks to renew auth
    :Used by portal: yes

skipUpgradeConfirmation
    :Location: General Parameters » Advanced parameters » Portal redirections » Skip upgrade confirmation
    :Description: Avoid asking confirmation during a session upgrade
    :Used by portal: yes

slaveAuthnLevel
    :Location: General Parameters » Authentication parameters » Slave parameters » Authentication level
    :Description: Slave authentication level
    :Used by portal: yes

slaveDisplayLogo
    :Location: General Parameters » Authentication parameters » Slave parameters » Display authentication logo
    :Description: Display Slave authentication logo
    :Used by portal: yes

slaveExportedVars
    :Location: General Parameters » Authentication parameters » Slave parameters » Exported variables
    :Description: Slave exported variables
    :Used by portal: yes

slaveHeaderContent
    :Location: General Parameters » Authentication parameters » Slave parameters » Control header content
    :Used by portal: yes

slaveHeaderName
    :Location: General Parameters » Authentication parameters » Slave parameters » Control header name
    :Used by portal: yes

slaveMasterIP
    :Location: General Parameters » Authentication parameters » Slave parameters » Master's IP address
    :Used by portal: yes

slaveUserHeader
    :Location: General Parameters » Authentication parameters » Slave parameters » Header for user login
    :Used by portal: yes

soapConfigServer
    :Location: General Parameters » Plugins » Portal servers » SOAP services » Configuration server
    :Description: Enable SOAP config server
    :Used by portal: yes

soapProxyUrn
    :Description: SOAP URN for Proxy
    :Used by portal: yes
    :Ini only: yes

soapSessionServer
    :Location: General Parameters » Plugins » Portal servers » SOAP services » Session server
    :Description: Enable SOAP session server
    :Used by portal: yes

sslByAjax
    :Location: General Parameters » Authentication parameters » mTLS parameters » Use Ajax request
    :Description: Use Ajax request for Mutual TLS Authentication
    :Used by portal: yes

sslHost
    :Location: General Parameters » Authentication parameters » mTLS parameters » Ajax mTLS URL
    :Description: URL for Mutual TLS Authentication Ajax request
    :Used by portal: yes

staticPrefix
    :Description: Prefix of static files for HTML templates
    :Used by portal: yes
    :Ini only: yes

statusQueueName
    :Description: Status channel name
    :Used by handler: yes
    :Ini only: yes

stayConnected
    :Location: General Parameters » Plugins » Trusted browser » Authentication bypass
    :Description: Stay connected activation rule
    :Used by portal: yes

stayConnectedBypassFG
    :Location: General Parameters » Plugins » Trusted browser » Do not check fingerprint
    :Description: Disable fingerprint checkng
    :Used by portal: yes

stayConnectedCookieName
    :Location: General Parameters » Plugins » Trusted browser » Cookie name
    :Description: Name of the stayConnected plugin cookie
    :Used by portal: yes

stayConnectedSingleSession
    :Location: General Parameters » Plugins » Trusted browser » One trusted browser per user
    :Description: Allow only one permanent session per user
    :Used by portal: yes

stayConnectedTimeout
    :Location: General Parameters » Plugins » Trusted browser » Expiration time
    :Description: StayConnected persistent connexion session timeout
    :Used by manager: yes

storePassword
    :Location: General Parameters » Sessions » Store user password in session
    :Description: Store password in session
    :Used by portal: yes

storePasswordEncrypted
    :Location: General Parameters » Sessions » Encrypt password in session
    :Description: Crypt the password in session
    :Used by portal: yes

strictTransportSecurityMax_Age
    :Location: General Parameters » Advanced parameters » Security » Strict-Transport-Security max age
    :Description: Max-age for Strict-Transport-Security
    :Used by portal: yes

successLoginNumber
    :Location: General Parameters » Plugins » Login history » Max successful logins count
    :Description: Number of success stored in login history
    :Used by portal: yes

syslogFacility
    :Description: Syslog logger technical facility
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

syslogSockOptions
    :Description: Option to send to setlogsock()
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

timeout
    :Location: General Parameters » Sessions » Sessions timeout
    :Description: Session timeout on server side
    :Used by portal: yes

timeoutActivity
    :Location: General Parameters » Sessions » Sessions activity timeout
    :Description: Session activity timeout on server side
    :Used by portal: yes

timeoutActivityInterval
    :Location: General Parameters » Sessions » Sessions update interval
    :Description: Update session timeout interval on server side
    :Used by portal: yes

tokenUseGlobalStorage
    :Location: General Parameters » Advanced parameters » Security » Use global storage
    :Description: Enable global token storage
    :Used by portal: yes

totp2fActivation
    :Location: General Parameters » Second factors » TOTP » Activation
    :Description: TOTP activation
    :Used by portal: yes

totp2fAuthnLevel
    :Location: General Parameters » Second factors » TOTP » Authentication level
    :Description: Authentication level for users authentified by password+TOTP
    :Used by portal: yes

totp2fDigits
    :Location: General Parameters » Second factors » TOTP » Number of digits
    :Description: Number of digits for TOTP code
    :Used by portal: yes

totp2fEncryptSecret
    :Location: General Parameters » Second factors » TOTP » Encrypt TOTP secrets
    :Description: Encrypt TOTP secrets in database
    :Used by portal: yes

totp2fInterval
    :Location: General Parameters » Second factors » TOTP » Interval
    :Description: TOTP interval
    :Used by portal: yes

totp2fIssuer
    :Location: General Parameters » Second factors » TOTP » Issuer name
    :Description: TOTP Issuer
    :Used by portal: yes

totp2fLabel
    :Location: General Parameters » Second factors » TOTP » Label
    :Description: Portal label for TOTP 2F
    :Used by portal: yes

totp2fLogo
    :Location: General Parameters » Second factors » TOTP » Logo
    :Description: Custom logo for TOTP 2F
    :Used by portal: yes

totp2fRange
    :Location: General Parameters » Second factors » TOTP » Range of attempts
    :Description: TOTP range (number of interval to test)
    :Used by portal: yes

totp2fSelfRegistration
    :Location: General Parameters » Second factors » TOTP » Self registration
    :Description: TOTP self registration activation
    :Used by portal: yes

totp2fTTL
    :Location: General Parameters » Second factors » TOTP » Lifetime
    :Description: TOTP device time to live
    :Used by portal: yes

totp2fUserCanRemoveKey
    :Location: General Parameters » Second factors » TOTP » Allow user to remove TOTP
    :Description: Authorize users to remove existing TOTP secret
    :Used by portal: yes

trustedBrowserRule
    :Location: General Parameters » Plugins » Trusted browser » Activation condition
    :Description: Trusted browser registration rule
    :Used by portal: yes

trustedBrowserUseTotp
    :Location: General Parameters » Plugins » Trusted browser » Use time-based fingerprinting
    :Description: Use TOTP for trusted browser registration
    :Used by portal: yes

trustedDomains
    :Location: General Parameters » Advanced parameters » Security » Trusted domains
    :Description: Trusted domains
    :Used by portal: yes

twitterAppName
    :Location: General Parameters » Authentication parameters » Twitter parameters » Application name
    :Used by portal: yes

twitterAuthnLevel
    :Location: General Parameters » Authentication parameters » Twitter parameters » Authentication level
    :Description: Twitter authentication level
    :Used by portal: yes

twitterKey
    :Location: General Parameters » Authentication parameters » Twitter parameters » API key
    :Used by portal: yes

twitterSecret
    :Location: General Parameters » Authentication parameters » Twitter parameters » API secret
    :Used by portal: yes

twitterUserField
    :Location: General Parameters » Authentication parameters » Twitter parameters » Field containing user identifier
    :Used by portal: yes

upgradeSession
    :Location: General Parameters » Plugins » Upgrade session
    :Description: Upgrade session activation
    :Used by portal: yes

useRedirectAjaxOnUnauthorized
    :Location: General Parameters » Advanced parameters » Handler redirections » Redirect AJAX requests on unauthorized
    :Description: Redirect Ajax requests to portal for unauthorized (401)
    :Used by handler: yes

useRedirectOnError
    :Location: General Parameters » Advanced parameters » Handler redirections » Redirect on error
    :Description: Use 302 redirect code for error (500)
    :Used by handler: yes

useRedirectOnForbidden
    :Location: General Parameters » Advanced parameters » Handler redirections » Redirect on forbidden
    :Description: Use 302 redirect code for forbidden (403)
    :Used by portal: yes

useSafeJail
    :Location: General Parameters » Advanced parameters » Security » Use Safe jail
    :Description: Activate Safe jail
    :Used by portal: yes
    :Used by handler: yes

userControl
    :Location: General Parameters » Advanced parameters » Security » Username control
    :Description: Regular expression to validate login
    :Used by portal: yes

userDB
    :Location: General Parameters » Authentication parameters » Users module
    :Description: User module
    :Used by portal: yes

userLogger
    :Description: User actions logger
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

userPivot
    :Location: General Parameters » Authentication parameters » DBI parameters » Schema » Login field name in user table
    :Used by portal: yes

userSyslogFacility
    :Description: Syslog logger user-actions facility
    :Used by portal: yes
    :Used by manager: yes
    :Used by handler: yes
    :Ini only: yes

vhostAccessToTrace
    :Location: Virtual Hosts » *configuration key* » Options » Access to trace
    :Used by portal: yes

vhostAliases
    :Location: Virtual Hosts » *configuration key* » Options » Aliases
    :Used by portal: yes

vhostAuthnLevel
    :Location: Virtual Hosts » *configuration key* » Options » Required authentication level
    :Used by portal: yes

vhostComment
    :Location: Virtual Hosts » *configuration key* » Options » Comment
    :Used by portal: yes

vhostDevOpsRulesUrl
    :Location: Virtual Hosts » *configuration key* » Options » DevOps rules file URL
    :Used by portal: yes

vhostHttps
    :Location: Virtual Hosts » *configuration key* » Options » HTTPS
    :Used by portal: yes

vhostMaintenance
    :Location: Virtual Hosts » *configuration key* » Options » Maintenance mode
    :Used by portal: yes

vhostOptions
    :Location: Options
    :Used by portal: yes

vhostPort
    :Location: Virtual Hosts » *configuration key* » Options » Port
    :Used by portal: yes

vhostServiceTokenTTL
    :Location: Virtual Hosts » *configuration key* » Options » ServiceToken timeout
    :Used by portal: yes

vhostType
    :Location: Virtual Hosts » *configuration key* » Options » Type
    :Description: Handler type
    :Used by portal: yes

viewerAllowBrowser
    :Description: Allow configuration browser
    :Used by portal: yes
    :Ini only: yes

viewerAllowDiff
    :Description: Allow configuration diff
    :Used by portal: yes
    :Ini only: yes

viewerHiddenKeys
    :Description: Hidden Conf keys
    :Used by manager: yes
    :Ini only: yes

virtualHosts
    :Used by portal: yes
    :Ini only: yes

webCronSecret
    :Location: General Parameters » Plugins » WebCron » Secret
    :Description: Secret token for webcron plugin
    :Used by portal: yes

webIDAuthnLevel
    :Location: General Parameters » Authentication parameters » WebID parameters » Authentication level
    :Description: WebID authentication level
    :Used by portal: yes

webIDExportedVars
    :Location: General Parameters » Authentication parameters » WebID parameters » Exported variables
    :Description: WebID exported variables
    :Used by portal: yes

webIDWhitelist
    :Location: General Parameters » Authentication parameters » WebID parameters » WebID whitelist
    :Used by portal: yes

webauthn2fActivation
    :Location: General Parameters » Second factors » WebAuthn » Activation
    :Description: WebAuthn second factor activation
    :Used by portal: yes

webauthn2fAttestation
    :Location: General Parameters » Second factors » WebAuthn » Attestation
    :Description: Ask the authenticator for an attestation
    :Used by portal: yes

webauthn2fAttestationTrust
    :Location: General Parameters » Second factors » WebAuthn » Attestation trusted certificates
    :Description: Certificate bundle for attestation trust validation
    :Used by portal: yes

webauthn2fAuthnLevel
    :Location: General Parameters » Second factors » WebAuthn » Authentication level
    :Description: Authentication level for users authentified by WebAuthn second factor
    :Used by portal: yes

webauthn2fLabel
    :Location: General Parameters » Second factors » WebAuthn » Label
    :Description: Portal label for WebAuthn second factor
    :Used by portal: yes

webauthn2fLogo
    :Location: General Parameters » Second factors » WebAuthn » Logo
    :Description: Custom logo for WebAuthn 2F
    :Used by portal: yes

webauthn2fResidentKey
    :Location: General Parameters » Second factors » WebAuthn » Use discoverable credential
    :Description: Use discoverable credential
    :Used by portal: yes

webauthn2fSelfRegistration
    :Location: General Parameters » Second factors » WebAuthn » Self registration
    :Description: WebAuthn self registration activation
    :Used by portal: yes

webauthn2fUserCanRemoveKey
    :Location: General Parameters » Second factors » WebAuthn » Allow user to remove WebAuthn
    :Description: Authorize users to remove existing WebAuthn
    :Used by portal: yes

webauthn2fUserVerification
    :Location: General Parameters » Second factors » WebAuthn » User verification
    :Description: Verify user during registration and login
    :Used by portal: yes

webauthnAppId
    :Location: General Parameters » Second factors » WebAuthn » Send U2F AppID
    :Description: Send AppID extension
    :Used by portal: yes

webauthnAuthnLevel
    :Location: General Parameters » Authentication parameters » WebAuthn parameters » Authentication level
    :Description: WebAuthn authentication level
    :Used by portal: yes

webauthnDefaultTransports
    :Location: General Parameters » Second factors » WebAuthn » Default transports
    :Description: WebAuthn default transports
    :Used by portal: yes

webauthnDisplayNameAttr
    :Location: General Parameters » Second factors » WebAuthn » User Display Name attribute
    :Description: Session attribute containing user display name
    :Used by portal: yes

webauthnRpId
    :Location: General Parameters » Second factors » WebAuthn » Relying Party ID
    :Description: WebAuthn Relying Party ID
    :Used by portal: yes

webauthnRpName
    :Location: General Parameters » Second factors » WebAuthn » Relying Party display name
    :Description: WebAuthn Relying Party display name
    :Used by portal: yes

whatToTrace
    :Location: General Parameters » Logs » REMOTE_USER
    :Description: Session parameter used to fill REMOTE_USER
    :Used by portal: yes
    :Used by handler: yes

wsdlServer
    :Location: General Parameters » Plugins » Portal servers » SOAP services » WSDL server
    :Description: Enable /portal.wsdl server
    :Used by portal: yes

yubikey2fActivation
    :Location: General Parameters » Second factors » Yubico OTP » Activation
    :Description: Yubikey second factor activation
    :Used by portal: yes

yubikey2fAuthnLevel
    :Location: General Parameters » Second factors » Yubico OTP » Authentication level
    :Description: Authentication level for users authentified by Yubikey second factor
    :Used by portal: yes

yubikey2fClientID
    :Location: General Parameters » Second factors » Yubico OTP » API client ID
    :Description: Yubico client ID
    :Used by portal: yes

yubikey2fFromSessionAttribute
    :Location: General Parameters » Second factors » Yubico OTP » Get Yubikey ID from session attribute
    :Description: Provision yubikey from the given session variable
    :Used by portal: yes

yubikey2fLabel
    :Location: General Parameters » Second factors » Yubico OTP » Label
    :Description: Portal label for Yubikey second factor
    :Used by portal: yes

yubikey2fLogo
    :Location: General Parameters » Second factors » Yubico OTP » Logo
    :Description: Custom logo for Yubikey 2F
    :Used by portal: yes

yubikey2fNonce
    :Location: General Parameters » Second factors » Yubico OTP » Nonce
    :Description: Yubico nonce
    :Used by portal: yes

yubikey2fPublicIDSize
    :Location: General Parameters » Second factors » Yubico OTP » OTP public ID part size
    :Description: Yubikey public ID size
    :Used by portal: yes

yubikey2fSecretKey
    :Location: General Parameters » Second factors » Yubico OTP » API secret key
    :Description: Yubico secret key
    :Used by portal: yes

yubikey2fSelfRegistration
    :Location: General Parameters » Second factors » Yubico OTP » Self registration
    :Description: Yubikey self registration activation
    :Used by portal: yes

yubikey2fTTL
    :Location: General Parameters » Second factors » Yubico OTP » Lifetime
    :Description: Yubikey device time to live
    :Used by portal: yes

yubikey2fUrl
    :Location: General Parameters » Second factors » Yubico OTP » Service URL
    :Description: Yubico server
    :Used by portal: yes

yubikey2fUserCanRemoveKey
    :Location: General Parameters » Second factors » Yubico OTP » Allow user to remove Yubikey
    :Description: Authorize users to remove existing Yubikey
    :Used by portal: yes

zimbraAccountKey
    :Description: Zimbra account session key
    :Used by handler: yes
    :Ini only: yes

zimbraBy
    :Description: Zimbra account type
    :Used by handler: yes
    :Ini only: yes

zimbraPreAuthKey
    :Description: Zimbra preauthentication key
    :Used by handler: yes
    :Ini only: yes

zimbraSsoUrl
    :Description: Zimbra local SSO URL pattern
    :Used by handler: yes
    :Ini only: yes

zimbraUrl
    :Description: Zimbra preauthentication URL
    :Used by handler: yes
    :Ini only: yes


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
Overlay real configuration backend                                            overlayRealtype      :doc:`Overlay<overlayconfbackend>`
Overlay directory                                                             overlayDirectory     :doc:`Overlay<overlayconfbackend>`
Overlay write authorization                                                   overlayWrite         :doc:`Overlay<overlayconfbackend>`

============================================================================= ==================== ===========================================================
