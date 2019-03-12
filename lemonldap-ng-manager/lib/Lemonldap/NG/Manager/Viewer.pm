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

extends 'Lemonldap::NG::Common::Conf::RESTServer';

our $VERSION = '2.0.2';

#############################
# I. INITIALIZATION METHODS #
#############################

use constant defaultRoute => 'viewer.html';

has ua => ( is => 'rw' );

sub addRoutes {
    my ( $self, $conf ) = @_;
    $self->ua( Lemonldap::NG::Common::UserAgent->new($conf) );

    # HTML template
    $self->addRoute( 'viewer.html', undef, ['GET'] )

      # READ
      # Special keys
      ->addRoute(
        confs => {
            ':cfgNum' => [
                qw(virtualHosts samlIDPMetaDataNodes samlSPMetaDataNodes
                  applicationList oidcOPMetaDataNodes oidcRPMetaDataNodes
                  casSrvMetaDataNodes casAppMetaDataNodes
                  authChoiceModules grantSessionRules combModules
                  openIdIDPList)
            ]
        },
        ['GET']
      )

      # Other keys
      ->addRoute( confs => { ':cfgNum' => { '*' => 'getKey' } }, ['GET'] )

      # Difference between confs
      ->addRoute( diff => { ':conf1' => { ':conf2' => 'diff' } } )
      ->addRoute( 'diff.html', undef, ['GET'] )
}

# 35 - New RSA key pair on demand
#      --------------------------


# 36 - URL File loader
#      ---------------

##@method public PSGI-JSON-response prx()
# Load file using posted URL and return its content
#
#@return PSGI JSON response
sub prx {
    my ( $self, $req, @others ) = @_;
    return $self->sendError( $req, 'There is no subkey for "prx"', 400 )
      if (@others);
    my $query = $req->jsonBodyToObj;
    return $self->sendError( $req, 'Missing parameter', 400 )
      unless ( $query->{url} );
    return $self->sendError( $req, 'Bad parameter', 400 )
      unless ( $query->{url} =~ m#^(?:f|ht)tps?://\w# );
    $self->ua->timeout(10);

    my $response = $self->ua->get( $query->{url} );
    unless ( $response->code == 200 ) {
        return $self->sendError( $req,
            $response->code . " (" . $response->message . ")", 400 );
    }
    unless ( $response->header('Content-Type') =~
        m#^(?:application/json|(?:application|text)/.*xml).*$# )
    {
        return $self->sendError( $req,
            'Content refused for security reason (neither XML or JSON)', 400 );
    }
    return $self->sendJSONresponse( $req, { content => $response->content } );
}

######################
# IV. Upload methods #
######################

#  - getConfByNum: override SUPER method to be able to use Zero


sub getConfByNum {
    my ( $self, $cfgNum, @args ) = @_;
    unless ( %{ $self->currentConf }
        and $cfgNum == $self->currentConf->{cfgNum} )
    {
        my $tmp;
        if ( $cfgNum == 0 ) {
            require Lemonldap::NG::Manager::Conf::Zero;
            $tmp = Lemonldap::NG::Manager::Conf::Zero::zeroConf();
            $self->currentConf($tmp);
        }
        else {
            $tmp = $self->SUPER::getConfByNum( $cfgNum, @args );
            return undef unless ( defined $tmp );
        }
    }
    return $cfgNum;
}

sub diff {
    my ( $self, $req, @path ) = @_;
    return $self->sendError( $req, 'to many arguments in path info', 400 )
      if (@path);
    my @cfgNum =
      ( scalar( $req->param('conf1') ), scalar( $req->param('conf2') ) );
    my @conf;
    $self->logger->debug(" Loading confs");

    # Load the 2 configurations
    for ( my $i = 0 ; $i < 2 ; $i++ ) {
        if ( %{ $self->currentConf }
            and $cfgNum[$i] == $self->currentConf->{cfgNum} )
        {
            $conf[$i] = $self->currentConf;
        }
        else {
            $conf[$i] = $self->confAcc->getConf(
                { cfgNum => $cfgNum[$i], raw => 1, noCache => 1 } );
            return $self->sendError(
                $req,
"Configuration $cfgNum[$i] not available $Lemonldap::NG::Common::Conf::msg",
                400
            ) unless ( $conf[$i] );
        }
    }
    require Lemonldap::NG::Manager::Conf::Diff;
    return $self->sendJSONresponse(
        $req,
        [
            $self->Lemonldap::NG::Manager::Conf::Diff::diff(
                $conf[0], $conf[1]
            )
        ]
    );
}

1;
