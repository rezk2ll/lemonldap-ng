package My;

sub hello {
    return 'Hello';
}

sub get_additional_arg {
    return $_[0];
}

sub accessToTrace {
    my $hash    = shift;
    my $custom  = $hash->{custom};
    my $req     = $hash->{req};
    my $vhost   = $hash->{vhost};
    my $custom  = $hash->{custom};
    my $params  = $hash->{params};
    my $session = $hash->{session};

    return "$custom alias $params->[0]_$params->[1]:$session->{groups} ($session->{$params->[2]})";
}

1;
