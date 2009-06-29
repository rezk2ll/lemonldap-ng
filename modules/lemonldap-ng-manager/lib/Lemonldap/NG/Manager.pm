## @file
# Lemonldap::NG Management interface

## @class
# Lemonldap::NG Management interface
package Lemonldap::NG::Manager;

use strict;

use XML::Simple;

use Lemonldap::NG::Common::CGI;
use Lemonldap::NG::Common::Conf; #link protected conf Configuration
use Lemonldap::NG::Manager::_HTML; #inherits
require Lemonldap::NG::Manager::_Response; #inherits
require Lemonldap::NG::Manager::_i18n; #inherits
require Lemonldap::NG::Manager::Help; #inherits
use Lemonldap::NG::Common::Conf::Constants; #inherits
use Lemonldap::NG::Common::Safelib;           #link protected safe Safe object
use LWP::UserAgent;
use Safe;
use MIME::Base64;

#inherits Lemonldap::NG::Handler::CGI

use base qw(Lemonldap::NG::Common::CGI);
our @ISA;

our $VERSION = '0.9';

# Secure jail
our $safe;

##@method private object safe()
# Provide the security jail.
#@return Safe object
sub safe {
    my $self = shift;
    return $safe if ($safe);
    $safe = new Safe;
    my @t =
      $self->{customFunctions} ? split( /\s+/, $self->{customFunctions} ) : ();
    foreach (@t) {
        s/^.*:://;
        next if ( $self->can($_) );
        eval "sub $_ {1}";
        $self->lmLog( $@, 'error' ) if ($@);
    }
    $safe->share_from( 'main', ['%ENV'] );
    $safe->share_from( 'Lemonldap::NG::Common::Safelib',
        $Lemonldap::NG::Common::Safelib::functions );
    $safe->share( '&encode_base64', @t );
    return $safe;
}

## @cmethod Lemonldap::NG::Manager new(hashref args)
# Constructor.
# @param $args hash reference containing parameters
sub new {
    my ( $class, $args ) = @_;
    my $self;
    if ( $args->{protection} ) {
        require Lemonldap::NG::Handler::CGI;
        unshift @ISA, "Lemonldap::NG::Handler::CGI";
        $self = $class->SUPER::new($args);
    }
    else {
        $self = $class->SUPER::new();
    }
    unless ($args) {
        $self->abort( "Unable to start",
            "parameters are required, I can't start so" );
    }
    %$self = ( %$self, %$args );
    foreach (qw(dhtmlXTreeImageLocation)) {
        unless ( $self->{$_} ) {
            $self->abort( "Unable to start",
                qq/The "$_" parameter is required/ );
        }
    }
    $self->{jsFile} ||= $self->_dir . "lemonldap-ng-manager.js";
    unless ( -r $self->{jsFile} ) {
        $self->abort(
qq#Unable to read $self->{jsFile}. You have to set "jsFile" parameter to /path/to/lemonldap-ng-manager.js#
        );
    }
    $self->{pageTitle} ||= "LemonLDAP::NG Administration";
    $self->{textareaW} ||= 50;
    $self->{textareaH} ||= 5;
    $self->{inputSize} ||= 30;
    unless ( __PACKAGE__->can('ldapServer') ) {
        Lemonldap::NG::Manager::_i18n::import( $self->{language}
              || $ENV{HTTP_ACCEPT_LANGUAGE} );
    }
    if ( $self->param('lmQuery') ) {
        my $tmp = "print_" . $self->param('lmQuery');
        $self->$tmp;
    }
    else {
        my $datas;
        if ( $datas = $self->param('POSTDATA') ) {
            $self->print_upload( \$datas );
        }
        else {
            return $self;
        }
    }
    exit;
}

## @method void doall()
# Launch :
# - Lemonldap::NG::Manager::_HTML::start_html()
# - Lemonldap::NG::Manager::_HTML::main()
# - CGI::end_html()
sub doall {
    my $self = shift;

    print $self->header( -type => 'text/html; charset=utf8' );

    # Test if we have to use specific CSS
    if ( defined $self->{cssFile} ) {
        print $self->start_html(
            -style => $self->{cssFile},
            -title => $self->{pageTitle},
        );
    }
    else {
        print $self->start_html( -title => $self->{pageTitle}, );
    }
    print $self->main;
    print $self->end_html;
}

## @method void print_css()
# Print HTTP headers using header_public() and call
# Lemonldap::NG::Manager::_HTML::css()
sub print_css {
    my $self = shift;
    print $self->header_public( $ENV{SCRIPT_FILENAME}, -type => 'text/css' );
    $self->css;
}

## @method void print_libjs()
# Print HTTP headers using header_public() and display $self->{jsFile}
# javascript file.
sub print_libjs {
    my $self = shift;
    print $self->header_public( $self->{jsFile},
        -type => 'application/x-javascript' );
    open F, $self->{jsFile};
    while (<F>) {
        print;
    }
    close F;
}

## @method void print_lmjs()
# Print HTTP headers using header_public() and call
# Lemonldap::NG::Manager::_HTML::javascript()
sub print_lmjs {
    my $self = shift;
    print $self->header_public( $ENV{SCRIPT_FILENAME},
        -type => 'text/javascript; charset=utf8' );
    $self->javascript;
}

## @method void print_help()
# AJAX method that display help chapter.
# Print HTTP headers using header_public() and display asked help chapter.
sub print_help {
    my $self = shift;
    print $self->header_public( $ENV{SCRIPT_FILENAME},
        -type => 'text/html; charset=utf8' );
    Lemonldap::NG::Manager::Help::import( $self->{language}
          || $ENV{HTTP_ACCEPT_LANGUAGE} )
      unless ( $self->can('help_groups') );
    my $chap = $self->param('help');
    eval { no strict "refs"; &{"help_$chap"} };
}

## @method void print_delete()
# Print HTTP headers and call Lemonldap::NG::Common::Conf::delete()
sub print_delete {
    my $self = shift;
    print $self->header( -type => 'text/html; charset=utf8' );
    Lemonldap::NG::Manager::Help::import( $self->{language}
          || $ENV{HTTP_ACCEPT_LANGUAGE} )
      unless ( $self->can('help_groups') );
    if ( $self->config->delete( $self->param('cfgNum') ) ) {
        print &txt_configurationDeleted;
    }
    else {
        print &txt_configurationNotDeleted;
    }
    exit;
}

## @method void print_conf()
# Print HTTP headers using header_public() and call printXmlConf()
sub print_conf {
    my $self = shift;
    print $self->header(
        -type            => "text/xml; charset=utf8",
        '-Cache-Control' => 'private'
    );
    $self->printXmlConf( { cfgNum => $self->param('cfgNum'), noCache => 1 } );
    exit;
}

## @fn protected hashref default()
# Build a minimum configuration if no configuration is available.
# @return Lemonldap::NG configuration hash reference.
sub default {
    return {
        cfgNum   => 0,
        ldapBase => "dc=example,dc=com",
    };
}

## @method protected string printXmlConf(array p)
# Call buildTree() then XML::Simple::XMLout to build the XML datas used by
# javascript library to display the tree.
# @param @p parameters given to buildTree()
# @return XML string
sub printXmlConf {
    my $self = shift;
    print XMLout(
        $self->buildTree(@_),

        #XMLDecl  => "<?xml version='1.0' encoding='iso-8859-1'?>",
        RootName => 'tree',
        KeyAttr  => { item => 'id', username => 'name' },
        NoIndent => 1,
        NoSort   => 0,
        XMLDecl  => '<?xml version="1.0" encoding="UTF-8"?>',
    );
}

## @method protected hashRef buildTree(array p)
# Transform Lemonldap::NG configuration into a tree that javascript library can
# understand.
# @param @p parameters given to Lemonldap::NG::Common::Conf::getConf()
# @return hash reference to the javascript tree structure
sub buildTree {
    my $self   = shift;
    my $config = $self->config->getConf(@_);
    $config = $self->default unless ( $config and $config->{cfgNum} );
    my $indice = 1;
    my $tree   = {
        id   => '0',
        item => {
            id   => 'root',
            open => 1,
            text => &txt_configuration . " $config->{cfgNum}",
            item => {
                generalParameters => {
                    text => &txt_generalParameters,
                    item => {
                        exportedVars => {
                            text => &txt_exportedVars,
                            item => {},
                        },
                        macros         => { text => &txt_macros, },
                        ldapParameters => {
                            text => &txt_ldapParameters,
                            item => {},
                        },
                        sessionStorage => {
                            text => &txt_sessionStorage,
                            item => {
                                globalStorageOptions =>
                                  { text => &txt_globalStorageOptions, }
                            },
                        },
                        authParams => {
                            text => &txt_authParams,
                            item => {},
                        },
                    },
                },
                groups       => { text => &txt_userGroups, },
                virtualHosts => {
                    text   => &txt_virtualHosts,
                    open   => 1,
                    select => 1,
                },
            },
        },
    };
    my $generalParameters = $tree->{item}->{item}->{generalParameters}->{item};
    my $exportedVars =
      $tree->{item}->{item}->{generalParameters}->{item}->{exportedVars}
      ->{item};
    my $ldapParameters =
      $tree->{item}->{item}->{generalParameters}->{item}->{ldapParameters}
      ->{item};
    my $sessionStorage =
      $tree->{item}->{item}->{generalParameters}->{item}->{sessionStorage}
      ->{item};
    my $globalStorageOptions =
      $tree->{item}->{item}->{generalParameters}->{item}->{sessionStorage}
      ->{item}->{globalStorageOptions}->{item};
    my $authParams =
      $tree->{item}->{item}->{generalParameters}->{item}->{authParams}->{item};
    $authParams->{authentication} =
      $self->xmlField( "value", $config->{authentication} || 'ldap',
        &txt_authenticationType, );
    $authParams->{portal} =
      $self->xmlField( "value", $config->{portal} || 'http://portal/',
        &txt_portal );
    $authParams->{securedCookie} =
      $self->xmlField( "value", $config->{securedCookie} || 0,
        &txt_securedCookie );
    $generalParameters->{whatToTrace} =
      $self->xmlField( "value", $config->{whatToTrace} || '$uid',
        &txt_whatToTrace );

    $generalParameters->{domain} =
      $self->xmlField( "value", $config->{domain} || 'example.com', &txt_domain,
      );
    $generalParameters->{cookieName} =
      $self->xmlField( "value", $config->{cookieName} || 'lemonldap',
        &txt_cookieName, );
    $generalParameters->{timeout} =
      $self->xmlField( "value", $config->{timeout} || 7200,
        &txt_sessionTimeout, );

    $sessionStorage->{globalStorage} =
      $self->xmlField( "value",
        $config->{globalStorage} || 'Apache::Session::File',
        &txt_apacheSessionModule, );

    $ldapParameters->{ldapServer} =
      $self->xmlField( "value", $config->{ldapServer} || 'localhost',
        &txt_ldapServer, );
    $ldapParameters->{ldapPort} =
      $self->xmlField( "value", $config->{ldapPort} || 389, &txt_ldapPort, );
    $ldapParameters->{ldapBase} =
      $self->xmlField( "value", $config->{ldapBase} || ' ', &txt_ldapBase, );
    $ldapParameters->{managerDn} =
      $self->xmlField( "value", $config->{managerDn} || ' ', &txt_managerDn, );
    $ldapParameters->{managerPassword} =
      $self->xmlField( "value", $config->{managerPassword} || ' ',
        &txt_managerPassword, );

    if ( $config->{exportedVars} ) {
        foreach my $n ( sort keys %{ $config->{exportedVars} } ) {
            $exportedVars->{ sprintf( "ev_%010d", $indice ) } =
              $self->xmlField( "both", $config->{exportedVars}->{$n}, $n );
            $indice++;
        }
    }
    else {
        foreach (qw(cn mail uid)) {
            $exportedVars->{ sprintf( "ev_%010d", $indice ) } =
              $self->xmlField( 'both', $_, $_ );
            $indice++;
        }
    }

    if ( $config->{globalStorageOptions}
        and %{ $config->{globalStorageOptions} } )
    {
        $tree->{item}->{item}->{generalParameters}->{item}->{sessionStorage}
          ->{item}->{globalStorageOptions}->{item} = {};
        $globalStorageOptions =
          $tree->{item}->{item}->{generalParameters}->{item}->{sessionStorage}
          ->{item}->{globalStorageOptions}->{item};
        foreach my $n ( sort keys %{ $config->{globalStorageOptions} } ) {
            $globalStorageOptions->{ sprintf( "go_%010d", $indice ) } =
              $self->xmlField( "both", $config->{globalStorageOptions}->{$n},
                $n );
            $indice++;
        }
    }

    if ( $config->{locationRules} and %{ $config->{locationRules} } ) {
        $tree->{item}->{item}->{virtualHosts}->{item} = {};
        my $virtualHost = $tree->{item}->{item}->{virtualHosts}->{item};

        # TODO: split locationRules into 2 arrays
        foreach my $host ( sort keys %{ $config->{locationRules} } ) {
            my $rules = $config->{locationRules}->{$host};
            my $vh_id = sprintf( "vh_%010d", $indice );
            $indice++;
            $virtualHost->{$vh_id} = $self->xmlField( "text", 'i', $host );
            my ( $ih, $ir ) =
              ( "exportedHeaders_$indice", "locationRules_$indice" );
            $virtualHost->{$vh_id}->{item} = {
                "$ih" => { text => &txt_httpHeaders, },
                "$ir" => { text => &txt_locationRules, },
            };
            foreach my $reg ( sort keys %$rules ) {
                my $type = ( $reg eq 'default' ) ? 'value' : 'both';
                $virtualHost->{$vh_id}->{item}->{$ir}->{item}
                  ->{ sprintf( "r_%010d", $indice ) } =
                  $self->xmlField( $type, $rules->{$reg}, $reg );
                $indice++;
            }
            my $headers = $config->{exportedHeaders}->{$host};
            foreach my $h ( sort keys %$headers ) {
                $virtualHost->{$vh_id}->{item}->{$ih}->{item}
                  ->{ sprintf( "h_%010d", $indice ) } =
                  $self->xmlField( "both", $headers->{$h}, $h );
                $indice++;
            }
        }
    }
    if ( $config->{groups} and %{ $config->{groups} } ) {
        $tree->{item}->{item}->{groups}->{item} = {};
        my $groups = $tree->{item}->{item}->{groups}->{item};
        foreach my $group ( sort keys %{ $config->{groups} } ) {
            $groups->{ sprintf( "g_%010d", $indice ) } =
              $self->xmlField( 'both', $config->{groups}->{$group}, $group );
            $indice++;
        }
    }
    if ( $config->{macros} and %{ $config->{macros} } ) {
        $tree->{item}->{item}->{generalParameters}->{item}->{macros}->{item} =
          {};
        my $macros =
          $tree->{item}->{item}->{generalParameters}->{item}->{macros}->{item};
        foreach my $macro ( sort keys %{ $config->{macros} } ) {
            $macros->{"m_$indice"} =
              $self->xmlField( 'both', $config->{macros}->{$macro}, $macro );
            $indice++;
        }
    }
    return $tree;
}

## @method protected hashref xmlField(string type, string value, string text)
# Little method used by buildTree to build javascript tree nodes.
# @param $type type of field (key and value can be both modified or not)
# @param $value value of the node
# @param $text text to display for the node
sub xmlField {
    my ( $self, $type, $value, $text ) = @_;
    $value =~ s/"/\&#34;/g;
    $text  =~ s/"/\&#34;/g;
    return {
        text     => $text,
        aCol     => "#000000",
        sCol     => "#0000FF",
        userdata => [
            { name => 'value', content => $value },
            { name => 'modif', content => $type },
        ],
    };
}

# Upload subroutines
## @method void print_upload(string datas)
# Print HTTP headers, and call upload() to store the new configuration.
# Then call Lemonldap::NG::Manager::_Response::send() to display the response
# @param $datas new configuration in javascript XML format
sub print_upload {
    my $self  = shift;
    my $datas = shift;
    print $self->header( -type => "text/javascript; charset=utf8" );
    my $r = Lemonldap::NG::Manager::_Response->new();
    my $tmp = $self->upload( $datas, $r );
    if ( $tmp == 0 ) {
        $r->message( &txt_unknownError, &txt_checkLogs );
    }
    elsif ( $tmp > 0 ) {
        $r->setConfiguration($tmp);
        $r->message( &txt_confSaved . " $tmp", &txt_warningConfNotApplied );
    }
    elsif ( $tmp == CONFIG_WAS_CHANGED ) {
        $r->message( &txt_saveFailure, &txt_configurationWasChanged );
    }
    elsif ( $tmp == SYNTAX_ERROR ) {
        $r->message( &txt_saveFailure, &txt_syntaxError );
    }
    $r->send;
}

## @method protected int upload(string tree, Lemonldap::NG::Manager::_Response response)
# Transform $tree in a hash reference using tree2conf(), verify it using
# checkConf() then save configuration using saveConf()
# @param $tree configuration in XML format
# @param $response response object
# @return error code
sub upload {
    my ( $self, $tree, $response ) = @_;
    my $config   = $self->tree2conf( $tree, $response );
    return SYNTAX_ERROR unless ( $self->checkConf( $config, $response ) );
    return $self->config->saveConf($config);
}

## @method protected hashref tree2conf(string tree, Lemonldap::NG::Manager::_Response response)
# Transform $tree into a Lemonldap::NG configuration hash reference.
# @param $tree configuration in XML format
# @param $response response object
# @return $tree transformed in hash reference
sub tree2conf {
    my ( $self, $tree, $response ) = @_;
    $tree = XMLin($$tree);
    my $config = {};

    # Load config number
    ( $config->{cfgNum} ) = ( $tree->{text} =~ /(\d+)$/ );

    # Load groups
    while ( my ( $g, $h ) = each( %{ $tree->{groups} } ) ) {
        next unless ( ref($h) );
        $config->{groups}->{ $h->{text} } = $h->{value};
    }

    # Load virtualHosts
    while ( my ( $k, $h ) = each( %{ $tree->{virtualHosts} } ) ) {
        next unless ( ref($h) );
        my $lr;
        my $eh;
        foreach ( keys(%$h) ) {
            $lr = $h->{$_} if ( $_ =~ /locationRules/ );
            $eh = $h->{$_} if ( $_ =~ /exportedHeaders/ );
        }
        my $vh = $h->{text};

        # TODO: split locationRules into 2 arrays
      LR: foreach my $r ( values(%$lr) ) {
            next LR unless ( ref($r) );
            $config->{locationRules}->{$vh}->{ $r->{text} } = $r->{value};
        }
      EH: foreach my $h ( values(%$eh) ) {
            next EH unless ( ref($h) );
            $config->{exportedHeaders}->{$vh}->{ $h->{text} } = $h->{value};
        }
    }

    # General parameters
    $config->{cookieName}  = $tree->{generalParameters}->{cookieName}->{value};
    $config->{timeout}     = $tree->{generalParameters}->{timeout}->{value};
    $config->{whatToTrace} = $tree->{generalParameters}->{whatToTrace}->{value};
    $config->{domain}      = $tree->{generalParameters}->{domain}->{value};
    $config->{globalStorage} =
      $tree->{generalParameters}->{sessionStorage}->{globalStorage}->{value};
    while (
        my ( $v, $h ) = each(
            %{
                $tree->{generalParameters}->{sessionStorage}
                  ->{globalStorageOptions}
              }
        )
      )
    {
        next unless ( ref($h) );
        $config->{globalStorageOptions}->{ $h->{text} } = $h->{value};
    }
    while ( my ( $v, $h ) = each( %{ $tree->{generalParameters}->{macros} } ) )
    {
        next unless ( ref($h) );
        $config->{macros}->{ $h->{text} } = $h->{value};
    }
    foreach (qw(ldapBase ldapPort ldapServer managerDn managerPassword)) {
        $config->{$_} =
          $tree->{generalParameters}->{ldapParameters}->{$_}->{value};
        $config->{$_} = '' if ( ref( $config->{$_} ) );
        $config->{$_} =~ s/^\s*(.*?)\s*/$1/;
    }
    foreach (qw(authentication portal securedCookie)) {
        $config->{$_} = $tree->{generalParameters}->{authParams}->{$_}->{value};
        $config->{$_} = '' if ( ref( $config->{$_} ) );
        $config->{$_} =~ s/^\s*(.*?)\s*/$1/;
    }
    while ( my ( $v, $h ) =
        each( %{ $tree->{generalParameters}->{exportedVars} } ) )
    {
        next unless ( ref($h) );
        $config->{exportedVars}->{ $h->{text} } = $h->{value};
    }
    return $config;
}

## @method protected boolean checkConf(hashref config,Lemonldap::NG::Manager::_Response response)
# Try to find faults in new uploaded configuration.
# @param $config Lemonldap::NG configuration hash reference
# @param $response response object
sub checkConf {
    my $self     = shift;
    my $config   = shift;
    my $response = shift;
    my $expr     = '';
    my $result   = 1;
    my $assign   = qr/(?<=[^=<!>\?])=(?![=~])/;

    # Check cookie name
    unless ( $config->{cookieName} =~ /^[a-zA-Z]\w*$/ ) {
        $result = 0;
        $response->error(
            '"' . $config->{cookieName} . '" ' . &txt_isNotAValidCookieName );
    }

    # Check session timeout
    unless ( $config->{timeout} =~ /^\d+$/ ) {
        $result = 0;
        $response->error( '"' . $config->{timeout} . '" ' . &txt_isNotANumber );
    }

    # Check domain name
    unless ( $config->{domain} =~
        /^(?=^.{1,254}$)\.?(?:(?!\d+\.)[\w\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$/ )
    {
        $result = 0;
        $response->error(
            '"' . $config->{domain} . '" ' . &txt_isNotAValidCookieName );
    }

    # Customized variables
    foreach ( @{ $self->{customVars} } ) {
        $expr .= "my \$$_ = '1';";
    }

    # Load variables
    foreach ( keys %{ $config->{exportedVars} } ) {

        # Reserved words
        if ( $_ eq 'groups' or $_ !~ /^\w+$/ ) {
            $response->error( "\"$_\" " . &txt_isNotAValidAttributeName );
            $result = 0;
        }
        if ( $config->{exportedVars}->{$_} !~ /^\w+$/ ) {
            $response->error( "\"$config->{exportedVars}->{$_}\" "
                  . &txt_isNotAValidLDAPAttributeName );
            $result = 0;
        }
        $expr .= "my \$$_ = '1';";
    }

    # Load and check macros
    $self->safe->reval($expr);
    if ($@) {
        $result = 0;
        $response->error( &txt_unknownErrorInVars . " ($@)" );
    }
    while ( my ( $k, $v ) = each( %{ $config->{macros} } ) ) {

        # Syntax
        if ( $k eq 'groups' or $k !~ /^[a-zA-Z]\w*$/ ) {
            $response->error( "\"$k\" " . &txt_isNotAValidMacroName );
            $result = 0;
        }

        # "=" may be a fault ("==")
        if ( $v =~ $assign ) {
            $response->warning(
                &txt_macro . " $k " . &txt_containsAnAssignment );
        }

        # Test macro values;
        $expr .= "my \$$k = $v;";
        $self->safe->reval($expr);
        if ($@) {
            $response->error(
                &txt_macro . " $k : " . &txt_syntaxError . " : $@" );
            $result = 0;
        }
    }

    # TODO: check module name
    # Check whatToTrace
    unless ( $config->{whatToTrace} =~ /^\$?[a-zA-Z]\w*$/ ) {
        $response->error(&txt_invalidWhatToTrace);
        $result = 0;
    }

    # Test groups
    $expr .= 'my $groups;';
    while ( my ( $k, $v ) = each( %{ $config->{groups} } ) ) {

        # Name syntax
        if ( $k !~ /^[\w-]+$/ ) {
            $response->error( "\"$k\" " . &txt_isNotAValidGroupName );
            $result = 0;
        }

        # "=" may be a fault (but not "==")
        if ( $v =~ $assign ) {
            $response->warning(
                &txt_group . " $k " . &txt_containsAnAssignment );
        }

        # Test boolean expression
        $self->safe->reval( $expr . "\$groups = '$k' if($v);" );
        if ($@) {
            $response->error( &txt_group . " $k " . &txt_syntaxError );
            $result = 0;
        }
    }

    # Test rules
    while ( my ( $vh, $rules ) = each( %{ $config->{locationRules} } ) ) {

     # Virtual host name has to be a fully qualified name or an IP address (CDA)
        unless ( $vh =~
/^(?:(?=^.{1,254}$)(?:(?!\d+\.)[\w\-]{1,63}\.?)+(?:[a-zA-Z]{2,})|(?:\d{1,3}\.){3}\d{1,3})$/
          )
        {
            $response->error( "\"$vh\" " . &txt_isNotAValidVirtualHostName );
            $result = 0;
        }
        while ( my ( $reg, $v ) = each( %{$rules} ) ) {

            # Test regular expressions
            unless ( $reg eq 'default' ) {
                $reg =~ s/#/\\#/g;
                $self->safe->reval( $expr . "my \$r = qr#$reg#;" );
                if ($@) {
                    $response->error(
                        &txt_rule . " $vh -> \"$reg\" : " . &txt_syntaxError );
                    $result = 0;
                }
            }

            # Test boolean expressions
            unless ( $v =~ /^(?:accept$|deny$|logout)/ ) {

                # "=" may be a fault (but not "==")
                if ( $v =~ $assign ) {
                    $response->warning( &txt_rule
                          . " $vh -> \"$reg\" : "
                          . &txt_containsAnAssignment );
                }

                $self->safe->reval( $expr . "my \$r=1 if($v);" );
                if ($@) {
                    $response->error(
                        &txt_rule . " $vh -> \"$reg\" : " . &txt_syntaxError );
                    $result = 0;
                }
            }
        }
    }

    # Test exported headers
    while ( my ( $vh, $headers ) = each( %{ $config->{exportedHeaders} } ) ) {

     # Virtual host name has to be a fully qualified name or an IP address (CDA)
        unless ( $vh =~
/^(?:(?=^.{1,254}$)(?:(?!\d+\.)[\w\-]{1,63}\.?)+(?:[a-zA-Z]{2,})|(?:\d{1,3}\.){3}\d{1,3})$/
          )
        {
            $response->error( "\"$vh\" " . &txt_isNotAValidVirtualHostName );
            $result = 0;
        }
        while ( my ( $header, $v ) = each( %{$headers} ) ) {

            # Header name syntax
            unless ( $header =~ /^[\w][-\w]*$/ ) {
                $response->error(
                    "\"$header\" ($vh) " . &txt_isNotAValidHTTPHeaderName );
                $result = 0;
            }

            # "=" may be a fault ("==")
            if ( $v =~ $assign ) {
                $response->warning( &txt_header
                      . " $vh -> $header "
                      . &txt_containsAnAssignment );
            }

            # Perl expression
            $self->safe->reval( $expr . "my \$r = $v;" );
            if ($@) {
                $response->error(
                    &txt_header . " $vh -> $header " . &txt_syntaxError );
                $result = 0;
            }
        }
    }
    return $result;
}

# Apply subroutines
# TODO: Credentials in applyConfFile

## @method void print_apply()
# Call all Lemonldap::NG handlers declared in $self->{applyConfFile} file to
# ask them to reload Lemonldap::NG configuration.
sub print_apply {
    my $self = shift;
    print $self->header( -type => "text/html; charset=utf8" );
    unless ( -r $self->{applyConfFile} ) {
        print "<h3>" . &txt_canNotReadApplyConfFile . "</h3>";
        return;
    }
    print '<h3>' . &txt_result . ' : </h3><ul>';
    open F, $self->{applyConfFile};
    my $ua = new LWP::UserAgent( requests_redirectable => [] );
    $ua->timeout(10);
    while (<F>) {
        local $| = 1;

        # pass blank lines and comments
        next if ( /^$/ or /^\s*#/ );
        chomp;
        s/\r//;

        # each line must be like:
        #    host  http(s)://vhost/request/
        my ( $host, $request ) = (/^\s*([^\s]+)\s+([^\s]+)$/);
        unless ( $host and $request ) {
            print "<li> " . &txt_invalidLine . ": $_</li>";
            next;
        }
        my ( $method, $vhost, $uri ) =
          ( $request =~ /^(https?):\/\/([^\/]+)(.*)$/ );
        unless ($vhost) {
            $vhost = $host;
            $uri   = $request;
        }
        print "<li>$host ... ";
        my $r =
          HTTP::Request->new( 'GET', "$method://$host$uri",
            HTTP::Headers->new( Host => $vhost ) );
        my $response = $ua->request($r);
        if ( $response->code != 200 ) {
            print join( ' ',
                &txt_error, ":", $response->code, $response->message, "</li>" );
        }
        else {
            print "OK</li>";
        }
    }
    print "</ul><p>" . &txt_changesAppliedLater . "</p>";
}

## @fn private string _dir()
# Return the path to the manager script
sub _dir {
    my $d = $ENV{SCRIPT_FILENAME};
    $d =~ s/[^\/]*$//;
    return $d;
}

## @method Lemonldap::NG::Common::Conf config()
# Return Lemonldap::NG::Common::Conf object if exists else, build it.
# @return Lemonldap::NG::Common::Conf object
sub config {
    my $self = shift;
    return $self->{_config} if $self->{_config};
    $self->{_config} =
      Lemonldap::NG::Common::Conf->new( $self->{configStorage} );
    unless ( $self->{_config} ) {
        $self->abort( "Unable to start",
            "Configuration not loaded\n" . $Lemonldap::NG::Common::Conf::msg );
    }
    return $self->{_config};
}

# Those sub are loaded en demand. With &header_public, they are not loaded each
# time.
*css        = *Lemonldap::NG::Manager::_HTML::css;
*javascript = *Lemonldap::NG::Manager::_HTML::javascript;
*main       = *Lemonldap::NG::Manager::_HTML::main;
*start_html = *Lemonldap::NG::Manager::_HTML::start_html;

__END__

=head1 NAME

Lemonldap::NG::Manager - Perl extension for managing Lemonldap::NG Web-SSO
system.

=head1 SYNOPSIS

  use Lemonldap::NG::Manager;
  my $h=new Lemonldap::NG::Manager(
      {
        configStorage=>{
            type=>'File',
            dirName=>"/tmp/",
        },
        dhtmlXTreeImageLocation=> "/devel/img/",
        # uncomment this only if lemonldap-ng-manager.js is not in the same
        # directory than your script.
        # jsFile => /path/to/lemonldap-ng-manager.js,
      }
    ) or die "Unable to start, see Apache logs";
  # Simple
  $h->doall();

You can also peersonalize the HTML code instead of using C<doall()>:

  print $self->header_public( $ENV{SCRIPT_FILENAME} );
  print $self->start_html (  # See CGI(3) for more about start_html
        -style => "/location/to/my.css",
        -title => "Example.com SSO configuration",
        );
  # optional HTML code for the top of the page
  print "<img src=...";
  print $self->main;
  # optional HTML code for the footer of the page
  print "<img src=...";
  
  print $self->end_html;

=head1 DESCRIPTION

Lemonldap::NG::Manager provides a web interface to manage Lemonldap::NG Web-SSO
system.

=head2 SUBROUTINES

=over

=item * B<new> (constructor): new instanciates the manager object. It takes the
following arguments:

=over

=item * B<configStorage> (required): a hash reference to the description of the
configuration database system. the key 'type' must be set. Example:

  configStorage => {
      type => "DBI",
      dbiChain    => "DBI:mysql:database=session;host=1.2.3.4",
      dbiUser     => "lemonldap-ng",
      dbiPassword => "pass",
  }

See L<Lemonldap::Manager::NG::Common::Conf::File> or
L<Lemonldap::Manager::NG::Common::Conf::DBI> to know which keys are required.

=item * B<dhtmlXTreeImageLocation> (required): the location of the directory
containing dhtmlXTree images (provided in example/imgs). If this parameter
isn't correct, the tree will not appear and you will have sone error in Apache
error logs.

=item * B<jsFile> (optional): the path to the file C<lemonldap-ng-manager.js>.
It is required only if this file is not in the same directory than your script.

=item * B<applyConfFile> (optional): the path to a file containing parameters
to make configuration reloaded by handlers. See C<reload> function in
L<Lemonldap::NG::Handler>. The configuration file must contains lines like:

  # Comments if wanted
  host  http://virtual-host/reload-path

When this parameter is set, an "apply" button is added to the manager menu.

=back

=item * B<doall>: subroutine that provide headers and the full html code. Il
simply calls C<header_public>, C<start_html>, C<main> and C<end_html> in this
order.

=item * B<header>: print HTTP headers. See L<CGI> for more.

=item * B<header_public>: print HTTP headers and manage the
C<If-Modified-Since> HTTP header. If it match to the age of the file passed
in first argument, it returns C<HTTP 304 Not Modified> end exit. Else, it
calls C<header> with the other arguments. By default, all elements of the
manager use this mecanism except the configuration itself.

=item * B<start_html>: subroutine that print the HTML headers. you can add
parameters to it; example;

  print start_html(-title     => 'My SSO configuration',
                  -author     => 'fred@capricorn.org',
                  -target     => '_blank',
                  -meta       => {'keywords'=>'pharaoh secret mummy',
                  'copyright' => 'copyright 1996 King Tut'},
                  -style      => {'src'=>'/styles/style1.css'},
                  -BGCOLOR    => 'blue');

See start_html description in L<CGI> for more. Bee carefull with C<-style>
argument. You have to call it like the example above or simply like this:
  -style=> '/styles/style1.css',
All other forms will not work.

=item * B<main>: il produce the main HTML code needed to build the
configuration interface.

=item * B<end_html>: close the HTML code by writing C<'E<lt>/bodyE<gt>E<lt>/htmlE<gt>'>

=back

Other subroutines manage the produce of CSS, Javascripts and of course the
configuration tree (called with AJAX).

=head1 SEE ALSO

L<Lemonldap::NG::Handler>, L<Lemonldap::NG::Portal>, L<CGI>,
http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://forge.objectweb.org/tracker/?group_id=274>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2007 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

