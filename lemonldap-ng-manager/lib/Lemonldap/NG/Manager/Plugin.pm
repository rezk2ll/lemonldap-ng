package Lemonldap::NG::Manager::Plugin;

use strict;
use Mouse;
use Lemonldap::NG::Common::UserAgent;
use Lemonldap::NG::Common::Conf::Constants;
use URI::URL;

our $VERSION = '2.18.0';

extends 'Lemonldap::NG::Common::Module';

has _confAcc => (
    is      => 'rw',
    lazy    => 1,
    default => sub { return $_[0]->p->{_confAcc} },
);

has ua => (
    is      => 'rw',
    lazy    => 1,
    builder => sub {
        Lemonldap::NG::Common::UserAgent->new( $_[0]->{conf} );
    }
);

# Icon from https://www.w3schools.com/icons/bootstrap_icons_glyphicons.asp
use constant icon => 'wrench';

sub sendError {
    my $self = shift;
    return $self->p->sendError(@_);
}

sub sendJSONresponse {
    my $self = shift;
    return $self->p->sendJSONresponse(@_);
}

sub addRoute {
    my ( $self, $word, $subName, $methods, $transform ) = @_;
    $transform //= sub {
        my ($sub) = @_;
        if ( ref $sub ) {
            return sub {
                shift;
                return $sub->( $self, @_ );
            }
        }
        else {
            return sub {
                shift;
                return $self->$sub(@_);
            }
        }
    };
    $self->p->addRoute( $word, $subName, $methods, $transform );
    return $self;
}

sub loadTemplate {
    my $self = shift;
    return $self->p->loadTemplate(@_);
}

## @method private applyConf()
# Try to inform other servers declared in `reloadUrls` that a new
# configuration is available.
#
#@return reload status as boolean
sub applyConf {
    my ( $self, $newConf ) = @_;
    if ( $self->p->api->tsv->{msgBrokerWriter}
        and my $sub = $self->p->api->tsv->{msgBrokerWriter}->can('applyConf') )
    {
        return $sub->( $self, $newConf );
    }
    return {};
}

1;
