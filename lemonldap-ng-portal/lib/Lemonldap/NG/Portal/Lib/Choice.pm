package Lemonldap::NG::Portal::Lib::Choice;

use strict;
use Mouse;

extends 'Lemonldap::NG::Portal::Lib::Wrapper';

our $VERSION = '2.0.0';

has modules => ( is => 'rw', default => sub { {} } );

# INITIALIZATION

# init() must be called by module::init() with a number:
#  - 0 for auth
#  - 1 for userDB
#  - 2 for passwordDB ?
sub init {
    my ( $self, $type ) = @_;

    foreach my $name ( keys %{ $self->conf->{authChoiceModules} } ) {
        my @mods =
          split( /[;\|]/, $self->conf->{authChoiceModules}->{$name} );
        my $module =
            '::'
          . [ 'Auth', 'UserDB', 'Password' ]->[$type] . '::'
          . $mods[$type];
        if ( $module = $self->loadPlugin( $name, $module ) ) {
            $self->modules->{$name} = $module;
            $self->p->lmLog(
                [qw(Authentication User Password)]->[$type]
                  . " module $name selected",
                'debug'
            );
        }
        else {
            # error() is set by underlying module
            return 0;
        }
    }
    return 1;
}

sub checkChoice {
    my ( $self, $req ) = @_;
    return $req->sessionInfo->{_choice} if ( $req->sessionInfo->{_choice} );
    my $name = $req->param( $self->conf->{authChoiceParam} ) or return 0;
    unless ( defined $self->modules->{$name} ) {
        $self->lmLog( "Unknown choice '$name'", 'error' );
        return 0;
    }
    $req->sessionInfo->{_choice} = $name;
    $req->datas->{enabledMods}   = [ $self->modules->{$name} ];
    $self->p->_authentication->authnLevel("${name}AuthnLevel");
    return 1;
}

package Lemonldap::NG::Portal::Simple;

# Build authentication loop displayed in template
# Return authLoop array reference
sub _buildAuthLoop {
    my ( $self, $req ) = @_;
    my @authLoop;

    # Test authentication choices
    unless ( ref $self->conf->{authChoiceModules} eq 'HASH' ) {
        $self->lmLog( "No authentication choices defined", 'warn' );
        return [];
    }

    foreach ( sort keys %{ $self->conf->{authChoiceModules} } ) {

        my $name = $_;

        # Ignore 'forcedSAML'
        next if $name eq 'forcedSAML';

        # Name can have a digit as first character
        # for sorting purpose
        # Remove it in displayed name
        $name =~ s/^(\d*)?(\s*)?//;

        # Replace also _ by space for a nice display
        $name =~ s/\_/ /g;

        # Find modules associated to authChoice
        my ( $auth, $userDB, $passwordDB, $url ) =
          split( /[;\|]/, $self->conf->{authChoiceModules}->{$_} );

        if ( $auth and $userDB and $passwordDB ) {

            # Default URL
            $url = ( defined $url ? $url .= $ENV{'REQUEST_URI'} : '#' );
            $self->lmLog( "Use URL $url", 'debug' );

            # Options to store in the loop
            my $optionsLoop =
              { name => $name, key => $_, module => $auth, url => $url };

            # Get displayType for this module
            my $displayType =
              &{"Lemonldap::NG::Portal::Auth::${auth}::getDisplayType"};

            $self->lmLog( "Display type $displayType for module $auth",
                'debug' );
            $optionsLoop->{$displayType} = 1;

            # If displayType is logo, check if key.png is available
            if (
                -e $self->getApacheHtdocsPath . "/skins/common/" . $_ . ".png" )
            {
                $optionsLoop->{logoFile} = $_ . ".png";
            }
            else { $optionsLoop->{logoFile} = $auth . ".png"; }

            # Register item in loop
            push @authLoop, $optionsLoop;

            $self->lmLog( "Authentication choice $name will be displayed",
                'debug' );
        }

        else {
            $req->error("Authentication choice $_ value is invalid");
            return 0;
        }

    }

    return \@authLoop;

}

1;

