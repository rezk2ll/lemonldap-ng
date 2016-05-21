##@class Lemonldap::NG::Portal::Main::Init
# Initialization part of Lemonldap::NG portal
#
# 2 public methods:
#  - init():       launch at startup. Load 'portal' section of lemonldap-ng.ini,
#                  initialize default route and launch reloadConf()
#  - reloadConf(): (re)load configuration using localConf (ie 'portal' section
#                  of lemonldap-ng.ini) and underlying handler configuration
package Lemonldap::NG::Portal::Main::Init;

our $VERSION = '2.0.0';

package Lemonldap::NG::Portal::Main;

use strict;
use Mouse;
use Regexp::Assemble;

# Configuration storage
has localConfig => ( is => 'rw', default => sub { {} } );
has conf        => ( is => 'rw', default => sub { {} } );
has menu        => ( is => 'rw', default => sub { {} } );

# Sub modules
has _authentication => ( is => 'rw' );
has _userDB         => ( is => 'rw' );

# Macros and groups
has _macros => ( is => 'rw' );
has _groups => ( is => 'rw' );

# TrustedDomain regexp
has trustedDomains => ( is => 'rw' );

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
has beforeLogout => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);

sub init {
    my ( $self, $args ) = @_;
    $args ||= {};
    $self->localConfig(
        {
            %{ Lemonldap::NG::Common::Conf->new( $args->{configStorage} )
                  ->getLocalConf('portal')
            },
            %$args
        }
    );
    Lemonldap::NG::Handler::Main::Reload->onReload( $self, 'reloadConf' );
    return 0 unless ( $self->SUPER::init($args) );
    return 0 if ( $self->error );

    # Handle requests (other path may be declared in enabled plugins)
    $self

      # "/"
      ->addUnauthRoute( '*' => 'login',     ['GET'] )
      ->addUnauthRoute( '*' => 'postLogin', ['POST'] )
      ->addAuthRoute( '*' => 'authenticatedRequest',     ['GET'] )
      ->addAuthRoute( '*' => 'postAuthenticatedRequest', ['POST'] )

      # Core REST API
      ->addUnauthRoute( ping => 'pleaseAuth', ['GET'] )
      ->addAuthRoute( ping => 'authenticated', ['GET'] )

      # Logout
      ->addAuthRoute( logout => 'logout', ['GET'] );

    # Default routes must point to routines declared above
    $self->defaultAuthRoute('');
    $self->defaultUnauthRoute('');
    1;
}

sub reloadConf {
    my ( $self, $conf ) = @_;

    # Reinitialize $self->conf
    %{ $self->{conf} } = %{ $self->localConfig };

    # Reinitialize arrays
    foreach (
        qw(_macros _groups beforeAuth betweenAuthAndDatas afterDatas forAuthUser)
      )
    {
        $self->{$_} = [];
    }

    # Load conf in portal object
    foreach my $key ( keys %$conf ) {
        $self->{conf}->{$key} ||= $conf->{$key};
    }

    # Initialize templateDir
    $self->{templateDir} =
      $self->conf->{templateDir} . '/' . $self->conf->{portalSkin};

    $self->{staticPrefix} = $self->conf->{staticPrefix} || '/';
    $self->{languages} = $self->conf->{languages} || '/';

    # Initialize session DBs
    unless ( $self->conf->{globalStorage} ) {
        $self->error(
            'globalStorage not defined (perhaps configuration can not be read)'
        );
        return 0;
    }

    # Initialize persistent session DB
    unless ( $self->conf->{persistentStorage} ) {
        $self->conf->{persistentStorage} = $self->conf->{globalStorage};
        $self->conf->{persistentStorageOptions} =
          $self->conf->{globalStorageOptions};
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
        $self->conf->{ $self->conf->{authentication} . "AuthnLevel" } );

    # Initialize trusted domain regexp
    if (    $self->conf->{trustedDomains}
        and $self->conf->{trustedDomains} =~ /^\s*\*\s*$/ )
    {
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

    # Compile macros in _macros, groups in _groups
    foreach my $type (qw(macros groups)) {
        $self->{"_$type"} = {};
        if ( $self->conf->{$type} ) {
            for my $name ( sort keys %{ $self->conf->{$type} } ) {
                my $sub =
                  HANDLER->tsv->{jail}->jail_reval( "sub{return("
                      . HANDLER->substitute( $self->conf->{$type}->{$name} )
                      . ")}" );
                if ($sub) {
                    $self->{"_$type"}->{$name} = $sub;
                }
                else {
                    $self->lmLog(
                        "$type $name returns an error: "
                          . HANDLER->tsv->{jail}->error,
                        'error'
                    );
                }
            }
        }
    }

    # Load plugins
    foreach my $plugin ( $self->enabledPlugins ) {
        $self->loadPlugin($plugin) or return 0;
    }

    $self->menu( $self->loadModule('::Main::Menu') );
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
