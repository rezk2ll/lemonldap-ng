package Lemonldap::NG::Handler::API::ApacheMP2;

our $VERSION = '1.4.0';

sub set_user {
    my ($class, $r, $user) = @_;
    $r->user($user);
}

sub header_in {
    my ($class, $r, $header) = @_;
    return $r->headers_in->{$header};
}

sub set_header_in {
    my ($class, $r, %headers) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $r->headers_in->set( $h => $v );
    }
}

sub unset_header_in {
    my ($class, $r, @headers) = @_;
    foreach my $h (@headers) {
        $r->headers_in->unset($h);
    }
} 

sub set_header_out {
    my ($class, $r, %headers) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $r->headers_out->set( $h => $v );
    }
} 

sub set_err_header_out {
    my ($class, $r, %headers) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $r->err_headers_out->set( $h => $v );
    }
}

1;
