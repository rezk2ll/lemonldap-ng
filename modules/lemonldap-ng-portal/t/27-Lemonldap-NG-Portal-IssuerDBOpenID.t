package My::Portal;

use Test::More tests => 8;
use strict;

our @ISA = qw(Lemonldap::NG::Portal::IssuerDBOpenID
  Lemonldap::NG::Portal::OpenID::SREG);

sub lmLog {
    my ( $self, $msg, $level ) = splice @_;
    #print STDERR "[$level] $msg\n";
}

our $CONFIRM;

sub param {
    my ( $self, $key ) = splice @_;
    return { confirm => $CONFIRM, }->{$key};
}

sub info                    { }
sub _sub                    { }
sub updatePersistentSession { }

SKIP: {
    eval { require Net::OpenID::Server; };
    skip(
        "Net::OpenID::Consumer is not installed, so "
          . "Lemonldap::NG::Portal::AuthOpenID will not be useable",
        2
    ) if ($@);
    use_ok('Lemonldap::NG::Portal::OpenID::Server');
    use_ok('Lemonldap::NG::Portal::IssuerDBOpenID');
    use_ok('Lemonldap::NG::Portal::OpenID::SREG');

    my $p = bless {}, __PACKAGE__;

    my ( $r, $h );
    ( $r, $h ) = $p->sregHook( '', '', 0, 0, {} );
    ok( $r == 0, 'Call sregHook with untrusted request' );
    $CONFIRM = -1;
    ok( !$p->sregHook( '', '', 1, 1, {} ), 'Call sregHook with confirm => -1' );
    $CONFIRM = 1;
    ok( $p->sregHook( '', '', 1, 1, {} ), 'Call sregHook without arguments' );
    ( $r, $h ) =
      $p->sregHook( '', '', 1, 1,
        { required => 'fullname,email', optional => 'nickname' },
      );
    ok( $r == 0, 'Unconfigured required attributes' );
    $p->{openIdSreg_fullname} = '$uid';
    $p->{openIdSreg_email}    = '$mail';
    ( $r, $h ) =
      $p->sregHook( '', '', 1, 1,
        { required => 'fullname,email', optional => 'nickname' },
      );
    ok( $r == 1, 'Configured required attributes' );
}
