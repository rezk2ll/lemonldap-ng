package My;

sub hello {
    return 'Hello';
}

sub get_uri {
    return $_[0];
}

sub get_additional_arg {
    return $_[1];
}

1;
