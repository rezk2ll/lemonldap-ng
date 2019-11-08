package Lemonldap::NG::Manager::Api::2F;
our $VERSION = '2.0.7';

package Lemonldap::NG::Manager::Api;

sub helloworld {
    my ( $self, $req, @others ) = @_;
    return [ 200, [], ["Hello world"]];
}

1;
