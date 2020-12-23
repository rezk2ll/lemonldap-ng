package Lemonldap::NG::Portal::Plugins::FindUser;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_NOTOKEN
  PE_TOKENEXPIRED
  PE_FIRSTACCESS
);

our $VERSION = '2.0.11';

extends qw(
  Lemonldap::NG::Portal::Main::Plugin
  Lemonldap::NG::Portal::Lib::_tokenRule
);

# INITIALIZATION
has ott => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->{conf}->{formTimeout} );
        return $ott;
    }
);

sub init {
    my ($self) = @_;
    my $imp = grep /::Plugins::Impersonation$/, $self->p->enabledPlugins;
    $self->addUnauthRoute( finduser => 'provideUser', ['POST'] ) if $imp;

    return 1;
}

# RUNNING METHOD
sub provideUser {
    my ( $self, $req ) = @_;
    my $error;

    # Check token
    if ( $self->ottRule->( $req, {} ) ) {
        my $token = $req->param('token');
        unless ($token) {
            $self->userLogger->warn('FindUser called without token');
            $error = PE_NOTOKEN;
        }
        unless ( $self->ott->getToken($token) ) {
            $self->userLogger->warn(
                'FindUser called with an expired/bad token');
            $error = PE_TOKENEXPIRED;
        }
    }
    if ($error) {
        eval { $self->p->_authentication->setSecurity($req) };
        return $self->p->do( $req, [ sub { $error } ] );
    }

    $req->steps( ['findUser'] );
    if ( $error = $self->p->process($req) ) {
        $self->logger->debug("Process returned error: $error");
        return $req->error($error);
    }

    $req->mustRedirect(0);
    return $self->sendJSONresponse(
        $req,
        {
            user   => ( $req->{findUser} ? $req->{findUser} : '' ),
            result => 1
        }
    ) if $req->wantJSON;
    return $self->p->do( $req, [ sub { PE_FIRSTACCESS } ] );
}

sub retreiveFindUserParams {
    my ( $self,      $req )       = @_;
    my ( $searching, $excluding ) = ( [], [] );
    $self->logger->debug("FindUser: reading parameters...");
    foreach ( sort keys %{ $self->conf->{findUserSearchingAttributes} } ) {
        if ( $req->params($_) ) {
            $self->logger->debug(
                "Pushing searching parameter: $_ => " . $req->params($_) );
            push @$searching, { key => $_, value => $req->params($_) };
        }
    }

    if ( scalar @$searching ) {
        $self->logger->debug("FindUser: reading excluding parameters...");
        foreach ( sort keys %{ $self->conf->{findUserExcludingAttributes} } ) {
            if ( $req->params($_) ) {
                $self->logger->debug( "Pushing excluded parameter: $_ => "
                      . $self->conf->{findUserExcludingAttributes}->{$_} );
                push @$excluding,
                  {
                    key   => $_,
                    value => $self->conf->{findUserExcludingAttributes}->{$_}
                  };
            }
        }
    }

    return ( $searching, $excluding );
}

1;
