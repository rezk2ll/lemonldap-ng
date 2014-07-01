# Methods run at configuration reload
package Lemonldap::NG::Handler::Reload;

#use Lemonldap::NG::Handler::Main qw(:all);
use Lemonldap::NG::Common::Safelib;    #link protected safe Safe object
use constant UNPROTECT => 1;
use constant SKIP      => 2;

use Lemonldap::NG::Handler::Main::Jail;
use Lemonldap::NG::Handler::Main::Logger;
use Lemonldap::NG::Handler::API qw(:httpCodes);
use Lemonldap::NG::Common::Crypto;

our $VERSION = '1.4.0';

## @imethod void configReload(hashRef conf, hashRef tsv)
# Given a Lemonldap::NG configuration $conf, computes values used to
# handle requests and store them in a thread shared object called $tsv
#
# methods called by configReload, and thread shared values computed, are:
# * defaultValuesInit():
#      (scalars for global options)
#      - cda
#      - cookieExpiration  # warning: absent from default Conf
#      - cookieName
#      - securedCookie,
#      - httpOnly
#      - whatToTrace
#      - customFunctions
#      - timeoutActivity
#      - useRedirectOnError
#      - useRedirectOnForbidden
#      - useSafeJail
#      (objects)
#      - cipher  # Lemonldap::NG::Common::Crypto object
#      - jail
#      (hashrefs for vhost options)
#      - https
#      - port
#      - maintenance
# * portalInit():
#      - portal (functions that returns portal URL)
# * locationRulesInit():
#      - locationCount
#      - defaultCondition
#      - defaultProtection
#      - locationCondition
#      - locationProtection
#      - locationRegexp
#      - locationConditionText
# * sessionStorageInit():
#      - sessionStorageModule
#      - sessionStorageOptions
#      - sessionCacheModule
#      - sessionCacheOptions
#      - sessionCache
# * headersInit():
#      - headerList
#      - forgeHeaders
# * postUrlInit():
# * aliasInit():
#      - vhostAlias

# @param $conf reference to the configuration hash
# @param $tsv reference to the thread-shared parameters conf
sub configReload {
    my ( $class, $conf, $tsv ) = @_;

    $class->defaultValuesInit ( $conf, $tsv );
    $class->portalInit        ( $conf, $tsv );
    $class->locationRulesInit ( $conf, $tsv );
    $class->sessionStorageInit( $conf, $tsv );
    $class->headersInit       ( $conf, $tsv );
#    $class->postUrlInit       ( $conf, $tsv );
    $class->aliasInit         ( $conf, $tsv );
    return 1;
}


## @imethod protected void defaultValuesInit(hashRef args)
# Set default values for non-customized variables
# @param $args reference to the configuration hash
sub defaultValuesInit {
    my ( $class, $conf, $tsv ) = @_;
    
    $tsv->{$_} = $conf->{$_}
      foreach (qw(
        cda              cookieExpiration    cookieName
        customFunctions  httpOnly            securedCookie
        timeoutActivity  useRedirectOnError  useRedirectOnForbidden
        useSafeJail      whatToTrace
      ));

    $tsv->{cipher} = Lemonldap::NG::Common::Crypto->new($conf->{key});
    $tsv->{jail} = Lemonldap::NG::Handler::Main::Jail->new(
        'safe'            => undef,
        'useSafeJail'     => $conf->{useSafeJail},
        'customFunctions' => $conf->{customFunctions}
    );
    $tsv->{jail}->build_safe();

    foreach my $opt (qw(https port maintenance)) {
        next unless defined $conf->{$opt};

        # Record default value in key '_'
        $tsv->{$opt} = { _ => $conf->{$opt} };

        # Override with vhost options
        if ( $conf->{vhostOptions} ) {
            my $name = 'vhost' . ucfirst($opt);
            foreach my $vhost ( keys %{ $conf->{vhostOptions} } ) {
                my $val = $conf->{vhostOptions}->{$vhost}->{$name};
                Lemonldap::NG::Handler::Main::Logger->lmLog(
                    "Options $opt for vhost $vhost: $val", 'debug' );
                $tsv->{$opt}->{$vhost} = $val
                    if ( $val >= 0 ); # Keep default value if $val is negative
            }
        }
    }
    return 1;
}

## @imethod protected void portalInit(hashRef args)
# Verify that portal variable exists. Die unless
# @param $args reference to the configuration hash
sub portalInit {
    my ( $class, $conf, $tsv ) = @_;
    die("portal parameter required") unless ( $conf->{portal} );
    if ( $conf->{portal} =~ /[\$\(&\|"']/ ) {
        ($tsv->{portal}) = $class->conditionSub( $conf->{portal}, $tsv );
    }
    else {
        $tsv->{portal} = sub { return $conf->{portal} };
    }
    return 1;
}

## @imethod void locationRulesInit(hashRef args)
# Compile rules.
# Rules are stored in $args->{locationRules}->{&lt;virtualhost&gt;} that contains
# regexp=>test expressions where :
# - regexp is used to test URIs
# - test contains an expression used to grant the user
#
# This function creates 2 hashRef containing :
# - one list of the compiled regular expressions for each virtual host
# - one list of the compiled functions (compiled with conditionSub()) for each
# virtual host
# @param $args reference to the configuration hash
sub locationRulesInit {
    my ( $class, $conf, $tsv ) = @_;

    foreach my $vhost ( keys %{ $conf->{locationRules} } ) {
        foreach ( sort keys %{ $conf->{locationRules}->{$vhost} } ) {
            my ( $cond, $prot )
              = $class->conditionSub( $conf->{locationRules}->{$vhost}->{$_}, $tsv );

            if ( $_ eq 'default' ) {
                $tsv->{defaultCondition}->{$vhost} = $cond;
                $tsv->{defaultProtection}->{$vhost} = $prot;
            }
            else {
                push @{ $tsv->{locationCondition}->{$vhost} } , $cond;
                push @{ $tsv->{locationProtection}->{$vhost} }, $prot;
                push @{ $tsv->{locationRegexp}->{$vhost} }    , qr/$_/;
                push @{ $tsv->{locationConditionText}->{$vhost} },
                  /^\(\?#(.*?)\)/ ? $1 : /^(.*?)##(.+)$/ ? $2 : $_;
                $tsv->{locationCount}->{$vhost}++;
            }
        }

        # Default policy set to 'accept'
        unless ( $defaultCondition->{$vhost} ) {
            $tsv->{defaultCondition}->{$vhost} = sub { 1 };
            $tsv->{defaultProtection}->{$vhost} = 0;
        }
    }
    return 1;
}

## @imethod protected void sessionStorageInit(hashRef args)
# Initialize the Apache::Session::* module choosed to share user's variables
# and the Cache::Cache module choosed to cache sessions
# @param $args reference to the configuration hash
sub sessionStorageInit {
    my ( $class, $conf, $tsv ) = @_;
    $tsv->{sessionStorageModule} = $conf->{globalStorage}
      or die("globalStorage required");
    eval "use $tsv->{sessionStorageModule}";
    die($@) if ($@);
    $tsv->{sessionStorageOptions} = $conf->{globalStorageOptions};

    if ($conf->{localSessionStorage}) {
        $tsv->{sessionCacheModule}  = $conf->{localSessionStorage};
        $tsv->{sessionCacheOptions} = $conf->{localSessionStorageOptions};
        $tsv->{sessionCacheOptions}->{default_expires_in} ||= 600;
    
        eval "use $tsv->{sessionCacheModule}";
        die($@) if ($@);
        eval '$tsv->{sessionCache} = new '
               . $tsv->{sessionCacheModule}
               . '($tsv->{sessionCacheOptions});';
        die("Unable to init local cache: $@") if ($@);
    
        if ($conf->{status}) {
            my $params = "";
            if ($tsv->{sessionCacheModule}) {
                require Data::Dumper;
                $params = " $tsv->{sessionCache},"
                    . Data::Dumper->new( [ $tsv->{sessionCacheOptions} ] )
                    ->Terse(1)->Indent(0)->Dump; # To send params on one line
            }
            print { $tsv->{statusPipe} } "RELOADCACHE$params";
        }
    }
    return 1;
}

## @imethod void headersInit(hashRef args)
# Create the subroutines used to insert headers into the HTTP request.
# @param $args reference to the configuration hash
sub headersInit {
    my ( $class, $conf, $tsv ) = @_;

    # Creation of the subroutine which will generate headers
    foreach my $vhost ( keys %{ $conf->{exportedHeaders} } ) {
        my %headers = %{ $conf->{exportedHeaders}->{$vhost} };
        $tsv->{headerList}->{$vhost} = [ keys %headers ];
        my $sub;
        foreach ( keys %headers ) {
            my $val = $class->substitute($headers{$_});
            $sub .= "'$_' => $val,";
        }

        $tsv->{forgeHeaders}->{$vhost} = $tsv->{jail}->jail_reval("sub{$sub}");

        Lemonldap::NG::Handler::Main::Logger->lmLog(
            "$self: Unable to forge headers: $@: sub {$sub}", 'error' )
          if ($@);
    }
    return 1;
}

## @imethod protected void postUrlInit()
# Prepare methods to post form attributes
sub postUrlInit {
    my ( $self, $transform, $args ) = splice @_;

    # Do nothing if no POST configured
    return unless ( $args->{post} );

    # Load required modules
    eval 'use Apache2::Filter;use URI';

    # Prepare transform sub
    $transform = {};

    # Browse all vhost
    foreach my $vhost ( keys %{ $args->{post} } ) {

        foreach
          my $alias ( @{ $self->getAliases( $vhost, $args->{vhostOptions} ) } )
        {

            my $mypost = $args->{post}->{$vhost};

            #  Browse all POST URI
            while ( my ( $url, $d ) = each( %{ $args->{post}->{$vhost} } ) ) {

                # Where to POST
                $d->{postUrl} ||= $url;

                # Register POST form for POST URL
                $transform->{$alias}->{$url} = sub {
                    my $r = shift;
                    Lemonldap::NG::Handler::Main::PostForm->buildPostForm(
                        $r, $d->{postUrl} );
                  }
                  if ( $url ne $d->{postUrl} );

                # Get datas to POST
                my $expr = $d->{expr};
                my %postdata;

                # Manage old and new configuration format
                # OLD: expr => 'param1 => value1, param2 => value2',
                # NEW : expr => { param1 => value1, param2 => value2 },
                if ( ref $expr eq 'HASH' ) {
                    %postdata = %$expr;
                }
                else {
                    %postdata = split /(?:\s*=>\s*|\s*,\s*)/, $expr;
                }

                # Build string for URI::query_form
                my $tmp;
                foreach ( keys %postdata ) {
                    $postdata{$_} =~ s/\$(\w+)/\$datas->{$1}/g;
                    $postdata{$_} = "'$postdata{$_}'"
                      if ( $postdata{$_} =~ /^\w+$/ );
                    $tmp .= "'$_'=>$postdata{$_},";
                }

                Lemonldap::NG::Handler::Main::Logger->lmLog(
                    "Compiling POST request for $url", 'debug' );
                $transform->{$alias}->{ $d->{postUrl} } = sub {
                    my $r = shift;
                    return
                      Lemonldap::NG::Handler::Main::PostForm->buildPostForm(
                        $r, $d->{postUrl} )
                      if ( $r->method ne 'POST' );
                    $r->add_input_filter(
                        sub {
                            Lemonldap::NG::Handler::Main::PostForm->postFilter(
                                $tmp, @_ );
                        }
                    );
                    OK;
                };
            }
        }
    }
    return $transform;
}

## @imethod protected codeRef conditionSub(string cond)
# Returns a compiled function used to grant users (used by
# locationRulesInit(). The second value returned is a non null
# constant if URL is not protected (by "unprotect" or "skip"), 0 else.
# @param $cond The boolean expression to use
# @param $mainClass  optional
# @return array (ref(sub), int)
sub conditionSub {
    my ( $class, $cond, $tsv ) = @_;
    my ( $OK, $NOK ) = ( sub { 1 }, sub { 0 } );

    # Simple cases : accept and deny
    return ( $OK, 0 )
      if ( $cond =~ /^accept$/i );
    return ( $NOK, 0 )
      if ( $cond =~ /^deny$/i );

    # Cases unprotect and skip : 2nd value is 1 or 2
    return ( $OK, UNPROTECT )
      if ( $cond =~ /^unprotect$/i );
    return ( $OK, SKIP )
      if ( $cond =~ /^skip$/i );

    # Case logout
    if ( $cond =~ /^logout(?:_sso)?(?:\s+(.*))?$/i ) {
        my $url = $1;
        return (
            $url
            ? (
                sub {
                    $Lemonldap::NG::Handler::Main::datas->{_logout} = $url;
                    return 0;
                },
                0
              )
            : (
                sub {
                    $Lemonldap::NG::Handler::Main::datas->{_logout} =
                      &{ $tsv->{portal} }();
                    return 0;
                },
                0
            )
        );
    }

    # Since filter exists only with Apache>=2, logout_app and logout_app_sso
    # targets are available only for it.
    # This error can also appear with Manager configured as CGI script
    if ( $cond =~ /^logout_app/i and MP() < 2 ) {
        Lemonldap::NG::Handler::Main::Logger->lmLog(
            "Rules logout_app and logout_app_sso require Apache>=2", 'warn' );
        return ( sub { 1 }, 0 );
    }

    # logout_app
    if ( $cond =~ /^logout_app(?:\s+(.*))?$/i ) {
        my $u = $1 || &{ $tsv->{portal} }();
        eval 'use Apache2::Filter' unless ( $INC{"Apache2/Filter.pm"} );
        return (
            sub {
                my $r = shift;
                $r->add_output_filter(
                    sub {
                        return Lemonldap::NG::Handler::Main->redirectFilter( $u, @_ );
                    }
                );
                1;
            },
            0
        );
    }
    elsif ( $cond =~ /^logout_app_sso(?:\s+(.*))?$/i ) {
        eval 'use Apache2::Filter' unless ( $INC{"Apache2/Filter.pm"} );
        my $u = $1 || &{ $tsv->{portal} }();
        return (
            sub {
                my $r = shift;
                Lemonldap::NG::Handler::Main->localUnlog;
                $r->add_output_filter(
                    sub {
                        my $r = shift->r;
                        return Lemonldap::NG::Handler::Main->redirectFilter(
                            &{ $tsv->{portal} }() . "?url="
                              . Lemonldap::NG::Handler::Main->encodeUrl( $r, $u )
                              . "&logout=1",
                            @_
                        );
                    }
                );
                1;
            },
            0
        );
    }

    # Replace some strings in condition
    $cond = $class->substitute($cond);
    my $sub = $tsv->{jail}->jail_reval("sub{return($cond)}");

    # Return sub and protected flag
    return ( $sub, 0 );
}

## @method arrayref aliasInit
# @param options vhostOptions configuration item
# @return arrayref of vhost and aliases
sub aliasInit {
    my ( $class, $conf, $tsv ) = @_;

    foreach my $vhost ( keys %{ $conf->{options} } ) {
        if ( my $aliases = $conf->{options}->{$vhost}->{vhostAliases} ) {
            foreach ( split /\s+/, $aliases ) {
                $tsv->{vhostAlias}->{$_} = $vhost;
            }
        }
    }
    return 1;
}
# TODO: support wildcards in aliases


sub substitute {
    my ( $class, $expr ) = @_;

    # substitute fake env vars
    # is /e necessary at end of sub ?
    $expr =~ s/\$ENV{TIME}/time/g;
    $expr =~ s/\$ENV{DATE}/&POSIX::strftime("%Y%m%d%H%M%S",localtime)/g;
    $expr =~ s/\$ENV{SERVER_NAME}/Lemonldap::NG::Handler::API->hostname/g;
    $expr =~ s/\$ENV{(IP|REMOTE_ADDR)}/Lemonldap::NG::Handler::API->remote_addr/g;
    $expr =~ s/\$ENV{REQUEST_URI}/Lemonldap::NG::Handler::API->uri/g;
    $expr =~ s/\$ENV{QUERY_STRING}/Lemonldap::NG::Handler::API->args/g;
    $expr =~ s/\$ENV{REQUEST_METHOD}/Lemonldap::NG::Handler::API->request_method/g;
    #TODO: substitute $ENV{HTTP_*} with corresponding header

    # substitute fake env vars - kept for retro-compatibility
    $expr =~ s/\$date/&POSIX::strftime("%Y%m%d%H%M%S",localtime)/g;
    $expr =~ s/\$vhost/Lemonldap::NG::Handler::API->hostname/g;
    $expr =~ s/\$ip/Lemonldap::NG::Handler::API->remote_addr/g;

    # substitute vars with session datas, excepts special vars $_ and $\d+
    $expr =~ s/\$((?!_|\d+)\w+)/\$datas->{$1}/g;

    return $expr;
}

1;
