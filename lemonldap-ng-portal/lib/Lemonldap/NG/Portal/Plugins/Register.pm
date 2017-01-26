package Lemonldap::NG::Portal::Plugins::Register;

use strict;
use Encode;
use Mouse;
use POSIX qw(strftime);
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_BADMAILTOKEN
  PE_CAPTCHAEMPTY
  PE_CAPTCHAERROR
  PE_MALFORMEDUSER
  PE_MAILCONFIRMATION_ALREADY_SENT
  PE_MAILCONFIRMOK
  PE_MAILERROR
  PE_MAILOK
  PE_OK
  PE_REGISTERALREADYEXISTS
  PE_REGISTERFIRSTACCESS
  PE_REGISTERFORMEMPTY
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin',
  'Lemonldap::NG::Portal::Lib::SMTP';

# PROPERTIES

has registerModule => ( is => 'rw' );

has registerUrl => (
    is      => 'rw',
    default => sub {
        my $p = $_[0]->conf->{portal};
        $p =~ s#/*$##;
        return "$p/register";
    }
);

has ott => (
    is      => 'rw',
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->conf->{registerTimeout} )
          if ( $_[0]->conf->{registerTimeout} );
        return $ott;
    }
);

has captcha => ( is => 'rw' );

# INITIALIZATION

sub init {
    my ($self) = @_;

    # Declare REST route
    $self->addUnauthRoute( register => 'register', [ 'POST', 'GET' ] );

    # Initialize Captcha if needed
    if ( $self->conf->{captcha_register_enabled} ) {
        $self->captcha( $self->p->loadModule('::Lib::Captcha') ) or return 0;

        # TODO: timeout
        $self->captcha->timeout( $self->conf->{registerTimeout} );
    }

    # Load register module
    $self->registerModule(
        $self->p->loadPlugin( '::Register::' . $self->conf->{registerDB} ) )
      or return 0;

    # TODO: load module if != $self->p->authentication

    return 1;
}

# RUNNIG METHODS

sub register {
    my ( $self, $req ) = @_;
    $req->error( $self->_register($req) );
    my ( $tpl, $prms ) = $self->display($req);
    return $self->p->sendHtml( $req, $tpl, params => $prms );
}

sub _register {
    my ( $self, $req ) = @_;

    unless ( $req->param('mail') || $req->param('register_token') ) {
        return PE_REGISTERFIRSTACCESS if ( $req->method =~ /GET/ );
        return PE_REGISTERFORMEMPTY;
    }

    $req->datas->{register_token} = $req->param('register_token');

    # If a register token is present, find the corresponding info
    if ( $req->datas->{register_token} ) {

        $self->lmLog(
            "Token given for register: " . $req->datas->{register_token},
            'debug' );

        # Get the corresponding session
        if ( my $datas = $self->ott->getToken( $req->datas->{register_token} ) )
        {
            foreach (qw(mail firstname lastname ipAddr)) {
                $req->datas->{registerInfo}->{$_} = $datas->{$_};
            }
            $self->lmLog(
                "User associated to token: "
                  . $req->datas->{registerInfo}->{mail},
                'debug'
            );
        }
        else {
            return PE_BADMAILTOKEN;
        }
    }
    else {

        # Use submitted value
        $req->datas->{registerInfo}->{mail}      = $req->param('mail');
        $req->datas->{registerInfo}->{firstname} = $req->param('firstname');
        $req->datas->{registerInfo}->{lastname}  = $req->param('lastname');
        $req->datas->{registerInfo}->{ipAddr}    = $req->address;

        # Captcha for register form
        # Only if register session does not already exist
        # TODO captcha
        if (   $self->conf->{captcha_register_enabled}
            && $req->datas->{registerInfo}->{mail}
            && !$self->getRegisterSession( $req->datas->{registerInfo}->{mail} )
          )
        {
            $req->datas->{captcha} = $req->param('captcha');
            $req->datas->{token}   = $req->param('token');

            unless ( $req->datas->{captcha} and $req->datas->{token} ) {
                $self->lmLog( "Captcha not filled", 'warn' );
                return PE_CAPTCHAEMPTY;
            }

            # Check captcha
            unless (
                $self->captcha->validateCaptcha(
                    $req->datas->{token},
                    $req->datas->{captcha}
                )
              )
            {
                $self->p->userNotice('Captcha failed: wrong code');
                return PE_CAPTCHAERROR;
            }
            $self->lmLog( "Captcha code verified", 'debug' );
        }

    }

    # Check mail
    return PE_MALFORMEDUSER
      unless ( $req->datas->{registerInfo}->{mail} =~
        /$self->{conf}->{userControl}/o );

    # Search for user using UserDB module
    # If the user already exists, register is forbidden
    $req->datas->{mail} = $req->{registerInfo}->{mail};
    if ( $self->p->_userDB->getUser($req) == PE_OK ) {
        $self->lmLog(
"Register: refuse mail $req->{mail} because already exists in UserDB",
            'error'
        );
        return PE_REGISTERALREADYEXISTS;
    }
    my $register_session =
      $self->getRegisterSession( $req->datas->{registerInfo}->{mail} );
    $req->datas->{mail_already_sent} =
      ( $register_session and !$req->id ) ? 1 : 0;

    # Skip this step if confirmation was already sent
    unless ( $req->datas->{register_token} or $register_session ) {

        # Create token
        $register_session = $self->ott->createToken(
            {
                mail      => $req->datas->{registerInfo}->{mail},
                firstname => $req->datas->{registerInfo}->{firstname},
                lastname  => $req->datas->{registerInfo}->{lastname},
                ipAddr    => $req->datas->{registerInfo}->{ipAddr},
                _type     => 'register',
            }
        );
    }

    # Send confirmation mail

    # Skip this step if user clicked on the confirmation link
    unless ( $req->datas->{register_token} ) {

        # Check if confirmation mail has already been sent
        $self->lmLog( 'No register_token', 'debug' );

        # Read session to get creation and expiration dates
        $req->id($register_session) unless $req->id;

        $self->lmLog( "Register session found: $register_session", 'debug' );

        my $registerSessionObj = $self->p->getApacheSession($register_session);

        # Mail session expiration date
        my $expTimestamp =
          $self->{conf}->{registerTimeout} || $self->conf->{timeout} + time;

        $self->lmLog( "Register expiration timestamp: $expTimestamp", 'debug' );

        $req->datas->{expMailDate} =
          strftime( "%d/%m/%Y", localtime $expTimestamp );
        $req->datas->{expMailTime} =
          strftime( "%H:%M", localtime $expTimestamp );

        # Mail session start date
        my $startTimestamp = time;

        $self->lmLog( "Register start timestamp: $startTimestamp", 'debug' );

        $req->datas->{startMailDate} =
          strftime( "%d/%m/%Y", localtime $startTimestamp );
        $req->datas->{startMailTime} =
          strftime( "%H:%M", localtime $startTimestamp );

        # Ask if user want another confirmation email
        if ( $req->datas->{mail_already_sent}
            and !$req->param('resendconfirmation') )
        {
            return PE_MAILCONFIRMATION_ALREADY_SENT;
        }

        # Build confirmation url
        my $url = $self->registerUrl . "?register_token=" . $req->{id};
        $url .= '&skin=' . $self->p->getSkin($req);
        $url .= '&'
          . $self->conf->{authChoiceParam} . '='
          . $req->datas->{_authChoice}
          if ( $req->datas->{_authChoice} );

        # Build mail content
        my $subject = $self->conf->{registerConfirmSubject};
        my $body;
        my $html = 1;

        # Use HTML template
        my $tplfile =
            $self->conf->{templateDir} . '/'
          . $self->conf->{portalSkin}
          . '/mail_register_confirm.tpl';
        $tplfile =
          $self->conf->{templateDir} . '/common/mail_register_confirm.tpl'
          unless ( -e $tplfile );
        my $template = HTML::Template->new( filename => $tplfile, );
        $body = $template->output();

        # Replace variables in body
        $body =~ s/\$expMailDate/$req->datas->{expMailDate}/g;
        $body =~ s/\$expMailTime/$req->datas->{expMailTime}/g;
        $body =~ s/\$url/$url/g;
        $body =~ s/\$(\w+)/decode("utf8",$req->datas->{registerInfo}->{$1})/ge;

        # Send mail
        return PE_MAILERROR
          unless $self->send_mail( $req->datas->{registerInfo}->{mail},
            $subject, $body, $html );

        $self->lmLog( 'Register message sent', 'debug' );
        return PE_MAILCONFIRMOK;
    }

    # Generate a complex password
    my $password = $self->gen_password( $self->conf->{randomPasswordRegexp} );

    $self->lmLog( "Generated password: " . $password, 'debug' );

    $req->datas->{registerInfo}->{password} = $password;
    $req->datas->{forceReset} = 1;

    # Find a login
    my $result = $self->registerModule->computeLogin($req);
    unless ( $result == PE_OK ) {
        $self->lmLog(
            "Could not compute login for "
              . $req->datas->{registerInfo}->{mail},
            'error'
        );
        return $result;
    }

    # Create user
    $self->lmLog( 'Create new user ' . $req->datas->{registerInfo}->{login},
        'debug' );
    $result = $self->registerModule->createUser($req);
    unless ( $result == PE_OK ) {
        $self->lmLog(
            "Could not create user " . $req->datas->{registerInfo}->{login},
            'error' );
        return $result;
    }

    my $subject = $self->conf->{registerDoneSubject};
    my $body;
    my $html = 1;

    # Use HTML template
    my $tplfile =
        $self->conf->{templateDir} . '/'
      . $self->conf->{portalSkin}
      . "/mail_register_done.tpl";
    $tplfile = $self->conf->{templateDir} . "/common/mail_register_done.tpl"
      unless ( -e $tplfile );
    my $template = HTML::Template->new( filename => $tplfile, );
    $body = $template->output();

    # Replace variables in body
    $body =~ s/\$(\w+)/decode("utf8",$req->datas->{registerInfo}->{$1})/ge;

    # Send mail
    return PE_MAILERROR
      unless $self->send_mail( $req->datas->{registerInfo}->{mail},
        $subject, $body, $html );

    return PE_MAILOK;
}

sub display {
    my ( $self, $req ) = @_;
    my %templateParams = (
        PORTAL_URL      => $self->conf->{portal},
        SKIN_PATH       => '/static',
        SKIN            => $self->conf->{portalSkin},
        SKIN_BG         => $self->conf->{portalSkinBackground},
        AUTH_ERROR      => $req->error,
        AUTH_ERROR_TYPE => $req->error_type,
        CHOICE_PARAM    => $self->conf->{authChoiceParam},
        CHOICE_VALUE    => $req->datas->{_authChoice},
        EXPMAILDATE     => $req->datas->{expMailDate},
        EXPMAILTIME     => $req->datas->{expMailTime},
        STARTMAILDATE   => $req->datas->{startMailDate},
        STARTMAILTIME   => $req->datas->{startMailTime},
        MAILALREADYSENT => $req->datas->{mail_already_sent},
        MAIL            => $self->p->checkXSSAttack( 'mail',
            $req->datas->{registerInfo}->{mail} ) ? ""
        : $req->datas->{registerInfo}->{mail},
        FIRSTNAME => $self->p->checkXSSAttack( 'firstname',
            $req->datas->{registerInfo}->{firstname} ) ? ""
        : $req->datas->{registerInfo}->{firstname},
        LASTNAME => $self->p->checkXSSAttack( 'lastname',
            $req->datas->{registerInfo}->{lastname} ) ? ""
        : $req->datas->{registerInfo}->{lastname},
        REGISTER_TOKEN => $self->p->checkXSSAttack( 'register_token',
            $req->datas->{register_token} ) ? ""
        : $req->datas->{register_token},
    );

    # Display form the first time
    if (
        (
               $req->error == PE_REGISTERFORMEMPTY
            or $req->error == PE_REGISTERFIRSTACCESS
            or $req->error == PE_REGISTERALREADYEXISTS
            or $req->error == PE_CAPTCHAERROR
            or $req->error == PE_CAPTCHAEMPTY
        )
        and !$req->param('mail_token')
      )
    {
        %templateParams = (
            %templateParams,
            DISPLAY_FORM            => 1,
            DISPLAY_RESEND_FORM     => 0,
            DISPLAY_CONFIRMMAILSENT => 0,
            DISPLAY_MAILSENT        => 0,
            DISPLAY_PASSWORD_FORM   => 0,
        );
    }

    # Display captcha if it's enabled
    if ( $self->conf->{captcha_register_enabled} ) {
        %templateParams = (
            %templateParams,
            CAPTCHA_SRC => $req->captcha,
            TOKEN       => $req->token,
        );
    }

    # Display mail confirmation resent form
    if ( $req->{error} == PE_MAILCONFIRMATION_ALREADY_SENT ) {
        %templateParams = (
            %templateParams,
            DISPLAY_FORM            => 0,
            DISPLAY_RESEND_FORM     => 1,
            DISPLAY_CONFIRMMAILSENT => 0,
            DISPLAY_MAILSENT        => 0,
            DISPLAY_PASSWORD_FORM   => 0,
        );
    }

    # Display confirmation mail sent
    if ( $req->{error} == PE_MAILCONFIRMOK ) {
        %templateParams = (
            %templateParams,
            DISPLAY_FORM            => 0,
            DISPLAY_RESEND_FORM     => 0,
            DISPLAY_CONFIRMMAILSENT => 1,
            DISPLAY_MAILSENT        => 0,
            DISPLAY_PASSWORD_FORM   => 0,
        );
    }

    # Display mail sent
    if ( $req->{error} == PE_MAILOK ) {
        %templateParams = (
            %templateParams,
            DISPLAY_FORM            => 0,
            DISPLAY_RESEND_FORM     => 0,
            DISPLAY_CONFIRMMAILSENT => 0,
            DISPLAY_MAILSENT        => 1,
            DISPLAY_PASSWORD_FORM   => 0,
        );
    }

    # Display password change form
    if (    $req->param('mail_token')
        and $req->{error} != PE_MAILERROR
        and $req->{error} != PE_BADMAILTOKEN
        and $req->{error} != PE_MAILOK )
    {
        %templateParams = (
            %templateParams,
            DISPLAY_FORM            => 0,
            DISPLAY_RESEND_FORM     => 0,
            DISPLAY_CONFIRMMAILSENT => 0,
            DISPLAY_MAILSENT        => 0,
            DISPLAY_PASSWORD_FORM   => 1,
        );
    }
    return ( 'register', \%templateParams );
}

1;
