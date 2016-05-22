##@file
# Web form authentication backend file

##@class
# Web form authentication backend class
package Lemonldap::NG::Portal::Auth::_WebForm;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants
  qw(PE_OK PE_FIRSTACCESS PE_FORMEMPTY PE_PASSWORDFORMEMPTY PE_CAPTCHAEMPTY PE_CAPTCHAERROR);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base';

## @apmethod int authInit()
# Does nothing.
sub init {
    1;
}

## @apmethod int extractFormInfo()
# Read username and password from POST datas
# @return Lemonldap::NG::Portal constant
sub extractFormInfo {
    my ( $self, $req ) = @_;

    # Init captcha
    if ( $self->conf->{captcha_login_enabled} ) {
        eval { $self->initCaptcha(); };
        $self->lmLog( "Can't init captcha: $@", "error" ) if $@;
    }

    # Detect first access and empty forms
    my $defUser        = defined $req->param('user');
    my $defPassword    = defined $req->param('password');
    my $defOldPassword = defined $req->param('oldpassword');

    # 1. No user defined at all -> first access
    return PE_FIRSTACCESS unless $defUser;

    # 2. If user and password defined -> login form
    if ( $defUser && $defPassword ) {
        return PE_FORMEMPTY
          unless ( ( $req->{user} = $req->param('user') )
            && ( $req->datas->{password} = $req->param('password') ) );
    }

    # 3. If user and oldpassword defined -> password form
    if ( $defUser && $defOldPassword ) {
        return PE_PASSWORDFORMEMPTY
          unless ( ( $req->{user} = $req->param('user') )
            && ( $req->datas->{oldpassword} = $req->param('oldpassword') )
            && ( $req->datas->{newpassword} = $req->param('newpassword') )
            && ( $req->datas->{confirmpassword} =
                $req->param('confirmpassword') ) );
    }

    # 4. Captcha for login form
    if ( $self->conf->{captcha_login_enabled} && $defUser && $defPassword ) {
        $req->datas->{captcha_user_code}  = $req->param('captcha_user_code');
        $req->datas->{captcha_check_code} = $req->param('captcha_code');

        unless ( $req->datas->{captcha_user_code}
            && $req->datas->{captcha_check_code} )
        {
            $self->lmLog( "Captcha not filled", 'warn' );
            return PE_CAPTCHAEMPTY;
        }

        $self->lmLog(
            "Captcha data received: "
              . $req->datas->{captcha_user_code} . " and "
              . $req->datas->{captcha_check_code},
            'debug'
        );

        # Check captcha
        my $captcha_result = $self->checkCaptcha(
            $req->datas->{captcha_user_code},
            $req->datas->{captcha_check_code}
        );

        if ( $captcha_result != 1 ) {
            if (   $captcha_result == -3
                or $captcha_result == -2 )
            {
                $self->lmLog( "Captcha failed: wrong code", 'warn' );
                return PE_CAPTCHAERROR;
            }
            elsif ( $captcha_result == 0 ) {
                $self->lmLog( "Captcha failed: code not checked (file error)",
                    'warn' );
                return PE_CAPTCHAERROR;
            }
            elsif ( $captcha_result == -1 ) {
                $self->lmLog( "Captcha failed: code has expired", 'warn' );
                return PE_CAPTCHAERROR;
            }
        }
        $self->lmLog( "Captcha code verified", 'debug' );
    }

    # Other parameters
    $req->datas->{timezone} = $req->param('timezone');

    PE_OK;
}

## @apmethod int setAuthSessionInfo()
# Set password in session datas if wanted.
# @return Lemonldap::NG::Portal constant
sub setAuthSessionInfo {
    my ( $self, $req ) = @_;

    # authenticationLevel
    # +1 for user/password with HTTPS
    $self->{_authnLevel} //= 0;
    $self->{_authnLevel} += 1 if $self->https();

    #TODO: check where _authnLevel is defined
    $self->{sessionInfo}->{authenticationLevel} = $self->{_authnLevel};

    # Store user submitted login for basic rules
    $self->{sessionInfo}->{'_user'} = $self->{'user'};

    # Store submitted password if set in configuration
    # WARNING: it can be a security hole
    if ( $self->conf->{storePassword} ) {
        $self->{sessionInfo}->{'_password'} = $req->datas->{'newpassword'}
          || $req->datas->{'password'};
    }

    # Store user timezone
    $self->{sessionInfo}->{'_timezone'} = $self->{'timezone'};

    PE_OK;
}

# @return display type
sub getDisplayType {
    return "standardform";
}

1;
