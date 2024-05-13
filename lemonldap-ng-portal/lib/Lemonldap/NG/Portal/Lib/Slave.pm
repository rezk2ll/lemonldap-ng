##@file
# Slave common functions

##@class
# Slave common functions
package Lemonldap::NG::Portal::Lib::Slave;

use strict;
use Mouse;
use Regexp::Common;

our $VERSION = '2.20';

# RUNNING METHODS

## @method Lemonldap::NG::Portal::_Slave checkIP()
# @return true if remote IP is accredited in LL::NG conf
sub checkIP {
    my ( $self, $req ) = @_;
    my $remoteIP = $req->address;
    my ( @regexpIP, @IPs );

    return 1
      if !$self->conf->{slaveMasterIP};

    @IPs = grep {
        if (m#^/(.+)?/$#) {
            push @regexpIP, qr/$1/;
            $self->logger->debug("Found IP regexp: $1");
            0;
        }
        elsif (m/$RE{net}{IPv4}/) {
            $self->logger->debug("Found IP address: $_");
            1;
        }
        elsif (m/$RE{net}{IPv6}/) {
            $self->logger->debug("Found IP address: $_");
            1;
        }
        else {
            $self->logger->warn("Found a non valid IP: $_");
            0;
        }
    } split /[,\s]/, $self->conf->{slaveMasterIP};

    foreach (@IPs) {
        return 1
          if $remoteIP eq $_;
    }
    foreach (@regexpIP) {
        return 1
          if $remoteIP =~ $_;
    }

    $self->userLogger->warn('Client IP not accredited for Slave module');
    return 0;
}

## @method Lemonldap::NG::Portal::_Slave checkHeader()
# @return true if header content matches LL::NG conf
sub checkHeader {
    my ( $self, $req ) = @_;
    return 1
      unless ( $self->conf->{slaveHeaderName}
        and $self->conf->{slaveHeaderContent} );

    my $slave_header = 'HTTP_' . uc( $self->conf->{slaveHeaderName} );
    $slave_header =~ s/\-/_/g;
    my $headerContent = $req->env->{$slave_header};

    $self->logger->debug(
            "Required slave header: $self->{conf}->{slaveHeaderName}"
          . "\nReceived slave header content: $headerContent" );

    return 1
      if (  $headerContent
        and $self->conf->{slaveHeaderContent} =~ /\b$headerContent\b/ );

    $self->userLogger->warn('Matching header not found for AuthSlave module ');
    return 0;
}

1;
