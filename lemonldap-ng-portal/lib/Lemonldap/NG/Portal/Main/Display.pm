## @file
# Display functions for LemonLDAP::NG Portal
package Lemonldap::NG::Portal::Main::Display;

our $VERSION = '2.0.0';

package Lemonldap::NG::Portal::Main;
use strict;

has skinRules => ( is => 'rw' );

sub displayInit {
    my ($self) = @_;
    $self->skinRules( [] );
    if ( $self->conf->{portalSkinRules} ) {
        foreach my $skinRule ( sort keys %{ $self->conf->{portalSkinRules} } ) {
            my $sub = HANDLER->buildSub( HANDLER->substitute($skinRule) );
            if ($sub) {
                push @{ $self->skinRules },
                  [ $self->conf->{portalSkinRules}->{$skinRule}, $sub ];
            }
            else {
                $self->lmLog(
                    qq(Skin rule "$skinRule" returns an error: )
                      . HANDLER->tsv->{jail}->error,
                    'error'
                );
            }
        }
    }
}

# Call portal process and set template parameters
# @return template name and template parameters
sub display {
    my ( $self, $req ) = @_;

    my $skin_dir = $self->conf->{templatesDir};
    my ( $skinfile, %templateParams );

    # 0. Display error page
    if ( my $http_error = $req->param('lmError') ) {

        $skinfile = 'error';

        # Check URL
        $self->controlUrl($req);

        %templateParams = (
            PORTAL_URL => $self->conf->{portal},
            LOGOUT_URL => $self->conf->{portal} . "?logout=1",
            URL        => $req->{urldc},
        );

        # Error code
        foreach ( 403, 500, 503 ) {
            $templateParams{"ERROR$_"} = ( $http_error == $_ ? 1 : 0 );
        }

    }

    # 1. Authentication not complete

    # 1.1 A notification has to be done (session is created but hidden and
    #     unusable until the user has accept the message)
    if ( my $notif = $req->datas->{notification} ) {
        $skinfile       = 'notification';
        %templateParams = (
            AUTH_ERROR_TYPE => $req->error_type,
            NOTIFICATION    => $notif,
            HIDDEN_INPUTS   => $self->buildHiddenForm($req),
            AUTH_URL        => $req->{datas}->{_url},
            CHOICE_PARAM    => $self->conf->{authChoiceParam},
            CHOICE_VALUE    => $req->datas->{_authChoice},
        );
    }

    # 1.2 An authentication (or userDB) module needs to ask a question
    #     before processing to the request
    elsif ( $req->{error} == PE_CONFIRM ) {
        $skinfile       = 'confirm';
        %templateParams = (
            AUTH_ERROR      => $req->error,
            AUTH_ERROR_TYPE => $req->error_type,
            AUTH_URL        => $req->{datas}->{_url},
            MSG             => $req->info,
            HIDDEN_INPUTS   => $self->buildHiddenForm($req),
            ACTIVE_TIMER    => $req->datas->{activeTimer},
            FORM_METHOD     => $self->conf->{confirmFormMethod},
            CHOICE_PARAM    => $self->conf->{authChoiceParam},
            CHOICE_VALUE    => $req->datas->{_authChoice},
            CHECK_LOGINS    => $self->conf->{portalCheckLogins}
              && $req->datas->{login},
            ASK_LOGINS => $req->datas->{checkLogins},
            CONFIRMKEY => $self->stamp(),
            LIST       => $req->datas->{list} || [],
            REMEMBER   => $req->datas->{confirmRemember},
        );
    }

    # 1.3 There is a message to display
    elsif ( my $info = $req->info ) {
        $skinfile       = 'info';
        %templateParams = (
            AUTH_ERROR      => $self->error,
            AUTH_ERROR_TYPE => $req->error_type,
            MSG             => $info,
            URL             => $req->{urldc},
            HIDDEN_INPUTS   => $self->buildHiddenForm($req),
            ACTIVE_TIMER    => $req->datas->{activeTimer},
            FORM_METHOD     => $self->conf->{infoFormMethod},
            CHOICE_PARAM    => $self->conf->{authChoiceParam},
            CHOICE_VALUE    => $req->datas->{_authChoice},
        );
    }

    # 1.4 OpenID menu page
    elsif ($req->{error} == PE_OPENID_EMPTY
        or $req->{error} == PE_OPENID_BADID )
    {
        $skinfile = 'openid';
        my $p = $self->conf->{portal} . $self->conf->{issuerDBOpenIDPath};
        $p =~ s#(?<!:)/?\^?/#/#g;
        my $id = $req->{sessionInfo}
          ->{ $self->conf->{openIdAttr} || $self->conf->{whatToTrace} };
        %templateParams = (
            AUTH_ERROR      => $self->error,
            AUTH_ERROR_TYPE => $req->error_type,
            PROVIDERURI     => $p,
            PORTAL_URL      => $self->conf->{portal},
            MSG             => $req->info(),
        );
        $templateParams{ID} = $req->datas->{_openidPortal} . $id if ($id);
    }

    # 2. Good authentication

    # 2.1 Redirection
    elsif ( $req->{error} == PE_REDIRECT ) {
        $skinfile       = "redirect";
        %templateParams = (
            URL           => $req->{urldc},
            HIDDEN_INPUTS => $self->buildHiddenForm($req),
            FORM_METHOD   => $req->datas->{redirectFormMethod} || 'get',
        );
    }

    # 2.2 Case : display menu
    elsif ( $req->error == PE_OK ) {

        $skinfile = 'menu';

        #utf8::decode($auth_user);

        %templateParams = (
            AUTH_USER => $req->{sessionInfo}->{ $self->conf->{portalUserAttr} },
            NEWWINDOW => $self->conf->{portalOpenLinkInNewWindow},
            LOGOUT_URL     => $self->conf->{portal} . "?logout=1",
            APPSLIST_ORDER => $req->{sessionInfo}->{'appsListOrder'},
            PING           => $self->conf->{portalPingInterval},
            $self->menu->params($req),
        );
    }

    # 3 Authentication has been refused OR this is the first access
    else {
        $skinfile = 'login';
        my $login = $self->userId($req);
        $login = '' if ( $login eq 'anonymous' );
        %templateParams = (
            AUTH_ERROR            => $req->error,
            AUTH_ERROR_TYPE       => $req->error_type,
            AUTH_URL              => $req->{datas}->{_url},
            LOGIN                 => $login,
            CHECK_LOGINS          => $self->conf->{portalCheckLogins},
            ASK_LOGINS            => $self->conf->{checkLogins},
            DISPLAY_RESETPASSWORD => $self->conf->{portalDisplayResetPassword},
            DISPLAY_REGISTER      => $self->conf->{portalDisplayRegister},
            MAIL_URL              => $self->conf->{mailUrl},
            REGISTER_URL          => $self->conf->{registerUrl},
            HIDDEN_INPUTS         => $self->buildHiddenForm($req),
        );

        # Display captcha if it's enabled
        if ( $req->captcha ) {
            %templateParams = (
                %templateParams,
                CAPTCHA_SRC  => $req->captcha,
                CAPTCHA_SIZE => $self->{conf}->{captcha_size} || 6
            );
        }
        if ( $req->token ) {
            %templateParams = (
                %templateParams,
                TOKEN  => $req->token,
            );
        }

        # Show password form if password policy error
        if (

               $req->{error} == PE_PP_CHANGE_AFTER_RESET
            or $req->{error} == PE_PP_MUST_SUPPLY_OLD_PASSWORD
            or $req->{error} == PE_PP_INSUFFICIENT_PASSWORD_QUALITY
            or $req->{error} == PE_PP_PASSWORD_TOO_SHORT
            or $req->{error} == PE_PP_PASSWORD_TOO_YOUNG
            or $req->{error} == PE_PP_PASSWORD_IN_HISTORY
            or $req->{error} == PE_PASSWORD_MISMATCH
            or $req->{error} == PE_BADOLDPASSWORD
            or $req->{error} == PE_PASSWORDFORMEMPTY
            or (    $req->{error} == PE_PP_PASSWORD_EXPIRED
                and $self->conf->{ldapAllowResetExpiredPassword} )
          )
        {
            %templateParams = (
                %templateParams,
                REQUIRE_OLDPASSWORD =>
                  1,    # Old password is required to check user credentials
                DISPLAY_FORM          => 0,
                DISPLAY_OPENID_FORM   => 0,
                DISPLAY_YUBIKEY_FORM  => 0,
                DISPLAY_PASSWORD      => 1,
                DISPLAY_RESETPASSWORD => 0,
                AUTH_LOOP             => [],
                CHOICE_PARAM          => $self->conf->{authChoiceParam},
                CHOICE_VALUE          => $req->datas->{_authChoice},
                OLDPASSWORD           => $self->checkXSSAttack( 'oldpassword',
                    $req->datas->{oldpassword} )
                ? ""
                : $req->datas->{oldpassword},
                HIDE_OLDPASSWORD => $self->conf->{hideOldPassword},
            );
        }

        # Disable all forms on:
        # * Logout message
        # * Bad URL error
        elsif ($req->{error} == PE_LOGOUT_OK
            or $req->{error} == PE_BADURL )
        {
            %templateParams = (
                %templateParams,
                DISPLAY_RESETPASSWORD => 0,
                DISPLAY_FORM          => 0,
                DISPLAY_OPENID_FORM   => 0,
                DISPLAY_YUBIKEY_FORM  => 0,
                AUTH_LOOP             => [],
                PORTAL_URL            => $self->conf->{portal},
                MSG                   => $req->info(),
            );

        }

        # Display authentication form
        else {

            # Authentication loop
            if ( $req->sessionInfo->{_choice}
                and my $authLoop = $self->_buildAuthLoop($req) )
            {
                %templateParams = (
                    %templateParams,
                    AUTH_LOOP            => $authLoop,
                    CHOICE_PARAM         => $self->conf->{authChoiceParam},
                    CHOICE_VALUE         => $req->datas->{_authChoice},
                    DISPLAY_FORM         => 0,
                    DISPLAY_OPENID_FORM  => 0,
                    DISPLAY_YUBIKEY_FORM => 0,
                );
            }

            # Choose what form to display if not in a loop
            else {

                my $displayType = $self->_authentication->getDisplayType($req);

                $self->lmLog( "Display type $displayType ", 'debug' );

                %templateParams = (
                    %templateParams,
                    DISPLAY_FORM => $displayType eq "standardform" ? 1 : 0,
                    DISPLAY_OPENID_FORM => $displayType eq "openidform" ? 1 : 0,
                    DISPLAY_YUBIKEY_FORM => $displayType eq "yubikeyform" ? 1
                    : 0,
                    DISPLAY_LOGO_FORM => $displayType eq "logo" ? 1 : 0,
                    module => $displayType eq "logo"
                    ? $self->getModule( $req, 'auth' )
                    : "",
                    AUTH_LOOP => [],
                    PORTAL_URL =>
                      ( $displayType eq "logo" ? $self->conf->{portal} : 0 ),
                    MSG => $req->info(),
                );

            }

        }

    }

    ## Common template params
    my $skin       = $self->getSkin($req);
    my $portalPath = $self->conf->{portal};
    $portalPath =~ s#^https?://[^/]+/?#/#;
    $portalPath =~ s#[^/]+\.fcgi$##;
    %templateParams = (
        %templateParams,
        SKIN_PATH => $portalPath . "skins",
        SKIN      => $skin,
        ANTIFRAME => $self->conf->{portalAntiFrame},
        SKIN_BG   => $self->conf->{portalSkinBackground},
        %{ $self->customParameters },
        %{ $req->{customParameters} // {} },
    );

    ## Custom template params
    if ( my $customParams = $self->getCustomTemplateParameters() ) {
        %templateParams = ( %templateParams, %$customParams );
    }

    $self->lmLog( "Skin returned: $skinfile", 'debug' );
    return ( $skinfile, \%templateParams );
}

##@method public void printImage(string file, string type)
# Print image to STDOUT
# @param $file The path to the file to print
# @param $type The content-type to use (ie: image/png)
# @return void
sub staticFile {
    my ( $self, $req, $file, $type ) = @_;
    require Plack::Util;
    require Cwd;
    require HTTP::Date;
    open my $fh, '<:raw', $self->conf->{templatesDir} . "/$file"
      or return $self->sendError( $req, $!, 403 );
    my @stat = stat $file;
    Plack::Util::set_io_path( $fh, Cwd::realpath($file) );
    return [
        200,
        [
            'Content-Type'   => $type,
            'Content-Length' => $stat[7],
            'Last-Modified'  => HTTP::Date::time2str( $stat[9] )
        ],
        $fh,
    ];
}

sub buildHiddenForm {
    my ( $self, $req ) = @_;
    my @keys = keys %{ $req->{portalHiddenFormValues} };
    my $val  = '';

    foreach (@keys) {

        # Check XSS attacks
        next
          if $self->checkXSSAttack( $_, $req->{portalHiddenFormValues}->{$_} );

        # Build hidden input HTML code
        $val .= qq{<input type="hidden" name="$_" id="$_" value="}
          . $req->{portalHiddenFormValues}->{$_} . '" />';
    }

    return $val;
}

# Return skin name
# @return skin name
# TODO: create property for skinRule
sub getSkin {
    my ( $self, $req ) = @_;

    my $skin = $self->conf->{portalSkin};

    # Fill sessionInfo to eval rule if empty (unauthenticated user)
    $req->{sessionInfo}->{_url}   ||= $req->{urldc};
    $req->{sessionInfo}->{ipAddr} ||= $req->address;

    # Load specific skin from skinRules
    foreach my $rule ( @{ $self->conf->{skinRules} } ) {
        if ( $rule->[1]->( $req->sessionInfo ) ) {
            $skin = $rule->[0];
            $self->lmLog( "Skin $skin selected from skin rule", 'debug' );
        }
    }

    # Check skin GET/POST parameter
    my $skinParam = $req->param('skin');
    if ( defined $skinParam && !$self->checkXSSAttack( 'skin', $skinParam ) ) {
        $skin = $skinParam;
        $self->lmLog( "Skin $skin selected from GET/POST parameter", 'debug' );
    }

    return $skin;
}

# Find custom templates parameters
# @return Custom parameters
sub getCustomTemplateParameters {
    my ($self)          = @_;
    my $conf            = $self->conf;
    my $customTplParams = {};

    foreach ( keys %$conf ) {
        next unless ( $_ =~ /^tpl_(.+)$/ );
        my $tplParam = $1;
        my $tplValue = $conf->{$_};
        $self->lmLog( "Set custom template parameter $tplParam with $tplValue",
            'debug' );

        $customTplParams->{$tplParam} = $tplValue;
    }

    return $customTplParams;
}

# Build an HTML array to display sessions
# @param $sessions Array ref of hash ref containing sessions datas
# @param $title Title of the array
# @param $displayUser To display "User" column
# @param $displaError To display "Error" column
# @return HTML string
sub mkSessionArray {
    my ( $self, $sessions, $title, $displayUser, $displayError ) = @_;

    return "" unless ( ref $sessions eq "ARRAY" and @$sessions );

    my $tmp = $title ? "<h3>$title</h3>" : "";
    $tmp .=
        '<table class="info"><tbody><tr>'
      . ( $displayUser ? '<th trspan="user">User</th>' : '' )
      . '<th trspan="date">Date</th><th trspan="ipAddr">IP address</th>';
    $tmp .= "<th>" . $self->conf->{sessionDataToRemember}->{$_} . "</th>"
      foreach ( keys %{ $self->conf->{sessionDataToRemember} } );
    $tmp .= '<th trspan="errorMsg">Error message</th>'
      if ($displayError);
    $tmp .= '</tr>';

    foreach my $session (@$sessions) {
        $tmp .= "<tr>"
        .($displayUser ? "<td>$session->{user}</td>" : '')
        . qq'<td class="localeDate" val="$session->{_utime}"></td>'
        . "<td>$session->{ipAddr}</td>";
        $tmp .= "<td>" . ( $session->{$_} || "" ) . "</td>"
          foreach ( keys %{ $self->conf->{sessionDataToRemember} } );
        $tmp .= "<td>$session->{error}</td>" if ($displayError);
        $tmp .= "</tr>";
    }
    $tmp .= '</tbody></table>';
    return $tmp;
}

1;
