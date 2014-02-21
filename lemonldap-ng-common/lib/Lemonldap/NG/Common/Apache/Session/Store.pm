
package Lemonldap::NG::Common::Apache::Session::Store;

our $VERSION = 1.4.0;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub insert {
    my $self    = shift;
    my $session = shift;
    $self->{args} = $session->{args};

    return $self->module->insert($session);
}

sub update {
    my $self    = shift;
    my $session = shift;
    $self->{args} = $session->{args};

    return $self->module->update($session);
}

sub materialize {
    my $self    = shift;
    my $session = shift;
    $self->{args} = $session->{args};

    return $self->module->materialize($session);
}

sub remove {
    my $self    = shift;
    my $session = shift;
    $self->{args} = $session->{args};

    return $self->module->remove($session);
}

sub close {
    my $self    = shift;
    my $session = shift;
    $self->{args} = $session->{args};

    return $self->module->close;
}

sub module {
    my $self = shift;
    return $self->{args}->{object_store};
}

1;
