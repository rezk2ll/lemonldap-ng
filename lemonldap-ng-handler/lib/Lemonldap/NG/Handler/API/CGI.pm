package Lemonldap::NG::Handler::API::CGI;

sub set_user {
    my ($class, $request, $user) = @_;
    $ENV{REMOTE_USER} = $user;
}

1;
