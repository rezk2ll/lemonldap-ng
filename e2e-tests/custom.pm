package My;

sub hello {
    return 'Hello';
}

sub get_additional_arg {
    return $_[0];
}

sub accessToTrace {
    my $hash = shift;
    return
"$hash->{custom} alias $hash->{params}->[0] $hash->{params}->[1]:$hash->{session}->{groups}";
}

1;
