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

    # TODO secret
    $self->lmLog(
'OpenID provider module is not fully functionnal now, use for test purpose only',
        'warn'
    );
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

    print STDERR Dumper($self->{_prm}); use Data::Dumper;
    unless($mode) {
        $self->lmLog( 'OpenID SP test', 'debug' );
        return PE_OPENID_EMPTY;
    }
    
    my ( $type, $data );
    if($mode eq 'associate') {
        return $self->_openIDResponse( $self->openIDServer->_mode_associate() );
    }
    elsif($mode eq 'check_authentication'){
        return $self->_openIDResponse( $self->openIDServer->_mode_check_authentication() );
    }
    else {
        # TODO: store datas
        $self->setHiddenFormValue('openidprm',Storable::nfreeze($self->{_prm}));
        return PE_OK;
    }
}

sub restoreOpenIDprm {
    my $self   = shift;
    if(my $tmp = $self->getHiddenFormValue('openidprm')){
        eval { $tmp = Storable::thaw($tmp); $self->{_prm}->{$_} = $tmp->{$_} foreach(keys %$tmp);};
    }
}

sub openIDServer {
    my $self = shift;
    return $self->{_openidserver} if($self->{_openidserver});
    $self->{_openidPortal} = $self->{portal} . "/openidserver/";
    $self->{_openidPortal} =~ s#(?<!:)//#/#g;

    $self->{_openidserver} = Net::OpenID::Server->new(

        # TODO
        server_secret=> sub{return 'azertt'},
        post_args    => $self->{_prm},
        get_args     => $self->{_prm},
        endpoint_url => $self->{_openidPortal},
        setup_url    => $self->{_openidPortal},
        get_user     => sub {
            print STDERR "############### 0#\n";
            return $self->{sessionInfo}
              ->{ $self->{OpenIdAttr} || $self->{whatToTrace} };
        },
        get_identity => sub {
            my ( $u, $identity ) = @_;
            print STDERR "############### 1 $u, $identity#\n";
            return $identity unless $u;
            return $self->{_openidPortal} . $u->username;
        },
        is_identity => sub {
            my ( $u, $identity ) = @_;
            return 0 unless($u and $identity);
            return $u eq ( split '/', $identity )[-1];
        },
        is_trusted => sub {
            my ( $u, $trust_root, $is_identity ) = @_;
            print STDERR "############### 3 $u, $trust_root, $is_identity#\n";
            return $is_identity;
        }
    );
    return $self->{_openidserver};
}

sub _openIDResponse {
    my ($self,$type,$data)=splice @_;
    if ( $type eq 'redirect' ) {
        $self->lmLog( 'OpenID redirection', 'debug' );
        print $self->redirect($data);
    }
    elsif ( $type eq 'setup' ) {
        $self->lmLog( 'OpenID setup', 'debug' );
        $self->abort('Must never append !!!');
    }
    else {
        $self->lmLog( 'OpenID generated page', 'debug' );
        print $self->header($type);
        print $data;
    }
    $self->quit();
    PE_OK;
}

## @apmethod int issuerForAuthUser()
# Do nothing
# @return Lemonldap::NG::Portal error code
sub issuerForAuthUser {
    my $self   = shift;
    $self->restoreOpenIDprm();

    $self->_openIDResponse( $self->openIDServer->handle_page() );

    PE_OK;
}

## @apmethod int issuerLogout()
# TODO
# @return Lemonldap::NG::Portal error code
sub issuerLogout {
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
