## @file
# Test uploaded parameters and store new configuration

## @class
# Test uploaded parameters and store new configuration
package Lemonldap::NG::Manager::Uploader;

use strict;
use XML::LibXML;
use XML::LibXSLT;
use MIME::Base64;

# TODO
use Data::Dumper;
use Lemonldap::NG::Common::Safelib;        #link protected safe Safe object
use Lemonldap::NG::Manager::Downloader;    #inherits
use Lemonldap::NG::Manager::_Struct;       #inherits

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

    # Apply XSLT stylesheet to returned datas
    my $result =
      $self->stylesheet->transform(
        $self->parser->parse_string( '<root>' . $$rdata . '</root>' ) )
      ->documentElement();

    # Get configuration number
    unless ( $self->{cfgNum} =
        $result->getChildrenByTagName('conf')->[0]->getAttribute('value') )
    {
        die "No configuration number found";
    }
    my $newConf = { cfgNum => $self->{cfgNum} };

    # Loading returned parameters
    my $errors = {};
    foreach ( @{ $result->getChildrenByTagName('element') } ) {
        my ( $id, $name, $value ) = (
            $_->getAttribute('id'),
            $_->getAttribute('name'),
            $_->getAttribute('value')
        );
        my $NK = 0;
        $id =~
          s/^text_(NewID_)?li_(\w+)(\d)(?:_\d+)?$/decode_base64($2.'='x $3)/e;
        $NK = 1 if ($1);
        $id =~ s/\r//g;
        $id =~ s/^\///;
        $id =~ s/(?:\/[^\/]*)?$/\/$name/ if ($NK);
        print STDERR "$id\n" if ($NK);
        next if ( $id =~ /^(generalParameters|virtualHosts)/ );
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

        # Tests (no test for hash root nodes)
        unless ( $test->{keyTest} and ( $id !~ /\// or $test->{'*'} ) ) {
            if ( $test->{keyTest} ) {
                ( $res, $m ) = $self->applyTest( $test->{keyTest}, $name );
                unless ($res) {
                    $errors->{errors}->{$name} = $m || $test->{keyMsgFail};
                    next;
                }
            }
            if ( $test->{test} ) {
                ( $res, $m ) = $self->applyTest( $test->{test}, $value );
                unless ($res) {
                    $errors->{errors}->{$name} = $m || $test->{msgFail};
                    next;
                }
            }
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
        $self->setKeyToH( $newConf, $confKey,
            $test->{keyTest}
            ? ( ( $id !~ /\// or $test->{'*'} ) ? {} : ( $name => $value ) )
            : $value );
    }

    # Loading unchanged parameters (ajax nodes not open)
    foreach ( @{ $result->getChildrenByTagName('ignore') } ) {
        my $node = $_->getAttribute('value');
        $node =~ s/^.*node=(.*?)(?:&.*)?\}$/$1/;
        foreach my $k ( $self->findAllConfKeys( $self->corresp( $node, 1 ) ) ) {
            my $v = $self->keyToH( $k, $self->conf );
            $v = $self->keyToH( $k, $self->defaultConf ) unless ( defined $v );
            if ( defined $v ) {
                $self->setKeyToH( $newConf, $k, $v );
            }
            else {
                $self->lmLog( "No default value found for $k", 'warn' );
            }
        }
    }

    #print STDERR Dumper( $newConf, $errors );
    #print STDERR Dumper($errors);
    $errors->{result}->{cfgNum} = $self->confObj->saveConf($newConf)
      unless ( $errors->{errors} );
    my $buf = '{';
    my $i   = 0;
    while ( my ( $type, $h ) = each %$errors ) {
        $buf .= ',' if ($i);
        $buf .= "'$type':{";
        $buf .= join( ',', map { "'$_':'$h->{$_}'" } keys %$h );
        $buf .= '}';
        $i++;
    }
    $buf .= '}';
    print $self->header(
        -type           => 'application/json',
        -Content_Length => length($buf)
    ) . $buf;
    $self->quit();
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
    foreach my $n ( @{ $h->{_nodes} } ) {
        $n =~ s/^.*?:(.*?)(?:\:.*)?$/$1/;
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

## @method protected void setKeyToH(hashref h,string key,string k2,string value)
# Insert key=>$value in $h at the position declared with $key. If $k2 is set,
# insert key=>{$k2=>$value}. Note that $key is splited with "/". The last part
# is used as key.
# @param $h New Lemonldap::NG configuration
# @param $key String "/path/key"
# @param $k2 Optional subkey
sub setKeyToH {
    my $value = pop;
    my ( $self, $h, $key, $k2 ) = @_;
    my $tmp = $h;
    $key =~ s/^\///;
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
