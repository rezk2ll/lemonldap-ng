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

            # trim white spaces
            $v =~ s/^\s*(.*?)\s*$/$1/;

            # Convert carriage returns (\r) and line feeds (\n)
            $v =~ s/\r/%0D/g;
            $v =~ s/\n/%0A/g;

            # Convert simple quotes
            $v =~ s/'/&#39;/g;

            # Surround with simple quotes
            $v = "'$v'" unless ( $self->{noQuotes} );

            # Store value in field
            $fields->{$k} = $v;
        }
    }
    return $fields;
}

sub unserialize {
    my ( $self, $fields ) = @_;
    my $conf;
    while ( my ( $k, $v ) = each(%$fields) ) {

        # Remove surrounding quotes
        $v =~ s/^'(.*)'$/$1/s;

        # Manage hashes
        if ( $k =~
/^(?:exportedVars|locationRules|groups|exportedHeaders|macros|globalStorageOptions|notificationStorageOptions|samlIDPMetaDataXML|samlIDPMetaDataExportedAttributes|samlSPMetaData)$/
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
            $v =~ s/%0D/\r/g;
            $v =~ s/%0A/\n/g;
            $conf->{$k} = $v;
        }
    }
    return $conf;
}

1;
__END__
