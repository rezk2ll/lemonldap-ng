##@file
# LDAP user database backend file

##@class
# LDAP user database backend class
package Lemonldap::NG::Portal::UserDBLDAP;

use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::_LDAP 'ldap';    #link protected ldap

our $VERSION = '0.1';

## @method int userDBInit()
# Does nothing.
# @return Lemonldap::NG::Portal constant
sub userDBInit {
    PE_OK;
}

## @apmethod int getUser()
# 7) Launch formateFilter() and search()
# @return Lemonldap::NG::Portal constant
sub getUser {
    my $self = shift;
    return $self->_subProcess(qw(formateFilter search));
}

## @apmethod protected int formateFilter()
# Set the LDAP filter.
# By default, the user is searched in the LDAP server with its UID.
# @return Lemonldap::NG::Portal constant
sub formateFilter {
    my $self = shift;
    $self->{filter} =
         $self->{authFilter}
      || $self->{filter};
    $self->{filter} =~ s/\$(user|_?password)/$self->{$1}/g;
    $self->{filter} =~ s/\$(\w+)/$self->{sessionInfo}->{$1}/g;
    $self->{filter} ||= "(&(uid=" . $self->{user} . ")(objectClass=inetOrgPerson))";
    PE_OK;
}

## @apmethod protected int search()
# Search the LDAP DN of the user.
# @return Lemonldap::NG::Portal constant
sub search {
    my $self = shift;
    unless ( $self->ldap ) {
        return PE_LDAPCONNECTFAILED;
    }
    my $mesg = $self->ldap->search(
        base   => $self->{ldapBase},
        scope  => 'sub',
        filter => $self->{filter},
    );
    if ( $mesg->code() != 0 ) {
        $self->lmLog( $mesg->error, 'error' );
        return PE_LDAPERROR;
    }
    unless ( $self->{entry} = $mesg->entry(0) ) {
        $self->_sub('userError',"$self->{user} was not found in LDAP directory");
        return PE_BADCREDENTIALS;
    }
    $self->{dn} = $self->{entry}->dn();
    PE_OK;
}

## @apmethod int setSessionInfo()
# 7) Load all parameters included in exportedVars parameter.
# Multi-value parameters are loaded in a single string with
# '; ' separator
# @return Lemonldap::NG::Portal constant
sub setSessionInfo {
    my ($self) = @_;
    $self->{sessionInfo}->{dn} = $self->{dn};
    unless ( $self->{exportedVars} ) {
        foreach (qw(uid cn mail)) {
            $self->{sessionInfo}->{$_} =
              join( '; ', $self->{entry}->get_value($_) ) || "";
        }
    }
    elsif ( ref( $self->{exportedVars} ) eq 'HASH' ) {
        foreach ( keys %{ $self->{exportedVars} } ) {
            if ( my $tmp = $ENV{$_} ) {
                $tmp =~ s/[\r\n]/ /gs;
                $self->{sessionInfo}->{$_} = $tmp;
            }
            else {
                $self->{sessionInfo}->{$_} = join( '; ',
                    $self->{entry}->get_value( $self->{exportedVars}->{$_} ) )
                  || "";
            }
        }
    }
    else {
        $self->abort('Only hash reference are supported now in exportedVars');
    }
    PE_OK;
}

1;

