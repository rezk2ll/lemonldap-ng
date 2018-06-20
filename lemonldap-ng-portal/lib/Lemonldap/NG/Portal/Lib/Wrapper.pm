# Base class for auth modules that call other auth modules (Choice,...)
#
# It fakes portal object to catch entry points and load them only if underlying
# auth module is activated
package Lemonldap::NG::Portal::Lib::Wrapper;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Auth';

has availableModules => ( is => 'rw', default => sub { {} } );

# Wrappers for portal entry points: entry points are enabled only for active
# authentication module
#
# Note that "beforeAuth" can't be used here and must be wrapped in auth
# module
#
# Note also that auth module must store in $req->datas->{enabledMods} a ref
# to each enabled underlying auth modules
sub betweenAuthAndDatas { '_betweenAuthAndDatas' }
sub afterDatas          { '_afterDatas' }
sub forAuthUser         { '_forAuthUser' }
sub beforeLogout        { '_beforeLogout' }

sub _betweenAuthAndDatas { _wrapEntryPoint( @_, 'betweenAuthAndDatas' ); }
sub _afterDatas          { _wrapEntryPoint( @_, 'afterDatas' ); }
sub _forAuthUser         { _wrapEntryPoint( @_, 'forAuthUser', 1 ); }
sub _beforeLogout        { _wrapEntryPoint( @_, 'beforeLogout', 1 ); }

sub _wrapEntryPoint {
    my ( $self, $req, $name, $connected ) = @_;
    my @t;
    if ($connected) {
        if ( my $mod = $req->userData->{ $self->sessionKey } ) {
            if ( $self->modules->{$mod} ) {
                @t = ( $self->modules->{$mod} );
            }
            else {
                $self->userLogger->error(
                    "Bad $self->{sessionKey} value in session ($name)");
            }
        }
        else {
            $self->userLogger->warn(
                "Missing $self->{sessionKey} key in session");
        }
    }
    else {
        @t = @{ $req->datas->{ "enabledMods" . $self->type } };
    }
    foreach (@t) {
        if ( $_->can($name) ) {

            # Launch sub and break loop if result isn't PE_OK (==0)
            if ( my $sub = $_->$name() ) {
                return $_->$sub($req);
            }
        }
    }
    return PE_OK;
}

# loadPlugin() fakes portal loadPlugin: it loads module but does not load
# entry points since they will be launched by ^ methods
sub loadPlugin {
    my ( $self, $name, $module ) = @_;
    my $obj = $self->p->can('loadModule')->( $self->p, $module );
    ( $obj and $obj->init ) or return 0;
    return $obj;
}

sub AUTOLOAD {
    no strict;

    # Unknown methods are tried with real portal
    my $self = shift;
    my $sub  = $AUTOLOAD;
    $sub =~ s/.*:://;
    if ( $self->p->can($sub) ) {
        return $self->p->$sub(@_);
    }
    die "Unknown method $sub";
}

1;
