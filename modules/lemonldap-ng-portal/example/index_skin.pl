#!/usr/bin/perl

use Lemonldap::NG::Portal::SharedConf;
use HTML::Template;
use strict;

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
    }
);

# Get skin value
my $skin     = $portal->{portalSkin};
my $skin_dir = $ENV{DOCUMENT_ROOT} . "/skins";
my ( $skinfile, %templateParams );

####################
# QUERY PROCESSING #
####################

# I - GOOD AUTHENTICATION

if ( $portal->process() ) {

    # 1.1 Image mode
    if ( $portal->{error} == PE_IMG_OK || $portal->{error} == PE_IMG_NOK ) {
        $skinfile = "$skin_dir/common/"
          . (
            $portal->{error} == PE_IMG_OK
            ? 'ok.png'
            : 'warning.png'
          );
        $portal->printImage( $skinfile, 'image/png' );
        exit;
    }

    # 1.2 Case : there is a message to display
    elsif ( my $info = $portal->info() ) {
        $skinfile       = 'info.tpl';
        %templateParams = (
            AUTH_ERROR_TYPE => $portal->error_type,
            MSG             => $info,
            SKIN            => $skin,
            URL             => $portal->{urldc},
            HIDDEN_INPUTS   => $portal->buildHiddenForm(),
            ACTIVE_TIMER    => $portal->{activeTimer},
            FORM_METHOD     => $portal->{infoFormMethod},
        );
    }

    # 1.3 Case : display menu
    else {
        $skinfile = 'menu.tpl';

        # Menu creation
        use Lemonldap::NG::Portal::Menu;
        my $menu = Lemonldap::NG::Portal::Menu->new(
            {
                portalObject => $portal,
                modules      => {
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
            AUTH_ERROR          => $portal->error,
            AUTH_ERROR_TYPE     => $portal->error_type,
            DISPLAY_APPSLIST    => $menu->displayModule("appslist"),
            DISPLAY_PASSWORD    => $menu->displayModule("password"),
            DISPLAY_LOGOUT      => $menu->displayModule("logout"),
            DISPLAY_TAB         => $menu->displayTab,
            LOGOUT_URL          => "$ENV{SCRIPT_NAME}?logout=1",
            REQUIRE_OLDPASSWORD => $portal->{portalRequireOldPassword},
        );

        if ( $menu->displayModule("appslist") ) {
            %templateParams = (
                %templateParams,
                APPSLIST_MENU => $menu->appslistMenu,
                APPSLIST_DESC => $menu->appslistDescription
            );
        }
    }
}

# II - USER NOT AUTHENTICATED

# 2.1 A notification has to be done (session is created but hidden and unusable
#     until the user has accept the message)
elsif ( my $notif = $portal->notification ) {
    $skinfile       = 'notification.tpl';
    %templateParams = (
        AUTH_ERROR_TYPE => $portal->error_type,
        NOTIFICATION    => $notif,
        SKIN            => $skin,
        HIDDEN_INPUTS   => $portal->buildHiddenForm(),
    );
}

# 2.2 An authentication (or userDB) module needs to ask a question
#     before processing to the request
elsif ( $portal->{error} == PE_CONFIRM ) {
    $skinfile       = 'confirm.tpl';
    %templateParams = (
        AUTH_ERROR      => $portal->error,
        AUTH_ERROR_TYPE => $portal->error_type,
        URL             => $portal->get_url,
        MSG             => $portal->info(),
        SKIN            => $skin,
        HIDDEN_INPUTS   => $portal->buildHiddenForm(),
        ACTIVE_TIMER    => $portal->{activeTimer},
        FORM_METHOD     => $portal->{confirmFormMethod},
    );
}

# 2.3 There is a message to display
elsif ( my $info = $portal->info() ) {
    $skinfile       = 'info.tpl';
    %templateParams = (
        AUTH_ERROR      => $portal->error,
        AUTH_ERROR_TYPE => $portal->error_type,
        MSG             => $info,
        SKIN            => $skin,
        URL             => $portal->{urldc},
        HIDDEN_INPUTS   => $portal->buildHiddenForm(),
        ACTIVE_TIMER    => $portal->{activeTimer},
        FORM_METHOD     => $portal->{infoFormMethod},
    );
}

# 2.4 OpenID menu page
elsif ( $portal->{error} == PE_OPENID_EMPTY ) {
    $skinfile       = 'openid.tpl';
    my $p = $portal->{portal}.$portal->{issuerDBOpenIDPath};
    $p =~ s#(?<!:)/\^?/#/#g;
    %templateParams = (
        SKIN            => $skin,
        PROVIDERURI => $p,
    );
}

# 2.5 Authentication has been refused OR this is the first access
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
        MAIL_URL              => $portal->{mailUrl},
        HIDDEN_INPUTS         => $portal->buildHiddenForm(),
        LOGIN_INFO            => $portal->loginInfo(),
    );

    # Adapt template if password policy error
    if (
        $portal->{portalDisplayChangePassword}
        and (  $portal->{error} == PE_PP_CHANGE_AFTER_RESET
            or $portal->{error} == PE_PP_MUST_SUPPLY_OLD_PASSWORD
            or $portal->{error} == PE_PP_INSUFFICIENT_PASSWORD_QUALITY
            or $portal->{error} == PE_PP_PASSWORD_TOO_SHORT
            or $portal->{error} == PE_PP_PASSWORD_TOO_YOUNG
            or $portal->{error} == PE_PP_PASSWORD_IN_HISTORY
            or $portal->{error} == PE_PASSWORD_MISMATCH
            or $portal->{error} == PE_BADOLDPASSWORD )
      )
    {
        %templateParams = (
            %templateParams,
            REQUIRE_OLDPASSWORD   => 1,
            DISPLAY_PASSWORD      => 1,
            DISPLAY_RESETPASSWORD => 0,
            DISPLAY_FORM          => 0
        );
    }

    # Adapt template for OpenID
    if ( $portal->get_module("auth") =~ /openid/i ) {
        %templateParams = (
            %templateParams,
            DISPLAY_RESETPASSWORD => 0,
            DISPLAY_FORM          => 0,
            DISPLAY_OPENID_FORM   => 1,
        );
    }

    # Adapt template if external authentication error
    # or logout is OK
    if (   $portal->{error} == PE_BADCERTIFICATE
        or $portal->{error} == PE_CERTIFICATEREQUIRED
        or $portal->{error} == PE_ERROR
        or $portal->{error} == PE_SAML_ERROR
        or $portal->{error} == PE_SAML_LOAD_SERVICE_ERROR
        or $portal->{error} == PE_SAML_LOAD_IDP_ERROR
        or $portal->{error} == PE_SAML_SSO_ERROR
        or $portal->{error} == PE_SAML_UNKNOWN_ENTITY
        or $portal->{error} == PE_SAML_DESTINATION_ERROR
        or $portal->{error} == PE_SAML_CONDITIONS_ERROR
        or $portal->{error} == PE_SAML_IDPSSOINITIATED_NOTALLOWED
        or $portal->{error} == PE_SAML_SLO_ERROR
        or $portal->{error} == PE_SAML_SIGNATURE_ERROR
        or $portal->{error} == PE_SAML_ART_ERROR
        or $portal->{error} == PE_SAML_SESSION_ERROR
        or $portal->{error} == PE_SAML_LOAD_SP_ERROR
        or $portal->{error} == PE_SAML_ATTR_ERROR
        or $portal->{error} == PE_LOGOUT_OK )
    {
        %templateParams = (
            %templateParams,
            DISPLAY_RESETPASSWORD => 0,
            DISPLAY_FORM          => 0,
            DISPLAY_OPENID_FORM   => 0,
            PORTAL_URL            => $portal->{portal},
            MSG                   => $portal->info(),
        );
    }
}

# HTML template creation
my $template = HTML::Template->new(
    filename          => "$skin_dir/$skin/$skinfile",
    die_on_bad_params => 0,
    cache             => 0,
    filter            => sub { $portal->translate_template(@_) }
);

# Give parameters to the template
while ( my ( $k, $v ) = each %templateParams ) {
    $template->param( $k, $v );
}

# Display it
print $portal->header('text/html; charset=utf-8');
print $template->output;

