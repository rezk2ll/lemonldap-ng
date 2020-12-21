package Lemonldap::NG::Portal::Plugins::FindUser;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_FIRSTACCESS
);

our $VERSION = '2.0.11';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION
sub init {
    my ($self) = @_;
    my $imp = grep /::Plugins::Impersonation$/, $self->p->enabledPlugins;
    $self->addUnauthRoute( finduser => 'provideUser', ['POST'] ) if $imp;

    return 1;
}

# RUNNING METHOD
sub provideUser {
    my ( $self, $req ) = @_;
    $req->steps( ['findUser'] );
    if ( my $error = $self->p->process($req) ) {
        $self->logger->debug("Process returned error: $error");
        return $req->error($error);
    }
    $req->mustRedirect(1);
    return $self->p->do( $req, [ sub { PE_FIRSTACCESS } ] );
}

sub retreiveFindUserParams {
    my ( $self,   $req )            = @_;
    my ( $params, $excludedParams ) = ( [ {} ], [ {} ] );
    $self->logger->debug("FindUser: reading parameters...");
    foreach ( sort keys %{ $self->conf->{findUserSearchingAttributes} } ) {
        $self->logger->debug( "Pushing searching parameter: $_ => " . $req->params($_) );
        push @$params, { key => $_, value => $req->params($_) };
    }
    $self->logger->debug("FindUser: reading excluding parameters...");
    foreach ( sort keys %{ $self->conf->{findUserExcludingAttributes} } ) {
        $self->logger->debug( "Pushing excluded parameter: $_ => "
              . $self->conf->{findUserExcludingAttributes}->{$_} );
        push @$excludedParams,
          {
            key   => $_,
            value => $self->conf->{findUserExcludingAttributes}->{$_}
          };
    }
    return ( $params, $excludedParams );
}

1;
