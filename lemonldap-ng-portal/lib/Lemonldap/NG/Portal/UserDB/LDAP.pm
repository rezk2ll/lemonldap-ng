package Lemonldap::NG::Portal::UserDB::LDAP;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants
  qw(PE_OK PE_LDAPCONNECTFAILED PE_LDAPERROR PE_BADCREDENTIALS);
use Lemonldap::NG::Portal::Lib::LDAP;

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
        $ldap = Lemonldap::NG::Portal::Lib::LDAP->new(
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

has ldapGroupAttributeNameSearch => (
    is      => 'rw',
    builder => sub {
        return $_[0]->{conf}->{ldapGroupAttributeNameSearch}
          ? [
            split( /\s+/, $_[0]->{conf}->{ldapGroupAttributeNameSearch} ),

            # Push group attribute value for recursive search
            (
                $_[0]->{conf}->{ldapGroupRecursive}
                  and $_[0]->{conf}->{ldapGroupAttributeNameGroup} ne "dn"
                ? $_[0]->{conf}->{ldapGroupAttributeNameGroup}
                : ()
            )
          ]
          : [];
    }
);

has attrs => (
    is      => 'rw',
    builder => sub {
        return [
            values %{ $_[0]->{conf}->{exportedVars} },
            values %{ $_[0]->{conf}->{ldapExportedVars} }
        ];
    }
);

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

# RUNNING METHODS

sub getUser {
    my ( $self, $req ) = @_;
    return PE_LDAPCONNECTFAILED unless $self->ldap and $self->bind();
    my $mesg = $self->ldap->search(
        base   => $self->conf->{ldapBase},
        scope  => 'sub',
        filter => $self->filter->($req),
        defer  => $self->conf->{ldapSearchDeref} || 'find',
        attrs  => $self->attrs,
    );
    if ( $mesg->code() != 0 ) {
        $self->lmLog( 'LDAP Search error: ' . $mesg->error, 'error' );
        return PE_LDAPERROR;
    }
    if ( $mesg->count() > 1 ) {
        $self->lmLog( 'More than one entry returned by LDAP directory',
            'error' );
        return PE_BADCREDENTIALS;
    }
    unless ( $req->datas->{entry} = $mesg->entry(0) ) {
        my $user = $req->{mail} || $req->{user};
        $self->p->userError("$user was not found in LDAP directory");
        return PE_BADCREDENTIALS;
    }
    $req->datas->{dn} = $req->datas->{entry}->dn();
    PE_OK;
}

# Load all parameters included in exportedVars parameter.
# Multi-value parameters are loaded in a single string with
# a separator (param multiValuesSeparator)
# @return Lemonldap::NG::Portal constant
sub setSessionInfo {
    my ( $self, $req ) = @_;
    $req->{sessionInfo}->{dn} = $req->datas->{dn};

    my %vars = ( %{ $self->conf->{exportedVars} },
        %{ $self->conf->{ldapExportedVars} } );
    while ( my ( $k, $v ) = each %vars ) {
        $self->{sessionInfo}->{$k} =
          $self->{ldap}->getLdapValue( $req->datas->{entry}, $v ) || "";
    }

    PE_OK;
}

# Load all groups in $groups.
# @return Lemonldap::NG::Portal constant
sub setGroups {
    my ( $self, $req ) = @_;
    my $groups  = $req->{sessionInfo}->{groups};
    my $hGroups = $req->{sessionInfo}->{hGroups};

    if ( $self->conf->{ldapGroupBase} ) {

        # Get value for group search
        my $group_value = $self->ldap->getLdapValue( $req->datas->{entry},
            $self->conf->{ldapGroupAttributeNameUser} );

        $self->lmLog(
            "Searching LDAP groups in "
              . $self->{ldapGroupBase}
              . " for $group_value",
            'debug'
        );

        # Call searchGroups
        my $ldapGroups = $self->ldap->searchGroups(
            $self->conf->{ldapGroupBase},
            $self->conf->{ldapGroupAttributeName},
            $group_value, $self->ldapGroupAttributeNameSearch
        );

        foreach ( keys %$ldapGroups ) {
            my $groupName = $_;
            $hGroups->{$groupName} = $ldapGroups->{$groupName};
            my $groupValues = [];
            foreach ( @{ $self->ldapGroupAttributeNameSearch } ) {
                next if $_ =~ /^name$/;
                my $firstValue = $ldapGroups->{$groupName}->{$_}->[0];
                push @$groupValues, $firstValue;
            }
            $groups .=
              $self->conf->{multiValuesSeparator} . join( '|', @$groupValues );
        }

    }

    $self->{sessionInfo}->{groups} = $groups;
    PE_OK;
}

1;
