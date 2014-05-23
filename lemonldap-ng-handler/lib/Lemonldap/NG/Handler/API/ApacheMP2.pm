package Lemonldap::NG::Handler::API::ApacheMP2;

sub set_user {
    my ($class, $request, $user) = @_;
    $request->user($user);
}

1;
