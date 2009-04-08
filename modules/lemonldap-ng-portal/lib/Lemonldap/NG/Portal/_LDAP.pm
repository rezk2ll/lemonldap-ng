##@file
# LDAP common functions

##@class
# LDAP common functions
package Lemonldap::NG::Portal::_LDAP;

require Net::LDAP; #inherits
use Exporter;
use base qw(Exporter Net::LDAP);
use Lemonldap::NG::Portal::Simple;
use strict;

our @EXPORT = qw(ldap);

our $VERSION = '0.11';

## @cmethod Lemonldap::NG::Portal::_LDAP new(Lemonldap::NG::Portal::Simple portal)
# Build a Net::LDAP object using parameters issued from $portal
# @return Lemonldap::NG::Portal::_LDAP object
sub new {
    my $class  = shift;
    my $portal = shift;
    my $self;
    unless ($portal) {
        $class->abort("$class : portal argument required !");
    }
    my $useTls = 0;
    my $tlsParam;
    my @servers = ();
    foreach my $server ( split /[\s,]+/, $portal->{ldapServer} ) {
        if ( $server =~ m{^ldap\+tls://([^/]+)/?\??(.*)$} ) {
            $useTls   = 1;
            $server   = $1;
            $tlsParam = $2 || "";
        }
        else {
            $useTls = 0;
        }
        push @servers, $server;
    }
    $self = Net::LDAP->new(
        \@servers,
            onerror => undef,
        ( $portal->{ldapPort} ? ( port => $portal->{ldapPort} ) : () ),
          );
    unless ($self) {
        $portal->lmLog( $@, 'error' );
        return 0;
    }
    bless $self, $class;
    if ($useTls) {
        my %h = split( /[&=]/, $tlsParam );
        $h{cafile} = $portal->{caFile} if ( $portal->{caFile} );
        $h{capath} = $portal->{caPath} if ( $portal->{caPath} );
        my $mesg = $self->start_tls(%h);
        if ( $mesg->code ) {
            $portal->lmLog( 'StartTLS failed', 'error' );
            return 0;
        }
    }
    $self->{portal} = $portal;
    return $self;
}

## @method Net::LDAP::Message bind(string dn, %args)
# Reimplementation of Net::LDAP::bind(). Connection is done :
# - with $dn and $args->{password} as dn/password if defined,
# - or with Lemonldap::NG account,
# - or with an anonymous bind.
# @param $dn LDAP distinguish name
# @param %args See Net::LDAP(3) manpage for more
# @return Net::LDAP::Message
sub bind {
    my $self = shift;
    my $mesg;
    my ( $dn, %args ) = @_;
    unless ($dn) {
        $dn = $self->{portal}->{managerDn};
        $args{password} = $self->{portal}->{managerPassword};
    }
    if ( $dn && $args{password} ) {
        $mesg = $self->SUPER::bind( $dn, %args );
    }
    else {
        $mesg = $self->SUPER::bind();
    }
    return $mesg;
}

our $ppLoaded = 0;

## @method private boolean loadPP ()
# Load Net::LDAP::Control::PasswordPolicy
# @return true if succeed.
sub loadPP {
    my $self = shift;
    return 1 if ($ppLoaded);

    # require Perl module
    eval 'require Net::LDAP::Control::PasswordPolicy';
    if ($@) {
        $self->lmLog(
            "Module Net::LDAP::Control::PasswordPolicy not found in @INC",
            'error' );
        return 0;
    }
    $ppLoaded = 1;
}

## @method protected int userBind(string dn, %args)
# Call bind() with and return
# @param $dn LDAP distinguish name
# @param %args See Net::LDAP(3) manpage for more
# @return Lemonldap::NG portal error code
sub userBind {
    my $self = shift;
    if ( $self->{portal}->{ldapPpolicyControl} ) {

        # Create Control object
        my $pp = Net::LDAP::Control::PasswordPolicy->new();

        # Bind with user credentials
        my $mesg = $self->bind(
            @_,
            control  => [$pp]
        );

        # Get server control response
        my ($resp) = $mesg->control("1.3.6.1.4.1.42.2.27.8.5.1");
        return ( $mesg->code == 0 ? PE_OK : PE_LDAPERROR )
          unless ( defined $resp );

        # Get expiration warning and graces
        # 
        $self->{portal}->{mustRedirect} = 0 if($self->{portal}->{ppolicy}->{time_before_expiration} = $resp->time_before_expiration or $self->{portal}->{ppolicy}->{grace_authentications_remaining} = $resp->grace_authentications_remaining);

        my $pp_error = $resp->pp_error;
        if ( defined $pp_error ) {
            #return [
            #    PE_PP_PASSWORD_EXPIRED,
            #    PE_PP_ACCOUNT_LOCKED,
            #    PE_PP_CHANGE_AFTER_RESET,
            #    PE_PP_PASSWORD_MOD_NOT_ALLOWED,
            #    PE_PP_MUST_SUPPLY_OLD_PASSWORD,
            #    PE_PP_INSUFFICIENT_PASSWORD_QUALITY,
            #    PE_PP_PASSWORD_TOO_SHORT,
            #    PE_PP_PASSWORD_TOO_YOUNG,
            #    PE_PP_PASSWORD_IN_HISTORY,
            #]->[$pp_error];
            return $pp_error + PE_PP_PASSWORD_EXPIRED;
        }
        elsif ( $mesg->code == 0 ) {
            return PE_OK;
        }
    }
    else {
        my $mesg =
          $self->bind( @_ );
        if ( $mesg->code == 0 ) {
            return PE_OK;
        }
    }
    $self->{portal}->_sub( 'userError', "Bad password for $self->{user}" );
    return PE_BADCREDENTIALS;
}

## @method protected Lemonldap::NG::Portal::_LDAP ldap()
# @return Lemonldap::NG::Portal::_LDAP object
sub ldap {
    my $self = shift;
    return $self->{ldap} if ( ref( $self->{ldap} ) );
    if ( $self->{ldap} = Lemonldap::NG::Portal::_LDAP->new($self)
        and my $mesg = $self->{ldap}->bind )
    {
        return $self->{ldap} if ( $mesg->code == 0 );
        $self->lmLog( "LDAP error : " . $mesg->error, 'error' );
    }
    else {
        $self->lmLog( "LDAP error : $@", 'error' );
    }
    return 0;
}

1;
