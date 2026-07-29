##@file
# LDAP configuration backend

##@class
# Implements LDAP backend for Lemonldap::NG
package Lemonldap::NG::Common::Conf::Backends::LDAP;

use strict;
use utf8;
use Net::LDAP;
use IO::Socket::Timeout;
use Lemonldap::NG::Common::Conf::Constants;    #inherits
use Lemonldap::NG::Common::Conf::Serializer;

our $VERSION = '3.0.0';

BEGIN {
    *Lemonldap::NG::Common::Conf::getLdapConnection = \&getLdapConnection;
}

sub prereq {
    my $self = shift;

    foreach ( 'ldapServer', 'ldapConfBase' ) {
        unless ( $self->{$_} ) {
            $Lemonldap::NG::Common::Conf::msg .=
              "$_ is required in LDAP configuration type \n";
            return 0;
        }
    }
    unless ( $self->{ldapBindDN} && $self->{ldapBindPassword} ) {
        unless ( $self->{ldapClientCert} && $self->{ldapClientKey} ) {
            $Lemonldap::NG::Common::Conf::msg =
"ldapBindDN/ldapBindPassword or ldapClientCert/ldapClientKey are required in LDAP configuration type \n";
            return 0;
        }

    }
    $self->{ldapObjectClass}      ||= "applicationProcess";
    $self->{ldapAttributeId}      ||= "cn";
    $self->{ldapAttributeContent} ||= "description";
    1;
}

sub available {
    my $self = shift;
    my $ldap = $self->getLdapConnection;
    unless ($ldap) {
        return 0;
    }

    my $search = $ldap->search(
        base   => $self->{ldapConfBase},
        filter => '(objectClass=' . $self->{ldapObjectClass} . ')',
        scope  => 'one',
        attrs  => [ $self->{ldapAttributeId} ],
    );
    $ldap->unbind;

    if ( $search->code ) {
        $self->logError($search);
        return 0;
    }

    my @entries = $search->entries();
    my @conf;
    foreach (@entries) {
        my $cn = $_->get_value( $self->{ldapAttributeId} );
        my ($cfgNum) = ( $cn =~ /lmConf-(\d*)/ );
        push @conf, $cfgNum;
    }
    return sort { $a <=> $b } @conf;
}

sub lastCfg {
    my $self  = shift;
    my @avail = $self->available;
    return $avail[$#avail];
}

sub getLdapConnection {
    my $self = shift;
    my ( @servers, %tlsParams, $useStartTls );

    foreach my $server ( split /[\s,]+/, $self->{ldapServer} ) {
        if ( $server =~ m{^ldap\+tls://([^/]+)/?\??(.*)$} ) {
            $useStartTls = 1;
            $server      = $1;
            %tlsParams   = split( /[&=]/, $2 || "" );
        }
        elsif ( $server =~ m{^(ldaps://[^/]+)/?\??(.*)$} ) {
            $useStartTls = 0;
            $server      = $1;
            %tlsParams   = split( /[&=]/, $2 || "" );
        }
        else {
            $useStartTls = 0;
        }
        push @servers, $server;
    }

    $tlsParams{verify} ||= $self->{ldapVerify} || 'require';
    $tlsParams{cafile} ||= $self->{ldapCAFile}
      if $self->{ldapCAFile};
    $tlsParams{capath}     ||= $self->{ldapCAPath} if $self->{ldapCAPath};
    $tlsParams{clientcert} ||= $self->{ldapClientCert}
      if $self->{ldapClientCert};
    $tlsParams{clientkey} ||= $self->{ldapClientKey}
      if $self->{ldapClientKey};
    require Authen::SASL if $self->{ldapClientCert};

    my $ldap = Net::LDAP->new(
        \@servers,
        onerror   => undef,
        keepalive => 1,
        raw       => qr/(?i:^jpegPhoto|;binary)/,
        %tlsParams,
        ( $self->{ldapPort}    ? ( port    => $self->{ldapPort} )    : () ),
        ( $self->{ldapTimeout} ? ( timeout => $self->{ldapTimeout} ) : () ),
        ( $self->{ldapVersion} ? ( version => $self->{ldapVersion} ) : () ),
    );

    unless ($ldap) {
        $Lemonldap::NG::Common::Conf::msg .= "$@\n";
        return;
    }
    elsif ( $Net::LDAP::VERSION < '0.64' ) {

        # CentOS7 has a bug in which IO::Socket::SSL will return a broken
        # socket when certificate validation fails. Net::LDAP does not catch
        # it, and the process ends up crashing.
        # As a precaution, make sure the underlying socket is doing fine:
        if (    $ldap->socket->isa('IO::Socket::SSL')
            and $ldap->socket->errstr < 0 )
        {
            $Lemonldap::NG::Common::Conf::msg .=
              "SSL connection error: " . $ldap->socket->errstr;
            return;
        }
    }

    # Set socket timeouts
    my $socket  = $ldap->socket;
    my $timeout = $self->{ldapIOTimeout} || 10;
    IO::Socket::Timeout->enable_timeouts_on($socket);
    $socket->read_timeout($timeout);
    $socket->write_timeout($timeout);

    if ($useStartTls) {
        my $mesg = $ldap->start_tls(%tlsParams);
        if ( $mesg->code ) {
            $self->logError($mesg);
            return;
        }
    }

    my $bind = $self->_bind($ldap);
    if ( $bind->code ) {
        $self->logError($bind);
        return;
    }

    return $ldap;
}

sub Lemonldap::NG::Common::Conf::_bind {
    my ( $self, $ldap ) = @_;

    if ( $self->{ldapBindDN} && $self->{ldapBindPassword} ) {
        return $ldap->bind( $self->{ldapBindDN},
            password => $self->{ldapBindPassword} );
    }
    elsif ( $self->{ldapClientCert} && $self->{ldapClientKey} ) {
        my $sasl = Authen::SASL->new(
            mechanism => 'EXTERNAL',
            callback  => { user => '' }
        );
        return $ldap->bind( undef, sasl => $sasl );
    }
    else {
        return $ldap->bind();
    }
}

sub lock {

    # No lock for LDAP
    return 1;
}

sub isLocked {

    # No lock for LDAP
    return 0;
}

sub unlock {

    # No lock for LDAP
    return 1;
}

sub store {
    my ( $self, $fields ) = @_;

    my $ldap = $self->getLdapConnection;
    unless ($ldap) {
        return 0;
    }

    $fields = $self->serialize($fields);

    my $lastCfg = $self->lastCfg;

    my $confName = "lmConf-" . $fields->{cfgNum};
    my $confDN =
      $self->{ldapAttributeId} . "=$confName," . $self->{ldapConfBase};

    # Store values as {key}value
    my @confValues;
    while ( my ( $k, $v ) = each(%$fields) ) {
        push @confValues, "{$k}$v";
    }

    my $operation;

    if ( $lastCfg == $fields->{cfgNum} ) {
        $operation =
          $ldap->modify( $confDN,
            replace => { $self->{ldapAttributeContent} => \@confValues } );
    }
    else {
        $operation = $ldap->add(
            $confDN,
            attrs => [
                objectClass              => [ 'top', $self->{ldapObjectClass} ],
                $self->{ldapAttributeId} => $confName,
                $self->{ldapAttributeContent} => \@confValues,
            ]
        );
    }
    $ldap->unbind;

    if ( $operation->code ) {
        $self->logError($operation);
        return 0;
    }

    return $fields->{cfgNum};
}

sub load {
    my ( $self, $cfgNum, $fields ) = @_;

    my $ldap = $self->getLdapConnection;
    unless ($ldap) {
        return;
    }

    my $f;
    my $confName = "lmConf-" . $cfgNum;
    my $confDN =
      $self->{ldapAttributeId} . "=$confName," . $self->{ldapConfBase};

    my $search = $ldap->search(
        base   => $confDN,
        filter => '(objectClass=' . $self->{ldapObjectClass} . ')',
        scope  => 'base',
        attrs  => [ $self->{ldapAttributeContent} ],
    );
    $ldap->unbind;

    if ( $search->code ) {
        $self->logError($search);
        return;
    }

    my $entry      = $search->shift_entry();
    my @confValues = $entry->get_value( $self->{ldapAttributeContent} );
    foreach (@confValues) {
        my ( $k, $v ) = ( $_ =~ /\{(.*?)\}(.*)/s );
        if ($fields) {
            $f->{$k} = $v if ( grep { $_ eq $k } @$fields );
        }
        else {
            $f->{$k} = $v;
        }
    }
    return $self->unserialize($f);
}

sub delete {
    my ( $self, $cfgNum ) = @_;

    my $ldap = $self->getLdapConnection;
    unless ($ldap) {
        return 0;
    }

    my $confDN =
        $self->{ldapAttributeId}
      . "=lmConf-"
      . $cfgNum . ","
      . $self->{ldapConfBase};
    my $delete = $ldap->delete($confDN);
    $ldap->unbind;
    $self->logError($delete) if $delete->code;
}

sub logError {
    my $self           = shift;
    my $ldap_operation = shift;
    $Lemonldap::NG::Common::Conf::msg .=
        "LDAP error "
      . $ldap_operation->code . ": "
      . $ldap_operation->error . " \n";
}

1;
