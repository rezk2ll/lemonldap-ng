##@file
# FastCGI package for Lemonldap::NG portal
#
##@class Lemonldap::NG::Portal::Main::Init
# FastCGI class for Lemonldap::NG portal
package Lemonldap::NG::Portal::Main::Init;

use strict;
use Mouse;
use Lemonldap::NG::Common::Conf::Constants;
use Lemonldap::NG::Handler::Main::Reload qw/keepConf/;

our $VERSION = '2.0.0';

use constant HANDLER => 'Lemonldap::NG::Handler::PSGI::API';

# Configuration storage
has localConfig => ( is => 'rw', default => sub { {} } );
has conf        => ( is => 'rw', default => sub { {} } );

# Sub modules
has _authentication => ( is => 'rw' );
has _userDB         => ( is => 'rw' );
has _passwordDB     => ( is => 'rw' );
has _registerDB     => ( is => 'rw' );

has _issuers => ( is => 'rw' );

sub init {
    my ( $self, $args ) = @_;
    $args ||= {};
    return 0 unless ( $self->SUPER::init($args) );
    $self->localConfig(
        { %{ HANDLER->confAcc->getLocalConf('portal') }, %$args } );
    return $self->checkConf($args);
}

sub checkConf {
    my ( $self, $args ) = @_;

    # If handler configuration has changed, apply it
    if (  !$self->conf->{cfgNum}
        or $self->conf->{cfgNum} ne ( my $conf = HANDLER->lmConf->{cfgNum} ) )
    {

        # Delete keys that will be generated
        foreach my $key (
            qw(persistentStorage samlStorage casStorage captchaStorage oidcStorage)
          )
        {
            delete $self->conf->{$key};
        }

        # Load conf in portal object
        foreach my $key ( keys %$conf ) {
            $self->conf->{$key} = $self->localConfig->{$key} // $conf->{$key};
        }

        # Initialize session DBs
        unless ( $self->conf->{globalStorage} ) {
            $self->error(
'globalStorage not defined (perhaps configuration can not be read)'
            );
            return 0;
        }
        foreach my $key (
            qw(persistentStorage samlStorage casStorage captchaStorage oidcStorage)
          )
        {
            unless ( $self->conf->{$key} ) {
                $self->conf->{$key} = $self->conf->{globalStorage};
                $self->conf->{ $key . 'Options' } =
                  $self->conf->{globalStorageOptions};
            }
        }

        # Initialize cookie domain
        unless ( $self->conf->{domain} ) {
            $self->error('Configuration error: no domain');
            return 0;
        }
        $self->conf->{domain} =~ s/^([^\.])/.$1/;

        # Load authentication/userDB/passwordDB modules
        # ---------------------------------------------
        for my $type (qw(authentication userDB passwordDB registerDB)) {
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
            return 0 unless ( $self->loadModule( $module, "_$type" ) );
        }

        # Load issuer modules
        # -------------------
        foreach my $issuerDBtype (qw(SAML OpenID CAS OpenIDConnect)) {
            my $module = 'Lemonldap::NG::Portal::IssuerDB' . $issuerDBtype;
            $self->lmLog(
                "[IssuerDB activation] Try issuerDB module $issuerDBtype",
                'debug' );
            unless ( $self->conf->{"issuerDB${issuerDBtype}Activation"} ) {
                $self->lmLog(
"[IssuerDB activation] Activation flag set to off, trying next",
                    'debug'
                );
                next;
            }

            #TODO: regexp ?
            my $path = $self->conf->{"issuerDB${issuerDBtype}Path"};
            unless ($path) {
                $self->lmLog(
"[IssuerDB activation] no path found for ${issuerDBtype}. Skipping",
                    'notice'
                );
                next;
            }

            return 0 unless ( $self->loadModule( $module, 'tmp' ) );
            $self->{issuers}->{$issuerDBtype} = $self->{tmp};
            delete $self->{tmp};
            $self->addAuthRoute(
                $path,
                sub {
                    my $self = shift;
                    return $self->issuerForAuthUser( $issuerDBtype, @_ );
                },
                [qw(GET POST PUT DELETE)]
            );
            $self->addUnauthRoute(
                $path,
                sub {
                    my $self = shift;
                    return $self->issuerForUnauthUser( $issuerDBtype, @_ );
                },
                [qw(GET POST PUT DELETE)]
            );

            # TODO "check the path"
        }
        $self->conf->{trustedDomains} ||= "";
        $self->conf->{trustedDomains} = "*"
          if ( $self->conf->{trustedDomains} =~ /(^|\s)\*(\s|$)/ );
        if (    $self->conf->{trustedDomains}
            and $self->conf->{trustedDomains} ne "*" )
        {
            $self->conf->{trustedDomains} =~ s#(^|\s+)\.#${1}[^/]+.#g;
            $self->conf->{trustedDomains} = '('
              . join( '|', split( /\s+/, $self->conf->{trustedDomains} ) )
              . ')';
            $self->conf->{trustedDomains} =~ s/\./\\./g;
        }
    }
    1;
}

##@method boolean loadModule(string module, boolean ignoreError)
# Load a module into portal namespace
# @param module module name
# @param ignoreError set to 1 if error should not appear in logs
# @return boolean
sub loadModule {
    my ( $self, $module, $keyname ) = @_;

    # Load module test
    eval "require $module";
    if ($@) {
        $self->error("$module load error: $@");
        return 0;
    }
    eval {
        $self->{$keyname} = $module->new( { p => $self, conf => $self->conf } );
    };
    if ($@) {
        $self->error("Unable to build $module object: $@");
        return 0;
    }
    return 0 unless ( $self->{$keyname} );
    $self->lmLog( "Module $module loaded", 'debug' );

    return 1;
}

1;
