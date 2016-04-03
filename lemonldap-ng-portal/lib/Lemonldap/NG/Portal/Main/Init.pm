##@class Lemonldap::NG::Portal::Main::Init
# Initialization part of Lemonldap::NG portal
#
# 2 public methods:
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

# Macros and groups
has _macros => ( is => 'rw' );
has _groups => ( is => 'rw' );

# Lists to store plugins entry-points
has beforeAuth => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);
has betweenAuthAndDatas => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);
has afterDatas => (
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

    # Handle requests (other path may be declared in enabled plugins)
    $self

      # "/"
      ->addUnauthRoute( '*', 'login',     ['GET'] )
      ->addUnauthRoute( '*', 'postLogin', ['POST'] )
      ->addAuthRoute( '*', 'authenticatedRequest', ['GET'] )

      # Core REST API
      ->addUnauthRoute( 'test', 'pleaseAuth', ['GET'] )
      ->addAuthRoute( 'test', 'authenticated', ['GET'] );

    # Default routes must point to routines declared above
    $self->defaultAuthRoute('');
    $self->defaultUnauthRoute('');
    return $self->reloadConf($args);
}

sub reloadConf {
    my ($self) = @_;

    my $conf = HANDLER->lmConf->{cfgNum};

    # Delete keys that will be generated
    foreach my $key (
        qw(persistentStorage samlStorage casStorage captchaStorage oidcStorage)
      )
    {
        delete $self->conf->{$key};
    }

    # Reinitialize arrays
    foreach (
        qw(_macros _groups beforeAuth betweenAuthAndDatas afterDatas forAuthUser)
      )
    {
        $self->{$_} = [];
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
        my $module = '::' . ucfirst($type) . '::' . $self->conf->{$type};
        $module =~ s/Authentication/Auth/;

        # Launch and initialize module
        return 0
          unless ( $self->{"_$type"} = $self->loadModule($module)
            and $self->{"_$type"}->init );
    }
    $self->_authentication->authnLevel(
        $self->conf->{ $self->conf->authentication . "AuthnLevel" } );

    # Initialize trusted domain regexp
    if ( $self->conf->{trustedDomains} =~ /^\s*\*\s*$/ ) {
        $self->trustedDomains(qr#^https?://#);
    }
    else {
        my $re = Regexp::Assemble->new();
        if ( my $td = $self->conf->{trustedDomains} ) {
            $td =~ s/^\s*(.*?)\s*/$1/;
            $self->lmLog( "Domain $_ added in trusted domains", 'debug' );
            foreach ( split( /\s+/, $td ) ) {
                s#^\.#([^/]+\.)?#;
                s/\./\\./;
                $re->add($_);
            }
        }
        foreach my $vhost ( keys %{ $self->conf->{locationRules} } ) {
            $self->lmLog( "Vhost $vhost added in trusted domains", 'debug' );
            $re->add( quotemeta($vhost) );
            if ( my $tmp =
                $self->conf->{vhostOptions}->{$vhost}->{vhostAliases} )
            {
                foreach my $alias ( split /\s+/, $tmp ) {
                    $self->lmLog( "Alias $alias added in trusted domains",
                        'debug' );
                    $re->add( quotemeta($alias) );
                }
            }
        }
        my $tmp = 'https?://' . $re->as_string . '(?:/|$)';
        $self->trustedDomains(qr/$tmp/);
    }
    if ( my $td = $self->conf->{trustedDomains} ) {
        $td =~ s/^\s*(.*?)\s*/$1/;
        if ( $td eq '*' ) {
            $self->trustedDomains(qr#^https?://#);
        }
        else {
            my $tmp =
              join( '|', map { s#^\.#([^/]+\.)?# } split( /\s+/, $td ) );
            $tmp =~ s/\./\\./g;
            $self->trustedDomains(qr#^https?://$tmp(?:\d+)?(?:/|$)#);
        }
    }

    # TODO: compile macros in _macros, groups in _groups

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
      unless ( $obj = $self->loadModule("$plugin") );
    foreach my $sub (
        qw(beforeAuthProcess addSessionData afterAuthProcess forAuthUser))
    {
        if ( $obj->can($sub) ) {
            if ( my $callback = $obj->$sub ) {
                push @{ $self->{$sub} }, sub { $obj->$callback( $_[1] ) };
            }
        }
    }
    return $obj->init;
}

sub loadModule {
    my ( $self, $module ) = @_;
    my $obj;
    $module = "Lemonldap::NG::Portal$module" if ( $module =~ /^::/ );

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
