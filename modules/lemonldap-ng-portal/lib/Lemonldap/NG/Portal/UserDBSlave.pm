## @file
# Slave userDB mechanism

## @class
# Slave userDB mechanism class
package Lemonldap::NG::Portal::UserDBSlave;

use strict;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::UserDBNull;

our $VERSION = '1.0.0';
our @ISA     = qw(Lemonldap::NG::Portal::UserDBNull);

## @apmethod int setSessionInfo()
# Search exportedVars values in HTTP headers.
# @return Lemonldap::NG::Portal constant
sub setSessionInfo {
    my $self = shift;
    my $c = 0;
    while ( my ( $k, $v ) = each %{ $self->{exportedVars} } ) {
        $v = 'HTTP_' . uc($v);
        $v =~ s/\-/_/g;
        $self->{sessionInfo}->{$k} = $ENV{$v} and $c++;
    }
    return ( $c ? PE_OK : PE_USERNOTFOUND );
}

1;

