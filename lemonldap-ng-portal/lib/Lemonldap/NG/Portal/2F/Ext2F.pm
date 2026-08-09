package Lemonldap::NG::Portal::2F::Ext2F;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants;
use IPC::Run;

our $VERSION = '2.0.16';

extends 'Lemonldap::NG::Portal::Lib::Code2F';

# INITIALIZATION

# Prefix can overriden by sfExtra and is used for routes
has prefix => ( is => 'rw', default => 'ext' );

# Used to lookup config
has conf_type => ( is => 'ro', default => 'ext' );
has legend    => ( is => 'rw', default => 'enterExt2fCode' );
has timeout => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return ( $self->conf->{ $self->conf_type . '2fTimeout' } || 60 );
    }
);

sub init {
    my ($self) = @_;

    if ( $self->code_activation ) {
        unless ( $self->conf->{ext2FSendCommand} ) {
            $self->error( $self->prefix
                  . '2f: missing "ext2FSendCommand" parameter, aborting' );
            return 0;
        }
    }
    else {
        foreach (qw(ext2FSendCommand ext2FValidateCommand)) {
            unless ( $self->conf->{$_} ) {
                $self->error(
                    $self->prefix . "2f: missing \"$_\" parameter, aborting" );
                return 0;
            }
        }
    }
    return $self->SUPER::init();
}

# RUNNING METHODS

sub verify_external {
    my ( $self, $req, $session, $code ) = @_;

    # Prepare command and launch it
    $self->logger->debug( $self->prefix
          . '2f: launching "Validate" command -> '
          . $self->conf->{ext2FValidateCommand} );
    $self->logger->debug(" code -> $code");
    my ( $c, $message ) =
      $self->launch( $session, $self->conf->{ext2FValidateCommand}, $code );
    if ( $c == 0 ) {
        $self->logger->debug(
            $self->prefix . "2f: validate command successful" );
        return PE_OK;
    }
    elsif ( $c == -1 ) {
        $self->logger->error(
            $self->prefix . "2f: could not run validate command: $message" );
    }
    else {
        $self->userLogger->warn( $self->prefix
              . '2f: validation failed for '
              . $session->{ $self->conf->{whatToTrace} } );
        my $rc = $c >> 8;
        $self->logger->error(
            $self->prefix . "2f: validate command returned $rc" );
    }
    return PE_BADOTP;
}

sub sendCode {
    my ( $self, $req, $sessionInfo, $code ) = @_;

    # Prepare command and launch it
    $self->logger->debug( $self->prefix
          . '2f: launching "Send" command -> '
          . $self->conf->{ext2FSendCommand} );
    my ( $c, $message ) =
      $self->launch( $sessionInfo, $self->conf->{ext2FSendCommand}, $code );
    if ( $c == 0 ) {
        $self->logger->debug( $self->prefix . "2f: send command successful" );
        return 1;
    }
    elsif ( $c == -1 ) {
        $self->logger->error(
            $self->prefix . "2f: could not run send command: $message" );
    }
    else {
        my $rc = $c >> 8;
        $self->logger->error( $self->prefix . "2f: send command returned $rc" );
    }
    return 0;
}

# system() is used with an array to avoid shell injection
sub launch {
    my ( $self, $session, $command, $code ) = @_;
    my @args;
    foreach ( split( /\s+/, $command ) ) {
        if ( defined $code ) {
            s#\$code\b#$code#g;
        }
        s#\$(\w+)#$session->{$1} // ''#ge;
        push @args, $_;
    }
    $self->logger->debug(
        $self->prefix . "2f: executing command: " . join( " ", @args ) );

    my ($err);
    my $c = eval {
        IPC::Run::run( \@args, \undef, '>', '/dev/null', '2>', \$err,
            IPC::Run::timeout( $self->timeout ) );
    };
    if ( defined($c) ) {
        my $shifted_ret = $?;
        if ($c) {
            return 0;
        }
        else {
            if ($err) {
                $self->logger->debug( "returned stderr: \n" . $err );
            }
            return $shifted_ret;
        }
    }
    else {
        return ( -1, $@ );
    }
}

1;

