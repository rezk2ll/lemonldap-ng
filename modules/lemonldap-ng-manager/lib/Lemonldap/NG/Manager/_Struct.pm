## @file
# Manager tree structure and tests

## @class
# Manager tree structure and tests
package Lemonldap::NG::Manager::_Struct;

use strict;
our $VERSION = '0.1';

## @method protected hashref cstruct(hashref h,string k)
# Merge $h with the structure produced with $k and return it.
# Used to manage virtual hosts.
#@param $h Result of struct()
#@param $k Name of the virtual host
#@return Tree structure
sub cstruct {
    shift;
    my ( $h, $k ) = @_;
    %$h = (
        %$h,
        virtualHosts => {
            $k => {
                _nodes => [qw(rules:rules:rules headers)],
                rules  => {
                    _nodes => ["hash:/locationRules/$k:rules:rules"],
                    _js    => 'rulesRoot'
                },
                headers => {
                    _nodes => ["hash:/exportedHeaders/$k"],
                    _js    => 'hashRoot'
                },
            }
        }
    );
    return $h;
}

## @method protected hashref struct(hashref h,string k)
# Returns the tree structure
#@param $h Result of struct()
#@param $k Name of the virtual host
#@return Tree structure
sub struct {
    my $self = shift;
    return {
        _nodes => [qw(n:generalParameters n:groups n:virtualHosts)],
        _help  => 'default',

        ######################
        # GENERAL PARAMETERS #
        ######################
        generalParameters => {
            _nodes => [
                qw(portal n:authParams logParams cookieParams cn:exportedVars cn:macros sessionParams n:advancedParams)
            ],
            _help  => 'default',
            portal => 'text:/portal',

            # AUTHENTICATION AND USERDB PARAMETERS
            authParams => {

               # Displayed nodes depend on authentication/userDB modules choosed
                _nodes => sub {
                    my $self = shift;
                    my $auth = $self->conf->{authentication}
                      || $self->defaultConf()->{authentication};
                    my $udb = $self->conf->{userDB}
                      || $self->defaultConf()->{userDB};
                    $auth = lc($auth);
                    $udb  = lc($udb);
                    my %res = qw(authentication 1 userDB 1);
                    foreach my $mod ( ( $auth, ( $auth ne $udb ? $udb : () ) ) )
                    {
                        my $tmp = {
                            ldap => ['ldapParams'],
                            ssl  => [qw(ldapParams SSLRequired)],
                        }->{$mod};
                        if ($tmp) {
                            $res{$_}++ foreach (@$tmp);
                        }
                    }
                    my @u = keys %res;
                    return \@u;
                },
                _help          => 'authParams',
                authentication => 'text:/authentication:authParams:authParams',
                userDB         => 'text:/userDB:authParams:authParams',
                ldapParams     => {
                    _nodes => [
                        qw(ldapServer ldapPort ldapBase managerDn managerPassword)
                    ],
                    _help           => 'ldap',
                    ldapServer      => 'text:/ldapServer',
                    ldapPort        => 'int:/ldapPort',
                    ldapBase        => 'text:/ldapBase',
                    managerDn       => 'text:/managerDn',
                    managerPassword => 'text:/managerPassword',
                },
                SSLRequired => 'bool:/SSLRequired',
            },

            # LOGS PARAMETERS
            logParams => {
                _nodes => [qw(syslog useXForwardedForIP whatToTrace)],
                syslog => 'text:/syslog',
                useXForwardedForIP => 'bool:/useXForwardedForIP',
                whatToTrace        => 'text:/whatToTrace:whatToTrace:text',
            },

            # COOKIE PARAMETERS
            cookieParams => {
                _nodes =>
                  [qw(cookieName domain securedCookie cookieExpiration)],
                _help      => 'cookies',
                cookieName => 'text:/cookieName:cookieName:text',
                domain     => 'text:/domain:domain:text',
                securedCookie =>
                  'int:/securedCookie:securedCookie:securedCookieValues',
                cookieExpiration => 'text:/cookieExpiration',
            },

            # EXPORTED ATTRIBUTES
            exportedVars => {
                _nodes => ['hash:/exportedVars:vars:btext'],
                _js    => 'hashRoot'
            },

            # MACROS
            macros =>
              { _nodes => ['hash:/macros:macros:btext'], _js => 'hashRoot' },

            # SESSIONS PARAMETERS
            sessionParams => {
                _nodes => [
                    qw(sessionStorage singleSession singleIP singleUserByIP notifyDeleted timeout storePassword)
                ],
                _help          => 'storage',
                sessionStorage => {
                    _nodes        => [qw(globalStorage globalStorageOptions)],
                    globalStorage => 'text:/globalStorage',
                    globalStorageOptions => {
                        _nodes => ['hash:/globalStorageOptions'],
                        _js    => 'hashRoot'
                    },
                },
                singleSession  => 'bool:/singleSession',
                singleIP       => 'bool:/singleIP',
                singleUserByIP => 'bool:/singleUserByIP',
                notifyDeleted  => 'bool:/notifyDeleted',
                storePassword  => 'bool:/storePassword',
                timeout        => 'text:/timeout:timeout:text',
            },

            # OTHER PARAMETERS
            advancedParams => {
                _nodes => [
                    qw(Soap exportedAttr trustedDomains https notifications passwordManagement userControl)
                ],
                Soap          => 'bool:/Soap',
                https         => 'bool:/https',
                exportedAttr  => 'text:/exportedAttr',
                notifications => {
                    _nodes => [
                        qw(notification notificationStorage notificationStorageOptions)
                    ],
                    _help                      => 'notifications',
                    notification               => 'bool:/notification',
                    notificationStorage        => 'text:/notificationStorage',
                    notificationStorageOptions => {
                        _nodes => ['hash:/notificationStorageOptions'],
                        _js    => 'hashRoot'
                    },
                },
                passwordManagement => {
                    _nodes => [
                        qw(passwordDB SMTPServer mailFrom mailSubject randomPasswordRegexp mailBody)
                    ],
                    passwordDB           => 'text:/passwordDB',
                    SMTPServer           => 'text:/SMTPServer',
                    mailFrom             => 'text:/mailFrom',
                    mailSubject          => 'text:/mailSubject',
                    randomPasswordRegexp => 'text:/randomPasswordRegexp',
                    mailBody             => 'text:/mailBody',
                },
                trustedDomains => 'text:/trustedDomains',
                userControl    => 'text:/userControl:userControl:text',
            }
        },

        ##########
        # GROUPS #
        ##########
        groups => {
            _nodes => ['hash:/groups:groups:btext'],
            _js    => 'hashRoot',
            _help  => 'default',
        },

        #################
        # VIRTUAL HOSTS #
        #################
        virtualHosts => {
            _nodes  => ['nhash:/locationRules:virtualHosts:vhost'],
            _upload => ['/exportedHeaders'],
            _help   => 'default',
            _call   => '$(\'#bnewvh\').show();',
        },
    };
}

## @method protected hashref testStruct()
# Returns the tests to do with the datas uploaded.
# @return hashref
sub testStruct {
    my $safe       = Safe->new();
    my $assignTest = qr/(?<=[^=<!>\?])=(?![=~])/;
    my $assignMsg  = 'containsAnAssignment';
    my $perlExpr   = sub {
        my $e = shift;
        $safe->reval( $e, 1 );
        return 1 unless ($@);
        return 1 if ( $@ =~ /Global symbol "\$.*requires explicit package/ );
        return ( 1,
            "Function \"<b>$1</b>\" must be declared in customFunctions" )
          if ( $@ =~ /Bareword "(.*?)" not allowed while "strict subs"/ );
        return ( 0, $@ );
    };
    my $boolean = { test => qr/^(?:0|1)?$/, msgFail => 'Value must be 0 or 1' };
    my $pcre = sub {
        my $r = shift;
        my $q;
        eval { $q = qr/$r/ };
        return ( $@ ? ( 0, $@ ) : 1 );
    };
    my $testNotDefined = { test => sub { 1 }, msgFail => 'Ok' };

    return {
        mailFrom             => $testNotDefined,
        trustedDomains       => $testNotDefined,
        exportedAttr         => $testNotDefined,
        mailSubject          => $testNotDefined,
        randomPasswordRegexp => $testNotDefined,
        passwordDB           => $testNotDefined,
        mailBody             => $testNotDefined,
        SMTPServer           => $testNotDefined,
        cookieExpiration     => $testNotDefined,
        notificationStorage  => $testNotDefined,
        authentication       => {
            test    => qr/^[a-zA-Z][\w\:]*$/,
            msgFail => 'Bad module name',
        },
        cda        => $boolean,
        cookieName => {
            test    => qr/^[a-zA-Z]\w*$/,
            msgFail => 'Bad cookie name',
        },
        domain => {
            test    => qr/^\.?\w+(?:\.[a-zA-Z]\w*)*(?:\.[a-zA-Z]+)$/,
            msgFail => 'Bad domain',
        },
        exportedHeaders => {
            keyTest    => qr/^[a-zA-Z](?:[\w\-\.]*\w)?$/,
            keyMsgFail => 'Bad virtual host name',
            '*'        => {
                keyTest    => qr/^\w([\w\-]*\w)?$/,
                keyMsgFail => 'Bad header name',
                test       => $perlExpr,
                warnTest   => sub {
                    my $e = shift;
                    return ( 0, $assignMsg ) if ( $e =~ $assignTest );
                    1;
                },
            },
        },
        exportedVars => {
            keyTest    => qr/^[a-zA-Z]\w*$/,
            keyMsgFail => 'Bad variable name',
            test       => qr/^[a-zA-Z]\w*$/,
            msgFail    => 'Bad attribute name',
        },
        globalStorage => {
            test    => qr/^[\w:]+$/,
            msgFail => 'Bad module name',
        },
        globalStorageOptions => {
            keyTest    => qr/^\w+$/,
            keyMsgFail => 'Bad parameter',
        },
        groups => {
            keyTest    => qr/^\w[\w-]*$/,
            keyMsgFail => 'Bad group name',
            test       => $perlExpr,
            warnTest   => sub {
                my $e = shift;
                return ( 0, $assignMsg ) if ( $e =~ $assignTest );
                1;
            },
        },
        https    => $boolean,
        ldapBase => {
            test    => qr/^(?:\w+=.*|)$/,
            msgFail => 'Bad LDAP base',
        },
        ldapPort => {
            test    => qr/^\d*$/,
            msgFail => 'Bad port number'
        },
        ldapServer => {
            test => sub {
                my $l = shift;
                my @s = split( /[\s,]+/, $l );
                foreach my $s (@s) {
                    $s =~
/^(?:ldap(?:s|\+tls|i):\/\/)?\w[\w\-\.]+\w(?::\d{0,5})?\/?$/
                      or return ( 0, "Bad ldap uri \"$s\"" );
                }
                return 1;
            },
        },
        locationRules => {
            keyTest => qr/^[a-zA-Z](?:[\w\-\.]*\w)?$/,
            msgFail => 'Bad virtual host name',
            '*'     => {
                keyTest => $pcre,
                test    => sub {
                    my $e = shift;
                    return 1 if ( $e eq 'accept' or $e eq 'deny' );
                    if ( $e =~ s/^logout(?:_(?:app|sso|app_sso))?\s*// ) {
                        return (
                            $e =~ /^(?:https?:\/\/\S+)?$/
                            ? 1
                            : ( 0, "bad url \"$e\"" )
                        );
                    }
                    return &$perlExpr($e);
                },
                warnTest => sub {
                    my $e = shift;
                    return ( 0, $assignMsg )
                      if (  $e =~ $assignTest
                        and $e !~ /^(?:accept|deny|logout)/ );
                    1;
                },
            },
        },
        macros => {
            keyTest    => qr/^[a-zA-Z]\w*$/,
            keyMsgFail => 'Bad macro name',
            test       => $perlExpr,
            warnTest   => sub {
                my $e = shift;
                return ( 0, $assignMsg ) if ( $e =~ $assignTest );
                1;
            },
        },
        managerDn => {
            test    => qr/^(?:\w+=.*,\w+=.*)?$/,
            msgFail => 'Bad LDAP dn',
        },
        managerPassword => {
            test    => qr/^\S*$/,
            msgFail => 'Bad LDAP password',
        },
        notification        => $boolean,
        notificationStorage => {
            test    => qr/^[\w:]+$/,
            msgFail => 'Bad module name',
        },
        notificationStorageOptions => {
            keyTest    => qr/^\w+$/,
            keyMsgFail => 'Bad parameter',
        },
        notifyDeleted => $boolean,
        portal        => {
            test    => qr/^https?:\/\/\S+$/,
            msgFail => 'Bad portal value',
        },
        protection => {
            keyTest => qr/^(?:none|authentificate|manager|)$/,
            msgFail => 'must be one of none authentificate manager',
        },
        securedCookie => {
            test    => qr/^(?:0|1|2)$/,
            msgFail => 'securedCookie must be 0, 1 or 2',
        },
        singleSession  => $boolean,
        singleIP       => $boolean,
        singleUserByIP => $boolean,
        Soap           => $boolean,
        SSLRequired    => $boolean,
        storePassword  => $boolean,
        syslog         => {
            test => qw/^(?:auth|authpriv|daemon|local\d|user)?$/,
            msgFail =>
              'Only auth|authpriv|daemon|local0-7|user is allowed here',
        },
        timeout => {
            test    => qr/^\d*$/,
            msgFail => 'Bad number'
        },
        userControl => {
            test    => $pcre,
            msgFail => 'Bad regular expression',
        },
        userDB => {
            test    => qr/^[a-zA-Z][\w\:]*$/,
            msgFail => 'Bad module name',
        },
        useXForwardedForIP => $boolean,
        whatToTrace        => {
            test    => qr/^\$?[a-zA-Z]\w*$/,
            msgFail => 'Bad value',
        },
    };
}

## @method protected hashref defaultConf()
#@return Hashref of default values
sub defaultConf {
    return {
        authentication  => 'LDAP',
        cda             => '0',
        cookieName      => 'lemonldap',
        domain          => 'example.com',
        exportedHeaders => { 'test.example.com' => { 'Auth-User' => '$uid' }, },
        exportedVars    => { cn => 'cn', mail => 'mail', uid => 'uid', },
        globalStorage   => 'Apache::Session::File',
        globalStorageOptions => {
            'Directory'     => '/var/lib/lemonldap-ng/sessions/',
            'LockDirectory' => '/var/lib/lemonldap-ng/sessions/lock/'
        },
        https           => '0',
        ldapBase        => 'dc=example,dc=com',
        ldapPort        => '389',
        ldapServer      => 'localhost',
        locationRules   => { 'test.example.com' => { default => 'accept' }, },
        managerDn       => '',
        managerPassword => '',
        notification    => '0',
        notificationStorage => 'File',
        notificationStorageOptions =>
          { dirName => '/var/lib/lemonldap-ng/notifications', },
        notifyDeleted      => '1',
        portal             => 'http://auth.example.com/',
        protection         => 'none',
        securedCookie      => '0',
        singleSession      => '0',
        singleIP           => '0',
        singleUserByIP     => '0',
        Soap               => '1',
        SSLRequired        => '0',
        storePassword      => '0',
        syslog             => '',
        timeout            => '7200',
        userControl        => '^[\w\.\-@]+$',
        userDB             => 'LDAP',
        useXForwardedForIP => '0',
        whatToTrace        => '$uid',
    };
}

sub subDefaultConf {
    return {
        locationRules   => { default     => 'deny' },
        exportedHeaders => { 'Auth-User' => '$uid' },
    };
}

1;
