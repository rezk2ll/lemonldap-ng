##@file
# All configuration attributes

##@class
# All configuration attributes

package Lemonldap::NG::Common::Conf::Attributes;

use Mouse;

our $VERSION = 1.4.0;

## A

has 'activeTimer' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Enable timers on portal pages',
);

has 'apacheAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '4',
    documentation => 'Apache authentication level',
);

has 'authChoiceParam' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'lmAuth',
    documentation => 'HTTP parameter to store choosen authentication method',
);

has 'authentication' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Demo',
    documentation => 'Authentication module',
);

## B

## C

has 'captcha_login_enabled' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Captcha on login page',
);

has 'captcha_mail_enabled' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Captcha on password reset page',
);

has 'captcha_size' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '6',
    documentation => 'Captcha size',
);

has 'casAccessControlPolicy' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'none',
    documentation => 'CAS access control policy',
);

has 'CAS_authnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '1',
    documentation => 'CAS authentication level',
);

has 'checkXSS' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Check XSS',
);

has 'confirmFormMethod' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'post',
    documentation => 'HTTP method for confirm page form',
);

has 'cookieName' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'lemonldap',
    documentation => 'Name of the cookie',
);

## D

has 'dbiAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '2',
    documentation => 'DBI authentication level',
);

has 'domain' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'example.com',
    documentation => 'DNS domain',
);

## E

## F

has 'facebookAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '1',
    documentation => 'Facebook authentication level',
);

has 'failedLoginNumber' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '5',
    documentation => 'Number of failures stored in login history',
);

## G

has 'globalStorage' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Apache::Session::File',
    documentation => 'Session backend module',
);

has 'globalStorageOptions' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return { Directory => "/tmp" };
    },
    documentation => 'Session backend module options',
);

has 'googleAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '1',
    documentation => 'Google authentication level',
);

## H

has 'hiddenAttributes' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '_password',
    documentation => 'Name of attributes to hide in logs',
);

has 'httpOnly' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Enable httpOnly flag in cookie',
);

## I

has 'infoFormMethod' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'get',
    documentation => 'HTTP method for info page form',
);

## J

has 'jsRedirect' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '0',
    documentation => 'Use javascript for redirections',
);

## K

has 'key' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return join( '', map { chr( int( rand(94) ) + 33 ) } ( 1 .. 16 ) );
    },
    documentation => 'Secret key',
);

## L

has 'ldapAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '2',
    documentation => 'LDAP authentication level',
);

has 'ldapGroupAttributeName' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'member',
    documentation => 'LDAP attribute name for member in groups',
);

has 'ldapGroupAttributeNameGroup' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'dn',
    documentation =>
      'LDAP attribute name in group entry referenced as member in groups',
);

has 'ldapGroupAttributeNameSearch' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'cn',
    documentation => 'LDAP attributes to search in groups',
);

has 'ldapGroupAttributeNameUser' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'dn',
    documentation =>
      'LDAP attribute name in user entry referenced as member in groups',
);

has 'ldapGroupObjectClass' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'groupOfNames',
    documentation => 'LDAP object class of groups',
);

has 'ldapGroupRecursive' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'LDAP recursive search in groups',
);

has 'ldapPasswordResetAttribute' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'pwdReset',
    documentation => 'LDAP password reset attribute',
);

has 'ldapPasswordResetAttributeValue' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'TRUE',
    documentation => 'LDAP password reset value',
);

has 'ldapUsePasswordResetAttribute' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'LDAP store reset flag in an attribute',
);

has 'loginHistoryEnabled' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Enable login history',
);

has 'logoutServices' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return {}; },
    documentation => 'Send logout trough GET request to these services',
);

## M

has 'mailConfirmSubject' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '[LemonLDAP::NG] Password reset confirmation',
    documentation => 'Mail subject for reset confirmation',
);

has 'mailFrom' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my $self = shift;
        return "noreply@" . $self->domain;
    },
    lazy          => 1,
    documentation => 'Sender email',
);

has 'mailSessionKey' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'mail',
    documentation => 'Session parameter where mail is stored',
);

has 'mailOnPasswordChange' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Send a mail when password is changed',
);

has 'mailSubject' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '[LemonLDAP::NG] Your new password',
    documentation => 'Mail subject for new password email',
);

has 'mailUrl' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my $self = shift;
        return $self->portal . "/mail.pl";
    },
    lazy          => 1,
    documentation => 'URL of password reset page',
);

has 'multiValuesSeparator' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '; ',
    documentation => 'Separator for multiple values',
);

## N

has 'notificationWildcard' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'allusers',
    documentation => 'Notification string to match all users',
);

has 'nullAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '2',
    documentation => 'Null authentication level',
);

## O

has 'openIdAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '1',
    documentation => 'OpenID authentication level',
);

## P

has 'passwordDB' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Demo',
    documentation => 'Password module',
);

has 'portal' => (
    is            => 'rw',
    isa           => 'Any',
    default       => 'http://auth.example.com',
    documentation => 'Portal URL',
);

has 'portalAutocomplete' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Allow autocompletion of login input in portal',
);

has 'portalCheckLogins' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Display login history checkbox in portal',
);

has 'portalDisplayAppslist' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'Display applications tab in portal',
);

has 'portalDisplayChangePassword' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'Display password tab in portal',
);

has 'portalDisplayLoginHistory' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'Display login history tab in portal',
);

has 'portalDisplayLogout' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'Display logout tab in portal',
);

has 'portalDisplayResetPassword' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'Display reset password button in portal',
);

has 'portalForceAuthn' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Force to authenticate when displaying portal',
);

has 'portalForceAuthnInterval' => (
    is      => 'rw',
    isa     => 'Int',
    default => '0',
    documentation =>
'Minimum number of seconds since last authentifcation to force reauthentication',
);

has 'portalOpenLinkInNewWindow' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Open applications in new windows',
);

has 'portalPingInterval' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '60000',
    documentation => 'Interval in ms between portal Ajax pings ',
);

has 'portalRequireOldPassword' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Old password is required to change the password',
);

has 'portalSkin' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'bootstrap',
    documentation => 'Name of portal skin',
);

has 'portalUserAttr' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '_user',
    documentation => 'Session parameter to display connected user in portal',
);

## Q

## R

has 'radiusAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '3',
    documentation => 'Radius authentication level',
);

has 'randomPasswordRegexp' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '[A-Z]{3}[a-z]{5}.\d{2}',
    documentation => 'Regular expression to create a random password',
);

has 'redirectFormMethod' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'get',
    documentation => 'HTTP method for redirect page form',
);

## S

has 'samlAuthnContextMapKerberos' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '4',
    documentation => 'SAML authn context kerberos level',
);

has 'samlAuthnContextMapPassword' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '2',
    documentation => 'SAML authn context password level',
);

has 'samlAuthnContextMapPasswordProtectedTransport' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '3',
    documentation => 'SAML authn context password protected transport level',
);

has 'samlAuthnContextMapTLSClient' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '5',
    documentation => 'SAML authn context TLS client level',
);

has 'samlIdPResolveCookie' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my $self = shift;
        return $self->cookieName . "idp";
    },
    lazy          => 1,
    documentation => 'SAML IDP resolution cookie',
);

has 'samlMetadataForceUTF8' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML force metadata UTF8 conversion',
);

has 'samlRelayStateTimeout' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '600',
    documentation => 'SAML timeout of relay state',
);

has 'securedCookie' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '0',
    documentation => 'Cookie securisation method',
);

has 'SMTPServer' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'localhost',
    documentation => 'SMTP Server',
);

has 'SSLAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '5',
    documentation => 'SSL authentication level',
);

has 'successLoginNumber' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '5',
    documentation => 'Number of success stored in login history',
);

## T

has 'twitterAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '1',
    documentation => 'Twitter authentication level',
);

## U

has 'userControl' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '^[\w\.\-@]+$',
    documentation => 'Regular expression to validate login',
);

has 'userDB' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Demo',
    documentation => 'User module',
);

has 'useSafeJail' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Activate Safe jail',
);

## V

## W

has 'whatToTrace' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'uid',
    documentation => 'Session parameter used to fill REMOTE_USER',
);

## X

## Y

## Z

no Mouse;

1;
