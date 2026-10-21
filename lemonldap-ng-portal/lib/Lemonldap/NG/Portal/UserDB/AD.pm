# UserDB::AD inherits from UserDB::LDAP. It just redefined default filter
package Lemonldap::NG::Portal::UserDB::AD;

use strict;
use Mouse;

use Lemonldap::NG::Common::Safelib;

our $VERSION = '2.0.11';

extends 'Lemonldap::NG::Portal::UserDB::LDAP';

# PROPERTIES

has filter => (
    is      => 'rw',
    lazy    => 1,
    builder => sub {
        $_[0]->{conf}->{AuthLDAPFilter} ||=
          '(&(sAMAccountName=$user)(objectClass=person))';
        $_[0]->{conf}->{mailLDAPFilter} ||=
          '(&(mail=$mail)(objectClass=person))';
        return $_[0]->buildFilter;
    }
);

has findUserFilter => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        $_[0]->conf->{AuthLDAPFilter}
          || $_[0]->conf->{LDAPFilter}
          || '(&(sAMAccountName=$user)(objectClass=person))';
    }
);

# Include objectGuid/logonHours in raw attributes
sub buildRaw {
    my ($self) = @_;
    my $ad     = qr/(?i:^objectGuid|^logonHours)/;
    my $base   = $self->SUPER::buildRaw;
    return $base ? qr/$base|$ad/ : $ad;
}

# Special processing for logonHours and objectGuid
sub getLdapValue {
    my ( $self, $entry, $attribute ) = @_;

    my $value = $self->SUPER::getLdapValue( $entry, $attribute );

    if ( $attribute =~ /^objectGuid/i and $value ) {

        if ( length($value) != 16 ) {
            $self->logger->info(
                "Invalid value for attribute $attribute in " . $entry->dn );
            return "";
        }
        return Lemonldap::NG::Common::Safelib::bin2guid($value);
    }
    elsif ( $attribute =~ /^logonHours/i and $value ) {
        if ( length($value) != 21 ) {
            $self->logger->info(
                "Invalid value for attribute $attribute in " . $entry->dn );
            return "";
        }

        # Reverse endianness, and store as hexstring
        return unpack( 'H*', pack( 'B*', unpack( 'b*', $value ) ) );
    }
    return $value;
}

1;
