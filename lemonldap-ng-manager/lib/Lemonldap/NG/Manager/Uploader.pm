## @file
# Test uploaded parameters and store new configuration

## @class
# Test uploaded parameters and store new configuration
package Lemonldap::NG::Manager::Uploader;

use strict;
use XML::LibXML;
use XML::LibXSLT;
use MIME::Base64;
use LWP::Simple;
use LWP::UserAgent;

use URI::Escape;
use Lemonldap::NG::Common::Safelib;        #link protected safe Safe object
use Lemonldap::NG::Manager::Downloader;    #inherits
use Lemonldap::NG::Manager::_Struct;       #link protected struct _Struct object
use Lemonldap::NG::Manager::_i18n;
use Lemonldap::NG::Manager::Request;
use Lemonldap::NG::Common::Conf::Constants;    #inherits

our $VERSION = '1.2.3';
our ( $stylesheet, $parser );

## @method void confUpload(ref rdata)
# Parse rdata to find parameters using XSLT, test them and tries to store the
# new configuration
# @param $rdata pointer to posted datas
sub confUpload {
    my ( $self, $rdata ) = @_;
    $$rdata =~ s/<img.*?>//g;
    $$rdata =~ s/<li class="line".*?<\/li>//g;

    # Variables to store current:
    # - Virtual host name
    # - SP and IDP name
    # - Menu category ID
    # - POST URL name
    my $vhostname;
    my $idpname;
    my $spname;
    my $catid;
    my $postname;

    # 1. ANALYSE DATAS

    # 1.1 Apply XSLT stylesheet to returned datas
    my $result =
      $self->stylesheet->transform(
        $self->parser->parse_string( '<root>' . $$rdata . '</root>' ) )
      ->documentElement();

    # 1.2 Get configuration number
    unless ( $self->{cfgNum} =
        $result->getChildrenByTagName('conf')->[0]->getAttribute('value') )
    {
        die "No configuration number found";
    }
    my $newConf = { cfgNum => $self->{cfgNum} };
    my $errors = {};

    # 1.3 Load and test returned parameters
    #     => begin loop
    foreach ( @{ $result->getChildrenByTagName('element') } ) {
        my ( $id, $name, $value ) = (
            $_->getAttribute('id'),
            $_->getAttribute('name'),
            $_->getAttribute('value')
        );

        # For menu categories and applications
        my $catflag = 0;
        my $appflag = 0;

        # For POST URL keys
        my $postflag     = 0;
        my $postdataflag = 0;

        # Unescape value
        $value = uri_unescape($value);

        $self->lmLog(
            "Upload process for attribute $name (id: $id / value: $value)",
            'debug' );

        my $NK = 0;
        $id =~
s/^text_(NewID_)?li_([\w\/\+\=]+)(\d)(?:_\d+)?$/decode_base64($2.'='x $3)/e;
        $NK = 1 if ($1);
        $id =~ s/\r//g;
        $id =~ s/^\///;

        $self->lmLog( "id decoded into $id", 'debug' );

        # Get Virtual Host name
        if ( $id =~ /locationRules\/([^\/]*)?$/ ) {
            $self->lmLog( "Entering Virtual Host $name", 'debug' );
            $vhostname = $name;
        }

        # Get SAML IDP name
        if ( $id =~ /samlIDPMetaDataExportedAttributes\/([^\/]*)?$/ ) {
            $self->lmLog( "Entering IDP $name", 'debug' );
            $idpname = $name;
        }

        # Get SAML SP name
        if ( $id =~ /samlSPMetaDataExportedAttributes\/([^\/]*)?$/ ) {
            $self->lmLog( "Entering SP $name", 'debug' );
            $spname = $name;
        }

        # Set menu category and application flags
        if ( $id =~ /applicationList/ ) {
            if ( $value =~ /^(.*)?\|(.*)?\|(.*)?\|(.*)?\|(.*?)$/ ) {
                $self->lmLog( "Entering application $name", 'debug' );
                $appflag = 1;
            }
            else {
                $self->lmLog( "Entering category $name", 'debug' );
                $catid = $name;  # Remeber category for applications coming next
                $catflag = 1;
            }
        }

        # Get POST URL name
        if ( $id =~ /post\/([^\/]*)?\/.*$/ ) {
            if ( $name =~ s/^postdata:// ) {
                $self->lmLog( "POST data $name", 'debug' );
                $postdataflag = 1;
            }
            else {
                $self->lmLog( "Entering POST URL $name", 'debug' );
                $postflag = 1;
                $postname = $name;
            }
        }

        # Manage new keys
        if ($NK) {

            # If a strange '5' appears at the end of value, remove it
            # -> javascript base64 bug?
            $id =~ s/5$//;

            # Special case: avoid bug with node created from parent node
            if ( $id =~
/^(virtualHosts|samlIDPMetaDataNode|samlSPMetaDataNode|generalParameters\/authParams\/choiceParams)/
              )
            {
                $self->lmLog( "Special trigger for $id (attribute $name)",
                    'debug' );

                # Virtual Host header
                $id =~
s/^virtualHosts\/([^\/]*)?\/header.*/exportedHeaders\/$1\/$name/;

                # Virtual Host rule
                $id =~
                  s/^virtualHosts\/([^\/]*)?\/rule.*/locationRules\/$1\/$name/;

                # Virtual Host post
                $id =~ s/^virtualHosts\/([^\/]*)?\/post.*/post\/$1\/$name/;

                # SAML IDP attribute
                $id =~
s/^samlIDPMetaDataNode\/([^\/]*)?.*/samlIDPMetaDataExportedAttributes\/$1\/$name/;

                # SAML SP attribute
                $id =~
s/^samlSPMetaDataNode\/([^\/]*)?.*/samlSPMetaDataExportedAttributes\/$1\/$name/;

                # Authentication choice
                $id =~
s/^generalParameters\/authParams\/choiceParams\/([^\/]*)?.*/authChoiceModules\/$name/;

            }

            # Do nothing for applicationList (managed at stage 1.3.2)
            elsif ( $id =~ /applicationList/ ) { $id = "applicationList"; }

            # Normal case
            else {
                $id =~ s/(?:\/[^\/]*)?$/\/$name/;
            }
        }

        # Set current Virtual Host name
        $id =~
s/^(exportedHeaders|locationRules|post)\/([^\/]*)?\/(.*)$/$1\/$vhostname\/$3/;

        # Set current SAML IDP name
        $id =~
s/^(samlIDPMetaDataXML|samlIDPMetaDataExportedAttributes|samlIDPMetaDataOptions)\/([^\/]*)?\/(.*)$/$1\/$idpname\/$3/;

        # Set current SAML SP name
        $id =~
s/^(samlSPMetaDataXML|samlSPMetaDataExportedAttributes|samlSPMetaDataOptions)\/([^\/]*)?\/(.*)$/$1\/$spname\/$3/;

        # Set current POST URL  name
        $id =~ s/^(post)\/([^\/]*)?\/(.*)$/$1\/$vhostname\/$postname/;

        $self->lmLog( "id transformed into $id", 'debug' );

        if ( $id =~
/^(generalParameters|variables|virtualHosts|samlIDPMetaDataNode|samlSPMetaDataNode)/
          )
        {
            $self->lmLog( "Ignoring attribute $name (id $id)", 'debug' );
            next;
        }

        # Get tests
        my ( $confKey, $test ) = $self->getConfTests($id);
        my ( $res, $m );

        # Set a default test if no test defined
        if ( !defined($test) ) {
            $self->lmLog(
                "No test defined for key $id (name: $name, value: $value)",
                'warn' );
            $test = { test => sub { 1 }, msgFail => 'Ok' };
        }

        if ( $test->{'*'} and $id =~ /\// ) { $test = $test->{'*'} }

        # 1.3.1 Tests:

        #     No tests for some keys
        unless ( $test->{keyTest} and ( $id !~ /\// or $test->{'*'} ) ) {

            # 1.3.1.1 Tests that return an error
            #         (parameter will not be stored in $newConf)
            if ( $test->{keyTest} ) {
                ( $res, $m ) = $self->applyTest( $test->{keyTest}, $name );
                unless ($res) {
                    $errors->{errors}->{$name} = $m || $test->{keyMsgFail};
                    next;
                }
                $errors->{warnings}->{$name} = $m if ($m);
            }
            if ( $test->{test} ) {
                ( $res, $m ) = $self->applyTest( $test->{test}, $value );
                unless ($res) {
                    $errors->{errors}->{$name} = $m || $test->{msgFail};
                    next;
                }
                $errors->{warnings}->{$name} = $m if ($m);
            }

            # 1.3.1.2 Tests that return a warning
            if ( $test->{warnKeyTest} ) {
                ( $res, $m ) = $self->applyTest( $test->{warnKeyTest}, $name );
                unless ($res) {
                    $errors->{warnings}->{$name} = $m || $test->{keyMsgWarn};
                }
            }
            if ( $test->{warnTest} ) {
                ( $res, $m ) = $self->applyTest( $test->{warnTest}, $value );
                unless ($res) {
                    $errors->{warnings}->{$name} = $m || $test->{keyMsgWarn};
                }
            }
        }

        # 1.3.2 Store accepted parameter in $newConf

        # Menu category
        if ($catflag) {
            $self->lmLog( "Register category $name data", 'debug' );

            # Set catname
            $self->setKeyToH( $newConf, "applicationList/$name/catname",
                $value );

            # Set type to category
            $self->setKeyToH( $newConf, "applicationList/$name/type",
                "category" );

        }

        # Menu application
        elsif ($appflag) {
            $self->lmLog( "Register application $name data", 'debug' );

            # Get options from splitted value
            my @t = split( /\|/, $value );

            # Set applications options
            $self->setKeyToH( $newConf,
                "applicationList/$catid/$name/options/name", $t[0] );
            $self->setKeyToH( $newConf,
                "applicationList/$catid/$name/options/uri", $t[1] );
            $self->setKeyToH( $newConf,
                "applicationList/$catid/$name/options/description", $t[2] );
            $self->setKeyToH( $newConf,
                "applicationList/$catid/$name/options/logo", $t[3] );
            $self->setKeyToH( $newConf,
                "applicationList/$catid/$name/options/display", $t[4] );

            # Set type to application
            $self->setKeyToH( $newConf, "applicationList/$catid/$name/type",
                "application" );

        }

        # Post URL
        elsif ($postflag) {
            $self->lmLog( "Register POST URL $name data", 'debug' );

            # Set postUrl
            $self->setKeyToH(
                $newConf, "post/$vhostname",
                "$postname", { postUrl => $value }
            ) if $value;
        }

        # Post data
        elsif ($postdataflag) {
            $self->lmLog( "Register POST data $name", 'debug' );

            # Set post data in expr
            $self->setKeyToH( $newConf, "post/$vhostname", "$postname",
                { expr => { $name => $value } } )
              if $value;
        }

        # Default case
        else {
            $self->setKeyToH(
                $newConf, $confKey,
                $test->{keyTest}
                ? ( ( $id !~ /\// or $test->{'*'} ) ? {} : ( $name => $value ) )
                : $value
            );
        }
    }    # END LOOP

    # 1.4 Loading unchanged parameters (ajax nodes not open)
    $self->lmLog( "Restore unchanged parameters", 'debug' );
    foreach ( @{ $result->getChildrenByTagName('ignore') } ) {
        my $node = $_->getAttribute('value');
        $node =~ s/^.*node=(.*?)(?:&.*)?\}$/$1/;
        $self->lmLog( "Unchanged node $node", 'debug' );
        foreach my $k ( $self->findAllConfKeys( $self->corresp($node) ) ) {
            $self->lmLog( "Unchanged key $k (node $node)", 'debug' );
            my $v = $self->keyToH( $k, $self->conf );
            $v = $self->keyToH( $k, $self->defaultConf ) unless ( defined $v );
            if ( defined $v ) {
                $self->setKeyToH( $newConf, $k, $v );
            }
            else {
                $self->lmLog( "No default value found for $k", 'info' );
            }
        }
    }

    # 1.5 Author attributes for accounting
    $newConf->{cfgAuthor}   = $ENV{REMOTE_USER} || 'anonymous';
    $newConf->{cfgAuthorIP} = $self->ipAddr;
    $newConf->{cfgDate}     = time();

    # 1.6 Global tests
    $self->lmLog( "Launch global tests", 'debug' );
    {
        my $tests = $self->globalTests($newConf);
        while ( my ( $name, $sub ) = each %$tests ) {
            my ( $res, $msg );
            eval {
                ( $res, $msg ) = $sub->();
                if ( $res == -1 ) {
                    $errors->{force}->{$name} = $msg
                      unless ( $self->param('force') );
                }
                elsif ($res) {
                    if ($msg) {
                        $errors->{warnings}->{$name} = $msg;
                    }
                }
                else {
                    $errors->{errors}->{$name} = $msg;
                }
            };
            $errors->{warnings}->{$name} = "Test $name failed: $@" if ($@);
        }
    }

    # 2. SAVE CONFIGURATION

    $errors->{result}->{other} = '';

    # 2.1 Don't store configuration if a syntax error was detected
    if ( $errors->{errors} ) {
        $errors->{result}->{cfgNum} = 0;
        $errors->{result}->{msg}    = $self->translate('syntaxError');
        $self->_sub( 'userInfo',
            "Configuration rejected for $newConf->{cfgAuthor}: syntax error" );
    }
    elsif ( $errors->{force} ) {
        $errors->{result}->{cfgNum} = 0;
        $errors->{result}->{msg}    = $self->translate('warning');
        $self->_sub( 'userInfo',
"Configuration rejected for $newConf->{cfgAuthor}: confirmation needed"
        );
        $errors->{result}->{other} = '* <a href=\'javascript:uploadConf(1)\'>'
          . $self->translate('clickHereToForce') . '</a>';
        foreach my $k ( keys %{ $errors->{force} } ) {
            $errors->{errors}->{$k} =
              delete( $errors->{force}->{$k} ) . '<sup>*</sup>';
        }
    }

    # 2.2 Try to save configuration
    else {

        # if "force" is set, Lemonldap::NG::Common::Conf accept it even if
        # conf database is locked or conf number isn't current number (used to
        # restore an old configuration)
        $self->confObj->{force} = 1 if ( $self->param('force') );

        # Call saveConf()
        $errors->{result}->{cfgNum} = $self->confObj->saveConf($newConf);

        # 2.2.1 Prepare response
        my $msg;

        # case "success"
        if ( $errors->{result}->{cfgNum} > 0 ) {

            # Store accounting datas to the response
            $errors->{cfgDatas} = {
                cfgAuthor   => $newConf->{cfgAuthor},
                cfgAuthorIP => $newConf->{cfgAuthorIP},
                cfgDate     => $newConf->{cfgDate}
            };
            $msg = 'confSaved';

            # Log success using Lemonldap::NG::Common::CGI::userNotice():
            #  * in system logs if "syslog" is set
            #  * in apache errors file otherwise
            $self->_sub( 'userNotice',
"Conf $errors->{result}->{cfgNum} saved by $newConf->{cfgAuthor}"
            );

            # Reload Handlers listed in apply section
            $errors->{applyStatus} = $self->applyConf();

        }

        # other cases
        else {
            $msg = {
                CONFIG_WAS_CHANGED, 'confWasChanged',
                UNKNOWN_ERROR,      'unknownError',
                DATABASE_LOCKED,    'databaseLocked',
                UPLOAD_DENIED,      'uploadDenied',
                SYNTAX_ERROR,       'syntaxError',
                DEPRECATED,         'confModuledeprecated',
              }->{ $errors->{result}->{cfgNum} }
              || 'unknownError';

            # Log failure using Lemonldap::NG::Common::CGI::userError()
            $self->_sub( 'userError',
                "Configuration rejected for $newConf->{cfgAuthor}: "
                  . $Lemonldap::NG::Common::Conf::msg );
        }

        # Translate msg returned
        $errors->{result}->{msg} = $self->translate($msg);
        if (   $errors->{result}->{cfgNum} == CONFIG_WAS_CHANGED
            or $errors->{result}->{cfgNum} == DATABASE_LOCKED )
        {
            $errors->{result}->{other} = '<a href=\'javascript:uploadConf(1)\'>'
              . $self->translate('clickHereToForce') . '</a>';
        }
        elsif ( $errors->{result}->{cfgNum} == DEPRECATED ) {
            $errors->{result}->{other} = 'Module : ' . $self->confObj->{type};
        }
    }

    # 3. PREPARE JSON RESPONSE
    binmode( STDOUT, ':bytes' );

    # 4. SEND JSON RESPONSE
    $self->sendJSONResponse($errors);

    $self->quit();
}

## @method public void fileUpload(string fieldname, string filename)
# Retrieve a file from an HTTP request, and return it. This function is for
# some functionnalities into the SAML2 modules of the manager, accessing
# to data through Ajax requests.
# @param $fieldname The name of the html input field.
# @param $filename File name
sub fileUpload {
    my $self      = shift;
    my $fieldname = shift;
    my $filename  = shift;
    my $content   = '';

    # Direct download
    if ($filename) {
        $content = ${ $self->rparam($fieldname) };
        print $self->header(
            -type           => 'application/force-download; charset=utf-8',
            -attachment     => $filename,
            -Content_Length => length $content
        ) . $content;
    }

    # JSON request
    else {
        my $UPLOAD_FH = $self->upload($fieldname);
        while (<$UPLOAD_FH>) {
            $content .= "$_";
        }
        $content =~ s!<!&lt;!g;
        $content =~ s!>!&gt;!g;

        $self->sendJSONResponse($content);
    }

    $self->quit();
}

## @method public void fileUpload (fieldname)
# Retrieve a file from an URL, and return it. This function is for
# some functionnalities into the SAML2 modules of the manager, accessing
# to data through Ajax requests.
# @param $fieldname The name of the html input field that contains the URL.
sub urlUpload {
    my $self      = shift;
    my $fieldname = shift;
    my $content   = '';

    # Get the URL
    my $url = ${ $self->rparam($fieldname) };

    # Get contents from URL
    my $content = get $url;
    $content = '' unless ( defined $content );
    $content =~ s!<!&lt;!g;
    $content =~ s!>!&gt;!g;

    $self->sendJSONResponse($content);

    $self->quit();
}

## @method protected array applyTest(void* test,string value)
# Apply the test to the value and return the result and an optional message
# returned by the test if the sub ref.
# @param $test Ref to a regexp or a sub
# @param $value Value to test
# @return Array containing:
# - the test result
# - an optional message
sub applyTest {
    my ( $self, $test, $value ) = @_;
    my ( $res, $msg );
    if ( ref($test) eq 'CODE' ) {
        ( $res, $msg ) = &$test($value);
    }
    else {
        $res = ( $value =~ $test ? 1 : 0 );
    }
    return ( $res, $msg );
}

## @method protected array getConfTests(string id)
# Call Lemonldap::NG::Manager::_Struct::testStruct().
# @param id Element ID in HTML Struct
# @return An array with configuration key and tests expression
sub getConfTests {
    my ( $self, $id ) = @_;

    $self->lmLog( "getConfTests: get id $id", 'debug' );

    my ( $confKey, $tmp ) = ( $id =~ /^(.*?)(?:\/(.*))?$/ );

    $self->lmLog( "getConfTests: split $id in $confKey and $tmp", 'debug' )
      if defined $tmp;

    my $h = $self->testStruct()->{$confKey};

    # '*' is used in virtualHosts tests
    if ( $h and $h->{'*'} and my ( $k, $v ) = ( $tmp =~ /^(.*?)\/(.*)$/ ) ) {
        $self->lmLog( "getConfKey: '*' in tests, return $confKey/$k", 'debug' );
        return ( "$confKey/$k", $h->{'*'} );
    }

    $self->lmLog( "getConfTests: return $confKey", 'debug' );
    return ( $confKey, $h );
}

## @method protected array findAllConfKeys(hashref h)
# Parse a tree structure to find all nodes corresponding to a configuration
# value.
# @param $h Tree structure
# @return Array of configuration parameter names
sub findAllConfKeys {
    my ( $self, $h ) = @_;
    my @res = ();

    # expand _nodes
    if ( ref( $h->{_nodes} ) eq 'CODE' ) {
        $h->{_nodes} = $h->{_nodes}->($self);
    }
    foreach my $n ( @{ $h->{_nodes} } ) {
        $n =~ s/^.*?:(.*?)(?:\:.*)?$/$1/;
        $self->lmLog( "findAllConfKey: got node $n", 'debug' );
        if ( ref( $h->{$n} ) ) {
            push @res, $self->findAllConfKeys( $h->{$n} );
        }
        else {
            my $m = $h->{$n} || $n;
            push @res, ( $m =~ /^(?:.*?:)?(.*?)(?:\:.*)?$/ ? $1 : () );
        }
    }
    push @res, @{ $h->{_upload} } if ( $h->{_upload} );
    return @res;
}

## @method protected String formatValue(string key, string value)
# Format a value.
# @param $key String "/path/key"
# @param $value String
# @return A formated value.
sub formatValue {
    my ( $self, $key, $value ) = @_;

    # Not used now
    return $value;
}

## @method protected void setKeyToH(hashref h,string key,string k2,string value)
# Insert key=>$value in $h at the position declared with $key. If $k2 is set,
# insert key=>{$k2=>$value}. Note that $key is splited with "/". The last part
# is used as key.
# @param $h New Lemonldap::NG configuration
# @param $key String "/path/key"
# @param $k2 Optional subkey
# @param $value Value
sub setKeyToH {
    my $value = pop;
    return unless ( ref($value) or length($value) );
    my ( $self, $h, $key, $k2 ) = @_;

    $self->lmLog( "setKeyToH: key $key / k2 $k2 / value $value", 'debug' );
    my $tmp = $h;
    $key =~ s/^\///;
    $value = $self->formatValue( $key, $value );
    while (1) {
        if ( $key =~ /\// ) {
            my $k = $`;
            $key = $';
            $tmp = $tmp->{$k} ||= {};
        }
        else {
            if ($k2) {
                unless ( ref( $tmp->{$key} ) ) {
                    $self->lmLog(
"setKeyToH: k2 $k2 set, but $key is not a reference, create it",
                        'debug'
                    );
                    $tmp->{$key} = {};
                }

                # Value can be an hashref
                if ( ref($value) eq 'HASH' ) {
                    foreach my $vv ( keys %$value ) {

                        # vv can be an hashref
                        if ( ref( $value->{$vv} ) eq 'HASH' ) {
                            foreach my $vvv ( keys %{ $value->{$vv} } ) {
                                $self->lmLog(
                                    "setKeyToH: set "
                                      . $value->{$vv}->{$vvv}
                                      . " in key $vvv in key $vv in key $k2 inside key $key",
                                    'debug'
                                );
                                $tmp->{$key}->{$k2}->{$vv}->{$vvv} =
                                  $value->{$vv}->{$vvv};
                            }
                        }
                        else {
                            $self->lmLog(
                                "setKeyToH: set "
                                  . $value->{$vv}
                                  . " in key $vv in key $k2 inside key $key",
                                'debug'
                            );
                            $tmp->{$key}->{$k2}->{$vv} = $value->{$vv};
                        }
                    }
                }
                else {
                    $self->lmLog(
                        "setKeyToH: set $value in key $k2 inside key $key",
                        'debug' );
                    $tmp->{$key}->{$k2} = $value;
                }
            }
            else {
                $self->lmLog( "setKeyToH: set $value in key $key", 'debug' );
                $tmp->{$key} = $value;
            }
            last;
        }
    }
}

## @method private XML::LibXML parser()
# @return XML::LibXML object (cached in global $parser variable)
sub parser {
    my $self = shift;
    return $parser if ($parser);
    $parser = XML::LibXML->new();
}

## @method private XML::LibXSLT stylesheet()
# Returns XML::LibXSLT parser (cached in global $stylesheet variable). Use
# datas stored at the end of this file to initialize the object.
# @return XML::LibXSLT object
sub stylesheet {
    my $self = shift;

    return $stylesheet if ($stylesheet);
    my $xslt = XML::LibXSLT->new();
    my $style_doc = $self->parser->parse_string( join( '', <DATA> ) );
    close DATA;
    $stylesheet = $xslt->parse_stylesheet($style_doc);
}

## @method private applyConf()
# Try to apply configuration by reloading Handlers
# @return reload status
sub applyConf {
    my $self = shift;
    my $status;

    # Get apply section values
    my %reloadUrls =
      %{ $self->confObj->getLocalConf( APPLYSECTION, undef, 0 ) };
    if ( !%reloadUrls && $self->confObj->getConf->{reloadUrls} ) {
        %reloadUrls = %{ $self->confObj->getConf->{reloadUrls} };
    }

    # Create user agent
    my $ua = new LWP::UserAgent( requests_redirectable => [] );
    $ua->timeout(10);

    # Parse apply values
    foreach ( keys %reloadUrls ) {
        my ( $host, $request ) = ( $_, $reloadUrls{$_} );
        my ( $method, $vhost, $uri ) =
          ( $request =~ /^(https?):\/\/([^\/]+)(.*)$/ );
        unless ($vhost) {
            $vhost = $host;
            $uri   = $request;
        }
        my $r =
          HTTP::Request->new( 'GET', "$method://$host$uri",
            HTTP::Headers->new( Host => $vhost ) );
        my $response = $ua->request($r);
        if ( $response->code != 200 ) {
            $status->{$host} =
              "Error " . $response->code . " (" . $response->message . ")";
            $self->_sub( 'userError',
                    "Apply configuration for $host: error "
                  . $response->code . " ("
                  . $response->message
                  . ")" );
        }
        else {
            $status->{$host} = "OK";
            $self->_sub( 'userNotice', "Apply configuration for $host: ok" );
        }
    }

    return $status;
}

1;
__DATA__
<?xml version="1.0" encoding="UTF-8"?>
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
  <xsl:choose>
   <xsl:when test="@id='text_li_cm9vdA2'">
    <conf><xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute></conf>
   </xsl:when>
   <xsl:otherwise>
    <element>
     <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
     <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
    </element>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
