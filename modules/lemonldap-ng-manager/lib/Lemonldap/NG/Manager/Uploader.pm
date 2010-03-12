## @file
# Test uploaded parameters and store new configuration

## @class
# Test uploaded parameters and store new configuration
package Lemonldap::NG::Manager::Uploader;

use strict;
use XML::LibXML;
use XML::LibXSLT;
use MIME::Base64;
use JSON;
use LWP::Simple;

# TODO
use Data::Dumper;
use URI::Escape;
use Lemonldap::NG::Common::Safelib;        #link protected safe Safe object
use Lemonldap::NG::Manager::Downloader;    #inherits
use Lemonldap::NG::Manager::_Struct;       #link protected struct _Struct object
use Lemonldap::NG::Manager::_i18n;
use Lemonldap::NG::Common::Conf::Constants;    #inherits

our $VERSION = '0.1';
our ( $stylesheet, $parser );

## @method void confUpload(ref rdata)
# Parse rdata to find parameters using XSLT, test them and tries to store the
# new configuration
# @param $rdata pointer to posted datas
sub confUpload {
    my ( $self, $rdata ) = @_;
    $$rdata =~ s/<img.*?>//g;
    $$rdata =~ s/<li class="line".*?<\/li>//g;

    # 1. ANALYSE DATAS

    # 1.1 Apply XSLT stylesheet to returned datas
    my $result =
      $self->stylesheet->transform(
        $self->parser->parse_string( '<root>' . $$rdata . '</root>' ) )
      ->documentElement();

    # 1.2 Get configuration number
    unless ( $self->{cfgNum} =
        $result->getChildrenByTagName('conf')->[0]->getAttribute('value') )
    {
        die "No configuration number found";
    }
    my $newConf = { cfgNum => $self->{cfgNum} };
    my $errors = {};

    # 1.3 Load and test returned parameters
    #     => begin loop
    foreach ( @{ $result->getChildrenByTagName('element') } ) {
        my ( $id, $name, $value ) = (
            $_->getAttribute('id'),
            $_->getAttribute('name'),
            $_->getAttribute('value')
        );

        # Unescape value
        $value = uri_unescape($value);

        $self->lmLog(
            "Upload process for attribute $name (id: $id / value: $value)",
            'debug' );

        my $NK = 0;
        $id =~
          s/^text_(NewID_)?li_(\w+)(\d)(?:_\d+)?$/decode_base64($2.'='x $3)/e;
        $NK = 1 if ($1);
        $id =~ s/\r//g;
        $id =~ s/^\///;
        $id =~ s/(?:\/[^\/]*)?$/\/$name/ if ($NK);

        $self->lmLog( "id transformed into $id", 'debug' );

        next
          if ( $id =~
            /^(generalParameters|variables|virtualHosts|samlIDPMetaDataNode)/ );
        my ( $confKey, $test ) = $self->getConfTests($id);
        my ( $res, $m );

        if ( !defined($test) ) {
            $errors->{errors}->{$name} =
              "Key $name: Lemonldap::NG::Manager error, see Apache's logs";
            $self->lmLog(
                "Unknown configuration key $id (name: $name, value: $value)",
                'error' );
            next;
        }

        if ( $test->{'*'} and $id =~ /\// ) { $test = $test->{'*'} }

        # 1.3.1 Tests:

        #     No tests for some keys
        unless ( $test->{keyTest} and ( $id !~ /\// or $test->{'*'} ) ) {

            # 1.3.1.1 Tests that return an error
            #         (parameter will not be stored in $newConf)
            if ( $test->{keyTest} ) {
                ( $res, $m ) = $self->applyTest( $test->{keyTest}, $name );
                unless ($res) {
                    $errors->{errors}->{$name} = $m || $test->{keyMsgFail};
                    next;
                }
                $errors->{warnings}->{$name} = $m if ($m);
            }
            if ( $test->{test} ) {
                ( $res, $m ) = $self->applyTest( $test->{test}, $value );
                unless ($res) {
                    $errors->{errors}->{$name} = $m || $test->{msgFail};
                    next;
                }
                $errors->{warnings}->{$name} = $m if ($m);
            }

            # 1.3.1.2 Tests that return a warning
            if ( $test->{warnKeyTest} ) {
                ( $res, $m ) = $self->applyTest( $test->{warnKeyTest}, $name );
                unless ($res) {
                    $errors->{warnings}->{$name} = $m || $test->{keyMsgWarn};
                }
            }
            if ( $test->{warnTest} ) {
                ( $res, $m ) = $self->applyTest( $test->{warnTest}, $value );
                unless ($res) {
                    $errors->{warnings}->{$name} = $m || $test->{keyMsgWarn};
                }
            }
        }

        # 1.3.2 Store accepted parameter in $newConf
        $self->lmLog( "Tests OK for $name, store $value in $confKey", 'debug' );
        $self->setKeyToH( $newConf, $confKey,
            $test->{keyTest}
            ? ( ( $id !~ /\// or $test->{'*'} ) ? {} : ( $name => $value ) )
            : $value );
    }    # END LOOP

    # 1.4 Loading unchanged parameters (ajax nodes not open)
    $self->lmLog( "Save unchanged parameters", 'debug' );
    foreach ( @{ $result->getChildrenByTagName('ignore') } ) {
        my $node = $_->getAttribute('value');
        $node =~ s/^.*node=(.*?)(?:&.*)?\}$/$1/;
        $self->lmLog( "Unchanged node $node", 'debug' );
        foreach my $k ( $self->findAllConfKeys( $self->corresp($node) ) ) {
            $self->lmLog( "Unchanged key $k (node $node)", 'debug' );
            my $v = $self->keyToH( $k, $self->conf );
            $v = $self->keyToH( $k, $self->defaultConf ) unless ( defined $v );
            if ( defined $v ) {
                $self->setKeyToH( $newConf, $k, $v );
            }
            else {
                $self->lmLog( "No default value found for $k", 'info' );
            }
        }
    }

    # 1.5 Author attributes for accounting
    $newConf->{cfgAuthor}   = $ENV{REMOTE_USER} || 'anonymous';
    $newConf->{cfgAuthorIP} = $ENV{REMOTE_ADDR};
    $newConf->{cfgDate}     = time();

    # 2. SAVE CONFIGURATION

    $errors->{result}->{other} = '';

    # 2.1 Don't store configuration if a syntax error was detected
    if ( $errors->{errors} ) {
        $errors->{result}->{cfgNum} = 0;
        $errors->{result}->{msg}    = $self->translate('syntaxError');
        $self->_sub( 'userInfo',
            "Configuration rejected for $newConf->{cfgAuthor}: syntax error" );
    }

    # 2.2 Try to save configuration
    else {

        # if "force" is set, Lemonldap::NG::Common::Conf accept it even if
        # conf database is locked or conf number isn't current number (used to
        # restore an old configuration)
        $self->confObj->{force} = 1 if ( $self->param('force') );

        # Call saveConf()
        $errors->{result}->{cfgNum} = $self->confObj->saveConf($newConf);

        # 2.2.1 Prepare response
        my $msg;

        # case "success"
        if ( $errors->{result}->{cfgNum} > 0 ) {

            # Store accounting datas to the response
            $errors->{cfgDatas} = {
                cfgAuthor   => $newConf->{cfgAuthor},
                cfgAuthorIP => $newConf->{cfgAuthorIP},
                cfgDate     => $newConf->{cfgDate}
            };
            $msg = 'confSaved';

            # Log success using Lemonldap::NG::Common::CGI::userNotice():
            #  * in system logs if "syslog" is set
            #  * in apache errors file otherwise
            $self->_sub( 'userNotice',
"Conf $errors->{result}->{cfgNum} saved by $newConf->{cfgAuthor}"
            );
        }

        # other cases
        else {
            $msg = {
                CONFIG_WAS_CHANGED, 'confWasChanged',
                UNKNOWN_ERROR,      'unknownError',
                DATABASE_LOCKED,    'databaseLocked',
                UPLOAD_DENIED,      'uploadDenied',
                SYNTAX_ERROR,       'syntaxError',
                DEPRECATED,         'confModuledeprecated',
            }->{ $errors->{result}->{cfgNum} };

            # Log failure using Lemonldap::NG::Common::CGI::userError()
            $self->_sub( 'userError',
                "Configuration rejected for $newConf->{cfgAuthor}: $msg" );
        }

        # Translate msg returned
        $errors->{result}->{msg} = $self->translate($msg);
        if (   $errors->{result}->{cfgNum} == CONFIG_WAS_CHANGED
            or $errors->{result}->{cfgNum} == DATABASE_LOCKED )
        {
            $errors->{result}->{other} = '<a href="javascript:uploadConf(1)">'
              . $self->translate('clickHereToForce') . '</a>';
        }
        elsif ( $errors->{result}->{cfgNum} == DEPRECATED ) {
            $errors->{result}->{other} = 'Module : ' . $self->confObj->{type};
        }
    }

    # 3. PREPARE JSON RESPONSE
    my $buf = '{';
    my $i   = 0;
    while ( my ( $type, $h ) = each %$errors ) {
        $buf .= ',' if ($i);
        $buf .= "'$type':{";
        $buf .= join(
            ',',
            map {
                $h->{$_} =~ s/'/\\'/;
                $h->{$_} =~ s/\n/ /g;
                "'$_':'$h->{$_}'"
              } keys %$h
        );
        $buf .= '}';
        $i++;
    }
    $buf .= '}';

    # 4. SEND JSON RESPONSE
    print $self->header(
        -type           => 'application/json',
        -Content_Length => length($buf)
    ) . $buf;
    $self->quit();
}

## @method public void fileUpload (fieldname)
# Retrieve a file from an HTTP request, and return it. This function is for
# some functionnalities into the SAML2 modules of the manager, accessing
# to data through Ajax requests.
# @param $fieldname The name of the html input field.
sub fileUpload {
    my $self = shift;
    my $fieldname = shift;

    # Upload the file on the server.
    my $UPLOAD_FH = $self->upload($fieldname);
    my $content = '';
    while ( <$UPLOAD_FH> )
    {
      $content .= "$_";
    }
    $content =~ s!<!&lt;!g;
    $content =~ s!>!&gt;!g;

    # Build JSON reponse
    my $json = new JSON();
    $json = $json->allow_nonref(['1']);
    $json = $json->utf8(['1']);
    my $json_content = $json->encode($content);
    my $buf = '{"status":"OK", "content":' . $json_content . '}';

    # Do not send response
    return $buf;
}

## @method public void fileUpload (fieldname)
# Retrieve a file from an URL, and return it. This function is for
# some functionnalities into the SAML2 modules of the manager, accessing
# to data through Ajax requests.
# @param $fieldname The name of the html input field that contains the URL.
sub urlUpload {
    my $self = shift;
    my $fieldname = shift;

    # Get the URL
    my $url = ${$self->rparam($fieldname)};

    # Get contents from URL
    my $content = get $url;
    $content = '' unless(defined $content);
    $content =~ s!<!&lt;!g;
    $content =~ s!>!&gt;!g;

    # Build JSON reponse
    my $json = new JSON();
    $json = $json->allow_nonref(['1']);
    $json = $json->utf8(['1']);
    my $json_content = $json->encode($content);
    my $buf = '{"status":"OK", "content":' . $json_content . '}';

    # Do not send response
    return $buf;
}

## @method protected array applyTest(void* test,string value)
# Apply the test to the value and return the result and an optional message
# returned by the test if the sub ref.
# @param $test Ref to a regexp or a sub
# @param $value Value to test
# @return Array containing:
# - the test result
# - an optional message
sub applyTest {
    my ( $self, $test, $value ) = @_;
    my ( $res, $msg );
    if ( ref($test) eq 'CODE' ) {
        ( $res, $msg ) = &$test($value);
    }
    else {
        $res = ( $value =~ $test ? 1 : 0 );
    }
    return ( $res, $msg );
}

## @method protected array getConfTests(string id)
# Call Lemonldap::NG::Manager::_Struct::testStruct().
sub getConfTests {
    my ( $self, $id ) = @_;
    my ( $confKey, $tmp ) = ( $id =~ /^(.*?)(?:\/(.*))?$/ );
    my $h = $self->testStruct()->{$confKey};
    if ( $h and $h->{'*'} and my ( $k, $v ) = ( $tmp =~ /^(.*?)\/(.*)$/ ) ) {
        return ( "$confKey/$k", $h->{'*'} );
    }
    return ( $confKey, $h );
}

## @method protected array findAllConfKeys(hashref h)
# Parse a tree structure to find all nodes corresponding to a configuration
# value.
# @param $h Tree structure
# @return Array of configuration parameter names
sub findAllConfKeys {
    my ( $self, $h ) = @_;
    my @res = ();

    # expand _nodes
    if ( ref( $h->{_nodes} ) eq 'CODE' ) {
        $h->{_nodes} = $h->{_nodes}->($self);
    }
    foreach my $n ( @{ $h->{_nodes} } ) {
        $n =~ s/^.*?:(.*?)(?:\:.*)?$/$1/;
        $self->lmLog( "findAllConfKey: got node $n", 'debug' );
        if ( ref( $h->{$n} ) ) {
            push @res, $self->findAllConfKeys( $h->{$n} );
        }
        else {
            my $m = $h->{$n} || $n;
            push @res, ( $m =~ /^(?:.*?:)?(.*?)(?:\:.*)?$/ ? $1 : () );
        }
    }
    push @res, @{ $h->{_upload} } if ( $h->{_upload} );
    return @res;
}

## @method protected String formatValue(string key, string value)
# Format a value.
# @param $key String "/path/key"
# @param $value String
# @return A formated value.
sub formatValue {
    my ( $self, $key, $value ) = @_;
    my $newvalue = $value;
    if ( $key =~ /^samlIDPMetaDataXML/ ) {
        my $metadata = Lemonldap::NG::Common::Conf::SAML::Metadata->new();
        if ( ref($value) ) {
            $metadata->initializeFromConfHash($value);
        }
        else {
            $metadata->initializeFromXML($value);
        }
        $newvalue = $metadata->toHash();
    }
    return $newvalue;
}

## @method protected void setKeyToH(hashref h,string key,string k2,string value)
# Insert key=>$value in $h at the position declared with $key. If $k2 is set,
# insert key=>{$k2=>$value}. Note that $key is splited with "/". The last part
# is used as key.
# @param $h New Lemonldap::NG configuration
# @param $key String "/path/key"
# @param $k2 Optional subkey
sub setKeyToH {
    my $value = pop;
    return unless ( ref($value) or length($value) );
    my ( $self, $h, $key, $k2 ) = @_;
    my $tmp = $h;
    $key =~ s/^\///;
    $value = $self->formatValue( $key, $value );
    while (1) {
        if ( $key =~ /\// ) {
            my $k = $`;
            $key = $';
            $tmp = $tmp->{$k} ||= {};
        }
        else {
            if ($k2) {
                $tmp->{$key} = {} unless ( ref( $tmp->{$key} ) );
                $tmp->{$key}->{$k2} = $value;
            }
            else {
                $tmp->{$key} = $value;
            }
            last;
        }
    }
}

## @method private XML::LibXML parser()
# @return XML::LibXML object (cached in global $parser variable)
sub parser {
    my $self = shift;
    return $parser if ($parser);
    $parser = XML::LibXML->new();
}

## @method private XML::LibXSLT stylesheet()
# Returns XML::LibXSLT parser (cached in global $stylesheet variable). Use
# datas stored at the end of this file to initialize the object.
# @return XML::LibXSLT object
sub stylesheet {
    my $self = shift;

    return $stylesheet if ($stylesheet);
    my $xslt = XML::LibXSLT->new();
    my $style_doc = $self->parser->parse_string( join( '', <DATA> ) );
    close DATA;
    $stylesheet = $xslt->parse_stylesheet($style_doc);
}

1;
__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <xsl:output method="xml"
             encoding="UTF-8"/>
 <xsl:template match="/">
  <root>
  <xsl:apply-templates/>
  </root>
 </xsl:template>
 <xsl:template match="li">
  <xsl:choose>
   <xsl:when test="starts-with(.,'.')">
    <ignore><xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute></ignore>
   </xsl:when>
   <xsl:otherwise>
    <xsl:apply-templates/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 <xsl:template match="span">
  <xsl:choose>
   <xsl:when test="@id='text_li_cm9vdA2'">
    <conf><xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute></conf>
   </xsl:when>
   <xsl:otherwise>
    <element>
     <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
     <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
    </element>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
