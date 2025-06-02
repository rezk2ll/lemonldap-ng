package Lemonldap::NG::Common::Session::Purge;

use strict;
use Lemonldap::NG::Common::Conf;
use Lemonldap::NG::Common::Conf::Constants;
use Lemonldap::NG::Common::Apache::Session;
use Lemonldap::NG::Common::Session;
use JSON;
use Mouse;
use Time::HiRes;

use constant defaultLogger => 'Lemonldap::NG::Common::Logger::Std';

has logLevel => ( is => 'rw' );
has force    => ( is => 'rw' );
has json     => ( is => 'rw' );
has conf => (
    is      => 'ro',
    default => sub {
        my $ca = Lemonldap::NG::Common::Conf->new()
          or die $Lemonldap::NG::Common::Conf::msg;
        my $conf =
             $ca->getConf
          or die "Unable to get configuration ($!)"
          or die "Unable to get configuration ($!)";
        my $localconf = $ca->getLocalConf(PORTALSECTION)
          or die "Unable to get local configuration ($!)";
        if ($localconf) {
            $conf->{$_} = $localconf->{$_} foreach ( keys %$localconf );
        }
        $conf->{logLevel} = $_[0]->logLevel || $conf->{logLevel} || 'info';
        return $conf;
    },
    lazy => 1,
);

has logger => (
    is      => 'ro',
    default => sub {
        my $self = shift;
        my $conf = $self->conf;
        my $logger =
          $self->conf->{logger} || $ENV{LLNG_DEFAULTLOGGER} || defaultLogger;
        $logger =~ s/^::/Lemonldap::NG::Common::Logger::/;
        $logger = defaultLogger
          if $logger eq 'Lemonldap::NG::Common::Logger::Apache2';
        eval "require $logger";
        die $@ if ($@);
        my $err;

        unless ( $conf->{logLevel} =~ /^(?:debug|info|notice|warn|error)$/ ) {
            $err = "Bad logLevel value $conf->{logLevel}, use 'info'";
            $conf->{logLevel} = 'info';
        }
        $logger = $logger->new($conf);
        $logger->error($err) if $err;
        return $logger;
    },
    lazy => 1,
);

has backends => (
    is      => 'ro',
    default => sub {
        my $conf   = $_[0]->conf;
        my $logger = $_[0]->logger;
        my %backends;
        my $module;

        # Sessions
        if ( $conf->{globalStorage} ) {

            # Load module
            $module = $conf->{globalStorage};
            eval "use $module";
            die $@ if ($@);
            $conf->{globalStorageOptions}->{backend} = $module;

            # Add module in managed backends
            $backends{SSO} = $conf->{globalStorageOptions};

            $logger->debug("Session backend $module will be used");
        }

        # SAML
        if ( $conf->{samlStorage}
            or keys %{ $conf->{samlStorageOptions} ||= {} } )
        {

            # Load module
            $module = $conf->{samlStorage} || $conf->{globalStorage};
            eval "use $module";
            die $@ if ($@);
            $conf->{samlStorageOptions}->{backend} = $module;

            # Add module in managed backends
            $backends{SAML} = $conf->{samlStorageOptions};

            $logger->debug("SAML backend $module will be used");
        }

        # CAS
        if ( $conf->{casStorage}
            or keys %{ $conf->{casStorageOptions} ||= {} } )
        {

            # Load module
            $module = $conf->{casStorage} || $conf->{globalStorage};
            eval "use $module";
            die $@ if ($@);
            $conf->{casStorageOptions}->{backend} = $module;

            # Add module in managed backends
            $backends{CAS} = $conf->{casStorageOptions};

            $logger->debug("CAS backend $module will be used");
        }

        # Captcha
        if ( $conf->{captchaStorage}
            or keys %{ $conf->{captchaStorageOptions} ||= {} } )
        {

            # Load module
            $module = $conf->{captchaStorage} || $conf->{globalStorage};
            eval "use $module";
            die $@ if ($@);
            $conf->{captchaStorageOptions}->{backend} = $module;

            # Add module in managed backends
            $backends{Captcha} = $conf->{captchaStorageOptions};

            $logger->debug("Captcha backend $module will be used");
        }

        # OpenIDConnect
        if ( $conf->{oidcStorage}
            or keys %{ $conf->{oidcStorageOptions} ||= {} } )
        {

            # Load module
            $module = $conf->{oidcStorage} || $conf->{globalStorage};
            eval "use $module";
            die $@ if ($@);
            $conf->{oidcStorageOptions}->{backend} = $module;

            # Add module in managed backends
            $backends{OIDC} = $conf->{oidcStorageOptions};

            $logger->debug("OIDC backend $module will be used");
        }
        return \%backends;
    },
    lazy => 1,
);

has force => ( is => 'ro' );

sub purge {
    my ($self) = @_;

    my $nb_purged  = {};
    my $nb_error   = {};
    my $start_time = {};
    my $end_time   = {};

  # Compute the list of backends here to avoid having big timing inconsistencies
    my $backends = $self->backends;
    my $conf     = $self->conf;

    $self->logger->info( __PACKAGE__ . "::purge() called" );
    $start_time->{total} = Time::HiRes::time();
    while ( my ( $type, $options ) = each %$backends ) {
        $self->logger->debug("Cleaning $type sessions");
        $nb_error->{$type}   = 0;
        $nb_purged->{$type}  = 0;
        $start_time->{$type} = Time::HiRes::time();

        if ( $options->{backend} eq "Apache::Session::Memcached" ) {
            $end_time->{$type} = Time::HiRes::time();
            next;
        }

        my @t;
        if ( $options->{backend}->can('deleteIfLowerThan') ) {
            $self->logger->debug(
                "Found deleteIfLowerThan() in backend, using it");
            my ( $success, $rows ) = $options->{backend}->deleteIfLowerThan(
                $options,
                {
                    not => { '_session_kind' => 'Persistent' },
                    or  => {
                        _utime => time - $conf->{timeout},
                        (
                            $conf->{timeoutActivity}
                            ? ( _lastSeen => time - $conf->{timeoutActivity} )
                            : ()
                        )
                    }
                }
            );

            if ($success) {
                if ($rows) {
                    $nb_purged->{$type} += $rows;
                }
                $end_time->{$type} = Time::HiRes::time();
                next;
            }
        }

        # Get all expired sessions
        Lemonldap::NG::Common::Apache::Session->get_key_from_all_sessions(
            $options,
            sub {
                my $entry = shift;
                my $id    = shift;
                my $time  = time;

                $self->logger->debug("Check session $id");

                # Empty session need to be removed
                unless ($entry) {
                    push @t, $id;
                    $self->logger->debug(
                        "Session $id is empty (corrupted?), delete forced");
                }

                # Do net check sessions without _utime
                return undef unless $entry->{_utime};

                # Do not expire persistent sessions
                return undef if ( $entry->{_session_kind} eq "Persistent" );

                # Session expired
                if ( $time - $entry->{_utime} > $conf->{timeout} ) {
                    push @t, $id;
                    $self->logger->debug("Session $id expired");
                }

                # User has no activity, so considere the session has expired
                elsif ( $conf->{timeoutActivity}
                    and $entry->{_lastSeen}
                    and $time - $entry->{_lastSeen} > $conf->{timeoutActivity} )
                {
                    push @t, $id;
                    $self->logger->debug("Session $id inactive");
                }
                undef;
            }
        );

        # Delete sessions
        my @errors;
        for my $id (@t) {

            my $session = Lemonldap::NG::Common::Session->new(
                storageModule        => $options->{backend},
                storageModuleOptions => $options,
                cacheModule          => $conf->{localSessionStorage},
                cacheModuleOptions   => $conf->{localSessionStorageOptions},
                id                   => $id,
            );

            unless ( $session->data ) {
                $self->logger->debug("Error while opening session $id");
                print STDERR "Error on session $id\n";
                $nb_error->{$type}++;
                push @errors, $id;
                next;
            }

            unless ( $session->remove ) {
                $self->logger->debug("Error while deleting session $id");
                print STDERR "Error on session $id\n";
                $nb_error->{$type}++;
                push @errors, $id;
                next;
            }
            $self->logger->debug("Session $id has been purged");
            $nb_purged->{$type}++;
        }

        # Remove lock files for File backend
        if (
            $options->{backend} =~ /^Apache::Session::(?:Browseable::)?File$/i )
        {
            require Apache::Session::Lock::File;
            my $l = new Apache::Session::Lock::File;
            my $lock_directory =
              $options->{LockDirectory} || $options->{Directory};
            $l->clean( $lock_directory, $conf->{timeout} );
        }

        # Force deletion of corrupted sessions for File backend
        if ( $options->{backend} =~ /^Apache::Session::(?:Browseable::)?File$/i
            and $self->force )
        {
            foreach (@errors) {
                my $id = $_;
                eval { unlink $options->{Directory} . "/$id"; };
                if ($@) {
                    $self->logger->error("Unable to remove session $id");
                }
                else {
                    $self->logger->warn("Session $id removed with force");
                    $nb_error->{$type}--;
                }
            }
        }

        # Force deletion of corrupted sessions for DBI backend
        if ( $options->{backend} =~
/^Apache::Session::(?:Browseable::)?(MySQL|Postgres|DBI|Oracle|Informix|MySQLJSON|PgHstore|PgJSON|SQLLite|Sybase)$/i
            and $self->force )
        {
            my $dbi = DBI->connect_cached( $options->{DataSource},
                $options->{UserName}, $options->{Password} );
            my $table = $options->{TableName} || "sessions";
            my $req   = $dbi->prepare("DELETE from $table WHERE id=?");
            foreach (@errors) {
                my $id  = $_;
                my $res = $req->execute($id);
                unless ( $res == 1 ) {
                    $self->logger->error(
                        "Fail to delete session $id with force");
                }
                else {
                    $self->logger->warn("Session $id removed with force");
                    $nb_error->{$type}--;
                }
            }
        }

        # Force deletion of corrupted sessions for LDAP backend
        if ( $options->{backend} =~ /^Apache::Session::(?:Browseable::)?LDAP$/i
            and $self->force )
        {
            my $useTls = 0;
            my $tlsParam;
            my @servers = ();
            foreach my $server ( split /[\s,]+/, $options->{ldapServer} ) {
                if ( $server =~ m{^ldap\+tls://([^/]+)/?\??(.*)$} ) {
                    $useTls   = 1;
                    $server   = $1;
                    $tlsParam = $2 || "";
                }
                else {
                    $useTls = 0;
                }
                push @servers, $server;
            }
            my $ldap =
              Net::LDAP->new( \@servers, keepalive => 1, onerror => undef, );
            unless ($ldap) {
                print STDERR "Unable to connect to LDAP server\n";
                $nb_error->{$type}++;
                $end_time->{$type} = Time::HiRes::time();
                next;
            }

            # Start TLS if needed
            if ($useTls) {
                my %h = split( /[&=]/, $tlsParam );
                $h{verify} ||= $options->{ldapVerify} || "require";
                $h{cafile} ||= $options->{ldapCAFile}
                  if ( $options->{ldapCAFile} );
                $h{capath} ||= $options->{ldapCAPath}
                  if ( $options->{ldapCAPath} );
                my $start_tls = $ldap->start_tls(%h);
                if ( $start_tls->code ) {
                    print STDERR "STARTTLS error: "
                      . $start_tls->code . ': '
                      . $start_tls->error;
                    $nb_error->{$type}++;
                    $end_time->{$type} = Time::HiRes::time();
                    next;
                }
            }

            my $bind = $ldap->bind( $options->{ldapBindDN},
                password => $options->{ldapBindPassword} );
            my $attrId = $options->{ldapAttributeId} | "cn";
            foreach (@errors) {
                my $id = $_;
                my $sessionDn =
                  $attrId . "=" . $id . "," . $options->{ldapConfBase};
                my $delete = $ldap->delete($sessionDn);
                if ( $delete->is_error ) {
                    $self->logger->error(
                        "Fail to delete session $id with force");
                }
                else {
                    $self->logger->warn("Session $id removed with force");
                    $nb_error->{$type}--;
                }
            }
        }
        $end_time->{$type} = Time::HiRes::time();
    }
    $end_time->{total} = Time::HiRes::time();

    my $total_purged = 0;
    $total_purged += $_ for values %$nb_purged;
    $nb_purged->{total} = $total_purged;

    my $total_error = 0;
    $total_error += $_ for values %$nb_error;
    $nb_error->{total} = $total_error;

    my $stats;
    for my $type ( "total", sort keys %{ $self->backends } ) {
        $stats->{$type}->{errors} = $nb_error->{$type};
        $stats->{$type}->{purged} = $nb_purged->{$type};
        $stats->{$type}->{duration_u} =
          int( 1000000 * ( $end_time->{$type} - $start_time->{$type} ) );
    }

    my $log = "Session purge completed: ";
    if ( $self->json ) {
        $log .= to_json($stats);
    }
    else {
        my @logentries;
        for my $type ( "total", sort keys %{ $self->backends } ) {
            my $logentry .= "$type (";
            $logentry    .= $stats->{$type}->{purged} . " purged, ";
            $logentry    .= $stats->{$type}->{errors} . " errors in ";
            $logentry    .= $stats->{$type}->{duration_u} . " us";
            $logentry    .= ")";
            push @logentries, $logentry;
        }
        $log .= join( ', ', @logentries );
    }

    $self->logger->info($log);
    $self->logger->warn(
"$total_error sessions remaining, try to purge them with force (option -f)"
    ) if $total_error;

    return {
        success => !($total_error),
        purged  => $total_purged,
        errors  => $total_error,
        stats   => $stats,
    };
}

sub localPurge {
    my ($self) = @_;
    $self->logger->debug( __PACKAGE__ . "::localPurge() called" );
    my $conf = $self->conf;
    if ( $conf->{localSessionStorage} ) {
        eval "require $conf->{localSessionStorage}";
        die $@ if $@;
        $conf->{localSessionStorageOptions}->{default_expires_in} ||= 600;
        my $s = $conf->{localSessionStorage}
          ->new( $conf->{localSessionStorageOptions} );
        $s->purge();
    }
}

1;
