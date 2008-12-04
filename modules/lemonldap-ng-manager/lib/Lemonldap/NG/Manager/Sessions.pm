package Lemonldap::NG::Manager::Sessions;

use strict;
use Lemonldap::NG::Handler::CGI qw(:globalStorage :locationRules);
use Lemonldap::NG::Common::Apache::Session;

our $VERSION = '0.1';

use base qw(Lemonldap::NG::Handler::CGI);

# Cleaner for Lemonldap::NG : removes old sessions from Apache::Session
#
# This module is written to be used by cron to clean old sessions from
# Apache::Session.

sub new {
    my ( $class, $args ) = @_;
    my $self = $class->SUPER::new($args)
      or $class->abort( 'Unable to start ' . __PACKAGE__,
        'See Apache logs for more' );
    foreach (qw(jqueryUri personnalCss imagePath)) {
        $self->{$_} = $args->{ $_
          }; # or print STDERR "Warning, $_ is not set, falling to default value\n";
    }
    eval "use $globalStorage";
    $class->abort( "Unable to load $globalStorage", $@ ) if ($@);
    return $self;
}

sub process {
    my $self = shift;

    if ( $ENV{PATH_INFO} eq "/css" ) {
        print $self->header(
            '-Cache-Control' => 'public',
            -type            => 'text/css',
        );
        $self->css;
        exit;
    }
    elsif ( $ENV{PATH_INFO} eq "/js" ) {
        print $self->header(
            '-Cache-Control' => 'public',
            -type            => 'text/javascript',
        );
        $self->js;
        exit;
    }

    # Beginning of the job

    # User connected from more than 1 IP
    if ( $self->param('doubleIp') ) {
        my ( $byUid, $byIp );
        $globalStorage->get_key_from_all_sessions(
            $globalStorageOptions,
            sub {
                my $entry = shift;
                my $id    = shift;
                push @{ $byUid->{ $entry->{uid} }->{ $entry->{ipAddr} } },
                  { id => $id, _utime => $entry->{_utime} };
                undef;
            }
        );
        $self->start('Sessions multi-IP');
        $self->window("Sessions multi-IP");
        foreach my $uid (
            sort { ( keys %{ $byUid->{$b} } ) <=> ( keys %{ $byUid->{$a} } ) }
            keys %$byUid
          )
        {
            last if ( ( keys %{ $byUid->{$uid} } ) == 1 );
            print "<li id=\"di$uid\" class=\"closed\"><span>$uid</span><ul>";
            foreach my $ip ( sort keys %{ $byUid->{$uid} } ) {
                print "<li class=\"open\" id=\"di$ip\"><span>$ip</span><ul>";
                foreach my $session ( @{ $byUid->{$uid}->{$ip} } ) {
                    print
"<li id=\"di$session->{id}\"><span onclick=\"display('$session->{id}');\">"
                      . localtime( $session->{_utime} )
                      . "</span></li>";
                }
                print "</ul></li>";
            }
            print "</ul></li>";
        }
        $self->end();
    }

    # Request for IP addresses
    elsif ( my $req = $self->param('fullip') ) {
        my $byUid;
        my $reip = quotemeta($req);
        $reip =~ s/\\\*/\.\*/g;
        $globalStorage->get_key_from_all_sessions(
            $globalStorageOptions,
            sub {
                my $entry = shift;
                my $id    = shift;
                if ( $entry->{ipAddr} =~ /^$reip$/ ) {
                    push @{ $byUid->{ $entry->{ipAddr} }->{ $entry->{uid} } },
                      { id => $id, _utime => $entry->{_utime} };
                }
                undef;
            }
        );
        $self->start("IP : $req");
        $self->window("$req");
        foreach my $ip ( sort keys %$byUid ) {
            print "<li id=\"fi$ip\"><span>$ip</span><ul>";
            foreach my $uid ( sort keys %{ $byUid->{$ip} } ) {
                $self->ajaxNode(
                    $uid,
                    $uid
                      . (
                        @{ $byUid->{$ip}->{$uid} } > 1
                        ? " <i><u><small>("
                          . @{ $byUid->{$ip}->{$uid} }
                          . " sessions)</small></u></i>"
                        : ''
                      ),
                    "uid=$uid"
                );
            }
            print "</ul></li>";
        }
        $self->end();
    }

    # Request for users
    elsif ( my $req = $self->param('fulluid') ) {
        my $byUid;
        my $reuser = quotemeta($req);
        $reuser =~ s/\\\*/\.\*/g;
        $globalStorage->get_key_from_all_sessions(
            $globalStorageOptions,
            sub {
                my $entry = shift;
                my $id    = shift;
                if ( $entry->{uid} =~ /^$reuser$/ ) {
                    push @{ $byUid->{ $entry->{uid} } },
                      { id => $id, _utime => $entry->{_utime} };
                }
                undef;
            }
        );
        $self->start("Users : $req");
        $self->window("$req");
        foreach my $uid ( sort keys %$byUid ) {
            $self->ajaxNode(
                $uid,
                $uid
                  . (
                    @{ $byUid->{$uid} } > 1
                    ? " <i><u><small>("
                      . @{ $byUid->{$uid} }
                      . " sessions)</small></u></i>"
                    : ''
                  ),
                "uid=$uid"
            );
        }
        $self->end();
    }

    # Ajax request to delete a session
    elsif ( my $id = $self->param('delete') ) {
        my %h;
        print $self->header( -type => 'text/html; charset=utf8' );
        eval { tie %h, $globalStorage, $id, $globalStorageOptions; };
        if ($@) {
            print "<strong>Error : $@</strong>\n";
        }
        else {
            my $uid = $h{uid};
            eval { tied(%h)->delete(); };
            if ($@) {
                print "<strong>Error : $@</strong>\n";
            }
            else {
                print "<strong>Session effac&eacute;e ($uid)</strong>";
            }

        }
    }

    # Ajax request to dump a session
    elsif ( my $id = ( $self->param('session') || $self->param('id') ) ) {
        my %h;
        print $self->header( -type => 'text/html; charset=utf8' );
        eval { tie %h, $globalStorage, $id, $globalStorageOptions; };
        if ($@) {
            print "<strong>Error : $@</strong>\n";
        }
        else {
            print
"<input type=\"button\" onclick=\"del('$id');\" value=\"Effacer la session\" /><p><b>Session d&eacute;marr&eacute;e le</b> "
              . localtime( $h{_utime} )
              . '</p><p><b>Membre des groupes SSO :</b><ul>';
            print "<li>$_</li>" foreach ( split /\s+/, $h{groups} );
            print '</ul></p>';
            print
'<p><b>Attributs et macros :</b></p><table border="0" witdh="100%">';
            foreach my $attr ( sort keys %h ) {
                next if ( $attr =~ /^(?:_utime|groups)$/ );
                print '<tr valign="top"><th style="text-align:left;">'
                  . htmlquote($attr)
                  . '</th><td>:</td><td>'
                  . htmlquote( $h{$attr} )
                  . '</td></tr>'
                  if ( $h{$attr} );
            }
            print '</table>';
            untie %h;
        }
    }

    # Ajax request to see users by IP
    elsif ( my $ip = $self->param('uidByIp') ) {
        my $byUser;
        print $self->header( -type => 'text/html; charset=utf8' );
        $globalStorage->get_key_from_all_sessions(
            $globalStorageOptions,
            sub {
                my $entry = shift;
                my $id    = shift;
                if ( $entry->{ipAddr} eq $ip ) {
                    push @{ $byUser->{ $entry->{uid} } },
                      { id => $id, _utime => $entry->{_utime} };
                }
                undef;
            }
        );
        foreach my $user ( sort keys %$byUser ) {
            print "<li id=\"ip$user\"><span>$user</span><ul>";
            foreach my $session ( @{ $byUser->{$user} } ) {
                print
"<li id=\"ip$session->{id}\"><span onclick=\"display('$session->{id}');\">"
                  . localtime( $session->{_utime} )
                  . "</span></li>";
            }
            print "</ul></li>";
        }
    }

    # Ajax request to see connexions from a user
    elsif ( my $uid = $self->param('uid') ) {
        my $byIp;
        print $self->header( -type => 'text/html; charset=utf8' );
        $globalStorage->get_key_from_all_sessions(
            $globalStorageOptions,
            sub {
                my $entry = shift;
                my $id    = shift;
                if ( $entry->{uid} eq $uid ) {
                    push @{ $byIp->{ $entry->{ipAddr} } },
                      { id => $id, _utime => $entry->{_utime} };
                }
                undef;
            }
        );
        foreach my $ip ( sort keys %$byIp ) {
            print "<li class=\"open\" id=\"uid$ip\"><span>$ip</span><ul>";
            foreach my $session ( @{ $byIp->{$ip} } ) {
                print
"<li id=\"uid$session->{id}\"><span onclick=\"display('$session->{id}');\">"
                  . localtime( $session->{_utime} )
                  . "</span></li>";
            }
            print "</ul></li>";
        }
    }

    # Ajax request to list users starting by a letter
    elsif ( defined( $self->param('letter') ) ) {
        my $letter = $self->param('letter');
        my ($byUid);
        print $self->header( -type => 'text/html; charset=utf8' );
        $globalStorage->get_key_from_all_sessions(
            $globalStorageOptions,
            sub {
                my $entry = shift;
                $entry->{uid} =~ /^$letter/ or return undef;
                $byUid->{ $entry->{uid} }++;
            },
        );
        foreach my $uid ( sort keys %$byUid ) {
            $self->ajaxNode(
                $uid,
                $uid
                  . (
                    $byUid->{$uid} > 1
                    ? " <i><u><small>($byUid->{$uid} sessions)</small></u></i>"
                    : ''
                  ),
                "uid=$uid"
            );
        }
    }

    # Display by IP classes
    elsif ( $self->param('ipclasses') ) {
        my $partial = $self->param('p') ? $self->param('p') . '.' : '';
        my $repartial = quotemeta($partial);
        my ( $byIp, $count );
        $globalStorage->get_key_from_all_sessions(
            $globalStorageOptions,
            sub {
                my $entry = shift;
                $entry->{ipAddr} =~ /^$repartial(\d+)/ or return undef;
                $byIp->{$1}++;
                $count++;
                undef;
            }
        );

        # Ajax request to list ip subclasses
        if ($partial) {
            print $self->header( -type => 'text/html; charset=utf8' );
        }

        # Display by IP subclass
        else {
            $self->start("Active sessions ($count)");
            $self->window(
                "Sessions par r&eacute;seaux <i><small>($count)</small></i>");
        }
        foreach my $ip ( sort { $a <=> $b } keys %$byIp ) {
            $self->ajaxNode(
                "$partial$ip",
                "$partial$ip <i><small>($byIp->{$ip})</small></i>",
                (
                    $partial !~ /^\d+\.\d+\.\d+/
                    ? "ipclasses=1&p=$partial$ip"
                    : "uidByIp=$partial$ip"
                )
            );
        }
        $self->end() unless ($partial);
    }

    # Default display
    else {
        my ( $byUid, $count );
        $globalStorage->get_key_from_all_sessions(
            $globalStorageOptions,
            sub {
                my $entry = shift;
                $entry->{uid} =~ /^(\w)/ or return undef;
                $byUid->{$1}++;
                $count++;
                undef;
            }
        );
        $self->start("Active sessions ($count)");
        $self->window("Sessions <i><small>($count)</small></i>");
        foreach my $letter ( sort keys %$byUid ) {
            $self->ajaxNode( "li_$letter",
                "$letter <i><small>($byUid->{$letter} sessions)</small></i>",
                "letter=$letter" );
        }
        $self->end();
    }
}

sub htmlquote {
    my $s = shift;
    $s =~ s/</&lt;/g;
    $s =~ s/>/&gt;/g;
    $s =~ s/&/&amp;/g;
    return $s;
}

# HTML headers
sub start {
    my $self = shift;
    print $self->header( -type => 'text/html; charset=utf8', );
    print $self->start_html(
        -title => shift || 'Sessions Lemonldap::NG',
        -encoding => 'utf8',
        -script   => [
            {
                -language => 'JavaScript1.2',
                -src      => $self->{jqueryUri} || 'jquery.js',
            },
            {
                -language => 'JavaScript1.2',
                -src      => "$ENV{SCRIPT_NAME}/js",
            },
            {
                -language => 'JavaScript1.2',
                -code     => '$(document).ready(function(){
            var simpleTreeCollection
            simpleTreeCollection = $(".simpleTree").simpleTree({
                autoclose: true,
                drag: false,
                afterClick:function(node){
                //alert("text-"+$("span:first",node).text());
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
            });
            function del(session) {
                $("#content").load("' . $ENV{SCRIPT_NAME} . '?delete="+session);
            }
            function display(session) {
                $("#content").load("'
                  . $ENV{SCRIPT_NAME} . '?session="+session);
            }
            ',
            },
        ],
        -style => {
            -src => [
                "$ENV{SCRIPT_NAME}/css",
                ( $self->{personnalCss} ? $self->{personnalCss} : () )
            ],
        },
    );
}

# Ajax node use by JQuery.simple.tree
sub ajaxNode {
    my ( $self, $id, $text, $param ) = @_;
    print
"<li id=\"$id\"><span>$text</span>\n<ul class=\"ajax\"><li id=\"sub_$id\">{url:$ENV{SCRIPT_NAME}?$param}</li></ul></li>\n";
}

# Design of the main window
sub window {
    my $self = shift;
    my $root = shift;
    print '<table border="0" width="100%"><tr style="text-align:center;">
      <td><a href="' . $ENV{SCRIPT_NAME} . '">Sessions actives</a></td>
      <td><a href="'
      . $ENV{SCRIPT_NAME} . '?ipclasses=1">R&eacute;seaux</a></td>
      <td><a href="'
      . $ENV{SCRIPT_NAME} . '?doubleIp=1">Utilisateurs multi-IP</a></td>
      <td><form action="'
      . $ENV{SCRIPT_NAME}
      . '" method="get">Recherche par UID <input name="fulluid" /><input type="submit" value="OK" /></form></td>
      <td><form action="'
      . $ENV{SCRIPT_NAME}
      . '" method="get">Recherche par IP <input name="fullip" /><input type="submit" value="OK" /></form></td>
    </tr></table>
    <table border="0" width="100%"><tr><td width="300px" valign="top"><div style="overflow:auto;height:600px;">
    <ul class="simpleTree"><li class="root" id="root"><span>' . $root
      . '</span><ul>';
}

# End of HTML
sub end {
    my $self = shift;
    print
'</ul></li></ul></div></td><td valign="top"><div id="content" style="overflow:auto;height:600px;"></div></td></tr></table>';
    print $self->end_html();
}

1;

sub css {
    my $self = shift;
    print <<"EOF";
body
{
	font: normal 12px arial, tahoma, helvetica, sans-serif;
	margin:0;
	padding:20px;
}
.simpleTree
{
	overflow:auto;
	margin:0;
	padding:0;
	/*
 * width: 250px;
 * height:350px;
 * overflow:auto;
 * border: 1px solid #444444;
 * */
}
.simpleTree li
{
    list-style: none;
    margin:0;
    padding:0 0 0 34px;
    line-height: 14px;
}
.simpleTree li span
{
    display:inline;
    clear: left;
    white-space: nowrap;
}
.simpleTree ul
{
    margin:0; 
    padding:0;
}
.simpleTree .root
{
    margin-left:-16px;
    background: url($self->{imagePath}root.gif) no-repeat 16px 0 #ffffff;
}
.simpleTree .line
{
    margin:0 0 0 -16px;
    padding:0;
    line-height: 3px;
    height:3px;
    font-size:3px;
    background: url($self->{imagePath}line_bg.gif) 0 0 no-repeat transparent;
}
.simpleTree .line-last
{
    margin:0 0 0 -16px;
    padding:0;
    line-height: 3px;
    height:3px;
    font-size:3px;
    background: url($self->{imagePath}spacer.gif) 0 0 no-repeat transparent;
}
.simpleTree .line-over
{
    margin:0 0 0 -16px;
    padding:0;
    line-height: 3px;
    height:3px;
    font-size:3px;
    background: url($self->{imagePath}line_bg_over.gif) 0 0 no-repeat transparent;
}
.simpleTree .line-over-last
{
    margin:0 0 0 -16px;
    padding:0;
    line-height: 3px;
    height:3px;
    font-size:3px;
    background: url($self->{imagePath}line_bg_over_last.gif) 0 0 no-repeat transparent;
}
.simpleTree .folder-open
{
    margin-left:-16px;
    background: url($self->{imagePath}collapsable.gif) 0 -2px no-repeat #fff;
}
.simpleTree .folder-open-last
{
    margin-left:-16px;
    background: url($self->{imagePath}collapsable-last.gif) 0 -2px no-repeat #fff;
}
.simpleTree .folder-close
{
    margin-left:-16px;
    background: url($self->{imagePath}expandable.gif) 0 -2px no-repeat #fff;
}
.simpleTree .folder-close-last
{
    margin-left:-16px;
    background: url($self->{imagePath}expandable-last.gif) 0 -2px no-repeat #fff;
}
.simpleTree .doc
{
    margin-left:-16px;
    background: url($self->{imagePath}leaf.gif) 0 -1px no-repeat #fff;
}
.simpleTree .doc-last
{
    margin-left:-16px;
    background: url($self->{imagePath}leaf-last.gif) 0 -1px no-repeat #fff;
}
.simpleTree .ajax
{
    background: url($self->{imagePath}spinner.gif) no-repeat 0 0 #ffffff;
    height: 16px;
    display:none;
}
.simpleTree .ajax li
{
    display:none;
    margin:0; 
    padding:0;
}
.simpleTree .trigger
{
    display:inline;
    margin-left:-32px;
    width: 28px;
    height: 11px;
    cursor:pointer;
}
.simpleTree .text
{
    cursor: default;
}
.simpleTree .active
{
    cursor: default;
    background-color:#F7BE77;
    padding:0px 2px;
    border: 1px dashed #444;
}
#drag_container
{
    background:#ffffff;
    color:#000;
    font: normal 11px arial, tahoma, helvetica, sans-serif;
    border: 1px dashed #767676;
}
#drag_container ul
{
    list-style: none;
    padding:0;
    margin:0;
}

#drag_container li
{
    list-style: none;
    background-color:#ffffff;
    line-height:18px;
    white-space: nowrap;
    padding:1px 1px 0px 16px;
    margin:0;
}
#drag_container li span
{
    padding:0;
}

#drag_container li.doc, #drag_container li.doc-last
{
    background: url($self->{imagePath}leaf.gif) no-repeat -17px 0 #ffffff;
}
#drag_container .folder-close, #drag_container .folder-close-last
{
    background: url($self->{imagePath}expandable.gif) no-repeat -17px 0 #ffffff;
}

#drag_container .folder-open, #drag_container .folder-open-last
{
    background: url($self->{imagePath}collapsable.gif) no-repeat -17px 0 #ffffff;
}
EOF
}

sub js {
    my $self = shift;
    print <<"EOF";
/*
* jQuery SimpleTree Drag&Drop plugin
* Update on 22th May 2008
* Version 0.3
*
* Licensed under BSD <http://en.wikipedia.org/wiki/BSD_License>
* Copyright (c) 2008, Peter Panov <panov\@elcat.kg>, IKEEN Group http://www.ikeen.com
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the Peter Panov, IKEEN Group nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY Peter Panov, IKEEN Group ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL Peter Panov, IKEEN Group BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


\$.fn.simpleTree = function(opt){
	return this.each(function(){
		var TREE = this;
		var ROOT = \$('.root',this);
		var mousePressed = false;
		var mouseMoved = false;
		var dragMoveType = false;
		var dragNode_destination = false;
		var dragNode_source = false;
		var dragDropTimer = false;
		var ajaxCache = Array();

		TREE.option = {
			drag:		true,
			animate:	false,
			autoclose:	false,
			speed:		'fast',
			afterAjax:	false,
			afterMove:	false,
			afterClick:	false,
			afterDblClick:	false,
			// added by Erik Dohmen (2BinBusiness.nl) to make context menu cliks available
			afterContextMenu:	false,
			docToFolderConvert:false
		};
		TREE.option = \$.extend(TREE.option,opt);
		\$.extend(this, {getSelected: function(){
			return \$('span.active', this).parent();
		}});
		TREE.closeNearby = function(obj)
		{
			\$(obj).siblings().filter('.folder-open, .folder-open-last').each(function(){
				var childUl = \$('>ul',this);
				var className = this.className;
				this.className = className.replace('open','close');
				if(TREE.option.animate)
				{
					childUl.animate({height:"toggle"},TREE.option.speed);
				}else{
					childUl.hide();
				}
			});
		};
		TREE.nodeToggle = function(obj)
		{
			var childUl = \$('>ul',obj);
			if(childUl.is(':visible')){
				obj.className = obj.className.replace('open','close');

				if(TREE.option.animate)
				{
					childUl.animate({height:"toggle"},TREE.option.speed);
				}else{
					childUl.hide();
				}
			}else{
				obj.className = obj.className.replace('close','open');
				if(TREE.option.animate)
				{
					childUl.animate({height:"toggle"},TREE.option.speed, function(){
						if(TREE.option.autoclose)TREE.closeNearby(obj);
						if(childUl.is('.ajax'))TREE.setAjaxNodes(childUl, obj.id);
					});
				}else{
					childUl.show();
					if(TREE.option.autoclose)TREE.closeNearby(obj);
					if(childUl.is('.ajax'))TREE.setAjaxNodes(childUl, obj.id);
				}
			}
		};
		TREE.setAjaxNodes = function(node, parentId, callback)
		{
			if(\$.inArray(parentId,ajaxCache) == -1){
				ajaxCache[ajaxCache.length]=parentId;
				var url = \$.trim(\$('>li', node).text());
				if(url && url.indexOf('url:'))
				{
					url=\$.trim(url.replace(/.*\\{url:(.*)\\}/i ,'\$1'));
					\$.ajax({
						type: "GET",
						url: url,
						contentType:'html',
						cache:false,
						success: function(responce){
							node.removeAttr('class');
							node.html(responce);
							\$.extend(node,{url:url});
							TREE.setTreeNodes(node, true);
							if(typeof TREE.option.afterAjax == 'function')
							{
								TREE.option.afterAjax(node);
							}
							if(typeof callback == 'function')
							{
								callback(node);
							}
						}
					});
				}
				
			}
		};
		TREE.setTreeNodes = function(obj, useParent){
			obj = useParent? obj.parent():obj;
			\$('li>span', obj).addClass('text')
			.bind('selectstart', function() {
				return false;
			}).click(function(){
				\$('.active',TREE).attr('class','text');
				if(this.className=='text')
				{
					this.className='active';
				}
				if(typeof TREE.option.afterClick == 'function')
				{
					TREE.option.afterClick(\$(this).parent());
				}
				return false;
			}).dblclick(function(){
				mousePressed = false;
				TREE.nodeToggle(\$(this).parent().get(0));
				if(typeof TREE.option.afterDblClick == 'function')
				{
					TREE.option.afterDblClick(\$(this).parent());
				}
				return false;
				// added by Erik Dohmen (2BinBusiness.nl) to make context menu actions
				// available
			}).bind("contextmenu",function(){
				\$('.active',TREE).attr('class','text');
				if(this.className=='text')
				{
					this.className='active';
				}
				if(typeof TREE.option.afterContextMenu == 'function')
				{
					TREE.option.afterContextMenu(\$(this).parent());
				}
				return false;
			}).mousedown(function(event){
				mousePressed = true;
				cloneNode = \$(this).parent().clone();
				var LI = \$(this).parent();
				if(TREE.option.drag)
				{
					\$('>ul', cloneNode).hide();
					\$('body').append('<div id="drag_container"><ul></ul></div>');
					\$('#drag_container').hide().css({opacity:'0.8'});
					\$('#drag_container >ul').append(cloneNode);
					\$("<img>").attr({id	: "tree_plus",src	: "$self->{imagePath}plus.gif"}).css({width: "7px",display: "block",position: "absolute",left	: "5px",top: "5px", display:'none'}).appendTo("body");
					\$(document).bind("mousemove", {LI:LI}, TREE.dragStart).bind("mouseup",TREE.dragEnd);
				}
				return false;
			}).mouseup(function(){
				if(mousePressed && mouseMoved && dragNode_source)
				{
					TREE.moveNodeToFolder(\$(this).parent());
				}
				TREE.eventDestroy();
			});
			\$('li', obj).each(function(i){
				var className = this.className;
				var open = false;
				var cloneNode=false;
				var LI = this;
				var childNode = \$('>ul',this);
				if(childNode.size()>0){
					var setClassName = 'folder-';
					if(className && className.indexOf('open')>=0){
						setClassName=setClassName+'open';
						open=true;
					}else{
						setClassName=setClassName+'close';
					}
					this.className = setClassName + (\$(this).is(':last-child')? '-last':'');

					if(!open || className.indexOf('ajax')>=0)childNode.hide();

					TREE.setTrigger(this);
				}else{
					var setClassName = 'doc';
					this.className = setClassName + (\$(this).is(':last-child')? '-last':'');
				}
			}).before('<li class="line">&nbsp;</li>')
			.filter(':last-child').after('<li class="line-last"></li>');
			TREE.setEventLine(\$('.line, .line-last', obj));
		};
		TREE.setTrigger = function(node){
			\$('>span',node).before('<img class="trigger" src="$self->{imagePath}spacer.gif" border=0>');
			var trigger = \$('>.trigger', node);
			trigger.click(function(event){
				TREE.nodeToggle(node);
			});
			if(!\$.browser.msie)
			{
				trigger.css('float','left');
			}
		};
		TREE.dragStart = function(event){
			var LI = \$(event.data.LI);
			if(mousePressed)
			{
				mouseMoved = true;
				if(dragDropTimer) clearTimeout(dragDropTimer);
				if(\$('#drag_container:not(:visible)')){
					\$('#drag_container').show();
					LI.prev('.line').hide();
					dragNode_source = LI;
				}
				\$('#drag_container').css({position:'absolute', "left" : (event.pageX + 5), "top": (event.pageY + 15) });
				if(LI.is(':visible'))LI.hide();
				var temp_move = false;
				if(event.target.tagName.toLowerCase()=='span' && \$.inArray(event.target.className, Array('text','active','trigger'))!= -1)
				{
					var parent = event.target.parentNode;
					var offs = \$(parent).offset({scroll:false});
					var screenScroll = {x : (offs.left - 3),y : event.pageY - offs.top};
					var isrc = \$("#tree_plus").attr('src');
					var ajaxChildSize = \$('>ul.ajax',parent).size();
					var ajaxChild = \$('>ul.ajax',parent);
					screenScroll.x += 19;
					screenScroll.y = event.pageY - screenScroll.y + 5;

					if(parent.className.indexOf('folder-close')>=0 && ajaxChildSize==0)
					{
						if(isrc.indexOf('minus')!=-1)\$("#tree_plus").attr('src','$self->{imagePath}plus.gif');
						\$("#tree_plus").css({"left": screenScroll.x, "top": screenScroll.y}).show();
						dragDropTimer = setTimeout(function(){
							parent.className = parent.className.replace('close','open');
							\$('>ul',parent).show();
						}, 700);
					}else if(parent.className.indexOf('folder')>=0 && ajaxChildSize==0){
						if(isrc.indexOf('minus')!=-1)\$("#tree_plus").attr('src','$self->{imagePath}plus.gif');
						\$("#tree_plus").css({"left": screenScroll.x, "top": screenScroll.y}).show();
					}else if(parent.className.indexOf('folder-close')>=0 && ajaxChildSize>0)
					{
						mouseMoved = false;
						\$("#tree_plus").attr('src','$self->{imagePath}minus.gif');
						\$("#tree_plus").css({"left": screenScroll.x, "top": screenScroll.y}).show();

						\$('>ul',parent).show();
						/*
							Thanks for the idea of Erik Dohmen
						*/
						TREE.setAjaxNodes(ajaxChild,parent.id, function(){
							parent.className = parent.className.replace('close','open');
							mouseMoved = true;
							\$("#tree_plus").attr('src','$self->{imagePath}plus.gif');
							\$("#tree_plus").css({"left": screenScroll.x, "top": screenScroll.y}).show();
						});

					}else{
						if(TREE.option.docToFolderConvert)
						{
							\$("#tree_plus").css({"left": screenScroll.x, "top": screenScroll.y}).show();
						}else{
							\$("#tree_plus").hide();
						}
					}
				}else{
					\$("#tree_plus").hide();
				}
				return false;
			}
			return true;
		};
		TREE.dragEnd = function(){
			if(dragDropTimer) clearTimeout(dragDropTimer);
			TREE.eventDestroy();
		};
		TREE.setEventLine = function(obj){
			obj.mouseover(function(){
				if(this.className.indexOf('over')<0 && mousePressed && mouseMoved)
				{
					this.className = this.className.replace('line','line-over');
				}
			}).mouseout(function(){
				if(this.className.indexOf('over')>=0)
				{
					this.className = this.className.replace('-over','');
				}
			}).mouseup(function(){
				if(mousePressed && dragNode_source && mouseMoved)
				{
					dragNode_destination = \$(this).parents('li:first');
					TREE.moveNodeToLine(this);
					TREE.eventDestroy();
				}
			});
		};
		TREE.checkNodeIsLast = function(node)
		{
			if(node.className.indexOf('last')>=0)
			{
				var prev_source = dragNode_source.prev().prev();
				if(prev_source.size()>0)
				{
					prev_source[0].className+='-last';
				}
				node.className = node.className.replace('-last','');
			}
		};
		TREE.checkLineIsLast = function(line)
		{
			if(line.className.indexOf('last')>=0)
			{
				var prev = \$(line).prev();
				if(prev.size()>0)
				{
					prev[0].className = prev[0].className.replace('-last','');
				}
				dragNode_source[0].className+='-last';
			}
		};
		TREE.eventDestroy = function()
		{
			// added by Erik Dohmen (2BinBusiness.nl), the unbind mousemove TREE.dragStart action
			// like this other mousemove actions binded through other actions ain't removed (use it myself
			// to determine location for context menu)
			\$(document).unbind('mousemove',TREE.dragStart).unbind('mouseup').unbind('mousedown');
			\$('#drag_container, #tree_plus').remove();
			if(dragNode_source)
			{
				\$(dragNode_source).show().prev('.line').show();
			}
			dragNode_destination = dragNode_source = mousePressed = mouseMoved = false;
			//ajaxCache = Array();
		};
		TREE.convertToFolder = function(node){
			node[0].className = node[0].className.replace('doc','folder-open');
			node.append('<ul><li class="line-last"></li></ul>');
			TREE.setTrigger(node[0]);
			TREE.setEventLine(\$('.line, .line-last', node));
		};
		TREE.convertToDoc = function(node){
			\$('>ul', node).remove();
			\$('img', node).remove();
			node[0].className = node[0].className.replace(/folder-(open|close)/gi , 'doc');
		};
		TREE.moveNodeToFolder = function(node)
		{
			if(!TREE.option.docToFolderConvert && node[0].className.indexOf('doc')!=-1)
			{
				return true;
			}else if(TREE.option.docToFolderConvert && node[0].className.indexOf('doc')!=-1){
				TREE.convertToFolder(node);
			}
			TREE.checkNodeIsLast(dragNode_source[0]);
			var lastLine = \$('>ul >.line-last', node);
			if(lastLine.size()>0)
			{
				TREE.moveNodeToLine(lastLine[0]);
			}
		};
		TREE.moveNodeToLine = function(node){
			TREE.checkNodeIsLast(dragNode_source[0]);
			TREE.checkLineIsLast(node);
			var parent = \$(dragNode_source).parents('li:first');
			var line = \$(dragNode_source).prev('.line');
			\$(node).before(dragNode_source);
			\$(dragNode_source).before(line);
			node.className = node.className.replace('-over','');
			var nodeSize = \$('>ul >li', parent).not('.line, .line-last').filter(':visible').size();
			if(TREE.option.docToFolderConvert && nodeSize==0)
			{
				TREE.convertToDoc(parent);
			}else if(nodeSize==0)
			{
				parent[0].className=parent[0].className.replace('open','close');
				\$('>ul',parent).hide();
			}

			// added by Erik Dohmen (2BinBusiness.nl) select node
			if(\$('span:first',dragNode_source).attr('class')=='text')
			{
				\$('.active',TREE).attr('class','text');
				\$('span:first',dragNode_source).attr('class','active');
			}

			if(typeof(TREE.option.afterMove) == 'function')
			{
				var pos = \$(dragNode_source).prevAll(':not(.line)').size();
				TREE.option.afterMove(\$(node).parents('li:first'), \$(dragNode_source), pos);
			}
		};

		TREE.addNode = function(id, text, callback)
		{
			var temp_node = \$('<li><ul><li id="'+id+'"><span>'+text+'</span></li></ul></li>');
			TREE.setTreeNodes(temp_node);
			dragNode_destination = TREE.getSelected();
			dragNode_source = \$('.doc-last',temp_node);
			TREE.moveNodeToFolder(dragNode_destination);
			temp_node.remove();
			if(typeof(callback) == 'function')
			{
				callback(dragNode_destination, dragNode_source);
			}
		};
		TREE.delNode = function(callback)
		{
			dragNode_source = TREE.getSelected();
			TREE.checkNodeIsLast(dragNode_source[0]);
			dragNode_source.prev().remove();
			dragNode_source.remove();
			if(typeof(callback) == 'function')
			{
				callback(dragNode_destination);
			}
		};

		TREE.init = function(obj)
		{
			TREE.setTreeNodes(obj, false);
		};
		TREE.init(ROOT);
	});
}
EOF
}
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Lemonldap::NG::Manager::Sessions - Perl extension to manage Lemonldap::NG
sessions

=head1 SYNOPSIS

  #!/usr/bin/perl

  use strict;
  use Lemonldap::NG::Manager::Sessions;
  our $cgi ||= Lemonldap::NG::Manager::Sessions->new({
        localStorage        => "Cache::FileCache",
        localStorageOptions => {
            'namespace'          => 'MyNamespace',
            'default_expires_in' => 600,
            'directory_umask'    => '007',
            'cache_root'         => '/tmp',
            'cache_depth'        => 5,
        },
        configStorage => $Lemonldap::NG::Conf::configStorage,
        configStorage=>{
          type=>'File',
          dirName=>"/tmp/",
        },
        https         => 1,
        jqueryUri     => '/js/jquery/jquery.js',
        imagePath     => '/js/jquery.simple.tree/',
        # Optionnal
        protection    => 'rule: $uid eq "admin"',
        # Or to use rules from manager
        protection    => 'manager',
	# Or just to authenticate without managing authorization
	protection    => 'authenticate',
  });
  $cgi->process();

=head1 DESCRIPTION

Lemonldap::NG::Manager::Sessions provides a web interface to manage
Lemonldap::NG sessions.

It inherits from L<Lemonldap::NG::Handler::CGI>, so see this manpage to
understand how arguments passed to the constructor.

=head1 SEE ALSO

L<Lemonldap::NG::Handler::CGI>, L<Lemonldap::NG::Manager>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

C<jquery.simple.tree> embedded javascript library is licensed under BSD
L<http://en.wikipedia.org/wiki/BSD_License> and copyrighted (c) 2008 by Peter
Panov E<lt>panov@elcat.kgE<gt>, IKEEN Group L<http://www.ikeen.com/>

=cut
