package Lemonldap::NG::Portal::_LDAP;

use Net::LDAP;

our $VERSION = '0.1';

sub new {
    my $class = shift;
    my $portal = shift;
    unless($portal) {
        die("$class : portal argument required !");
    }
    my $self = bless {portal=>$portal},$class;
    $self->{ldapServer}         = $portal->{ldapServer} || 'localhost';
    $self->{ldapPort}           = $portal->{ldapPort} || 389;
    $self->{ldapPpolicyControl} = $portal->{ldapPpolicyControl} || 0;
    $self->{managerDn} = $portal->{managerDn};
    $self->{managerPassword} = $portal->{managerPassword};
    $self->bind or return 0;
    return $self;
}

# Private sub used to bind to LDAP server both with Lemonldap::NG account and user
# credentials if LDAP authentication is used
sub _bind {
    my ( $self, $dn, $password ) = @_;
    my $mesg;
    if ( $dn and $password ) {    # named bind
        $mesg = $self->{ldap}->bind( $dn, password => $password );
    }
    else {                        # anonymous bind
        $mesg = $self->{ldap}->bind();
    }
    if ( $mesg->code() != 0 ) {
        return 0;
    }
    return 1;
}

# 5. First LDAP connexion used to find user DN with the filter defined before.
sub connectLDAP {
    my $self = shift;
    return PE_OK if ( $self->{ldap} );
    my $useTls = 0;
    my $tlsParam;
    foreach my $server ( split /[\s,]+/, $self->{ldapServer} ) {
        if ( $server =~ m{^ldap\+tls://([^/]+)/?\??(.*)$} ) {
            $useTls   = 1;
            $server   = $1;
            $tlsParam = $2 || "";
        }
        else {
            $useTls = 0;
        }
        last
          if $self->{ldap} = Net::LDAP->new(
            $server,
            port    => $self->{ldapPort},
            onerror => undef,
          );
    }
    return PE_LDAPCONNECTFAILED unless ( $self->{ldap} );
    if ($useTls) {
        my %h = split( /[&=]/, $tlsParam );
        $h{cafile} = $self->{caFile} if ( $self->{caFile} );
        $h{capath} = $self->{caPath} if ( $self->{caPath} );
        my $mesg = $self->{ldap}->start_tls(%h);
        $mesg->code && return PE_LDAPCONNECTFAILED;
    }
    PE_OK;
}

sub search {
    shift->{ldap}->search(@_);
}

# 6. LDAP bind with Lemonldap::NG account or anonymous unless defined
sub bind {
    my $self = shift;
    $self->connectLDAP unless ( $self->{ldap} );
    return 0
      unless (
        $self->_bind(
            $self->{managerDn}, $self->{managerPassword}
        )
      );
    PE_OK;
}

# 11. Now, LDAP will not be used by Lemonldap::NG except for LDAP
#     authentication scheme
sub unbind {
    my $self = shift;
    $self->{ldap}->unbind if $self->{ldap};
    delete $self->{ldap};
    PE_OK;
}

1;

