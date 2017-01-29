package Lemonldap::NG::Portal::Plugins::Register;

use strict;
use Encode;
use Mouse;
use POSIX qw(strftime);
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_BADCREDENTIALS
  PE_BADMAILTOKEN
  PE_CAPTCHAEMPTY
  PE_CAPTCHAERROR
  PE_MAILCONFIRMOK
  PE_MAILERROR
  PE_MAILFIRSTACCESS
  PE_MAILFORMEMPTY
  PE_MAILOK
  PE_MALFORMEDUSER
  PE_NOTOKEN
  PE_OK
  PE_PASSWORDFIRSTACCESS
  PE_PASSWORDFORMEMPTY
  PE_PASSWORD_OK
  PE_TOKENEXPIRED
  PE_USERNOTFOUND
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin',
  'Lemonldap::NG::Portal::Lib::SMTP';

# PROPERTIES

# Mail timeout token generator
has mailott => (
    is      => 'rw',
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->conf->{mailTimeout} || $_[0]->conf->{timeout} );
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
    $self->addUnauthRoute( resetpwd => 'resetPwd', [ 'POST', 'GET' ] );

    # Initialize Captcha if needed
    if ( $self->conf->{captcha_mail_enabled} ) {
        $self->captcha( $self->p->loadModule('::Lib::Captcha') ) or return 0;
    }

    # Initialize form token if needed (captcha provides also a token)
    elsif ( $self->conf->{requireToken} ) {
        $_[0]->ott(
            $_[0]->p->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken') )
          or return 0;
        $_[0]->ott->timeout( $_[0]->conf->{formTimeout} );
    }
    return 1;
}

# RUNNIG METHODS

# Handle reset requests
sub resetPwd {
    my ( $self, $req ) = @_;

    # Check parameters
    $req->error( $self->_reset($req) );

    # Display form
    my ( $tpl, $prms ) = $self->display($req);
    return $self->p->sendHtml( $req, $tpl, params => $prms );
}

sub _reset {
    my ( $self, $req ) = @_;
    my ( $mailToken, $newPwd, $confirmPwd );

    # Check for first access
    $mailToken = $req->param('mail_token');
    unless ( $req->param('mail') || $mailToken ) {
        $self->setSecurity($req);
        return PE_MAILFIRSTACCESS if ( $req->method eq 'GET' );
        return PE_MAILFORMEMPTY;
    }

    # Check for mail link
    if ($mailToken) {
        $self->lmLog( "Token given for password reset: " . $mailToken,
            'debug' );

        # Check if token is valid
        my $mailSession = $self->mailott->getToken($mailToken);
        unless ($mailSession) {
            $self->p->userNotice('Bad reset token');
            return PE_BADMAILTOKEN;
        }

        $req->{mail} = $mailSession->{user};
        $req->datas->{mailAddress} =
          $mailSession->{ $self->conf->{mailSessionKey} };
        $self->lmLog( 'User associated to: ' . $req->{mail} . 'debug' );
    }

    # Check for values posted
    else {

        # Use submitted value
        $req->{mail} = $req->param('mail');

        # Check if token exists
        my $token;
        if ( $self->ott or $self->captcha ) {
            $token = $req->param('token');
            unless ($token) {
                $self->setSecurity($req);
                $self->p->userNotice('Reset try without token');
                return PE_NOTOKEN;
            }
        }

        # Captcha for register form
        if ( $self->captcha ) {
            my $captcha = $req->param('captcha');

            unless ($captcha) {
                $self->p->userNotice('Reset try with captcha not filled');

                # Set captcha or token
                $self->setSecurity($req);
                return PE_CAPTCHAEMPTY;
            }

            # Check captcha
            unless ( $self->captcha->validateCaptcha( $token, $captcha ) ) {
                $self->p->userInfo('Captcha failed: wrong code');

                # Set captcha or token
                $self->setSecurity($req);
                return PE_CAPTCHAERROR;
            }
            $self->lmLog( "Captcha code verified", 'debug' );
        }
        elsif ( $self->ott ) {
            unless ( $self->ott->getToken($token) ) {
                $self->setSecurity($req);
                $self->p->userNotice('Reset try with expired/bas token');
                return PE_TOKENEXPIRED;
            }
        }
        unless ( $req->{mail} =~ /$self->{conf}->{userControl}/o ) {
            $self->setSecurity($req);
            return PE_MALFORMEDUSER;
        }
    }

    # Search user in database
    $req->user( $req->{mail} );
    $req->steps(
        [
            'getUser',                  'setSessionInfo',
            'setMacros',                'setGroups',
            'setPersistentSessionInfo', 'setLocalGroups'
        ]
    );
    if ( my $error = $self->p->process($req) ) {
        if ( $error == PE_USERNOTFOUND or $error = PE_BADCREDENTIALS ) {
            $self->p->userNotice(
                "Reset asked for a unvalid user ($req->{mail})");

            # To avoid mail enumeration, return OK
            return PE_MAILCONFIRMOK;
        }
        return $error;
    }

    # Build temporary session
    my $mailSession;
    unless ( ( $mailSession = $self->getMailSession( $req->{mail} ) )
        or $mailToken )
    {

        # Create a new session

        my $infos = {};

        $mailSession = $self->p->getApacheSession();

        # Set _utime for session autoremove
        # Use default session timeout and mail session timeout to compute it
        my $time        = time();
        my $timeout     = $self->conf->{timeout};
        my $mailTimeout = $self->conf->{mailTimeout} || $timeout;

        $infos->{_utime} = $time + ( $mailTimeout - $timeout );

        # Store expiration timestamp for further use
        $infos->{mailSessionTimeoutTimestamp} = $time + $mailTimeout;

        # Store start timestamp for further use
        $infos->{mailSessionStartTimestamp} = $time;

        # Store mail
        $infos->{ $self->conf->{mailSessionKey} } =
          $self->p->getFirstValue(
            $req->{sessionInfo}->{ $self->conf->{mailSessionKey} } );

        # Store user
        $infos->{user} = $req->{mail};

        # Store type
        $infos->{_type} = "mail";

        # Update session
        $mailSession->update($infos);
    }

    # Send confirmation mail
    unless ($mailToken) {
        my $mailAlreadySent = ( $mailSession->{id} and !$req->id ) ? 1 : 0;
        $req->{id} ||= $mailSession->{id};

        $self->lmLog( 'Mail session found: ' . $mailSession->id, 'debug' );

        # Mail session expiration date
        my $expTimestamp = $mailSession->data->{mailSessionTimeoutTimestamp};

        $self->lmLog( "Mail expiration timestamp: $expTimestamp", 'debug' );

        my $expMailDate = strftime( "%d/%m/%Y", localtime $expTimestamp );
        my $expMailTime = strftime( "%H:%M",    localtime $expTimestamp );

        # Mail session start date
        my $startTimestamp = $mailSession->data->{mailSessionStartTimestamp};

        $self->lmLog( "Mail start timestamp: $startTimestamp", 'debug' );
        my $startMailDate = strftime( "%d/%m/%Y", localtime $startTimestamp );
        my $startMailTime = strftime( "%H:%M",    localtime $startTimestamp );

        # Ask if user want another confirmation email
        if ( $self->mailAlreadySent and !$req->param('resendconfirmation') ) {
            $self->p->userNotice(
                'Reset mail already sent to ' . $req->{mail} );

            # To avoid enumeration, return OK
            return PE_MAILCONFIRMOK;
        }

        # Get mail address
        $req->datas->{mailAddress} ||=
          $self->p->getFirstValue(
            $req->{sessionInfo}->{ $self->conf->{mailSessionKey} } );

        # Build confirmation url
        my $url =
            $self->conf->{mailUrl}
          . "?mail_token="
          . $req->{id}
          . '&skin='
          . $self->p->getSkin;
        $url .= '&'
          . $self->conf->{authChoiceParam} . '='
          . $req->datas->{_authChoice}
          if ( $req->datas->{_authChoice} );

        # Build mail content
        my $subject = $self->conf->{mailConfirmSubject};
        my $body;
        my $html;
        if ( $self->conf->{mailConfirmBody} ) {

            # We use a specific text message, no html
            $body = $self->{mailConfirmBody};
        }
        else {

            # Use HTML template
            my $tplfile =
                $self->conf->{templateDir} . '/'
              . $self->conf->{portalSkin}
              . '/mail_confirm.tpl';
            $tplfile = $self->conf->{templateDir} . '/common/mail_confirm.tpl'
              unless ( -e $tplfile );
            my $template = HTML::Template->new( filename => $tplfile, );
            $body = $template->output();
            $html = 1;
        }

        # Replace variables in body
        $body =~ s/\$expMailDate/$expMailDate/g;
        $body =~ s/\$expMailTime/$expMailTime/g;
        $body =~ s/\$url/$url/g;
        $body =~ s/\$(\w+)/decode("utf8",$req->{sessionInfo}->{$1})/ge;

        # Send mail
        unless (
            $self->send_mail( $self->{mailAddress}, $subject, $body, $html ) )
        {
            $self->lmLog( 'Unable to send reset mail', 'debug' );

            # Don't return an error here to avoid enumeration
        }
        return PE_MAILCONFIRMOK;
    }

    # mailToken is valid, time to change password

    # Check if user wants to generate the new password
    if ( $req->param('reset') ) {
        $self->lmLog(
            "Reset password request for " . $req->{sessionInfo}->{_user},
            'debug' );

        # Generate a complex password
        my $password =
          $self->gen_password( $self->conf->{randomPasswordRegexp} );

        $self->lmLog( "Generated password: " . $password, 'debug' );

        $req->datas->{newpassword}     = $password;
        $req->datas->{confirmpassword} = $password;
        $req->datas->{forceReset}      = 1;
    }

    # Else a password is required in request
    else {
        $req->datas->{newpassword}     = $req->param('newpassword');
        $req->datas->{confirmpassword} = $req->param('confirmpassword');
        unless ( $req->datas->{newpassword} && $req->datas->{confirmpassword} )
        {
            return PE_PASSWORDFIRSTACCESS if ( $req->method eq 'GET' );
            return PE_PASSWORDFORMEMPTY;
        }

        # Modify the password TODO: change this
        my $tmp = $self->conf->{portalRequireOldPassword};
        $self->conf->{portalRequireOldPassword} = 0;
        my $result = $self->p->_passwordDB->modifyPassword($req);

        # Mail token can be used only one time, delete the session if all is ok
        return $result unless ( $result == PE_PASSWORD_OK or $result == PE_OK );
    }

    # Send mail containing the new password
    $req->datas->{mailAddress} ||=
      $self->p->getFirstValue(
        $req->{sessionInfo}->{ $self->conf->{mailSessionKey} } );

    # Build mail content
    my $subject = $self->conf->{mailSubject};
    my $body;
    my $html;
    if ( $self->conf->{mailBody} ) {

        # We use a specific text message, no html
        $body = $self->{mailBody};
    }
    else {

        # Use HTML template
        my $tplfile =
            $self->conf->{templateDir} . '/'
          . $self->conf->{portalSkin}
          . '/mail_password.tpl';
        $tplfile = $self->conf->{templateDir} . '/common/mail_password.tpl'
          unless ( -e $tplfile );
        my $template = HTML::Template->new( filename => $tplfile, );
        $body = $template->output();
        $html = 1;
    }

    # Replace variables in body
    my $password = $req->datas->{newpassword};
    $body =~ s/\$password/$password/g;
    $body =~ s/\$(\w+)/decode("utf8",$req->{sessionInfo}->{$1})/ge;

    # Send mail
    return PE_MAILERROR
      unless $self->send_mail( $self->{mailAddress}, $subject, $body, $html );

    PE_MAILOK;
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
