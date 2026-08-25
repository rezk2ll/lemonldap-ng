package Lemonldap::NG::Common::Logger::Apache2;

use strict;
use Apache2::ServerRec;
use Encode;

our $VERSION = '2.0.0';
our $AUTOLOAD;

sub new {
    return bless {}, shift;
}

sub AUTOLOAD {
    my ( $self, @args ) = @_;
    $AUTOLOAD =~ s/.*:://;
    my $message = join( "", @args );
    return Apache2::ServerRec->log->$AUTOLOAD( encode( 'UTF-8', $message ) );
}

1;
