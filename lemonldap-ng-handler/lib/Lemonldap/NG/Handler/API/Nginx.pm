package Lemonldap::NG::Handler::API::Nginx;

sub set_user {
    my ($class, $request, $user) = @_;
    # Nginx perl API does not (yet ?) allow to set $remote_user var
    # So one tries to set the variable $user instead
    $request->variable("user", $user) 
        if ( defined $request->variable("user") );
}

1;
