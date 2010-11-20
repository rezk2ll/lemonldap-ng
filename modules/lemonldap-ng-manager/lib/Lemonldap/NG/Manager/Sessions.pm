## @file
# Session explorer

## @class
# Session explorer.
# Synopsis:
#  * build a new Lemonldap::NG::Manager::Sessions object
#  * insert tree() result in HTML
#
# tree() loads on of the tree methods.
# new() manage ajax requests (inserted in HTML tree)
package Lemonldap::NG::Manager::Sessions;

use strict;
use Lemonldap::NG::Handler::CGI qw(:globalStorage :locationRules);
use Lemonldap::NG::Common::Apache::Session;   #inherits
use Lemonldap::NG::Common::Conf;              #link protected conf Configuration
use Lemonldap::NG::Common::Conf::Constants;   #inherits
require Lemonldap::NG::Manager::_i18n;        #inherits
use utf8;

#inherits Apache::Session

our $whatToTrace;
*whatToTrace = \$Lemonldap::NG::Handler::_CGI::whatToTrace;

our $VERSION = '1.0.0';

our @ISA = qw(
  Lemonldap::NG::Handler::CGI
  Lemonldap::NG::Manager::_i18n
);

## @cmethod Lemonldap::NG::Manager::Sessions new(hashRef args)
# Constructor.
# @param $args Arguments for Lemonldap::NG::Handler::CGI::new()
# @return New Lemonldap::NG::Manager::Sessions object
sub new {
    my ( $class, $args ) = @_;
    my $self = $class->SUPER::new($args)
      or $class->abort( 'Unable to start ' . __PACKAGE__,
        'See Apache logs for more' );

    # Output UTF-8
    binmode( STDOUT, ':utf8' );

    # Try to get configuration values from global configuration
    my $config = Lemonldap::NG::Common::Conf->new( $self->{configStorage} );
    unless ($config) {
        $self->abort( "Unable to start",
            "Configuration not loaded\n" . $Lemonldap::NG::Common::Conf::msg );
    }

    # Load parameters from lemonldap-ng.ini.
    my $localconf = $config->getLocalConf(MANAGERSECTION);

    # Local args prepends global args
    if ($localconf) {
        $self->{$_} = $args->{$_} || $localconf->{$_}
          foreach ( keys %$localconf );
    }

    # Load default skin if no other specified
    $self->{managerSkin} ||= 'default';

    # Now try to load Apache::Session module
    unless ( $globalStorage->can('populate') ) {
        eval "require $globalStorage";
        $class->abort( "Unable to load $globalStorage", $@ ) if ($@);
    }
    %{ $self->{globalStorageOptions} } = %$globalStorageOptions;
    $self->{globalStorageOptions}->{backend} = $globalStorage;

    # Check if we use X-FORWARDED-FOR header for IP
    $self->{ipField} =
      $self->{useXForwardedForIP} ? "xForwardedForAddr" : "ipAddr";

    # Multi values separator
    $self->{multiValuesSeparator} ||= '; ';

    # Now we're ready to display sessions. Choose display type
    foreach my $k ( $self->param() ) {

        # Case ajax request : execute corresponding sub and quit
        if ( grep { $_ eq $k } qw(delete session id uidByIp uid letter p) ) {
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

    # Parse all sessions to store first letter
    Lemonldap::NG::Common::Apache::Session->get_key_from_all_sessions(
        $self->{globalStorageOptions},
        sub {
            my $entry = shift;
            next if ( $entry->{_httpSessionType} );
            $entry->{$whatToTrace} =~ /^(\w)/ or return undef;
            $byUid->{$1}++;
            $count++;
            undef;
        }
    );

    # Build tree sorted by first letter
    foreach my $letter ( sort keys %$byUid ) {
        $res .= $self->ajaxNode(

            # ID
            "li_$letter",

            # Legend
            "$letter <i><small>($byUid->{$letter} "
              . (
                  $byUid->{$letter} == 1
                ? $self->translate('session')
                : $self->translate('sessions')
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
            ? $self->translate('session')
            : $self->translate('sessions')
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
    my ( %h, $res );

    # Try to read session
    eval { tie %h, $globalStorage, $id, $globalStorageOptions; };
    if ($@) {
        if ( $@ =~ /does not exist in the data store/i ) {
            $self->lmLog( "Apache::Session error: $@", 'error' );
            $res .= '<h1 class="ui-widget-header ui-corner-all">'
              . $self->translate('error') . '</h1>';
            $res .= '<div class="ui-corner-all ui-widget-content">';
            $res .= "Apache::Session error: $@";
            $res .= '</div>';
            return $res;
        }
        else {
            $self->abort("Apache::Session error: $@");
        }
    }
    else {
        if ( $h{_httpSession} ) {
            my %h2;
            eval {
                tie %h2, $globalStorage, $h{_httpSession},
                  $globalStorageOptions;
                tied(%h2)->delete();
            };
            if ($@) {
                $self->lmLog( "Apache::Session error: $@", 'error' );
                $res .= '<h1 class="ui-widget-header ui-corner-all">'
                  . $self->translate('error') . '</h1>';
                $res .= '<div class="ui-corner-all ui-widget-content">';
                $res .= "Apache::Session error: $@";
                $res .= '</div>';
                return $res;
            }
        }
        eval { tied(%h)->delete(); };
        if ($@) {
            $self->abort( 'Apache::Session error', $@ );
        }
        else {
            $self->lmLog( "Session $id deleted", 'info' );
            $res .= '<h1 class="ui-widget-header ui-corner-all">'
              . $self->translate('sessionDeleted') . '</h1>';
            return $res;
        }
    }
}

## @method protected string session()
# Build session dump.
# @return string XML tree
sub session {
    my ( $self, $id ) = splice @_;
    my ( %h, $res );

    # Try to read session
    eval { tie %h, $globalStorage, $id, $globalStorageOptions; };
    if ($@) {
        $self->lmLog( "Apache::Session error: $@", 'error' );
        $res .= '<h1 class="ui-widget-header ui-corner-all">'
          . $self->translate('error') . '</h1>';
        $res .= '<div class="ui-corner-all ui-widget-content">';
        $res .= "Apache::Session error: $@";
        $res .= '</div>';
        return $res;
    }

    # Session is avalaible, print content
    my %session = %h;
    untie %h;

    # General informations

    $res .= '<h1 class="ui-widget-header ui-corner-all">';
    $res .= $self->translate('sessionTitle');
    $res .= '</h1>';

    $res .=
        "<p><strong>"
      . $self->translate('sessionStartedAt')
      . ":</strong> "
      . $self->_stToStr( $session{startTime} ) . "</p>";

    # Transform values
    # -> split multiple values
    # -> decode UTF8
    # -> Manage dates
    # -> Hide password
    # -> quote HTML
    foreach ( keys %session ) {

        # Remove empty value
        delete $session{$_} unless ( length $session{$_} );

        # Quote HTML
        my $value = htmlquote( $session{$_} );

        # Values in sessions are UTF8
        utf8::decode($value);

        # Multiple values
        if ( $value =~ m/$self->{multiValuesSeparator}/ ) {
            my $newvalue = '<ul>';
            $newvalue .= "<li>$_</li>"
              foreach ( split( $self->{multiValuesSeparator}, $value ) );
            $newvalue .= '</ul>';
            $value = $newvalue;
        }

        # Hide password
        $value = '******' if ( $_ =~ /^_password$/ );

        # Manage timestamp
        if ( $_ =~ /^(_utime|_lastAuthnUTime)$/ ) {
            $value = "$value (" . localtime($value) . ")";
        }

        # Manage dates
        if ( $_ =~ /^(startTime|updateTime)$/ ) {
            $value = "$value (" . $self->_stToStr($value) . ")";
        }

        # Register value
        $session{$_} = $value;
    }

    # Map attributes to categories
    my $categories = {
        'dateTitle'       => [qw(_utime startTime updateTime _lastAuthnUTime)],
        'connectionTitle' => [qw(ipAddr xForwardedForAddr _timezone)],
        'authenticationTitle' =>
          [qw(_session_id _user _password authenticationLevel)],
        'modulesTitle' => [qw(_auth _userDB _passwordDB _issuerDB _authChoice)],
        'saml'         => [
            qw(_idp _idpConfKey _samlToken _lassoSessionDump _lassoIdentityDump)
        ],
        'groups' => [qw(groups)],
        'ldap'   => [qw(dn)],
    };

    # Display categories
    foreach my $category ( keys %$categories ) {

        # Test if category is not empty
        my $empty = 1;
        foreach ( @{ $categories->{$category} } ) {
            $empty = 0 if exists $session{$_};
        }
        next if ($empty);

        # Display category
        $res .= '<div class="ui-corner-all ui-widget-content category">';
        $res .= '<h2 class="ui-corner-all ui-widget-header">'
          . $self->translate($category) . '</h2>';
        $res .= '<ul>';

        foreach my $attribute ( @{ $categories->{$category} } ) {

            # Hide empty attributes
            next unless exists $session{$attribute};

            # Display attribute
            $res .=
                '<li><strong>'
              . $self->translate($attribute)
              . '</strong> (<tt>$'
              . $attribute
              . '</tt>): '
              . $session{$attribute} . '</li>';

            # Delete attribute, to hide it
            delete $session{$attribute};
        }
        $res .= '</ul>';
        $res .= '</div>';
    }

    # OpenID
    my $openidempty = 1;
    foreach ( keys %session ) {
        $openidempty = 0 if $_ =~ /^_openid/;
    }
    unless ($openidempty) {
        $res .= '<div class="ui-corner-all ui-widget-content category">';
        $res .=
          '<h2 class="ui-corner-all ui-widget-header">' . 'OpenID' . '</h2>';
        $res .= '<ul>';

        foreach ( keys %session ) {
            next if $_ !~ /^_openid/;
            $res .=
              '<li><strong>' . $_ . '</strong>: ' . $session{$_} . '</li>';

            # Delete attribute, to hide it
            delete $session{$_};
        }

        $res .= '</ul>';
        $res .= '</div>';
    }

    # Other attributes
    $res .= '<div class="ui-corner-all ui-widget-content category">';
    $res .= '<h2 class="ui-corner-all ui-widget-header">'
      . $self->translate('attributesAndMacros') . '</h2>';
    $res .= '<ul>';

    foreach my $attribute (
        sort {
            return $a cmp $b
              if ( ( $a =~ /^_/ and $b =~ /^_/ )
                or ( $a !~ /^_/ and $b !~ /^_/ ) );
            return $b cmp $a
        } keys %session
      )
    {

        # Display attribute
        $res .=
            '<li><strong>'
          . $attribute
          . '</strong>: '
          . $session{$attribute} . '</li>';
    }

    $res .= '</ul>';
    $res .= '</div>';

    # Delete button
    $res .= '<div style="text-align:center">';
    $res .=
        "<input type=\"button\" onclick=\"del('$id');\""
      . ' class="ui-state-default ui-corner-all"'
      . " value=\""
      . $self->translate('deleteSession') . "\" />";
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
    my ( $byIp, $res );
    Lemonldap::NG::Common::Apache::Session->get_key_from_all_sessions(
        $self->{globalStorageOptions},
        sub {
            my $entry = shift;
            my $id    = shift;
            next if ( $entry->{_httpSessionType} );
            if ( $entry->{$whatToTrace} eq $uid ) {
                push @{ $byIp->{ $entry->{ $self->{ipField} } } },
                  { id => $id, startTime => $entry->{startTime} };
            }
            undef;
        }
    );
    foreach my $ip ( sort keys %$byIp ) {
        $res .= "<li class=\"open\" id=\"uid$ip\"><span>$ip</span><ul>";
        foreach my $session ( sort { $a->{startTime} <=> $b->{startTime} }
            @{ $byIp->{$ip} } )
        {
            $res .=
"<li id=\"uid$session->{id}\"><span onclick=\"displaySession('$session->{id}');\">"
              . $self->_stToStr( $session->{startTime} )
              . "</span></li>";
        }
        $res .= "</ul></li>";
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
    Lemonldap::NG::Common::Apache::Session->get_key_from_all_sessions(
        $self->{globalStorageOptions},
        sub {
            my $entry = shift;
            next if ( $entry->{_httpSessionType} );
            $entry->{$whatToTrace} =~ /^$letter/ or return undef;
            $byUid->{ $entry->{$whatToTrace} }++;
        },
    );
    foreach my $uid ( sort keys %$byUid ) {
        $res .= $self->ajaxNode(
            $uid,
            $uid
              . (
                $byUid->{$uid} > 1
                ? " <i><u><small>($byUid->{$uid} "
                  . (
                      $byUid->{$uid} == 1
                    ? $self->translate('session')
                    : $self->translate('sessions')
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

Lemonldap::NG::Manager::Sessions provides a web interface to manage
Lemonldap::NG sessions.

It inherits from L<Lemonldap::NG::Handler::CGI>, so see this manpage to
understand how arguments passed to the constructor.

=head1 SEE ALSO

L<Lemonldap::NG::Handler::CGI>, L<Lemonldap::NG::Manager>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008, 2010 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
