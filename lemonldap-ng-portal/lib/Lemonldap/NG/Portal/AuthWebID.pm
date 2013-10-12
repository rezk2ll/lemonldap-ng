##@file
# WebID authentication backend file

#############################
### EXPERIMENTAL MODULE ! ###
#############################

##@class
# WebID authentication backend class
package Lemonldap::NG::Portal::AuthWebID;

use strict;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::AuthSSL;

our $VERSION = '1.3.0';
our @ISA     = qw(Lemonldap::NG::Portal::AuthSSL);
our $initDone;

BEGIN {
    eval {
        require threads::shared;
        threads::shared::share($initDone);
    };
}

## @apmethod int authInit()
# @return Lemonldap::NG::Portal constant
sub authInit {
    my $self = shift;
    my $tmp  = $self->SUPER::authInit(@_);
    return $tmp unless ( $tmp eq PE_OK );
    unless ($initDone) {
        eval "use Web::ID";
        $self->abort( 'Unable to load Web::ID', $@ ) if ($@);
        $initDone++;
    }
    PE_OK;
}

sub extractFormInfo {
    my $self = shift;
    my $tmp  = $self->SUPER::extractFormInfo(@_);
    return $tmp unless ( $tmp eq PE_OK );
    return PE_CERTIFICATEREQUIRED
      unless ( $ENV{SSL_CLIENT_CERT}
        and $self->{webid} =
        Web::ID->new( certificate => $ENV{SSL_CLIENT_CERT} ) );
    return ( $self->{webid}->valid() ? PE_OK : PE_BADCREDENTIALS );
}
1;
__END__
