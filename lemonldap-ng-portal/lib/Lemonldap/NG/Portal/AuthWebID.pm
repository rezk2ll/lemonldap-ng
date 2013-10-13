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
use Lemonldap::NG::Common::Regexp;
use Regexp::Assemble;

our $VERSION = '1.3.0';
our @ISA     = qw(Lemonldap::NG::Portal::AuthSSL);
our $initDone;
our $reWebIDWhitelist;

BEGIN {
    eval {
        require threads::shared;
        threads::shared::share($initDone);
        threads::shared::share($reWebIDWhitelist);
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

        # Now examine white list and compile it
        my @hosts = split /\s+/, $self->{webIDWhitelist};
        $self->abort( 'WebID white list is empty',
            'Set it in manager, use * to accept all FOAF providers' )
          unless (@hosts);
        my $re = Regexp::Assemble->new();
        foreach my $h (@hosts) {
            $self->lmLog( "Add $h in WebID whitelist", 'debug' );
            $h = quotemeta($h);
            $h =~ s/\\\*/\.\*\?/g;
            $re->add($h);
        }
        $reWebIDWhitelist = '^https?://' . $re->as_string . '(?:/.*|)$';

    }
    PE_OK;
}

sub extractFormInfo {
    my $self = shift;

    # 1. Verify SSL exchange using AuthSSL::extractFormInfo()
    my $tmp = $self->SUPER::extractFormInfo(@_);
    return $tmp unless ( $tmp eq PE_OK );

    # 2. Return an error if SSL_CLIENT_CERT is not set
    $self->abort( 'SSL configuration error',
        'Unable to get client certificate, SSL_CLIENT_CERT is not set' )
      unless ( $ENV{SSL_CLIENT_CERT} );

    # 3. Verify that certificate is WebID compliant
    return PE_BADCREDENTIALS
      unless ( $self->{webid} =
        Web::ID->new( certificate => $ENV{SSL_CLIENT_CERT} ) );

    # WebID URI is used as user field
    $self->{user} = $self->{webid}->uri;

    # 4. Verify that FOAF host is in white list
    return PE_BADPARTNER unless ( $self->{user} =~ $reWebIDWhitelist );

    # 5. Verify FOAF document
    return PE_BADCREDENTIALS unless ( $self->{webid}->valid() );

    # 6. OK, access granted
    return PE_OK;
}
1;
__END__
