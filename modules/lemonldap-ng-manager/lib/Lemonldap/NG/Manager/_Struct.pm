## @file
# Manager tree structure and tests

## @class
# Manager tree structure and tests
package Lemonldap::NG::Manager::_Struct;

use strict;
use Lemonldap::NG::Common::Conf::SAML::Metadata;

our $VERSION = '0.1';

## @method protected hashref cstruct(hashref h,string k)
# Merge $h with the structure produced with $k and return it.
# Used to manage virtual hosts, and metadatas (IDP, SP).
#@param $h Result of struct()
#@param $k Full path of the key
#@return Tree structure
sub cstruct {
    shift;
    my ( $h, $k ) = @_;
    my @tmp = split(/\//, $k);
    return $h unless (scalar(@tmp) > 1);
    my $k1 = $tmp[0];
    my $k2 = $tmp[1];
    if ($k1 =~ /virtualHosts/i)
    {
    %$h = (
        %$h,
        virtualHosts => {
              $k2 => {
                _nodes => [qw(rules:rules:rules headers)],
                rules  => {
                      _nodes => ["hash:/locationRules/$k2:rules:rules"],
                    _js    => 'rulesRoot'
                },
                headers => {
                      _nodes => ["hash:/exportedHeaders/$k2"],
                      _js    => 'hashRoot'
                    },
                }
            }
        );
    }
    elsif ($k1 =~ /samlIDPMetaData/i)
    {
      %$h = (
          %$h,
          samlIDPMetaData => {
              $k2 => {
                  _nodes => [
                      qw(samlIDPMetaDataExportedAttributes samlIDPMetaDataXML)
                    ],
                  samlIDPMetaDataExportedAttributes => {
                      _nodes => [
                          "hash:/samlIDPMetaDataExportedAttributes/$k2"
                        . ":samlIDPMetaDataExportedAttributes:btext"
                        ],
                    _js    => 'hashRoot'
                },
                  samlIDPMetaDataXML => "samlmetadata:/samlIDPMetaDataXML/$k2"
                                      . ":samlIDPMetaDataXML:textarea",
            }
        }
    );
    }
    return $h;
}

## @method protected hashref struct(hashref h,string k)
# Returns the tree structure
#@return Tree structure
sub struct {
    my $self = shift;
    return {
        _nodes => [qw(n:generalParameters n:variables n:virtualHosts n:samlServiceMetaData n:samlIDPMetaData)],
        _help  => 'default',

        ######################
        # GENERAL PARAMETERS #
        ######################
        generalParameters => {
            _nodes => [
                qw(portalParams n:authParams logParams cookieParams sessionParams n:advancedParams)
            ],
            _help  => 'default',

            # PORTAL PARAMETERS
            portalParams => {
                _nodes => [
                    qw(portal portalSkin portalDisplayLogout portalDisplayResetPassword portalDisplayChangePassword portalDisplayAppslist portalAutocomplete portalRequireOldPassword portalUserAttr portalOpenLinkInNewWindow)
                ],
                _help => 'portalParams',

            portal => 'text:/portal',
                portalSkin          => 'text:/portalSkin',
                portalDisplayLogout => 'text:/portalDisplayLogout',
                portalDisplayResetPassword =>
                  'text:/portalDisplayResetPassword',
                portalDisplayChangePassword =>
                  'text:/portalDisplayChangePassword',
                portalDisplayAppslist     => 'text:/portalDisplayAppslist',
                portalAutocomplete        => 'bool:/portalAutocomplete',
                portalRequireOldPassword  => 'bool:/portalRequireOldPassword',
                portalUserAttr            => 'text:/portalUserAttr',
                portalOpenLinkInNewWindow => 'bool:/portalOpenLinkInNewWindow',
            },

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

            # SESSIONS PARAMETERS
            sessionParams => {
                _nodes => [
                    qw(sessionStorage grantSessionRule singleSession singleIP singleUserByIP notifyDeleted notifyOther timeout storePassword)
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
                notifyOther    => 'bool:/notifyOther',
                storePassword  => 'bool:/storePassword',
                timeout        => 'text:/timeout:timeout:text',
                grantSessionRule => 'text:/grantSessionRule',
            },

            # OTHER PARAMETERS
            advancedParams => {
                _nodes => [
                    qw(Soap exportedAttr trustedDomains https notifications passwordManagement userControl portalForceAuthn)
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
                portalForceAuthn =>
                  'bool:/portalForceAuthn:portalForceAuthn:bool',
            }
        },

        #############
        # VARIABLES #
        #############

        variables => {
            _nodes => [qw(cn:exportedVars cn:macros n:groups)],
            _help  => 'default',

            # EXPORTED ATTRIBUTES
            exportedVars => {
                _nodes => ['hash:/exportedVars:vars:btext'],
                _js    => 'hashRoot',
            },

            # MACROS
            macros => {
                _nodes => ['hash:/macros:macros:btext'],
                _js    => 'hashRoot',
            },

            # GROUPS
            groups => {
                _nodes => ['hash:/groups:groups:btext'],
                _js    => 'hashRoot',
                _help  => 'default',
            },
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

        ########
        # SAML #
        ########
            samlIDPMetaData => {
                _nodes  => ['nhash:/samlIDPMetaDataExportedAttributes:samlIDPMetaData:samlMetaData'],
                _upload => ['/samlIDPMetaDataXML'],
                _help   => 'default',
                _call   => '$(\'#newsamlmetadatab\').show();',
            },

            samlServiceMetaData => {
                _nodes => [
                    qw(samlEntityID
                   samlServicePrivateKey
                       n:samlOrganization
                       n:samlSPSSODescriptor
                       n:samlIDPSSODescriptor)
                  ],
                _help  => 'default',

                # GLOBAL INFORMATIONS
                samlEntityID => 'text:/samlEntityID',
            samlServicePrivateKey =>
              'textarea:/samlServicePrivateKey:samlServicePrivateKey:textarea',
                samlOrganization => {
                    _nodes => [
                        qw(samlOrganizationDisplayName
                           samlOrganizationName
                           samlOrganizationURL)
                      ],
                    _help  => 'default',
                    samlOrganizationDisplayName =>
                        'text:/samlOrganizationDisplayName',
                    samlOrganizationURL => 'text:/samlOrganizationURL',
                    samlOrganizationName => 'text:/samlOrganizationName',
                  },

                # SERVICE PROVIDER
                'samlSPSSODescriptor' => {
                    _nodes => [
                        qw(samlSPSSODescriptorAuthnRequestsSigned
                           samlSPSSODescriptorProtocolSupportEnumeration
                           samlSPSSODescriptorKeyDescriptorSigning
                           n:samlSPSSODescriptorSingleLogoutService
                           n:samlSPSSODescriptorAssertionConsumerService
                           n:samlSPSSODescriptorNameIDFormat)
                      ],
                    _help  => 'default',

                    samlSPSSODescriptorAuthnRequestsSigned =>
                      'bool:/samlSPSSODescriptorAuthnRequestsSigned',
                    samlSPSSODescriptorProtocolSupportEnumeration =>
                      'text:/samlSPSSODescriptorProtocolSupportEnumeration',
                    samlSPSSODescriptorKeyDescriptorSigning =>
                      'textarea:/samlSPSSODescriptorKeyDescriptorSigning',

                    samlSPSSODescriptorSingleLogoutService => {
                        _nodes => [
                            qw(samlSPSSODescriptorSingleLogoutServiceHTTP
                               samlSPSSODescriptorSingleLogoutServiceSOAP)
                          ],
                        _help  => 'default',
                        samlSPSSODescriptorSingleLogoutServiceHTTP =>
'samlService:/samlSPSSODescriptorSingleLogoutServiceHTTP',
                        samlSPSSODescriptorSingleLogoutServiceSOAP =>
'samlService:/samlSPSSODescriptorSingleLogoutServiceSOAP',
                      },

                    samlSPSSODescriptorAssertionConsumerService => {
                        _nodes => [
                            qw(samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact
                               samlSPSSODescriptorAssertionConsumerServiceHTTPPost
                               samlSPSSODescriptorAssertionConsumerServiceHTTPRedirect)
                          ],
                        _help  => 'default',
                        samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact =>
'samlAssertion:/samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact',
                        samlSPSSODescriptorAssertionConsumerServiceHTTPPost =>
'samlAssertion:/samlSPSSODescriptorAssertionConsumerServiceHTTPPost',
                        samlSPSSODescriptorAssertionConsumerServiceHTTPRedirect =>
'samlAssertion:/samlSPSSODescriptorAssertionConsumerServiceHTTPRedirect',
                    },

                    samlSPSSODescriptorNameIDFormat => {
                        _nodes => [
                            qw(samlSPSSODescriptorNameIDFormatX509SubjectName
                               samlSPSSODescriptorNameIDFormatPersistent
                               samlSPSSODescriptorNameIDFormatTransient)
                        ],
                        _help => 'default',
                        samlSPSSODescriptorNameIDFormatX509SubjectName =>
'bool:/samlSPSSODescriptorNameIDFormatX509SubjectName:samlNameIDFormatX509SubjectName:bool',
                        samlSPSSODescriptorNameIDFormatPersistent =>
'bool:/samlSPSSODescriptorNameIDFormatPersistent:samlNameIDFormatPersistent:bool',
                        samlSPSSODescriptorNameIDFormatTransient =>
'bool:/samlSPSSODescriptorNameIDFormatTransient:samlNameIDFormatTransient:bool',
                      },
                  },

                # IDENTITY PROVIDER
                samlIDPSSODescriptor => {
                    _nodes => [
                        qw(samlIDPSSODescriptorWantAuthnRequestsSigned
                           samlIDPSSODescriptorProtocolSupportEnumeration
                           samlIDPSSODescriptorKeyDescriptorSigning
                           n:samlIDPSSODescriptorSingleSignOnService
                           n:samlIDPSSODescriptorSingleLogoutService
                           n:samlIDPSSODescriptorArtifactResolutionService
                           n:samlIDPSSODescriptorNameIDFormat
                           n:samlIDPSSODescriptorManageNameIDService)
                      ],
                    _help  => 'default',

                    samlIDPSSODescriptorWantAuthnRequestsSigned =>
                        'bool:/samlIDPSSODescriptorWantAuthnRequestsSigned',
                    samlIDPSSODescriptorProtocolSupportEnumeration =>
                        'text:/samlIDPSSODescriptorProtocolSupportEnumeration',
                    samlIDPSSODescriptorKeyDescriptorSigning =>
                        'textarea:/samlIDPSSODescriptorKeyDescriptorSigning',

                    samlIDPSSODescriptorSingleSignOnService => {
                        _nodes => [
                            qw(samlIDPSSODescriptorSingleSignOnServiceHTTP
                               samlIDPSSODescriptorSingleSignOnServiceSOAP)
                          ],
                        _help => 'default',
                        samlIDPSSODescriptorSingleSignOnServiceHTTP =>
'samlService:/samlIDPSSODescriptorSingleSignOnServiceHTTP',
                        samlIDPSSODescriptorSingleSignOnServiceSOAP =>
'samlService:/samlIDPSSODescriptorSingleSignOnServiceSOAP',
                      },

                    samlIDPSSODescriptorSingleLogoutService => {
                        _nodes => [
                            qw(samlIDPSSODescriptorSingleLogoutServiceHTTP
                               samlIDPSSODescriptorSingleLogoutServiceSOAP)
                          ],
                        _help  => 'default',
                        samlIDPSSODescriptorSingleLogoutServiceHTTP =>
'samlService:/samlIDPSSODescriptorSingleLogoutServiceHTTP',
                        samlIDPSSODescriptorSingleLogoutServiceSOAP =>
'samlService:/samlIDPSSODescriptorSingleLogoutServiceSOAP',
                      },

                    samlIDPSSODescriptorArtifactResolutionService => {
                        _nodes => [
                            qw(samlIDPSSODescriptorArtifactResolutionServiceArtifact)
                          ],
                        _help  => 'default',
                        samlIDPSSODescriptorArtifactResolutionServiceArtifact =>
'samlAssertion:/samlIDPSSODescriptorArtifactResolutionServiceArtifact',
                    },

                    samlIDPSSODescriptorNameIDFormat => {
                        _nodes => [
                            qw(samlIDPSSODescriptorNameIDFormatX509SubjectName
                               samlIDPSSODescriptorNameIDFormatPersistent
                               samlIDPSSODescriptorNameIDFormatTransient)
                        ],
                        _help => 'default',
                        samlIDPSSODescriptorNameIDFormatX509SubjectName =>
'bool:/samlIDPSSODescriptorNameIDFormatX509SubjectName:samlNameIDFormatX509SubjectName:bool',
                        samlIDPSSODescriptorNameIDFormatPersistent =>
'bool:/samlIDPSSODescriptorNameIDFormatPersistent:samlNameIDFormatPersistent:bool',
                        samlIDPSSODescriptorNameIDFormatTransient =>
'bool:/samlIDPSSODescriptorNameIDFormatTransient:samlNameIDFormatTransient:bool',
                      },

                    samlIDPSSODescriptorManageNameIDService => {
                        _nodes => [
                            qw(samlIDPSSODescriptorManageNameIDServiceHTTP
                               samlIDPSSODescriptorManageNameIDServiceSOAP)
                          ],
                        _help  => 'default',
                        samlIDPSSODescriptorManageNameIDServiceHTTP =>
'samlService:/samlIDPSSODescriptorManageNameIDServiceHTTP',
                        samlIDPSSODescriptorManageNameIDServiceSOAP =>
'samlService:/samlIDPSSODescriptorManageNameIDServiceSOAP',
                      },
                  },
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
        grantSessionRule => {
            test     => $perlExpr,
            warnTest => sub {
                my $e = shift;
                return ( 0, $assignMsg ) if ( $e =~ $assignTest );
                1;
            },
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
        notifyOther   => $boolean,
        portal        => {
            test    => qr/^https?:\/\/\S+$/,
            msgFail => 'Bad portal value',
        },
        portalAutocomplete          => $boolean,
        portalDisplayAppslist       => { test => $perlExpr, },
        portalDisplayChangePassword => { test => $perlExpr, },
        portalDisplayLogout         => { test => $perlExpr, },
        portalDisplayResetPassword  => $boolean,
        portalForceAuthn            => $boolean,
        portalOpenLinkInNewWindow   => $boolean,
        portalParams                => $testNotDefined,
        portalRequireOldPassword    => $boolean,
        portalSkin                  => {
            test    => qr/\w+$/,
            msgFail => 'Bad skin name',
        },
        portalUserAttr => {
            test    => qr/\w+$/,
            msgFail => 'Unvalid session field',
        },
        protection => {
            keyTest => qr/^(?:none|authentificate|manager|)$/,
            msgFail => 'must be one of none authentificate manager',
        },
        saml                  => $testNotDefined,
        samlServiceMetaData   => $testNotDefined,
        samlServicePrivateKey => $testNotDefined,
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
        variables          => $testNotDefined,
        whatToTrace        => {
            test    => qr/^\$?[a-zA-Z]\w*$/,
            msgFail => 'Bad value',
        },
        ########
        # SAML #
        ########
        samlIDPMetaData => $testNotDefined,
        samlIDPMetaDataXML => $testNotDefined,
        samlIDPMetaDataExportedAttributes => $testNotDefined,
        samlServicePrivateKey => $testNotDefined,
        samlEntityID => $testNotDefined,
        samlOrganizationDisplayName => $testNotDefined,
        samlOrganizationName => $testNotDefined,
        samlOrganizationURL => $testNotDefined,
        samlSPSSODescriptorAuthnRequestsSigned => $boolean,
        samlSPSSODescriptorProtocolSupportEnumeration => $testNotDefined,
        samlSPSSODescriptorKeyDescriptorSigning => $testNotDefined,
        samlSPSSODescriptorSingleLogoutServiceHTTP => $testNotDefined,
        samlSPSSODescriptorSingleLogoutServiceSOAP => $testNotDefined,
        samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact =>
          $testNotDefined,
        samlSPSSODescriptorAssertionConsumerServiceHTTPPost => $testNotDefined,
        samlSPSSODescriptorAssertionConsumerServiceHTTPRedirect =>
          $testNotDefined,
        samlSPSSODescriptorNameIDFormatX509SubjectName => $boolean,
        samlSPSSODescriptorNameIDFormatPersistent      => $boolean,
        samlSPSSODescriptorNameIDFormatTransient       => $boolean,
        samlIDPSSODescriptorWantAuthnRequestsSigned => $boolean,
        samlIDPSSODescriptorProtocolSupportEnumeration => $testNotDefined,
        samlIDPSSODescriptorKeyDescriptorSigning => $testNotDefined,
        samlIDPSSODescriptorSingleSignOnServiceHTTP => $testNotDefined,
        samlIDPSSODescriptorSingleSignOnServiceSOAP => $testNotDefined,
        samlIDPSSODescriptorSingleLogoutServiceHTTP => $testNotDefined,
        samlIDPSSODescriptorSingleLogoutServiceSOAP => $testNotDefined,
        samlIDPSSODescriptorArtifactResolutionServiceArtifact =>
          $testNotDefined,
        samlIDPSSODescriptorNameIDFormatX509SubjectName => $boolean,
        samlIDPSSODescriptorNameIDFormatPersistent      => $boolean,
        samlSPSSODescriptorNameIDFormatTransient        => $boolean,
        samlIDPSSODescriptorManageNameIDServiceHTTP => $testNotDefined,
        samlIDPSSODescriptorManageNameIDServiceSOAP => $testNotDefined,
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
        notifyOther        => '1',
        portal             => 'http://auth.example.com/',
	portalSkin         => 'pastel',
	portalUserAttr     => '_user',
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
        ########
        # SAML #
        ########
        samlIDPMetaData => '',
        samlIDPMetaDataXML => '',
        samlIDPMetaDataExportedAttributes => '',
        samlServicePrivateKey => '',
        samlEntityID                => 'http://auth.example.com/saml/metadata',
        samlOrganizationDisplayName => 'Example',
        samlOrganizationName => 'Example',
        samlOrganizationURL => 'http://www.example.com',
        samlSPSSODescriptorAuthnRequestsSigned => '0',
        samlSPSSODescriptorProtocolSupportEnumeration =>
          'urn:oasis:names:tc:SAML:2.0:protocol',
        samlSPSSODescriptorKeyDescriptorSigning => '',
        samlSPSSODescriptorSingleLogoutServiceHTTP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;'
          . 'http://auth.example.com/saml/proxySingleLogout;'
          . 'http://auth.example.com/saml/proxySingleLogoutReturn',
        samlSPSSODescriptorSingleLogoutServiceSOAP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:SOAP;'
          . 'http://auth.example.com/saml/proxySingleLogoutSOAP;',
        samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact =>
          '1;0;urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact;'
          . 'http://auth.example.com/saml/proxySingleSignOnArtifact',
        samlSPSSODescriptorAssertionConsumerServiceHTTPPost =>
          '0;1;urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST;'
          . 'http://auth.example.com/saml/proxySingleSignOnPost',
        samlSPSSODescriptorAssertionConsumerServiceHTTPRedirect =>
          '0;2;urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;'
          . 'http://auth.example.com/saml/proxySingleSignOnRedirect',
        samlSPSSODescriptorNameIDFormatX509SubjectName => '0',
        samlSPSSODescriptorNameIDFormatPersistent      => '1',
        samlSPSSODescriptorNameIDFormatTransient       => '0',
        samlIDPSSODescriptorWantAuthnRequestsSigned => '0',
        samlIDPSSODescriptorProtocolSupportEnumeration =>
          'urn:oasis:names:tc:SAML:2.0:protocol',
        samlIDPSSODescriptorKeyDescriptorSigning => '',
        samlIDPSSODescriptorSingleSignOnServiceHTTP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;'
          . 'http://auth.example.com/saml/singleSignOn;',
        samlIDPSSODescriptorSingleSignOnServiceSOAP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:SOAP;'
          . 'http://auth.example.com/saml/singleSignOnSOAP;',
        samlIDPSSODescriptorSingleLogoutServiceHTTP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;'
          . 'http://auth.example.com/saml/singleLogout;'
          . 'http://auth.example.com/saml/singleLogoutReturn',
        samlIDPSSODescriptorSingleLogoutServiceSOAP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:SOAP;'
          . 'http://auth.example.com/saml/singleLogoutSOAP;',
        samlIDPSSODescriptorArtifactResolutionServiceArtifact =>
          '1;0;urn:oasis:names:tc:SAML:2.0:bindings:SOAP;'
          . 'http://auth.example.com/saml/artifact',
        samlIDPSSODescriptorManageNameIDServiceHTTP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;'
          . 'http://auth.example.com/saml/manageNameId;'
          . 'http://auth.example.com/saml/manageNameIdReturn',
        samlIDPSSODescriptorManageNameIDServiceSOAP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:SOAP;'
          . 'http://auth.example.com/saml/manageNameIdSOAP;',
        samlIDPSSODescriptorNameIDFormatX509SubjectName => '0',
        samlIDPSSODescriptorNameIDFormatPersistent      => '1',
        samlIDPSSODescriptorNameIDFormatTransient       => '0',
    };
}

sub subDefaultConf {
    return {
        locationRules   => { default     => 'deny' },
        exportedHeaders => { 'Auth-User' => '$uid' },
    };
}

1;
