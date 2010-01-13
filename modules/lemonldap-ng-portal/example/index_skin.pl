#!/usr/bin/perl

use Lemonldap::NG::Portal::SharedConf;
use HTML::Template;
use strict;

# Menu configuration
my $skin_dir    = "__SKINDIR__";
my $appsxmlfile = "__APPSXMLFILE__";
my $appsimgpath = "apps/";

my $portal = Lemonldap::NG::Portal::SharedConf->new(
    {

        # ACCESS TO CONFIGURATION
        # By default, Lemonldap::NG uses the default lemonldap-ng.ini file to
        # know where to find its configuration
        # (generaly /etc/lemonldap-ng/lemonldap-ng.ini)
        # You can specify by yourself this file :
        #configStorage => { confFile => '/path/to/my/file' },
        # or set explicitely parameters :
        #configStorage => {
        #  type => 'File',
        #  dirName => '/usr/local/lemonldap-ng/data//conf'
        #},
        # Note that YOU HAVE TO SET configStorage here if you've declared this
        # portal as SOAP configuration server in the manager

        # PORTAL CUSTOMIZATION
        # * Skin
        # portalSkin => 'pastel',
        # * Modules displayed
        # portalDisplayLogout => 1,
        # portalDisplayResetPassword => 1,
        # portalDisplayChangePassword => 1,
        # portalDisplayAppslist => 1,
        # * Allow password autocompletion
        #   (passwords stored in user web browsers)
        # portalAutocomplete => "on",
        # * Require the old password when changing password
        # portalRequireOldPassword => 1,
        # * Attribute displayed as connected user
        # portalUserAttr => "mail",

        # LOG
        # By default, all is logged in Apache file. To log user actions by
        # syslog, just set syslog facility here:
        #syslog => 'auth',

        # SOAP FUNCTIONS
        # Remove comment to activate SOAP Functions getCookies(user,pwd) and
        # error(language, code)
        Soap => 1,

        # Note that getAttibutes() will be activated but on a different URI
        # (http://auth.example.com/index.pl/sessions)
        # You can also restrict attributes and macros exported by getAttributes
        #exportedAttr => 'uid mail',

        # PASSWORD POLICY
        # Remove comment to use LDAP Password Policy
        #ldapPpolicyControl => 1,

        # Remove comment to store password in session (use with caution)
        #storePassword      => 1,

        # Remove comment to use LDAP modify password extension
        # (beware of compatibility with LDAP Password Policy)
        #ldapSetPassword    => 1,

        # RESET PASSWORD BY MAIL
        # SMTP server (default to localhost), set to '' to use default mail
        # service
        #SMTPServer => "localhost",

        # Mail From address
        #mailFrom => "noreply@test.com",

        # Mail subject
        #mailSubject => "Password reset",

        # Mail body (can use $password for generated password, and other session
        # infos, like $cn)
        #mailBody => 'Hello $cn,\n\nYour new password is $password',

        # LDAP filter to use
        #mailLDAPFilter => '(&(mail=$mail)(objectClass=inetOrgPerson))',

        # Random regexp
        #randomPasswordRegexp => '[A-Z]{3}[a-z]{5}.\d{2}',

        # LDAP GROUPS
        # Set the base DN of your groups branch
        #ldapGroupBase => 'ou=groups,dc=example,dc=com',
        # Objectclass used by groups
        #ldapGroupObjectClass => 'groupOfUniqueNames',
        # Attribute used by groups to store member
        #ldapGroupAttributeName => 'uniqueMember',
        # Attribute used by user to link to groups
        #ldapGroupAttributeNameUser => 'dn',
        # Attribute used to identify a group. The group will be displayed as
        # cn|mail|status, where cn, mail and status will be replaced by their
        # values.
        #ldapGroupAttributeNameSearch => ['cn'],

        # CUSTOM FUNCTION
        # If you want to create customFunctions in rules, declare them here:
        #customFunctions    => 'function1 function2',
        #customFunctions    => 'Package::func1 Package::func2',

        # NOTIFICATIONS SERVICE
        # Use it to be able to notify messages during authentication
        #notification => 1,
        # Note that the SOAP function newNotification will be activated on
        # http://auth.example.com/index.pl/notification
        # If you want to hide this, just protect "/index.pl/notification" in
        # your Apache configuration file

        # CROSS-DOMAIN
        # If you have some handlers that are not registered on the main domain,
        # uncomment this
        #cda => 1,

        # XSS protection bypass
        # By default, the portal refuse redirections that comes from sites not
        # registered in the configuration (manager) except for those coming
        # from trusted domains. By default, trustedDomains contains the domain
        # declared in the manager. You can set trustedDomains to empty value so
        # that, undeclared sites will be rejected. You can also set here a list
        # of trusted domains or hosts separated by spaces. This is usefull if
        # your website use Lemonldap::NG without handler with SOAP functions.
        # Exemples :
        #trustedDomains => 'my.trusted.host example2.com',
        #trustedDomains => '',

        # OTHERS
        # You can also overload any parameter issued from manager
        # configuration. Example:
        #globalStorage => 'Apache::Session::File',
        #globalStorageOptions => {
        #  'Directory' => '/var/lib/lemonldap-ng/sessions/',
        #  'LockDirectory' => '/var/lib/lemonldap-ng/sessions/lock/',
        #},
        # Note that YOU HAVE TO SET globalStorage here if you've declared this
        # portal as SOAP session server in the manager
        #},
    }
);

# Get skin value
my $skin = $portal->{portalSkin};

my ( $skinfile, %templateParams );

# 1. Case well authenticated
if ( $portal->process() ) {

    # Case : there is a message to display
    if ( my $info = $portal->info() ) {
        $skinfile       = 'info.tpl';
        %templateParams = (
            AUTH_ERROR_TYPE => $portal->error_type,
            MSG             => $info,
            SKIN            => $skin,
            URL             => $portal->{urldc},
        );
    }

    # Case : display menu
    else {
        $skinfile = 'menu.tpl';

    # Menu creation
    use Lemonldap::NG::Portal::Menu;
    my $menu = Lemonldap::NG::Portal::Menu->new(
        {
            portalObject => $portal,
            apps         => {
                xmlfile => "$appsxmlfile",
                imgpath => "$appsimgpath",
            },
            modules => {
                appslist => $portal->{portalDisplayAppslist},
                password => $portal->{portalDisplayChangePassword},
                logout   => $portal->{portalDisplayLogout},
            },
        }
    );
        %templateParams = (
            AUTH_USER => $portal->{sessionInfo}->{ $portal->{portalUserAttr} },
            AUTOCOMPLETE        => $portal->{portalAutocomplete},
            SKIN                => $skin,
            AUTH_ERROR          => $menu->error,
            AUTH_ERROR_TYPE     => $menu->error_type,
            DISPLAY_APPSLIST    => $menu->displayModule("appslist"),
            DISPLAY_PASSWORD    => $menu->displayModule("password"),
            DISPLAY_LOGOUT      => $menu->displayModule("logout"),
            DISPLAY_TAB         => $menu->displayTab,
            LOGOUT_URL          => "$ENV{SCRIPT_NAME}?logout=1",
            REQUIRE_OLDPASSWORD => $portal->{portalRequireOldPassword},
            (
                $menu->displayModule("appslist")
                ? (
                    APPSLIST_MENU => $menu->appslistMenu,
                    APPSLIST_DESC => $menu->appslistDescription
                  )
                : ()
            )
        );
    }
}
elsif ( my $notif = $portal->notification ) {
    $skinfile       = 'notification.tpl';
    %templateParams = (
        AUTH_ERROR_TYPE => $portal->error_type,
        NOTIFICATION    => $notif,
        SKIN            => $skin,
    );
}
elsif ( $portal->{error} == PE_CONFIRM ) {
    $skinfile       = 'confirm.tpl';
    %templateParams = (
        AUTH_ERROR      => $portal->error,
        AUTH_ERROR_TYPE => $portal->error_type,
        AUTH_URL        => $portal->get_url,
        MSG             => $portal->info(),
        SKIN            => $skin,
    );
}
else {
    $skinfile       = 'login.tpl';
    %templateParams = (
        AUTH_ERROR            => $portal->error,
        AUTH_ERROR_TYPE       => $portal->error_type,
        AUTH_URL              => $portal->get_url,
        LOGIN                 => $portal->get_user,
        AUTOCOMPLETE          => $portal->{portalAutocomplete},
        SKIN                  => $skin,
        DISPLAY_RESETPASSWORD => $portal->{portalDisplayResetPassword},
        DISPLAY_FORM          => 1,

    # Adapt template if password policy error
        (
        $portal->{portalDisplayChangePassword}
              and ($portal->{error} == PE_PP_CHANGE_AFTER_RESET
            or $portal->{error} == PE_PP_MUST_SUPPLY_OLD_PASSWORD
            or $portal->{error} == PE_PP_INSUFFICIENT_PASSWORD_QUALITY
            or $portal->{error} == PE_PP_PASSWORD_TOO_SHORT
            or $portal->{error} == PE_PP_PASSWORD_TOO_YOUNG
            or $portal->{error} == PE_PP_PASSWORD_IN_HISTORY
            or $portal->{error} == PE_PASSWORD_MISMATCH
            or $portal->{error} == PE_BADOLDPASSWORD )
            ?

              (
                REQUIRE_OLDPASSWORD   => 1,
                DISPLAY_PASSWORD      => 1,
                DISPLAY_RESETPASSWORD => 0,
                DISPLAY_FORM          => 0
      )
            : ()
        ),

    # Adapt template if external authentication error
        (
            $portal->{error} == PE_BADCERTIFICATE
        or $portal->{error} == PE_CERTIFICATEREQUIRED
              or $portal->{error} == PE_ERROR
            ? (
                DISPLAY_RESETPASSWORD => 0,
                DISPLAY_FORM          => 0,
              )
            : ()
        )
    );
}

my $template = HTML::Template->new(
    filename          => "$skin_dir/$skin/$skinfile",
    die_on_bad_params => 0,
    cache             => 0,
    filter            => sub { $portal->translate_template(@_) }
);

while ( my ( $k, $v ) = each %templateParams ) {
    $template->param( $k, $v );
}

print $portal->header('text/html; charset=utf-8');
print $template->output;

