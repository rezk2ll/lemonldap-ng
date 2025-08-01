use warnings;
use Test::More;
use strict;
use IO::String;
use MIME::Base64;
use URI;
use URI::QueryParam;

require 't/test-lib.pm';
require 't/saml-lib.pm';
require 't/oidc-lib.pm';

my $res;

subtest "No keys defined, fallback to old config vars" => sub {
    my $client = LLNG::Manager::Test->new( {
            ini => {
                oidcServicePrivateKeySig    => oidc_key_op_private_sig(),
                oidcServicePublicKeySig     => oidc_cert_op_public_sig(),
                oidcServiceKeyIdSig         => "currentkey",
                samlServicePrivateKeySig    => saml_key_idp_private_sig(),
                samlServicePublicKeySig     => saml_key_idp_public_sig(),
                samlServicePrivateKeySigPwd => "mypass",
                samlServicePrivateKeyEnc    => saml_key_idp_private_enc(),
                samlServicePublicKeyEnc     => saml_key_idp_public_enc(),
                samlServicePrivateKeyEncPwd => "mypass",
                customPlugins               => "t::TestKeys"
            }
        }
    );

    my $instance = $client->p->loadedModules->{'t::TestKeys'};

    is( $instance->get_private_key(undef),
        undef, "Invalid key ID returns undef" );
    is( $instance->get_private_key(""), undef, "Invalid key ID returns undef" );
    is( $instance->get_private_key("notfound"),
        undef, "Invalid key ID returns undef" );

    is( $instance->get_public_key(undef),
        undef, "Invalid key ID returns undef" );
    is( $instance->get_public_key(""), undef, "Invalid key ID returns undef" );
    is( $instance->get_public_key("notfound"),
        undef, "Invalid key ID returns undef" );

    is_deeply(
        $instance->get_public_key("default-saml-sig"),
        {
            'external_id' => 'default-saml-sig',
            'public'      => saml_key_idp_public_sig(),
        },
        "Default SAML public signature key is as expected"
    );
    is_deeply(
        $instance->get_private_key("default-saml-sig"),
        {
            'external_id' => 'default-saml-sig',
            'password'    => 'mypass',
            'private'     => saml_key_idp_private_sig(),
            'public'      => saml_key_idp_public_sig(),
        },
        "Default SAML private signature key is as expected"
    );

    is_deeply(
        $instance->get_public_key("default-saml-enc"),
        {
            'external_id' => 'default-saml-enc',
            'public'      => saml_key_idp_public_enc(),
        },
        "Default SAML public encryption key is as expected"
    );
    is_deeply(
        $instance->get_private_key("default-saml-enc"),
        {
            'external_id' => 'default-saml-enc',
            'password'    => 'mypass',
            'private'     => saml_key_idp_private_enc(),
            'public'      => saml_key_idp_public_enc(),
        },
        "Default SAML private encryption key is as expected"
    );

    is_deeply(
        $instance->get_public_key("default-oidc-sig"),
        {
            'external_id' => 'currentkey',
            'public'      => oidc_cert_op_public_sig(),
        },
        "Default OIDC public key is as expected"
    );
    is_deeply(
        $instance->get_private_key("default-oidc-sig"),
        {
            'external_id' => 'currentkey',
            'password'    => '',
            'private'     => oidc_key_op_private_sig(),
            'public'      => oidc_cert_op_public_sig(),
        },
        "Default OIDC private key is as expected"
    );
};

subtest "Explicit key has priority over legacy conf" => sub {
    my $client = LLNG::Manager::Test->new( {
            ini => {
                keys => {
                    "default-saml-sig" => {
                        keyPrivate => saml_key_idp_private_sig(),
                        keyPublic  => saml_key_idp_public_sig(),
                    }
                },
                issuerDBSAMLActivation          => 1,
                issuerDBOpenIDConnectActivation => 1,
                samlServicePrivateKeySig        => "invalid",
                samlServicePublicKeySig         => "invalid",
                samlServicePrivateKeySigPwd     => "invalid",
                oidcServicePrivateKeySig        => oidc_key_op_private_sig(),
                oidcServicePublicKeySig         => oidc_cert_op_public_sig(),
                oidcServiceKeyIdSig             => "currentkey",
                customPlugins                   => "t::TestKeys"
            }
        }
    );
    my $instance = $client->p->loadedModules->{'t::TestKeys'};

    is_deeply(
        $instance->get_public_key("default-saml-sig"),
        {
            'external_id' => 'default-saml-sig',
            'public'      => saml_key_idp_public_sig(),
        },
        "Default SAML public key is as expected"
    );
    is_deeply(
        $instance->get_private_key("default-saml-sig"),
        {
            'external_id' => 'default-saml-sig',
            'password'    => '',
            'private'     => saml_key_idp_private_sig(),
            'public'      => saml_key_idp_public_sig(),
        },
        "Default SAML private key is as expected"
    );
};

subtest "Explicit key only" => sub {
    my $client = LLNG::Manager::Test->new( {
            ini => {
                keys => {
                    "default-saml-sig" => {
                        keyPrivate => saml_key_idp_private_sig(),
                        keyPublic  => saml_key_idp_public_sig(),
                    }
                },
                issuerDBSAMLActivation          => 1,
                issuerDBOpenIDConnectActivation => 1,
                oidcServicePrivateKeySig        => oidc_key_op_private_sig(),
                oidcServicePublicKeySig         => oidc_cert_op_public_sig(),
                oidcServiceKeyIdSig             => "currentkey",
                customPlugins                   => "t::TestKeys"
            }
        }
    );
    my $instance = $client->p->loadedModules->{'t::TestKeys'};

    is_deeply(
        $instance->get_public_key("default-saml-sig"),
        {
            'external_id' => 'default-saml-sig',
            'public'      => saml_key_idp_public_sig(),
        },
        "Default SAML public key is as expected"
    );
    is_deeply(
        $instance->get_private_key("default-saml-sig"),
        {
            'external_id' => 'default-saml-sig',
            'password'    => '',
            'private'     => saml_key_idp_private_sig(),
            'public'      => saml_key_idp_public_sig(),
        },
        "Default SAML private key is as expected"
    );
};

clean_sessions();

done_testing();

BEGIN {

    package t::TestKeys;
    use Test::More;
    use Mouse;
    extends 'Lemonldap::NG::Portal::Main::Plugin';
    with 'Lemonldap::NG::Portal::Lib::Key';

}
1;
