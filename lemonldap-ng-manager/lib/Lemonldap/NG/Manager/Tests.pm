package Lemonldpa::NG::Manager::Tests;

## @method hashref tests(hashref conf)
# Return a hash ref where keys are the names of the tests and values
# subroutines to execute.
#
# Subroutines can return one of the followings :
# -  (1)         : everything is OK
# -  (1,message) : OK with a warning
# -  (0,message) : NOK
# - (-1,message) : OK, but must be confirmed (ignored if confirm parameter is
# set
#
# Those subroutines can also modify configuration.
#
# @param $conf Configuration to test
# @return hash ref where keys are the names of the tests and values
sub tests {
    my $conf = shift;
    return {

        # 1. CHECKS

        # Check if portal is in domain
        portalIsInDomain => sub {
            return (
                1,
                (
                    index( $conf->{portal}, $conf->{domain} ) > 0
                    ? ''
                    : "Portal seems not to be in the domain $conf->{domain}"
                )
            );
        },

        # Check if virtual hosts are in the domain
        vhostInDomainOrCDA => sub {
            return 1 if ( $conf->{cda} );
            my @pb;
            foreach my $vh ( keys %{ $conf->{locationRules} } ) {
                push @pb, $vh unless ( index( $vh, $conf->{domain} ) >= 0 );
            }
            return (
                1,
                (
                    @pb
                    ? 'Virtual hosts '
                      . join( ', ', @pb )
                      . " are not in $conf->{domain} and cross-domain-authentication is not set"
                    : undef
                )
            );
        },

        # Check if virtual host do not contain a port
        vhostWithPort => sub {
            my @pb;
            foreach my $vh ( keys %{ $conf->{locationRules} } ) {
                push @pb, $vh if ( $vh =~ /:/ );
            }
            if (@pb) {
                return ( 0,
                        'Virtual hosts '
                      . join( ', ', @pb )
                      . " contain a port, this is not allowed" );
            }
            else { return 1; }
        },

        # Force vhost to be lowercase
        vhostUpperCase => sub {
            my @pb;
            foreach my $vh ( keys %{ $conf->{locationRules} } ) {
                push @pb, $vh if ( $vh ne lc $vh );
            }
            if (@pb) {
                return ( 0,
                        'Virtual hosts '
                      . join( ', ', @pb )
                      . " must be in lower case" );
            }
            else { return 1; }
        },

        # Check if "userDB" and "authentication" are consistent
        authAndUserDBConsistency => sub {
            foreach my $type (qw(Facebook Google OpenID SAML WebID)) {
                return ( 0,
"\"$type\" can not be used as user database without using \"$type\" for authentication"
                  )
                  if (  $conf->{userDB} =~ /$type/
                    and $conf->{authentication} !~ /$type/ );
            }
            return 1;
        },

        # Check that OpenID macros exists
        checkAttrAndMacros => sub {
            my @tmp;
            foreach my $k ( keys %$conf ) {
                if ( $k =~
/^(?:openIdSreg_(?:(?:(?:full|nick)nam|languag|postcod|timezon)e|country|gender|email|dob)|whatToTrace)$/
                  )
                {
                    my $v = $conf->{$k};
                    $v =~ s/^$//;
                    next if ( $v =~ /^_/ );
                    push @tmp,
                      $k
                      unless (
                        defined(
                            $conf->{exportedVars}->{$v}
                              or defined( $conf->{macros}->{$v} )
                        )
                      );
                }
            }
            return (
                1,
                (
                    @tmp
                    ? 'Values of parameter(s) "'
                      . join( ', ', @tmp )
                      . '" are not defined in exported attributes or macros'
                    : ''
                )
            );
        },

        # Test that variables are exported if Google is used as UserDB
        checkUserDBGoogleAXParams => sub {
            my @tmp;
            if ( $conf->{userDB} =~ /^Google/ ) {
                while ( my ( $k, $v ) = each %{ $conf->{exportedVars} } ) {
                    if ( $v !~ Lemonldap::NG::Common::Regexp::GOOGLEAXATTR() ) {
                        push @tmp, $v;
                    }
                }
            }
            return (
                1,
                (
                    @tmp
                    ? 'Values of parameter(s) "'
                      . join( ', ', @tmp )
                      . '" are not exported by Google'
                    : ''
                )
            );
        },

        # Test that variables are exported if OpenID is used as UserDB
        checkUserDBOpenIDParams => sub {
            my @tmp;
            if ( $conf->{userDB} =~ /^OpenID/ ) {
                while ( my ( $k, $v ) = each %{ $conf->{exportedVars} } ) {
                    if ( $v !~ Lemonldap::NG::Common::Regexp::OPENIDSREGATTR() )
                    {
                        push @tmp, $v;
                    }
                }
            }
            return (
                1,
                (
                    @tmp
                    ? 'Values of parameter(s) "'
                      . join( ', ', @tmp )
                      . '" are not exported by OpenID SREG'
                    : ''
                )
            );
        },

        # Try to use Apache::Session module
        testApacheSession => sub {
            my ( $id, %h );
            return 1
              if ( $conf->{globalStorage} eq
                   $Lemonldap::NG::Handler::Main::tsv->{sessionStorageModule}
                or $conf->{globalStorage} eq
                'Lemonldap::NG::Common::Apache::Session::SOAP' );
            eval "use $conf->{globalStorage}";
            return ( -1, "Unknown package $conf->{globalStorage}" ) if ($@);
            eval {
                tie %h, $conf->{globalStorage}, undef,
                  $conf->{globalStorageOptions};
            };
            return ( -1, "Unable to create a session ($@)" )
              if ( $@ or not tied(%h) );
            eval {
                $h{a} = 1;
                $id = $h{_session_id} or return ( -1, 'No _session_id' );
                untie(%h);
                tie %h, $conf->{globalStorage}, $id,
                  $conf->{globalStorageOptions};
            };
            return ( -1, "Unable to insert datas ($@)" ) if ($@);
            return ( -1, "Unable to recover data stored" )
              unless ( $h{a} == 1 );
            eval { tied(%h)->delete; };
            return ( -1, "Unable to delete session ($@)" ) if ($@);
            my $gc = $Lemonldap::NG::Handler::Main::tsv->{sessionStorageModule};
            return ( -1,
'All sessions may be lost and you <b>must</b> restart all your Apache servers'
            ) if ( $conf->{globalStorage} ne $gc );
            return 1;
        },

        # Warn if cookie name has changed
        cookieNameChanged => sub {
            return (
                1,
                (
                    $Lemonldap::NG::Handler::Main::tsv->{cookieName} ne
                      $conf->{cookieName}
                    ? 'Cookie name has changed, you <b>must</b> restart all your Apache servers'
                    : ()
                )
            );
        },

        # Warn if manager seems to be unprotected
        managerProtection => sub {
            return (
                1,
                (
                    $conf->{cfgAuthor} eq 'anonymous'
                    ? 'Your manager seems to be unprotected'
                    : ''
                )
            );
        },

        # Test SMTP connection and authentication
        smtpConnectionAuthentication => sub {

            # Skip test if no SMTP configuration
            return 1 unless ( $conf->{SMTPServer} );

            # Use SMTP
            eval "use Net::SMTP";
            return ( 0, "Net::SMTP module is required to use SMTP server" )
              if ($@);

            # Create SMTP object
            my $smtp = Net::SMTP->new( $conf->{SMTPServer} );
            return ( 0,
                "SMTP connection to " . $conf->{SMTPServer} . " failed" )
              unless ($smtp);

            # Skip other tests if no authentication
            return 1
              unless ( $conf->{SMTPAuthUser} and $conf->{SMTPAuthPass} );

            # Try authentication
            return ( 0, "SMTP authentication failed" )
              unless $smtp->auth( $conf->{SMTPAuthUser},
                $conf->{SMTPAuthPass} );

            # Return
            return 1;
        },

        # 2. MODIFICATIONS

        # Remove unused and non-customized parameters
        compactModules => sub {
            foreach my $k ( keys %$conf ) {

                # No analysis for hash keys
                next if ( ref $conf->{$k} );

                # Check federation modules
                foreach my $type (qw(CAS OpenID SAML)) {

                    # Check authChoice values
                    my ( $authChoice, $userDBChoice ) = ( undef, undef );
                    if ( $conf->{authentication} eq 'Choice'
                        and defined $conf->{authChoiceModules} )
                    {
                        foreach ( keys %{ $conf->{authChoiceModules} } ) {
                            my ( $auth, $userDB, $passwordDB ) =
                              split( '|', $conf->{authChoiceModules}->{$_} );
                            $authChoice   = 1 if $auth =~ /$type/i;
                            $userDBChoice = 1 if $userDB =~ /$type/i;
                        }
                    }

                    if (
                        (
                                $k =~ /^$type/i
                            and not( $conf->{"issuerDB${type}Activation"} )
                            and not( $conf->{authentication} =~ /$type/i )
                            and not( $conf->{userDB} =~ /$type/i )
                            and not( defined $authChoice
                                or defined $userDBChoice )
                        )
                      )
                    {
                        my $confAttributes =
                          Lemonldap::NG::Common::Conf::Attributes->new();
                        my $v = $confAttributes->$k;
                        if ( defined($v) and $conf->{$k} eq $v ) {
                            delete $conf->{$k};
                        }
                    }
                }
                return 1;
            }
        },
    };
}

1;
