package Lemonldap::NG::Common::AuditLogger::UserLoggerJSON;

use strict;
use JSON;
use Scalar::Util qw(weaken);

our $VERSION = '2.21.0';

sub new {
    my ( $class, $psgi_or_handler ) = @_;
    my $self = bless {}, $class;

    $self->{userLogger} = $psgi_or_handler->userLogger
      or die 'Missing userLogger';
    weaken $self->{userLogger};
    my $json = JSON->new->canonical;
    $self->{encode} = sub { $json->encode(@_) };
    return $self;
}

sub log {
    my ( $self, $req, %fields ) = @_;

    my $message = $fields{message};
    my $sub     = $fields{logLevel} || 'info';
    unless ( $sub =~ /^(?:debug|info|notice|warn|error)$/ ) {
        $fields{message} = "[malformed logLevel $sub] $fields{message}";
        $sub = 'error';
    }
    foreach ( keys %fields ) {
        delete $fields{$_} if ref( $fields{$_} );
    }
    $self->{userLogger}->$sub( $self->{encode}->( \%fields ) );
}
1;
