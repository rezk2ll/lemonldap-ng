##@file
# Configuration tree file

##@class Lemonldap::NG::Manager::Downloader
# Configuration tree builder
package Lemonldap::NG::Manager::Downloader;

use MIME::Base64;

# TODO
use Data::Dumper;

require Lemonldap::NG::Manager::_Struct;    #inherits
require Lemonldap::NG::Manager::_i18n;      #inherits

## @method string node(string node)
# Build the part of the tree that does not depends of the the configuration.
# Call corresp(), ajaxNode(), confNode() or itself with li() and span().
#@param $node Node to display
#@return HTML string
sub node {
    my ( $self, $node ) = @_;
    my $res;
    $node =~ s/^\///;

    #$self->lmLog( "Processing to node: $node", 'debug' );
    if ( my ( $tmp, $help, $js ) = $self->corresp($node) ) {

        # Menu node
        if ( ref($tmp) ) {

            # expand _nodes
            if ( ref( $tmp->{_nodes} ) eq 'CODE' ) {
                $tmp->{_nodes} = $tmp->{_nodes}->($self);
            }

            # Scan subnodes
            foreach ( @{ $tmp->{_nodes} } ) {
                my $flag = ( $_ =~ s/^(\w+):// ? $1 : '' );
                my ( $target, $_h, $_j ) = split /:\s*/;
                $help ||= $_h;

                # subnode is an ajax subnode
                if ( $flag =~ /^(c?)n$/ ) {
                    $res .= $self->ajaxNode(
                        ( $1 ? $target : "$node/$target" ),
                        "$target",
                        "node=$node/$target",
                        $tmp->{$target}->{_help} || $help,
                        $tmp->{$target}->{_js},
                        '',
                        0,
                        $tmp->{$target}->{_call}
                    );
                    next;
                }

                # Substitute sub by its value
                if ( ref( $tmp->{$target} ) eq 'sub' ) {
                    $tmp->{$target} = &{ $tmp->{$target} }($self);
                }

                # subnode is a node
                if ( ref( $tmp->{$target} ) ) {
                    $res .= $self->li( "$node/$target", "closed" )
                      . $self->span(
                        "$node/$target", $target, '',
                        $tmp->{$target}->{_js},
                        $tmp->{$target}->{_help} || $help
                      )
                      . "<ul>"
                      . $self->node("$node/$target")
                      . "</ul></li>";
                }

                # subnode points to a configuration node
                elsif ( $flag =~ /^n?hash$/ ) {
                    $res .=
                      $self->confNode( $node, "$flag:$target", $help, $_j );
                }

                else {
                    $res .= $self->node("$node/$target");
                }
            }
        }

        # node points to a configuration point
        else {
            $res .= $self->confNode( $node, $tmp, $help, $js );
        }
    }
    else {
        $self->lmLog( "$node was not found in tree\n", 'error' );
    }
    return $res;
}

## @method string confNode(string node, string target, string help, string js)
# Build the part of the tree that does not depends of the the configuration.
# Call ajaxNode(), itself, keyToH(), li(), span().
# @param node Unique identifier for the node
# @param target String that represents the type and the position of the
# parameter in the configuration
# @param help Help chapter to display when selected
# @param js Javascript function to launch when selected
# @return HTML string
sub confNode {
    my ( $self, $node, $target, $help, $js ) = @_;
    my $res;
    $self->lmLog( "Processing to configuration node: $target", 'debug' );
    $target =~ s/^\///;
    if ( $target =~ /^(.+?):(?!\/)(.+?):(?!\/)(.+?)$/ ) {
        ( $target, $help, $js ) = ( $1, $2, $3 );
    }

    # Hash datas downloaded later by ajax if needed
    if ( $target =~ s/^nhash:// ) {
        my $h = $self->keyToH( $target, $self->conf );
        return unless ($h);
        foreach ( sort keys %$h ) {
            if ( ref($h) ) {
                $res .= $self->ajaxNode( "$target/$_", $_,
                    "node=$node/$_\&amp;key=$_", $help, $js, undef, 1 );
            }
            else {
                $res .=
                  $self->confNode( "$target/$_", "btext:$target/$_", $help,
                    $js );
            }
        }
    }

    # Hash datas
    elsif ( $target =~ s/^hash:// ) {
        my $h = $self->keyToH( $target, $self->conf );
        unless ($h) {
            my $tmp;
            unless ( ($tmp) = ( $target =~ /^\/?(.*)\// )
                and $h = $self->subDefaultConf()->{$tmp} )
            {
                $self->lmLog( "$target hash is not defined in configuration",
                    'error' );
                return;
            }
        }
        foreach ( sort keys %$h ) {
            if ( ref( $h->{$_} ) ) {
                $res .= $self->confNode( "$target/$_", $help, $js );
            }
            else {
                $js ||= 'btext';
                my $id = "$target/$_";
                $id =~ s/=*$//;

                # Here, "notranslate" is set to true : hash values must not be
                # translated
                $res .=
                    $self->li($id)
                  . $self->span( $id, "$_", $h->{$_}, $js, $help, 1 ) . "</li>";
            }
        }
    }

    # subnode is a conditaional node
    elsif ( $target =~ s/^sub:// ) {
        foreach my $s ( $self->_sub($target) ) {
            $res .= $self->confNode( $node, $s, $help );
        }
    }

    else {
        $target =~ s/^(\w+)://;
        my $type = $1 || 'text';
        $js ||= $type;
        my $text = $target;
        $text =~ s/^.*\///;
        my $h = $self->keyToH( $target, $self->conf );

        $h = $self->keyToH( $target, $self->defaultConf ) unless ( defined $h );
        unless ( defined $h ) {
            $self->lmLog( "$target does not exists in menu hash", "debug" );
            $h = {
                text  => '',
                hash  => {},
                'int' => 0,
            }->{$type};
            $self->lmLog( "Type $type unknown", 'warn' ) unless ( defined $h );
        }
        if ( ref($h) ) {
            $res .=
                $self->li( "$target", "closed" )
              . $self->span( "$target", $text, '', $js, $help ) . "<ul>";
            foreach ( sort keys %$h ) {
                if ( ref( $h->{$_} ) ) {
                    $res .=
                      $self->confNode( '', "btext:$target/$_", $help, $js );
                }
                else {
                    my $id = "$target/$_";
                    $res .=
                        $self->li($id)
                      . $self->span( $id, $_, $h->{$_}, $js, $help ) . "</li>";
                }
            }
            $res .= '</ul></li>';
        }
        else {
            my $id = "$target";
            $res .=
                $self->li($id)
              . $self->span( $id, $text, $h, $js, $help ) . "</li>";
        }
    }
    return $res;
}

## @method hashref keyToH(string key, hashref h)
# Return the part of $h corresponding to $key.
# Example, if $h={a=>{b=>{c=>1}}} and $key='/a/b' then keyToH() will
# return {c=>1}
# @return hashref
sub keyToH {
    my ( $self, $key, $h ) = @_;
    $key =~ s/^\///;
    foreach ( split /\//, $key ) {
        return () unless ( defined( $h->{$_} ) );
        $h = $h->{$_};
    }
    return $h;
}

## @method array corresp(string key,boolean last)
# Search a the key $key in the hashref Lemonldap::NG::Manager::struct().
# If $key is not set, uses Lemonldap::NG::Manager::struct().
# If the URL parameter key is set, uses Lemonldap::NG::Manager::cstruct()
# with this parameter.
# This function call itself 1 time if the key is not found using cstruct().
# The flag $last is used to avoid loop.
# @return An array containing :
# - the (sub)structure of the menu
# - the help chapter (using inheritance of the up key)
# - the optional javascript function to use when node is selected
# @param key string
# @param last optional boolean
sub corresp {
    my ( $self, $key, $last ) = @_;
    $key =~ s/^\///;
    my $h = $self->struct();
    return $h unless ($key);
    if ( my $k2 = $self->param('key') ) {
        $h = $self->cstruct( $h, $k2 );
    }
    my @tmp1 = split /\//, $key;
    my $help;
    my $js;
    while ( $_ = shift(@tmp1) ) {
        if ( ref($h) and defined $h->{$_} ) {
            $help = $h->{_help} if ( $h->{_help} );
            $js   = $h->{_js}   if ( $h->{_js} );
            $h    = $h->{$_};
        }

        # The wanted key does not exists
        elsif ( ref($h) ) {
            unless ($last) {
                $self->param( 'key', $_ );
                return $self->corresp( $key, 1 );
            }
            else {
                $self->lmLog( "Key $key does not exist in configuration hash",
                    'error' );
                return ();
            }
        }

        # If the key does not exist in manager tree, it must be defined in
        # configuration hash
        else {
            return "$h/" . join( '/', $_, @tmp1 );
        }
    }
    if ( ref($h) ) {
        $help = $h->{_help} if ( $h->{_help} );
        $js   = $h->{_js}   if ( $h->{_js} );
    }
    return $h, $help, $js;
}

## @method protected hashref conf()
# If configuration is not in memory, calls
# Lemonldap::NG::Common::Conf::getConf() and returns it.
# @return Lemonldap::NG configuration
sub conf {
    my $self = shift;
    return $self->{_conf} if ( $self->{_conf} );
    my $args = { cfgNum => $self->{cfgNum} };
    $args->{noCache} = 1 if ( $self->param('cfgNum') );
    $self->{_conf} = $self->confObj->getConf($args);
    $self->abort( 'Unable to get configuration',
        $Lemonldap::NG::Common::Conf::msg )
      unless ( $self->{_conf} );
    if ( my $c = $self->param('conf') ) {
        $self->{_conf}->{$_} = $self->param($_) foreach ( split /\s+/, $c );
    }
    return $self->{_conf};
}

## @method protected Lemonldap::NG::Common::Conf confObj()
# At the first call, creates a new Lemonldap::NG::Common::Conf object and
# return it. This object is cached for later calls.
# @return Lemonldap::NG::Common::Conf object
sub confObj {
    my $self = shift;
    return $self->{_confObj} if ( $self->{_confObj} );
    $self->{_confObj} =
      Lemonldap::NG::Common::Conf->new( $self->{configStorage} );
    $self->abort(
        'Unable to access to configuration',
        $Lemonldap::NG::Common::Conf::msg
    ) unless ( $self->{_confObj} );
    $self->lmLog( $Lemonldap::NG::Common::Conf::msg, 'debug' )
      if ($Lemonldap::NG::Common::Conf::msg);
    return $self->{_confObj};
}

## @method protected string ajaxnode(string id,string text,string param,string help,string js,string data,boolean noT)
# Returns a tree node with Ajax functions inside for opening the node later.
# Call li() and span().
# @param $id HTML id of the element
# @param $text text to display
# @param $param Parameters for the Ajax query
# @param $help Help chapter to display
# @param $js Javascript function to call when selected
# @param $data Value of the parameter
# @param $noT Optional flag to block translation
# @return HTML string
sub ajaxNode {
    my ( $self, $id, $text, $param, $help, $js, $data, $noT, $call ) = @_;
    $param .= "&amp;cfgNum=$self->{cfgNum}";
    return
        $self->li($id)
      . $self->span( $id, $text, $data, undef, $help, $noT )
      . "<ul class=\"ajax\">"
      . $self->li("sub_$id")
      . ".{url:$ENV{SCRIPT_NAME}?$param"
      . ( $js ? ",js:$js" : '' )
      . ( $call ? ",call:$call" : '' )
      . "}</li></ul></li>\n";
}

## @method protected string span(string id,string text,string param,string help,string js,string data,boolean noT)
# Return the span part of the node
# @param $id HTML id of the element
# @param $text text to display
# @param $param Parameters for the Ajax query
# @param $help Help chapter to display
# @param $js Javascript function to call when selected
# @param $data Value of the parameter
# @param $noT Optional flag to block translation
# @return HTML string
sub span {
    my ( $self, $id, $text, $data, $js, $help, $noT ) = @_;
    use Carp qw(cluck);
    cluck('dd') if ( $js eq 'default' );
    my $tmp = $text;
    $data = '' unless ( defined $data );
    $js ||= "none";
    $id = "li_" . encode_base64( $id, '' );
    $id   =~ s/(=*)$/length($1)/e;
    $data =~ s/"/&#39;/g;
    $tmp  =~ s/"/&#39;/g;
    $text = join ' ', map { $self->translate($_) } split /\s+/, $text
      unless ($noT);
    $text = $self->escapeHTML($text);
    return
"<span name=\"$tmp\" id=\"text_$id\" onclick=\"$js('$id')\" help=\"$help\" value=\"$data\">$text</span>
";
}

## @method protected string li(string id,string class)
# Returns the LI part of the node.
# @param $id HTML id of the element
# @param $class CSS class
# @return HTML string
sub li {
    my ( $self, $id, $class ) = @_;
    $id = "li_" . encode_base64( $id, '' );
    $id =~ s/(=*)$/length($1)/e;
    return "<li id=\"$id\"" . ( $class ? " class=\"$class\">" : ">" );
}

1;
