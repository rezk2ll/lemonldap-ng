##@class Lemonldap::NG::Portal::Main::Init
# Initialization part of Lemonldap::NG portal
#
# 2 methods:
#  - init():       launch at startup. Load 'portal' section of lemonldap-ng.ini,
#                  initialize default route and launch reloadConf()
#  - reloadConf(): (re)load configuration using localConf (ie 'portal' section
#                  of lemonldap-ng.ini) and underlying handler configuration
package Lemonldap::NG::Portal::Main::Init;

use strict;
use Mouse;
use Lemonldap::NG::Common::Conf::Constants;
use Lemonldap::NG::Handler::Main::Reload qw/keepConf/;
use Lemonldap::NG::Portal::Main::Plugins;

our $VERSION = '2.0.0';

use constant HANDLER => 'Lemonldap::NG::Handler::PSGI::API';

# Configuration storage
has localConfig => ( is => 'rw', default => sub { {} } );
has conf        => ( is => 'rw', default => sub { {} } );

# Sub modules
has _authentication => ( is => 'rw' );
has _userDB         => ( is => 'rw' );

# Lists to store plugins entry-points
has beforeAuthProcess => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);
has addSessionData => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);
has afterAuthProcess => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);
has forAuthUser => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);

sub init {
    my ( $self, $args ) = @_;
    $args ||= {};
    return 0 unless ( $self->SUPER::init( { conf => $args } ) );
    $self->localConfig(
        { %{ HANDLER->confAcc->getLocalConf('portal') }, %$args } );

    # Handle default requests (other path may be declared in enabled plugins)
    $self->addAuthRoute('*'=>'menu');
    $self->addUnauthRoute('*'=>'login');

    # Default routes must point to routines declared above
    $self->defaultAuthRoute('');
    $self->defaultUnauthRoute('');
    return $self->reloadConf($args);
}

sub reloadConf {
    my ( $self ) = @_;

    my $conf = HANDLER->lmConf->{cfgNum};

    # Delete keys that will be generated
    foreach my $key (
        qw(persistentStorage samlStorage casStorage captchaStorage oidcStorage)
      )
    {
        delete $self->conf->{$key};
    }

    # Load conf in portal object
    foreach my $key ( keys %$conf ) {
        $self->conf->{$key} =
          $self->localConfig->{$key} // $conf->{$key};
    }

    # Initialize session DBs
    unless ( $self->conf->{globalStorage} ) {
        $self->error(
            'globalStorage not defined (perhaps configuration can not be read)'
        );
        return 0;
    }

    # Initialize cookie domain
    unless ( $self->conf->{domain} ) {
        $self->error('Configuration error: no domain');
        return 0;
    }
    $self->conf->{domain} =~ s/^([^\.])/.$1/;

    # Load authentication/userDB
    # --------------------------
    for my $type (qw(authentication userDB)) {
        unless ( $self->conf->{$type} ) {
            $self->error("$type is not set");
            return 0;
        }
        my $module = ucfirst($type) . $self->conf->{$type};
        $module =~ s/\s.*$//;
        $module =~ s/^Authentication/Auth/;
        $module = "Lemonldap::NG::Portal::$module";

        # $self->conf->{authentication} and $self->conf->{userDB} can
        # contains arguments (key1 = scalar_value; key2 = ...)
        my ( $tmp, %h ) = split( /\s*[=;]\s*/, $self->conf->{$type} );
        %{ $self->{conf} } = ( %h, %{ $self->{conf} } ) if (%h);

        # Launch and initialize module
        return 0
          unless ( $self->{"_$type"} = $self->loadModule($module)
            and $self->{"_$type"}->init );
    }

    # Initialize trusted domain list
    $self->conf->{trustedDomains} ||= "";
    $self->conf->{trustedDomains} = "*"
      if ( $self->conf->{trustedDomains} =~ /(^|\s)\*(\s|$)/ );
    if (    $self->conf->{trustedDomains}
        and $self->conf->{trustedDomains} ne "*" )
    {
        $self->conf->{trustedDomains} =~ s#(^|\s+)\.#${1}[^/]+.#g;
        $self->conf->{trustedDomains} = '('
          . join( '|', split( /\s+/, $self->conf->{trustedDomains} ) ) . ')';
        $self->conf->{trustedDomains} =~ s/\./\\./g;
    }

    # Load plugins
    foreach my $plugin ( $self->enabledPlugins ) {
        $self->loadPlugin($plugin) or return 0;
    }
    1;
}

sub loadPlugin {
    my ( $self, $plugin ) = @_;
    my $obj;
    return 0
      unless ( $obj =
        $self->loadModule("Lemonldap::NG::Portal::Plugins::$plugin") );
    foreach my $sub (
        qw(beforeAuthProcess addSessionData afterAuthProcess forAuthUser))
    {
        if ( $obj->can($sub) ) {
            push @{ $self->{$sub} }, $obj->$sub;
        }
    }
    return $obj->init;
}

sub loadModule {
    my ( $self, $module ) = @_;
    my $obj;

    eval "require $module";
    if ($@) {
        $self->error("$module load error: $@");
        return 0;
    }
    eval {
        $obj = $module->new( { p => $self, conf => $self->conf } );
        $self->lmLog( "Module $module loaded", 'debug' );
    };
    if ($@) {
        $self->error("Unable to build $module object: $@");
        return 0;
    }
    return $obj;
}

1;
