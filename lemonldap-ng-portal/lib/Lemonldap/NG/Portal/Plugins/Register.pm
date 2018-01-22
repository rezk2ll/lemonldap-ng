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
  PE_NOTOKEN
  PE_OK
  PE_REGISTERALREADYEXISTS
  PE_REGISTERFIRSTACCESS
  PE_REGISTERFORMEMPTY
  PE_TOKENEXPIRED
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin',
  'Lemonldap::NG::Portal::Lib::SMTP';

# PROPERTIES

# Sub module (Demo, LDAP,...)
has registerModule => ( is => 'rw' );

# Register url to set in the mail
has registerUrl => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $p = $_[0]->conf->{portal};
        $p =~ s#/*$##;
        return "$p/register";
    }
);

# Mail timeout token generator
has mailott => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->cache(0);
        $ott->timeout( $_[0]->conf->{registerTimeout}
              || $_[0]->conf->{timeout} );
        return $ott;
    }
);

# Form timout token generator (used if requireToken is set)
has ott => ( is => 'rw' );

# Captcha generator
has captcha => ( is => 'rw' );

# INITIALIZATION

sub init {
    my ($self) = @_;

    # Declare REST route
    $self->addUnauthRoute( register => 'register', [ 'POST', 'GET' ] );

    # Initialize Captcha if needed
    if ( $self->conf->{captcha_register_enabled} ) {
        $self->captcha( $self->p->loadModule('::Lib::Captcha') ) or return 0;
    }

    # Initialize form token if needed (captcha provides also a token)
    elsif ( $self->conf->{requireToken} ) {
        $_[0]->ott(
            $_[0]->p->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken') )
          or return 0;
        $_[0]->ott->timeout( $_[0]->conf->{formTimeout} );
    }

    # Load registered module
    $self->registerModule(
        $self->p->loadPlugin( '::Register::' . $self->conf->{registerDB} ) )
      or return 0;

    return 1;
}

# RUNNIG METHODS

# Handle register requests
sub register {
    my ( $self, $req ) = @_;

    $self->p->controlUrl($req);

    # Check parameters
    $req->error( $self->_register($req) );

    # Display form
    my ( $tpl, $prms ) = $self->display($req);
    return $self->p->sendHtml( $req, $tpl, params => $prms );
}

# Parameters check
sub _register {
    my ( $self, $req ) = @_;

    # Check if it's a first access
    unless ( ( $req->method =~ /^POST$/i and $req->param('mail') )
        or $req->param('register_token') )
    {

        # Set captcha or token
        $self->setSecurity($req);
        $self->logger->debug('First access to register form');
        return PE_REGISTERFIRSTACCESS if ( $req->method eq 'GET' );
        return PE_REGISTERFORMEMPTY;
    }

    # Get register token (mail link)
    $req->datas->{register_token} = $req->param('register_token');

    # If a register token is present, find the corresponding info
    if ( $req->datas->{register_token} ) {

        $self->logger->debug(
            "Token given for register: " . $req->datas->{register_token} );

        # Get the corresponding session
        if ( my $datas =
            $self->mailott->getToken( $req->datas->{register_token} ) )
        {
            $self->logger->debug(
                'Token ' . $req->datas->{register_token} . ' found' );
            foreach (qw(mail firstname lastname ipAddr)) {
                $req->datas->{registerInfo}->{$_} = $datas->{$_};
            }
            $self->logger->debug( "User associated to token: "
                  . $req->datas->{registerInfo}->{mail} );
        }
        else {
            return PE_BADMAILTOKEN;
        }
    }

    # Case else: user tries to register
    else {

        # Use submitted value
        $req->datas->{registerInfo}->{mail}      = $req->param('mail');
        $req->datas->{registerInfo}->{firstname} = $req->param('firstname');
        $req->datas->{registerInfo}->{lastname}  = $req->param('lastname');
        $req->datas->{registerInfo}->{ipAddr}    = $req->address;

        # Check captcha/token only if register session does not already exist
        if ( $req->datas->{registerInfo}->{mail}
            and
            !$self->getRegisterSession( $req->datas->{registerInfo}->{mail} ) )
        {
            # Check if token exists
            my $token;
            if ( $self->ott or $self->captcha ) {
                $token = $req->param('token');
                unless ($token) {
                    $self->setSecurity($req);
                    $self->userLogger->warn('Register try without token');
                    return PE_NOTOKEN;
                }
            }

            # Captcha for register form
            if ( $self->captcha ) {
                my $captcha = $req->param('captcha');

                unless ($captcha) {
                    $self->userLogger->warn(
                        'Register try with captcha not filled');

                    # Set captcha or token
                    $self->setSecurity($req);
                    return PE_CAPTCHAEMPTY;
                }

                # Check captcha
                unless ( $self->captcha->validateCaptcha( $token, $captcha ) ) {
                    $self->userLogger->info('Captcha failed: wrong code');

                    # Set captcha or token
                    $self->setSecurity($req);
                    return PE_CAPTCHAERROR;
                }
                $self->logger->debug("Captcha code verified");
            }
            elsif ( $self->ott ) {
                unless ( $self->ott->getToken($token) ) {
                    $self->setSecurity($req);
                    $self->userLogger->notice(
                        'Register try with expired/bad token');
                    return PE_TOKENEXPIRED;
                }
            }
        }
    }

    # Check mail
    return PE_MALFORMEDUSER
      unless ( $req->datas->{registerInfo}->{mail} =~
        m/$self->{conf}->{userControl}/o );

    # Search for user using UserDB module
    # If the user already exists, register is forbidden
    $req->user( $req->datas->{registerInfo}->{mail} );
    if ( $self->p->_userDB->getUser( $req, useMail => 1 ) == PE_OK ) {
        $self->userLogger->error(
"Register: refuse mail $req->{mail} because already exists in UserDB"
        );
        return PE_REGISTERALREADYEXISTS;
    }
    my $register_session =
      $self->getRegisterSession( $req->datas->{registerInfo}->{mail} );
    $req->datas->{mail_already_sent} =
      ( $register_session and !$req->id ) ? 1 : 0;

    # Skip this step if confirmation was already sent
    unless ( $req->datas->{register_token} or $register_session ) {

        # Create mail token
        $register_session = $self->mailott->createToken(
            {
                mail      => $req->datas->{registerInfo}->{mail},
                firstname => $req->datas->{registerInfo}->{firstname},
                lastname  => $req->datas->{registerInfo}->{lastname},
                ipAddr    => $req->datas->{registerInfo}->{ipAddr},
                _type     => 'register',
            }
        );
        $self->logger->debug("Token $register_session created");
    }

    # Send confirmation mail

    # Skip this step if user clicked on the confirmation link
    unless ( $req->datas->{register_token} ) {

        # Check if confirmation mail has already been sent
        $self->logger->debug('No register_token');

        # Read session to get creation and expiration dates
        $req->id($register_session) unless $req->id;

        $self->logger->debug("Register session found: $register_session");

        # Mail session expiration date
        my $expTimestamp =
          $self->{conf}->{registerTimeout} || $self->conf->{timeout} + time;

        $self->logger->debug("Register expiration timestamp: $expTimestamp");

        $req->datas->{expMailDate} =
          strftime( "%d/%m/%Y", localtime $expTimestamp );
        $req->datas->{expMailTime} =
          strftime( "%H:%M", localtime $expTimestamp );

        # Mail session start date
        my $startTimestamp = time;

        $self->logger->debug("Register start timestamp: $startTimestamp");

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
        $url .= '&url=' . $req->datas->{_url} if ( $req->datas->{_url} );

        # Build mail content
        my $tr      = $self->translate($req);
        my $subject = $self->conf->{registerConfirmSubject};
        unless ($subject) {
            $subject = 'registerConfirmSubject';
            $tr->( \$subject );
        }
        my $body;
        my $html = 1;

        # Use HTML template
        $body = $self->loadTemplate( 'mail_register_confirm', filter => $tr );

        # Replace variables in body
        $body =~ s/\$expMailDate/$req->datas->{expMailDate}/g;
        $body =~ s/\$expMailTime/$req->datas->{expMailTime}/g;
        $body =~ s/\$url/$url/g;
        $body =~ s/\$(\w+)/$req->datas->{registerInfo}->{$1}/eg;

        # Send mail
        return PE_MAILERROR
          unless $self->send_mail( $req->datas->{registerInfo}->{mail},
            $subject, $body, $html );

        $self->logger->debug('Register message sent');
        return PE_MAILCONFIRMOK;
    }

    # Generate a complex password
    my $password = $self->gen_password( $self->conf->{randomPasswordRegexp} );

    $self->logger->debug( "Generated password: " . $password );

    $req->datas->{registerInfo}->{password} = $password;
    $req->datas->{forceReset} = 1;

    # Find a login
    my $result = $self->registerModule->computeLogin($req);
    unless ( $result == PE_OK ) {
        $self->logger->error( "Could not compute login for "
              . $req->datas->{registerInfo}->{mail} );
        return $result;
    }

    # Create user
    $self->logger->debug(
        'Create new user ' . $req->datas->{registerInfo}->{login} );
    $result = $self->registerModule->createUser($req);
    unless ( $result == PE_OK ) {
        $self->logger->error(
            "Could not create user " . $req->datas->{registerInfo}->{login} );
        return $result;
    }

    # Build mail content
    my $tr      = $self->translate($req);
    my $subject = $self->conf->{registerDoneSubject};
    unless ($subject) {
        $subject = 'registerDoneSubject';
        $tr->( \$subject );
    }
    my $body;
    my $html = 1;

    # Use HTML template
    $body = $self->loadTemplate( 'mail_register_done', filter => $tr );

    # Build portal url
    my $url = $self->conf->{portal};
    $url =~ s#/*$##;
    $url .= '/?skin=' . $self->p->getSkin($req);
    $url .=
      '&' . $self->conf->{authChoiceParam} . '=' . $req->datas->{_authChoice}
      if ( $req->datas->{_authChoice} );
    $url .= '&url=' . $req->datas->{_url} if ( $req->datas->{_url} );

    # Replace variables in body
    $body =~ s/\$url/$url/g;
    $body =~ s/\$(\w+)/$req->datas->{registerInfo}->{$1}/ge;

    # Send mail
    return PE_MAILERROR
      unless $self->send_mail( $req->datas->{registerInfo}->{mail},
        $subject, $body, $html );

    return PE_MAILOK;
}

sub display {
    my ( $self, $req ) = @_;
    my %templateParams = (
        SKIN_PATH       => '/static',
        SKIN            => $self->p->getSkin($req),
        SKIN_BG         => $self->conf->{portalSkinBackground},
        AUTH_ERROR      => $req->error,
        AUTH_ERROR_TYPE => $req->error_type,
        AUTH_URL        => $req->datas->{_url},
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
            or $req->error == PE_NOTOKEN
            or $req->error == PE_TOKENEXPIRED
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
    if ( $req->captcha ) {
        $templateParams{CAPTCHA_SRC} = $req->captcha;
        $templateParams{CAPTCHA_SIZE} = $self->conf->{captcha_size} || 6;
    }
    if ( $req->token ) {
        $templateParams{TOKEN} = $req->token;
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

sub setSecurity {
    my ( $self, $req ) = @_;
    if ( $self->captcha ) {
        $self->captcha->setCaptcha($req);
    }
    elsif ( $self->ott ) {
        $self->ott->setToken($req);
    }
}

1;
