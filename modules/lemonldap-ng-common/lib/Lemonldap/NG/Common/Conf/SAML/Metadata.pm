
##@class
# SAML Metadata object for Lemonldap::NG
package Lemonldap::NG::Common::Conf::SAML::Metadata;

use strict;
use warnings;
use XML::LibXML;
use Safe;

our $VERSION = '0.1';

## @cmethod Lemonldap::NG::Common::Conf::SAML::Metadata new(hashRef args)
# Class constructor.
#@param args hash reference
#@return Lemonldap::NG::Common::Conf::SAML::Metadata object
sub new
{
    my $class = shift;
    my $self = bless {}, $class ;
    if ( ref( $_[0] ) )
    {
        %$self = %{ $_[0] };
    }
    elsif ( defined @_ && $#_ % 2 == 1 )
    {
        %$self = @_;
    }
    return $self;
}

## @method public boolean initializeFromFile(string file)
# Initialize this object from XML file.
# @param $file Filename
# @return boolean
sub initiliazeFromFile
{
    my $self = shift;
    my $file = shift;
    my $xml = $self->_loadFile($file);
    if (!$xml)
    {
      return 0;
    }
    my $data = $self->_parseXML($xml);
    while (my ($k,$v) = each(%{$data}))
    {
      $self->{$k} = $v;
    }
    return 1;
}

## @method public static boolean load(Array files)
# Return an array of Metadata object.
# @param $files Array of filenames
# @return Array of Metadata objects
sub load
{
    my @files = @_;
    my @metadatas = ();
    foreach (@files)
    {
      my $metadata = new Lemonldap::NG::Common::Conf::SAML::Metadata();
      if ($metadata->initiliazeFromFile($_))
      {
        push @metadatas, $metadata;
      }
    }
    return @metadatas;
}

## @method private hashref _loadFile(string file)
# Load XML file as a hash reference returned by LibXML.
# @param $file Filename
# @return Hashref
sub _loadFile
{
    my $self = shift;
    my $file = shift;
    my $parser = XML::LibXML->new();
    $parser->validation('0'); # should be 1
    my $xml;
    eval
    {
      $xml = $parser->parse_file( $file );
    };
    return 0 if ($@);
    my $root = $xml->documentElement;
    return $root;
}

## @method private hashref _parseXML(hashref node)
# Parse XML content and store data into a simple hashref.
# @param $node XML content returned by LibXML
# @return Hashref
sub _parseXML
{
    my $self = shift;
    my ($node) = @_;
    my $data = ();
    if ($node->getName() =~ /#text/)
    {
      return;
    }
    foreach my $attr ($node->getAttributes())
    {
      my $name = $attr->getName();
      my $value = $attr->getValue();
      $data->{$name} = $value;
    }
    my $i = 0;
    my @childs = $node->getChildNodes();
    foreach my $child (@childs)
    {
      my $child_data = $self->_parseXML($child);
      if ($child_data)
      {
        if (!$data->{$child->getName()})
        {
          $data->{$child->getName()} = ();
          $i = 0;
        }
        $data->{$child->getName()}->{$i} = $child_data;
        $i++;
      }
    }
    return $data;
}

1;

