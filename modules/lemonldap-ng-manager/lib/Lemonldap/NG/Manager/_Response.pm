package Lemonldap::NG::Manager::_Response;

our $VERSION = '0.1';

sub new {
    my $class = shift;
    return bless { errors => [], warnings => [] }, $class;
}

sub print {
    my $self = shift;
    $self->{txt} .= $_ foreach(@_);
}

sub message {
    my $self = shift;
    my ($title, $txt) = @_;
    $self->{txt} = "<h3>$title</h3><p>$txt</p>" . $self->{txt};
}

sub warning {
    my $self = shift;
    push @{$self->{warnings}}, @_;
}

sub error {
    my $self = shift;
    return scalar @{$self->{errors}} unless(@_);
    push @{$self->{errors}}, @_;
}

sub setConfiguration {
    my $self = shift;
    $self->{configuration} = shift;
}

sub send {
    my $self = shift;
    my $buf;
    $buf = "tree.setItemText('root','Configuration $self->{configuration}');"
        if($self->{configuration});
    if ( $self->error ) {
        $self->{txt} .= "<h4>Errors</h4><ul>";
        foreach ( @{$self->{errors}} ) {
            s/</&lt;/g;
            s/>/&gt;/g;
            $self->{txt} .= "<li>$_</li>"
        }
        $self->{txt} .= "</ul>";
    }
    if ( $self->warning ) {
        $self->{txt} .= "<h4>Warnings</h4><ul>";
        foreach ( @{$self->{warnings}} ) {
            s/</&lt;/g;
            s/>/&gt;/g;
            $self->{txt} .= "<li>$_</li>"
        }
        $self->{txt} .= "</ul>";
    }
    if($self->{txt}) {
        $self->{txt} =~ s/'/\\'/g;
        $self->{txt} =~ s/[\r\n]//g;
        $buf .= "document.getElementById('help').innerHTML='$self->{txt}';";
    }
    print $buf;
}

1;
__END__
