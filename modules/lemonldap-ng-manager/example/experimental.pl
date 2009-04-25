#!/usr/bin/perl

#use Lemonldap::NG::Manager;

my $h = new Lemonldap::NG::Manager::Experimental(
    {
        jqueryUri     => '/javascript/jquery/jquery.js',
        imagePath     => '/images/',
        applyConfFile => '/etc/lemonldap-ng//apply.conf',
        cssFile       => 'theme/default.css',
        textareaW     => 50,
        textareaH     => 2,
        inputSize     => 30,

        # OPTIONAL PARAMETERS
        #jsFile => /path/to/lemonldap-ng-manager.js,

        # ACCESS TO CONFIGURATION

        # By default, Lemonldap::NG uses the default storage.conf file to know
        # where to find is configuration
        # (generaly /etc/lemonldap-ng/storage.conf)
        # You can specify by yourself this file :
        #configStorage => { Type => 'File', dirName => '/path/to/my/file' },

        # You can also specify directly the configuration
        # (see Lemonldap::NG::Handler::SharedConf(3))
        #configStorage => {
        #      type => 'File',
        #      directory => '/usr/local/lemonlda-ng/conf/'
        #},

        # CUSTOM FUNCTION
        # If you want to create customFunctions in rules, declare them here:
        #customFunctions    => 'function1 function2',
        #customFunctions    => 'Package::func1 Package::func2',
    }
) or die "Unable to start";

$h->doall();

package Lemonldap::NG::Manager::Experimental;

use strict;
use MIME::Base64;
use Lemonldap::NG::Handler::CGI qw(:globalStorage :locationRules);
use Lemonldap::NG::Common::Conf::Constants;    #inherits
use Lemonldap::NG::Common::Safelib;            #link protected safe Safe object
#require Lemonldap::NG::Manager::_Struct; #inherits
require Lemonldap::NG::Manager::Help;      #inherits

our $VERSION = '0.1';
our ( $stylesheet, $parser );
our @ISA;

BEGIN {
#    *struct      = \&Lemonldap::NG::Manager::_Struct::struct;
#    *cstruct     = \&Lemonldap::NG::Manager::_Struct::cstruct;
#    *defaultConf = \&Lemonldap::NG::Manager::_Struct::defaultConf;
    *process     = *doall;
    @ISA=qw(Lemonldap::NG::Handler::CGI Lemonldap::NG::Manager::_Struct Lemonldap::NG::Manager::Uploader);
}

sub new {
    my ( $class, $args ) = @_;
    my $self = $class->SUPER::new($args)
      or $class->abort( 'Unable to start ' . __PACKAGE__,
        'See Apache logs for more' );
    $self->{imagePath} ||= 'images/';
    return $self;
}

sub doall {
    my $self = shift;
    if ( $ENV{PATH_INFO} eq "/css" ) {
        print $self->header_public( $ENV{SCRIPT_FILENAME}, -type => 'text/css',
        );
        $self->css;
        $self->quit();
    }
    elsif ( $ENV{PATH_INFO} eq "/js" ) {
        print $self->header_public( $ENV{SCRIPT_FILENAME},
            -type => 'text/javascript', );
        $self->js;
        $self->quit();
    }
    elsif ( $self->param('help') ) {
        print $self->header_public( $ENV{SCRIPT_FILENAME},
            -type => 'text/html; charset=utf8' );
        Lemonldap::NG::Manager::Help::import( $self->{language}
              || $ENV{HTTP_ACCEPT_LANGUAGE} )
          unless ( $self->can('help_groups') );
        my $chap = $self->param('help');
        eval { no strict "refs"; &{"help_$chap"} };
        $self->quit();
    }
    elsif ( my $rdata = $self->rparam('data') ) {
        #require Lemonldap::NG::Manager::Uploader; #inherits
        $self->confUpload($rdata);
        $self->quit();
    }
    $self->{cfgNum} =
         $self->param('cfgNum')
      || $self->confObj->lastCfg()
      || 'UNAVAILABLE';
    if ( my $p = $self->param('node') ) {
        $self->node($p);
    }
    else {
        $self->start();
        $self->window( "Configuration $self->{cfgNum}", $self->{cfgNum} );
        $self->node();
        $self->end();
    }
}

use Data::Dumper;

sub node {
    my ( $self, $node ) = @_;
    $node =~ s/^\///;

    #$self->lmLog( "Processing to node: $node", 'debug' );
    if ( my ( $tmp, $help, $js ) = $self->corresp($node) ) {

        # Menu node
        if ( ref($tmp) ) {

            # Scan subnodes
            foreach ( @{ $tmp->{_nodes} } ) {
                my $flag = ( $_ =~ s/^(\w+):// ? $1 : '' );
                my ( $target, $_h, $_j ) = split /:\s*/;
                $help ||= $_h;

                # subnode is an ajax subnode
                if ( $flag eq 'n' ) {
                    $self->ajaxNode(
                        "$node/$target",
                        "$target",
                        "node=$node/$target",
                        $tmp->{$target}->{_help} || $help,
                        $tmp->{$target}->{_js}
                    );
                }

                # subnode is a node
                elsif ( ref( $tmp->{$target} ) ) {
                    print $self->li( "$node/$target", "closed" )
                      . $self->span(
                        "$node/$target", $target, '',
                        $tmp->{$target}->{_js},
                        $tmp->{$target}->{_help} || $help
                      ) . "<ul>";
                    $self->node("$node/$target");
                    print "</ul></li>";
                }

                # subnode points to a configuration node
                elsif ( $flag =~ /^n?hash$/ ) {
                    $self->confNode( $node, "$flag:$target", $help, $_j );
                }

                else {
                    $self->node("$node/$target");
                }
            }
        }

        # node points to a configuration point
        else {
            $self->confNode( $node, $tmp, $help, $js );
        }
    }
    else {
        $self->lmLog( "$node was not found in tree\n", 'error' );
    }
}

sub confNode {
    my ( $self, $node, $target, $help, $js ) = @_;
    $self->lmLog( "Processing to configuration node: $target", 'debug' );
    $target =~ s/^\///;
    my ( $t1, $t2 ) = ( '', '' );
    if ( $target =~ /^(.+?):(?!\/)(.+?):(?!\/)(.+?)$/ ) {
        ( $target, $help, $js ) = ( $1, $2, $3 );
    }
    ( $target, $t1, $t2 ) = split /:(?!\/)/, $target
      if ( $target =~ /:(?!\/)/ );
    $help ||= $t1;
    $js   ||= $t2;
    if ( $target =~ s/^nhash:// ) {
        my $h = keyToH( $target, $self->conf );
        return unless ($h);
        foreach ( sort keys %$h ) {
            if ( ref($h) ) {
                $self->ajaxNode( "$target/$_", $_, "node=$node/$_\&amp;key=$_",
                    $help, $js );
            }
            else {
                $self->confNode( '', "btext:$target/$_", $help, $js );
            }
        }
    }
    elsif ( $target =~ s/^hash:// ) {
        my $h = keyToH( $target, $self->conf );
        return unless ($h);
        foreach ( sort keys %$h ) {
            if ( ref( $h->{$_} ) ) {
                $self->confNode( "$target/$_", $help, $js );
            }
            else {
                $js ||= 'btext';
                my $id = "$target/$_";
                $id =~ s/=*$//;
                print $self->li($id)
                  . $self->span( $id, "$_", $h->{$_}, $js, $help ) . "</li>";
            }
        }
    }
    else {
        $target =~ s/^(\w+)://;
        my $type = $1 || 'text';
        $js ||= $type;
        my $text = $target;
        $text =~ s/^.*\///;
        my $h = keyToH( $target, $self->conf );

        $h = keyToH( $target, $self->defaultConf ) unless ( defined $h );
        unless ( defined $h ) {
            $self->lmLog( "$target does not exists in configuration hash",
                "warn" );
            return;
        }
        if ( ref($h) ) {
            print $self->li( "$target", "closed" )
              . $self->span( "$target", $text, '', $js, $help ) . "<ul>";
            foreach ( sort keys %$h ) {
                if ( ref( $h->{$_} ) ) {
                    $self->confNode( '', "btext:$target/$_", $help, $js );
                }
                else {
                    my $id = "$target/$_";
                    print $self->li($id)
                      . $self->span( $id, $_, $h->{$_}, $js, $help ) . "</li>";
                }
            }
            print '</ul></li>';
        }
        else {
            my $id = "$target";
            print $self->li($id)
              . $self->span( $id, $text, $h, $js, $help ) . "</li>";
        }
    }
}

sub keyToH {
    my ( $key, $h ) = @_;
    $key =~ s/^\///;
    foreach ( split /\//, $key ) {
        return undef unless ( defined( $h->{$_} ) );
        $h = $h->{$_};
    }
    return $h;
}

sub corresp {
    my $self = shift;
    my $key  = shift;
    my $h    = $self->struct();
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
            $self->lmLog("Key $key does not exist in configuration hash",'error');
            return undef;
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

sub conf {
    my $self = shift;
    return $self->{_conf} if ( $self->{_conf} );
    my $args = { cfgNum => $self->{cfgNum} };
    $args->{noCache} = 1 if ( $self->param('cfgNum') );
    $self->{_conf} = $self->confObj->getConf($args);
    $self->abort( 'Unable to get configuration',
        $Lemonldap::NG::Common::Conf::msg )
      unless ( $self->{_conf} );
    return $self->{_conf};
}

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

## @method protected void ajaxnode(string id, string text, string param)
# Display tree node with Ajax functions inside for opening the node.
# @param $id HTML id of the element.
# @param $text text to display
# @param $param Parameters for the Ajax query
sub ajaxNode {
    my ( $self, $id, $text, $param, $help, $js, $data ) = @_;
    $param .= "&amp;cfgNum=$self->{cfgNum}";
    print $self->li($id)
      . $self->span( $id, $text, $data, $js, $help )
      . "<ul class=\"ajax\">"
      . $self->li("sub_$id")
      . ".{url:$ENV{SCRIPT_NAME}?$param}</li></ul></li>\n";
}

sub span {
    my ( $self, $id, $text, $data, $js, $help ) = @_;
    my $tmp = $text;
    $data = '' unless ( defined $data );
    $js ||= "none";
    $id = "li_" . encode_base64( $id, '' );
    $id   =~ s/(=*)$/length($1)/e;
    $data =~ s/"/&#39;/g;
    $tmp  =~ s/"/&#39;/g;
    $text = $self->escapeHTML($text);
    return
"<span name=\"$tmp\" id=\"text_$id\" onclick=\"$js('$id')\" help=\"$help\" value=\"$data\">$text</span>
";
}

sub li {
    my ( $self, $id, $class ) = @_;
    $id = "li_" . encode_base64( $id, '' );
    $id =~ s/(=*)$/length($1)/e;
    return "<li id=\"$id\"" . ( $class ? " class=\"$class\">" : ">" );
}

## @method protected void start()
# Display HTTP and HTML headers.
sub start {
    my $self = shift;
    print $self->header( -type => 'text/html; charset=utf8', );
    print $self->start_html(
        -title => shift || 'Lemonldap::NG Manager',
        -encoding => 'utf8',
        -script   => [
            {
                -language => 'JavaScript1.2',
                -src      => "$self->{imagePath}/xlib.js",
            },
            {
                -language => 'JavaScript1.2',
                -src      => $self->{jqueryUri} || 'jquery.js',
            },
            {
                -language => 'JavaScript1.2',
                -src      => "$self->{imagePath}/tree.js",
            },
            {
                -language => 'JavaScript1.2',
                -code     => "var scriptname='$ENV{SCRIPT_NAME}';"
                  . "var imagepath='$self->{imagePath}';",
            },
            {
                -language => 'JavaScript1.2',
                -src      => "$self->{imagePath}/manager.js",
            },
        ],
        -style => {
            -src => [
                "$self->{imagePath}/manager.css",
                ( $self->{personnalCss} ? $self->{personnalCss} : () )
            ],
        },
    );
}

sub window {
    my ( $self, $root, $data ) = @_;
    print '<div class="clsTemporaryContainer">
 <div style="visibility: visible;" id="idSplitter3" class="clsSplitter">
  <div style="z-index: 2;" id="gauche" class="clsPane">
   <img style="padding:4px;padding-left:12px;" alt="Lemonldap::NG" src="'
      . $self->{imagePath}
      . '/logo_lemonldap-ng.png"/><br/>&nbsp;<ul class="simpleTree">'
      . $self->li( 'root', 'root' )
      . $self->span( 'root', $root, $data, '', 'default' ) . '<ul>';
}

## @method protected void end()
# Display the end of HTML page.
sub end {
    my $self = shift;
    print << 'EOF';
</ul></li></ul></div><!-- end Pane -->
<div style="overflow: hidden; z-index: 2;" id="droit" class="clsPane">
 <div style="visibility: visible;" id="idSplitter32" class="clsSplitter">
  <div style="z-index: 2;overflow:auto;height:500px;" id="haut" class="clsPane">
   <form action="#" onsubmit="false">
   <h2 id="content_title">Lemonldap::NG Manager</h2>
   <div id="buttons"></div>
    <button onclick="$.post('/test.pl',{data: $('#li_cm9vdA2').html()},function(data){return 1},'html');" >Sauvegarder</button>
   <div id="content">
    <div id="content_default" class="content">
    Default
    </div>
    <div id="content_text" class="hidden">
    <input type="text" id="text" onchange="setlmdata(currentId,this.value)"/>
    </div>
    <div id="content_securedCookie" class="hidden">
    <input id="securedCookie0" type="radio" name="securedCookie" value="0" onclick="setlmdata('li_bGlfL3NlY3VyZWRDb29raWU1','0')" /> Cookie non sécurisé <br/>
    <input id="securedCookie1" type="radio" name="securedCookie" value="1" onclick="setlmdata('li_bGlfL3NlY3VyZWRDb29raWU1','1')" /> Cookie sécurisé <br/>
    <input id="securedCookie2" type="radio" name="securedCookie" value="2" onclick="setlmdata('li_bGlfL3NlY3VyZWRDb29raWU1','2')" /> 2 cookies <br/>
    </div>
    <div id="content_int" class="hidden">
    <input type="text" id="int" onchange="setlmdata(currentId,this.value)"/>
    </div>
    <div id="content_btext" class="hidden">
    <input type="text" id="btextKey" onchange="setlmtext(currentId,this.value)"/> <input type="text" id="btextValue" onchange="setlmdata(currentId,this.value)"/>
    </div>
    <div id="content_rules" class="hidden">
    <textarea id="rulKey" cols="30" rows="2" onchange="setlmtext(currentId,this.value)"></textarea>&nbsp;<textarea id="rulValue" cols="50" rows="2" onchange="setlmdata(currentId,this.value)"></textarea>
    </div>
   </div></form>
  </div><!-- end Pane -->
  <div style="z-index: 2;" id="bas" class="clsPane">
   <div id="help">
   </div>
  </div><!-- end Pane -->
  <div style="z-index: 1; cursor: n-resize;" id="barre2" class="clsDragBar clsDragBar-hframe">
   &nbsp;
  </div>
 </div><!-- end Splitter -->
</div><!-- end Pane -->
<div style="z-index: 1; cursor: n-resize;" id="barre3" class="clsDragBar clsDragBar-vframe">
</div>
</div><!-- end Splitter -->
</div><!-- end TemporaryContainer -->
EOF
    print $self->end_html();
}

1;

package Lemonldap::NG::Manager::_Struct;

use strict;
our $VERSION='0.1';

sub cstruct {
    shift;
    my ( $h, $k ) = @_;
    %$h = (
        %$h,
        virtualHosts => {
            $k => {
                _nodes => [qw(rules:rules:rules headers)],
                rules  => { _nodes => ["hash:/locationRules/$k:rules:rules"], },
                headers => { _nodes => ["hash:/exportedHeaders/$k"], },
            }
        }
    );
    return $h;
}

sub struct {
    return {
        _nodes            => [qw(n:generalParameters n:groups n:virtualHosts)],
        _help             => 'default',
        generalParameters => {
            _nodes => [
                qw(n:authParams cookieParams n:exportedVars n:macros sessionParams ldapParams)
            ],
            _help      => 'default',
            authParams => {
                _nodes => [qw(portal authentication userDB whatToTrace)],
                _help  => 'authParams',
                authentication => 'text:/authentication',
                portal         => 'text:/portal',
                userDB         => 'text:/userDB',
                whatToTrace    => 'text:/whatToTrace:whatToTrace:text',
            },
            cookieParams => {
                _nodes     => [qw(cookieName domain securedCookie)],
                cookieName => 'text:/cookieName:cookieName:text',
                domain     => 'text:/domain:domain:text',
                securedCookie =>
                  'int:/securedCookie:securedCookie:securedCookieValues',
            },
            exportedVars  => { _nodes => ['hash:/exportedVars:vars:btext'], },
            macros        => { _nodes => ['hash:/macros:macros:btext'], },
            sessionParams => {
                _nodes         => [qw(sessionStorage timeout)],
                _help          => 'storage',
                sessionStorage => {
                    _nodes        => [qw(globalStorage globalStorageOptions)],
                    globalStorage => 'text:/globalStorage',
                    globalStorageOptions =>
                      { _nodes => ['hash:/globalStorageOptions'], },
                },
                timeout => 'text:/timeout:timeout:text',
            },
            ldapParams => {
                _nodes =>
                  [qw(ldapServer ldapPort ldapBase managerDn managerPassword)],
                _help           => 'ldap',
                ldapServer      => 'text:/ldapServer',
                ldapPort        => 'int:/ldapPort',
                ldapBase        => 'text:/ldapBase',
                managerDn       => 'text:/managerDn',
                managerPassword => 'text:/managerPassword',
            },
        },
        groups => { _nodes => ['hash:/groups:groups:none'], },
        virtualHosts =>
          { _nodes => ['nhash:/locationRules:virtualHosts:none'], },
    };
}

sub defaultConf {
    return { userDB => 'LDAP', };
}

1;
package Lemonldap::NG::Manager::Uploader;

use strict;
use XML::LibXML;
use XML::LibXSLT;
use MIME::Base64;

our $VERSION='0.1';

sub confUpload {
    my($self,$rdata)=@_;
        $$rdata =~ s/<img.*?>//g;
        $$rdata =~ s/<li class="line".*?<\/li>//g;
        my $xml    = $self->parser->parse_string('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
                 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<root>' . $$rdata . '</root>');

        my $result = $self->stylesheet->transform($xml)->documentElement();
        open LOG, ">/tmp/log2";
        print LOG $self->stylesheet->transform($xml)->toString();
        foreach ( @{ $result->getChildrenByTagName('ignore') } ) {
            my $node = $_->getAttribute('value');
            $node =~ s/^.*node=(.*?)(?:&.*)?\}$/$1/;
            print LOG "Ignore $node\n";
        }
        foreach ( @{ $result->getChildrenByTagName('element') } ) {
            my ( $id, $name, $value ) = (
                $_->getAttribute('id'),
                $_->getAttribute('name'),
                $_->getAttribute('value')
            );
            $id =~ s/^text_li_(\w+)(\d)$/decode_base64($1.'='x $2)/e;
            $id =~ s/^\///;
            my $tmp;
            #$tmp = $self->corresp($id);
            print LOG "$id ; $name \"$value\"\n";
        }
        close LOG;
        $self->start();
        $self->end();
}

sub parser {
    my $self = shift;
    return $parser if ($parser);
    $parser = XML::LibXML->new();
}

sub stylesheet {
    my $self = shift;

    #return $stylesheet if($stylesheet);
    my $xslt      = XML::LibXSLT->new();
    my $style_doc = $self->parser->parse_string(
        q#<?xml version="1.0" encoding="UTF-8"?>
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
  <element>
   <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
   <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
   <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
  </element>
  <!--xsl:copy-of select="."/>
  <element>
   <name><xsl:value-of select="@name"/></name>
   <id><xsl:value-of select="@id"/></id>
   <value><xsl:value-of select="@id"/></value>
  </element-->
 </xsl:template>
</xsl:stylesheet>
#
    );
    $stylesheet = $xslt->parse_stylesheet($style_doc);
}

1;
