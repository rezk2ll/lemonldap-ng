package Lemonldap::NG::Common::Logger::Apache2;

use Apache2::ServerRec;
use Encode;

our $VERSION = '2.0.0';

sub new {
    return bless {}, shift;
}

sub AUTOLOAD {
    my ( $self, @args ) = @_;
    $AUTOLOAD =~ s/.*:://;
    my $message = join( "", @args );
    return Apache2::ServerRec->log->$AUTOLOAD( encode( 'UTF-8', $message_ ) );
}

1;
