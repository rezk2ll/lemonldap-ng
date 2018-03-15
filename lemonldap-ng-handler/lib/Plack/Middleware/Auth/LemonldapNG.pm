package Plack::Middleware::Auth::LemonldapNG;

our $AUTHORITY = 'cpan:GUIMARD';
our $VERSION   = '2.0';
our $llclass   = 'Lemonldap::NG::Handler::Server';

use strict;
use base qw(Plack::Middleware);
use Plack::Util;
use Plack::Util::Accessor qw(
  llhandler
  llparams
  on_reject
);

sub prepare_app {
    my ($self) = @_;
    Plack::Util::load_class($llclass);
    $self->llhandler( $llclass->run( $self->llparams ) );
}

sub call {
    my ( $self, $env ) = @_;
    my $res    = $self->llhandler->($env);
    my $rejApp = $self->on_reject;
    unless ( $res->[0] == 200 ) {
        if ($rejApp) {
            return $self->$rejApp( $env, $res );
        }
        else {
            return $res;
        }
    }
    my $app = $self->app;
    @_ = $env;
    goto $app;
}

__PACKAGE__;
__END__

=head1 NAME

Plack::Middleware::Auth::LemonldapNG - authentication middleware for Lemonldap-NG

=head1 SYNOPSIS

  use Plack::Builder;
  
  my $app   = sub { ... };

  # Optionally ($proposedResponse is the PSGI response of Lemonldap::NG handler
  #sub on_reject {
  #    my($self,$env,$proposedResponse) = @_;
  #    ...
  #}
  
  builder
  {
    enable "Auth::LemonldapNG";
    # Or with some LLNG args or a reject sub
    #enable "Auth::LemonldapNG",
    #  llparams => {
    #    configStorage => ...
    #  },
    #  on_reject => \&on_reject;
    $app;
  };
