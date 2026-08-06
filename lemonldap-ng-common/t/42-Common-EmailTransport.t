use warnings;
use strict;
use Test::More;

BEGIN { use_ok('Lemonldap::NG::Common::EmailTransport') }

my %base = (
    SMTPServer   => 'smtp.example.com',
    SMTPPort     => 587,
    SMTPAuthUser => 'dwho',
    SMTPAuthPass => 'dwho',
);

# No SMTP server -> no transport (local sendmail is used)
is( Lemonldap::NG::Common::EmailTransport->new( {} ),
    undef, 'No transport without SMTPServer' );

# Default: credentials are given to Net::SMTP which chooses the mechanism
my $transport = Lemonldap::NG::Common::EmailTransport->new( {%base} );
is( $transport->sasl_username, 'dwho', 'sasl_username is set' );
is( $transport->sasl_password, 'dwho', 'sasl_password is set' );
ok( !$transport->sasl_authenticator, 'No SASL authenticator by default' );

SKIP: {
    skip 'Email::Sender is too old to select the SASL mechanism', 4
      unless Email::Sender::Transport::SMTP->can('sasl_authenticator');
    eval { require Authen::SASL; };
    skip 'Authen::SASL is not installed', 4 if $@;

    # SMTPAuthMech: an Authen::SASL object restricted to the wanted
    # mechanism(s) is used instead
    $transport = Lemonldap::NG::Common::EmailTransport->new(
        { %base, SMTPAuthMech => 'PLAIN LOGIN CRAM-MD5' } );
    ok( !$transport->sasl_username, 'sasl_username is not set' );
    my $sasl = $transport->sasl_authenticator;
    ok( $sasl, 'SASL authenticator is set' );
    is( $sasl->mechanism, 'PLAIN LOGIN CRAM-MD5', 'Mechanisms are restricted' );

    # Only the wanted mechanism is used
    $transport = Lemonldap::NG::Common::EmailTransport->new(
        { %base, SMTPAuthMech => 'PLAIN' } );
    my $client =
      $transport->sasl_authenticator->client_new( 'smtp', 'smtp.example.com' );
    is( $client->mechanism, 'PLAIN', 'Chosen mechanism' );
}

# SMTPAuthMech is ignored when no user is set
$transport = Lemonldap::NG::Common::EmailTransport->new(
    { %base, SMTPAuthUser => '', SMTPAuthMech => 'PLAIN' } );
ok( !$transport->sasl_username,      'No sasl_username without SMTPAuthUser' );
ok( !$transport->sasl_authenticator, 'No SASL object without SMTPAuthUser' );

done_testing();
