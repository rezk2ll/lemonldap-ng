## @file
# Base file for Lemonldap::NG handlers

## @class
# Base class for Lemonldap::NG handlers.
# All methods in handler are class methods: in ModPerl environment, handlers
# are always launched without object created.
#
# The main method is run() who is called by Apache for each requests (using
# handler() wrapper).
#
# The main initialization subroutine is init() who launch localInit() and
# globalInit().
package Lemonldap::NG::Handler::Initialization::LocalInit;

use Mouse;

use Lemonldap::NG::Handler::SharedConf;    # Needed to get VERSION
use Lemonldap::NG::Handler::Main::Logger;
use Lemonldap::NG::Handler::API qw(:httpCodes); # for importing modules and constants

our $VERSION = '1.4.0';

# Mouse attributes
##################

# default attributes from constructor
has localStorage => ( is => 'rw', isa => 'Maybe[Str]', required => 1 );

has refLocalStorage => ( is => 'rw', required => 1 );

has localStorageOptions =>
  ( is => 'rw', isa => 'Maybe[HashRef]', required => 1 );

has childInitDone => ( is => 'rw' );

# attributes built and returned
has [ 'statusPipe', 'statusOut' ] => ( is => 'rw' );


# Mouse methods
###############

## @imethod void localInit(hashRef args)
# Call purgeCache() to purge the local cache, launch the status process
# (statusProcess()) in wanted and launch childInit().
# @param $args reference to the initialization hash
sub localInit($$) {
    my ( $self, $args ) = splice @_;
    if ( $self->{localStorage} = $args->{localStorage} ) {
        $self->{localStorageOptions} = $args->{localStorageOptions};
        $self->{localStorageOptions}->{default_expires_in} ||= 600;
        $self->purgeCache();
    }
    if ( $args->{status} ) {
        if ( defined $self->{localStorage} ) {
            $self->statusProcess();
        }
        else {

            # localStorage is mandatory for status module
            Lemonldap::NG::Handler::Main::Logger->lmLog(
"Status module can not be loaded without localStorage parameter",
                'warn'
            );
        }
    }
    $self->childInit($args);

    Lemonldap::NG::Handler::API->setServerSignature(
        "Lemonldap::NG::Handler/" . $Lemonldap::NG::Handler::VERSION
    ) unless ( $args->{hideSignature} );

    return (
        $self->{localStorage},        $self->{refLocalStorage},
        $self->{localStorageOptions}, $self->{statusPipe},
        $self->{statusOut},           $self->{childInitDone}
    );
}

## @imethod protected void purgeCache()
# Purge the local cache.
# Launched at Apache startup.
sub purgeCache {
    my $self = shift;
    eval "use $self->{localStorage};";
    die("Unable to load $self->{localStorage}: $@") if ($@);

    # At each Apache (re)start, we've to clear the cache to avoid living
    # with old datas
    eval '$self->{refLocalStorage} = new '
      . $self->{localStorage}
      . '($self->{localStorageOptions});';
    if ( defined $self->{refLocalStorage} ) {
        $self->{refLocalStorage}->clear();
    }
    else {
        Lemonldap::NG::Handler::Main::Logger->lmLog(
            "Unable to clear local cache: $@", 'error' );
    }
}

# Status daemon creation

## @ifn protected void statusProcess()
# Launch the status processus.
sub statusProcess {
    my $self = shift;
    require IO::Pipe;
    $self->{statusPipe} = IO::Pipe->new;
    $self->{statusOut}  = IO::Pipe->new;
    if ( my $pid = fork() ) {
        $self->{statusPipe}->writer();
        $self->{statusOut}->reader();
        $self->{statusPipe}->autoflush(1);
    }
    else {
        require Data::Dumper;
        $self->{statusPipe}->reader();
        $self->{statusOut}->writer();
        my $fdin  = $self->{statusPipe}->fileno;
        my $fdout = $self->{statusOut}->fileno;
        open STDIN,  "<&$fdin";
        open STDOUT, ">&$fdout";
        my @tmp = ();
        push @tmp, "-I$_" foreach (@INC);
        exec 'perl', '-MLemonldap::NG::Handler::Status',
          @tmp,
          '-e',
          '&Lemonldap::NG::Handler::Status::run('
          . $self->{localStorage} . ','
          . Data::Dumper->new( [ $self->{localStorageOptions} ] )->Terse(1)
          ->Dump . ');';
    }
}

## @imethod protected boolean childInit()
# Indicates to Apache that it has to launch:
# - initLocalStorage() for each child process (after fork and uid change)
# - cleanLocalStorage() after each requests
# @return True
sub childInit {
    my ( $self, $args ) = splice @_;
    return 1 if ( $self->{childInitDone} );

    # We don't initialise local storage in the "init" subroutine because it can
    # be used at the starting of Apache and so with the "root" privileges. Local
    # Storage is also initialized just after Apache's fork and privilege lost.

    # Local storage is cleaned after giving the content of the page to increase
    # performances.
    no strict;
    if ( MP() == 2 ) {
        $s = Apache2::ServerUtil->server;
        $s->push_handlers( PerlChildInitHandler =>
              sub { return $self->initLocalStorage( $_[1], $_[0] ); } );
    }
    elsif ( MP() == 1 ) {
        Apache->push_handlers(
            PerlChildInitHandler => sub { return $self->initLocalStorage(@_); }
        );
    }
    $self->{childInitDone}++;
    1;
}

## @imethod protected int initLocalStorage()
# Prepare local cache (if not done before by Lemonldap::NG::Common::Conf)
# @return Apache2::Const::DECLINED
sub initLocalStorage {
    my $self = shift;
    if ( $self->{localStorage} and not $self->{refLocalStorage} ) {
        eval
"use $self->{localStorage};\$self->{refLocalStorage} = new $self->{localStorage}(\$self->{localStorageOptions});";

        Lemonldap::NG::Handler::Main::Logger->lmLog(
            "Local cache initialization failed: $@", 'error' )
          unless ( defined $self->{refLocalStorage} );
    }
    return DECLINED;
}

1;
