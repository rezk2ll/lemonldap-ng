# Base package for simple issuers plugins
#
# Issuer should just implement a run() method that will be called only for
# authenticated users when PATH_INFO starts with issuerDBXXPath
#
# run() should just return a Lemonldap::NG::Portal::Main::Constants value. It
# is called using process() method (Lemonldap::NG::Portal::Main::Process)
package Lemonldap::NG::Portal::Main::Issuer;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

extends 'Lemonldap::NG::Portal::Main::Plugin';

our $VERSION = '2.0.0';

# PROPERTIES

has type => ( is => 'rw' );

# INITIALIZATION

sub init {
    my ($self) = @_;
    my $type = ref( $_[0] );
    $type =~ s/.*:://;
    $self->type($type);
    if ( my $path = $self->conf->{"issuerDB${type}Path"} ) {
        $self->addUnauthRoute( $path => '_redirect',  ['GET'] );
        $self->addUnauthRoute( $path => '_pRedirect', ['POST'] );
        $self->addAuthRoute( $path => "_forAuthUser", [ 'GET', 'POST' ] );
    }
    else {
        $self->lmLog( "No path declared for issuer $type. Skipping", 'debug' );
    }
}

# RUNNING METHODS

# Case 1: Unauthentified users are redirected to the main portal

sub _redirect {
    my ( $self, $req ) = @_;
    $req->{urldc} =
        $self->conf->{portal}
      . $req->path
      . ( $req->query ? '?' . $req->query : () );
    return $self->p->do( $req, [] );
}

sub _pRedirect {
    my ( $self, $req ) = @_;
    $req->parseBody;

    # TODO
    die("TODO: store datas and redirect");
}

# Case 3: authentified user, launch
sub _forAuthUser {
    my ( $self, $req ) = @_;
    return $self->p->do(
        $req,
        [
            'importHandlerDatas',
            'controlUrl',
            @{ $self->p->forAuthUser },
            sub {
                return $self->forAuthUser(@_);
            },
        ]
    );
}

1;
