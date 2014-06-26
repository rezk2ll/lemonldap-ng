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

has localStorageOptions =>
  ( is => 'rw', isa => 'Maybe[HashRef]', required => 1 );

# attributes built and returned
has [ 'statusPipe', 'statusOut' ] => ( is => 'rw' );


# Mouse methods
###############

## @imethod void localInit(hashRef args)
# Launch the status process (statusProcess()) if wanted
# @param $args reference to the initialization hash
sub localInit($$) {
    my ( $self, $args ) = splice @_;
    if ( $self->{localStorage} = $args->{localStorage} ) {
        $self->{localStorageOptions} = $args->{localStorageOptions};
        $self->{localStorageOptions}->{default_expires_in} ||= 600;
    }
    if ( $args->{status} ) {
        $self->statusProcess();
    }

    Lemonldap::NG::Handler::API->setServerSignature(
        "Lemonldap::NG::Handler/" . $Lemonldap::NG::Handler::VERSION
    ) if ( $Lemonldap::NG::Handler::VERSION and !$args->{hideSignature} );

    return (
        $self->{localStorage}, $self->{localStorageOptions},
        $self->{statusPipe},   $self->{statusOut}
    );
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
        $Data::Dumper::Terse = 1;
        $self->{statusPipe}->reader();
        $self->{statusOut}->writer();
        my $fdin  = $self->{statusPipe}->fileno;
        my $fdout = $self->{statusOut}->fileno;
        open STDIN,  "<&$fdin";
        open STDOUT, ">&$fdout";
        my @tmp = ();
        push @tmp, "-I$_" foreach (@INC);
        my $params = $self->{localStorage}
                   ? $self->{localStorage} . ', '
                     . Data::Dumper::Dumper($self->{localStorageOptions})
                   : "";
        exec 'perl', '-MLemonldap::NG::Handler::Status',
          @tmp,
          '-e',
          "&Lemonldap::NG::Handler::Status::run($params)";
    }
}

1;
