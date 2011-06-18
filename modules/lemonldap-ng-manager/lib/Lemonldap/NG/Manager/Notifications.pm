## @file
# Notification explorer

## @class
# Notification explorer.
# Synopsis:
#  * build a new Lemonldap::NG::Manager::Notifications object
#  * insert tree() result in HTML
#
# tree() loads on of the tree methods.
# new() manage ajax requests (inserted in HTML tree)
package Lemonldap::NG::Manager::Notifications;

use strict;
use File::Basename;
use Lemonldap::NG::Handler::CGI qw(:globalStorage :locationRules);
use Lemonldap::NG::Portal::Notification;
use Lemonldap::NG::Common::Conf;              #link protected conf Configuration
use Lemonldap::NG::Common::Conf::Constants;   #inherits
require Lemonldap::NG::Manager::_i18n;        #inherits
use utf8;

our $whatToTrace;
*whatToTrace = \$Lemonldap::NG::Handler::_CGI::whatToTrace;

our $VERSION = '1.1.0';

our @ISA = qw(
  Lemonldap::NG::Handler::CGI
  Lemonldap::NG::Manager::_i18n
);

## @cmethod Lemonldap::NG::Manager::Notifications new(hashRef args)
# Constructor.
# @param $args Arguments for Lemonldap::NG::Handler::CGI::new()
# @return New Lemonldap::NG::Manager::Notifications object
sub new {
    my ( $class, $args ) = @_;

    # Output UTF-8
    binmode( STDOUT, ':utf8' );

    # Try to get configuration values from global configuration
    my $conf = Lemonldap::NG::Common::Conf->new( $args->{configStorage} )
      or Lemonldap::NG::Handler::CGI->abort( 'Unable to get configuration',
        $Lemonldap::NG::Common::Conf::msg );

    # Configuration from MANAGER section
    if ( my $localconf = $conf->getLocalConf(MANAGERSECTION) ) {
        $args->{$_} ||= $localconf->{$_} foreach ( keys %$localconf );
    }

    # Load global configuration
    if ( my $globalconf = $conf->getConf() ) {
        $args->{$_} ||= $globalconf->{$_} foreach ( keys %$globalconf );
    }

    my $self = $class->SUPER::new($args)
      or $class->abort( 'Unable to start ' . __PACKAGE__,
        'See Apache logs for more' );

    # Local args prepends global args
    $self->{$_} = $args->{$_} foreach ( keys %$args );

    # Load default skin if no other specified
    $self->{managerSkin} ||= 'default';

    # Verify if Notification is enabled
    $class->abort("Notifications not enabled, please update configuration")
      unless $self->{notification};

    # Now try to load Notification module
    my $tmp;

    # Use configuration options
    if ( $self->{notificationStorage} ) {
        $tmp->{type} = $self->{notificationStorage};
        foreach ( keys %{ $self->{notificationStorageOptions} } ) {
            $tmp->{$_} = $self->{notificationStorageOptions}->{$_};
        }
    }

    # Else use the configuration backend
    else {
        (%$tmp) = ( %{ $self->{lmConf} } );
        $class->abort( "notificationStorage not defined",
            "This parameter is required to use notification system" )
          unless ( ref($tmp) );

        # Get the type
        $tmp->{type} =~ s/.*:://;
        $tmp->{type} =~ s/(CBDI|RDBI)/DBI/;    # CDBI/RDBI are DBI

        # If type not File or DBI, abort
        $class->abort("Only File or DBI supported for Notifications")
          unless $tmp->{type} =~ /^(File|DBI)$/;

        # Force table name
        $tmp->{table} = 'notifications';
    }

    $tmp->{p}            = $self;
    $self->{notifObject} = Lemonldap::NG::Portal::Notification->new($tmp);
    $class->abort($Lemonldap::NG::Portal::Notification::msg)
      unless ( $self->{notifObject} );

    # Multi values separator
    $self->{multiValuesSeparator} ||= '; ';

    # Absolute path to the htdocs directory where is manager script.
    my ( $mname, $mpath, $msuffix ) = fileparse( $ENV{SCRIPT_FILENAME} );
    $self->{managerHtdocsPath} = $mpath;

    # Now we're ready to display sessions. Choose display type
    foreach my $k ( $self->param() ) {

        # Case ajax request : execute corresponding sub and quit
        if ( grep { $_ eq $k } qw(delete notification id uidByIp uid letter p) )
        {
            print $self->header( -type => 'text/html;charset=utf-8' );
            print $self->$k( $self->param($k) );
            $self->quit();
        }

        # Case else : store tree type choosen to use it later in tree()
        elsif ( grep { $_ eq $k } qw(doubleIp fullip fulluid ipclasses) ) {
            $self->{_tree} = $k;
            last;
        }
    }

    # default display : list by uid
    $self->{_tree} ||= 'list';
    return $self;
}

## @method string tree()
# Launch required tree builder. It can be one of :
#  * doubleIp()
#  * fullip()
#  * fulluid()
#  * ipclasses()
#  * list() (default)
# @return string XML tree
sub tree {
    my $self = shift;

    my $sub = $self->{_tree};
    $self->lmLog( "Building chosen tree: $sub", 'debug' );
    my ( $r, $legend ) = $self->$sub( $self->param($sub) );
    return
qq{<ul class="simpleTree"><li class="root" id="root"><span>$legend</span><ul>$r</ul></li></ul>};
}

################
# TREE METHODS #
################

## @method protected string list()
# Build default tree (by letter)
# @return string XML tree
sub list {
    my $self = shift;
    my ( $byUid, $count, $res );
    $count = 0;

    # Parse all notifications to store first letter
    my $n = $self->{notifObject}->getAll();

    foreach ( keys %$n ) {
        $n->{$_}->{uid} =~ /^(\w)/ or next;
        $byUid->{$1}++;
        $count++;
    }

    # Build tree sorted by first letter
    foreach my $letter ( sort keys %$byUid ) {
        $res .= $self->ajaxNode(

            # ID
            "li_$letter",

            # Legend
            "$letter <i><small>($byUid->{$letter} "
              . (
                $byUid->{$letter} == 1
                ? "notification"
                : "notifications"
              )
              . ")</small></i>",

            # Next request
            "letter=$letter"
        );
    }
    return (
        $res,
        "$count "
          . (
            $count == 1
            ? "notification"
            : "notifications"
          )
    );
}

## @method protected string doubleIp()
# Build tree with users connected from more than 1 IP
# @return string XML tree
sub doubleIp {
    my $self = shift;
    my ( $byUid, $byIp, $res, $count );

    # Parse all sessions
    Lemonldap::NG::Common::Apache::Session->get_key_from_all_sessions(
        $self->{globalStorageOptions},
        sub {
            my $entry = shift;
            my $id    = shift;
            next if ( $entry->{_httpSessionType} );
            push @{ $byUid->{ $entry->{$whatToTrace} }
                  ->{ $entry->{ $self->{ipField} } } },
              { id => $id, startTime => $entry->{startTime} };
            undef;
        }
    );

    # Build tree sorted by uid (or other field chosen in whatToTrace parameter)
    foreach my $uid (
        sort { ( keys %{ $byUid->{$b} } ) <=> ( keys %{ $byUid->{$a} } ) }
        keys %$byUid
      )
    {

        # Parse only uid that are connected from more than 1 IP
        last if ( ( keys %{ $byUid->{$uid} } ) == 1 );
        $count++;

        # Build UID node with IP as sub node
        $res .= "<li id=\"di$uid\" class=\"closed\"><span>$uid</span><ul>";
        foreach my $ip ( sort keys %{ $byUid->{$uid} } ) {
            $res .= "<li class=\"open\" id=\"di$ip\"><span>$ip</span><ul>";

            # For each IP node, store sessions sorted by start time
            foreach my $session ( sort { $a->{startTime} <=> $b->{startTime} }
                @{ $byUid->{$uid}->{$ip} } )
            {
                $res .=
"<li id=\"di$session->{id}\"><span onclick=\"displaySession('$session->{id}');\">"
                  . $self->_stToStr( $session->{startTime} )
                  . "</span></li>";
            }
            $res .= "</ul></li>";
        }
        $res .= "</ul></li>";
    }

    return (
        $res,
        "$count "
          . (
              $count == 1
            ? $self->translate('user')
            : $self->translate('users')
          )
    );
}

## @method protected string fullip(string req)
# Build single IP tree
# @param $req Optional IP request (127* for example)
# @return string XML tree
sub fullip {
    my ( $self, $req ) = splice @_;
    my ( $byUid, $res );

    # Build regexp based on IP request
    my $reip = quotemeta($req);
    $reip =~ s/\\\*/\.\*/g;

    # Parse all sessions and store only if IP match regexp
    Lemonldap::NG::Common::Apache::Session->get_key_from_all_sessions(
        $self->{globalStorageOptions},
        sub {
            my $entry = shift;
            my $id    = shift;
            next if ( $entry->{_httpSessionType} );
            if ( $entry->{ $self->{ipField} } =~ /$reip/ ) {
                push @{ $byUid->{ $entry->{ $self->{ipField} } }
                      ->{ $entry->{$whatToTrace} } },
                  { id => $id, startTime => $entry->{startTime} };
            }
            undef;
        }
    );

    # Build tree sorted by IP
    foreach my $ip ( sort keys %$byUid ) {
        $res .= "<li id=\"fi$ip\"><span>$ip</span><ul>";
        foreach my $uid ( sort keys %{ $byUid->{$ip} } ) {
            $res .= $self->ajaxNode(
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
        $res .= "</ul></li>";
    }
    return $res;
}

## @method protected string fulluid(string req)
# Build single uid tree
# @param $req request (examples: foo*, foo.bar)
# @return string XML tree
sub fulluid {
    my ( $self, $req ) = splice @_;
    my ( $byUid, $res );

    # Build regexp based on request
    my $reuser = quotemeta($req);
    $reuser =~ s/\\\*/\.\*/g;

    # Parse all sessions to find user that match regexp
    Lemonldap::NG::Common::Apache::Session->get_key_from_all_sessions(
        $self->{globalStorageOptions},
        sub {
            my $entry = shift;
            my $id    = shift;
            next if ( $entry->{_httpSessionType} );
            if ( $entry->{$whatToTrace} =~ /^$reuser$/ ) {
                push @{ $byUid->{ $entry->{$whatToTrace} } },
                  { id => $id, startTime => $entry->{startTime} };
            }
            undef;
        }
    );

    # Build tree sorted by uid
    foreach my $uid ( sort keys %$byUid ) {
        $res .= $self->ajaxNode(
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
}

## @method protected string ipclasses()
# Build IP classes tree (call _ipclasses())
# @return string XML tree
sub ipclasses {
    my $self = shift;
    return $self->_ipclasses();
}

##################
# AJAX RESPONSES #
##################

## @method protected string delete(string id)
# Delete a session
# @param id Session identifier
# @return string XML tree
sub delete {
    my ( $self, $id ) = splice @_;
    my ( $uid, $ref ) = ( $id =~ /([^_]+?)_(.+)/ );
    my ( $n, $res );

    # Try to read notification
    $n = $self->{notifObject}->_get( $uid, $ref );

    unless ($n) {
        $self->lmLog( "Notification $ref not found for user $uid", 'error' );
        $res .= '<h1 class="ui-widget-header ui-corner-all">'
          . $self->translate('error') . '</h1>';
        $res .= '<div class="ui-corner-all ui-widget-content">';
        $res .= "Notification $ref not found for user $uid";
        $res .= '</div>';
        return $res;
    }

    # Delete notifications
    my $status = 1;
    foreach ( keys %$n ) {
        $status = 0 unless ( $self->{notifObject}->_delete($_) );
    }

    unless ($status) {

        $self->lmLog( "Notification $ref for user $uid not deleted", 'error' );
        $res .= '<h1 class="ui-widget-header ui-corner-all">'
          . $self->translate('error') . '</h1>';
        $res .= '<div class="ui-corner-all ui-widget-content">';
        $res .= "Notification $ref for user $uid not deleted";
        $res .= '</div>';
        return $res;

    }

    else {
        $self->lmLog( "Notification $ref deleted for user $uid", 'info' );
        $res .= '<h1 class="ui-widget-header ui-corner-all">'
          . $self->translate('notificationDeleted') . '</h1>';
        return $res;
    }

}

## @method protected string notification()
# Build notification dump.
# @return string XML tree
sub notification {
    my ( $self, $id ) = splice @_;
    my ( $uid, $ref ) = ( $id =~ /([^_]+?)_(.+)/ );
    my ( $n, $res );

    # Try to read notification
    $n = $self->{notifObject}->_get( $uid, $ref );

    unless ($n) {
        $self->lmLog( "Notification $ref not found for user $uid", 'error' );
        $res .= '<h1 class="ui-widget-header ui-corner-all">'
          . $self->translate('error') . '</h1>';
        $res .= '<div class="ui-corner-all ui-widget-content">';
        $res .= "Notification $ref not found for user $uid";
        $res .= '</div>';
        return $res;
    }

    # Notification is avalaible, print content
    $res .= '<h1 class="ui-widget-header ui-corner-all">';
    $res .= "Notification $ref";
    $res .= '</h1>';

    foreach ( keys %$n ) {

        my $xml = $n->{$_};

        # Quote HTML
        $xml = htmlquote($xml);

        # UTF-8
        utf8::decode($xml);

        # Replace line breaks
        $xml =~ s#\n#<br />#g;

        # Print XML
        $res .= "<p style=\"text-align:left;\"><tt>$xml</tt></p>";

    }

    # Delete button
    $res .= '<div style="text-align:center">';
    $res .=
        "<input type=\"button\" onclick=\"del('$id');\""
      . ' class="ui-state-default ui-corner-all"'
      . " value=\""
      . $self->translate('deleteNotification') . "\" />";
    $res .= '</div>';

    return $res;
}

## @method protected string uidByIp()
# Build single IP tree
# @return string XML tree
sub uidByIp {
    my ( $self, $ip ) = splice @_;
    my ( $byUser, $res );
    Lemonldap::NG::Common::Apache::Session->get_key_from_all_sessions(
        $self->{globalStorageOptions},
        sub {
            my $entry = shift;
            my $id    = shift;
            next if ( $entry->{_httpSessionType} );
            if ( $entry->{ $self->{ipField} } eq $ip ) {
                push @{ $byUser->{ $entry->{$whatToTrace} } },
                  { id => $id, startTime => $entry->{startTime} };
            }
            undef;
        }
    );
    foreach my $user ( sort keys %$byUser ) {
        $res .= "<li id=\"ip$user\"><span>$user</span><ul>";
        foreach my $session ( sort { $a->{startTime} <=> $b->{startTime} }
            @{ $byUser->{$user} } )
        {
            $res .=
"<li id=\"ip$session->{id}\"><span onclick=\"displaySession('$session->{id}');\">"
              . $self->_stToStr( $session->{startTime} )
              . "</span></li>";
        }
        $res .= "</ul></li>";
    }
    return $res;
}

## @method protected string uid()
# Build single UID tree part
# @return string XML tree
sub uid {
    my ( $self, $uid ) = splice @_;
    my ( $byRef, $res );

    # Parse all notifications
    my $n = $self->{notifObject}->getAll();

    foreach ( keys %$n ) {
        if ( $n->{$_}->{uid} eq $uid ) {
            push @$byRef, $n->{$_}->{ref};
        }
    }

    foreach my $ref ( sort @$byRef ) {
        $res .=
"<li class=\"open\" id=\"uid$ref\"><span onclick=\"displayNotification('${uid}_$ref');\">$ref</span></li>";
    }
    return $res;
}

# Ajax request to list users starting by a letter
## @method protected string letter()
# Build letter XML part
# @return string XML tree
sub letter {
    my $self   = shift;
    my $letter = $self->param('letter');
    my ( $byUid, $res );

    # Parse all notifications
    my $n = $self->{notifObject}->getAll();

    foreach ( keys %$n ) {
        $n->{$_}->{uid} =~ /^$letter/ or next;
        $byUid->{ $n->{$_}->{uid} }++;
    }

    foreach my $uid ( sort keys %$byUid ) {
        $res .= $self->ajaxNode(
            $uid,
            $uid
              . (
                $byUid->{$uid} > 1
                ? " <i><u><small>($byUid->{$uid} "
                  . (
                    $byUid->{$uid} == 1
                    ? "notification"
                    : "notifications"
                  )
                  . ")</small></u></i>"
                : ''
              ),
            "uid=$uid"
        );
    }
    return $res;
}

## @method protected string p()
# Build IP classes sub tree (call _ipclasses())
# @return string XML tree
sub p {
    my $self = shift;
    my @t    = $self->_ipclasses(@_);
    return $t[0];
}

## @method private string _ipclasses()
# Build IP classes (sub) tree
# @return string XML tree
sub _ipclasses {
    my ( $self, $p ) = splice @_;
    my $partial = $p ? "$p." : '';
    my $repartial = quotemeta($partial);
    my ( $byIp, $count, $res );
    Lemonldap::NG::Common::Apache::Session->get_key_from_all_sessions(
        $self->{globalStorageOptions},
        sub {
            my $entry = shift;
            next if ( $entry->{_httpSessionType} );
            $entry->{ $self->{ipField} } =~ /^$repartial(\d+)/
              or return undef;
            $byIp->{$1}++;
            $count++;
            undef;
        }
    );

    foreach my $ip ( sort { $a <=> $b } keys %$byIp ) {
        $res .= $self->ajaxNode(
            "$partial$ip",
            "$partial$ip <i><small>($byIp->{$ip} "
              . (
                  $byIp->{$ip} == 1 ? $self->translate('session')
                : $self->translate('sessions')
              )
              . ")</small></i>",
            (
                $partial !~ /^\d+\.\d+\.\d+/ ? "ipclasses=1&p=$partial$ip"
                : "uidByIp=$partial$ip"
            )
        );
    }
    return (
        $res,
        "$count "
          . (
              $count == 1
            ? $self->translate('session')
            : $self->translate('sessions')
          )
    );

    #return $res;
}

## @fn protected string htmlquote(string s)
# Change <, > and & to HTML encoded values in the string
# @param $s HTML string
# @return HTML string
sub htmlquote {
    my $s = shift;
    $s =~ s/&/&amp;/g;
    $s =~ s/</&lt;/g;
    $s =~ s/>/&gt;/g;
    return $s;
}

## @method private void ajaxnode(string id, string text, string param)
# Display tree node with Ajax functions inside for opening the node.
# @param $id HTML id of the element.
# @param $text text to display
# @param $param Parameters for the Ajax query
sub ajaxNode {
    my ( $self, $id, $text, $param ) = @_;
    return
"<li id=\"$id\"><span>$text</span>\n<ul class=\"ajax\"><li id=\"sub_$id\">{url:$ENV{SCRIPT_NAME}?$param}</li></ul></li>\n";
}

## @method private string _stToStr(string)
# Transform a utime string into readeable string (ex: "2010-08-18 13:03:13")
# @return Formated string
sub _stToStr {
    shift;
    return
      sprintf( '%d-%02d-%02d %d:%02d:%02d', unpack( 'a4a2a2a2a2a2', shift ) );
}

1;
__END__

=head1 NAME

Lemonldap::NG::Manager::Notifications - Perl extension to manage Lemonldap::NG
notifications

=head1 SYNOPSIS

  #!/usr/bin/perl

  use strict;
  use Lemonldap::NG::Manager::Notificationss;
  our $cgi ||= Lemonldap::NG::Manager::Notifications->new({
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
        # Force the use of X-FORWARDED-FOR for IP
        useXForwardedForIP => 1,
        # Optionnal
        protection    => 'rule: $uid eq "admin"',
        # Or to use rules from manager
        protection    => 'manager',
	# Or just to authenticate without managing authorization
	protection    => 'authenticate',
  });
  $cgi->process();

=head1 DESCRIPTION

Lemonldap::NG::Manager::Notifications provides a web interface to manage
Lemonldap::NG notifications.

It inherits from L<Lemonldap::NG::Handler::CGI>, so see this manpage to
understand how arguments passed to the constructor.

=head1 SEE ALSO

L<Lemonldap::NG::Handler::CGI>, L<Lemonldap::NG::Manager>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>
Clement Oudot, E<ltclem.oudot@gmail.com>E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Xavier Guimard, Clement Oudot

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
