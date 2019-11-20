package Lemonldap::NG::Portal::Plugins::Refresh;

use strict;
use Mouse;

our $VERSION = '2.0.5';

extends 'Lemonldap::NG::Portal::Main::Plugin',
  'Lemonldap::NG::Portal::Lib::OtherSessions';

sub init {
    my ($self) = @_;
    $self->addUnauthRoute( refreshsessions => 'run', ['POST'] );
}

sub run {
    my ( $self, $req );
    return $self->p->sendError( $req, 'Bad request', 400 )
      unless $req->wantJSON;
    my $info = $req->jsonBodyToObj;
    return $self->p->sendError( $req, 'Bad request', 400 ) unless $info->{uid};
    my $sessions =
      $self->module->searchOn( $self->moduleOpts, $self->conf->{whatToTrace},
        $uid );
    my $c = 0;
    foreach my $id ( keys %$sessions ) {
        $c++;
        $req->userData(
            { _session_id => $id, $self->conf->{whatToTrace} => $uid } );
        $req->id($id);
        $req->user($uid);
        $self->p->refresh($req);
    }
    $req->$_(undef) foreach (qw(user id));
    $self->userData(                      {} );
    return $self->sendJSONresponse( $req, { updated => $c } );
}

1;
