##@file
# Configuration tree file

##@class Lemonldap::NG::Manager::Downloader
# Configuration tree builder
package Lemonldap::NG::Manager::Downloader;

use strict;
use MIME::Base64;

use URI::Escape;

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

    $self->lmLog( "Processing to node: $node", 'debug' );

    if ( my ( $tmp, $help, $js ) = $self->corresp($node) ) {

        # Menu node
        if ( ref($tmp) ) {

            # expand _nodes
            if ( ref( $tmp->{_nodes} ) eq 'CODE' ) {
                $tmp->{_nodes} = $tmp->{_nodes}->($self);
            }

            # Scan subnodes
            foreach ( @{ $tmp->{_nodes} } ) {
                $self->lmLog( "Scan subnode $_", 'debug' );
                my $flag = ( $_ =~ s/^(\w+):// ? $1 : '' );
                $self->lmLog( "Found flag $flag", 'debug' ) if $flag;
                my ( $target, $_h, $_j ) = split /:\s*/;
                $help ||= $_h;

                # subnode is an ajax subnode
                if ( $flag =~ /^(c?)n$/ ) {
                    $res .= $self->ajaxNode(
                        id => ( $1 ? $target : "$node/$target" ),
                        text  => "$target",
                        param => "node=$node/$target",
                        help  => $tmp->{$target}->{_help} || $help,
                        js    => $tmp->{$target}->{_js},
                        data  => '',
                        noT   => 0,
                        call  => $tmp->{$target}->{_call}
                    );
                    next;
                }

                # Substitute sub by its value
                if ( ref( $tmp->{$target} ) eq 'sub' ) {
                    $tmp->{$target} = &{ $tmp->{$target} }($self);
                }

                # subnode is a node
                if ( ref( $tmp->{$target} ) ) {
                    $self->lmLog( "$target is a subnode of $node", 'debug' );
                    $res .= $self->li( "$node/$target", "closed" )
                      . $self->span(
                        id   => "$node/$target",
                        text => $target,
                        data => '',
                        js   => $tmp->{$target}->{_js},
                        help => $tmp->{$target}->{_help} || $help
                      )
                      . "<ul>"
                      . $self->node("$node/$target")
                      . "</ul></li>";
                }

                # subnode points to a configuration node
                elsif ( $flag =~ /^(n?hash|applicationlist|post)$/ ) {
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
                $res .= $self->ajaxNode(
                    id    => "$target/$_",
                    text  => $_,
                    param => "node=$node/$_\&amp;key=$_",
                    help  => $help,
                    js    => $js,
                    noT   => 1
                );
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
            unless ( ($tmp) = ( $target =~ /^\/?([^\/]*)/ )
                and $h = $self->subDefaultConf()->{$tmp} )
            {
                $self->lmLog( "Try to get default conf for $tmp", 'debug' );
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

                # 1. Here, "notranslate" is set to true : hash values must not
                #    be translated
                # 2. if a regexp comment exists, it is set as text
                my $text = ( /^\(\?#(.*?)\)/ ? $1 : $_ );
                $res .= $self->li($id)
                  . $self->span(
                    id   => $id,
                    text => $text,
                    name => $_,
                    data => $h->{$_},
                    js   => $js,
                    help => $help,
                    noT  => 1
                  ) . "</li>";
            }
        }
    }

    # subnode is a conditional node
    elsif ( $target =~ s/^sub:// ) {
        foreach my $s ( $self->_sub($target) ) {
            $res .= $self->confNode( $node, $s, $help );
        }
    }

    # saml metadata
    elsif ( $target =~ s/^samlmetadata:// ) {
        my $h = $self->keyToH( $target, $self->conf );
        $h = $h->{samlIDPMetaDataXML} if ( ref $h && $h->{samlIDPMetaDataXML} );
        $h = $h->{samlSPMetaDataXML}  if ( ref $h && $h->{samlSPMetaDataXML} );
        my $data;

        # Manage old metadata format
        if ( ref($h) eq "HASH" ) {
            $self->lmLog( "Convert metadata from old format", 'debug' );
            my $metadata = Lemonldap::NG::Common::Conf::SAML::Metadata->new();
            $metadata->initializeFromConfHash($h);
            $data = $metadata->toXML();
        }
        else {
            $data = $h;
        }
        my $text = $target;
        $text =~ s/^\/([^\/]+)\/.*$/$1/;
        $res .= $self->li("$target/")
          . $self->span(
            id     => "$target/",
            text   => $text,
            data   => $data,
            js     => $js,
            help   => $help,
            target => "samlmetadata",
          ) . "</li>";
    }

    # Application list
    elsif ( $target =~ s/^applicationlist:// ) {
        $self->lmLog( "Load applications list (target $target)", 'debug' );

        my $h = $self->keyToH( $target, $self->conf );

        # Try to get value from defaultConf
        $h = $self->keyToH( $target, $self->defaultConf ) unless ( defined $h );

        unless ( defined $h ) {
            $self->lmLog( "$target is not defined in configuration", 'error' );
            return;
        }

        # Loop on categories
        foreach my $catid ( sort keys %$h ) {

            # Build ID
            my $id = "$target/$catid";
            $id =~ s/=*$//;

            # Display menu item
            $self->lmLog( "Display menu item for category $catid", 'debug' );

            # Here, "notranslate" is set to true : hashvalues must not be
            # translated
            $res .= $self->li($id)
              . $self->span(
                id   => $id,
                text => "$catid",
                data => $h->{$catid}->{catname},
                js   => $js,
                help => $help,
                noT  => 1
              );

            delete $h->{$catid}->{type};
            delete $h->{$catid}->{catname};

            # Loop on applications

            if ( %{ $h->{$catid} } ) {
                $res .= '<ul>';
            }

            foreach my $appid ( sort keys %{ $h->{$catid} } ) {

                $id = "$target/$catid/$appid";
                $id =~ s/=*$//;

                my $data =
                    $h->{$catid}->{$appid}->{options}->{name} . "|"
                  . $h->{$catid}->{$appid}->{options}->{uri} . "|"
                  . $h->{$catid}->{$appid}->{options}->{description} . "|"
                  . $h->{$catid}->{$appid}->{options}->{logo} . "|"
                  . $h->{$catid}->{$appid}->{options}->{display};

                # Display menu item
                $self->lmLog( "Display menu item for application $appid",
                    'debug' );

                $res .= $self->li($id)
                  . $self->span(
                    id   => $id,
                    text => "$appid",
                    data => $data,
                    js   => "applicationListApplication",
                    help => $help,
                    noT  => 1
                  ) . "</li>";

            }

            if ( %{ $h->{$catid} } ) {
                $res .= '</ul>';
            }

            $res .= "</li>";
        }
    }

    # POST
    elsif ( $target =~ s/^post:// ) {
        $self->lmLog( "Load POST data (target $target)", 'debug' );

        my $h = $self->keyToH( $target, $self->conf );

        # Try to get value from defaultConf
        unless ($h) {
            unless ( $h = $self->subDefaultConf()->{post} ) {
                $self->lmLog( "Try to get default conf for post", 'debug' );
                $self->lmLog( "$target hash is not defined in configuration",
                    'error' );
                return;
            }
        }

        # Loop on POST URI
        foreach my $posturi ( sort keys %$h ) {

            # Build ID
            my $id = "$target/$posturi";
            $id =~ s/=*$//;

            # Display menu item
            $self->lmLog( "Display menu item for POST URI $posturi", 'debug' );

            # Here, "notranslate" is set to true : hashvalues must not be
            # translated
            $res .= $self->li($id)
              . $self->span(
                id   => $id,
                text => "$posturi",
                data => $h->{$posturi}->{postUrl},
                js   => $js,
                help => $help,
                noT  => 1
              );

            # Loop on post data (expr)

            if ( %{ $h->{$posturi}->{expr} } ) {
                $res .= '<ul>';
            }

            foreach my $postdata ( sort keys %{ $h->{$posturi}->{expr} } ) {

                $id = "$target/$posturi/$postdata";
                $id =~ s/=*$//;

                # Display menu item
                $self->lmLog( "Display menu item for POST data $postdata",
                    'debug' );

                $res .= $self->li($id)
                  . $self->span(
                    id   => $id,
                    text => "$postdata",
                    name => "postdata:$postdata",
                    data => $h->{$posturi}->{expr}->{$postdata},
                    js   => "postData",
                    help => $help,
                    noT  => 1
                  ) . "</li>";

            }

            if ( %{ $h->{$posturi}->{expr} } ) {
                $res .= '</ul>';
            }

            $res .= "</li>";
        }

    }

    else {
        $target =~ s/^(\w+)://;
        my $type = $1 || 'text';
        $js ||= $type;
        my $text = $target;
        $text =~ s/^.*\///;
        my $h = $self->keyToH( $target, $self->conf );

        # Try to get value from defaultConf
        $h = $self->keyToH( $target, $self->defaultConf ) unless ( defined $h );

        # If no value found, try to remove 2 first target components
        # to manage complex hash like samlIDPMetaDataOptions
        unless ( defined $h ) {
            $target =~ /([^\/]*)$/;
            $h = $self->keyToH( $1, $self->defaultConf );
        }

        # If still no value, set a default value depending on type
        unless ( defined $h ) {
            $self->lmLog( "$target has no default value", "debug" );
            $h = {
                text     => '',
                hash     => {},
                'int'    => 0,
                textarea => '',
                bool     => 0,
                trool    => -1,
                filearea => '',
                select   => '',
            }->{$type};
            $self->lmLog( "Type $type unknown", 'warn' ) unless ( defined $h );
        }
        if ( ref($h) ) {
            $res .= $self->li( "$target", "closed" )
              . $self->span(
                id   => "$target",
                text => $text,
                data => '',
                js   => $js,
                help => $help
              ) . "<ul>";
            foreach ( sort keys %$h ) {
                if ( ref( $h->{$_} ) ) {
                    $res .=
                      $self->confNode( '', "btext:$target/$_", $help, $js );
                }
                else {
                    my $id = "$target/$_";
                    $res .= $self->li($id)
                      . $self->span(
                        id   => $id,
                        text => $_,
                        data => $h->{$_},
                        js   => $js,
                        help => $help
                      ) . "</li>";
                }
            }
            $res .= '</ul></li>';
        }
        else {
            my $id = "$target";
            $res .= $self->li($id)
              . $self->span(
                id   => $id,
                text => $text,
                data => $h,
                js   => $js,
                help => $help
              ) . "</li>";
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

    $self->lmLog( "Look for key $key in configuration", 'debug' );

    my $h = $self->struct();

    # No key, return complete struct
    return $h unless ($key);

    # Key as URL parameter, call cstruct
    if ( my $k2 = $self->param('key') ) {
        $h = $self->cstruct( $h, $key );
    }

    my @tmp1 = split /\//, $key;
    my $help;
    my $js;

    # Browse key components
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
            $self->lmLog( "Key $_ does not exist in manager tree", 'debug' );
            return "$h/" . join( '/', $_, @tmp1 );
        }
    }
    if ( ref($h) ) {
        $help = $h->{_help} if ( $h->{_help} );
        $js   = $h->{_js}   if ( $h->{_js} );
    }
    return $h, $help, $js;
}

## @method protected void sendCfgParams(hashref h)
# Send Author, IP, and date from a Lemonldap::NG::Conf
sub sendCfgParams {
    my ( $self, $h ) = @_;
    my @buf;
    foreach (qw(cfgAuthor cfgAuthorIP cfgDate)) {
        my $tmp = $h->{$_} || 'anonymous';
        $tmp =~ s/'/\\'/g;
        push @buf, "\"$_\":\"$tmp\"";
    }
    $_ = '{' . join( ',', @buf ) . '}';
    print $self->header(
        -type           => 'application/json',
        -Content_Length => length($_)
    ) . $_;
    $self->quit();
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
    my ( $self, %args ) = @_;
    $args{param} .= "&amp;cfgNum=$self->{cfgNum}";
    return $self->li( $args{id} ) . $self->span(%args)

      # . $self->span( $id, $text, $data, $js, $help, $noT )
      . "<ul class=\"ajax\">"
      . $self->li("sub_$args{id}")
      . ".{url:$ENV{SCRIPT_NAME}?$args{param}"

      . ( $args{deferedJs} ? ",js:$args{deferedJs}" : '' )
      . ( $args{call}      ? ",call:$args{call}"    : '' )
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
    my ( $self, %args ) = @_;

    # Data
    $args{data} = '' unless ( defined $args{data} );
    $args{data} = uri_escape( $args{data} );
    $args{data} =~ s/"/%22/g;

    # ID
    $args{id} = "li_" . encode_base64( $args{id}, '' );
    $args{id} =~ s/(=*)$/length($1)/e;

    # Javascript
    $args{js} ||= "none";
    $args{js} .= "('$args{id}')" unless ( $args{js} =~ /\(/ );

    # Text
    $args{name} ||= $args{text};
    my $tmp = $args{name};
    $tmp =~ s/"/&#39;/g;
    $args{text} = join ' ', map { $self->translate($_) } split /\s+/,
      $args{text}
      unless ( $args{noT} );
    $args{text} = $self->escapeHTML( $args{text} );

    # Return HTML code
    return
"<span name=\"$tmp\" id=\"text_$args{id}\" onclick=\"$args{js}\" help=\"$args{help}\" value=\"$args{data}\">$args{text}</span>
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
