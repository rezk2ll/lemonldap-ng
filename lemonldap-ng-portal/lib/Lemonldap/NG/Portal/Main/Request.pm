package Lemonldap::NG::Portal::Main::Request;

# Developpers, be careful: new() is never called so default values will not be
# taken in account (see Portal::Run::handler())

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants;

extends 'Lemonldap::NG::Common::PSGI::Request';

# List of methods to call
has steps => ( is => 'rw' );

# Datas shared between methods
has datas => ( is => 'rw', default => sub { {} } );

# Session datas when created
has id          => ( is => 'rw' );
has sessionInfo => ( is => 'rw' );
has user        => ( is => 'rw' );

# Response cookies (list of strings built by cookie())
has respCookies => ( is => 'rw' );

# Template to display (if not defined, login or menu)
has template => ( is => 'rw' );

# Boolean to indicate that response must be a redirection
has mustRedirect => ( is => 'rw' );

# Boolean to indicate that url isn't Base64 encoded
has urlNotBase64 => ( is => 'rw' );

# Info to display at login
has info => ( is => 'rw' );

# Menu error
has menuError => ( is => 'rw' );

# Notification
has notification => ( is => 'rw' );

has _authChoice   => ( is => 'rw' );
has _openidPortal => ( is => 'rw' );

sub wantJSON {
    return $_[0]->accept =~ m#(?:application|text)/json# ? 1 : 0;
}

# Error type
sub error_type {
    my $req = shift;
    my $code = shift || $req->error;

    # Positive errors
    return "positive"
      if (
        scalar(
            grep { /^$code$/ } (
                PE_REDIRECT,        PE_DONE,
                PE_OK,              PE_PASSWORD_OK,
                PE_MAILOK,          PE_LOGOUT_OK,
                PE_MAILFIRSTACCESS, PE_PASSWORDFIRSTACCESS,
                PE_MAILCONFIRMOK,   PE_REGISTERFIRSTACCESS,
            )
        )
      );

    # Warning errors
    return "warning"
      if (
        scalar(
            grep { /^$code$/ } (
                PE_INFO,                          PE_SESSIONEXPIRED,
                PE_FORMEMPTY,                     PE_FIRSTACCESS,
                PE_PP_GRACE,                      PE_PP_EXP_WARNING,
                PE_NOTIFICATION,                  PE_BADURL,
                PE_CONFIRM,                       PE_MAILFORMEMPTY,
                PE_MAILCONFIRMATION_ALREADY_SENT, PE_PASSWORDFORMEMPTY,
                PE_CAPTCHAEMPTY,                  PE_REGISTERFORMEMPTY,
            )
        )
      );

    # Negative errors (default)
    return "negative";

    #TODO
}

sub errorString {

    #TODO
}

sub loginInfo {
}

# TODO: oldpassword
1;
