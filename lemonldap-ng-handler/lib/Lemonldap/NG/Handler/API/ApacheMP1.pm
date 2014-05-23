package Lemonldap::NG::Handler::API::ApacheMP1;

sub set_user {
    my ($class, $request, $user) = @_;
    $request->connection->user($user);
}

1;
