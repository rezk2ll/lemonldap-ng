package Lemonldap::NG::Portal::Lib::Choice;

use strict;
use Mouse;
use Safe;

extends 'Lemonldap::NG::Portal::Lib::Wrapper';

our $VERSION = '2.0.0';

has modules => ( is => 'rw', default => sub { {} } );

has rules => ( is => 'rw', default => sub { {} } );

has type => ( is => 'rw' );

has catch => ( is => 'rw', default => sub { {} } );

has sessionKey => ( is => 'ro', default => '_choice' );

my $_choiceRules;

# INITIALIZATION

# init() must be called by module::init() with a number:
#  - 0 for auth
#  - 1 for userDB
#  - 2 for passwordDB ?
sub init {
    my ( $self, $type ) = @_;
    $self->type($type);

    unless ( $self->conf->{authChoiceModules}
        and %{ $self->conf->{authChoiceModules} } )
    {
        $self->error("'authChoiceModules' is empty");
        return 0;
    }

    foreach my $name ( keys %{ $self->conf->{authChoiceModules} } ) {
        my @mods =
          split( /[;\|]/, $self->conf->{authChoiceModules}->{$name} );
        my $module =
            '::'
          . [ 'Auth', 'UserDB', 'Password' ]->[$type] . '::'
          . $mods[$type];
        if ( $module = $self->loadPlugin( $name, $module ) ) {
            $self->modules->{$name} = $module;
            $self->logger->debug(
                [qw(Authentication User Password)]->[$type]
                  . " module $name selected" );
        }
        else {
            $self->logger->error(
                "Choice: unable to load $name, disabling it: " . $self->error );
            $self->error('');
        }

        # Test if auth module wants to catch some path
        unless ($type) {
            if ( $module->can('catch') ) {
                $self->catch->{$name} = $module->catch;
            }
        }

        # Display conditions
        my $safe = Safe->new;
        my $cond = $mods[4];
        if ( defined $cond ) {
            $self->logger->debug("Found a rule for $name");
            $_choiceRules->{$name} =
              $safe->reval("sub{my(\$env)=\@_;return ($cond)}");
            if ($@) {
                $self->logger->error("Bad condition $cond: $@");
                return 0;
            }
        }
        else {
            $self->logger->debug("No rule for $name");
            $_choiceRules->{$name} = sub { 1 };
        }
    }
    unless ( keys %{ $self->modules } ) {
        $self->error('Choice: no available modules found, aborting');
        return 0;
    }
    return 1;
}

sub checkChoice {
    my ( $self, $req ) = @_;
    my $name;
    foreach ( keys %{ $self->catch } ) {
        if ( $req->path_info =~ $self->catch->{$_} ) {
            $name = $_;
            last;
        }
    }
    $name ||=
         $req->userData->{_choice}
      || $req->sessionInfo->{_choice}
      || $req->pdata->{_choice}
      || $req->param( $self->conf->{authChoiceParam} )
      or return 0;
    unless ( defined $self->modules->{$name} ) {
        $self->logger->error("Unknown choice '$name'");
        return 0;
    }

    # Store choice if module loops
    $req->pdata->{_choice} = $name;
    return $name if ( $req->datas->{ "enabledMods" . $self->type } );
    $req->sessionInfo->{_choice} = $name;
    $req->datas->{ "enabledMods" . $self->type } = [ $self->modules->{$name} ];
    $self->p->_authentication->authnLevel("${name}AuthnLevel");
    return $name;
}

sub name {
    my ( $self, $req, $type ) = @_;
    unless ($req) {
        return 'Choice';
    }
    my $n = ref( $req->datas->{ "enabledMods" . $self->type }->[0] );
    $n =~ s/^Lemonldap::NG::Portal::(?:(?:UserDB|Auth)::)?//;
    return $n;
}

package Lemonldap::NG::Portal::Main;

# Build authentication loop displayed in template
# Return authLoop array reference
sub _buildAuthLoop {
    my ( $self, $req ) = @_;
    my @authLoop;

    # Test authentication choices
    unless ( ref $self->conf->{authChoiceModules} eq 'HASH' ) {
        $self->logger->warn("No authentication choices defined");
        return [];
    }

    foreach ( sort keys %{ $self->conf->{authChoiceModules} } ) {

        my $name = $_;

        # Name can have a digit as first character
        # for sorting purpose
        # Remove it in displayed name
        $name =~ s/^(\d*)?(\s*)?//;

        # Replace also _ by space for a nice display
        $name =~ s/\_/ /g;

        # Find modules associated to authChoice
        my ( $auth, $userDB, $passwordDB, $url, $condition ) =
          split( /[;\|]/, $self->conf->{authChoiceModules}->{$_} );

        unless ( $_choiceRules->{$_} ) {
            $self->logger->error("$_ has no rule !!!");
            $_choiceRules->{$_} = sub { 1 };
        }
        unless ( $_choiceRules->{$_}->( $req->env ) ) {
            $self->logger->debug(
"Condition returns false, authentication choice $_ will not be displayed"
            );
        }
        else {
            $self->logger->debug("Displaying authentication choice $_");
            if ( $auth and $userDB and $passwordDB ) {

                # Default URL
                if ( defined $url
                    and not $self->checkXSSAttack( 'URI',
                        $req->env->{'REQUEST_URI'} ) )
                {
                    $url .= $req->env->{'REQUEST_URI'};
                }
                else {
                    $url .= '#';
                }
                $self->logger->debug("Use URL $url");

                # Options to store in the loop
                my $optionsLoop =
                  { name => $name, key => $_, module => $auth, url => $url };

                # Get displayType for this module
                no strict 'refs';
                my $displayType = "Lemonldap::NG::Portal::Auth::${auth}"
                  ->can('getDisplayType')->( undef, $req );

                $self->logger->debug(
                    "Display type $displayType for module $auth");
                $optionsLoop->{$displayType} = 1;

           # If displayType is logo, check if key.png is available
           # TODO:
           #if (
           #    -e $self->getApacheHtdocsPath . "/skins/common/" . $_ . ".png" )
           #{
           #    $optionsLoop->{logoFile} = $_ . ".png";
           #}
           #else {
                $optionsLoop->{logoFile} = $auth . ".png";

                #}

                # Register item in loop
                push @authLoop, $optionsLoop;

                $self->logger->debug(
                    "Authentication choice $name will be displayed");
            }
            else {
                $req->error("Authentication choice $_ value is invalid");
                return 0;
            }
        }

    }

    return \@authLoop;

}

1;

