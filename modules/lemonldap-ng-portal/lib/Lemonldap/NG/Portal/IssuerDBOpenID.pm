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
    if ( $ENV{PATH_INFO} =~ /^\/openid/ ) {

        # TODO: store GET and POST params somewhere...
    }
    PE_OK;
}

## @apmethod int issuerForAuthUser()
# Do nothing
# @return Lemonldap::NG::Portal error code
sub issuerForAuthUser {
    my $self   = shift;
    my $portal = $self->{portal};
    $portal .= 'index.pl' if ( $portal =~ /\/$/ );

    #TODO: Catch openIdSetup
    my $server = Net::OpenID::Server->new(
        post_args    => $self->params(),
        get_args     => $self->params(),
        endpoint_url => $portal . "/openid/",
        setup_url    => $self->{portal},
        get_user     => sub {
            return $self->{sessionInfo}
              ->{ $self->{OpenIdAttr} || $self->{whatToTrace} };
        },
        get_identity => sub {
            my ( $u, $identity ) = @_;
            return $identity unless $u;
            return $portal . "/openid/" . $u->username;
        },
        is_identity => sub {
            my ( $u, $identity ) = @_;
            return $u && $u->username eq ( split '/', $identity )[-1];
        },
        is_trusted => sub {
            my ( $u, $trust_root, $is_identity ) = @_;
            return $is_identity;
        }
    );

    my ( $type, $data ) = $server->handle_page();

    if ( $type eq 'redirect' ) {
        print $self->redirect($data);
        $self->quit();
    }
    elsif ( $type eq 'setup' ) {

        # TODO: what is in $data;
        print $self->redirect( $portal
              . "?openIdSetup=1&trust_root=$data->{trust_root}&return_to=$data->{return_to}"
        );
        print $self->quit();
    }
    else {
        print $self->header($type);
        print $data;
        $self->quit();
    }

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
