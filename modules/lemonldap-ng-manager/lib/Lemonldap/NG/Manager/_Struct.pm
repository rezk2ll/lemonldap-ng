package Lemonldap::NG::Manager::_Struct;

use strict;
our $VERSION = '0.1';

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
                headers =>
                  { _nodes => ["hash:/exportedHeaders/$k"], _js => 'hashRoot' },
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
                qw(n:authParams cookieParams cn:exportedVars cn:macros sessionParams ldapParams)
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
            exportedVars => {
                _nodes => ['hash:/exportedVars:vars:btext'],
                _js    => 'hashRoot'
            },
            macros =>
              { _nodes => ['hash:/macros:macros:btext'], _js => 'hashRoot' },
            sessionParams => {
                _nodes         => [qw(sessionStorage timeout)],
                _help          => 'storage',
                sessionStorage => {
                    _nodes        => [qw(globalStorage globalStorageOptions)],
                    globalStorage => 'text:/globalStorage',
                    globalStorageOptions => {
                        _nodes => ['hash:/globalStorageOptions'],
                        _js    => 'hashRoot'
                    },
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
        groups => { _nodes => ['hash:/groups:groups:btext'], _js => 'hashRoot' },
        virtualHosts =>
          { _nodes => ['nhash:/locationRules:virtualHosts:none'], },
    };
}

sub testStruct {
    my $assignTest = qr/(?<=[^=<!>\?])=(?![=~])/;
    my $assignMsg  = 'containsAnAssignment';
    my $perlExpr   = sub {
        my $e = shift;
        eval "use strict;$e";
        return 1 if ( $@ =~ /Global symbol "\$.*requires explicit package/ );
        return ( $@ ? ( 0, $@ ) : 1 );
    };
    return {
        authentication => {
            test    => qr/^[a-zA-Z][\w\:]*$/,
            msgFail => 'Bad module name',
        },
        userDB => {
            test    => qr/^[a-zA-Z][\w\:]*$/,
            msgFail => 'Bad module name',
        },
        whatToTrace => {
            test    => qr/^\$?[a-zA-Z]\w*$/,
            msgFail => 'Bad value',
        },
        portal => {
            test    => qr/^https?:\/\/\S+$/,
            msgFail => 'Bad portal value',
        },
        cookieName => {
            test    => qr/^[a-zA-Z]\w*$/,
            msgFail => 'Bad cookie name',
        },
        securedCookie => {
            test    => qr/^(?:0|1|2)$/,
            msgFail => 'securedCookie must be 0, 1 or 2',
        },
        domain => {
            test    => qr/^\.?\w+(?:\.[a-zA-Z]\w*)*(?:\.[a-zA-Z]+)$/,
            msgFail => 'Bad domain',
        },
        timeout => {
            test    => qr/^\d*$/,
            msgFail => 'Bad number'
        },
        globalStorage => {
            test    => qr/^[\w:]+$/,
            msgFail => 'Bad module name',
        },
        globalStorageOptions => {
            keyTest    => qr/^\w+$/,
            keyMsgFail => 'Bad parameter',
        },
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
        managerDn => {
            test    => qr/^(?:\w+=.*,\w+=.*)?$/,
            msgFail => 'Bad LDAP dn',
        },
        managerPassword => {},
        groups          => {
            keyTest    => qr/^\w[\w-]*$/,
            keyMsgFail => 'Bad group name',
            test       => $perlExpr,
            warnTest   => sub {
                my $e = shift;
                return ( 0, $assignMsg ) if ( $e =~ $assignTest );
                1;
            },
        },
        exportedVars => {
            keyTest    => qr/^[a-zA-Z]\w*$/,
            keyMsgFail => 'Bad variable name',
            test       => qr/^[a-zA-Z]\w*$/,
            msgFail    => 'Bad attribute name',
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
        locationRules => {
            keyTest => qr/^[a-zA-Z](?:[\w\-\.]*\w)?$/,
            msgFail => 'Bad virtual host name',
            '*'     => {
                keyTest => sub {
                    my $r = shift;
                    my $q;
                    eval { $q = qr/$r/ };
                    return ( $@ ? ( 0, $@ ) : 1 );
                },
                test => sub {
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
        exportedHeaders => {
            keyTest => qr/^[a-zA-Z](?:[\w\-\.]*\w)?$/,
            msgFail => 'Bad virtual host name',
            '*'     => {
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
    };
}

sub defaultConf {
    return {
        userDB     => 'LDAP',
        ldapServer => 'localhost',
    };
}

sub newNode {
    virtualHost => {
        '*' => {
            exportedHeaders => { 'Auth-User' => '$uid' },
            locationRules   => { 'default'   => 'deny' },
        }
      },
      groups               => { 'NewGroup'  => '0', },
      macro                => { 'NewMacro'  => '', },
      globalStorageOptions => { 'NewOption' => '', },
      ;
}

1;
