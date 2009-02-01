package Lemonldap::NG::Common::BuildWSDL;

use Lemonldap::NG::Common::Conf;

sub new {
    my($class, $configStorage) = @_;
    my $self = bless {}, $class;
    my $lmConf = Lemonldap::NG::Common::Conf->new($configStorage) or die($Lemonldap::NG::Common::Conf::msg);
    $self->{conf} = $lmConf->getConf() or die "Unable to load configuration";
    return $self;
}

sub buildWSDL {
    my($self,$xml) = @_;
    $xml =~ s/__PORTAL__/$self->{conf}->{portal}/gs;
    $xml =~ s/__DOMAIN__/$self->{conf}->{domain}/gs;
    my @cookies = split /\s+/, $self->{conf}->{cookieName};
    s#(.*)#<element name="$1" type="xsd:string"></element># foreach(@cookies);
    #s#(.*)#<element name="$1" nillable="true" type="xsd:string"></element># foreach(@cookies);
    $xml =~ s/__XMLCOOKIELIST__/join("\n",@cookies)/ges;
    return $xml;
}

1;

