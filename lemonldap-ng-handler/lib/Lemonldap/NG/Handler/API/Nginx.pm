package Lemonldap::NG::Handler::API::Nginx;

our $VERSION = '1.4.0';

sub set_user {
    my ($class, $r, $user) = @_;
    # Nginx perl API does not (yet ?) allow to set $remote_user var
    # So one tries to set the variable $user instead
    $r->variable("user", $user) 
        if ( defined $r->variable("user") );
}

sub header_in {
    my ($class, $r, $header) = @_;
    return $r->header_in($header);
}

sub set_header_in {
    my ($class, $r, %headers) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        # TODO
    }
}

sub unset_header_in {
    my ($class, $r, @headers) = @_;
    foreach my $h (@headers) {
        # TODO
    }
}

sub set_header_out {
    my ($class, $r, %headers) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        # TODO
    }
}

sub set_err_header_out {
    my ($class, $r, %headers) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        # TODO
    }
}

1;
