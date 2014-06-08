package Lemonldap::NG::Handler::API::ApacheMP1;

our $VERSION = '1.4.0';

sub set_user {
    my ( $class, $r, $user ) = @_;
    $r->connection->user($user);
}

sub header_in {
    my ( $class, $r, $header ) = @_;
    return $r->header_in($header);
}

sub set_header_in {
    my ( $class, $r, %headers ) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $r->header_in( $h => $v );
    }
}

sub unset_header_in {
    my ( $class, $r, @headers ) = @_;
    foreach my $h (@headers) {
        $r->header_in( $h => "" ) if ( $r->header_in($h) );
    }
}

sub set_header_out {
    my ( $class, $r, %headers ) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $r->header_out( $h => $v );
    }
}

sub set_err_header_out {
    my ( $class, $r, %headers ) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $r->err_header_out( $h => $v );
    }
}

1;
