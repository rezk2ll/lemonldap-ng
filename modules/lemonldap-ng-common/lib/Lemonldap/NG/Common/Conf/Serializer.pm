package Lemonldap::NG::Common::Conf::Serializer;

use Data::Dumper;

BEGIN {
    *Lemonldap::NG::Common::Conf::serialize = \&serialize;
    *Lemonldap::NG::Common::Conf::unserialize = \&unserialize;
}

sub serialize {
    my ( $self, $conf ) = @_;
    my $fields;
    local $Data::Dumper::Indent = 0;
    local $Data::Dumper::Varname = "data";
    while ( my ( $k, $v ) = each(%$conf) ) {
        next if ( $k =~ /^(?:reVHosts|cipher)$/ );
        if ( ref($v) ) {
            $fields->{$k} = Dumper($v);
            $fields->{$k} =~ s/'/&#39;/g;
            $fields->{$k} = "'$fields->{$k}'" unless ( $self->{noQuotes} );
        }
        elsif ( $v =~ /^\d+$/ ) {
            $fields->{$k} = "$v";
        }
        else {

            # mono-line
            $v =~ s/[\r\n]/ /gm;

            # trim
            $v =~ s/^\s*(.*?)\s*$/$1/;
            $v =~ s/'/&#39;/g;
            $v = "'$v'" unless ( $self->{noQuotes} );
            $fields->{$k} = $v;
        }
    }
    return $fields;
}

sub unserialize {
    my ( $self, $fields ) = @_;
    my $conf;
    while ( my ( $k, $v ) = each(%$fields) ) {
        $v =~ s/^'(.*)'$/$1/s;
        if ( $k =~
/^(?:exportedVars|locationRules|groups|exportedHeaders|macros|globalStorageOptions|notificationStorageOptions|samlServiceMetaData)$/
            and $v ||= {}
            and not ref($v) )
        {
            $conf->{$k} = {};
            if ( defined($v) and $v !~ /^\$/ ) {
                print STDERR
"Lemonldap::NG : Warning: configuration is in old format, you've to migrate !\n";
                eval { require Storable; require MIME::Base64; };
                if ($@) {
                    $msg = "Error : $@";
                    return 0;
                }
                $conf->{$k} = Storable::thaw( MIME::Base64::decode_base64($v) );
            }
            else {
                my $data;
                $v =~ s/^\$([_a-zA-Z][_a-zA-Z0-9]*) *=/\$data =/;
                $v =~ s/&#?39;/'/g;
                eval $v;
                print STDERR
"Lemonldap::NG : Error while reading configuration with $k key: $@\n"
                  if ($@);
                $conf->{$k} = $data;
            }
        }
        else {
            $v =~ s/&#?39;/'/g;
            $conf->{$k} = $v;
        }
    }
    return $conf;
}

1;
__END__
