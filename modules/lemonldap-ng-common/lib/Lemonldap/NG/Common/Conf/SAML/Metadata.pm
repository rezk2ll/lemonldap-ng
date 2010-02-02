
##@class
# SAML Metadata object for Lemonldap::NG
package Lemonldap::NG::Common::Conf::SAML::Metadata;

use strict;
use warnings;
use XML::Simple;
use Data::Dumper;
use Safe;

our $VERSION = '0.1';
our $DEBUG   = 0;

## @cmethod Lemonldap::NG::Common::Conf::SAML::Metadata new(hashRef args)
# Class constructor.
#@param args hash reference
#@return Lemonldap::NG::Common::Conf::SAML::Metadata object
sub new {
    my $class = shift;
    my $self = bless {}, $class;
    if ( ref( $_[0] ) ) {
        %$self = %{ $_[0] };
    }
    elsif ( defined @_ && $#_ % 2 == 1 ) {
        %$self = @_;
    }
    return $self;
}

## @method void setDebug(boolean debug)
# Set debug flag
# @param boolean debug value
# @return nothing
sub setDebug {
    my $self = shift;
    my $debug = shift || 1;

    $DEBUG = $debug;

    return;
}

## @method public static hashref createSimpleStruct ()
# Create a simple struct that allow user to turn SAML
# feature on.
# @return hashref Simple struct to be included in Manager
#                 configuration structure
sub createSimpleStruct {
    return {
        _nodes => [
            qw(samlEntityID n:samlOrganization n:samlSPSSODescriptor n:samlIDPSSODescriptor)
        ],
        _help  => 'default',

        ############################
        # Global SAML Informations #
        ############################

        samlEntityID => 'text:/samlEntityID',
        samlOrganization => {
            _nodes => [
                qw(samlOrganizationDisplayName samlOrganizationName samlOrganizationURL)
            ],
            _help  => 'default',
            samlOrganizationDisplayName => 'text:/samlOrganizationDisplayName',
            samlOrganizationURL => 'text:/samlOrganizationURL',
            samlOrganizationName => 'text:/samlOrganizationName',
          },

        #########################
        # SAML Service Provider #
        #########################

        'samlSPSSODescriptor' => {
            _nodes => [
                qw(samlSPSSODescriptorAuthnRequestsSigned
                          samlSPSSODescriptorProtocolSupportEnumeration
                          n:samlSPSSODescriptorKeyDescriptor
                          n:samlSPSSODescriptorSingleLogoutService
                  n:samlSPSSODescriptorAssertionConsumerService)
            ],
            _help  => 'default',

            samlSPSSODescriptorAuthnRequestsSigned =>
              'text:/samlSPSSODescriptorAuthnRequestsSigned',
            samlSPSSODescriptorProtocolSupportEnumeration =>
              'text:/samlSPSSODescriptorProtocolSupportEnumeration',

            samlSPSSODescriptorKeyDescriptor => {
                _nodes => [
                    qw(samlSPSSODescriptorKeyDescriptorSigning
                      samlSPSSODescriptorKeyDescriptorEncryption)
                ],
                _help => 'default',
                samlSPSSODescriptorKeyDescriptorSigning =>
                  'text:/samlSPSSODescriptorKeyDescriptorSigning',
                samlSPSSODescriptorKeyDescriptorEncryption =>
                  'text:/samlSPSSODescriptorKeyDescriptorEncryption',
              },

            samlSPSSODescriptorSingleLogoutService => {
                _nodes => [
                    qw(samlSPSSODescriptorSingleLogoutServiceHTTPLocation
                              samlSPSSODescriptorSingleLogoutServiceHTTPReponseLocation
                              samlSPSSODescriptorSingleLogoutServiceSOAPLocation
                      samlSPSSODescriptorSingleLogoutServiceSOAPResponseLocation)
                ],
                _help  => 'default',
                samlSPSSODescriptorSingleLogoutServiceHTTPLocation =>
                  'text:/samlSPSSODescriptorSingleLogoutServiceHTTPLocation',
                samlSPSSODescriptorSingleLogoutServiceHTTPReponseLocation =>
'text:/samlSPSSODescriptorSingleLogoutServiceHTTPReponseLocation',
                samlSPSSODescriptorSingleLogoutServiceSOAPLocation =>
                  'text:/samlSPSSODescriptorSingleLogoutServiceSOAPLocation',
                samlSPSSODescriptorSingleLogoutServiceSOAPResponseLocation =>
'text:/samlSPSSODescriptorSingleLogoutServiceSOAPResponseLocation',
              },

            samlSPSSODescriptorAssertionConsumerService => {
                _nodes => [
                    qw(n:samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact
                              n:samlSPSSODescriptorAssertionConsumerServiceHTTPPost
                      n:samlSPSSODescriptorAssertionConsumerServiceHTTPRedirect)
                ],
                _help  => 'default',

                samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact => {
                    _nodes => [
                        qw(samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactIndex
                                  samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactDefault
                          samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactLocation)
                    ],
                    _help  => 'default',
                    samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactIndex =>
'int:/samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactIndex',
                    samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactDefault =>
'bool:/samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactDefault',
                    samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactLocation =>
'text:/samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactLocation',
                  },

                samlSPSSODescriptorAssertionConsumerServiceHTTPPost => {
                    _nodes => [
                        qw(samlSPSSODescriptorAssertionConsumerServiceHTTPPostIndex
                                  samlSPSSODescriptorAssertionConsumerServiceHTTPPostDefault
                          samlSPSSODescriptorAssertionConsumerServiceHTTPPostLocation)
                    ],
                    _help  => 'default',
                    samlSPSSODescriptorAssertionConsumerServiceHTTPPostIndex =>
'int:/samlSPSSODescriptorAssertionConsumerServiceHTTPPostIndex',
                    samlSPSSODescriptorAssertionConsumerServiceHTTPPostDefault =>
'bool:/samlSPSSODescriptorAssertionConsumerServiceHTTPPostDefault',
                    samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactLocation =>
'text:/samlSPSSODescriptorAssertionConsumerServiceHTTPPostLocation',
                  },

                samlSPSSODescriptorAssertionConsumerServiceHTTPRedirect => {
                    _nodes => [
                        qw(samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectIndex
                                  samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectDefault
                          samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectLocation)
                    ],
                    _help  => 'default',
                    samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectIndex =>
'int:/samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectIndex',
                    samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectDefault =>
'bool:/samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectDefault',
                    samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectLocation =>
'text:/samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectLocation',
                  },
              },
          },

        ##########################
        # SAML Identity Provider #
        ##########################

        samlIDPSSODescriptor => {
            _nodes => [
                qw(samlIDPSSODescriptorWantAuthnRequestsSigned
                          samlIDPSSODescriptorProtocolSupportEnumeration
                          n:samlIDPSSODescriptorKeyDescriptor
                          n:samlIDPSSODescriptorSingleSignOnService
                          n:samlIDPSSODescriptorSingleLogoutService
                          n:samlIDPSSODescriptorArtifactResolutionService
                  n:samlIDPSSODescriptorManageNameIDService)
            ],
            _help  => 'default',

            samlIDPSSODescriptorWantAuthnRequestsSigned =>
              'text:/samlIDPSSODescriptorWantAuthnRequestsSigned',
            samlIDPSSODescriptorProtocolSupportEnumeration =>
              'text:/samlIDPSSODescriptorProtocolSupportEnumeration',

            samlIDPSSODescriptorKeyDescriptor => {
                _nodes => [
                    qw(samlIDPSSODescriptorKeyDescriptorSigning
                      samlIDPSSODescriptorKeyDescriptorEncryption)
                ],
                _help => 'default',
                samlIDPSSODescriptorKeyDescriptorSigning =>
                  'text:/samlIDPSSODescriptorKeyDescriptorSigning',
                samlIDPSSODescriptorKeyDescriptorEncryption =>
                  'text:/samlIDPSSODescriptorKeyDescriptorEncryption',
              },

            samlIDPSSODescriptorSingleSignOnService => {
                _nodes => [
                    qw(samlIDPSSODescriptorSingleSignOnServiceHTTPLocation
                      samlIDPSSODescriptorSingleSignOnServiceSOAPLocation)
                ],
                _help => 'default',
                samlIDPSSODescriptorSingleSignOnServiceHTTPLocation =>
                  'text:/samlIDPSSODescriptorSingleSignOnServiceHTTPLocation',
                samlIDPSSODescriptorSingleSignOnServiceSOAPLocation =>
                  'text:/samlIDPSSODescriptorSingleSignOnServiceSOAPLocation',
              },

            samlIDPSSODescriptorSingleLogoutService => {
                _nodes => [
                    qw(samlIDPSSODescriptorSingleLogoutServiceHTTPLocation
                              samlIDPSSODescriptorSingleLogoutServiceHTTPResponseLocation
                              samlIDPSSODescriptorSingleLogoutServiceSOAPLocation
                      samlIDPSSODescriptorSingleLogoutServiceSOAPResponseLocation)
                ],
                _help  => 'default',
                samlIDPSSODescriptorSingleLogoutServiceHTTPLocation =>
                  'text:/samlIDPSSODescriptorSingleLogoutServiceHTTPLocation',
                samlIDPSSODescriptorSingleLogoutServiceHTTPResponseLocation =>
'text:/samlIDPSSODescriptorSingleLogoutServiceHTTPResponseLocation',
                samlIDPSSODescriptorSingleLogoutServiceSOAPLocation =>
                  'text:/samlIDPSSODescriptorSingleLogoutServiceSOAPLocation',
                samlIDPSSODescriptorSingleLogoutServiceSOAPResponseLocation =>
'text:/samlIDPSSODescriptorSingleLogoutServiceSOAPResponseLocation',
              },

            samlIDPSSODescriptorArtifactResolutionService => {
                _nodes =>
                  [qw(n:samlIDPSSODescriptorArtifactResolutionServiceArtifact)],
                _help  => 'default',

                samlIDPSSODescriptorArtifactResolutionServiceArtifact => {
                    _nodes => [
                        qw(samlIDPSSODescriptorArtifactResolutionServiceArtifactIndex
                                  samlIDPSSODescriptorArtifactResolutionServiceArtifactDefault
                          samlIDPSSODescriptorArtifactResolutionServiceArtifactLocation)
                    ],
                    _help  => 'default',
                    samlIDPSSODescriptorArtifactResolutionServiceArtifactIndex =>
'int:/samlIDPSSODescriptorArtifactResolutionServiceArtifactIndex',
                    samlIDPSSODescriptorArtifactResolutionServiceArtifactDefault =>
'bool:/samlIDPSSODescriptorArtifactResolutionServiceArtifactDefault',
                    samlIDPSSODescriptorArtifactResolutionServiceArtifactLocation =>
'text:/samlIDPSSODescriptorArtifactResolutionServiceArtifactLocation',
                  },
              },

            samlIDPSSODescriptorManageNameIDService => {
                _nodes => [
                    qw(samlIDPSSODescriptorManageNameIDServiceHTTPLocation
                              samlIDPSSODescriptorManageNameIDServiceHTTPResponseLocation
                              samlIDPSSODescriptorManageNameIDServiceSOAPLocation
                      samlIDPSSODescriptorManageNameIDServiceSOAPResponseLocation)
                ],
                _help  => 'default',
                samlIDPSSODescriptorManageNameIDServiceHTTPLocation =>
                  'text:/samlIDPSSODescriptorManageNameIDServiceHTTPLocation',
                samlIDPSSODescriptorManageNameIDServiceHTTPResponseLocation =>
'text:/samlIDPSSODescriptorManageNameIDServiceHTTPResponseLocation',
                samlIDPSSODescriptorManageNameIDServiceSOAPLocation =>
                  'text:/samlIDPSSODescriptorManageNameIDServiceSOAPLocation',
                samlIDPSSODescriptorManageNameIDServiceSOAPResponseLocation =>
'text:/samlIDPSSODescriptorManageNameIDServiceSOAPResponseLocation',
              },
          },
      };
}

## @method public boolean initiliazeFromConf(string s)
# Initialize this object from configuration string.
# @param $s Configuration string.
# @return boolean
sub initializeFromConf {
    my $self = shift;
    my $string = shift;

    $string =~ s/&#39;/'/g;
    my $data = eval $string;

    return $self->initializeFromConfHash($data);
}

## @method public boolean initiliazeFromConfHash(hash h)
# Initialize this object from configuration hash element.
# @param $h Configuration hash element.
# @return boolean
sub initializeFromConfHash {
    my $self = shift;
    my $hash = shift;

    return 0 unless $hash;

    while ( my ( $k, $v ) = each(%$hash) ) {
      $self->{$k} = $v;
    }

    return 1;
}

## @method public boolean initializeFromFile(string file)
# Initialize this object from XML file.
# @param $file Filename
# @return boolean
sub initializeFromFile {
    my $self = shift;
    my $file = shift;
    my $xml = $self->_loadFile($file);
    if ( !$xml ) {
      return 0;
    }
    return $self->initializeFromXML($xml);
}

## @method public boolean initializeFromXML(string string)
# Initialize this object from configuration XML string.
# @param $string Configuration XML string.
# @return boolean
sub initializeFromXML {
    my $self = shift;
    my $string = shift;

    # Remove spaces
    $string =~ s/[\n\r\s]+/ /g;
    $string =~ s/> </></g;

    # New XML::Simple object
    my $xs = XML::Simple->new( ForceContent => 1 );
    my $data = $xs->XMLin($string);

    # Store data in Metadata object
    if ($data) {
        while ( my ( $k, $v ) = each( %{$data} ) ) {
      $self->{$k} = $v;
    }
    return 1;
    }
    return 0;

}

## @method public string toXML
# Return this object in XML format.
# @return string
sub toXML {
    my $self = shift;

    # Use XML::Simple to Dump Perl Hash in XML format
    my $xs = XML::Simple->new( RootName => "md:EntityDescriptor" );

    # Force xmlns:md key
    $self->{"xmlns:md"} = "urn:oasis:names:tc:SAML:2.0:metadata" unless defined $self->{"xmlns:md"};

    # Serialize XML
    my $xml = $xs->XMLout($self);

    return $xml;
}

## @method public string toConf ()
# Return this object in configuration string format.
# @return string
sub toConf {
    my $self = shift;
    my $fields;
    local $Data::Dumper::Indent = 0;
    local $Data::Dumper::Varname = "data";
    my $data = Dumper($self);
    $data =~ s/^\s*(.*?)\s*$/$1/;
    $data =~ s/'/&#39;/g;
    return $data;
}

## @method public hashref toStruct ()
# Return this object to be display into the Manager.
# @return hashref
sub toStruct {
  my $self = shift;
  my $struct = ();
    foreach ( keys %$self ) {
    $struct->{$_} = $self->{$_};
  }
    return $self->_toStruct( '', $struct );
}

## @method private hashref _toStruct (Hashref node)
# Return a preformated structure to be stored into Manager structure.
# @param $path The path of the node.
# @param $node The current node into the hashref tree.
# @return Hashref A structure to be inserted into Manager structure.
sub _toStruct {
    my $self = shift;
    my $path = shift;
    my $node = shift;
    if ( ref $node ) {
      my $struct = {
          _nodes => [],
          _help => 'default'
        };
      my @nodes = ();
        my $tmpnode;
        if ( ref $node eq 'ARRAY' ) {

            # More than one value for the same key
            # Build a hash with indices
            my $i = 0;
            foreach (@$node) {
                $tmpnode->{$i} = $node->[$i];
            }
        }
        else {
            $tmpnode = $node;
        }
        foreach ( keys %$tmpnode ) {

            if ( $_ =~ /^xmlns/ ) {
          next;
        }
        my $key = $path . ' ' . $_;
        $key =~ s/^ +//g;
            my $data;

            $data = $self->_toStruct( $key, $tmpnode->{$_} );
            if ($data) {
          $struct->{$key} = $data;
          push @nodes, 'n:' . $key;
        }
            else {
          $struct->{$key} = 'text:/' . $_;
          push @nodes, $key;
        }
      }
      $struct->{_nodes} = \@nodes;
      return $struct;
    }
    return 0;
}

## @method public static boolean load(Array files)
# Return an array of Metadata object.
# @param $files Array of filenames
# @return Array of Metadata objects
sub load {
    my @files     = splice @_;
    my @metadatas = ();
    foreach (@files) {
      my $metadata = new Lemonldap::NG::Common::Conf::SAML::Metadata();
        if ( $metadata->initializeFromFile($_) ) {
        push @metadatas, $metadata;
      }
    }
    return @metadatas;
}

## @method private hashref _loadFile(string file)
# Load XML file as a XML string.
# @param $file Filename
# @return string
sub _loadFile {
    my $self = shift;
    my $file = shift;
    local $/ = undef;
    open FILE, $file
      or die "Couldn't open file: $!";
    my $string = <FILE>;
    close FILE;
    return $string;
}

1;

