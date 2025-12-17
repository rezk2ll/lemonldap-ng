package Lemonldap::NG::Portal::Main::Authentication;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants ':all';

our $VERSION = '2.23.1';

extends 'Lemonldap::NG::Portal::Main::Plugin',
  'Lemonldap::NG::Portal::Lib::Wrapper';
with 'Lemonldap::NG::Portal::Lib::OverConf';

has choiceRules      => ( is => 'rw', default => sub { {} } );
has auth_modules     => ( is => 'rw', default => sub { {} } );
has userdb_modules   => ( is => 'rw', default => sub { {} } );
has password_modules => ( is => 'rw', default => sub { {} } );
has catch            => ( is => 'rw', default => sub { {} } );
has sessionKey       => ( is => 'ro', default => '_choice' );

has select_only => (
    is      => 'rw',
    lazy    => 1,
    builder => sub {
        my ($self) = @_;
        return $self->conf->{authChoiceSelectOnly};
    }
);

# INITIALIZATION

# init() must be called by module::init() with a number:
#  - 0 for auth
#  - 1 for userDB
#  - 2 for passwordDB
sub init {
    my ($self) = @_;

    unless ( $self->conf->{authChoiceModules}
        and %{ $self->conf->{authChoiceModules} } )
    {
        $self->conf->{authChoiceModules}->{Default} = join( ';',
            $self->conf->{authentication},
            $self->conf->{userDB},
            $self->conf->{passwordDB},
        );
        $self->select_only(1);
        $self->logger->debug( "FIXME: default choice config "
              . $self->conf->{authChoiceModules}->{Default} );
    }

    foreach my $name ( keys %{ $self->conf->{authChoiceModules} } ) {
        my @mods =
          split( /;\s*/, $self->conf->{authChoiceModules}->{$name} );

        my $over;
        if ( $mods[5] ) {
            eval { $over = JSON::from_json( $mods[5] ) };
            if ($@) {
                $self->logger->error("Bad over value ($@), skipped");
            }
        }

        $mods[1] = $mods[0] if ( $mods[1] eq "Same" );

        $self->_load_module( $name, $mods[0], $over, "Auth",
            $self->auth_modules );
        $self->_load_module( $name, $mods[1], $over, "UserDB",
            $self->userdb_modules );
        $self->_load_module( $name, $mods[2], $over, "Password",
            $self->password_modules );

        # Test if auth module wants to catch some path
        if (    $self->auth_modules->{$name}
            and $self->auth_modules->{$name}->can('catch') )
        {
            $self->catch->{$name} = $self->auth_modules->{$name}->catch;
        }

        # Display conditions
        my $cond = $mods[4];
        if ( defined $cond and $cond ne "" ) {    # 0 is a valid rule!
            my $rule =
              $self->p->buildRule( $cond, "Choice condition for $name" );
            return 0 unless $rule;
            $self->choiceRules->{$name} = $rule;
        }
        else {
            $self->logger->debug("No rule for $name");
            $self->choiceRules->{$name} = sub { 1 };
        }
    }

    # FIXME
    # unless ( keys %{ $self->modules } ) {
    #     $self->error('Choice: no available module found, aborting');
    #     return 0;
    # }
    return 1;
}

# RUNNING METHODS

sub checkChoice {
    my ( $self, $req ) = @_;
    my ( $name, $how ) = $self->_getChoiceFromReq($req);

    return 0 unless ($name);
    $self->logger->debug("Choice $name selected from $how");

    unless ( defined $self->auth_modules->{$name} ) {
        $self->logger->error("Unknown choice '$name'");
        return 0;
    }

    unless ( $req->data->{findUserChoice} ) {

        # Store choice if module loops
        $req->pdata->{_choice}       = $name;
        $req->data->{_authChoice}    = $name;
        $req->sessionInfo->{_choice} = $name;
    }

    return $name;
}

sub _getChoiceFromReq {
    my ( $self, $req ) = @_;

    # Check Choice from pdata, unless the request carries an explicit choice.
    if ( defined $req->pdata->{_choice}
        and !$req->parameters->get( $self->conf->{authChoiceParam} ) )
    {
        return ( $req->pdata->{_choice}, "pdata" );
    }
    elsif (( defined $req->data->{_authChoice} )
        or ( defined $req->data->{_choice} ) )
    {
        my $name = $req->data->{_authChoice} || $req->data->{_choice};
        return ( $name, "req->data" );
    }

    # Check with catch method
    foreach ( keys %{ $self->catch } ) {
        if ( $req->path_info =~ $self->catch->{$_} ) {
            return ( $_, "caught path " . $req->path_info );
        }
    }

    # Set by OAuth Resource Owner grant // RESTServer pwdCheck
    if ( $req->data->{_pwdCheck} and $self->{conf}->{authChoiceAuthBasic} ) {
        return ( $self->{conf}->{authChoiceAuthBasic}, "basic auth context" );
    }

    if ( $req->data->{findUserChoice} ) {
        return ( $req->data->{findUserChoice}, "findUser" );
    }

    if ( $req->parameters->get( $self->conf->{authChoiceParam} ) ) {
        return ( $req->parameters->get( $self->conf->{authChoiceParam} ),
            "param" );
    }

    # Use the choice from current session unless we are doing an upgrade
    # in which case the user should be offered to choose again
    unless ( $req->data->{discardChoiceForCurrentSession} ) {
        if ( $req->userData->{_choice} ) {
            return ( $req->userData->{_choice}, "userData" );
        }
        if ( $req->sessionInfo->{_choice} ) {
            return ( $req->sessionInfo->{_choice}, "sessionInfo" );
        }
    }

    if ( $self->select_only ) {
        my @allowed_choices = grep { $self->_evaluateRule( $req, $_ ) }
          keys %{ $self->conf->{authChoiceModules} };
        if ( @allowed_choices == 1 ) {
            return ( $allowed_choices[0], "only available" );
        }
    }

    # Try hook
    my $context = {};
    my $h       = $self->p->processHook( $req, 'getAuthChoice', $context );
    return 0 if ( $h != PE_OK );
    if ( $h == PE_OK and $context->{choice} ) {
        return ( $context->{choice}, "hook" );
    }

    return 0;
}

sub _load_module {
    my ( $self, $choice_name, $module_name, $over, $kind, $register_hash) = @_;

    my $module = "::${kind}::${module_name}";
    if ( $module = $self->loadModule( $module, $over ) ) {
        $self->logger->debug("$kind module $module_name selected");
        $register_hash->{$choice_name} = $module;
        return 1;
    }
    $self->logger->error( "Choice: unable to load $module_name ($kind)" );
    return 0;
}

sub _authCancel {
    my ( $self, $req ) = @_;
    delete $req->pdata->{_choice};
    return $self->SUPER::_authCancel($req);
}

sub extractFormInfo {
    my ( $self, $req ) = @_;

    $self->logger->debug( "Send init/script -> " . $req->data->{customScript} )
      if $req->data->{customScript};
    unless ( $self->checkChoice($req) ) {
        $self->setSecurity($req);
        return PE_FIRSTACCESS;
    }

    my $res =
      $self->auth_modules->{ $req->data->{_authChoice} }->extractFormInfo($req);
    if ( $res > 0 ) {
        $self->setSecurity($req);
        delete $req->pdata->{_choice};
    }
    return $res;
}

sub authenticate {
    my ( $self, $req ) = @_;
    my $res =
      $self->auth_modules->{ $req->data->{_authChoice} }->authenticate( $_[1] );
    delete $req->pdata->{_choice} if ( $res > 0 );
    return $res;
}

sub setAuthSessionInfo {
    my ( $self, $req ) = @_;
    $self->checkChoice($req) unless ( $req->data->{_authChoice} );
    my $res = $self->auth_modules->{ $req->data->{_authChoice} }
      ->setAuthSessionInfo($req);
    delete $req->pdata->{_choice} if ( $res > 0 );
    return $res;
}

sub authLogout {
    my ( $self, $req ) = @_;
    $_[0]->checkChoice($req) or return PE_OK;
    my $res =
      $self->auth_modules->{ $req->data->{_authChoice} }->authLogout( $_[1] );
    delete $_[1]->pdata->{_choice};
    delete $_[1]->data->{_authChoice};
    return $res;
}

sub setSecurity {
    my ( $self, $req ) = @_;
    foreach my $mod ( values %{ $self->auth_modules } ) {
        if ( $mod->can('setSecurity') ) {
            $mod->setSecurity($req);
            last;
        }
    }
}

sub isCallback {
    my ( $self, $req ) = @_;
    if ( my $choice = $req->pdata->{_choice} ) {
        my $mod = $self->auth_modules->{$choice};
        if ( $mod and $mod->can('isCallback') and $mod->isCallback($req) ) {
            $self->logger->debug("Detected callback for $choice");
            return 1;
        }
    }
    return;
}

sub getUser {
    my ( $self, $req, %args ) = @_;
    $self->checkChoice($req) or return PE_FIRSTACCESS;
    my $res = $self->userdb_modules->{ $req->data->{_authChoice} }
      ->getUser( $req, %args );
    delete $req->pdata->{_choice} if ( $res > 0 );
    return $res;
}

sub findUser {
    my ( $self, $req, %args ) = @_;
    my $choice = $self->checkChoice($req) or return PE_FIRSTACCESS;

    my $res = $self->userdb_modules->{$choice}->findUser( $req, %args );
    delete $req->pdata->{_choice} if ( $res > 0 );
    return $res;
}

sub setSessionInfo {
    my ( $self, $req ) = @_;
    my $res = $self->userdb_modules->{ $req->data->{_authChoice} }
      ->setSessionInfo($req);
    delete $req->pdata->{_choice} if ( $res > 0 );
    return $res;
}

sub setGroups {
    my ( $self, $req ) = @_;
    $self->checkChoice($req);
    my $res =
      $self->userdb_modules->{ $req->data->{_authChoice} }->setGroups($req);
    delete $req->pdata->{_choice} if ( $res > 0 );
    return $res;
}

sub confirm {
    my ( $self, $req, $pwd ) = @_;
    $self->checkChoice($req) or return PE_ERROR;
    return $self->password_modules->{ $req->data->{_authChoice} }
      ->confirm( $req, $pwd );
}

sub modifyPassword {
    my ( $self, $req, $pwd, %args ) = @_;
    $self->checkChoice($req) or return PE_ERROR;
    return $self->password_modules->{ $req->data->{_authChoice} }
      ->modifyPassword( $req, $pwd, %args );
}

sub setNewPassword {
    my ( $self, $req, $pwd, $useMail ) = @_;
    $self->checkChoice($req) or return PE_ERROR;
    return $self->password_modules->{ $req->data->{_authChoice} }
      ->setNewPassword( $req, $pwd, $useMail );
}

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
          split( /;\s*/, $self->conf->{authChoiceModules}->{$_} );

        unless ( $self->_evaluateRule( $req, $_ ) ) {
            $self->logger->debug(
                    "Condition returns false, authentication choice $_"
                  . " will not be displayed" );
        }
        else {
            if (    $auth
                and $self->auth_modules->{$_}
                and $userDB
                and $self->userdb_modules->{$_}
                and $passwordDB
                and $self->password_modules->{$_} )
            {
                $self->logger->debug("Displaying authentication choice $_");

                # Default URL
                if ( defined $url and $url =~ URIRE ) {
                    $req->allowCsp( 'form-action', $url );
                }
                else {
                    $url .= '#';
                }
                $self->logger->debug("Use URL $url");

                eval {
                    my $mod = $self->auth_modules->{$_};
                    $mod->initDisplay($req) if $mod->can('initDisplay');
                };
                $self->logger->info(
                    "Unable to initialize choice $_ display: $@")
                  if $@;

                my $name_without_space = $name =~ s/^\s*//r;

                # Options to store in the loop
                my $optionsLoop = {
                    name                       => $name,
                    key                        => $_,
                    module                     => $auth,
                    url                        => $url,
                    "name_$name_without_space" => 1,
                    "module_$auth"             => 1,
                    "key_$_"                   => 1,
                };

                # Get displayType for this module
                no strict 'refs';
                my $displayType =
                  eval { $self->auth_modules->{$_}->getDisplayType($req); }
                  || 'logo';

                $self->logger->debug(
                    "Display type $displayType for module $auth");
                $optionsLoop->{$displayType} = 1;
                my $logo = $_;

                my $foundLogo = 0;

                # If displayType is logo, check if key.png is available
                if (  -e $self->conf->{templateDir}
                    . "/../htdocs/static/common/modules/"
                    . $logo
                    . ".png" )
                {
                    $optionsLoop->{logoFile} = $logo . ".png";
                    $foundLogo = 1;
                }
                else {
                    $optionsLoop->{logoFile} = $auth . ".png";
                }

                # Compatibility, with Custom, try the module name if
                # key was not found
                if ( $auth eq 'Custom' and not $foundLogo ) {
                    $logo =
                      ( ( $self->{conf}->{customAuth} || "" ) =~ /::(\w+)$/ )
                      [0];
                    if (
                        $logo
                        and ( -e $self->conf->{templateDir}
                            . "/../htdocs/static/common/modules/"
                            . $logo
                            . ".png" )
                      )
                    {
                        $optionsLoop->{logoFile} = $logo . ".png";
                    }
                }

                # If a choice has already been selected,
                # activate the corresponding form
                if ( $req->data->{_authChoice} ) {
                    $optionsLoop->{ACTIVE_FORM} =
                      ( $req->data->{_authChoice} eq $_ );

                }

                # if not, activate the first form in the list
                else {
                    $optionsLoop->{ACTIVE_FORM} = @authLoop ? 0 : 1;
                }

                # Register item in loop
                push @authLoop, $optionsLoop;

                $self->logger->debug(
"Authentication choice $name_without_space will be displayed"
                );
            }
            else {
                $self->logger->debug(
"Authentication choice $_ is invalid and will not be displayed"
                );
                $req->error("Authentication choice $_ is invalid");
                next;
            }
        }

    }

    return \@authLoop;

}

sub _evaluateRule {
    my ( $self, $req, $choice ) = @_;

    my $extraData = {};
    $extraData->{targetAuthnLevel} = $req->pdata->{targetAuthnLevel}
      if defined $req->pdata->{targetAuthnLevel};
    unless ( $self->choiceRules->{$choice} ) {
        $self->logger->error("$choice has no rule");
        $self->choiceRules->{$choice} = sub { 1 };
    }
    return $self->choiceRules->{$_}->( $req, $extraData );
}

sub name {
    my ( $self, $req, $type ) = @_;

    my $accessor = {
        "auth"     => "auth_modules",
        "user"     => "userdb_modules",
        "password" => "password_modules",
    }->{$type};

    return "UNKNOWN" unless $accessor;

    my $choice = $self->checkChoice($req);

    return "UNKNOWN" unless $choice;

    my $mod = $self->$accessor->{$choice};

    return "UNKNOWN" unless $mod;

    if ( my $sub = $mod->can('name') ) {
        return $sub->( $mod, $req, $type );
    }
    else {
        my $s = ref($mod);
        $s =~
          s/^Lemonldap::NG::Portal::(?:(?:Issuer|UserDB|Auth|Password)::)?//;
        return $s;
    }
}

1;
