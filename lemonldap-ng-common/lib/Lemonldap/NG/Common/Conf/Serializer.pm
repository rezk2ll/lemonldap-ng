package Lemonldap::NG::Common::Conf::Serializer;

use Data::Dumper;

our $VERSION = '1.9.0';

BEGIN {
    *Lemonldap::NG::Common::Conf::normalize   = \&normalize;
    *Lemonldap::NG::Common::Conf::unnormalize = \&unnormalize;
    *Lemonldap::NG::Common::Conf::serialize   = \&serialize;
    *Lemonldap::NG::Common::Conf::unserialize = \&unserialize;
}

## @method string normalize(string value)
# Change quotes, spaces and line breaks
# @param value Input value
# @return normalized string
sub normalize {
    my ( $self, $value ) = @_;

    # trim white spaces
    $value =~ s/^\s*(.*?)\s*$/$1/;

    # Convert carriage returns (\r) and line feeds (\n)
    $value =~ s/\r/%0D/g;
    $value =~ s/\n/%0A/g;

    # Convert simple quotes
    $value =~ s/'/&#39;/g;

    # Surround with simple quotes
    $value = "'$value'" unless ( $self->{noQuotes} );

    return $value;
}

## @method string unnormalize(string value)
# Revert quotes, spaces and line breaks
# @param value Input value
# @return unnormalized string
sub unnormalize {
    my ( $self, $value ) = @_;

    # Convert simple quotes
    $value =~ s/&#?39;/'/g;

    # Convert carriage returns (\r) and line feeds (\n)
    $value =~ s/%0D/\r/g;
    $value =~ s/%0A/\n/g;

    # Keep number as numbers
    $value += 0 if ( $value =~ /^(?:0|(?:\-[0-9]|[1-9])[0-9]*)(?:\.[0-9]+)?$/ );

    return $value;
}

## @method hashref serialize(hashref conf)
# Parse configuration and convert it into fields
# @param conf Configuration
# @return fields
sub serialize {
    my ( $self, $conf ) = @_;
    my $fields;

    # Data::Dumper options
    local $Data::Dumper::Indent  = 0;
    local $Data::Dumper::Varname = "data";

    # Parse configuration
    while ( my ( $k, $v ) = each(%$conf) ) {

        # 1.Hash ref
        if ( ref($v) ) {
            $fields->{$k} = $self->normalize( Dumper($v) );
        }

        # 2. Numeric values
        elsif ( $v =~ /^\d+$/ ) {
            $fields->{$k} = "$v";
        }

        # 3. Standard values
        else {
            $fields->{$k} = $self->normalize($v);
        }
    }

    return $fields;
}

## @method hashref unserialize(hashref fields)
# Convert fields into configuration
# @param fields Fields
# @return configuration
sub unserialize {
    my ( $self, $fields ) = @_;
    my $conf;

    # Parse fields
    while ( my ( $k, $v ) = each(%$fields) ) {

        # Remove surrounding quotes
        $v =~ s/^'(.*)'$/$1/s;

        # Manage hashes

        # Regexp::Assemble of:
        # applicationList
        # authChoiceModules
        # captchaStorageOptions
        # CAS_proxiedServices
        # casAttributes
        # casStorageOptions
        # dbiExportedVars
        # demoExportedVars
        # exportedHeaders
        # exportedVars
        # facebookExportedVars
        # globalStorageOptions
        # googleExportedVars
        # grantSessionRules
        # groups
        # ldapExportedVars
        # localSessionStorageOptions
        # locationRules
        # logoutServices
        # macros
        # notificationStorageOptions
        # oidcOPMetaDataExportedVars
        # oidcOPMetaDataJSON
        # oidcOPMetaDataJWKS
        # oidcOPMetaDataOptions
        # oidcRPMetaDataExportedVars
        # oidcRPMetaDataOptions
        # oidcServiceMetaDataAuthnContext
        # openIdExportedVars
        # persistentStorageOptions
        # portalSkinRules
        # post
        # reloadUrls
        # remoteGlobalStorageOptions
        # samlIDPMetaDataExportedAttributes
        # samlIDPMetaDataOptions
        # samlIDPMetaDataXML
        # samlSPMetaDataExportedAttributes
        # samlSPMetaDataOptions
        # samlSPMetaDataXML
        # samlStorageOptions
        # sessionDataToRemember
        # slaveExportedVars
        # vhostOptions
        # webIDExportedVars
        if ( $k =~
/^(?:(?:l(?:o(?:ca(?:lSessionStorageOption|tionRule)|goutService)|dapExportedVar)|(?:(?:d(?:emo|bi)|facebook|webID)ExportedVa|exported(?:Heade|Va))r|g(?:r(?:antSessionRule|oup)|lobalStorageOption|oogleExportedVar)|ca(?:s(?:StorageOption|Attribute)|ptchaStorageOption)|re(?:moteGlobalStorageOption|loadUrl)|(?:notificationStorage|vhost)Option|CAS_proxiedService|macro)s|s(?:aml(?:S(?:PMetaData(?:(?:ExportedAttribute|Option)s|XML)|torageOptions)|IDPMetaData(?:(?:ExportedAttribute|Option)s|XML))|essionDataToRemember|laveExportedVars)|o(?:idc(?:OPMetaData(?:(?:ExportedVar|Option)s|J(?:SON|WKS))|RPMetaData(?:ExportedVar|Option)s|ServiceMetaDataAuthnContext)|penIdExportedVars)|p(?:ersistentStorageOptions|o(?:rtalSkinRules|st))|a(?:uthChoiceModules|pplicationList))$/
            and $v ||= {}
            and not ref($v) )
        {
            $conf->{$k} = {};

            # Value should be a Data::Dumper, else this is an old format
            if ( defined($v) and $v !~ /^\$/ ) {

                $msg .=
" Warning: configuration is in old format, you've to migrate!";

                eval { require Storable; require MIME::Base64; };
                if ($@) {
                    $msg .= " Error: $@";
                    return 0;
                }
                $conf->{$k} = Storable::thaw( MIME::Base64::decode_base64($v) );
            }

            # Convert Data::Dumper
            else {
                my $data;
                $v =~ s/^\$([_a-zA-Z][_a-zA-Z0-9]*) *=/\$data =/;
                $v = $self->unnormalize($v);

                # Evaluate expression
                eval $v;

                if ($@) {
                    $msg .= " Error: cannot read configuration key $k: $@";
                }

                # Store value in configuration object
                $conf->{$k} = $data;
            }
        }

        # Other fields type
        else {
            $conf->{$k} = $self->unnormalize($v);
        }
    }

    return $conf;
}

1;
__END__
