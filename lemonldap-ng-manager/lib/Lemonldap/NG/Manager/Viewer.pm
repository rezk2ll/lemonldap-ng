package Lemonldap::NG::Manager::Viewer;

use 5.10.0;
use utf8;
use Mouse;
use Lemonldap::NG::Common::Conf::Constants;
use Lemonldap::NG::Common::UserAgent;
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

    my $hiddenPK = '';
    $hiddenPK = $self->{viewerHiddenPK} || $conf->{viewerHiddenPK};
    my @enabledPK = ();
    my @keys      = qw(virtualHosts samlIDPMetaDataNodes samlSPMetaDataNodes
      applicationList oidcOPMetaDataNodes oidcRPMetaDataNodes
      casSrvMetaDataNodes casAppMetaDataNodes
      authChoiceModules grantSessionRules combModules
      openIdIDPList);

    foreach (@keys) {

        # Ignore hidden ConfTree Primary Keys
        push @enabledPK, $_
          unless ( $hiddenPK =~ /\b$_\b/ );
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
      );

    foreach ( split /\s+/, $hiddenPK ) {
        $self->addRoute(
            view => { ':cfgNum' => { $_ => 'rejectKey' } },
            ['GET']
        );
    }
    unless ( $self->{viewerAllowBrowser} || $conf->{viewerAllowBrowser} ) {
        $self->addRoute(
            view => { ':cfgNum' => 'rejectKey' },
            ['GET']
        );
    }

    # Other keys
    $self->addRoute( view => { ':cfgNum' => { '*' => 'getKey' } }, ['GET'] )

      # Difference between confs
      ->addRoute( diff => { ':conf1' => { ':conf2' => 'diff' } } )
      ->addRoute( 'diff.html', undef, ['GET'] );
}

sub getConfByNum {
    my ( $self, $cfgNum, @args ) = @_;
    $self->SUPER::getConfByNum( $cfgNum, @args );
}

sub diff {
    my ( $self, $req, @path ) = @_;
    $self->SUPER::diff( $req, @path );
}

sub rejectKey {
    my ( $self, $req ) = @_;
    return $self->sendJSONresponse( $req, { 'value' => '_Hidden_' } );
}

1;
