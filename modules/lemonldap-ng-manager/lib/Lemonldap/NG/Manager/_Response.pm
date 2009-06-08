## @file
# Prepare Lemonldap::NG::Manager response for new configurations

## @class
# Prepare Lemonldap::NG::Manager response for new configurations
package Lemonldap::NG::Manager::_Response;

our $VERSION = '0.11';

## @cmethod Lemonldap::NG::Manager::_Response new()
# Constructor
# @return Lemonldap::NG::Manager::_Response object
sub new {
    my $class = shift;
    return bless { errors => [], warnings => [] }, $class;
}

## @method void print(array p)
# Join all stings in @p into $self->{txt}
sub print {
    my $self = shift;
    $self->{txt} .= $_ foreach(@_);
}

## @method void message(string title,string txt)
# Build HTML part to display.
# @param $title title of the message
# @param $txt text of the message
sub message {
    my $self = shift;
    my ($title, $txt) = @_;
    $self->{txt} = "<h3>$title</h3><p>$txt</p>" . $self->{txt};
}

## @method private void warning(array warnings)
# Store warnings in $self->{warnings}
# @param @warnings array of string
sub warning {
    my $self = shift;
    push @{$self->{warnings}}, @_;
}

## @method private void error(array errors)
# Store warnings in $self->{errors}
# @param @errors array of string
sub error {
    my $self = shift;
    return scalar @{$self->{errors}} unless(@_);
    push @{$self->{errors}}, @_;
}

## @method protected void setConfiguration(hashref configuration)
# Store $configuration in $self->{configuration}
# @param $configuration Lemonldap::NG configuration
sub setConfiguration {
    my $self = shift;
    $self->{configuration} = shift;
}

## @method void send()
# Display upload response.
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
