package Lemonldap::NG::Common::PSGI::Router;

use Mouse;
use Lemonldap::NG::Common::PSGI;
use Lemonldap::NG::Common::PSGI::Constants;

our $VERSION = '1.9.0';

extends 'Lemonldap::NG::Common::PSGI';

# Properties
has 'routes' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { { GET => {}, POST => {}, PUT => {}, DELETE => {} } }
);
has 'defaultRoute' => ( is => 'rw', default => 'index.html' );

# Routes initialization

sub addRoute {
    my ( $self, $word, $dest, $methods ) = splice(@_);
    $methods ||= [qw(GET POST PUT DELETE)];
    foreach my $method (@$methods) {
        $self->genRoute( $self->routes->{$method}, $word, $dest );
    }
    return $self;
}

sub genRoute {
    my ( $self, $routes, $word, $dest ) = splice @_;
    if ( ref $word eq 'ARRAY' ) {
        foreach my $w (@$word) {
            $self->genRoute( $routes, $w, $dest );
        }
    }
    else {
        if ( $word =~ /^:(.*)$/ ) {
            $routes->{'#'} = $1;
            die "Target required for $word" unless ($dest);
            $word = ':';
        }
        else {
            $dest ||= $word;
        }
        if ( my $t = ref $dest ) {
            if ( $t eq 'CODE' ) {
                $routes->{$word} = $dest;
            }
            elsif ( $t eq 'HASH' ) {
                $routes->{$word} ||= {};
                foreach my $w ( keys %$dest ) {
                    $self->genRoute( $routes->{$word}, $w, $dest->{$w} );
                }
            }
            elsif ( $t eq 'ARRAY' ) {
                $routes->{$word} ||= {};
                foreach my $w ( @{$dest} ) {
                    $self->genRoute( $routes->{$word}, $w );
                }
            }
            else {
                die "Type $t unauthorizated in routes";
            }
        }
        elsif ( $dest =~ /^(.+)\.html$/ ) {
            my $tpl = $1 or die;
            $routes->{$word} = sub { $self->sendHtml( $_[1], $tpl ) };
        }
        elsif ( $self->can($dest) ) {
            $routes->{$word} = sub { shift; $self->$dest(@_) };
        }
        else {
            die "$dest() isn't a method";
        }
        $self->lmLog( "route $word added", 'debug' );
    }
}

sub routerAbort {
    my ( $self, $path, $msg ) = splice @_;
    delete $self->routes->{$path};
    $self->addRoute(
        $path => sub {
            my ( $self, $req ) = splice @_;
            return $self->sendError( $req, $msg, 500 );
        }
    );
}

# Methods that dispatch requests

sub router {
    my ( $self, $req ) = splice @_;

    #print STDERR Dumper($self->routes);use Data::Dumper;

    # Reinitialize configuration message
    $Lemonldap::NG::Common::Conf::msg = '';

    # Launch reqInit() if exists
    if ( $self->can('reqInit') ) {
        $self->reqInit($req);
    }

    # Only words are taken in path
    my @path = grep { $_ =~ /^[\.\w]+/ } split /\//, $req->path();
    $self->lmLog( "Start routing " . ( $path[0] // 'default route' ), 'debug' );

    unless (@path) {
        push @path, $self->defaultRoute;

        # TODO: E-Tag, Expires,...
        #
        ## NB: this is not HTTP compliant: host and protocol are required !
        #my $url = '/' . $self->defaultRoute;
        #return [
        #    302,
        #    [ 'Content-Type' => 'text/plain', 'Location' => $url ],
        #    ['Document has moved here: $url']
        #];
    }
    return $self->followPath( $req, $self->routes->{ $req->method }, \@path );
}

sub followPath {
    my ( $self, $req, $routes, $path ) = splice @_;
    if ( $path->[0] and defined $routes->{ $path->[0] } ) {
        my $w = shift @$path;
        if ( ref( $routes->{$w} ) eq 'CODE' ) {
            return $routes->{$w}->( $self, $req, @$path );
        }
        return $self->followPath( $req, $routes->{$w}, $path );
    }
    elsif ( $routes->{':'} ) {
        my $v = shift @$path;
        $req->params->{ $routes->{'#'} } = $v;
        if ( ref( $routes->{':'} ) eq 'CODE' ) {
            return $routes->{':'}->( $self, $req, @$path );
        }
        return $self->followPath( $req, $routes->{':'}, $path );
    }
    elsif ( my $sub = $routes->{'*'} ) {
        return $self->$sub( $req, @$path );
    }
    else {
        $self->lmLog( 'Bad request received (' . $req->path . ')', 'warn' );
        return $self->sendError( $req, 'Bad request', 400 );
    }
}

1;
