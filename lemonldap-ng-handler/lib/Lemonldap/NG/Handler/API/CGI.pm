package Lemonldap::NG::Handler::API::CGI;

our $VERSION = '1.4.0';

sub set_user {
    my ( $class, $r, $user ) = @_;
    $ENV{REMOTE_USER} = $user;
}

sub header_in {
    my ( $class, $r, $header ) = @_;
    return $ENV{ cgiName($header) };
}

sub set_header_in {
    my ( $class, $r, %headers ) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $ENV{ cgiName($h) } = $v;
    }
}

sub unset_header_in {
    my ( $class, $r, @headers ) = @_;
    foreach my $h (@headers) {
        $ENV{ cgiName($h) } = undef;
    }
}

sub set_header_out {
    my ( $class, $r, %headers ) = @_;
    while ( my ( $h, $v ) = each %headers ) {

        # TODO
    }
}

sub set_err_header_out {
    my ( $class, $r, %headers ) = @_;
    while ( my ( $h, $v ) = each %headers ) {

        # TODO
    }
}

sub cgiName {
    my $h = uc(shift);
    $h =~ s/-/_/g;
    return "HTTP_$h";
}

1;
