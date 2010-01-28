
##@class
# SAML Metadata object for Lemonldap::NG
package Lemonldap::NG::Common::Conf::SAML::Metadata;

use strict;
use warnings;
use XML::LibXML;
use Data::Dumper;
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

## @method public boolean initiliazeFromConf(string s)
# Initialize this object from configuration string.
# @param $s Configuration string.
# @return boolean
sub initializeFromConf
{
    my $self = shift;
    my ($string) = @_;
    $string =~ s/&#39;/'/g;
    my $data = eval $string;
    while ( my ( $k, $v ) = each(%$data) )
    {
      $self->{$k} = $v;
    }
    return 0;
}

## @method public boolean initializeFromFile(string file)
# Initialize this object from XML file.
# @param $file Filename
# @return boolean
sub initializeFromFile
{
    my $self = shift;
    my $file = shift;
    my $xml = $self->_loadFile($file);
    if (!$xml)
    {
      return 0;
    }
    return $self->initializeFromXML($xml);
}

## @method public boolean initializeFromXML(string string)
# Initialize this object from configuration XML string.
# @param $string Configuration XML string.
# @return boolean
sub initializeFromXML
{
    my $self = shift;
    my ($string) = @_;
    my $data;
    my $parser = XML::LibXML->new();
    $parser->validation('0');
    $string =~ s/[\n\r\s]+/ /g;
    $string =~ s/> </></g;
    eval
    {
      my $xml = $parser->parse_string($string);
      $data = $self->_parseXML($xml->documentElement);
    };
    return 0 if ($@);
    if ($data)
    {
    while (my ($k,$v) = each(%{$data}))
    {
      $self->{$k} = $v;
    }
    return 1;
    }
    return 0;
}

## @method public string toXML
# Return this object in XML format.
# @return string
sub toXML
{
    my $self = shift;
    my $writer = XML::LibXML->new();
    $writer->validation('0');
    my $doc = $writer->createDocument($self);
    return '';
}

## @method public string toConf ()
# Return this object in configuration string format.
# @return string
sub toConf
{
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
sub toStruct
{
  my $self = shift;
  my $struct = ();
  foreach (keys %$self)
  {
    $struct->{$_} = $self->{$_};
  }
  return $self->_toStruct('', $struct);
}

## @method private hashref _toStruct (Hashref node)
# Return a preformated structure to be stored into Manager structure.
# @param $path The path of the node.
# @param $node The current node into the hashref tree.
# @return Hashref A structure to be inserted into Manager structure.
sub _toStruct
{
    my $self = shift;
    my $path = shift;
    my ($node) = @_;
    if (ref $node)
    {
      my $struct = {
          _nodes => [],
          _help => 'default'
        };
      my @nodes = ();
      foreach (keys %$node)
      {
        if ($_ =~ /^xmlns/)
        {
          next;
        }
        my $key = $path . ' ' . $_;
        $key =~ s/^ +//g;
        my $data = $self->_toStruct($key, $node->{$_});
        if ($data)
        {
          $struct->{$key} = $data;
          push @nodes, 'n:' . $key;
        }
        else
        {
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
sub load
{
    my @files = @_;
    my @metadatas = ();
    foreach (@files)
    {
      my $metadata = new Lemonldap::NG::Common::Conf::SAML::Metadata();
      if ($metadata->initializeFromFile($_))
      {
        push @metadatas, $metadata;
      }
    }
    return @metadatas;
}

## @method private hashref _loadFile(string file)
# Load XML file as a XML string.
# @param $file Filename
# @return string
sub _loadFile
{
    my $self = shift;
    my $file = shift;
    local $/=undef;
    open FILE, $file
      or die "Couldn't open file: $!";
    my $string = <FILE>;
    close FILE;
    return $string;
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

