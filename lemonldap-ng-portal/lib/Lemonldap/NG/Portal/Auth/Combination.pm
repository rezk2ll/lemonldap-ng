package Lemonldap::NG::Portal::Auth::Combination;

use strict;
use Mouse;
use Lemonldap::NG::Common::Combination::Parser;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_ERROR);

# TODO: See Lib::Wrapper
extends 'Lemonldap::NG::Portal::Auth::Base';

# PROPERTIES

has stackSub => ( is => 'rw' );

# INITIALIZATION

sub init {
    my ($self) = @_;
    unless ( $self->conf->{combination} ) {
        $self->error('No combination found');
        return 0;
    }
    my %mods;
    foreach my $mod ( @{ $self->conf->{combModules} } ) {
        my @tmp = ( undef, undef );

        # TODO: override params
        if ( $mod->{for} < 2 ) {
            $tmp[0] = $self->p->loadPlugin("::Auth::$mod->{type}");
            unless ( $tmp[0] ) {
                $self->error("Unable to load Auth::$mod->{type}");
                return 0;
            }
        }
        unless ( $mod->{for} == 1 ) {
            $tmp[1] = $self->p->loadPlugin("::UserDB::$mod->{type}");
            unless ( $tmp[1] ) {
                $self->error("Unable to load UserDB::$mod->{type}");
                return 0;
            }
        }
        $mods{ $mod->{name} } = \@tmp;
    }
    eval {
        $self->stackSub(
            Lemonldap::NG::Common::Combination::Parser->parse(
                \%mods, $self->conf->{combination}
            )
        );
    };
    if ($@) {
        $self->error("Bad combination: $@");
        return 0;
    }
    return 1;
}

sub name {
    my ( $self, $req, $type ) = @_;
    return $req->sessionInfo->{ ( $type eq 'auth' ? '_auth' : '_userDB' ) }
      || 'Combination';
}

sub extractFormInfo {
    my ( $self, $req ) = @_;

    # Get available authentication schemes for this user
    $self->getStack( $req, 'extractFormInfo' ) or return PE_ERROR;
    return $self->try( 0, 'extractFormInfo', $req );
}

sub getUser {
    return $_[0]->try( 1, 'getUser', $_[1] );
}

sub authenticate {
    return $_[0]->try( 0, 'authenticate', $_[1] );
}

sub setAuthSessionInfo {
    return $_[0]->try( 0, 'setAuthSessionInfo', $_[1] );
}

sub setSessionInfo {
    return $_[0]->try( 1, 'setSessionInfo', $_[1] );
}

sub setGroups {
    return $_[0]->try( 1, 'setGroups', $_[1] );
}

sub getDisplayType {
    return $_[0]->try( 0, 'getDisplayType', {} );
}

# TODO: authLogout

sub getStack {
    my ( $self, $req, @steps ) = @_;
    return $req->datas->{multiStack} if ( $req->datas->{multiStack} );
    my $stack = $req->datas->{multiStack} = $self->stackSub->($req->env);
    unless ($stack) {
        $self->lmLog( 'No authentication scheme for this user', 'error' );
    }
    @{ $req->datas->{multiSteps} } = ( @steps, @{ $req->steps } );
    $req->datas->{multiTry} = 0;
    return $stack;
}

sub try {
    my ( $self, $type, $subname, $req ) = @_;
    my ( $nb, $stack ) = ( $req->datas->{multiTry}, $req->datas->{multiStack} );

    # If more than 1 scheme is available
    my ( $res, $name );
    if ( $nb < @$stack - 1 ) {

        # TODO: change logLevel for userLog()
        ( $res, $name ) = $stack->[$nb]->[$type]->( $subname, $req );

        # On error, restart authentication with next scheme
        if ( $res > PE_OK ) {
            $self->lmLog( qq'Scheme "$name" has return $res, trying next',
                'info' );
            $req->datas->{multiTry}++;
            $req->steps( [ @{ $req->datas->{multiSteps} } ] );
            return PE_OK;
        }
    }
    else {
        ( $res, $name ) = $stack->[$nb]->[$type]->( $subname, $req );
    }
    $req->sessionInfo->{ [ '_auth', '_userDB' ]->[$type] } = $name;
    return $res;
}

1;
