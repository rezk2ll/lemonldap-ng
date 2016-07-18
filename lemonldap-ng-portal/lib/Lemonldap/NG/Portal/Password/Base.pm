# Base package for Password modules
package Lemonldap::NG::Portal::Password::Base;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_BADOLDPASSWORD
  PE_PASSWORD_OK
  PE_PASSWORD_MISMATCH
  PE_PP_MUST_SUPPLY_OLD_PASSWORD
);

extends 'Lemonldap::NG::Portal::Main::Plugin';

our $VERSION = '2.0.0';

sub forAuthUser { '_modifyPassword' }

sub _modifyPassword {
    my ( $self, $req ) = @_;

    # Exit if no password change requested
    return PE_OK
      unless ( $req->datas->{newpassword} = $req->param('newpassword') );

    # Check if portal require old password
    if ( $self->conf->{portalRequireOldPassword} ) {

        # TODO: verify oldpassword
        unless ( $req->datas->{oldpassword} = $req->param('oldpassword') ) {
            $self->lmLog( "Portal require old password", 'warn' );
            return PE_PP_MUST_SUPPLY_OLD_PASSWORD;
        }

        # Verify that old password is good
        return PE_PASSWORD_MISMATCH
          unless (
            $req->datas->{newpassword} eq $req->param('confirmpassword') );

        # Verify old password
        return PE_BADOLDPASSWORD
          unless ( $self->confirm( $req, $req->datas->{newpassword} ) );
    }

    # Call password package
    my $res =
      $self->modifyPassword( $req, $req->datas->{newpassword} );
    if ( $res == PE_PASSWORD_OK ) {
        $self->lmLog( 'Update password in session for ' . $req->user, 'debug' );
        my $infos;

        # Store new password if asked
        if ( $self->conf->{storePassword} ) {
            $self->p->updateSession(
                $req,
                {
                    _passwordDB => $self->getModule( $req, 'password' ),
                    _password   => $req->{newpassword}
                }
            );
        }
        else {
            $self->p->updateSession( $req,
                { _passwordDB => $self->getModule( $req, 'password' ) } );
        }

        # Set a flag to ignore password change in Menu
        $req->{ignorePasswordChange} = 1;

        # Set a flag to allow sending a mail
        $req->{passwordWasChanged} = 1;

        #  Continue process if password change is ok
        return PE_OK;
    }
    return $res;
}

1;
