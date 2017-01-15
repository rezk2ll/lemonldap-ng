package Lemonldap::NG::Portal::Lib::LDAP;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Lib::Net::LDAP;

extends 'Lemonldap::NG::Common::Module';

our $VERSION = '2.0.0';

# PROPERTIES

has ldap => (
    is      => 'rw',
    lazy    => 1,
    builder => 'newLdap',
);

sub newLdap {
    my $self = $_[0];
    my $ldap;

    # Build object and test LDAP connexion
    if (
        $ldap = Lemonldap::NG::Portal::Lib::Net::LDAP->new(
            { p => $self->{p}, conf => $self->{conf} }
        )
        and my $msg = $ldap->bind
      )
    {
        if ( $msg->code != 0 ) {
            $self->lmLog( "LDAP error: " . $msg->error, 'error' );
        }
        else {
            if ( $self->{conf}->{ldapPpolicyControl} and not $ldap->loadPP() ) {
                $self->lmLog( "LDAP password policy error", 'error' );
            }
        }
    }
    else {
        $self->lmLog( "LDAP error: $@", 'error' );
    }
    return $ldap;
}

has filter => (
    is      => 'rw',
    lazy    => 1,
    builder => 'buildFilter',
);

sub buildFilter {
    my $conf = $_[0]->{conf};
    $_[0]->{p}->lmLog( "LDAP Search base: $_[0]->{conf}->{ldapBase}", 'debug' );

    # TODO : mailLDAPFilter
    my $filter =
         $conf->{AuthLDAPFilter}
      || $conf->{LDAPFilter}
      || '(&(uid=$user)(objectClass=inetOrgPerson))';
    $filter =~ s/"/\\"/g;
    $filter =~ s/\$(\w+)/".\$req->{sessionInfo}->{$1}."/g;
    $filter =~ s/\$req->\{sessionInfo\}->\{user\}/\$req->{user}/g;
    $filter =~
      s/\$req->\{sessionInfo\}->\{(_?password|mail)\}/\$req->{datas}->{$1}/g;
    $_[0]->{p}->lmLog( "LDAP transformed filter: $filter", 'debug' );
    $filter = "sub{my(\$req)=\$_[0];return \"$filter\";}";
    return eval $filter;
}

# INITIALIZATION

sub init {
    my ($self) = @_;
    $self->ldap and $self->filter;
}
# RUNNING METHODS

# Test LDAP connection before trying to bind
sub bind {
    my $self = shift;
    unless ($self->ldap
        and $self->ldap->root_dse( attrs => ['supportedLDAPVersion'] ) )
    {
        $self->ldap( $self->newLdap );
    }
    return undef unless($self->ldap);
    my $msg = $self->ldap->bind(@_);
    if ( $msg->code ) {
        $self->lmLog( $msg->error, 'error' );
        return undef;
    }
    return 1;
}

1;
