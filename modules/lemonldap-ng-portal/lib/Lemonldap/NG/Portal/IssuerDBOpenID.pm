## @file
# OpenID Issuer file

## @class
# OpenID Issuer class
package Lemonldap::NG::Portal::IssuerDBOpenID;

use strict;
use Lemonldap::NG::Portal::Simple;

our $VERSION = '0.01';

## @method void issuerDBInit()
# Do nothing
# @return Lemonldap::NG::Portal error code
sub issuerDBInit {
    my $self = shift;
    eval { require Net::OpenID::Server };
    $self->abort( 'Unable to load Net::OpenID::Server', $@ ) if ($@);
    $self->{openIdSecret} ||= $self->{conf}->crypt(0);
    return PE_OK;
}

## @apmethod int issuerForUnAuthUser()
# Do nothing
# @return Lemonldap::NG::Portal error code
sub issuerForUnAuthUser {
    my $self = shift;

    # Restore datas
    $self->restoreOpenIDprm();
    my $mode = $self->param('openid.mode');

    unless ($mode) {
        $self->lmLog( 'OpenID SP test', 'debug' );
        return PE_OPENID_EMPTY;
    }

    my ( $type, $data );
    if ( $mode eq 'associate' ) {
        return $self->_openIDResponse( $self->openIDServer->_mode_associate() );
    }
    elsif ( $mode eq 'check_authentication' ) {
        return $self->_openIDResponse(
            $self->openIDServer->_mode_check_authentication() );
    }
    else {
        $self->storeOpenIDprm();
        return PE_OK;
    }
}

## @apmethod int issuerForAuthUser()
# Do nothing
# @return Lemonldap::NG::Portal error code
sub issuerForAuthUser {
    my $self = shift;

    # Restore datas
    $self->restoreOpenIDprm();

    return $self->_openIDResponse( $self->openIDServer->handle_page() );
}

## @apmethod int issuerLogout()
# TODO
# @return Lemonldap::NG::Portal error code
sub issuerLogout {
    PE_OK;
}

sub storeOpenIDprm {
    my $self = shift;
    delete( $self->{_prm}->{lmhidden_openidprm} );
    $self->setHiddenFormValue( 'openidprm',
        Storable::nfreeze( $self->{_prm} ) );
}

sub restoreOpenIDprm {
    my $self = shift;
    return if ( $self->{openIDRestored} );
    if ( my $tmp = $self->getHiddenFormValue('openidprm') ) {
        $self->lmLog( 'Restore OpenID parameters', 'debug' );
        eval {
            $tmp = Storable::thaw($tmp);
            $self->{_prm}->{$_} = $tmp->{$_} foreach ( keys %$tmp );
        };
    }
    $self->{openIDRestored} = 1;
}

sub openIDServer {
    my $self = shift;
    return $self->{_openidserver} if ( $self->{_openidserver} );
    $self->{_openidPortal} = $self->{portal} . "/openidserver/";
    $self->{_openidPortal} =~ s#(?<!:)//#/#g;

    $self->{_openidserver} = Net::OpenID::Server->new(

        # TODO
        server_secret => sub { return $self->{openIdSecret} },
        post_args     => $self->{_prm},
        get_args      => $self->{_prm},
        endpoint_url => $self->{_openidPortal},
        setup_url    => $self->{_openidPortal},
        get_user     => sub {
            return $self->{sessionInfo}
              ->{ $self->{OpenIdAttr} || $self->{whatToTrace} };
        },
        get_identity => sub {
            my ( $u, $identity ) = @_;
            return $identity unless $u;
            return $self->{_openidPortal} . $u;
        },
        is_identity => sub {
            my ( $u, $identity ) = @_;
            return 0 unless ( $u and $identity );
            if( $u eq ( split '/', $identity )[-1]){
                return 1;
            }
            else {
                $self->{_badOpenIdentity} = 1;
                return 0;
            }
        },
        is_trusted => sub {
            my ( $u, $trust_root, $is_identity ) = @_;
            return 0 unless ( $u and $is_identity );
            if ( $self->{sessionInfo}->{"_openidTrust$trust_root"} ) {
                $self->lmLog( 'OpenID request already trusted', 'debug' );
                return 1;
            }
            elsif ( $self->param("confirm") ) {
                $self->updateSession( { "_openidTrust$trust_root" => 1 } );
                return 1;
            }
            else {
                $self->lmLog( 'OpenID request not trusted', 'debug' );
                $self->{_openIdTrustRequired} = 1;
                return 0;
            }
        }
    );
    return $self->{_openidserver};
}

sub _openIDResponse {
    my ( $self, $type, $data ) = splice @_;
    if ( $type eq 'redirect' ) {
        $self->lmLog( 'OpenID redirection', 'debug' );
        print $self->redirect($data);
    }
    elsif ( $type eq 'setup' ) {
        if ( $self->{_openIdTrustRequired} ) {

            # TODO
            $self->info( "<h2>Site demandé " . $data->{trust_root} . "</h2>" );
            $self->lmLog( 'OpenID confirmation', 'debug' );
            $self->storeOpenIDprm();
            return PE_CONFIRM;
        }
        if ( $self->{_badOpenIdentity} ) {
            $self->userNotice(
                "The user $self->{sessionInfo}->{_user} tries to use the id \"$data->{identity}\" on $data->{trust_root}");
            return PE_OPENID_BADID;
        }
    }
    else {
        $self->lmLog( 'OpenID generated page', 'debug' );
        print $self->header($type);
        print $data;
    }
    $self->quit();
    PE_OK;
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::IssuerDBOpenID - OpenID IssuerDB for Lemonldap::NG

=head1 DESCRIPTION

OpenID Issuer implementation in LemonLDAP::NG

=head1 SEE ALSO

L<Lemonldap::NG::Portal>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
