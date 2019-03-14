# This module implements all the methods that responds to '/confs/*' requests
# It contains 2 sections:
#  - initialization methods
#  - upload method
#
# Read methods are inherited from Lemonldap::NG::Common::Conf::RESTServer
package Lemonldap::NG::Manager::Viewer;

use 5.10.0;
use utf8;
use Mouse;
use Lemonldap::NG::Common::Conf::Constants;
use Lemonldap::NG::Common::UserAgent;
use Crypt::OpenSSL::RSA;
use Convert::PEM;
use URI::URL;

use feature 'state';

extends 'Lemonldap::NG::Manager::Conf';

our $VERSION = '2.0.3';

#############################
# I. INITIALIZATION METHODS #
#############################

use constant defaultRoute => 'viewer.html';

has ua => ( is => 'rw' );

sub addRoutes {
    my ( $self, $conf ) = @_;
    $self->ua( Lemonldap::NG::Common::UserAgent->new($conf) );

    my @enabledPK = ();
    my @keys      = qw(virtualHosts samlIDPMetaDataNodes samlSPMetaDataNodes
      applicationList oidcOPMetaDataNodes oidcRPMetaDataNodes
      casSrvMetaDataNodes casAppMetaDataNodes
      authChoiceModules grantSessionRules combModules
      openIdIDPList);

    foreach (@keys) {

        # Ignore hidden ConfTree Primary Keys
        push @enabledPK, $_
          unless ( $conf->{viewerHiddenPK} =~ /\b$_\b/ );
    }

    # HTML template
    $self->addRoute( 'viewer.html', undef, ['GET'] )

      # READ
      # Special keys
      ->addRoute(
        view => {
            ':cfgNum' => \@enabledPK
        },
        ['GET']
      )

      # Other keys
      ->addRoute( view => { ':cfgNum' => { '*' => 'getKey' } }, ['GET'] );
}

sub prx {
    my ( $self, $req, @others ) = @_;
    $self->SUPER::prx( $req, @others );
}

sub getConfByNum {
    my ( $self, $cfgNum, @args ) = @_;
    $self->SUPER::getConfByNum( $cfgNum, @args );
}

sub diff {
    my ( $self, $req, @path ) = @_;
    $self->SUPER::diff( $req, @path );
}

1;
