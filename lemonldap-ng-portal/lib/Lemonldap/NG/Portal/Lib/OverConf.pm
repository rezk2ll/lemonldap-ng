package Lemonldap::NG::Portal::Lib::OverConf;

use Mouse::Role;
use Scalar::Util 'weaken';

# To avoid "tied" destroy, tied configurations are kept here
our @overC;

# Override portal loadPlugin() to use a wrapped configuration
sub loadPlugin {
    my ( $self, $plugin, $over ) = @_;
    my $obj;
    my $nc;
    if ($over) {
        require Lemonldap::NG::Common::Conf::Wrapper;
        tie %$nc, 'Lemonldap::NG::Common::Conf::Wrapper', $self->conf, $over;
        push @overC, $nc;
    }
    else {
        $nc = $self->conf;
    }
    return 0
      unless ( $obj = $self->p->loadModule( "$plugin", $nc ) );
    return 0
      unless $obj = $self->p->findEP( $plugin, $obj );
    $obj->{userLogger} = $self->wrapUserLogger;
    weaken $obj->{userLogger};
    return $obj;
}

1;
