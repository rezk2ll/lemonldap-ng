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
    my @tmp = split( /\//, $k );
    return $h unless ( scalar(@tmp) > 1 );
    my $k1 = $tmp[0];
    my $k2 = $tmp[1];
    if ( $k1 =~ /^virtualHosts/i ) {
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
    elsif ( $k1 =~ /^samlIDPMetaDataNode/i ) {
        %$h = (
            %$h,
            samlIDPMetaDataNode => {
                $k2 => {
                    _nodes => [
                        qw(samlIDPMetaDataXML samlIDPMetaDataExportedAttributes samlIDPMetaDataOptions)
                    ],
                    samlIDPMetaDataExportedAttributes => {
                        _nodes => [
                                "hash:/samlIDPMetaDataExportedAttributes/$k2"
                              . ":samlIDPMetaDataExportedAttributes:samlAttribute"
                        ],
                        _js => 'samlAttributeRoot'
                    },
                    samlIDPMetaDataXML => "samlmetadata:/samlIDPMetaDataXML/$k2"
                      . ":samlIDPMetaDataXML:filearea",
                    samlIDPMetaDataOptions => {
                        _nodes => [
                            qw(samlIDPMetaDataOptionsNameIDFormat samlIDPMetaDataOptionsForceAuthn samlIDPMetaDataOptionsAllowProxiedAuthn samlIDPMetaDataOptionsSSOBinding samlIDPMetaDataOptionsSLOBinding samlIDPMetaDataOptionsResolutionRule)
                        ],
                        samlIDPMetaDataOptionsNameIDFormat =>
"text:/samlIDPMetaDataOptions/$k2/samlIDPMetaDataOptionsNameIDFormat",
                        samlIDPMetaDataOptionsForceAuthn =>
"bool:/samlIDPMetaDataOptions/$k2/samlIDPMetaDataOptionsForceAuthn",
                        samlIDPMetaDataOptionsAllowProxiedAuthn =>
"bool:/samlIDPMetaDataOptions/$k2/samlIDPMetaDataOptionsAllowProxiedAuthn",
                        samlIDPMetaDataOptionsSSOBinding =>
"text:/samlIDPMetaDataOptions/$k2/samlIDPMetaDataOptionsSSOBinding",
                        samlIDPMetaDataOptionsSLOBinding =>
"text:/samlIDPMetaDataOptions/$k2/samlIDPMetaDataOptionsSLOBinding",
                        samlIDPMetaDataOptionsResolutionRule =>
"textarea:/samlIDPMetaDataOptions/$k2/samlIDPMetaDataOptionsResolutionRule",
                    },
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
        _nodes => [
            qw(n:generalParameters n:variables n:virtualHosts n:samlServiceMetaData n:samlIDPMetaDataNode)
        ],
        _help => 'default',

        ######################
        # GENERAL PARAMETERS #
        ######################
        generalParameters => {
            _nodes => [
                qw(n:portalParams n:authParams n:logParams n:cookieParams n:sessionParams n:advancedParams)
            ],
            _help => 'default',

            # PORTAL PARAMETERS
            portalParams => {
                _nodes => [qw(portal n:portalModules n:portalCustomization)],
                _help  => 'portalParams',

                portal => 'text:/portal:portal:text',

                portalModules => {
                    _nodes => [
                        qw(portalDisplayLogout portalDisplayResetPassword portalDisplayChangePassword portalDisplayAppslist)
                    ],
                    portalDisplayLogout => 'text:/portalDisplayLogout',
                    portalDisplayResetPassword =>
                      'text:/portalDisplayResetPassword',
                    portalDisplayChangePassword =>
                      'text:/portalDisplayChangePassword',
                    portalDisplayAppslist => 'text:/portalDisplayAppslist',
                },

                portalCustomization => {
                    _nodes => [
                        qw(portalSkin portalAutocomplete portalRequireOldPassword portalUserAttr portalOpenLinkInNewWindow)
                    ],

                    portalSkin         => 'text:/portalSkin',
                    portalAutocomplete => 'bool:/portalAutocomplete',
                    portalRequireOldPassword =>
                      'bool:/portalRequireOldPassword',
                    portalUserAttr => 'text:/portalUserAttr',
                    portalOpenLinkInNewWindow =>
                      'bool:/portalOpenLinkInNewWindow',
                },
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
                    my $pdb = $self->conf->{passwordDB}
                      || $self->defaultConf()->{passwordDB};
                    $auth = lc($auth);
                    $udb  = lc($udb);
                    $pdb  = lc($pdb);
                    my %res;

                    foreach my $mod (
                        (
                            $auth,
                            ( $udb ne ( $auth or $pdb ) ? $udb : () ),
                            ( $pdb ne ( $auth or $udb ) ? $pdb : () )
                        )
                      )
                    {
                        my $tmp = {
                            ldap    => ['ldapParams'],
                            ssl     => [qw(ldapParams sslParams)],
                            cas     => ['casParams'],
                            remote  => ['remoteParams'],
                            proxy   => ['proxyParams'],
                            openid  => ['openIdParams'],
                            twitter => ['twitterParams'],
                            dbi     => ['dbiParams'],
                        }->{$mod};
                        if ($tmp) {
                            $res{$_}++ foreach (@$tmp);
                        }
                    }
                    my @u = keys %res;

              # Add authentication, userDB and passwordDB nodes at the beginning
                    unshift( @u, "passwordDB" );
                    unshift( @u, "userDB" );
                    unshift( @u, "authentication" );

                    # Return nodes
                    return \@u;
                },

                _help => 'authParams',

                authentication => 'text:/authentication:authParams:authParams',
                userDB         => 'text:/userDB:authParams:userdbParams',
                passwordDB => 'text:/passwordDB:authParams:passworddbParams',

                # LDAP
                ldapParams => {
                    _nodes => [
                        qw(n:ldapConnection n:ldapFilters n:ldapGroups n:ldapPassword)
                    ],
                    _help => 'ldap',

                    ldapConnection => {
                        _nodes => [
                            qw(ldapServer ldapPort ldapBase managerDn managerPassword)
                        ],
                        ldapServer      => 'text:/ldapServer',
                        ldapPort        => 'int:/ldapPort',
                        ldapBase        => 'text:/ldapBase',
                        managerDn       => 'text:/managerDn',
                        managerPassword => 'text:/managerPassword',
                    },

                    ldapFilters => {
                        _nodes =>
                          [qw(LDAPFilter AuthLDAPFilter mailLDAPFilter)],
                        LDAPFilter     => 'text:/LDAPFilter',
                        AuthLDAPFilter => 'text:/AuthLDAPFilter',
                        mailLDAPFilter => 'text:/mailLDAPFilter',
                    },

                    ldapGroups => {
                        _nodes => [
                            qw(ldapGroupBase ldapGroupObjectClass ldapGroupAttributeName ldapGroupAttributeNameUser ldapGroupAttributeNameSearch ldapGroupRecursive ldapGroupAttributeNameGroup)
                        ],
                        ldapGroupBase        => 'text:/ldapGroupBase',
                        ldapGroupObjectClass => 'text:/ldapGroupObjectClass',
                        ldapGroupAttributeName =>
                          'text:/ldapGroupAttributeName',
                        ldapGroupAttributeNameUser =>
                          'text:/ldapGroupAttributeNameUser',
                        ldapGroupAttributeNameSearch =>
                          'text:/ldapGroupAttributeNameSearch',
                        ldapGroupRecursive => 'bool:/ldapGroupRecursive',
                        ldapGroupAttributeNameGroup =>
                          'text:/ldapGroupAttributeNameGroup',
                    },

                    ldapPassword => {
                        _nodes => [qw(ldapPpolicyControl ldapSetPassword)],
                        ldapPpolicyControl => 'bool:/ldapPpolicyControl',
                        ldapSetPassword    => 'bool:/ldapSetPassword',
                    },

                },

                # SSL
                sslParams => {
                    _nodes       => [qw(SSLVar SSLLDAPField SSLRequire)],
                    SSLVar       => 'text:/SSLVar',
                    SSLLDAPField => 'text:/SSLLDAPField',
                    SSLRequire   => 'bool:/SSLRequire',
                },

                # CAS
                casParams => {
                    _nodes =>
                      [qw(CAS_url CAS_loginUrl CAS_validationUrl CAS_CAFile)],
                    CAS_url           => 'text:/CAS_url',
                    CAS_loginUrl      => 'text:/CAS_loginUrl',
                    CAS_validationUrl => 'text:/CAS_validationUrl',
                    CAS_CAFile        => 'text:/CAS_CAFile',
                },

                # Remote
                remoteParams => {
                    _nodes => [
                        qw(remotePortal remoteGlobalStorage remoteGlobalStorageOptions)
                    ],
                    remotePortal        => 'text:/remotePortal',
                    remoteGlobalStorage => 'text:/remoteGlobalStorage',
                    remoteGlobalStorageOptions =>
                      { _nodes => ['hash:/remoteGlobalStorageOptions'], },
                },

                # Proxy
                proxyParams => {
                    _nodes =>
                      [qw(soapAuthService remoteCookieName soapSessionService)],
                    soapAuthService    => 'text:/soapAuthService',
                    remoteCookieName   => 'text:/remoteCookieName',
                    soapSessionService => 'text:/soapSessionService',
                },

                # OpenID
                openIdParams => {
                    _nodes       => [qw(openIdSecret)],
                    openIdSecret => 'text:/openIdSecret',
                },

                # Twitter
                twitterParams => {
                    _nodes     => [qw(twitterKey twitterSecret twitterAppName)],
                    twitterKey => 'text:/twitterKey',
                    twitterSecret  => 'text:/twitterSecret',
                    twitterAppName => 'text:/twitterAppName',
                },

                # DBI
                dbiParams => {
                    _nodes => [qw(n:dbiConnection n:dbiSchema n:dbiPassword)],

                    dbiConnection => {
                        _nodes => [qw(n:dbiConnectionAuth n:dbiConnectionUser)],

                        dbiConnectionAuth => {
                            _nodes =>
                              [qw(dbiAuthChain dbiAuthUser dbiAuthPassword)],
                            dbiAuthChain    => 'text:/dbiAuthChain',
                            dbiAuthUser     => 'text:/dbiAuthUser',
                            dbiAuthPassword => 'text:/dbiAuthPassword',
                        },

                        dbiConnectionUser => {
                            _nodes =>
                              [qw(dbiUserChain dbiUserUser dbiUserPassword)],
                            dbiUserChain    => 'text:/dbiUserChain',
                            dbiUserUser     => 'text:/dbiUserUser',
                            dbiUserPassword => 'text:/dbiUserPassword',
                        },
                    },

                    dbiSchema => {
                        _nodes => [
                            qw(dbiAuthTable dbiUserTable dbiAuthLoginCol dbiAuthPasswordCol dbiAuthMailCol userPivot)
                        ],
                        dbiAuthTable       => 'text:/dbiAuthTable',
                        dbiUserTable       => 'text:/dbiUserTable',
                        dbiAuthLoginCol    => 'text:/dbiAuthLoginCol',
                        dbiAuthPasswordCol => 'text:/dbiAuthPasswordCol',
                        dbiAuthMailCol     => 'text:/dbiAuthMailCol',
                        userPivot          => 'text:/userPivot',
                    },

                    dbiPassword => {
                        _nodes              => [qw(dbiAuthPasswordHash)],
                        dbiAuthPasswordHash => 'text:/dbiAuthPasswordHash',
                    },
                },
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
                  [qw(cookieName domain cda securedCookie cookieExpiration)],
                _help      => 'cookies',
                cookieName => 'text:/cookieName:cookieName:text',
                domain     => 'text:/domain:domain:text',
                cda        => 'bool:/cda',
                securedCookie =>
                  'select:/securedCookie:securedCookie:securedCookieValues',
                cookieExpiration => 'text:/cookieExpiration',
            },

            # SESSIONS PARAMETERS
            sessionParams => {
                _nodes => [
                    qw(grantSessionRule storePassword timeout n:sessionStorage n:multipleSessions)
                ],
                _help => 'storage',

                grantSessionRule => 'textarea:/grantSessionRule',
                storePassword    => 'bool:/storePassword',
                timeout          => 'text:/timeout:timeout:text',

                sessionStorage => {
                    _nodes        => [qw(globalStorage globalStorageOptions)],
                    globalStorage => 'text:/globalStorage',
                    globalStorageOptions => {
                        _nodes => ['hash:/globalStorageOptions'],
                        _js    => 'hashRoot'
                    },
                },

                multipleSessions => {
                    _nodes => [
                        qw(singleSession singleIP singleUserByIP notifyDeleted notifyOther)
                    ],
                    singleSession  => 'bool:/singleSession',
                    singleIP       => 'bool:/singleIP',
                    singleUserByIP => 'bool:/singleUserByIP',
                    notifyDeleted  => 'bool:/notifyDeleted',
                    notifyOther    => 'bool:/notifyOther',
                },
            },

            # OTHER PARAMETERS
            advancedParams => {
                _nodes => [
                    qw(customFunctions n:soap n:notifications n:passwordManagement n:security n:redirection)
                ],

                customFunctions => 'text:/customFunctions',

                soap => {
                    _nodes         => [qw(Soap exportedAttr trustedDomains)],
                    Soap           => 'bool:/Soap',
                    exportedAttr   => 'text:/exportedAttr',
                    trustedDomains => 'text:/trustedDomains',
                },

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
                        qw(SMTPServer mailUrl mailFrom mailSubject mailBody mailConfirmSubject mailConfirmBody randomPasswordRegexp)
                    ],
                    SMTPServer           => 'text:/SMTPServer',
                    mailUrl              => 'text:/mailUrl',
                    mailFrom             => 'text:/mailFrom',
                    mailSubject          => 'text:/mailSubject',
                    mailBody             => 'textarea:/mailBody',
                    mailConfirmSubject   => 'text:/mailConfirmSubject',
                    mailConfirmBody      => 'textarea:/mailConfirmBody',
                    randomPasswordRegexp => 'text:/randomPasswordRegexp',
                },

                security => {
                    _nodes      => [qw(userControl portalForceAuthn)],
                    userControl => 'text:/userControl:userControl:text',
                    portalForceAuthn =>
                      'bool:/portalForceAuthn:portalForceAuthn:bool',
                },

                redirection => {
                    _nodes => [qw(https port)],
                    https  => 'bool:/https',
                    port   => 'int:/port',
                  }

            }
        },

        #############
        # VARIABLES #
        #############

        variables => {
            _nodes => [qw(cn:exportedVars cn:macros cn:groups)],
            _help  => 'default',

            # EXPORTED ATTRIBUTES
            exportedVars => {
                _nodes => ['hash:/exportedVars:vars:btext'],
                _js    => 'hashRoot',
		_help  => 'vars',
            },

            # MACROS
            macros => {
                _nodes => ['hash:/macros:macros:btext'],
                _js    => 'hashRoot',
		_help  => 'macros',
            },

            # GROUPS
            groups => {
                _nodes => ['hash:/groups:groups:btext'],
                _js    => 'hashRoot',
		_help  => 'groups',
            },
        },

        #################
        # VIRTUAL HOSTS #
        #################
        virtualHosts => {
            _nodes  => ['nhash:/locationRules:virtualHosts:vhost'],
            _upload => ['/exportedHeaders'],
            _help   => 'virtualHosts',
            _js     => 'vhostRoot',
        },

        ########
        # SAML #
        ########
        # virtual keys should not begin like configuration keys.
        samlIDPMetaDataNode => {
            _nodes => [
'nhash:/samlIDPMetaDataExportedAttributes:samlIDPMetaDataNode:samlMetaData'
            ],
            _upload => [ '/samlIDPMetaDataXML', '/samlIDPMetaDataOptions' ],
            _help   => 'default',
            _js     => 'samlIdpRoot',
        },

        samlServiceMetaData => {
            _nodes => [
                qw(samlEntityID
                  samlServicePrivateKey
                  n:samlOrganization
                  n:samlSPSSODescriptor
                  n:samlIDPSSODescriptor)
            ],
            _help => 'default',

            # GLOBAL INFORMATIONS
            samlEntityID => 'text:/samlEntityID',
            samlServicePrivateKey =>
              'filearea:/samlServicePrivateKey:samlServicePrivateKey:filearea',
            samlOrganization => {
                _nodes => [
                    qw(samlOrganizationDisplayName
                      samlOrganizationName
                      samlOrganizationURL)
                ],
                _help => 'default',
                samlOrganizationDisplayName =>
                  'text:/samlOrganizationDisplayName',
                samlOrganizationURL  => 'text:/samlOrganizationURL',
                samlOrganizationName => 'text:/samlOrganizationName',
            },

            # SERVICE PROVIDER
            'samlSPSSODescriptor' => {
                _nodes => [
                    qw(samlSPSSODescriptorAuthnRequestsSigned
                      samlSPSSODescriptorKeyDescriptorSigning
                      n:samlSPSSODescriptorSingleLogoutService
                      n:samlSPSSODescriptorAssertionConsumerService
                      n:samlSPSSODescriptorNameIDFormat)
                ],
                _help => 'default',

                samlSPSSODescriptorAuthnRequestsSigned =>
                  'bool:/samlSPSSODescriptorAuthnRequestsSigned',
                samlSPSSODescriptorKeyDescriptorSigning =>
                  'filearea:/samlSPSSODescriptorKeyDescriptorSigning',

                samlSPSSODescriptorSingleLogoutService => {
                    _nodes => [
                        qw(samlSPSSODescriptorSingleLogoutServiceHTTP
                          samlSPSSODescriptorSingleLogoutServiceSOAP)
                    ],
                    _help => 'default',
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
                    _help => 'default',
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
                      samlIDPSSODescriptorKeyDescriptorSigning
                      n:samlIDPSSODescriptorSingleSignOnService
                      n:samlIDPSSODescriptorSingleLogoutService
                      n:samlIDPSSODescriptorArtifactResolutionService
                      n:samlIDPSSODescriptorNameIDFormat
                      n:samlIDPSSODescriptorManageNameIDService)
                ],
                _help => 'default',

                samlIDPSSODescriptorWantAuthnRequestsSigned =>
                  'bool:/samlIDPSSODescriptorWantAuthnRequestsSigned',
                samlIDPSSODescriptorKeyDescriptorSigning =>
                  'filearea:/samlIDPSSODescriptorKeyDescriptorSigning',

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
                    _help => 'default',
                    samlIDPSSODescriptorSingleLogoutServiceHTTP =>
'samlService:/samlIDPSSODescriptorSingleLogoutServiceHTTP',
                    samlIDPSSODescriptorSingleLogoutServiceSOAP =>
'samlService:/samlIDPSSODescriptorSingleLogoutServiceSOAP',
                },

                samlIDPSSODescriptorArtifactResolutionService => {
                    _nodes => [
                        qw(samlIDPSSODescriptorArtifactResolutionServiceArtifact)
                    ],
                    _help => 'default',
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
                    _help => 'default',
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
        return 1
          if ( $@ =~ /Global symbol "\$.*requires explicit package/ );
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
        mailUrl              => $testNotDefined,
        mailConfirmSubject   => $testNotDefined,
        mailConfirmBody      => $testNotDefined,
        authentication       => {
            test    => qr/^[a-zA-Z]+(?:\s[\w\s:;]+)?$/,
            msgFail => 'Bad module name',
        },
        cda        => $boolean,
        cookieName => {
            test    => qr/^[a-zA-Z]\w*$/,
            msgFail => 'Bad cookie name',
        },
        customFunctions => $testNotDefined,
        domain          => {
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
        ldapPpolicyControl           => $boolean,
        ldapSetPassword              => $boolean,
        mailLDAPFilter               => $testNotDefined,
        LDAPFilter                   => $testNotDefined,
        AuthLDAPFilter               => $testNotDefined,
        ldapGroupRecursive           => $boolean,
        ldapGroupObjectClass         => $testNotDefined,
        ldapGroupBase                => $testNotDefined,
        ldapGroupAttributeName       => $testNotDefined,
        ldapGroupAttributeNameUser   => $testNotDefined,
        ldapGroupAttributeNameSearch => $testNotDefined,
        ldapGroupAttributeNameGroup  => $testNotDefined,
        locationRules                => {
            keyTest => qr/^[a-zA-Z](?:[\w\-\.]*\w)?$/,
            msgFail => 'Bad virtual host name',
            '*'     => {
                keyTest => $pcre,
                test    => sub {
                    my $e = shift;
                    return 1 if ( $e =~ /^(?:accept|deny|unprotect)$/i );
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
                    return ( 0, $assignMsg ) if ( $e =~ $assignTest );
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
        port          => {
            test    => qr/^\d*$/,
            msgFail => 'Bad port number'
        },
        portal => {
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
        securedCookie         => {
            test    => qr/^(?:0|1|2)$/,
            msgFail => 'securedCookie must be 0, 1 or 2',
        },
        singleSession  => $boolean,
        singleIP       => $boolean,
        singleUserByIP => $boolean,
        Soap           => $boolean,
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
        samlIDPMetaDataExportedAttributes => {
            keyTest    => qr/^[a-zA-Z](?:[\w\-\.]*\w)?$/,
            keyMsgFail => 'Bad metadata name',
            '*'        => {
                keyTest    => qr/^\w([\w\-]*\w)?$/,
                keyMsgFail => 'Bad attribute name',
                test       => sub { return 1; },
            },
        },
        samlIDPMetaDataXML => {
            keyTest    => qr/^[a-zA-Z](?:[\w\-\.]*\w)?$/,
            keyMsgFail => 'Bad metadata name',
            '*'        => {
                test    => sub { return 1; },
                keyTest => sub { return 1; },
            },
        },
        samlIDPMetaDataOptions => {
            keyTest    => qr/^[a-zA-Z](?:[\w\-\.]*\w)?$/,
            keyMsgFail => 'Bad metadata name',
            '*'        => {
                test    => sub { return 1; },
                keyTest => sub { return 1; },
            },
        },
        samlServicePrivateKey                         => $testNotDefined,
        samlEntityID                                  => $testNotDefined,
        samlOrganizationDisplayName                   => $testNotDefined,
        samlOrganizationName                          => $testNotDefined,
        samlOrganizationURL                           => $testNotDefined,
        samlSPSSODescriptorAuthnRequestsSigned        => $boolean,
        samlSPSSODescriptorKeyDescriptorSigning       => $testNotDefined,
        samlSPSSODescriptorSingleLogoutServiceHTTP    => $testNotDefined,
        samlSPSSODescriptorSingleLogoutServiceSOAP    => $testNotDefined,
        samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact =>
          $testNotDefined,
        samlSPSSODescriptorAssertionConsumerServiceHTTPPost => $testNotDefined,
        samlSPSSODescriptorAssertionConsumerServiceHTTPRedirect =>
          $testNotDefined,
        samlSPSSODescriptorNameIDFormatX509SubjectName => $boolean,
        samlSPSSODescriptorNameIDFormatPersistent      => $boolean,
        samlSPSSODescriptorNameIDFormatTransient       => $boolean,
        samlIDPSSODescriptorWantAuthnRequestsSigned    => $boolean,
        samlIDPSSODescriptorKeyDescriptorSigning       => $testNotDefined,
        samlIDPSSODescriptorSingleSignOnServiceHTTP    => $testNotDefined,
        samlIDPSSODescriptorSingleSignOnServiceSOAP    => $testNotDefined,
        samlIDPSSODescriptorSingleLogoutServiceHTTP    => $testNotDefined,
        samlIDPSSODescriptorSingleLogoutServiceSOAP    => $testNotDefined,
        samlIDPSSODescriptorArtifactResolutionServiceArtifact =>
          $testNotDefined,
        samlIDPSSODescriptorNameIDFormatX509SubjectName => $boolean,
        samlIDPSSODescriptorNameIDFormatPersistent      => $boolean,
        samlSPSSODescriptorNameIDFormatTransient        => $boolean,
        samlIDPSSODescriptorManageNameIDServiceHTTP     => $testNotDefined,
        samlIDPSSODescriptorManageNameIDServiceSOAP     => $testNotDefined,

        # SSL
        SSLVar       => $testNotDefined,
        SSLLDAPField => $testNotDefined,
        SSLRequire   => $boolean,

        # CAS
        CAS_url           => $testNotDefined,
        CAS_loginUrl      => $testNotDefined,
        CAS_validationUrl => $testNotDefined,
        CAS_CAFile        => $testNotDefined,

        # Remote
        remotePortal        => $testNotDefined,
        remoteGlobalStorage => {
            test    => qr/^[\w:]+$/,
            msgFail => 'Bad module name',
        },
        remoteGlobalStorageOptions => {
            keyTest    => qr/^\w+$/,
            keyMsgFail => 'Bad parameter',
        },

        # Proxy
        soapAuthService    => $testNotDefined,
        remoteCookieName   => $testNotDefined,
        soapSessionService => $testNotDefined,

        # OpenID
        openIdSecret => $testNotDefined,

        # Twitter
        twitterKey     => $testNotDefined,
        twitterSecret  => $testNotDefined,
        twitterAppName => $testNotDefined,

        # DBI
        dbiAuthChain        => $testNotDefined,
        dbiAuthUser         => $testNotDefined,
        dbiAuthPassword     => $testNotDefined,
        dbiUserChain        => $testNotDefined,
        dbiUserUser         => $testNotDefined,
        dbiUserPassword     => $testNotDefined,
        dbiAuthTable        => $testNotDefined,
        dbiUserTable        => $testNotDefined,
        dbiAuthLoginCol     => $testNotDefined,
        dbiAuthPasswordCol  => $testNotDefined,
        dbiAuthMailCol      => $testNotDefined,
        userPivot           => $testNotDefined,
        dbiAuthPasswordHash => $testNotDefined,

    };
}

## @method protected hashref defaultConf()
#@return Hashref of default values
sub defaultConf {
    my $self = shift;
    my $portal =
      defined $self->{portal} ? $self->{portal} : 'http://auth.example.com';
    $portal =~ s/\/$//;
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
        notifyDeleted       => '1',
        notifyOther         => '1',
        portal              => $portal,
        portalSkin          => 'pastel',
        portalUserAttr      => '_user',
        protection          => 'none',
        remoteGlobalStorage => 'Lemonldap::NG::Common::Apache::Session::SOAP',
        securedCookie       => '0',
        singleSession       => '0',
        singleIP            => '0',
        singleUserByIP      => '0',
        Soap                => '1',
        SSLRequired         => '0',
        storePassword       => '0',
        syslog              => '',
        timeout             => '7200',
        userControl         => '^[\w\.\-@]+$',
        userDB              => 'LDAP',
        passwordDB          => 'LDAP',
        useXForwardedForIP  => '0',
        whatToTrace         => '$uid',
        ########
        # SAML #
        ########
        samlIDPMetaDataXML => { 'authentic' => {} },
        samlIDPMetaDataExportedAttributes =>
          { 'authentic' => { 'uid' => '0;uid;;' } },
        samlIDPMetaDataOptions => {
            'authentic' => {
                'samlIDPMetaDataOptionsNameIDFormat'      => '',
                'samlIDPMetaDataOptionsForceAuthn'        => '0',
                'samlIDPMetaDataOptionsAllowProxiedAuthn' => '1',
                'samlIDPMetaDataOptionsSSOBinding'        => '',
                'samlIDPMetaDataOptionsSLOBinding'        => '',
                'samlIDPMetaDataOptionsResolutionRule'    => '',
            }
        },
        samlServicePrivateKey                  => '',
        samlEntityID                           => $portal . '/saml/metadata',
        samlOrganizationDisplayName            => 'Example',
        samlOrganizationName                   => 'Example',
        samlOrganizationURL                    => 'http://www.example.com',
        samlSPSSODescriptorAuthnRequestsSigned => '0',
        samlSPSSODescriptorKeyDescriptorSigning => '',
        samlSPSSODescriptorSingleLogoutServiceHTTP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;' 
          . $portal
          . '/saml/proxySingleLogout;'
          . $portal
          . '/saml/proxySingleLogoutReturn',
        samlSPSSODescriptorSingleLogoutServiceSOAP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:SOAP;' 
          . $portal
          . '/saml/proxySingleLogoutSOAP;',
        samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact =>
          '1;0;urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact;' 
          . $portal
          . '/saml/proxySingleSignOnArtifact',
        samlSPSSODescriptorAssertionConsumerServiceHTTPPost =>
          '0;1;urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST;' 
          . $portal
          . '/saml/proxySingleSignOnPost',
        samlSPSSODescriptorAssertionConsumerServiceHTTPRedirect =>
          '0;2;urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;' 
          . $portal
          . '/saml/proxySingleSignOnRedirect',
        samlSPSSODescriptorNameIDFormatX509SubjectName => '0',
        samlSPSSODescriptorNameIDFormatPersistent      => '1',
        samlSPSSODescriptorNameIDFormatTransient       => '0',
        samlIDPSSODescriptorWantAuthnRequestsSigned    => '0',
        samlIDPSSODescriptorKeyDescriptorSigning => '',
        samlIDPSSODescriptorSingleSignOnServiceHTTP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;' 
          . $portal
          . '/saml/singleSignOn;',
        samlIDPSSODescriptorSingleSignOnServiceSOAP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:SOAP;' 
          . $portal
          . '/saml/singleSignOnSOAP;',
        samlIDPSSODescriptorSingleLogoutServiceHTTP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;' 
          . $portal
          . '/saml/singleLogout;'
          . $portal
          . '/saml/singleLogoutReturn',
        samlIDPSSODescriptorSingleLogoutServiceSOAP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:SOAP;' 
          . $portal
          . '/saml/singleLogoutSOAP;',
        samlIDPSSODescriptorArtifactResolutionServiceArtifact =>
          '1;0;urn:oasis:names:tc:SAML:2.0:bindings:SOAP;' 
          . $portal
          . '/saml/artifact',
        samlIDPSSODescriptorManageNameIDServiceHTTP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;' 
          . $portal
          . '/saml/manageNameId;'
          . $portal
          . '/saml/manageNameIdReturn',
        samlIDPSSODescriptorManageNameIDServiceSOAP =>
          'urn:oasis:names:tc:SAML:2.0:bindings:SOAP;' 
          . $portal
          . '/saml/manageNameIdSOAP;',
        samlIDPSSODescriptorNameIDFormatX509SubjectName => '0',
        samlIDPSSODescriptorNameIDFormatPersistent      => '1',
        samlIDPSSODescriptorNameIDFormatTransient       => '0',
    };
}

sub subDefaultConf {
    return {
        locationRules              => { default     => 'deny' },
        exportedHeaders            => { 'Auth-User' => '$uid' },
        remoteGlobalStorageOptions => {
            'proxy' => 'https://remote/index.pl/sessions',
            'ns'    => 'https://remote/Lemonldap/NG/Common/CGI/SOAPService',
        },
        samlIDPMetaDataXML                => {       {} },
        samlIDPMetaDataExportedAttributes => { 'uid' => '0;uid;;' },
        samlIDPMetaDataOptions            => {
            'samlIDPMetaDataOptionsNameIDFormat'      => '',
            'samlIDPMetaDataOptionsForceAuthn'        => '0',
            'samlIDPMetaDataOptionsAllowProxiedAuthn' => '1',
            'samlIDPMetaDataOptionsSSOBinding'        => '',
            'samlIDPMetaDataOptionsSLOBinding'        => '',
            'samlIDPMetaDataOptionsResolutionRule'    => '',
        },
    };
}

1;
