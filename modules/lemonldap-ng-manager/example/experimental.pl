#!/usr/bin/perl

#use Lemonldap::NG::Manager::Experimental;

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

BEGIN {
    require Lemonldap::NG::Manager::Help;      #inherits
}
use base qw(Lemonldap::NG::Handler::CGI);

our $VERSION = '0.1';

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
        exit;
    }
    elsif ( $ENV{PATH_INFO} eq "/js" ) {
        print $self->header_public( $ENV{SCRIPT_FILENAME},
            -type => 'text/javascript', );
        $self->js;
        exit;
    }
    elsif ( $self->param('help') ) {
        print $self->header_public( $ENV{SCRIPT_FILENAME},
            -type => 'text/html; charset=utf8' );
        Lemonldap::NG::Manager::Help::import( $self->{language}
              || $ENV{HTTP_ACCEPT_LANGUAGE} )
          unless ( $self->can('help_groups') );
        my $chap = $self->param('help');
        eval { no strict "refs"; &{"help_$chap"} };
        exit;
    }

    #elsif ( $ENV{PATH_INFO} eq "/manager.js" ) {
    #    #print $self->header_public( $ENV{SCRIPT_FILENAME},
    #    #    -type => 'text/javascript', );
    #    print $self->header('text/javascript');
    #    $self->mnjs;
    #    exit;
    #}
    $self->{cfgNum} =
         $self->param('cfgNum')
      || Lemonldap::NG::Common::Conf->new()->lastCfg()
      || 'UNAVAILABLE';
    if ( my $p = $self->param('node') ) {
        $self->node($p);
    }
    else {
        $self->start();
        $self->window("Configuration $self->{cfgNum}");
        $self->node();
        $self->end();
    }
}

sub conf {
    my ($self) = @_;
    return $self->{_conf} if ( $self->{_conf} );
    my $args = { cfgNum => $self->{cfgNum} };
    $args->{noCache} = 1 if ( $self->param('cfgNum') );
    $self->{_conf} = Lemonldap::NG::Common::Conf->new()->getConf($args);
    $self->abort('Unable to get configuration') unless ( $self->{_conf} );
    return $self->{_conf};
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
                        "li_$node/$target",
                        "$target",
                        "node=$node/$target",
                        $tmp->{$target}->{_help} || $help,
                        $tmp->{$target}->{_js}
                    );
                }

                # subnode is a node
                elsif ( ref( $tmp->{$target} ) ) {
                    print STDERR "DEBUG: $target, H:$tmp->{$target}->{_help}\n";
                    print $self->li( "li_$node/$target", "closed" )
                      . $self->span(
                        "li_$node/$target", $target, '',
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
                $self->ajaxNode( "li_$target/$_", $_,
                    "node=$node/$_\&amp;key=$_", $help, $js );
            }
            else {
                $self->confNode( '', "btext:li_$target/$_", $help, $js );
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
                my $id = "li_" . encode_base64( "$target/$_", '' );
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

        #$h = keyToH( $target, $self->defaultConf ) unless ( defined $h );
        unless ( defined $h ) {
            $self->lmLog( "$target does not exists in configuration hash",
                "warn" );
            return;
        }
        if ( ref($h) ) {
            print $self->li( "li_$target", "closed" )
              . $self->span( "$target", $text, '', $js, $help ) . "<ul>";
            foreach ( sort keys %$h ) {
                if ( ref( $h->{$_} ) ) {
                    $self->confNode( '', "btext:$target/$_", $help, $js );
                }
                else {
                    my $id = "li_" . encode_base64( "$target/$_", '' );
                    $id =~ s/=*$//;
                    print $self->li($id)
                      . $self->span( $id, $_, $h->{$_}, $js, $help ) . "</li>";
                }
            }
            print '</ul></li>';
        }
        else {
            my $id = "li_" . encode_base64( $target, '' );
            $id =~ s/=*$//;
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
            $self->lmLog( "Key $key does not exists", "warn" );
            exit;
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

sub window {
    my $self = shift;
    my $root = shift;
    print
#'<table border="0" width="100%"><tr><td width="300px" valign="top"><div style="overflow:auto;height:500px;">
'<!--<div id="xBody">-->
  <div class="clsTemporaryContainer">
      <div style="visibility: visible;" id="idSplitter3" class="clsSplitter">
        <div style="z-index: 2;" id="gauche" class="clsPane">
    <center><img src="'.$self->{imagePath}.'/logo_lemonldap-ng.png"><br/>&nbsp;</center>
    <ul class="simpleTree"><li class="root" id="root"><span>' . $root
      . '</span><ul>';
}

## @method protected void start()
# Display HTTP and HTML headers.
sub start {
    my $self = shift;
    print $self->header( -type => 'text/html; charset=utf8', );
    print $self->start_html(
        -title => shift || 'Sessions Lemonldap::NG',
        -encoding => 'utf8',
        -script   => [
            {
                -language => 'JavaScript1.2',
                -src      => $self->{Xlib} || 'xlib.js',
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
                ."var imagepath='$self->{imagePath}';",
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
    $data = '' unless ( defined $data );
    $js ||= "none";
    $id   =~ s#/#_#g;
    $data =~ s/"/&#39;/g;
    return
"<span id=\"text_$id\" onclick=\"$js('$id')\" help=\"$help\" value=\"$data\">$text</span>
";
}

sub li {
    my ( $self, $id, $class ) = @_;
    $id =~ s#/#_#g;
    return "<li id=\"$id\"" . ( $class ? " class=\"$class\">" : ">" );
}

## @method protected void end()
# Display the end of HTML page.
sub end {
    my $self = shift;
    print
q{</ul></li></ul></div><!-- end Pane -->
<!--</td><td valign="top">-->

<div style="overflow: hidden; z-index: 2;" id="droit" class="clsPane">
 <div style="visibility: visible;" id="idSplitter32" class="clsSplitter">
  <div style="z-index: 2;" id="haut" class="clsPane" style="overflow:auto;height:500px;">
   <form action="#" onsubmit="false">
   <h2 id="content_title">Lemonldap::NG Manager</h2>
   <div id="buttons"></div>
   <div id="content">
    <div id="content_default" class="content">
    Default
    </div>
    <div id="content_text" class="hidden">
    <input type="text" id="text"/>
    </div>
    <div id="content_securedCookie" class="hidden">
    <input id="securedCookie0" type="radio" name="securedCookie" value="0" onclick="setlmdata('li__securedCookie','0')" /> Cookie non sécurisé <br>
    <input id="securedCookie1" type="radio" name="securedCookie" value="1" onclick="setlmdata('li__securedCookie','1')" /> Cookie sécurisé <br>
    <input id="securedCookie2" type="radio" name="securedCookie" value="2" onclick="setlmdata('li__securedCookie','2')" /> 2 cookies <br>
    </div>
    <div id="content_int" class="hidden">
    <input type="int" id="int"/>
    </div>
    <div id="content_btext" class="hidden">
    <input type="text" id="btextKey"/> <input type="text" id="btextValue"/>
    </div>
    <div id="content_rules" class="hidden">
    rules
    </div>
   </div></form>
  </div><!-- end Pane -->
  <div style="z-index: 2;" id="bas" class="clsPane">
   <div id="help">
   </div>
  </div><!-- end Pane -->
  <div style="z-index: 1; cursor: n-resize;" id="barre2" class="clsDragBar">
   &nbsp;
  </div>
 </div><!-- end Splitter -->
</div><!-- end Pane -->
<div style="z-index: 1; cursor: n-resize;" id="barre2" class="clsDragBar">
</div>
</div><!-- end Splitter -->
</div><!-- end TemporaryContainer -->
<!--</td></tr></table>-->
</div>};
    print $self->end_html();
}

1;

sub mnjs {
    my $self = shift;
    print <<'EOF';
$(document).ready(function(){
var simpleTreeCollection
simpleTreeCollection = $(".simpleTree").simpleTree({
    autoclose: false,
    drag: false,
    afterClick:function(node){
        var span=$('span:first',node);
        $('#help').load(scriptname+'?help='+span.attr('help'));
    },
    afterDblClick:function(node){
    //alert("text-"+$("span:first",node).text());
    },
    afterMove:function(destination, source, pos){
    //alert("destination-"+$("span:first",destination).text()+" source-"+$("span:first",source).text()+" pos-"+pos);
    },
    afterAjax:function() {
    //alert("Loaded");
    },
    animate:true
    //,docToFolderConvert:true
    });
  var w=X.clientWidth()-12;
  var h=X.clientHeight()-12;
  //var h=window.outerHeight;
  s32=new xSplitter('idSplitter32',0,0,0,0,false,4,h/2,h/8,true,0);
  s3=new xSplitter('idSplitter3',0,0,w,h,true,4,w/4,w/8,true,4,null,s32);
  X.addEventListener(window,'resize',win_onresize,false);
}
);
function win_onresize(){
  var cw=X.clientWidth();
  var w=X.clientWidth()-12;
  var h=X.clientHeight()-12;
  s3.paint(w,h,w/4,w/5);
}
function lmtext(id){
  return $('#text_'+id).html();
}
function lmdata(id){
  //alert( $('#text_'+id).attr('value'));
  return $('#text_'+id).attr('value');
}
function setlmtext(id,v){
  $('#text_'+id).html(v);
}
function setlmdata(id,v){
  $('#text_'+id).attr('value',v);
}
function display(div,title) {
  var divs=$('#content').children();
  divs.toggleClass('hidden',true);
  divs.removeClass('content');
  $('#content_'+div).removeClass('hidden');
  $('#content_'+div).addClass('content');
  $('#content_title').html(title);
}
function none(id) {
  display('default','Lemonldap::NG Manager');
}
function btext(id) {
  $('#btextKey').attr('value',lmtext(id));
  $('#btextKey').change(function(){setlmtext(id,this.value)});
  $('#btextValue').attr('value',lmdata(id));
  $('#btextValue').change(function(){setlmdata(id,this.value)});
  display('btext','Clef');
}
function int(id) {
  $('#int').attr('value',lmdata(id));
  $('#int').change(function(){setlmdata(id,this.value)});
  display('int',lmtext(id));
}
function text(id) {
  $('#text').attr('value',lmdata(id));
  $('#text').change(function(){setlmdata(id,this.value)});
  display('text',lmtext(id));
}
function securedCookieValues(id){
  var v;
  v=lmdata(id);
  $('#securedCookie'+v).attr('checked',1);
  display('securedCookie',lmtext(id));
}
function rules(id){
  //display('btext',$('#'+id).parent().parent);
}
EOF
}

1;
