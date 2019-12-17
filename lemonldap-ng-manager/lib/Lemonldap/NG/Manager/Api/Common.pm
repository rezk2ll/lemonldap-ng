package Lemonldap::NG::Manager::Api::Common;
our $VERSION = '2.0.7';

package Lemonldap::NG::Manager::Api;

use Lemonldap::NG::Manager::Build::Attributes;
use Lemonldap::NG::Manager::Build::CTrees;
# use Scalar::Util 'weaken'; ?

sub _isSimpleKeyValueHash {
    my ( $self, $hash) = @_;
    if (ref($hash) ne "HASH") {
        return 0;
    }
    foreach (keys %{$hash}) {
        if (ref($hash->{$_}) ne '' || ref($_) ne '') {
            return 0;
        }
    }
    return 1;
}

sub _setDefaultValues {
    my ( $self, $attrs, $rootNode) = @_;
    my @allAttrs = $self->_listAttributes($rootNode);
    my $defaultAttrs = Lemonldap::NG::Manager::Build::Attributes::attributes();

    foreach $attr (@allAttrs) {
        unless (defined $attrs->{$attr}) {
            if (defined $defaultAttrs->{$attr} && defined $defaultAttrs->{$attr}->{default}) {
                $attrs->{$attr} = $defaultAttrs->{$attr}->{default};
            }
        }
    }

    return $attrs;
}

sub _hasAllowedAttributes {
    my ( $self, $attributes, $rootNode) = @_;

    my @allowedAttributes = $self->_listAttributes($rootNode);

    foreach $attribute (keys %{$attributes}) {
        if (length(ref($attribute))) {
            return {
                res => "ko",
                msg => "Invalid input: Attribute $attribute is not a string."
            };
        }
        unless (grep {/^$attribute$/} @allowedAttributes) {
            return {
                res => "ko",
                msg => "Invalid input: Attribute $attribute does not exist."
            };
        }
    }

    return { res => "ok" };
}

sub _listAttributes {
    my ( $self, $rootNode) = @_;

    my $mainTree = Lemonldap::NG::Manager::Build::CTrees::cTrees();

    my $rootNodes = [ grep { ref($_) eq "HASH" } @{$mainTree->{$rootNode}} ];

    my @attributes;
    foreach $node (@{$rootNodes}) {
        push @attributes, $self->_listNodeAttributes($node);
    }
    return @attributes;
}

sub _listNodeAttributes {
    my ( $self, $node) = @_;

    my @attributes;
    foreach $child (@{$node->{nodes}}) {
        if (ref($child) eq "HASH"){
            push (@attributes, $self->_listNodeAttributes($child));
        } else {
           push (@attributes, $child);
        }
    }

    return @attributes;
}

1;
