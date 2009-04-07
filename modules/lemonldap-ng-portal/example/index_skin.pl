#!/usr/bin/perl

use Lemonldap::NG::Portal::SharedConf;
use HTML::Template;

# Path configuration
my $skin        = "pastel";
my $skin_dir    = "__SKINDIR__";
my $appsxmlfile = "__APPSXMLFILE__";
my $appsimgpath = "apps/";

# Password management
use constant USER_CAN_CHANGE_PASSWORD => 1;
use constant REQUIRE_OLDPASSWORD      => 1;

# Logout displayed
use constant DISPLAY_LOGOUT => 1;

my $portal = Lemonldap::NG::Portal::SharedConf->new(
    {

        # ACCESS TO CONFIGURATION

        # By default, Lemonldap::NG uses the default storage.conf file to know
        # where to find its configuration
        # (generaly /etc/lemonldap-ng/storage.conf)
        # You can specify by yourself this file :
        #configStorage => { File => '/path/to/my/file' },
        # or set explicitely parameters :
        #configStorage => {
        #  Type => 'File',
        #  dirName => '/path/to/config/dir/'
        #},
        # Note that YOU HAVE TO SET configStorage here if you've declared this
        # portal as SOAP configuration server in the manager

        # You can also specify directly the configuration
        # (see Lemonldap::NG::Handler::SharedConf(3))
        #configStorage => {
        #      type => 'File',
        #      directory => '/usr/local/lemonlda-ng/conf/'
        #},

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

        # OTHERS
        # You can also overload any parameter issued from manager
        # configuration. Example:
        #globalStorage => 'Apache::Session::File',
        #globalStorageOptions => {
        #  'Directory' => '/var/lib/lemonldap-ng/sessions/'
        #  'LockDirectory' => '/var/lib/lemonldap-ng/sessions/lock/'
        #}
        # Note that YOU HAVE TO SET globalStorage here if you've declared this
        # portal as SOAP session server in the manager
        #},
    }
);

if ( $portal->process() ) {

    # HTML::Template object creation
    my $template = HTML::Template->new(
        filename          => "$skin_dir/$skin/menu.tpl",
        die_on_bad_params => 0,
        cache             => 0,
        filter            => sub { $portal->translate_template(@_) }
    );

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
                appslist => 1,
                password => USER_CAN_CHANGE_PASSWORD,
                logout   => DISPLAY_LOGOUT,
            },
            # CUSTOM FUNCTION : if you want to create customFunctions in rules, declare them here
            #customFunctions    => 'function1 function2',
        }
    );

    $template->param( AUTH_ERROR          => $menu->error );
    $template->param( AUTH_ERROR_TYPE     => $menu->error_type );
    $template->param( DISPLAY_APPSLIST    => $menu->displayModule("appslist") );
    $template->param( DISPLAY_PASSWORD    => $menu->displayModule("password") );
    $template->param( DISPLAY_LOGOUT      => $menu->displayModule("logout") );
    $template->param( DISPLAY_TAB         => $menu->displayTab );
    $template->param( LOGOUT_URL          => "$ENV{SCRIPT_NAME}?logout=1" );
    $template->param( REQUIRE_OLDPASSWORD => REQUIRE_OLDPASSWORD );
    if ( $menu->displayModule("appslist") ) {
        $template->param( APPSLIST_MENU => $menu->appslistMenu );
        $template->param( APPSLIST_DESC => $menu->appslistDescription );
    }

    print $portal->header('text/html; charset=utf8');
    print $template->output;
}
elsif ( my $notif = $portal->notification ) {
    my $template = HTML::Template->new(
        filename          => "$skin_dir/$skin/notification.tpl",
        die_on_bad_params => 0,
        cache             => 0,
        filter            => sub { $portal->translate_template(@_) }
    );
    $template->param( AUTH_ERROR      => $portal->error );
    $template->param( AUTH_ERROR_TYPE => $portal->error_type );
    $template->param( NOTIFICATION    => $notif );
    print $portal->header('text/html; charset=utf8');
    print $template->output;
}
else {

    # HTML::Template object creation
    my $template = HTML::Template->new(
        filename          => "$skin_dir/$skin/login.tpl",
        die_on_bad_params => 0,
        cache             => 0,
        filter            => sub { $portal->translate_template(@_) }
    );

    $template->param( AUTH_ERROR      => $portal->error );
    $template->param( AUTH_ERROR_TYPE => $portal->error_type );
    $template->param( AUTH_URL        => $portal->get_url );
    if ( USER_CAN_CHANGE_PASSWORD
        and $portal->error == PE_PP_CHANGE_AFTER_RESET )
    {
        $template->param( REQUIRE_OLDPASSWORD => 1 );
        $template->param( DISPLAY_PASSWORD    => 1 );
    }
    else {
        $template->param( DISPLAY_FORM => 1 );
    }

    print $portal->header('text/html; charset=utf8');
    print $template->output;
}

